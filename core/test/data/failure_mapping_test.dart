import 'package:test/test.dart';

import 'package:core/application/async_state.dart';
import 'package:core/domain/failures.dart';

/// FR-008: every transport failure maps to a friendly, categorized Failure.
void main() {
  group('failure message contract', () {
    test('no failure message leaks technical detail', () {
      const List<Failure> failures = [
        NetworkFailure(),
        AuthenticationFailure(),
        AuthorizationFailure(),
        ServerFailure(),
        ValidationFailure(),
        UnknownFailure(),
      ];
      for (final Failure f in failures) {
        expect(
          f.userMessage,
          isNot(
            anyOf(contains('Dio'), contains('HTTP'), contains('Exception')),
          ),
        );
      }
    });

    test('validation failures carry field-level messages', () {
      const ValidationFailure f = ValidationFailure(
        fields: {'username': 'already taken'},
      );
      expect(f.fields['username'], 'already taken');
    });
  });

  group('AsyncState presentation contract', () {
    test('error state exposes retryable friendly message', () {
      const AsyncState<int> s = AsyncState<int>.error(NetworkFailure());
      s.when(
        loading: () => fail('unexpected loading'),
        data: (_) => fail('unexpected data'),
        error: (Failure f) => expect(f.userMessage, isNotEmpty),
      );
    });
  });
}
