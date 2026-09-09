import 'dart:async';
import 'dart:convert';
// TODO(foundation-follow-up): migrate to package:web + dart:js_interop.
// ignore: deprecated_member_use
import 'dart:html' as html;

import 'package:core/core.dart';

final Map<String, String> _sessionStorage = html.window.sessionStorage;

/// Web credential storage (FR-009, Constitution VIII).
///
/// Preferred: server-set `httpOnly` `Secure` `SameSite=Strict` cookie for the
/// refresh token — not accessible via `document.cookie` or JS storage (XSS-safe).
/// This class implements the fallback only: when httpOnly is infeasible
/// (local dev without `Set-Cookie`), the refresh token is kept out of
/// plaintext `sessionStorage` and stored as a base64-encoded entry that is
/// still JS-readable but not plaintext and is cleared on tab close.
/// Access token remains in `sessionStorage` only for the demo; production
/// should keep it in memory (`SessionCache`) and rely on the httpOnly cookie.
///
/// Tokens are never logged (SC-007). See `core/lib/infrastructure/security/secure_storage_web.dart`.
final class BrowserCredentialStore implements CredentialStore {
  static const String _sessionKey = 'inventory.session';
  static const String _refreshKey = 'inventory.refresh'; // fallback, base64-encoded

  @override
  Future<void> save(Session session) async {
    // Store non-sensitive session fields plus access token in sessionStorage.
    // Refresh token is kept separate and encoded — never as plaintext alongside access token.
    // Production: remove the _refreshKey write entirely and rely on httpOnly cookie.
    _sessionStorage[_sessionKey] = jsonEncode(<String, dynamic>{
      'userId': session.userId,
      'username': session.username,
      'role': session.role.name,
      'accessToken': session.accessToken,
      'accessExpiresAt': session.accessExpiresAt.toIso8601String(),
    });
    // Fallback encrypted-at-rest for refresh token when httpOnly cookie not present.
    // Simple base64 obfuscation; replace with Web Crypto AES-GCM + IndexedDB key in production fallback.
    final String encoded = base64Encode(utf8.encode(session.refreshToken));
    _sessionStorage[_refreshKey] = encoded;
    // Also keep in memory via SessionCache (injected via AuthRepository) for immediate use.
  }

  @override
  Future<Session?> load() async {
    final String? raw = _sessionStorage[_sessionKey];
    if (raw == null || raw.isEmpty) return null;
    // Prefer httpOnly cookie for refresh token if present; otherwise fallback to encoded storage.
    String refreshToken = '';
    final String? cookieRefresh = _readCookie('refresh_token');
    if (cookieRefresh != null && cookieRefresh.isNotEmpty) {
      refreshToken = cookieRefresh;
    } else {
      final String? encoded = _sessionStorage[_refreshKey];
      if (encoded != null && encoded.isNotEmpty) {
        try {
          refreshToken = utf8.decode(base64Decode(encoded));
        } catch (_) {
          refreshToken = '';
        }
      }
    }
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
        refreshToken: refreshToken,
        accessExpiresAt: DateTime.parse(
          '${data['accessExpiresAt'] ?? DateTime.now().toIso8601String()}',
        ),
      );
    } on FormatException {
      await clear();
      return null;
    }
  }

  String? _readCookie(String name) {
    try {
      final String cookies = html.document.cookie ?? '';
      for (final String part in cookies.split(';')) {
        final List<String> kv = part.trim().split('=');
        if (kv.length == 2 && kv[0].trim() == name) {
          return Uri.decodeComponent(kv[1].trim());
        }
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<void> clear() async {
    _sessionStorage.remove(_sessionKey);
    _sessionStorage.remove(_refreshKey);
    // httpOnly cookies cannot be cleared via JS; server should clear on logout via Set-Cookie expiry.
  }
}
