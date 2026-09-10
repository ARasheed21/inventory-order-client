import 'package:meta/meta.dart';

import 'session.dart';

/// Read-only view returned by `GET /auth/me` (FR-010, data-model.md §5).
///
/// No write path in this feature (profile editing out of scope).
@immutable
final class Profile {
  const Profile({
    required this.id,
    required this.username,
    required this.email,
    required this.roles,
  });

  final String id;
  final String username;
  final String email;
  final Set<Role> roles;

  factory Profile.fromJson(Map<String, dynamic> json) {
    final String id = '${json['id'] ?? json['sub'] ?? ''}';
    final String username = '${json['username'] ?? ''}';
    final String email = '${json['email'] ?? ''}';
    final List<dynamic> rawRoles = (json['roles'] as List<dynamic>?) ?? [];
    final Set<Role> roles = rawRoles
        .map((e) => _roleFromWire('$e'))
        .whereType<Role>()
        .toSet();
    // Fallback: if roles empty but single role string present
    if (roles.isEmpty && json['role'] is String) {
      final Role? r = _roleFromWire(json['role'] as String);
      if (r != null) roles.add(r);
    }
    return Profile(
      id: id,
      username: username,
      email: email,
      roles: roles.isEmpty ? {Role.customer} : roles,
    );
  }

  static Role? _roleFromWire(String wire) {
    final String normalized =
        wire.trim().toUpperCase().replaceFirst(RegExp(r'^ROLE_'), '');
    switch (normalized) {
      case 'CUSTOMER':
        return Role.customer;
      case 'WAREHOUSE':
        return Role.warehouse;
      case 'ADMIN':
        return Role.admin;
      default:
        return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is Profile &&
      other.id == id &&
      other.username == username &&
      other.email == email &&
      other.roles.length == roles.length &&
      other.roles.containsAll(roles);

  @override
  int get hashCode => Object.hash(id, username, email, Object.hashAll(roles));

  @override
  String toString() => 'Profile($id, $username, $email, $roles)';
}
