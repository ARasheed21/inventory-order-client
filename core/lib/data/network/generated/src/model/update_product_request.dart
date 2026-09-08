//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_product_request.g.dart';

/// Payload used to update an existing product entry
///
/// Properties:
/// * [name] - Product name
/// * [description] - Product description
/// * [price] - Product price
/// * [currency] - Currency code
/// * [quantityInStock] - Inventory quantity on hand
/// * [category] - Product category
@BuiltValue()
abstract class UpdateProductRequest
    implements Built<UpdateProductRequest, UpdateProductRequestBuilder> {
  /// Product name
  @BuiltValueField(wireName: r'name')
  String get name;

  /// Product description
  @BuiltValueField(wireName: r'description')
  String? get description;

  /// Product price
  @BuiltValueField(wireName: r'price')
  String get price;

  /// Currency code
  @BuiltValueField(wireName: r'currency')
  String get currency;

  /// Inventory quantity on hand
  @BuiltValueField(wireName: r'quantityInStock')
  int get quantityInStock;

  /// Product category
  @BuiltValueField(wireName: r'category')
  String? get category;

  UpdateProductRequest._();

  factory UpdateProductRequest([void updates(UpdateProductRequestBuilder b)]) =
      _$UpdateProductRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateProductRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateProductRequest> get serializer =>
      _$UpdateProductRequestSerializer();
}

class _$UpdateProductRequestSerializer
    implements PrimitiveSerializer<UpdateProductRequest> {
  @override
  final Iterable<Type> types = const [
    UpdateProductRequest,
    _$UpdateProductRequest,
  ];

  @override
  final String wireName = r'UpdateProductRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateProductRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType(String),
      );
    }
    yield r'price';
    yield serializers.serialize(
      object.price,
      specifiedType: const FullType(String),
    );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(String),
    );
    yield r'quantityInStock';
    yield serializers.serialize(
      object.quantityInStock,
      specifiedType: const FullType(int),
    );
    if (object.category != null) {
      yield r'category';
      yield serializers.serialize(
        object.category,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdateProductRequest object, {
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
    required UpdateProductRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.name = valueDes;
          break;
        case r'description':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
        case r'price':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.price = valueDes;
          break;
        case r'currency':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.currency = valueDes;
          break;
        case r'quantityInStock':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.quantityInStock = valueDes;
          break;
        case r'category':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.category = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdateProductRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateProductRequestBuilder();
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
