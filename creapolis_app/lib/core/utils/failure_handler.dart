import 'package:dio/dio.dart';
import '../errors/exceptions.dart';
import '../errors/failures.dart';

/// Clase helper para convertir DioExceptions en Exceptions
class ExceptionHandler {
  static Exception handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(error.message ?? 'Tiempo de espera agotado');

      case DioExceptionType.badResponse:
        return _handleStatusCodeException(error.response?.statusCode, error);

      case DioExceptionType.cancel:
        return Exception('Petición cancelada');

      case DioExceptionType.connectionError:
        return NetworkException('Sin conexión a internet');

      case DioExceptionType.badCertificate:
        return ServerException('Certificado de seguridad inválido');

      case DioExceptionType.unknown:
        return NetworkException(error.message ?? 'Error de conexión');
    }
  }

  static Exception _handleStatusCodeException(
    int? statusCode,
    DioException error,
  ) {
    final message = _extractErrorMessage(error.response?.data);

    switch (statusCode) {
      case 400:
        return ValidationException(message ?? 'Petición inválida');
      case 401:
        return AuthException(message ?? 'No autorizado');
      case 403:
        return AuthorizationException(message ?? 'Acceso prohibido');
      case 404:
        return NotFoundException(message ?? 'Recurso no encontrado');
      case 409:
        return ConflictException(message ?? 'Conflicto');
      case 422:
        final errors = error.response?.data?['errors'] as Map<String, dynamic>?;
        return ValidationException(
          message ?? 'Datos de entrada inválidos',
          errors,
        );
      case 500:
      case 502:
      case 503:
        return ServerException(message ?? 'Error del servidor', statusCode);
      default:
        return ServerException(message ?? 'Error desconocido', statusCode);
    }
  }

  static String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ??
          data['error'] as String? ??
          data['msg'] as String?;
    }
    return null;
  }
}

/// Clase helper para convertir Exceptions en Failures
class FailureHandler {
  static Failure handleException(Exception exception) {
    if (exception is ServerException) {
      return ServerFailure(exception.message);
    } else if (exception is NetworkException) {
      return NetworkFailure(exception.message);
    } else if (exception is AuthException) {
      return AuthFailure(exception.message);
    } else if (exception is AuthorizationException) {
      return AuthorizationFailure(exception.message);
    } else if (exception is ValidationException) {
      return ValidationFailure(exception.message, exception.errors);
    } else if (exception is NotFoundException) {
      return NotFoundFailure(exception.message);
    } else if (exception is ConflictException) {
      return ConflictFailure(exception.message);
    } else if (exception is CacheException) {
      return CacheFailure(exception.message);
    } else if (exception is TimeoutException) {
      return TimeoutFailure(exception.message);
    }
    return UnknownFailure(exception.toString());
  }
}
