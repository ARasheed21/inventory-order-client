//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'register_response.g.dart';

/// Returned after successful registration; the account is created and tokens are issued immediately
///
/// Properties:
/// * [username] - Username of the created account
/// * [accessToken] - JWT access token for Authorization: Bearer headers
/// * [refreshToken] - JWT refresh token for POST /auth/refresh
/// * [expiresIn] - Access token lifetime in seconds
@BuiltValue()
abstract class RegisterResponse
    implements Built<RegisterResponse, RegisterResponseBuilder> {
  /// Username of the created account
  @BuiltValueField(wireName: r'username')
  String? get username;

  /// JWT access token for Authorization: Bearer headers
  @BuiltValueField(wireName: r'accessToken')
  String? get accessToken;

  /// JWT refresh token for POST /auth/refresh
  @BuiltValueField(wireName: r'refreshToken')
  String? get refreshToken;

  /// Access token lifetime in seconds
  @BuiltValueField(wireName: r'expiresIn')
  int? get expiresIn;

  RegisterResponse._();

  factory RegisterResponse([void updates(RegisterResponseBuilder b)]) =
      _$RegisterResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RegisterResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RegisterResponse> get serializer =>
      _$RegisterResponseSerializer();
}

class _$RegisterResponseSerializer
    implements PrimitiveSerializer<RegisterResponse> {
  @override
  final Iterable<Type> types = const [RegisterResponse, _$RegisterResponse];

  @override
  final String wireName = r'RegisterResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RegisterResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.username != null) {
      yield r'username';
      yield serializers.serialize(
        object.username,
        specifiedType: const FullType(String),
      );
    }
    if (object.accessToken != null) {
      yield r'accessToken';
      yield serializers.serialize(
        object.accessToken,
        specifiedType: const FullType(String),
      );
    }
    if (object.refreshToken != null) {
      yield r'refreshToken';
      yield serializers.serialize(
        object.refreshToken,
        specifiedType: const FullType(String),
      );
    }
    if (object.expiresIn != null) {
      yield r'expiresIn';
      yield serializers.serialize(
        object.expiresIn,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    RegisterResponse object, {
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
    required RegisterResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'username':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.username = valueDes;
          break;
        case r'accessToken':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.accessToken = valueDes;
          break;
        case r'refreshToken':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.refreshToken = valueDes;
          break;
        case r'expiresIn':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.expiresIn = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RegisterResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RegisterResponseBuilder();
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
