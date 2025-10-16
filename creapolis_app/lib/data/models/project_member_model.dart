import '../../domain/entities/project_member.dart';

/// Model para ProjectMember con serialización JSON
class ProjectMemberModel extends ProjectMember {
  const ProjectMemberModel({
    required super.id,
    required super.userId,
    required super.projectId,
    required super.userName,
    required super.userEmail,
    super.userAvatarUrl,
    required super.role,
    required super.joinedAt,
  });

  /// Crea un ProjectMemberModel desde JSON del backend
  factory ProjectMemberModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;

    return ProjectMemberModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      projectId: json['projectId'] as int,
      userName: user?['name'] as String? ?? 'Unknown',
      userEmail: user?['email'] as String? ?? '',
      userAvatarUrl: user?['avatarUrl'] as String?,
      role: ProjectMemberRole.fromString(json['role'] as String?),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }

  /// Convierte el model a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'projectId': projectId,
      'role': role.toBackendString(),
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  /// Convierte la entidad de dominio a model
  factory ProjectMemberModel.fromEntity(ProjectMember member) {
    return ProjectMemberModel(
      id: member.id,
      userId: member.userId,
      projectId: member.projectId,
      userName: member.userName,
      userEmail: member.userEmail,
      userAvatarUrl: member.userAvatarUrl,
      role: member.role,
      joinedAt: member.joinedAt,
    );
  }

  @override
  ProjectMemberModel copyWith({
    int? id,
    int? userId,
    int? projectId,
    String? userName,
    String? userEmail,
    String? userAvatarUrl,
    ProjectMemberRole? role,
    DateTime? joinedAt,
  }) {
    return ProjectMemberModel(
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
