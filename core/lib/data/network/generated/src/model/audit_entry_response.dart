//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'audit_entry_response.g.dart';

/// AuditEntryResponse
///
/// Properties:
/// * [revision]
/// * [timestamp]
/// * [author]
/// * [revisionType]
/// * [snapshot]
@BuiltValue()
abstract class AuditEntryResponse
    implements Built<AuditEntryResponse, AuditEntryResponseBuilder> {
  @BuiltValueField(wireName: r'revision')
  int? get revision;

  @BuiltValueField(wireName: r'timestamp')
  int? get timestamp;

  @BuiltValueField(wireName: r'author')
  String? get author;

  @BuiltValueField(wireName: r'revisionType')
  String? get revisionType;

  @BuiltValueField(wireName: r'snapshot')
  BuiltMap<String, JsonObject?>? get snapshot;

  AuditEntryResponse._();

  factory AuditEntryResponse([void updates(AuditEntryResponseBuilder b)]) =
      _$AuditEntryResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuditEntryResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuditEntryResponse> get serializer =>
      _$AuditEntryResponseSerializer();
}

class _$AuditEntryResponseSerializer
    implements PrimitiveSerializer<AuditEntryResponse> {
  @override
  final Iterable<Type> types = const [AuditEntryResponse, _$AuditEntryResponse];

  @override
  final String wireName = r'AuditEntryResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuditEntryResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.revision != null) {
      yield r'revision';
      yield serializers.serialize(
        object.revision,
        specifiedType: const FullType(int),
      );
    }
    if (object.timestamp != null) {
      yield r'timestamp';
      yield serializers.serialize(
        object.timestamp,
        specifiedType: const FullType(int),
      );
    }
    if (object.author != null) {
      yield r'author';
      yield serializers.serialize(
        object.author,
        specifiedType: const FullType(String),
      );
    }
    if (object.revisionType != null) {
      yield r'revisionType';
      yield serializers.serialize(
        object.revisionType,
        specifiedType: const FullType(String),
      );
    }
    if (object.snapshot != null) {
      yield r'snapshot';
      yield serializers.serialize(
        object.snapshot,
        specifiedType: const FullType(BuiltMap, [
          FullType(String),
          FullType.nullable(JsonObject),
        ]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AuditEntryResponse object, {
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
    required AuditEntryResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'revision':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.revision = valueDes;
          break;
        case r'timestamp':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.timestamp = valueDes;
          break;
        case r'author':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.author = valueDes;
          break;
        case r'revisionType':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.revisionType = valueDes;
          break;
        case r'snapshot':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltMap, [
                      FullType(String),
                      FullType.nullable(JsonObject),
                    ]),
                  )
                  as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.snapshot.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuditEntryResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuditEntryResponseBuilder();
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
