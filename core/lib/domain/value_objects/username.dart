import 'package:meta/meta.dart';
import 'package:fpdart/fpdart.dart';

import '../failures.dart';

/// Username value object (FR-002, clarification Q1).
///
/// Rules: trimmed, 3–30 chars, allowed `[a-zA-Z0-9._-]`, first char must be
/// alphanumeric, no spaces or control chars. Sanitized on construction.
@immutable
final class Username {
  const Username._(this.value);

  final String value;

  static final RegExp _pattern =
      RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9._-]{2,29}$');

  /// Validates [raw] and returns `Right(Username)` or `Left(ValidationFailure)`.
  static Either<ValidationFailure, Username> validate(String raw) {
    final String sanitized = _sanitize(raw);
    if (sanitized.isEmpty) {
      return const Left(
        ValidationFailure(fields: {
          'username': 'Username is required',
        }),
      );
    }
    if (sanitized.length < 3 || sanitized.length > 30) {
      return const Left(
        ValidationFailure(fields: {
          'username':
              'Username must be 3–30 characters, letters, digits, dot, underscore or hyphen only',
        }),
      );
    }
    if (!_pattern.hasMatch(sanitized)) {
      return const Left(
        ValidationFailure(fields: {
          'username':
              'Username must be 3–30 characters, letters, digits, dot, underscore or hyphen only',
        }),
      );
    }
    return Right(Username._(sanitized));
  }

  static String _sanitize(String input) {
    // Trim and strip control characters (0x00–0x1F, 0x7F); internal spaces are kept
    // so they fail the charset regex instead of being silently removed.
    final String trimmed = input.trim();
    final StringBuffer buf = StringBuffer();
    for (final int code in trimmed.codeUnits) {
      if (code >= 32 && code != 127) buf.writeCharCode(code);
    }
    return buf.toString();
  }

  @override
  bool operator ==(Object other) =>
      other is Username && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Username($value)';
}
