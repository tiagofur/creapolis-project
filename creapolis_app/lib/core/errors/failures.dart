import 'package:equatable/equatable.dart';

/// Clase base abstracta para todos los fallos
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  List<Object?> get props => [message, code];
}

/// Fallo de servidor (5xx)
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error del servidor']);
}

/// Fallo de red/conexión
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sin conexión a internet']);
}

/// Fallo de autenticación (401)
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Error de autenticación']);
}

/// Fallo de autorización (403)
class AuthorizationFailure extends Failure {
  const AuthorizationFailure([
    super.message = 'No tienes permisos para realizar esta acción',
  ]);
}

/// Recurso no encontrado (404)
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Recurso no encontrado']);
}

/// Fallo de validación (400, 422)
class ValidationFailure extends Failure {
  final Map<String, dynamic>? errors;

  const ValidationFailure([super.message = 'Datos inválidos', this.errors]);

  @override
  List<Object?> get props => [message, code, errors];
}

/// Fallo de conflicto (409)
class ConflictFailure extends Failure {
  const ConflictFailure([super.message = 'Conflicto con el estado actual']);
}

/// Fallo de caché/almacenamiento local
class CacheFailure extends Failure {
  const CacheFailure([
    super.message = 'Error al acceder al almacenamiento local',
  ]);
}

/// Fallo genérico desconocido
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Ha ocurrido un error inesperado']);
}

/// Tiempo de espera agotado
class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Tiempo de espera agotado']);
}

/// Operación cancelada
class CancelFailure extends Failure {
  const CancelFailure([super.message = 'Operación cancelada']);
}
