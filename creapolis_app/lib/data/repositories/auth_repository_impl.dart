import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

/// Implementación del repositorio de autenticación
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _sharedPreferences;

  AuthRepositoryImpl(
    this._remoteDataSource,
    this._secureStorage,
    this._sharedPreferences,
  );

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Llamar al data source
      final response = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      // Validar estructura de respuesta
      if (response['token'] == null) {
        return Left(
          ServerFailure('Token no recibido del servidor. Respuesta: $response'),
        );
      }
      if (response['user'] == null) {
        return Left(
          ServerFailure(
            'Datos de usuario no recibidos del servidor. Respuesta: $response',
          ),
        );
      }

      // Extraer datos de la respuesta
      final token = response['token'] as String;
      final userJson = response['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userJson);

      // Guardar token en almacenamiento seguro
      await _secureStorage.write(key: StorageKeys.accessToken, value: token);

      // Guardar datos del usuario en SharedPreferences
      await _saveUserData(user);

      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Error inesperado al iniciar sesión: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      // El backend espera 'name' como un solo campo
      final fullName = '$firstName $lastName'.trim();

      // Llamar al data source
      final response = await _remoteDataSource.register(
        email: email,
        password: password,
        name: fullName,
      );

      // Extraer datos de la respuesta
      final token = response['token'] as String;
      final userJson = response['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userJson);

      // Guardar token en almacenamiento seguro
      await _secureStorage.write(key: StorageKeys.accessToken, value: token);

      // Guardar datos del usuario en SharedPreferences
      await _saveUserData(user);

      return Right(user);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ConflictException catch (e) {
      return Left(ConflictFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Error inesperado al registrar: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> getProfile() async {
    try {
      // Llamar al data source (ya tiene el token en los headers por el interceptor)
      final user = await _remoteDataSource.getProfile();

      // Actualizar datos en cache
      await _saveUserData(user);

      return Right(user);
    } on AuthException catch (e) {
      // Token inválido o expirado, limpiar sesión
      await logout();
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      // Si hay datos en cache, intentar retornarlos
      final cachedUser = await _getCachedUser();
      if (cachedUser != null) {
        return Right(cachedUser);
      }
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Error inesperado al obtener perfil: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Intentar hacer logout en el servidor
      try {
        await _remoteDataSource.logout();
      } catch (_) {
        // Ignorar errores del servidor en logout
        // Lo importante es limpiar datos locales
      }

      // Limpiar almacenamiento seguro
      await _secureStorage.delete(key: StorageKeys.accessToken);
      await _secureStorage.delete(key: StorageKeys.refreshToken);

      // Limpiar SharedPreferences
      await _sharedPreferences.remove(StorageKeys.userId);
      await _sharedPreferences.remove(StorageKeys.userEmail);
      await _sharedPreferences.remove(StorageKeys.userName);
      await _sharedPreferences.remove(StorageKeys.userRole);

      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Error al cerrar sesión: $e'));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      // Verificar si existe un token
      final token = await _secureStorage.read(key: StorageKeys.accessToken);
      return token != null && token.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Guardar datos del usuario en SharedPreferences
  Future<void> _saveUserData(User user) async {
    await _sharedPreferences.setInt(StorageKeys.userId, user.id);
    await _sharedPreferences.setString(StorageKeys.userEmail, user.email);
    await _sharedPreferences.setString(StorageKeys.userName, user.name);
    await _sharedPreferences.setString(
      StorageKeys.userRole,
      _roleToString(user.role),
    );
  }

  /// Obtener usuario desde cache
  Future<User?> _getCachedUser() async {
    try {
      final id = _sharedPreferences.getInt(StorageKeys.userId);
      final email = _sharedPreferences.getString(StorageKeys.userEmail);
      final name = _sharedPreferences.getString(StorageKeys.userName);
      final roleString = _sharedPreferences.getString(StorageKeys.userRole);

      if (id == null || email == null || name == null || roleString == null) {
        return null;
      }

      return User(
        id: id,
        email: email,
        name: name,
        role: _roleFromString(roleString),
      );
    } catch (_) {
      return null;
    }
  }

  /// Convertir UserRole a string para almacenamiento
  String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'admin';
      case UserRole.projectManager:
        return 'project_manager';
      case UserRole.teamMember:
        return 'team_member';
    }
  }

  /// Convertir string a UserRole desde almacenamiento
  UserRole _roleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'project_manager':
        return UserRole.projectManager;
      case 'team_member':
        return UserRole.teamMember;
      default:
        return UserRole.teamMember;
    }
  }
}



