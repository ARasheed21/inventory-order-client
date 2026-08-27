import 'package:dio/dio.dart';

import '../../application/env_config.dart';
import '../../infrastructure/observability/reporter.dart';

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
  const List<String> unauthenticatedPaths = <String>[
    '/auth/login',
    '/auth/register',
    '/auth/refresh',
  ];

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl.toString(),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  dio.interceptors.addAll(<Interceptor>[
    InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        final bool protected = !unauthenticatedPaths.any(options.path.contains);
        final String? token = credentials.accessToken;
        if (protected && token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (DioException error, ErrorInterceptorHandler handler) async {
        final int? status = error.response?.statusCode;
        final bool protected = !unauthenticatedPaths.any(
          error.requestOptions.path.contains,
        );
        if (status == 401 &&
            protected &&
            error.requestOptions.extra['_retried'] != true) {
          final String? renewed = await credentials.renewAccessToken();
          if (renewed != null) {
            try {
              final RequestOptions retry = error.requestOptions
                ..extra['_retried'] = true
                ..headers['Authorization'] = 'Bearer $renewed';
              final Response<dynamic> response = await dio.fetch(retry);
              return handler.resolve(response);
            } on DioException catch (_) {
              return handler.next(error);
            }
          }
        }
        handler.next(error);
      },
    ),
  ]);

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
