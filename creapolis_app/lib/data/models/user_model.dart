import '../../domain/entities/user.dart';

/// Modelo de datos para User
///
/// Extiende la entidad User y agrega funcionalidades de serialización.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.role,
    super.googleAccessToken,
    super.googleRefreshToken,
  });

  /// Crear UserModel desde JSON
  ///
  /// Usado para deserializar respuestas de la API.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Validar campos requeridos
    if (json['id'] == null) {
      throw Exception('User ID is required but was null');
    }
    if (json['email'] == null) {
      throw Exception('User email is required but was null');
    }
    if (json['name'] == null) {
      throw Exception('User name is required but was null');
    }
    if (json['role'] == null) {
      throw Exception('User role is required but was null');
    }

    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      role: _roleFromString(json['role'] as String),
      googleAccessToken: json['googleAccessToken'] as String?,
      googleRefreshToken: json['googleRefreshToken'] as String?,
    );
  }

  /// Convertir UserModel a JSON
  ///
  /// Usado para serializar datos para enviar a la API.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': _roleToString(role),
      if (googleAccessToken != null) 'googleAccessToken': googleAccessToken,
      if (googleRefreshToken != null) 'googleRefreshToken': googleRefreshToken,
    };
  }

  /// Crear UserModel desde una entidad User
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      googleAccessToken: user.googleAccessToken,
      googleRefreshToken: user.googleRefreshToken,
    );
  }

  /// Convertir string a UserRole
  static UserRole _roleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'project_manager':
      case 'projectmanager':
        return UserRole.projectManager;
      case 'team_member':
      case 'teammember':
      case 'member':
        return UserRole.teamMember;
      default:
        return UserRole.teamMember; // Default role
    }
  }

  /// Convertir UserRole a string
  static String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'admin';
      case UserRole.projectManager:
        return 'project_manager';
      case UserRole.teamMember:
        return 'team_member';
    }
  }

  /// Copiar con nuevos valores
  UserModel copyWith({
    int? id,
    String? email,
    String? name,
    UserRole? role,
    String? googleAccessToken,
    String? googleRefreshToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      googleAccessToken: googleAccessToken ?? this.googleAccessToken,
      googleRefreshToken: googleRefreshToken ?? this.googleRefreshToken,
    );
  }
}



