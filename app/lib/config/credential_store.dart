import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:core/core.dart';

/// Stores session secrets in platform-secure storage
/// (keystore/keychain-backed via [FlutterSecureStorage]) per FR-009.
final class FlutterSecureCredentialStore implements CredentialStore {
  FlutterSecureCredentialStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          );

  final FlutterSecureStorage _storage;

  static const String _key = 'inventory.session';

  @override
  Future<void> save(Session session) async {
    await _storage.write(
      key: _key,
      value: jsonEncode(<String, dynamic>{
        'userId': session.userId,
        'username': session.username,
        'role': session.role.name,
        'accessToken': session.accessToken,
        'refreshToken': session.refreshToken,
        'accessExpiresAt': session.accessExpiresAt.toIso8601String(),
      }),
    );
  }

  @override
  Future<Session?> load() async {
    final String? raw = await _storage.read(key: _key);
    if (raw == null) return null;
    try {
      final Map<String, dynamic> data = Map<String, dynamic>.from(
        jsonDecode(raw) as Map<dynamic, dynamic>,
      );
      return Session(
        userId: '${data['userId'] ?? ''}',
        username: '${data['username'] ?? ''}',
        role: Role.values.firstWhere(
          (Role r) => r.name == data['role'],
          orElse: () => Role.customer,
        ),
        accessToken: '${data['accessToken'] ?? ''}',
        refreshToken: '${data['refreshToken'] ?? ''}',
        accessExpiresAt: DateTime.parse(
          '${data['accessExpiresAt'] ?? DateTime.now().toIso8601String()}',
        ),
      );
    } on FormatException {
      // Corrupted entry: drop it rather than crash at startup.
      await clear();
      return null;
    }
  }

  @override
  Future<void> clear() => _storage.delete(key: _key);
}
