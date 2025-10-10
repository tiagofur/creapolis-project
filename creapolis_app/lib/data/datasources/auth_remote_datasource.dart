import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/app_logger.dart';
import '../models/user_model.dart';

/// Interface para el data source remoto de autenticación
abstract class AuthRemoteDataSource {
  /// Login de usuario
  ///
  /// Retorna el UserModel con el JWT token
  /// Lanza [ServerException] si hay error en el servidor
  /// Lanza [AuthException] si las credenciales son inválidas
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });

  /// Registro de usuario
  ///
  /// Retorna el UserModel con el JWT token
  /// Lanza [ServerException] si hay error en el servidor
  /// Lanza [ValidationException] si los datos son inválidos
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  });

  /// Obtener perfil del usuario autenticado
  ///
  /// Retorna el UserModel del usuario actual
  /// Lanza [AuthException] si no hay token válido
  /// Lanza [ServerException] si hay error en el servidor
  Future<UserModel> getProfile();

  /// Logout de usuario
  ///
  /// Lanza [ServerException] si hay error en el servidor
  Future<void> logout();
}

/// Implementación del data source remoto de autenticación
@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      // Validar que la respuesta sea exitosa
      if (response.statusCode != 200) {
        throw ServerException(
          'Error al iniciar sesión: código ${response.statusCode}',
        );
      }

      // Validar que la respuesta tenga datos
      if (response.data == null) {
        throw ServerException('Respuesta vacía del servidor');
      }

      // La respuesta del backend tiene estructura: {success, message, data: {user, token}}
      final responseData = response.data as Map<String, dynamic>;

      AppLogger.debug(
        '🔍 LOGIN - responseData type: ${responseData.runtimeType}',
      );
      AppLogger.debug(
        '🔍 LOGIN - responseData.keys: ${responseData.keys.toList()}',
      );
      AppLogger.debug(
        '🔍 LOGIN - responseData.containsKey("data"): ${responseData.containsKey("data")}',
      );
      AppLogger.debug(
        '🔍 LOGIN - responseData["data"] type: ${responseData["data"]?.runtimeType}',
      );

      // Extraer el objeto 'data' que contiene user y token
      final dataRaw = responseData['data'];
      AppLogger.debug('🔍 LOGIN - dataRaw: $dataRaw');
      AppLogger.debug('🔍 LOGIN - dataRaw is Map: ${dataRaw is Map}');
      AppLogger.debug(
        '🔍 LOGIN - dataRaw is Map<String, dynamic>: ${dataRaw is Map<String, dynamic>}',
      );

      final data = dataRaw as Map<String, dynamic>?;

      AppLogger.debug('🔍 LOGIN - data is null: ${data == null}');
      if (data != null) {
        AppLogger.debug('🔍 LOGIN - data.keys: ${data.keys.toList()}');
        AppLogger.debug(
          '🔍 LOGIN - data["token"] type: ${data["token"]?.runtimeType}',
        );
        AppLogger.debug(
          '🔍 LOGIN - data["user"] type: ${data["user"]?.runtimeType}',
        );
        AppLogger.debug(
          '🔍 LOGIN - data.containsKey("token"): ${data.containsKey("token")}',
        );
        AppLogger.debug(
          '🔍 LOGIN - data.containsKey("user"): ${data.containsKey("user")}',
        );
      }

      if (data == null) {
        throw ServerException(
          'Datos no encontrados en respuesta. Respuesta recibida: $responseData',
        );
      }

      // Validar estructura de respuesta
      if (!data.containsKey('token') || !data.containsKey('user')) {
        throw ServerException(
          'Formato de respuesta inválido. Keys encontradas: ${data.keys.toList()}. Data completa: $data',
        );
      }

      AppLogger.debug('✅ LOGIN - Retornando data con token y user');
      return data;
    } on DioException catch (e) {
      // Manejar errores de Dio (401, 409, etc.)
      if (e.response?.statusCode == 401) {
        throw AuthException(e.error?.toString() ?? 'Credenciales inválidas');
      } else if (e.response?.statusCode == 409) {
        throw ConflictException(
          e.error?.toString() ?? 'Conflicto con el estado actual',
        );
      } else if (e.response?.statusCode == 422) {
        throw ValidationException(
          e.error?.toString() ?? 'Datos de entrada inválidos',
        );
      } else {
        throw ServerException(
          e.error?.toString() ?? 'Error del servidor: ${e.message}',
        );
      }
    } on AuthException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al iniciar sesión: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _dioClient.post(
        '/auth/register',
        data: {'email': email, 'password': password, 'name': name},
      );

      // Validar que la respuesta sea exitosa
      if (response.statusCode != 201) {
        throw ServerException(
          'Error al registrar: código ${response.statusCode}',
        );
      }

      // Validar que la respuesta tenga datos
      if (response.data == null) {
        throw ServerException('Respuesta vacía del servidor');
      }

      // La respuesta del backend tiene estructura: {success, message, data: {user, token}}
      final responseData = response.data as Map<String, dynamic>;

      // Extraer el objeto 'data' que contiene user y token
      final data = responseData['data'] as Map<String, dynamic>?;

      if (data == null) {
        throw ServerException(
          'Datos no encontrados en respuesta. Respuesta recibida: $responseData',
        );
      }

      // Validar estructura de respuesta
      if (!data.containsKey('token') || !data.containsKey('user')) {
        throw ServerException(
          'Formato de respuesta inválido. Data recibida: $data',
        );
      }

      return data;
    } on DioException catch (e) {
      // Manejar errores de Dio
      if (e.response?.statusCode == 409) {
        throw ConflictException(e.error?.toString() ?? 'El usuario ya existe');
      } else if (e.response?.statusCode == 422) {
        throw ValidationException(
          e.error?.toString() ?? 'Datos de entrada inválidos',
        );
      } else {
        throw ServerException(
          e.error?.toString() ?? 'Error del servidor: ${e.message}',
        );
      }
    } on ValidationException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al registrar usuario: $e');
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await _dioClient.get('/auth/me');

      // La respuesta del backend tiene estructura: {success, message, data: {user data}}
      final responseData = response.data as Map<String, dynamic>;

      // Extraer el objeto 'data' que contiene los datos del usuario
      final data = responseData['data'] as Map<String, dynamic>?;

      if (data == null) {
        throw ServerException('Datos de usuario no encontrados en respuesta');
      }

      return UserModel.fromJson(data);
    } on AuthException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al obtener perfil: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dioClient.post('/auth/logout');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al cerrar sesión: $e');
    }
  }
}
