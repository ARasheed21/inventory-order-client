import 'package:meta/meta.dart';

/// Authorization roles carried by a session (Constitution VI).
enum Role { customer, warehouse, admin }

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
