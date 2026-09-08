import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../data/cache/read_cache.dart';
import '../data/network/api_http_client.dart';
import '../data/realtime/realtime_channel.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/order_repository_impl.dart';
import '../domain/entities/session.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/order_repository.dart';
import '../infrastructure/observability/reporter.dart';
import 'env_config.dart';

/// Service locator for long-lived core services (plan R5, Constitution III).
///
/// Platform packages register platform-specific implementations (credential
/// stores) BEFORE calling [configureCore].
final GetIt getIt = GetIt.instance;

/// Builds and registers all core services. Call once from platform
/// `main()` after environment configuration is loaded.
///
/// [onDioBuilt] is an optional hook invoked after each Dio instance is
/// configured. Platform packages use it to install certificate pinning
/// (Constitution VIII, FR-013) without pulling `dart:io` into core.
Future<void> configureCore({
  required EnvironmentConfig config,
  required CredentialStore credentialStore,
  Reporter reporter = const ConsoleReporter(),
  void Function(Dio dio)? onDioBuilt,
}) async {
  getIt.registerSingleton<EnvironmentConfig>(config);
  getIt.registerSingleton<Reporter>(reporter);
  getIt.registerSingleton<CredentialStore>(credentialStore);
  getIt.registerSingleton<ReadCache>(InMemoryReadCache());

  final AuthRepositoryImpl repository = AuthRepositoryImpl(
    dio: buildDio(
      config: config,
      credentials: _LazyCredentials(),
      reporter: reporter,
      onDioBuilt: onDioBuilt,
    ),
    credentialStore: credentialStore,
    reporter: reporter,
  );

  // The Dio interceptors resolve credentials lazily through getIt so the
  // repository and client can reference each other without a cycle.
  getIt.registerSingleton<SessionCredentials>(_LazyCredentials());
  getIt.registerSingleton<AuthRepositoryImpl>(repository);
  getIt.registerSingleton<AuthRepository>(repository);
  getIt.registerSingleton<OrderRepository>(
    OrderRepositoryImpl(
      dio: buildDio(
        config: config,
        credentials: _LazyCredentials(),
        onDioBuilt: onDioBuilt,
      ),
      cache: getIt<ReadCache>(),
    ),
  );
  getIt.registerSingleton<RealtimeChannel>(RealtimeChannel(reporter: reporter));

  await repository.restore();
}

/// Bridges Dio to the registered [AuthRepository] without creating a
/// construction-time dependency cycle.
final class _LazyCredentials implements SessionCredentials {
  SessionCredentials? get _delegate {
    try {
      return getIt<AuthRepositoryImpl>();
    } on Object {
      return null;
    }
  }

  @override
  String? get accessToken => _delegate?.accessToken;

  @override
  Future<String?> renewAccessToken() =>
      _delegate?.renewAccessToken() ?? Future<String?>.value(null);
}
