import 'package:core/core.dart';

/// Resolves [EnvironmentConfig] from compile-time dart-defines
/// (`--dart-define-from-file=config.env`, see `.env.example`).
///
/// Missing values abort startup with a clear message naming the variable,
/// pointing contributors back to setup documentation (FR-002, FR-014).
abstract final class AppEnv {
  static const String _apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const String _wsUrl = String.fromEnvironment('WS_URL');
  static const String _sentryDsn = String.fromEnvironment('SENTRY_DSN');
  static const String _certPins = String.fromEnvironment('CERT_PINS');
  static const String _appEnv = String.fromEnvironment('APP_ENV');

  static EnvironmentConfig load() {
    try {
      return EnvironmentConfig.fromEnvironment(
        lookup: <String, String?>{
          'API_BASE_URL': _apiBaseUrl,
          'WS_URL': _wsUrl,
          'SENTRY_DSN': _sentryDsn,
          'CERT_PINS': _certPins,
          'APP_ENV': _appEnv,
        },
      );
    } on Object catch (error, stackTrace) {
      reportStartupProblem(error, stackTrace: stackTrace);
      rethrow;
    }
  }
}
