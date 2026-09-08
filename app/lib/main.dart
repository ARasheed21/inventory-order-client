import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:core/core.dart';

import 'config/app_env.dart';
import 'config/certificate_pinning.dart';
import 'config/credential_store.dart';
import 'config/observability.dart';
import 'config/router.dart';
import 'config/session_gate.dart';
import 'config/theme.dart';

Future<void> main() async {
  final EnvironmentConfig config = AppEnv.load();
  final Reporter reporter = createReporter(config);

  reporter.log(
    AppLogLevel.info,
    'app.start',
    context: {
      'environment': config.environment.name,
      'api': config.apiBaseUrl.toString(),
    },
  );

  if (config.sentryDsn != null) {
    await SentryFlutter.init((SentryFlutterOptions options) {
      options
        ..dsn = config.sentryDsn
        ..tracesSampleRate = 0.2;
    });
  }

  await configureCore(
    config: config,
    credentialStore: FlutterSecureCredentialStore(),
    reporter: reporter,
    onDioBuilt: (dio) => pinnerFromConfig(config)?.install(dio),
  );

  final ProviderContainer container = ProviderContainer();

  // Route guard + realtime channel follow the live session state.
  bool authenticated = false;
  container.listen(sessionStreamProvider, (_, next) {
    authenticated = next.valueOrNull != null;
    final RealtimeChannel channel = getIt<RealtimeChannel>();
    final Session? session = next.valueOrNull is Session
        ? next.valueOrNull as Session
        : null;
    if (session != null) {
      channel.start(url: config.wsUrl, token: session.accessToken);
    } else {
      channel.stop();
    }
  }, fireImmediately: false);
  final RouterRefresh refresh = RouterRefresh(
    getIt<AuthRepository>().watchSession(),
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: InventoryApp(
        gate: SessionAuthGate(() => authenticated),
        refresh: refresh,
      ),
    ),
  );
}

class InventoryApp extends ConsumerWidget {
  const InventoryApp({required this.gate, required this.refresh, super.key});

  final AuthGate gate;
  final Listenable refresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: AppStrings.common.appName,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: buildAppRouter(gate, refreshListenable: refresh),
    );
  }
}
