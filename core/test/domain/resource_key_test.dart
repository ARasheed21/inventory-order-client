import 'package:test/test.dart';

import 'package:core/domain/resource_key.dart';

void main() {
  group('ResourceKey', () {
    test('namespaces and ids compose into one value', () {
      final ResourceKey k = ResourceKey('catalog', 'list');
      expect(k.toString(), 'catalog:list');
      expect(k.namespace, 'catalog');
    });

    test('equal keys are equal and hash equal', () {
      expect(ResourceKey('product', '1'), equals(ResourceKey('product', '1')));
      expect(
        ResourceKey('product', '1').hashCode,
        ResourceKey('product', '1').hashCode,
      );
      expect(
        ResourceKey('product', '1'),
        isNot(equals(ResourceKey('product', '2'))),
      );
    });

    test('empty namespace or id is rejected', () {
      expect(() => ResourceKey('', 'id'), throwsArgumentError);
      expect(() => ResourceKey('ns', ' '), throwsArgumentError);
    });
  });
}
