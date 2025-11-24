import 'package:equatable/equatable.dart';

/// Eventos del BLoC de autenticación
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para iniciar sesión
class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Evento para registrar usuario
class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;

  const RegisterEvent({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });

  @override
  List<Object?> get props => [email, password, firstName, lastName];
}

/// Evento para obtener perfil del usuario autenticado
class GetProfileEvent extends AuthEvent {
  const GetProfileEvent();
}

/// Evento para cerrar sesión
class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

/// Evento para verificar si está autenticado (al iniciar la app)
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

/// Evento para actualizar perfil
class UpdateProfileEvent extends AuthEvent {
  final String? name;
  final String? avatarUrl;

  const UpdateProfileEvent({this.name, this.avatarUrl});

  @override
  List<Object?> get props => [name, avatarUrl];
}

/// Evento para cambiar contraseña
class ChangePasswordEvent extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}
