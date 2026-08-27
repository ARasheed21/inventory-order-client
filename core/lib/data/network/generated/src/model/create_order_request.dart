//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:core/data/network/generated/src/model/create_order_item_request.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_order_request.g.dart';

/// Payload used to create a new order
///
/// Properties:
/// * [customerId] - Customer identifier
/// * [items] - Order items to reserve
@BuiltValue()
abstract class CreateOrderRequest
    implements Built<CreateOrderRequest, CreateOrderRequestBuilder> {
  /// Customer identifier
  @BuiltValueField(wireName: r'customerId')
  String get customerId;

  /// Order items to reserve
  @BuiltValueField(wireName: r'items')
  BuiltList<CreateOrderItemRequest> get items;

  CreateOrderRequest._();

  factory CreateOrderRequest([void updates(CreateOrderRequestBuilder b)]) =
      _$CreateOrderRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateOrderRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateOrderRequest> get serializer =>
      _$CreateOrderRequestSerializer();
}

class _$CreateOrderRequestSerializer
    implements PrimitiveSerializer<CreateOrderRequest> {
  @override
  final Iterable<Type> types = const [CreateOrderRequest, _$CreateOrderRequest];

  @override
  final String wireName = r'CreateOrderRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateOrderRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'customerId';
    yield serializers.serialize(
      object.customerId,
      specifiedType: const FullType(String),
    );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [
        FullType(CreateOrderItemRequest),
      ]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateOrderRequest object, {
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
    required CreateOrderRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'customerId':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.customerId = valueDes;
          break;
        case r'items':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(CreateOrderItemRequest),
                    ]),
                  )
                  as BuiltList<CreateOrderItemRequest>;
          result.items.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateOrderRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateOrderRequestBuilder();
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
