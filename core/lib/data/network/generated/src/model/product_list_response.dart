//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:core/data/network/generated/src/model/product_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'product_list_response.g.dart';

/// Paginated product catalog page
///
/// Properties:
/// * [content] - Products on this page
/// * [total] - Total number of matching products
/// * [page] - Current page number (0-based)
/// * [size] - Page size
@BuiltValue()
abstract class ProductListResponse
    implements Built<ProductListResponse, ProductListResponseBuilder> {
  /// Products on this page
  @BuiltValueField(wireName: r'content')
  BuiltList<ProductResponse>? get content;

  /// Total number of matching products
  @BuiltValueField(wireName: r'total')
  int? get total;

  /// Current page number (0-based)
  @BuiltValueField(wireName: r'page')
  int? get page;

  /// Page size
  @BuiltValueField(wireName: r'size')
  int? get size;

  ProductListResponse._();

  factory ProductListResponse([void updates(ProductListResponseBuilder b)]) =
      _$ProductListResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProductListResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProductListResponse> get serializer =>
      _$ProductListResponseSerializer();
}

class _$ProductListResponseSerializer
    implements PrimitiveSerializer<ProductListResponse> {
  @override
  final Iterable<Type> types = const [
    ProductListResponse,
    _$ProductListResponse,
  ];

  @override
  final String wireName = r'ProductListResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProductListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.content != null) {
      yield r'content';
      yield serializers.serialize(
        object.content,
        specifiedType: const FullType(BuiltList, [FullType(ProductResponse)]),
      );
    }
    if (object.total != null) {
      yield r'total';
      yield serializers.serialize(
        object.total,
        specifiedType: const FullType(int),
      );
    }
    if (object.page != null) {
      yield r'page';
      yield serializers.serialize(
        object.page,
        specifiedType: const FullType(int),
      );
    }
    if (object.size != null) {
      yield r'size';
      yield serializers.serialize(
        object.size,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ProductListResponse object, {
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
    required ProductListResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'content':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(ProductResponse),
                    ]),
                  )
                  as BuiltList<ProductResponse>?;
          if (valueDes == null) continue;
          result.content.replace(valueDes);
          break;
        case r'total':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.total = valueDes;
          break;
        case r'page':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.page = valueDes;
          break;
        case r'size':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.size = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProductListResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProductListResponseBuilder();
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
