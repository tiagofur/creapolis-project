import 'package:flutter/material.dart';

import '../errors/failures.dart';

/// Clase para mapear errores técnicos a mensajes amigables para el usuario
class ErrorMessageMapper {
  /// Convierte un Failure en un mensaje amigable con sugerencias
  static FriendlyErrorMessage map(Failure failure) {
    if (failure is ServerFailure) {
      return _mapServerFailure(failure);
    } else if (failure is NetworkFailure) {
      return _mapNetworkFailure(failure);
    } else if (failure is CacheFailure) {
      return _mapCacheFailure(failure);
    } else if (failure is ValidationFailure) {
      return _mapValidationFailure(failure);
    } else if (failure is AuthFailure) {
      return _mapAuthFailure(failure);
    } else if (failure is AuthorizationFailure) {
      return _mapAuthorizationFailure(failure);
    } else if (failure is NotFoundFailure) {
      return _mapNotFoundFailure(failure);
    } else if (failure is TimeoutFailure) {
      return _mapTimeoutFailure(failure);
    } else if (failure is ConflictFailure) {
      return _mapConflictFailure(failure);
    }

    return FriendlyErrorMessage(
      title: 'Error Inesperado',
      message: 'Ha ocurrido un error. Por favor, intenta de nuevo.',
      icon: Icons.error_outline,
      color: Colors.red,
      suggestion: 'Si el problema persiste, contacta con soporte.',
      severity: ErrorSeverity.error,
      canRetry: true,
    );
  }

  static FriendlyErrorMessage _mapServerFailure(ServerFailure failure) {
    final message = failure.message.toLowerCase();

    if (message.contains('timeout') || message.contains('time out')) {
      return FriendlyErrorMessage(
        title: 'Tiempo de Espera Agotado',
        message: 'El servidor tardó demasiado en responder.',
        icon: Icons.access_time,
        color: Colors.orange,
        suggestion:
            'Verifica tu conexión a internet e intenta nuevamente en unos momentos.',
        severity: ErrorSeverity.warning,
        canRetry: true,
      );
    }

    if (message.contains('500') || message.contains('internal server')) {
      return FriendlyErrorMessage(
        title: 'Error del Servidor',
        message: 'Estamos experimentando problemas técnicos.',
        icon: Icons.cloud_off,
        color: Colors.red,
        suggestion:
            'Nuestro equipo ya está trabajando en ello. Intenta de nuevo en unos minutos.',
        severity: ErrorSeverity.error,
        canRetry: true,
      );
    }

    if (message.contains('503') || message.contains('unavailable')) {
      return FriendlyErrorMessage(
        title: 'Servicio No Disponible',
        message: 'El servicio está temporalmente fuera de línea.',
        icon: Icons.cloud_off,
        color: Colors.orange,
        suggestion: 'Estamos realizando mantenimiento. Intenta más tarde.',
        severity: ErrorSeverity.warning,
        canRetry: true,
      );
    }

    return FriendlyErrorMessage(
      title: 'Error del Servidor',
      message: 'No pudimos completar tu solicitud.',
      icon: Icons.cloud_off,
      color: Colors.red,
      suggestion: 'Intenta nuevamente en unos momentos.',
      severity: ErrorSeverity.error,
      canRetry: true,
    );
  }

  static FriendlyErrorMessage _mapNetworkFailure(NetworkFailure failure) {
    return FriendlyErrorMessage(
      title: 'Sin Conexión',
      message: 'No se pudo conectar a internet.',
      icon: Icons.wifi_off,
      color: Colors.orange,
      suggestion:
          'Verifica tu conexión Wi-Fi o datos móviles e intenta nuevamente.',
      severity: ErrorSeverity.warning,
      canRetry: true,
      actionLabel: 'Verificar Conexión',
    );
  }

  static FriendlyErrorMessage _mapCacheFailure(CacheFailure failure) {
    return FriendlyErrorMessage(
      title: 'Error de Almacenamiento',
      message: 'No se pudo guardar la información localmente.',
      icon: Icons.storage,
      color: Colors.orange,
      suggestion: 'Verifica que tengas espacio disponible en tu dispositivo.',
      severity: ErrorSeverity.warning,
      canRetry: false,
    );
  }

  static FriendlyErrorMessage _mapValidationFailure(ValidationFailure failure) {
    return FriendlyErrorMessage(
      title: 'Datos Inválidos',
      message: failure.message,
      icon: Icons.warning_amber,
      color: Colors.amber,
      suggestion: 'Verifica que todos los campos estén correctamente llenados.',
      severity: ErrorSeverity.info,
      canRetry: false,
    );
  }

  static FriendlyErrorMessage _mapAuthFailure(AuthFailure failure) {
    final message = failure.message.toLowerCase();

    if (message.contains('credentials') || message.contains('password')) {
      return FriendlyErrorMessage(
        title: 'Credenciales Incorrectas',
        message: 'El correo o contraseña no son correctos.',
        icon: Icons.lock_outline,
        color: Colors.red,
        suggestion: 'Verifica tus datos e intenta de nuevo.',
        severity: ErrorSeverity.error,
        canRetry: false,
        actionLabel: '¿Olvidaste tu contraseña?',
      );
    }

    if (message.contains('token') || message.contains('expired')) {
      return FriendlyErrorMessage(
        title: 'Sesión Expirada',
        message: 'Tu sesión ha caducado.',
        icon: Icons.schedule,
        color: Colors.orange,
        suggestion: 'Por favor, inicia sesión nuevamente.',
        severity: ErrorSeverity.warning,
        canRetry: false,
        actionLabel: 'Iniciar Sesión',
      );
    }

    return FriendlyErrorMessage(
      title: 'Error de Autenticación',
      message: 'No se pudo verificar tu identidad.',
      icon: Icons.lock_outline,
      color: Colors.red,
      suggestion: 'Verifica tus credenciales e intenta nuevamente.',
      severity: ErrorSeverity.error,
      canRetry: false,
    );
  }

  static FriendlyErrorMessage _mapAuthorizationFailure(
    AuthorizationFailure failure,
  ) {
    return FriendlyErrorMessage(
      title: 'Permiso Denegado',
      message: 'No tienes permiso para realizar esta acción.',
      icon: Icons.block,
      color: Colors.red,
      suggestion:
          'Contacta con el administrador del workspace si necesitas acceso.',
      severity: ErrorSeverity.error,
      canRetry: false,
    );
  }

  static FriendlyErrorMessage _mapTimeoutFailure(TimeoutFailure failure) {
    return FriendlyErrorMessage(
      title: 'Tiempo de Espera Agotado',
      message: 'La operación tardó demasiado tiempo.',
      icon: Icons.access_time,
      color: Colors.orange,
      suggestion:
          'Verifica tu conexión a internet e intenta nuevamente en unos momentos.',
      severity: ErrorSeverity.warning,
      canRetry: true,
    );
  }

  static FriendlyErrorMessage _mapConflictFailure(ConflictFailure failure) {
    return FriendlyErrorMessage(
      title: 'Conflicto Detectado',
      message: 'Los datos han sido modificados por otro usuario.',
      icon: Icons.sync_problem,
      color: Colors.amber,
      suggestion: 'Recarga los datos e intenta de nuevo.',
      severity: ErrorSeverity.warning,
      canRetry: true,
      actionLabel: 'Recargar',
    );
  }

  static FriendlyErrorMessage _mapNotFoundFailure(NotFoundFailure failure) {
    return FriendlyErrorMessage(
      title: 'No Encontrado',
      message: 'El recurso solicitado no existe o fue eliminado.',
      icon: Icons.search_off,
      color: Colors.grey,
      suggestion: 'Verifica que la información sea correcta.',
      severity: ErrorSeverity.info,
      canRetry: false,
    );
  }
}

/// Mensaje de error amigable con toda la información necesaria
class FriendlyErrorMessage {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final String suggestion;
  final ErrorSeverity severity;
  final bool canRetry;
  final String? actionLabel;

  const FriendlyErrorMessage({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.suggestion,
    required this.severity,
    required this.canRetry,
    this.actionLabel,
  });
}

/// Niveles de severidad de error
enum ErrorSeverity { info, warning, error, critical }
