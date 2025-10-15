import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: Iniciar sesión
///
/// Maneja la lógica de negocio para el inicio de sesión.
@injectable
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  /// Ejecutar el caso de uso
  ///
  /// ```dart
  /// final result = await loginUseCase(LoginParams(
  ///   email: 'user@example.com',
  ///   password: 'password123',
  /// ));
  ///
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (user) => print('Logged in: ${user.fullName}'),
  /// );
  /// ```
  Future<Either<Failure, User>> call(LoginParams params) async {
    return await repository.login(
      email: params.email,
      password: params.password,
    );
  }
}

/// Parámetros para el caso de uso Login
class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}



