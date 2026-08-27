//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'inventory_response.g.dart';

/// Inventory payload returned by the REST API
///
/// Properties:
/// * [productId] - Product identifier
/// * [name] - Product name
/// * [quantityInStock] - Current stock quantity
@BuiltValue()
abstract class InventoryResponse
    implements Built<InventoryResponse, InventoryResponseBuilder> {
  /// Product identifier
  @BuiltValueField(wireName: r'productId')
  String? get productId;

  /// Product name
  @BuiltValueField(wireName: r'name')
  String? get name;

  /// Current stock quantity
  @BuiltValueField(wireName: r'quantityInStock')
  int? get quantityInStock;

  InventoryResponse._();

  factory InventoryResponse([void updates(InventoryResponseBuilder b)]) =
      _$InventoryResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InventoryResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InventoryResponse> get serializer =>
      _$InventoryResponseSerializer();
}

class _$InventoryResponseSerializer
    implements PrimitiveSerializer<InventoryResponse> {
  @override
  final Iterable<Type> types = const [InventoryResponse, _$InventoryResponse];

  @override
  final String wireName = r'InventoryResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InventoryResponse object, {
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
  }

  @override
  Object serialize(
    Serializers serializers,
    InventoryResponse object, {
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
    required InventoryResponseBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InventoryResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InventoryResponseBuilder();
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
