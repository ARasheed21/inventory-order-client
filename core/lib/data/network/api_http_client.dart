import 'package:dio/dio.dart';

import '../../application/env_config.dart';
import '../../infrastructure/observability/reporter.dart';
import 'auth_interceptor.dart';

/// Source of session credentials for request signing and renewal.
abstract interface class SessionCredentials {
  /// Current access token, or `null` when logged out.
  String? get accessToken;

  /// Performs a silent refresh (FR-010); returns the new access token or
  /// `null` when renewal failed.
  Future<String?> renewAccessToken();
}

/// Builds the application-wide [Dio] instance:
/// - base URL from [EnvironmentConfig] (FR-014);
/// - JWT bearer injection on protected requests;
/// - one-shot automatic 401 → refresh → retry;
/// - friendly error mapping so raw exceptions never reach repositories.
///
/// [onDioBuilt] is an optional hook that runs after the Dio instance is
/// configured but before it is returned. Platform packages use this to
/// install certificate pinning (Constitution VIII, FR-013) without
/// pulling `dart:io` into the core barrel.
Dio buildDio({
  required EnvironmentConfig config,
  required SessionCredentials credentials,
  Reporter reporter = const ConsoleReporter(),
  void Function(Dio dio)? onDioBuilt,
}) {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl.toString(),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  dio.interceptors.add(
    AuthInterceptor(
      dio: dio,
      getAccessToken: () async => credentials.accessToken,
      renewAccessToken: () => credentials.renewAccessToken(),
      reporter: reporter,
    ),
  );

  if (!config.isReleaseLike) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (Object message) => reporter.log(
          AppLogLevel.debug,
          'http',
          context: {'detail': '$message'},
        ),
      ),
    );
  }

  onDioBuilt?.call(dio);
  return dio;
}
