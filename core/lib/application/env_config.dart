/// Startup configuration loaded from environment files (FR-014).
///
/// Pure Dart: platforms supply their own lookup (dart-defines on mobile,
/// fetched env document or defines on web). Missing required values abort
/// startup with a message naming the variable.
library;

import '../infrastructure/observability/reporter.dart';

/// Deployment environment selector.
enum AppEnvironment { dev, staging }

/// Immutable environment configuration resolved once at startup.
class EnvironmentConfig {
  EnvironmentConfig._({
    required this.apiBaseUrl,
    required this.wsUrl,
    required this.sentryDsn,
    required this.certPins,
    required this.environment,
  });

  final Uri apiBaseUrl;
  final Uri wsUrl;
  final String? sentryDsn;
  final List<String> certPins;
  final AppEnvironment environment;

  /// True when release-grade requirements apply (Sentry DSN + pins required).
  bool get isReleaseLike => environment != AppEnvironment.dev;

  /// Reads and validates configuration from [lookup]. Throws
  /// [MissingEnvironmentException] on absent required values or
  /// [FormatException] on malformed values.
  static EnvironmentConfig fromEnvironment({
    required Map<String, String?> lookup,
  }) {
    final Map<String, String?> env = lookup;
    String require(String name) {
      final String? value = env[name];
      if (value == null || value.trim().isEmpty) {
        throw MissingEnvironmentException(name);
      }
      return value.trim();
    }

    String? optional(String name) {
      final String? value = env[name];
      return value == null || value.trim().isEmpty ? null : value.trim();
    }

    final String rawApi = require('API_BASE_URL');
    final String rawWs = require('WS_URL');
    final String rawEnv = require('APP_ENV');

    final Uri api =
        Uri.tryParse(rawApi) ??
        (throw FormatException('API_BASE_URL is not a valid URI: $rawApi'));
    final Uri ws =
        Uri.tryParse(rawWs) ??
        (throw FormatException('WS_URL is not a valid URI: $rawWs'));

    final AppEnvironment environment = switch (rawEnv.toLowerCase()) {
      'dev' => AppEnvironment.dev,
      'staging' => AppEnvironment.staging,
      _ => throw FormatException(
        'APP_ENV must be "dev" or "staging", got "$rawEnv"',
      ),
    };

    final String? dsn = optional('SENTRY_DSN');
    final List<String> pins = (optional('CERT_PINS') ?? '')
        .split(',')
        .map((String p) => p.trim())
        .where((String p) => p.isNotEmpty)
        .toList(growable: false);

    return EnvironmentConfig._(
      apiBaseUrl: api,
      wsUrl: ws,
      sentryDsn: dsn,
      certPins: pins,
      environment: environment,
    ).._validateReleaseRequirements(dsn, pins);
  }

  void _validateReleaseRequirements(String? dsn, List<String> pins) {
    if (!isReleaseLike) return;
    if (dsn == null) {
      throw MissingEnvironmentException(
        'SENTRY_DSN',
        reason: 'required in $environment',
      );
    }
    if (pins.isEmpty) {
      throw MissingEnvironmentException(
        'CERT_PINS',
        reason: 'required in $environment',
      );
    }
  }
}

/// Thrown at startup when a required environment variable is missing.
final class MissingEnvironmentException implements Exception {
  MissingEnvironmentException(this.variableName, {this.reason});

  final String variableName;
  final String? reason;

  @override
  String toString() =>
      'MissingEnvironmentException: required environment variable '
      '"$variableName" is not set${reason == null ? '' : ' ($reason)'}';
}

/// Convenience accessor so callers can surface config problems through the
/// standard observability facade before any platform binding exists.
void reportStartupProblem(Object error, {StackTrace? stackTrace}) {
  const ConsoleReporter().recordError(error, stackTrace: stackTrace);
}
