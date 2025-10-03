import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: Registrar nuevo usuario
///
/// Maneja la lógica de negocio para el registro de usuarios.
@injectable
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  /// Ejecutar el caso de uso
  ///
  /// ```dart
  /// final result = await registerUseCase(RegisterParams(
  ///   email: 'user@example.com',
  ///   password: 'password123',
  ///   firstName: 'John',
  ///   lastName: 'Doe',
  /// ));
  ///
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (user) => print('Registered: ${user.fullName}'),
  /// );
  /// ```
  Future<Either<Failure, User>> call(RegisterParams params) async {
    // Validaciones de negocio
    if (params.password.length < 6) {
      return Left(
        ValidationFailure('La contraseña debe tener al menos 6 caracteres'),
      );
    }

    if (!_isValidEmail(params.email)) {
      return Left(ValidationFailure('Email inválido'));
    }

    if (params.firstName.trim().isEmpty || params.lastName.trim().isEmpty) {
      return Left(ValidationFailure('Nombre y apellido son requeridos'));
    }

    return await repository.register(
      email: params.email,
      password: params.password,
      firstName: params.firstName,
      lastName: params.lastName,
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}

/// Parámetros para el caso de uso Register
class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String firstName;
  final String lastName;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });

  @override
  List<Object?> get props => [email, password, firstName, lastName];
}
