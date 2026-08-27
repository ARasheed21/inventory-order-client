import 'package:meta/meta.dart';

/// Namespaced identifier for a cacheable resource read model
/// (e.g. `catalog:list`, `product:{id}`).
@immutable
class ResourceKey {
  const ResourceKey._(this._value);

  factory ResourceKey(String namespace, String id) {
    if (namespace.trim().isEmpty) {
      throw ArgumentError.value(namespace, 'namespace', 'must be non-empty');
    }
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'must be non-empty');
    }
    return ResourceKey._('$namespace:$id');
  }

  final String _value;

  String get namespace => _value.split(':').first;

  @override
  String toString() => _value;

  @override
  bool operator ==(Object other) =>
      other is ResourceKey && other._value == _value;

  @override
  int get hashCode => _value.hashCode;
}
