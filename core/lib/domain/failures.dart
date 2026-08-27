import 'package:meta/meta.dart';

/// Centralized user-visible error strings (FR-015). Kept adjacent to the
/// taxonomy so failures stay dependency-light.

/// Domain-level failure taxonomy.
///
/// Every operation failure maps to exactly one [Failure] subtype. Raw
/// exceptions MUST NOT cross the repository boundary (Constitution IV).
@immutable
sealed class Failure {
  const Failure(this.userMessage);

  /// Friendly, localized message safe to render directly in the UI.
  final String userMessage;

  @override
  String toString() => '$runtimeType($userMessage)';
}

final class NetworkFailure extends Failure {
  const NetworkFailure({String? message})
    : super(message ?? StringsError.network);
}

final class AuthenticationFailure extends Failure {
  const AuthenticationFailure({String? message})
    : super(message ?? StringsError.authentication);
}

final class AuthorizationFailure extends Failure {
  const AuthorizationFailure({String? message})
    : super(message ?? StringsError.authorization);
}

final class ServerFailure extends Failure {
  const ServerFailure({String? message})
    : super(message ?? StringsError.server);
}

final class ValidationFailure extends Failure {
  const ValidationFailure({this.fields = const {}})
    : super(StringsError.validation);

  /// Field-level messages keyed by backend field name.
  ///
  /// Treat as read-only; mutation by callers is a contract violation.
  final Map<String, String> fields;
}

final class UnknownFailure extends Failure {
  const UnknownFailure({String? message})
    : super(message ?? StringsError.unknown);
}

/// Error messages referenced by the failure taxonomy. Centralized with the
/// rest of the user-visible strings (FR-015); kept here as re-exports so
/// failures.dart stays dependency-light.
abstract final class StringsError {
  static const String network = 'You appear to be offline. Please try again.';
  static const String authentication =
      'Your session has expired. Please sign in again.';
  static const String authorization = "You don't have permission to do that.";
  static const String server =
      'Something went wrong on our side. Please try again.';
  static const String validation = 'Please review the highlighted fields.';
  static const String unknown =
      'Something unexpected happened. Please try again.';
}
