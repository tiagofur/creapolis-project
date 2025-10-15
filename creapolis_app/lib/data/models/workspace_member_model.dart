import '../../domain/entities/workspace.dart';
import '../../domain/entities/workspace_member.dart';

/// Model para WorkspaceMember que maneja serialización JSON
class WorkspaceMemberModel {
  final int id;
  final int workspaceId;
  final int userId;
  final String userName;
  final String userEmail;
  final String? userAvatarUrl;
  final String role;
  final DateTime joinedAt;
  final DateTime? lastActiveAt;
  final bool isActive;

  const WorkspaceMemberModel({
    required this.id,
    required this.workspaceId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userAvatarUrl,
    required this.role,
    required this.joinedAt,
    this.lastActiveAt,
    this.isActive = true,
  });

  /// Crear desde JSON
  factory WorkspaceMemberModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceMemberModel(
      id: json['id'] as int,
      workspaceId: json['workspaceId'] as int,
      userId: json['userId'] as int,
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String,
      userAvatarUrl: json['userAvatarUrl'] as String?,
      role: json['role'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      lastActiveAt: json['lastActiveAt'] != null
          ? DateTime.parse(json['lastActiveAt'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workspaceId': workspaceId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userAvatarUrl': userAvatarUrl,
      'role': role,
      'joinedAt': joinedAt.toIso8601String(),
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// Convertir a entidad de dominio
  WorkspaceMember toEntity() {
    return WorkspaceMember(
      id: id,
      workspaceId: workspaceId,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userAvatarUrl: userAvatarUrl,
      role: WorkspaceRole.fromString(role),
      joinedAt: joinedAt,
      lastActiveAt: lastActiveAt,
      isActive: isActive,
    );
  }

  /// Crear desde entidad de dominio
  factory WorkspaceMemberModel.fromEntity(WorkspaceMember member) {
    return WorkspaceMemberModel(
      id: member.id,
      workspaceId: member.workspaceId,
      userId: member.userId,
      userName: member.userName,
      userEmail: member.userEmail,
      userAvatarUrl: member.userAvatarUrl,
      role: member.role.value,
      joinedAt: member.joinedAt,
      lastActiveAt: member.lastActiveAt,
      isActive: member.isActive,
    );
  }
}



