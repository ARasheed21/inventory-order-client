import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Binds the core [Reporter] facade to the platform observability stack:
/// console in dev, crash-reporting forwarding in release-like environments.
Reporter createReporter(EnvironmentConfig config) {
  if (!config.isReleaseLike) return const ConsoleReporter();
  return const _SentryForwardingReporter(ConsoleReporter());
}

final class _SentryForwardingReporter implements Reporter {
  const _SentryForwardingReporter(this._console);
  final Reporter _console;

  @override
  void log(
    AppLogLevel level,
    String event, {
    Map<String, Object?> context = const {},
  }) {
    _console.log(level, event, context: context);
    if (level == AppLogLevel.error) {
      Sentry.captureMessage(event, level: SentryLevel.error);
    }
  }

  @override
  void recordError(
    Object error, {
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  }) {
    _console.recordError(error, stackTrace: stackTrace, context: context);
    if (kReleaseMode) {
      Sentry.captureException(error, stackTrace: stackTrace);
    }
  }
}
