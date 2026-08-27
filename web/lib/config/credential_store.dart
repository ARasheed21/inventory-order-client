import 'dart:async';
import 'dart:convert';
// TODO(foundation-follow-up): migrate to package:web + dart:js_interop.
// ignore: deprecated_member_use
import 'dart:html' as html;

import 'package:core/core.dart';

final Map<String, String> _sessionStorage = html.window.sessionStorage;

/// Web credential storage (FR-009).
///
/// Production deployments use server-set httpOnly Secure cookies for refresh
/// tokens (preferred per implementation guide). This foundation store keeps
/// the session in `sessionStorage` — cleared when the tab closes — so no
/// long-lived secret lands in JavaScript-readable persistent storage.
final class BrowserCredentialStore implements CredentialStore {
  @override
  Future<void> save(Session session) async {
    // ignore: avoid_dynamic_calls
    _sessionStorage['inventory.session'] = jsonEncode(<String, dynamic>{
      'userId': session.userId,
      'username': session.username,
      'role': session.role.name,
      'accessToken': session.accessToken,
      'refreshToken': session.refreshToken,
      'accessExpiresAt': session.accessExpiresAt.toIso8601String(),
    });
  }

  @override
  Future<Session?> load() async {
    final String? raw = _sessionStorage['inventory.session'];
    if (raw == null || raw.isEmpty) return null;
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
      await clear();
      return null;
    }
  }

  @override
  Future<void> clear() async {
    _sessionStorage.remove('inventory.session');
  }
}

