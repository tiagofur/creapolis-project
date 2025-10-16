import 'package:equatable/equatable.dart';

/// Roles disponibles para miembros de proyecto
enum ProjectMemberRole {
  owner,
  admin,
  member,
  viewer;

  /// Convierte string del backend a enum
  static ProjectMemberRole fromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'owner':
        return ProjectMemberRole.owner;
      case 'admin':
        return ProjectMemberRole.admin;
      case 'viewer':
        return ProjectMemberRole.viewer;
      case 'member':
      default:
        return ProjectMemberRole.member;
    }
  }

  /// Convierte enum a string para el backend
  String toBackendString() {
    return name.toUpperCase();
  }

  /// Obtiene el nombre display para UI
  String get displayName {
    switch (this) {
      case ProjectMemberRole.owner:
        return 'Propietario';
      case ProjectMemberRole.admin:
        return 'Administrador';
      case ProjectMemberRole.member:
        return 'Miembro';
      case ProjectMemberRole.viewer:
        return 'Observador';
    }
  }

  /// Obtiene el color asociado al rol
  String get colorHex {
    switch (this) {
      case ProjectMemberRole.owner:
        return '#F59E0B'; // amber
      case ProjectMemberRole.admin:
        return '#8B5CF6'; // violet
      case ProjectMemberRole.member:
        return '#3B82F6'; // blue
      case ProjectMemberRole.viewer:
        return '#6B7280'; // gray
    }
  }
}

/// Entidad de dominio para ProjectMember
class ProjectMember extends Equatable {
  final int id;
  final int userId;
  final int projectId;
  final String userName;
  final String userEmail;
  final String? userAvatarUrl;
  final ProjectMemberRole role;
  final DateTime joinedAt;

  const ProjectMember({
    required this.id,
    required this.userId,
    required this.projectId,
    required this.userName,
    required this.userEmail,
    this.userAvatarUrl,
    required this.role,
    required this.joinedAt,
  });

  /// Verifica si el miembro es el owner del proyecto
  bool get isOwner => role == ProjectMemberRole.owner;

  /// Verifica si el miembro tiene permisos de administración
  bool get canManage =>
      role == ProjectMemberRole.owner || role == ProjectMemberRole.admin;

  /// Verifica si el miembro puede solo ver
  bool get isReadOnly => role == ProjectMemberRole.viewer;

  /// Verifica si el miembro puede editar contenido
  bool get canEdit =>
      role == ProjectMemberRole.owner ||
      role == ProjectMemberRole.admin ||
      role == ProjectMemberRole.member;

  @override
  List<Object?> get props => [
    id,
    userId,
    projectId,
    userName,
    userEmail,
    userAvatarUrl,
    role,
    joinedAt,
  ];

  /// Copia con nuevos valores
  ProjectMember copyWith({
    int? id,
    int? userId,
    int? projectId,
    String? userName,
    String? userEmail,
    String? userAvatarUrl,
    ProjectMemberRole? role,
    DateTime? joinedAt,
  }) {
    return ProjectMember(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      projectId: projectId ?? this.projectId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
