import '../../domain/entities/session.dart';
import 'credential_storage.dart';

/// Mobile credential store backed by `flutter_secure_storage`.
///
/// The real implementation lives in `app/` where the Flutter dependency is
/// available. This file in `core` documents the contract and provides a
/// test-friendly in-memory fallback. The `AppSecureStorage` in
/// `app/lib/infrastructure/security/app_secure_storage.dart` should implement
/// [CredentialStorage] by delegating to `FlutterSecureStorage` with
/// `EncryptedSharedPreferences` on Android API 26+ (see implementation-guide §7).
///
/// Storage keys (canonical):
/// - `auth.access_token`
/// - `auth.refresh_token`
/// - `auth.user_id`
/// - `auth.username`
/// - `auth.role`
/// - `auth.expires_at` (ISO 8601 UTC)
///
/// Tokens are never logged; `Session.toString` already redacts secrets.
final class SecureStorageMobile implements CredentialStorage {
  final CredentialStorage _delegate;

  SecureStorageMobile({CredentialStorage? delegate})
    : _delegate = delegate ?? InMemoryCredentialStorage();

  @override
  Future<void> save(Session session) => _delegate.save(session);

  @override
  Future<Session?> load() => _delegate.load();

  @override
  Future<void> clear() => _delegate.clear();
}
