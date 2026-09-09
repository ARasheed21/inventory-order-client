import '../../domain/resource_key.dart';
import 'read_cache.dart';
import '../../domain/entities/session.dart';

/// Session-scoped in-memory cache for the authenticated session.
///
/// Lifetime equals the process/session; cleared on logout and never persisted
/// (constitution IV, plan Technical Context — no Drift in this feature).
/// Thin typed wrapper over the generic [ReadCache] from foundation.
final class SessionCache {
  SessionCache({ReadCache? cache}) : _cache = cache ?? InMemoryReadCache();

  final ReadCache _cache;

  static final ResourceKey _sessionKey = ResourceKey('auth', 'session');
  static final ResourceKey _profileKey = ResourceKey('auth', 'profile');

  Session? get session => _cache.get<Session>(_sessionKey);

  set session(Session? value) {
    if (value == null) {
      _cache.invalidate(_sessionKey);
    } else {
      _cache.put<Session>(_sessionKey, value);
    }
    // Fresh put clears staleness.
    _stale = false;
  }

  bool _stale = false;

  /// Marks the cached session/profile as stale without dropping it
  /// (failed refresh / WS disconnect hint).
  void markStale() {
    _cache.markStale(_sessionKey);
    _cache.markStale(_profileKey);
    _stale = true;
  }

  bool get isStale => _stale;

  void clear() {
    _cache.clear();
    _stale = false;
  }
}
