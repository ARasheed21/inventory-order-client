import 'dart:convert';

import 'package:test/test.dart';

import 'package:core/domain/entities/profile.dart';
import 'package:core/domain/entities/session.dart';

void main() {
  group('ROLE_ADMIN dedicated', () {
    test('parseRoleFromPayload returns admin for explicit ROLE_ADMIN', () {
      expect(parseRoleFromPayload({'roles': ['ROLE_ADMIN']}), Role.admin);
      expect(parseRoleFromPayload({'role': 'ROLE_ADMIN'}), Role.admin);
      expect(parseRoleFromPayload({'authorities': ['ROLE_ADMIN']}), Role.admin);
      expect(parseRoleFromPayload({'roles': ['admin']}), Role.admin);
    });

    test('Profile.fromJson correctly maps ROLE_ADMIN to admin', () {
      final profile = Profile.fromJson({
        'id': 'admin-1',
        'username': 'admin',
        'email': 'admin@example.com',
        'roles': ['ROLE_ADMIN'],
      });
      expect(profile.roles, contains(Role.admin));
      expect(profile.roles.length, 1);
    });

    test('JWT with ROLE_ADMIN decodes to admin role', () {
      final header = base64UrlEncode(utf8.encode('{"alg":"HS256"}')).replaceAll('=', '');
      final payload = base64UrlEncode(utf8.encode('{"roles":["ROLE_ADMIN"]}')).replaceAll('=', '');
      final token = '$header.$payload.signature';
      expect(parseRoleFromPayload({'accessToken': token}), Role.admin);
    });

    test('route behavior: admin session has admin role and not customer-only', () {
      final session = Session(
        userId: 'u1',
        username: 'admin',
        role: Role.admin,
        accessToken: 'a',
        refreshToken: 'r',
        accessExpiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
      );
      expect(session.role, Role.admin);
      // Admin should be considered privileged over customer
      expect(session.role != Role.customer, isTrue);
      expect(session.role == Role.admin, isTrue);
    });
  });

  group('ROLE_WAREHOUSE dedicated', () {
    test('parseRoleFromPayload returns warehouse for explicit ROLE_WAREHOUSE', () {
      expect(parseRoleFromPayload({'roles': ['ROLE_WAREHOUSE']}), Role.warehouse);
      expect(parseRoleFromPayload({'role': 'ROLE_WAREHOUSE'}), Role.warehouse);
      expect(parseRoleFromPayload({'authorities': [{'authority': 'ROLE_WAREHOUSE'}]}), Role.warehouse);
      expect(parseRoleFromPayload({'roles': ['warehouse']}), Role.warehouse);
    });

    test('Profile.fromJson correctly maps ROLE_WAREHOUSE to warehouse', () {
      final profile = Profile.fromJson({
        'id': 'wh-1',
        'username': 'warehouse',
        'email': 'wh@example.com',
        'roles': ['ROLE_WAREHOUSE'],
      });
      expect(profile.roles, contains(Role.warehouse));
      expect(profile.roles.length, 1);
    });

    test('JWT with ROLE_WAREHOUSE decodes to warehouse role', () {
      final header = base64UrlEncode(utf8.encode('{"alg":"HS256"}')).replaceAll('=', '');
      final payload = base64UrlEncode(utf8.encode('{"roles":["ROLE_WAREHOUSE"]}')).replaceAll('=', '');
      final token = '$header.$payload.signature';
      expect(parseRoleFromPayload({'accessToken': token}), Role.warehouse);
    });

    test('route behavior: warehouse session has warehouse role and not admin', () {
      final session = Session(
        userId: 'u2',
        username: 'wh',
        role: Role.warehouse,
        accessToken: 'a',
        refreshToken: 'r',
        accessExpiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
      );
      expect(session.role, Role.warehouse);
      expect(session.role != Role.admin, isTrue);
      expect(session.role == Role.warehouse, isTrue);
    });
  });

  group('ROLE_ADMIN and ROLE_WAREHOUSE priority vs CUSTOMER', () {
    test('admin takes precedence over warehouse and customer in mixed payload', () {
      expect(
        parseRoleFromPayload({
          'roles': ['ROLE_CUSTOMER', 'ROLE_WAREHOUSE', 'ROLE_ADMIN']
        }),
        Role.admin,
      );
    });

    test('warehouse takes precedence over customer', () {
      expect(
        parseRoleFromPayload({
          'roles': ['ROLE_CUSTOMER', 'ROLE_WAREHOUSE']
        }),
        Role.warehouse,
      );
    });

    test('route guard logic: admin and warehouse are distinct from customer', () {
      // Simulates route guard check: admin should access admin routes, warehouse should not, customer should not
      bool canAccessAdmin(Role r) => r == Role.admin;
      bool canAccessWarehouse(Role r) => r == Role.warehouse || r == Role.admin;

      expect(canAccessAdmin(Role.admin), isTrue);
      expect(canAccessAdmin(Role.warehouse), isFalse);
      expect(canAccessAdmin(Role.customer), isFalse);

      expect(canAccessWarehouse(Role.warehouse), isTrue);
      expect(canAccessWarehouse(Role.admin), isTrue);
      expect(canAccessWarehouse(Role.customer), isFalse);
    });
  });
}
