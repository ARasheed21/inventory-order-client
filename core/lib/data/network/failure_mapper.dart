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
  if (status == 409) {
    final Map<String, String> fields = _extractFields(error.response);
    if (fields.isEmpty) {
      return const ValidationFailure(
        fields: <String, String>{
          'username': 'Username or email already registered.',
          'email': 'Username or email already registered.',
        },
      );
    }
    return ValidationFailure(fields: fields);
  }
  if (status == 429) {
    return RateLimitedFailure(retryAfter: _parseRetryAfter(error.response));
  }
  if (status != null && status >= 500) {
    return const ServerFailure();
  }
  if (status != null && status >= 400) {
    return ValidationFailure(fields: _extractFields(error.response));
  }
  return const ServerFailure();
}

Duration? _parseRetryAfter(Response<dynamic>? response) {
  final Map<String, List<String>> headers = response?.headers.map ?? const {};
  String? raw;
  for (final entry in headers.entries) {
    if (entry.key.toLowerCase() == 'retry-after' && entry.value.isNotEmpty) {
      raw = entry.value.first;
      break;
    }
  }
  if (raw == null) return const Duration(seconds: 60);
  final String value = raw.trim();
  final int? seconds = int.tryParse(value);
  if (seconds != null) return Duration(seconds: seconds);
  try {
    final DateTime date = DateTime.parse(value).toUtc();
    final Duration diff = date.difference(DateTime.now().toUtc());
    return diff.isNegative ? const Duration(seconds: 60) : diff;
  } catch (_) {
    return const Duration(seconds: 60);
  }
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
