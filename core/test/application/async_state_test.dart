import 'package:test/test.dart';

import 'package:core/application/async_state.dart';
import 'package:core/domain/failures.dart';

void main() {
  group('AsyncState', () {
    test('loading state reports loading and no data', () {
      const AsyncState<int> s = AsyncState<int>.loading();
      expect(s.isLoading, isTrue);
      expect(s.dataOrNull, isNull);
    });

    test('data state carries value', () {
      const AsyncState<int> s = AsyncState<int>.data(42);
      expect(s.isLoading, isFalse);
      expect(s.dataOrNull, 42);
    });

    test('error state carries failure', () {
      const AsyncState<int> s = AsyncState<int>.error(ServerFailure());
      expect(s.dataOrNull, isNull);
      s.when(
        loading: () => fail('should not be loading'),
        data: (_) => fail('should not be data'),
        error: (Failure f) => expect(f, isA<ServerFailure>()),
      );
    });

    test('equality works for data states', () {
      expect(
        const AsyncState<int>.data(1),
        equals(const AsyncState<int>.data(1)),
      );
      expect(
        const AsyncState<int>.data(1),
        isNot(equals(const AsyncState<int>.data(2))),
      );
    });
  });
}
