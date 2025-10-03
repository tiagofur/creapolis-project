import 'package:equatable/equatable.dart';

/// Entidad de dominio para respuesta de autenticación
class AuthResponse extends Equatable {
  final String accessToken;
  final String? refreshToken;
  final int userId;
  final String email;
  final String name;
  final String role;

  const AuthResponse({
    required this.accessToken,
    this.refreshToken,
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
  });

  @override
  List<Object?> get props => [
    accessToken,
    refreshToken,
    userId,
    email,
    name,
    role,
  ];
}
