import '../../domain/entities/session.dart'
    show CredentialStore, Session;

/// Canonical alias per plan (tasks use `CredentialStorage`); implementation
/// lives in platform packages. This file keeps both names interoperable.
typedef CredentialStorage = CredentialStore;

/// In-memory fallback used in tests and when no platform store is registered.
///
/// Never used in release builds; it satisfies the contract for hermetic
/// unit tests without pulling platform dependencies into `core`.
final class InMemoryCredentialStorage implements CredentialStore {
  Session? _session;

  @override
  Future<void> save(Session session) async {
    _session = session;
  }

  @override
  Future<Session?> load() async => _session;

  @override
  Future<void> clear() async {
    _session = null;
  }
}
