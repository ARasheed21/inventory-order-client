import 'package:dio/dio.dart';

import '../network/generated/src/api/authentication_api.dart';
import '../network/generated/src/model/register_request.dart';
import '../network/generated/src/model/register_response.dart';
import '../network/generated/src/serializers.dart';

/// Thin wrapper around the generated `AuthenticationApi` to isolate
/// Dio/DTO details from the repository (Constitution I).
///
/// Used by `AuthRepositoryImpl` for the registration flow (T026).
final class AuthRemoteDataSource {
  AuthRemoteDataSource(Dio dio)
    : _api = AuthenticationApi(dio, standardSerializers);

  final AuthenticationApi _api;

  Future<RegisterResponse> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final Response<RegisterResponse> response = await _api.register(
      registerRequest: RegisterRequest(
        (RegisterRequestBuilder b) => b
          ..username = username
          ..email = email
          ..password = password,
      ),
    );
    return response.data!;
  }
}
