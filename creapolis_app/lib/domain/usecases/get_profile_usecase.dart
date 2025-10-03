import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: Obtener perfil del usuario actual
///
/// Obtiene la información del usuario autenticado.
@injectable
class GetProfileUseCase {
  final AuthRepository repository;

  GetProfileUseCase(this.repository);

  /// Ejecutar el caso de uso
  ///
  /// Requiere que el usuario esté autenticado (JWT válido).
  ///
  /// ```dart
  /// final result = await getProfileUseCase();
  ///
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (user) => print('Profile: ${user.fullName}'),
  /// );
  /// ```
  Future<Either<Failure, User>> call() async {
    return await repository.getProfile();
  }
}
