import '../../features/workspace/data/models/workspace_model.dart';
import '../../domain/entities/workspace_invitation.dart';

/// Model para WorkspaceInvitation que maneja serialización JSON
class WorkspaceInvitationModel {
  final int id;
  final int workspaceId;
  final String workspaceName;
  final String? workspaceDescription;
  final String? workspaceAvatarUrl;
  final String workspaceType;
  final String inviterName;
  final String inviterEmail;
  final String? inviterAvatarUrl;
  final String inviteeEmail;
  final String role;
  final String token;
  final String status;
  final DateTime createdAt;
  final DateTime expiresAt;

  const WorkspaceInvitationModel({
    required this.id,
    required this.workspaceId,
    required this.workspaceName,
    this.workspaceDescription,
    this.workspaceAvatarUrl,
    required this.workspaceType,
    required this.inviterName,
    required this.inviterEmail,
    this.inviterAvatarUrl,
    required this.inviteeEmail,
    required this.role,
    required this.token,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
  });

  /// Crear desde JSON
  factory WorkspaceInvitationModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceInvitationModel(
      id: json['id'] as int,
      workspaceId: json['workspaceId'] as int,
      workspaceName: json['workspaceName'] as String,
      workspaceDescription: json['workspaceDescription'] as String?,
      workspaceAvatarUrl: json['workspaceAvatarUrl'] as String?,
      workspaceType: json['workspaceType'] as String,
      inviterName: json['inviterName'] as String,
      inviterEmail: json['inviterEmail'] as String,
      inviterAvatarUrl: json['inviterAvatarUrl'] as String?,
      inviteeEmail: json['inviteeEmail'] as String,
      role: json['role'] as String,
      token: json['token'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workspaceId': workspaceId,
      'workspaceName': workspaceName,
      'workspaceDescription': workspaceDescription,
      'workspaceAvatarUrl': workspaceAvatarUrl,
      'workspaceType': workspaceType,
      'inviterName': inviterName,
      'inviterEmail': inviterEmail,
      'inviterAvatarUrl': inviterAvatarUrl,
      'inviteeEmail': inviteeEmail,
      'role': role,
      'token': token,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  /// Convertir a entidad de dominio
  WorkspaceInvitation toEntity() {
    return WorkspaceInvitation(
      id: id,
      workspaceId: workspaceId,
      workspaceName: workspaceName,
      workspaceDescription: workspaceDescription,
      workspaceAvatarUrl: workspaceAvatarUrl,
      workspaceType: WorkspaceType.fromString(workspaceType),
      inviterName: inviterName,
      inviterEmail: inviterEmail,
      inviterAvatarUrl: inviterAvatarUrl,
      inviteeEmail: inviteeEmail,
      role: WorkspaceRole.fromString(role),
      token: token,
      status: InvitationStatus.fromString(status),
      createdAt: createdAt,
      expiresAt: expiresAt,
    );
  }

  /// Crear desde entidad de dominio
  factory WorkspaceInvitationModel.fromEntity(WorkspaceInvitation invitation) {
    return WorkspaceInvitationModel(
      id: invitation.id,
      workspaceId: invitation.workspaceId,
      workspaceName: invitation.workspaceName,
      workspaceDescription: invitation.workspaceDescription,
      workspaceAvatarUrl: invitation.workspaceAvatarUrl,
      workspaceType: invitation.workspaceType.value,
      inviterName: invitation.inviterName,
      inviterEmail: invitation.inviterEmail,
      inviterAvatarUrl: invitation.inviterAvatarUrl,
      inviteeEmail: invitation.inviteeEmail,
      role: invitation.role.value,
      token: invitation.token,
      status: invitation.status.value,
      createdAt: invitation.createdAt,
      expiresAt: invitation.expiresAt,
    );
  }
}
