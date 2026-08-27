import 'package:dio/dio.dart';

import '../../domain/failures.dart';

/// Maps transport-layer failures to the domain [Failure] taxonomy (FR-008,
/// Constitution IV). Raw exceptions never cross the repository boundary.
Failure mapDioError(Object error, {StackTrace? stackTrace}) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        return _mapResponse(error);
      case DioExceptionType.cancel:
        return const UnknownFailure(message: 'The request was cancelled.');
      case DioExceptionType.badCertificate:
        return const NetworkFailure(message: 'Secure connection failed.');
      case DioExceptionType.transformTimeout:
        return const NetworkFailure();
      case DioExceptionType.unknown:
        return const NetworkFailure();
    }
  }
  return const UnknownFailure();
}

Failure _mapResponse(DioException error) {
  final int? status = error.response?.statusCode;
  if (status == 400) {
    return ValidationFailure(fields: _extractFields(error.response));
  }
  if (status == 401) {
    return const AuthenticationFailure();
  }
  if (status == 403) {
    return const AuthorizationFailure();
  }
  return const ServerFailure();
}

Map<String, String> _extractFields(Response<dynamic>? response) {
  final dynamic data = response?.data;
  if (data is Map<String, dynamic>) {
    final dynamic errors = data['errors'] ?? data['fieldErrors'];
    if (errors is Map<String, dynamic>) {
      return errors.map((key, value) => MapEntry(key, value.toString()));
    }
    final dynamic message = data['message'];
    if (message is String) {
      return <String, String>{'_': message};
    }
  }
  return const <String, String>{};
}
