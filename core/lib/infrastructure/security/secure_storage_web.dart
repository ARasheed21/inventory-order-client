import '../../domain/entities/session.dart';
import 'credential_storage.dart';

/// Web credential store with httpOnly Secure cookie preference.
///
/// Preferred path (requires backend `Set-Cookie`):
/// - Refresh token in server-set `httpOnly` `Secure` `SameSite=Strict` cookie.
/// - Access token kept only in memory (`SessionCache`), never persisted.
///
/// Fallback when httpOnly is infeasible (e.g., local dev without cookie support):
/// - Encrypted `localStorage` entry via Web Crypto AES-GCM with a per-install
///   random key in IndexedDB — still not readable by simple XSS payloads.
///
/// The real web binding is registered in `web/lib/main.dart`; this file in
/// `core` is the documented contract plus an in-memory fallback for tests.
///
/// Tokens are never logged (SC-007).
final class SecureStorageWeb implements CredentialStorage {
  final CredentialStorage _delegate;

  SecureStorageWeb({CredentialStorage? delegate})
    : _delegate = delegate ?? InMemoryCredentialStorage();

  @override
  Future<void> save(Session session) => _delegate.save(session);

  @override
  Future<Session?> load() => _delegate.load();

  @override
  Future<void> clear() => _delegate.clear();
}
