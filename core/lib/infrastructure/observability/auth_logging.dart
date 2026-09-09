import 'reporter.dart';

/// Structured auth event names (FR-018, SC-007 — never log token payloads).
abstract final class AuthLogEvent {
  static const String loginAttempt = 'auth.login_attempt';
  static const String loginSuccess = 'auth.login_success';
  static const String loginFailure = 'auth.login_failure';
  static const String registerAttempt = 'auth.register_attempt';
  static const String registerValidationFailed = 'auth.register_validation_failed';
  static const String registerSuccess = 'auth.register_success';
  static const String refreshAttempt = 'auth.refresh_attempt';
  static const String refreshSucceeded = 'auth.refresh_succeeded';
  static const String refreshFailed = 'auth.refresh_failed';
  static const String logout = 'auth.logout';
  static const String rateLimited = 'auth.rate_limited';
  static const String sessionExpired = 'auth.session_expired';
}

/// Small helper that forwards auth events to [Reporter] without ever
/// including credential material. Callers pass only non-sensitive context
/// (username, role set, retryAfter seconds, failure type).
final class AuthLogger {
  const AuthLogger(this.reporter);

  final Reporter reporter;

  void logAttempt(String event, {Map<String, Object?> context = const {}}) {
    // Defensive: strip any accidental token keys.
    final Map<String, Object?> safe = Map<String, Object?>.from(context)
      ..remove('accessToken')
      ..remove('refreshToken')
      ..remove('token');
    reporter.log(AppLogLevel.info, event, context: safe);
  }

  void logFailure(
    String event,
    Object error, {
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  }) {
    final Map<String, Object?> safe = Map<String, Object?>.from(context)
      ..remove('accessToken')
      ..remove('refreshToken');
    reporter.recordError(error, stackTrace: stackTrace, context: safe);
  }
}
