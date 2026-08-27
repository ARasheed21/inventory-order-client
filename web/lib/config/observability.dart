import 'package:core/core.dart';
import 'package:sentry/sentry.dart';

/// Binds the core [Reporter] facade to the web observability stack:
/// console in dev, crash-reporting forwarding in release-like environments.
Reporter createReporter(EnvironmentConfig config) {
  if (!config.isReleaseLike) return const ConsoleReporter();
  return _SentryForwardingReporter(const ConsoleReporter());
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
    Sentry.captureException(error, stackTrace: stackTrace);
  }
}
