import 'package:equatable/equatable.dart';

/// Roles de usuario en el sistema
enum UserRole {
  admin,
  projectManager,
  teamMember;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.projectManager:
        return 'Gestor de Proyecto';
      case UserRole.teamMember:
        return 'Miembro del Equipo';
    }
  }
}

/// Entidad de dominio para Usuario
class User extends Equatable {
  final int id;
  final String email;
  final String name;
  final UserRole role;
  final String? googleAccessToken;
  final String? googleRefreshToken;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.googleAccessToken,
    this.googleRefreshToken,
  });

  /// Verifica si el usuario es administrador
  bool get isAdmin => role == UserRole.admin;

  /// Verifica si el usuario es gestor de proyecto
  bool get isProjectManager => role == UserRole.projectManager;

  /// Verifica si el usuario tiene Google Calendar conectado
  bool get hasGoogleCalendar => googleAccessToken != null;

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    role,
    googleAccessToken,
    googleRefreshToken,
  ];
}
