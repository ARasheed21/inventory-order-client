import 'package:test/test.dart';

import 'package:core/domain/value_objects/username.dart';

void main() {
  group('Username', () {
    test('accepts valid usernames 3-30 with allowed charset', () {
      expect(Username.validate('alice').isRight(), isTrue);
      expect(Username.validate('bob_123').isRight(), isTrue);
      expect(Username.validate('a.b-c').isRight(), isTrue);
      expect(Username.validate('User_01').isRight(), isTrue);
      expect(Username.validate('abc').isRight(), isTrue); // min 3
      expect(Username.validate('a' * 30).isRight(), isTrue); // max 30
    });

    test('rejects too short or too long', () {
      expect(Username.validate('ab').isLeft(), isTrue);
      expect(Username.validate('a').isLeft(), isTrue);
      expect(Username.validate('a' * 31).isLeft(), isTrue);
      expect(Username.validate('').isLeft(), isTrue);
      expect(Username.validate('   ').isLeft(), isTrue);
    });

    test('rejects disallowed characters and spaces', () {
      expect(Username.validate('alice!').isLeft(), isTrue);
      expect(Username.validate('alice@bob').isLeft(), isTrue);
      expect(Username.validate('alice bob').isLeft(), isTrue);
      expect(Username.validate('_alice').isLeft(), isTrue); // must start alphanumeric
      expect(Username.validate('.alice').isLeft(), isTrue);
    });

    test('trims and strips control characters', () {
      expect(Username.validate('  alice  ').isRight(), isTrue);
      final result = Username.validate('  alice  ');
      result.fold((l) => fail('should be valid'), (r) {
        expect(r.value, 'alice');
      });
    });

    test('error message mentions 3-30 and allowed chars', () {
      final left = Username.validate('ab').fold((l) => l, (r) => throw 'should fail');
      expect(left.fields['username'], contains('3–30'));
    });
  });
}
