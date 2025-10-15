import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: Cerrar sesión
///
/// Elimina el JWT y limpia todos los datos de sesión.
@injectable
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  /// Ejecutar el caso de uso
  ///
  /// ```dart
  /// final result = await logoutUseCase();
  ///
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (_) => print('Logged out successfully'),
  /// );
  /// ```
  Future<Either<Failure, void>> call() async {
    return await repository.logout();
  }
}



