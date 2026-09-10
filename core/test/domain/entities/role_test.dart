import 'dart:convert';

import 'package:test/test.dart';

import 'package:core/domain/entities/session.dart';

void main() {
  group('parseRoleFromPayload', () {
    test('defaults to customer when no role present', () {
      expect(parseRoleFromPayload({}), Role.customer);
      expect(parseRoleFromPayload({'username': 'bob'}), Role.customer);
    });

    test('parses ROLE_CUSTOMER, ROLE_WAREHOUSE, ROLE_ADMIN from roles list', () {
      expect(
        parseRoleFromPayload({
          'roles': ['ROLE_CUSTOMER']
        }),
        Role.customer,
      );
      expect(
        parseRoleFromPayload({
          'roles': ['ROLE_WAREHOUSE']
        }),
        Role.warehouse,
      );
      expect(
        parseRoleFromPayload({
          'roles': ['ROLE_ADMIN']
        }),
        Role.admin,
      );
    });

    test('parses without ROLE_ prefix and case-insensitive', () {
      expect(parseRoleFromPayload({'roles': ['admin']}), Role.admin);
      expect(parseRoleFromPayload({'roles': ['warehouse']}), Role.warehouse);
      expect(parseRoleFromPayload({'roles': ['Customer']}), Role.customer);
    });

    test('picks highest priority ADMIN > WAREHOUSE > CUSTOMER', () {
      expect(
        parseRoleFromPayload({
          'roles': ['ROLE_CUSTOMER', 'ROLE_WAREHOUSE']
        }),
        Role.warehouse,
      );
      expect(
        parseRoleFromPayload({
          'roles': ['ROLE_WAREHOUSE', 'ROLE_ADMIN']
        }),
        Role.admin,
      );
      expect(
        parseRoleFromPayload({
          'roles': ['ROLE_CUSTOMER', 'ROLE_ADMIN', 'ROLE_WAREHOUSE']
        }),
        Role.admin,
      );
    });

    test('parses single role string and authorities map', () {
      expect(parseRoleFromPayload({'role': 'ROLE_ADMIN'}), Role.admin);
      expect(
        parseRoleFromPayload({
          'authorities': [
            {'authority': 'ROLE_WAREHOUSE'}
          ]
        }),
        Role.warehouse,
      );
    });

    test('decodes roles from JWT accessToken when no explicit roles', () {
      // JWT payload {"roles":["ROLE_ADMIN"]} base64
      final String header = base64UrlEncode(utf8.encode('{"alg":"HS256"}')).replaceAll('=', '');
      final String payload = base64UrlEncode(utf8.encode('{"roles":["ROLE_ADMIN"]}')).replaceAll('=', '');
      final String token = '$header.$payload.signature';
      expect(
        parseRoleFromPayload({'accessToken': token}),
        Role.admin,
      );
      final String whPayload = base64UrlEncode(utf8.encode('{"roles":["ROLE_WAREHOUSE"]}')).replaceAll('=', '');
      final String whToken = '$header.$whPayload.signature';
      expect(
        parseRoleFromPayload({'accessToken': whToken}),
        Role.warehouse,
      );
    });

    test('explicit roles take precedence over JWT', () {
      final String header = base64UrlEncode(utf8.encode('{"alg":"HS256"}')).replaceAll('=', '');
      final String payload = base64UrlEncode(utf8.encode('{"roles":["ROLE_ADMIN"]}')).replaceAll('=', '');
      final String token = '$header.$payload.signature';
      // Explicit customer should win over JWT admin? Actually explicit is checked first, so explicit customer would be returned, but priority logic still applies to explicit list only.
      // Here we test explicit admin overrides JWT customer
      expect(
        parseRoleFromPayload({
          'roles': ['ROLE_WAREHOUSE'],
          'accessToken': token,
        }),
        Role.warehouse,
      );
    });
  });
}
