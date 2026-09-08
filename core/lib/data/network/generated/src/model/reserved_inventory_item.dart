//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reserved_inventory_item.g.dart';

/// ReservedInventoryItem
///
/// Properties:
/// * [productId]
/// * [name]
/// * [quantityInStock]
/// * [quantityReserved]
/// * [quantityAvailable]
@BuiltValue()
abstract class ReservedInventoryItem
    implements Built<ReservedInventoryItem, ReservedInventoryItemBuilder> {
  @BuiltValueField(wireName: r'productId')
  String? get productId;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'quantityInStock')
  int? get quantityInStock;

  @BuiltValueField(wireName: r'quantityReserved')
  int? get quantityReserved;

  @BuiltValueField(wireName: r'quantityAvailable')
  int? get quantityAvailable;

  ReservedInventoryItem._();

  factory ReservedInventoryItem([
    void updates(ReservedInventoryItemBuilder b),
  ]) = _$ReservedInventoryItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReservedInventoryItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReservedInventoryItem> get serializer =>
      _$ReservedInventoryItemSerializer();
}

class _$ReservedInventoryItemSerializer
    implements PrimitiveSerializer<ReservedInventoryItem> {
  @override
  final Iterable<Type> types = const [
    ReservedInventoryItem,
    _$ReservedInventoryItem,
  ];

  @override
  final String wireName = r'ReservedInventoryItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReservedInventoryItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.productId != null) {
      yield r'productId';
      yield serializers.serialize(
        object.productId,
        specifiedType: const FullType(String),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.quantityInStock != null) {
      yield r'quantityInStock';
      yield serializers.serialize(
        object.quantityInStock,
        specifiedType: const FullType(int),
      );
    }
    if (object.quantityReserved != null) {
      yield r'quantityReserved';
      yield serializers.serialize(
        object.quantityReserved,
        specifiedType: const FullType(int),
      );
    }
    if (object.quantityAvailable != null) {
      yield r'quantityAvailable';
      yield serializers.serialize(
        object.quantityAvailable,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ReservedInventoryItem object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(
      serializers,
      object,
      specifiedType: specifiedType,
    ).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReservedInventoryItemBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'productId':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.productId = valueDes;
          break;
        case r'name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'quantityInStock':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.quantityInStock = valueDes;
          break;
        case r'quantityReserved':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.quantityReserved = valueDes;
          break;
        case r'quantityAvailable':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.quantityAvailable = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReservedInventoryItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReservedInventoryItemBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
