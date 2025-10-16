import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../constants/storage_keys.dart';
import '../../services/last_route_service.dart';
import '../../utils/app_logger.dart';
import '../exceptions/api_exceptions.dart';

/// Interceptor para manejo centralizado de errores HTTP
///
/// Mapea códigos de error HTTP a excepciones custom:
/// - 400 → BadRequestException
/// - 401 → UnauthorizedException (auto-logout y limpieza)
/// - 403 → ForbiddenException
/// - 404 → NotFoundException
/// - 500-599 → ServerException
/// - Network errors → NetworkException
class ErrorInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final LastRouteService _lastRouteService;

  ErrorInterceptor({
    FlutterSecureStorage? storage,
    LastRouteService? lastRouteService,
  }) : _storage = storage ?? const FlutterSecureStorage(),
       _lastRouteService =
           lastRouteService ?? LastRouteService(const FlutterSecureStorage());

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error(
      'HTTP Error: ${err.requestOptions.method} ${err.requestOptions.path}',
    );
    AppLogger.error('Status Code: ${err.response?.statusCode}');
    AppLogger.error('Error Type: ${err.type}');
    AppLogger.error('Message: ${err.message}');

    // Si es error 401, limpiar tokens y rutas automáticamente
    if (err.response?.statusCode == 401) {
      AppLogger.warning(
        '⚠️ Error 401: Token inválido o usuario no encontrado. Limpiando sesión...',
      );
      _clearAuthenticationData();
    }

    // Mapear DioException a nuestras excepciones custom
    final exception = _mapDioExceptionToApiException(err);

    // Loguear la excepción mapeada
    AppLogger.error(
      'Mapped to: ${exception.runtimeType} - ${exception.message}',
    );

    // Rechazar con la excepción mapeada
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        response: err.response,
        type: err.type,
      ),
    );
  }

  /// Mapea DioException a excepciones custom según código de error
  ApiException _mapDioExceptionToApiException(DioException error) {
    switch (error.type) {
      // Errores de conexión
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Error de conexión: Timeout', statusCode: 0);

      case DioExceptionType.connectionError:
        return NetworkException(
          'Sin conexión a internet. Verifica tu conexión.',
          statusCode: 0,
        );

      // Errores de cancelación
      case DioExceptionType.cancel:
        return ApiException('Petición cancelada', statusCode: 0);

      // Errores HTTP
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        final responseData = error.response?.data;

        // Extraer mensaje del backend si existe
        final message = _extractMessage(responseData);

        switch (statusCode) {
          case 400:
            return BadRequestException(
              message ?? 'Solicitud inválida',
              statusCode: statusCode,
              errors: _extractErrors(responseData),
            );

          case 401:
            return UnauthorizedException(
              message ?? 'No autorizado. Inicia sesión nuevamente.',
              statusCode: statusCode,
            );

          case 403:
            return ForbiddenException(
              message ?? 'No tienes permisos para realizar esta acción.',
              statusCode: statusCode,
            );

          case 404:
            return NotFoundException(
              message ?? 'Recurso no encontrado',
              statusCode: statusCode,
            );

          case 409:
            return ConflictException(
              message ?? 'Conflicto: El recurso ya existe',
              statusCode: statusCode,
            );

          case 422:
            return ValidationException(
              message ?? 'Datos inválidos',
              statusCode: statusCode,
              errors: _extractErrors(responseData),
            );

          case 429:
            return ApiException(
              'Demasiadas solicitudes. Intenta más tarde.',
              statusCode: statusCode,
            );

          case >= 500:
            return ServerException(
              message ?? 'Error del servidor. Intenta más tarde.',
              statusCode: statusCode,
            );

          default:
            return ApiException(
              message ?? 'Error desconocido (código $statusCode)',
              statusCode: statusCode,
            );
        }

      // Otros errores
      case DioExceptionType.badCertificate:
        return ApiException('Error de certificado SSL', statusCode: 0);

      case DioExceptionType.unknown:
        return ApiException(
          error.message ?? 'Error desconocido',
          statusCode: 0,
        );
    }
  }

  /// Extrae errores de validación del response data
  Map<String, dynamic>? _extractErrors(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final errors = responseData['errors'];
      if (errors is Map<String, dynamic>) {
        return errors;
      }
    }
    return null;
  }

  /// Intenta convertir los campos comunes de mensaje en un string legible
  String? _extractMessage(dynamic responseData) {
    if (responseData == null) return null;

    String? asString(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is List) {
        return value
            .map((element) => asString(element) ?? element.toString())
            .join(', ');
      }
      if (value is Map<String, dynamic>) {
        // Buscar campos comunes dentro del objeto
        final nested =
            asString(value['message']) ??
            asString(value['error']) ??
            asString(value['detail']) ??
            asString(value['description']);
        return nested ?? value.toString();
      }
      return value.toString();
    }

    if (responseData is Map<String, dynamic>) {
      return asString(responseData['message']) ??
          asString(responseData['error']) ??
          asString(responseData['detail']) ??
          asString(responseData['description']);
    }

    return asString(responseData);
  }

  /// Limpia los datos de autenticación cuando hay un error 401
  /// Esto evita que la app intente restaurar rutas con un token inválido
  Future<void> _clearAuthenticationData() async {
    try {
      // Limpiar tokens
      await _storage.delete(key: StorageKeys.accessToken);
      await _storage.delete(key: StorageKeys.refreshToken);
      AppLogger.info('🔐 Tokens de autenticación eliminados');

      // Limpiar rutas guardadas
      await _lastRouteService.clearAll();
      AppLogger.info('🧹 Rutas guardadas limpiadas');
    } catch (e) {
      AppLogger.error('❌ Error al limpiar datos de autenticación: $e');
    }
  }
}
