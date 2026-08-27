import 'package:test/test.dart';

import 'package:core/data/cache/read_cache.dart';
import 'package:core/domain/resource_key.dart';

void main() {
  group('InMemoryReadCache', () {
    late InMemoryReadCache cache;

    setUp(() => cache = InMemoryReadCache());

    test('put/get round-trips typed payloads', () {
      final ResourceKey key = ResourceKey('catalog', 'list');
      cache.put<List<String>>(key, <String>['a', 'b']);
      expect(cache.get<List<String>>(key), <String>['a', 'b']);
      // Wrong type reads as absent.
      expect(cache.get<String>(key), isNull);
    });

    test('invalidate removes the entry', () {
      final ResourceKey key = ResourceKey('product', '1');
      cache.put<String>(key, 'payload');
      cache.invalidate(key);
      expect(cache.get<String>(key), isNull);
    });

    test('markStale flags without dropping data', () {
      final ResourceKey key = ResourceKey('catalog', 'list');
      cache.put<String>(key, 'stale-payload');
      cache.markStale(key);
      expect(cache.get<String>(key), 'stale-payload');
    });

    test('clear drops every entry (logout semantics)', () {
      cache.put<String>(ResourceKey('a', '1'), 'x');
      cache.put<String>(ResourceKey('b', '2'), 'y');
      cache.clear();
      expect(cache.get<String>(ResourceKey('a', '1')), isNull);
      expect(cache.get<String>(ResourceKey('b', '2')), isNull);
    });
  });
}
