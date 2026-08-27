import '../../domain/resource_key.dart';

/// A session-scoped, in-memory read-model wrapper (data-model.md §5).
class CachedEntry {
  CachedEntry({required this.payload, required this.fetchedAt});

  Object payload;
  DateTime fetchedAt;
  bool isStale = false;
}

/// In-memory cache port used by read-heavy screens (FR-011).
///
/// Lifetime equals the process/session: entries are cleared on logout and
/// never persisted. Persistent offline caching is deferred to feature epics
/// that need it.
abstract interface class ReadCache {
  T? get<T>(ResourceKey key);

  void put<T>(ResourceKey key, T payload);

  void invalidate(ResourceKey key);

  /// Marks an entry stale without dropping it (failed refresh / push hint).
  void markStale(ResourceKey key);

  void clear();
}

final class InMemoryReadCache implements ReadCache {
  final Map<ResourceKey, CachedEntry> _entries = {};

  @override
  T? get<T>(ResourceKey key) {
    final CachedEntry? entry = _entries[key];
    if (entry == null) return null;
    if (entry.payload is! T) return null;
    return entry.payload as T;
  }

  @override
  void put<T>(ResourceKey key, T payload) {
    final CachedEntry? existing = _entries[key];
    if (existing != null && identical(existing.payload, payload as Object?)) {
      existing.isStale = false;
      return;
    }
    _entries[key] = CachedEntry(
      payload: payload as Object,
      fetchedAt: DateTime.now().toUtc(),
    );
  }

  @override
  void invalidate(ResourceKey key) => _entries.remove(key);

  @override
  void markStale(ResourceKey key) {
    _entries[key]?.isStale = true;
  }

  @override
  void clear() => _entries.clear();
}
