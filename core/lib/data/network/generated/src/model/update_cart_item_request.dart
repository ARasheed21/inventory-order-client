//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_cart_item_request.g.dart';

/// Payload used to update a cart item. productId is optional; when omitted the item keeps its current product.
///
/// Properties:
/// * [productId] - New product id (optional - omit to only change quantity)
/// * [quantity] - Quantity of the product in the cart
@BuiltValue()
abstract class UpdateCartItemRequest
    implements Built<UpdateCartItemRequest, UpdateCartItemRequestBuilder> {
  /// New product id (optional - omit to only change quantity)
  @BuiltValueField(wireName: r'productId')
  String? get productId;

  /// Quantity of the product in the cart
  @BuiltValueField(wireName: r'quantity')
  int? get quantity;

  UpdateCartItemRequest._();

  factory UpdateCartItemRequest([
    void updates(UpdateCartItemRequestBuilder b),
  ]) = _$UpdateCartItemRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateCartItemRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateCartItemRequest> get serializer =>
      _$UpdateCartItemRequestSerializer();
}

class _$UpdateCartItemRequestSerializer
    implements PrimitiveSerializer<UpdateCartItemRequest> {
  @override
  final Iterable<Type> types = const [
    UpdateCartItemRequest,
    _$UpdateCartItemRequest,
  ];

  @override
  final String wireName = r'UpdateCartItemRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateCartItemRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.productId != null) {
      yield r'productId';
      yield serializers.serialize(
        object.productId,
        specifiedType: const FullType(String),
      );
    }
    if (object.quantity != null) {
      yield r'quantity';
      yield serializers.serialize(
        object.quantity,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdateCartItemRequest object, {
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
    required UpdateCartItemRequestBuilder result,
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
        case r'quantity':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.quantity = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdateCartItemRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateCartItemRequestBuilder();
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
