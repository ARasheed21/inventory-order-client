import 'package:meta/meta.dart';
import 'package:fpdart/fpdart.dart';

import '../failures.dart';

/// Email value object (FR-002).
///
/// Rules: trimmed, lowercased, RFC-5322 simplified pattern,
/// no consecutive dots, no spaces.
@immutable
final class Email {
  const Email._(this.value);

  final String value;

  static final RegExp _pattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static Either<ValidationFailure, Email> validate(String raw) {
    final String sanitized = _sanitize(raw);
    if (sanitized.isEmpty) {
      return const Left(
        ValidationFailure(fields: {'email': 'Email is required'}),
      );
    }
    if (!_pattern.hasMatch(sanitized)) {
      return const Left(
        ValidationFailure(fields: {
          'email': 'Please enter a valid email address',
        }),
      );
    }
    if (sanitized.contains('..')) {
      return const Left(
        ValidationFailure(fields: {
          'email': 'Please enter a valid email address',
        }),
      );
    }
    return Right(Email._(sanitized.toLowerCase()));
  }

  static String _sanitize(String input) {
    final String trimmed = input.trim();
    final StringBuffer buf = StringBuffer();
    for (final int code in trimmed.codeUnits) {
      if (code >= 32 && code != 127) buf.writeCharCode(code);
    }
    return buf.toString();
  }

  @override
  bool operator ==(Object other) => other is Email && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Email($value)';
}
