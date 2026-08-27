import 'package:test/test.dart';

import 'package:core/domain/failures.dart';

void main() {
  group('Failure taxonomy', () {
    test('each subtype carries a friendly default message', () {
      const List<Failure> failures = [
        NetworkFailure(),
        AuthenticationFailure(),
        AuthorizationFailure(),
        ServerFailure(),
        ValidationFailure(),
        UnknownFailure(),
      ];
      for (final Failure f in failures) {
        expect(f.userMessage, isNotEmpty, reason: '$f must have a message');
        expect(f.userMessage, isNot(contains('Exception')));
      }
    });

    test('custom messages override defaults', () {
      const Failure f = ServerFailure(message: 'custom');
      expect(f.userMessage, 'custom');
    });

    test('ValidationFailure exposes field-level messages', () {
      const ValidationFailure f = ValidationFailure(
        fields: {'username': 'taken'},
      );
      expect(f.fields['username'], 'taken');
    });

    test('sealed hierarchy exhaustive switch compiles and routes', () {
      String describe(Failure f) => switch (f) {
        NetworkFailure() => 'network',
        AuthenticationFailure() => 'auth',
        AuthorizationFailure() => 'authorization',
        ServerFailure() => 'server',
        ValidationFailure() => 'validation',
        UnknownFailure() => 'unknown',
      };
      expect(describe(const NetworkFailure()), 'network');
      expect(describe(const UnknownFailure()), 'unknown');
    });
  });
}
