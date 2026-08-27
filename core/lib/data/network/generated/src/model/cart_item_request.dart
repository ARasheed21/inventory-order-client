//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'cart_item_request.g.dart';

/// Payload used to create or update a cart item
///
/// Properties:
/// * [productId] - Identifier of the product to add to the cart
/// * [quantity] - Quantity of the product in the cart
@BuiltValue()
abstract class CartItemRequest
    implements Built<CartItemRequest, CartItemRequestBuilder> {
  /// Identifier of the product to add to the cart
  @BuiltValueField(wireName: r'productId')
  String get productId;

  /// Quantity of the product in the cart
  @BuiltValueField(wireName: r'quantity')
  int? get quantity;

  CartItemRequest._();

  factory CartItemRequest([void updates(CartItemRequestBuilder b)]) =
      _$CartItemRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CartItemRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CartItemRequest> get serializer =>
      _$CartItemRequestSerializer();
}

class _$CartItemRequestSerializer
    implements PrimitiveSerializer<CartItemRequest> {
  @override
  final Iterable<Type> types = const [CartItemRequest, _$CartItemRequest];

  @override
  final String wireName = r'CartItemRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CartItemRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'productId';
    yield serializers.serialize(
      object.productId,
      specifiedType: const FullType(String),
    );
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
    CartItemRequest object, {
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
    required CartItemRequestBuilder result,
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
                    specifiedType: const FullType(String),
                  )
                  as String;
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
  CartItemRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CartItemRequestBuilder();
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
