import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';

/// Interfaz del repositorio de autenticación
///
/// Define los contratos que debe cumplir la implementación concreta.
/// Usa `Either<Failure, T>` para manejar errores de forma funcional.
abstract class AuthRepository {
  /// Iniciar sesión con email y contraseña
  ///
  /// Retorna [Right(User)] si es exitoso
  /// Retorna [Left(Failure)] si hay error
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Registrar un nuevo usuario
  ///
  /// Retorna [Right(User)] si es exitoso
  /// Retorna [Left(Failure)] si hay error
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  /// Obtener perfil del usuario actual
  ///
  /// Requiere JWT válido almacenado
  /// Retorna [Right(User)] si es exitoso
  /// Retorna [Left(Failure)] si hay error o no está autenticado
  Future<Either<Failure, User>> getProfile();

  /// Cerrar sesión
  ///
  /// Elimina el JWT y limpia datos de sesión
  /// Retorna [Right(void)] si es exitoso
  /// Retorna [Left(Failure)] si hay error
  Future<Either<Failure, void>> logout();

  /// Verificar si el usuario está autenticado
  ///
  /// Verifica si existe un JWT válido almacenado
  Future<bool> isAuthenticated();
}
