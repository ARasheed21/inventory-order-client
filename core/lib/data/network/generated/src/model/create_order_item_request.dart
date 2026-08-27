//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_order_item_request.g.dart';

/// Order item payload for a product reservation
///
/// Properties:
/// * [productId] - Identifier of the product to reserve
/// * [quantity] - Requested item quantity
@BuiltValue()
abstract class CreateOrderItemRequest
    implements Built<CreateOrderItemRequest, CreateOrderItemRequestBuilder> {
  /// Identifier of the product to reserve
  @BuiltValueField(wireName: r'productId')
  String get productId;

  /// Requested item quantity
  @BuiltValueField(wireName: r'quantity')
  int? get quantity;

  CreateOrderItemRequest._();

  factory CreateOrderItemRequest([
    void updates(CreateOrderItemRequestBuilder b),
  ]) = _$CreateOrderItemRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateOrderItemRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateOrderItemRequest> get serializer =>
      _$CreateOrderItemRequestSerializer();
}

class _$CreateOrderItemRequestSerializer
    implements PrimitiveSerializer<CreateOrderItemRequest> {
  @override
  final Iterable<Type> types = const [
    CreateOrderItemRequest,
    _$CreateOrderItemRequest,
  ];

  @override
  final String wireName = r'CreateOrderItemRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateOrderItemRequest object, {
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
    CreateOrderItemRequest object, {
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
    required CreateOrderItemRequestBuilder result,
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
  CreateOrderItemRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateOrderItemRequestBuilder();
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
