//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'order_response.g.dart';

/// Order payload returned by the REST API
///
/// Properties:
/// * [id] - Order identifier
/// * [customerId] - Customer identifier
/// * [status] - Order lifecycle status
/// * [totalAmount] - Order total amount
/// * [currency] - Currency code
/// * [createdAt] - Order creation timestamp
/// * [reservedUntil] - Reservation expiry timestamp
/// * [reservationSecondsRemaining] - Server-computed seconds left before the reservation expires (0 when not pending)
@BuiltValue()
abstract class OrderResponse
    implements Built<OrderResponse, OrderResponseBuilder> {
  /// Order identifier
  @BuiltValueField(wireName: r'id')
  String? get id;

  /// Customer identifier
  @BuiltValueField(wireName: r'customerId')
  String? get customerId;

  /// Order lifecycle status
  @BuiltValueField(wireName: r'status')
  String? get status;

  /// Order total amount
  @BuiltValueField(wireName: r'totalAmount')
  num? get totalAmount;

  /// Currency code
  @BuiltValueField(wireName: r'currency')
  String? get currency;

  /// Order creation timestamp
  @BuiltValueField(wireName: r'createdAt')
  DateTime? get createdAt;

  /// Reservation expiry timestamp
  @BuiltValueField(wireName: r'reservedUntil')
  DateTime? get reservedUntil;

  /// Server-computed seconds left before the reservation expires (0 when not pending)
  @BuiltValueField(wireName: r'reservationSecondsRemaining')
  int? get reservationSecondsRemaining;

  OrderResponse._();

  factory OrderResponse([void updates(OrderResponseBuilder b)]) =
      _$OrderResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OrderResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OrderResponse> get serializer =>
      _$OrderResponseSerializer();
}

class _$OrderResponseSerializer implements PrimitiveSerializer<OrderResponse> {
  @override
  final Iterable<Type> types = const [OrderResponse, _$OrderResponse];

  @override
  final String wireName = r'OrderResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrderResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.customerId != null) {
      yield r'customerId';
      yield serializers.serialize(
        object.customerId,
        specifiedType: const FullType(String),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(String),
      );
    }
    if (object.totalAmount != null) {
      yield r'totalAmount';
      yield serializers.serialize(
        object.totalAmount,
        specifiedType: const FullType(num),
      );
    }
    if (object.currency != null) {
      yield r'currency';
      yield serializers.serialize(
        object.currency,
        specifiedType: const FullType(String),
      );
    }
    if (object.createdAt != null) {
      yield r'createdAt';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.reservedUntil != null) {
      yield r'reservedUntil';
      yield serializers.serialize(
        object.reservedUntil,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.reservationSecondsRemaining != null) {
      yield r'reservationSecondsRemaining';
      yield serializers.serialize(
        object.reservationSecondsRemaining,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    OrderResponse object, {
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
    required OrderResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'customerId':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.customerId = valueDes;
          break;
        case r'status':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.status = valueDes;
          break;
        case r'totalAmount':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(num),
                  )
                  as num?;
          if (valueDes == null) continue;
          result.totalAmount = valueDes;
          break;
        case r'currency':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.currency = valueDes;
          break;
        case r'createdAt':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.createdAt = valueDes;
          break;
        case r'reservedUntil':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.reservedUntil = valueDes;
          break;
        case r'reservationSecondsRemaining':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.reservationSecondsRemaining = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OrderResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OrderResponseBuilder();
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
