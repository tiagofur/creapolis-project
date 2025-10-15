import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../utils/app_logger.dart';

/// Interceptor para inyectar token JWT en todas las peticiones
///
/// Funcionalidad:
/// - Lee el token JWT del secure storage
/// - Añade header 'Authorization: Bearer token' a cada petición
/// - Omite header en endpoints públicos (login, register)
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  // Endpoints públicos que NO requieren token
  static const _publicEndpoints = [
    '/auth/login',
    '/auth/register',
    '/auth/refresh-token',
  ];

  AuthInterceptor({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Verificar si es un endpoint público
    final isPublicEndpoint = _publicEndpoints.any(
      (endpoint) => options.path.contains(endpoint),
    );

    if (!isPublicEndpoint) {
      try {
        // Leer token del secure storage
        final token = await _storage.read(key: 'auth_token');

        if (token != null && token.isNotEmpty) {
          // Inyectar token en el header
          options.headers['Authorization'] = 'Bearer $token';

          AppLogger.debug(
            'Auth: Token inyectado para ${options.method} ${options.path}',
          );
        } else {
          AppLogger.warning(
            'Auth: No hay token disponible para ${options.method} ${options.path}',
          );
        }
      } catch (e) {
        AppLogger.error('Auth: Error leyendo token del storage: $e');
      }
    } else {
      AppLogger.debug('Auth: Endpoint público ${options.path}, sin token');
    }

    // Continuar con la petición
    handler.next(options);
  }

  /// Guarda el token JWT en el secure storage
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: 'auth_token', value: token);
      AppLogger.info('Auth: Token guardado exitosamente');
    } catch (e) {
      AppLogger.error('Auth: Error guardando token: $e');
      rethrow;
    }
  }

  /// Elimina el token JWT del secure storage
  Future<void> clearToken() async {
    try {
      await _storage.delete(key: 'auth_token');
      AppLogger.info('Auth: Token eliminado exitosamente');
    } catch (e) {
      AppLogger.error('Auth: Error eliminando token: $e');
      rethrow;
    }
  }

  /// Lee el token JWT del secure storage (útil para debugging)
  Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      return token;
    } catch (e) {
      AppLogger.error('Auth: Error leyendo token: $e');
      return null;
    }
  }
}
