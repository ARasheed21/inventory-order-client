import 'package:meta/meta.dart';

import '../value_objects/email.dart';
import '../value_objects/username.dart';
import 'session.dart';

/// Domain representation of a registered user (data-model.md §2).
///
/// Invariants: `roles` never empty; `username`/`email` validity guaranteed
/// by value objects (account cannot exist with invalid constituents).
@immutable
final class Account {
  const Account({
    required this.id,
    required this.username,
    required this.email,
    required this.roles,
    this.createdAt,
  }) : assert(id != '', 'id must be non-empty');

  final String id;
  final Username username;
  final Email email;
  final Set<Role> roles;
  final DateTime? createdAt;

  Account copyWith({
    String? id,
    Username? username,
    Email? email,
    Set<Role>? roles,
    DateTime? createdAt,
  }) =>
      Account(
        id: id ?? this.id,
        username: username ?? this.username,
        email: email ?? this.email,
        roles: roles ?? this.roles,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      other is Account &&
      other.id == id &&
      other.username == username &&
      other.email == email &&
      other.roles.length == roles.length &&
      other.roles.containsAll(roles);

  @override
  int get hashCode => Object.hash(id, username, email, Object.hashAll(roles));

  @override
  String toString() => 'Account($id, ${username.value}, ${email.value}, $roles)';
}
