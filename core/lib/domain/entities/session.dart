import 'dart:convert';

import 'package:meta/meta.dart';

/// Authorization roles carried by a session (Constitution VI).
enum Role { customer, warehouse, admin }

/// Parses [Role] from a payload map that may contain `roles`, `role`,
/// `authorities`, `authority`, or JWT `accessToken` claims.
///
/// Priority: ADMIN > WAREHOUSE > CUSTOMER. Used by `AuthRepositoryImpl`
/// and tested directly for integration coverage (T032-like).
Role parseRoleFromPayload(Map<String, dynamic> payload) {
  final List<String> candidates = <String>[];
  void addFrom(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      candidates.add(value);
    } else if (value is List) {
      for (final dynamic e in value) {
        if (e is String && e.trim().isNotEmpty) {
          candidates.add(e);
        } else if (e is Map && e['authority'] is String) {
          candidates.add(e['authority'] as String);
        } else if (e is Map && e['role'] is String) {
          candidates.add(e['role'] as String);
        }
      }
    } else if (value is Map && value['authority'] is String) {
      candidates.add(value['authority'] as String);
    }
  }

  addFrom(payload['roles']);
  addFrom(payload['role']);
  addFrom(payload['authorities']);
  addFrom(payload['authority']);
  addFrom(payload['userRoles']);

  if (candidates.isEmpty) {
    final String access = '${payload['accessToken'] ?? ''}';
    candidates.addAll(_rolesFromJwt(access));
  }

  bool hasAdmin = false;
  bool hasWarehouse = false;
  for (final String raw in candidates) {
    final String normalized =
        raw.trim().toUpperCase().replaceFirst(RegExp(r'^ROLE_'), '');
    if (normalized == 'ADMIN') hasAdmin = true;
    if (normalized == 'WAREHOUSE') hasWarehouse = true;
  }
  if (hasAdmin) return Role.admin;
  if (hasWarehouse) return Role.warehouse;
  return Role.customer;
}

List<String> _rolesFromJwt(String token) {
  try {
    final List<String> parts = token.split('.');
    if (parts.length != 3) return const [];
    final String payload = parts[1];
    String normalized = payload.replaceAll('-', '+').replaceAll('_', '/');
    while (normalized.length % 4 != 0) {
      normalized += '=';
    }
    final String decoded = utf8.decode(base64Decode(normalized));
    final Map<String, dynamic> json =
        Map<String, dynamic>.from(jsonDecode(decoded) as Map);
    final dynamic roles = json['roles'] ?? json['authorities'] ?? json['role'];
    if (roles is List) return roles.map((e) => '$e').toList();
    if (roles is String) return <String>[roles];
  } catch (_) {}
  return const [];
}

/// Authenticated identity + credentials held for the current user.
///
/// Secrets are held only as opaque strings; storage location is decided by
/// the platform [CredentialStore] implementation (FR-009).
@immutable
final class Session {
  const Session({
    required this.userId,
    required this.username,
    required this.role,
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpiresAt,
  });

  final String userId;
  final String username;
  final Role role;
  final String accessToken;
  final String refreshToken;
  final DateTime accessExpiresAt;

  /// True when the access token should be renewed proactively.
  bool get expiresSoon =>
      accessExpiresAt.difference(DateTime.now().toUtc()) <
      const Duration(minutes: 1);

  Session copyWith({
    String? userId,
    String? username,
    Role? role,
    String? accessToken,
    String? refreshToken,
    DateTime? accessExpiresAt,
  }) => Session(
    userId: userId ?? this.userId,
    username: username ?? this.username,
    role: role ?? this.role,
    accessToken: accessToken ?? this.accessToken,
    refreshToken: refreshToken ?? this.refreshToken,
    accessExpiresAt: accessExpiresAt ?? this.accessExpiresAt,
  );

  @override
  bool operator ==(Object other) =>
      other is Session &&
      other.userId == userId &&
      other.username == username &&
      other.role == role &&
      other.accessToken == accessToken &&
      other.refreshToken == refreshToken &&
      other.accessExpiresAt == accessExpiresAt;

  @override
  int get hashCode => Object.hash(
    userId,
    username,
    role,
    accessToken,
    refreshToken,
    accessExpiresAt,
  );

  @override
  String toString() =>
      'Session($userId, $username, ${role.name}, expires=$accessExpiresAt)';
}

/// Storage abstraction for session secrets (FR-009).
///
/// Implementations live in platform packages: encrypted keystore/keychain on
/// mobile, httpOnly-cookie-backed or encrypted storage on web.
abstract interface class CredentialStore {
  Future<void> save(Session session);

  /// Returns the persisted session, or `null` when none exists.
  Future<Session?> load();

  Future<void> clear();
}
