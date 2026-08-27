import 'dart:async';

import 'package:jaspr/client.dart';
import 'package:sentry/sentry.dart';

import 'package:core/core.dart';

import 'config/app_env.dart';
import 'config/credential_store.dart';
import 'config/observability.dart';
import 'config/session_gate.dart';
import 'routes/routes.dart';

bool authenticated = false;

Future<void> main() async {
  final config = await WebEnv.load();
  final reporter = createReporter(config);

  reporter.log(
    AppLogLevel.info,
    'web.start',
    context: {'environment': config.environment.name},
  );

  final dsn = config.sentryDsn;
  if (dsn != null) {
    await Sentry.init((SentryOptions options) {
      options
        ..dsn = dsn
        ..tracesSampleRate = 0.2;
    });
  }

  await configureCore(
    config: config,
    credentialStore: BrowserCredentialStore(),
    reporter: reporter,
  );

  // Realtime channel + auth flag follow the live session state.
  // Session subscription drives the route guard + realtime channel:
  // ignore: unused_local_variable
  final StreamSubscription<Session?> sub = getIt<AuthRepository>()
      .watchSession()
      .listen((session) {
        authenticated = session != null;
        final channel = getIt<RealtimeChannel>();
        if (session != null) {
          channel.start(url: config.wsUrl, token: session.accessToken);
        } else {
          channel.stop();
        }
      });

  // Attaches the routed app component to the <body> of the page.
  runApp(buildAppRouter(SessionAuthGate(() => authenticated)));
}
