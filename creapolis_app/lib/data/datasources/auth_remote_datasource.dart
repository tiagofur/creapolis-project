import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/network/dio_client.dart';
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

      // La respuesta debe contener: {user: {...}, token: "..."}
      return response.data as Map<String, dynamic>;
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

      // La respuesta debe contener: {user: {...}, token: "..."}
      return response.data as Map<String, dynamic>;
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
      final response = await _dioClient.get('/auth/profile');

      return UserModel.fromJson(response.data as Map<String, dynamic>);
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
