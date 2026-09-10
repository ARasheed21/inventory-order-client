import 'package:meta/meta.dart';
import 'package:fpdart/fpdart.dart';

import '../failures.dart';

/// Password value object (FR-002, 8–128 chars, letter+digit).
///
/// Stored as private string; `toString` is redacted to prevent
/// accidental logging (SC-007, Constitution VIII).
@immutable
final class Password {
  const Password._(this._value);

  final String _value;

  /// Exposes length without exposing the raw value.
  int get length => _value.length;

  /// Validates [raw] and returns `Right(Password)` or `Left(ValidationFailure)`.
  static Either<ValidationFailure, Password> validate(String raw) {
    final String sanitized = _sanitize(raw);
    if (sanitized.isEmpty) {
      return const Left(
        ValidationFailure(fields: {'password': 'Password is required'}),
      );
    }
    if (sanitized.length < 8 || sanitized.length > 128) {
      return const Left(
        ValidationFailure(fields: {
          'password':
              'Password must be 8–128 characters and contain a letter and a digit',
        }),
      );
    }
    final bool hasLetter = sanitized.contains(RegExp(r'[A-Za-z]'));
    final bool hasDigit = sanitized.contains(RegExp(r'[0-9]'));
    if (!hasLetter || !hasDigit) {
      return const Left(
        ValidationFailure(fields: {
          'password':
              'Password must be 8–128 characters and contain a letter and a digit',
        }),
      );
    }
    return Right(Password._(sanitized));
  }

  static String _sanitize(String input) {
    // Trim and strip control characters, but keep internal spaces? Passwords
    // should not have control chars; trim only.
    final String trimmed = input.trim();
    final StringBuffer buf = StringBuffer();
    for (final int code in trimmed.codeUnits) {
      if (code >= 32 && code != 127) buf.writeCharCode(code);
    }
    return buf.toString();
  }

  /// Only the repository may extract the raw value for transmission.
  /// This accessor is intentionally not named `value` to discourage use.
  String get rawForTransmission => _value;

  @override
  bool operator ==(Object other) =>
      other is Password && other._value == _value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => 'Password(***)';
}
