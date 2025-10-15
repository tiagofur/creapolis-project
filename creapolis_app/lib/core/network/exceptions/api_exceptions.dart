/// Excepciones custom para manejo de errores de API
///
/// Jerarquía:
/// - ApiException (base)
///   - NetworkException (errores de conexión)
///   - BadRequestException (400)
///   - UnauthorizedException (401)
///   - ForbiddenException (403)
///   - NotFoundException (404)
///   - ConflictException (409)
///   - ValidationException (422)
///   - ServerException (500-599)
library;

/// Excepción base para errores de API
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  ApiException(this.message, {required this.statusCode, this.errors});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Error de conexión (sin internet, timeout, etc.)
class NetworkException extends ApiException {
  NetworkException(super.message, {required super.statusCode});

  @override
  String toString() => 'NetworkException: $message';
}

/// Error 400: Solicitud mal formada
class BadRequestException extends ApiException {
  BadRequestException(super.message, {required super.statusCode, super.errors});

  @override
  String toString() => 'BadRequestException(400): $message';
}

/// Error 401: No autorizado (token inválido/expirado)
class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message, {required super.statusCode});

  @override
  String toString() => 'UnauthorizedException(401): $message';
}

/// Error 403: Prohibido (sin permisos)
class ForbiddenException extends ApiException {
  ForbiddenException(super.message, {required super.statusCode});

  @override
  String toString() => 'ForbiddenException(403): $message';
}

/// Error 404: Recurso no encontrado
class NotFoundException extends ApiException {
  NotFoundException(super.message, {required super.statusCode});

  @override
  String toString() => 'NotFoundException(404): $message';
}

/// Error 409: Conflicto (recurso ya existe)
class ConflictException extends ApiException {
  ConflictException(super.message, {required super.statusCode});

  @override
  String toString() => 'ConflictException(409): $message';
}

/// Error 422: Validación fallida
class ValidationException extends ApiException {
  ValidationException(super.message, {required super.statusCode, super.errors});

  /// Obtiene mensaje de error para un campo específico
  String? getFieldError(String field) {
    if (errors == null) return null;
    return errors![field] as String?;
  }

  @override
  String toString() {
    final errorDetails = errors != null ? ' - Errors: $errors' : '';
    return 'ValidationException(422): $message$errorDetails';
  }
}

/// Error 500-599: Error del servidor
class ServerException extends ApiException {
  ServerException(super.message, {required super.statusCode});

  @override
  String toString() => 'ServerException($statusCode): $message';
}



