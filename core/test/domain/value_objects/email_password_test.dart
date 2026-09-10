import 'package:test/test.dart';

import 'package:core/domain/value_objects/email.dart';
import 'package:core/domain/value_objects/password.dart';

void main() {
  group('Email', () {
    test('accepts valid emails', () {
      expect(Email.validate('alice@example.com').isRight(), isTrue);
      expect(Email.validate('  ALICE@Example.COM  ').isRight(), isTrue);
      expect(Email.validate('a.b+tag@example.co.uk').isRight(), isTrue);
    });

    test('lowercases on success', () {
      final email = Email.validate('ALICE@EXAMPLE.COM').fold((l) => throw 'fail', (r) => r);
      expect(email.value, 'alice@example.com');
    });

    test('rejects invalid emails', () {
      expect(Email.validate('').isLeft(), isTrue);
      expect(Email.validate('alice@').isLeft(), isTrue);
      expect(Email.validate('alice@example').isLeft(), isTrue);
      expect(Email.validate('alice@@example.com').isLeft(), isTrue);
      expect(Email.validate('alice@example..com').isLeft(), isTrue);
      expect(Email.validate('alice bob@example.com').isLeft(), isTrue);
    });
  });

  group('Password', () {
    test('accepts valid passwords 8-128 with letter+digit', () {
      expect(Password.validate('Secr3tPwd').isRight(), isTrue);
      expect(Password.validate('s3cret-pass').isRight(), isTrue);
      expect(Password.validate('a' * 7 + '1').isRight(), isTrue); // 8 chars
      expect(Password.validate('a' * 127 + '1').isRight(), isTrue); // 128
    });

    test('rejects too short or too long', () {
      expect(Password.validate('Abc1def').isLeft(), isTrue); // 7
      expect(Password.validate('a' * 129).isLeft(), isTrue);
      expect(Password.validate('').isLeft(), isTrue);
    });

    test('rejects missing letter or digit', () {
      expect(Password.validate('12345678').isLeft(), isTrue); // no letter
      expect(Password.validate('abcdefgh').isLeft(), isTrue); // no digit
      expect(Password.validate('ABCDEFGH').isLeft(), isTrue);
    });

    test('toString is redacted', () {
      final pw = Password.validate('Secr3tPwd').fold((l) => throw 'fail', (r) => r);
      expect(pw.toString(), isNot(contains('Secr3tPwd')));
      expect(pw.toString(), contains('***'));
    });
  });
}
