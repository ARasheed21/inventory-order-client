import 'dart:async';

import 'package:dio/dio.dart';

import '../../infrastructure/observability/reporter.dart';

/// Single-flight JWT refresh interceptor.
///
/// Responsibilities (research R4, clarification Q5):
/// - Inject `Authorization: Bearer <token>` on protected paths.
/// - On 401 (protected), perform a single-flight refresh via
///   `SessionCredentials.renewAccessToken()` and queue concurrent 401s.
/// - On refresh success: rewrite header, retry original via `dio.fetch()`,
///   re-authenticate STOMP CONNECT frame (delegated to `AuthRealtimeAdapter`).
/// - On refresh 401: clear storage and surface `AuthenticationFailure` so
///   `AuthNotifier` can emit `loggedOut`.
///
/// This file currently provides the *skeleton* used by `api_http_client.dart`
/// which already wires a `QueuedInterceptor`-like flow. The full guard
/// (Completer, queued retry) is completed in Phase 4 US2 T038.
final class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required Dio dio,
    required Future<String?> Function() getAccessToken,
    required Future<String?> Function() renewAccessToken,
    this.reporter = const ConsoleReporter(),
  })  : _dio = dio,
        _getAccessToken = getAccessToken,
        _renewAccessToken = renewAccessToken;

  final Dio _dio;
  final Future<String?> Function() _getAccessToken;
  final Future<String?> Function() _renewAccessToken;
  final Reporter reporter;

  Completer<String?>? _refreshCompleter;

  static const List<String> _unauthenticatedPaths = <String>[
    '/auth/login',
    '/auth/register',
    '/auth/refresh',
  ];

  bool _isProtected(String path) =>
      !_unauthenticatedPaths.any(path.contains);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isProtected(options.path)) {
      final String? token = await _getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final int? status = err.response?.statusCode;
    final bool protected = _isProtected(err.requestOptions.path);
    if (status == 401 &&
        protected &&
        err.requestOptions.extra['_retried'] != true) {
      // Single-flight gate: only first concurrent 401 becomes leader.
      bool isLeader = false;
      Completer<String?> completer;
      if (_refreshCompleter == null || _refreshCompleter!.isCompleted) {
        _refreshCompleter = completer = Completer<String?>();
        isLeader = true;
      } else {
        completer = _refreshCompleter!;
        isLeader = false;
      }
      if (isLeader) {
        try {
          final String? renewed = await _renewAccessToken();
          if (!completer.isCompleted) completer.complete(renewed);
        } catch (e) {
          if (!completer.isCompleted) completer.complete(null);
        } finally {
          // Allow next 401 to start a fresh refresh cycle.
          Future<void>.delayed(Duration.zero, () {
            if (identical(_refreshCompleter, completer)) {
              _refreshCompleter = null;
            }
          });
        }
      }
      final String? renewed = await completer.future;
      if (renewed != null) {
        try {
          final RequestOptions retry = err.requestOptions
            ..extra['_retried'] = true
            ..headers['Authorization'] = 'Bearer $renewed';
          // Use the owning Dio instance to preserve baseUrl, interceptors,
          // logging, and certificate-pinning hooks.
          final Response<dynamic> response =
              await _dio.fetch<dynamic>(retry);
          return handler.resolve(response);
        } on DioException catch (_) {
          return handler.next(err);
        }
      }
    }
    handler.next(err);
  }
}
