import 'package:test/test.dart';

import 'package:core/domain/entities/account.dart';
import 'package:core/domain/entities/profile.dart';
import 'package:core/domain/entities/session.dart';
import 'package:core/domain/failures.dart';
import 'package:core/domain/value_objects/email.dart';
import 'package:core/domain/value_objects/username.dart';

void main() {
  group('Account', () {
    test('creates with validated username and email', () {
      final username = Username.validate('alice').fold((l) => throw 'fail', (r) => r);
      final email = Email.validate('alice@example.com').fold((l) => throw 'fail', (r) => r);
      final account = Account(
        id: 'u1',
        username: username,
        email: email,
        roles: {Role.customer},
      );
      expect(account.id, 'u1');
      expect(account.roles, contains(Role.customer));
    });

    test('equality by id+username+email+roles', () {
      final u = Username.validate('alice').fold((l) => throw 'fail', (r) => r);
      final e = Email.validate('alice@example.com').fold((l) => throw 'fail', (r) => r);
      final a1 = Account(id: '1', username: u, email: e, roles: {Role.customer});
      final a2 = Account(id: '1', username: u, email: e, roles: {Role.customer});
      expect(a1, equals(a2));
    });
  });

  group('Profile', () {
    test('parses from /auth/me JSON with ROLE_ prefix', () {
      final profile = Profile.fromJson({
        'id': 'u1',
        'username': 'alice',
        'email': 'alice@example.com',
        'roles': ['ROLE_CUSTOMER', 'ROLE_ADMIN'],
      });
      expect(profile.username, 'alice');
      expect(profile.roles, containsAll([Role.customer, Role.admin]));
    });

    test('defaults to customer when roles missing', () {
      final profile = Profile.fromJson({
        'id': 'u1',
        'username': 'alice',
        'email': 'alice@example.com',
      });
      expect(profile.roles, {Role.customer});
    });
  });

  group('ValidationFailure', () {
    test('carries field-level messages', () {
      const f = ValidationFailure(fields: {'username': 'taken'});
      expect(f.fields['username'], 'taken');
      expect(f.userMessage, isNotEmpty);
    });
  });
}
