/// Severity levels for structured application logging (FR-018).
enum AppLogLevel { debug, info, warning, error }

/// Structured observability facade.
///
/// Platforms bind a concrete implementation at startup: console logging in
/// dev, crash-reporting forwarding in release. Key events and errors flow
/// through this interface only — no direct `print` calls anywhere.
abstract interface class Reporter {
  void log(AppLogLevel level, String event, {Map<String, Object?> context});

  void recordError(
    Object error, {
    StackTrace? stackTrace,
    Map<String, Object?> context,
  });
}

/// Console-backed reporter used in development builds and tests.
final class ConsoleReporter implements Reporter {
  const ConsoleReporter();

  @override
  void log(
    AppLogLevel level,
    String event, {
    Map<String, Object?> context = const {},
  }) {
    // ignore: avoid_print
    print('[${level.name}] $event ${context.isEmpty ? '' : context}');
  }

  @override
  void recordError(
    Object error, {
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  }) {
    // ignore: avoid_print
    print('[error] $error ${context.isEmpty ? '' : context}\n$stackTrace');
  }
}
