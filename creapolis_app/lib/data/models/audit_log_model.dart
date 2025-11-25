import 'package:creapolis_app/domain/entities/audit_log.dart';

class AuditLogModel extends AuditLog {
  const AuditLogModel({
    required super.id,
    required super.userId,
    super.workspaceId,
    super.projectId,
    required super.action,
    required super.entityType,
    required super.entityId,
    super.details,
    super.metadata,
    super.ipAddress,
    super.userAgent,
    required super.createdAt,
    super.userName,
    super.userEmail,
    super.userAvatarUrl,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'],
      userId: json['userId'],
      workspaceId: json['workspaceId'],
      projectId: json['projectId'],
      action: json['action'],
      entityType: json['entityType'],
      entityId: json['entityId'],
      details: json['details'],
      metadata: json['metadata'],
      ipAddress: json['ipAddress'],
      userAgent: json['userAgent'],
      createdAt: DateTime.parse(json['createdAt']),
      userName: json['user']?['name'],
      userEmail: json['user']?['email'],
      userAvatarUrl: json['user']?['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'workspaceId': workspaceId,
      'projectId': projectId,
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'details': details,
      'metadata': metadata,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
