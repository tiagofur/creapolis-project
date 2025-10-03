/// Excepción del servidor
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException(this.message, [this.statusCode]);

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

/// Excepción de red / conexión
class NetworkException implements Exception {
  final String message;

  NetworkException([this.message = 'Sin conexión a internet']);

  @override
  String toString() => 'NetworkException: $message';
}

/// Excepción de autenticación
class AuthException implements Exception {
  final String message;

  AuthException([this.message = 'Error de autenticación']);

  @override
  String toString() => 'AuthException: $message';
}

/// Excepción de autorización
class AuthorizationException implements Exception {
  final String message;

  AuthorizationException([this.message = 'No autorizado']);

  @override
  String toString() => 'AuthorizationException: $message';
}

/// Excepción de validación
class ValidationException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;

  ValidationException(this.message, [this.errors]);

  @override
  String toString() => 'ValidationException: $message';
}

/// Excepción de cache
class CacheException implements Exception {
  final String message;

  CacheException([this.message = 'Error de cache']);

  @override
  String toString() => 'CacheException: $message';
}

/// Excepción no encontrado
class NotFoundException implements Exception {
  final String message;

  NotFoundException([this.message = 'Recurso no encontrado']);

  @override
  String toString() => 'NotFoundException: $message';
}

/// Excepción de conflicto
class ConflictException implements Exception {
  final String message;

  ConflictException([this.message = 'Conflicto']);

  @override
  String toString() => 'ConflictException: $message';
}

/// Excepción de timeout
class TimeoutException implements Exception {
  final String message;

  TimeoutException([this.message = 'Tiempo de espera agotado']);

  @override
  String toString() => 'TimeoutException: $message';
}
