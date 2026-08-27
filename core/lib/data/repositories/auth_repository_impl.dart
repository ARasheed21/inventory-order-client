import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../infrastructure/observability/reporter.dart';
import '../../domain/entities/session.dart';
import '../../domain/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../network/generated/src/api/authentication_api.dart';
import '../network/generated/src/model/login_request.dart';
import '../network/generated/src/model/refresh_request.dart';
import '../network/generated/src/model/register_request.dart';
import '../network/generated/src/model/register_response.dart';
import '../network/generated/src/serializers.dart';
import '../network/api_http_client.dart';
import '../network/failure_mapper.dart';

Map<String, dynamic> _unwrap(JsonObject object) =>
    Map<String, dynamic>.from(object.asMap);

/// Data-layer implementation of [AuthRepository] backed by the generated
/// contract client and a platform-provided secure [CredentialStore].
final class AuthRepositoryImpl implements AuthRepository, SessionCredentials {
  AuthRepositoryImpl({
    required Dio dio,
    required this.credentialStore,
    Reporter reporter = const ConsoleReporter(),
  }) : _authenticationApi = AuthenticationApi(dio, standardSerializers),
       _reporter = reporter;

  final AuthenticationApi _authenticationApi;
  final CredentialStore credentialStore;
  final Reporter _reporter;

  Session? _current;
  final StreamController<Session?> _sessionStream =
      StreamController<Session?>.broadcast();

  @override
  Session? get current => _current;

  @override
  Stream<Session?> watchSession() => _sessionStream.stream;

  @override
  String? get accessToken => _current?.accessToken;

  @override
  Future<String?> renewAccessToken() async {
    final Either<Failure, Session> result = await refresh();
    return result.fold((Failure failure) {
      _reporter.log(
        AppLogLevel.warning,
        'auth.refresh_failed',
        context: {'error': failure.userMessage},
      );
      return null;
    }, (Session session) => session.accessToken);
  }

  @override
  Future<Either<Failure, Session>> login(String username, String password) =>
      _authenticate(
        () => _authenticationApi.login(
          loginRequest: LoginRequest(
            (LoginRequestBuilder b) => b
              ..username = username
              ..password = password,
          ),
        ),
      );

  @override
  Future<Either<Failure, Session>> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final Response<RegisterResponse> response = await _authenticationApi
          .register(
            registerRequest: RegisterRequest(
              (RegisterRequestBuilder b) => b
                ..username = username
                ..email = email
                ..password = password,
            ),
          );
      final RegisterResponse payload = response.data!;
      final Session created = Session(
        userId: payload.username ?? '',
        username: payload.username ?? '',
        role: Role.customer,
        accessToken: payload.accessToken ?? '',
        refreshToken: payload.refreshToken ?? '',
        accessExpiresAt: DateTime.now().toUtc().add(
          Duration(seconds: payload.expiresIn ?? 0),
        ),
      );
      await _persist(created);
      return Right(created);
    } on DioException catch (e, s) {
      return Left(mapDioError(e, stackTrace: s));
    }
  }

  /// Restores a persisted session from secure storage at startup so users
  /// stay logged in across restarts (FR-009).
  Future<void> restore() async {
    final Session? stored = await credentialStore.load();
    if (stored != null && _current == null) {
      _current = stored;
      _sessionStream.add(stored);
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    await credentialStore.clear();
    _current = null;
    _sessionStream.add(null);
    return const Right<Failure, void>(null);
  }

  @override
  Future<Either<Failure, Session>> refresh() async {
    final Session? session = _current;
    if (session == null) return const Left(AuthenticationFailure());
    try {
      final Response<JsonObject> response = await _authenticationApi.refresh(
        refreshRequest: RefreshRequest(
          (RefreshRequestBuilder b) => b..refreshToken = session.refreshToken,
        ),
      );
      final Map<String, dynamic> payload = _unwrap(response.data!);
      // The refresh endpoint may only rotate the access token; keep the
      // existing refresh token when the payload omits it.
      final Session renewed = _sessionFromPayload(
        payload,
        fallbackRefreshToken: session.refreshToken,
      );
      await _persist(renewed);
      return Right(renewed);
    } on DioException catch (e, s) {
      final Failure failure = mapDioError(e, stackTrace: s);
      if (failure is AuthenticationFailure && _current != null) {
        await logout();
      }
      return Left(failure);
    }
  }

  Future<Either<Failure, Session>> _authenticate(
    Future<Response<JsonObject>> Function() call,
  ) async {
    try {
      final Response<JsonObject> response = await call();
      final Session session = _sessionFromPayload(_unwrap(response.data!));
      await _persist(session);
      return Right(session);
    } on DioException catch (e, s) {
      return Left(mapDioError(e, stackTrace: s));
    }
  }

  Future<void> _persist(Session session) async {
    _current = session;
    await credentialStore.save(session);
    _sessionStream.add(session);
  }

  Session _sessionFromPayload(
    Map<String, dynamic> payload, {
    String? fallbackRefreshToken,
  }) {
    final int expiresIn = switch (payload['expiresIn']) {
      final int v => v,
      final num v => v.toInt(),
      final String v => int.parse(v),
      _ => throw const UnknownFailure(message: 'Malformed token payload.'),
    };
    return Session(
      userId: '${payload['userId'] ?? payload['username'] ?? ''}',
      username: '${payload['username'] ?? ''}',
      role: Role.customer,
      accessToken: '${payload['accessToken'] ?? ''}',
      refreshToken: '${payload['refreshToken'] ?? fallbackRefreshToken ?? ''}',
      accessExpiresAt: DateTime.now().toUtc().add(Duration(seconds: expiresIn)),
    );
  }
}
