import 'package:equatable/equatable.dart';

class AuditLog extends Equatable {
  final int id;
  final int userId;
  final int? workspaceId;
  final int? projectId;
  final String action;
  final String entityType;
  final int entityId;
  final String? details;
  final String? metadata;
  final String? ipAddress;
  final String? userAgent;
  final DateTime createdAt;
  final String? userName;
  final String? userEmail;
  final String? userAvatarUrl;

  const AuditLog({
    required this.id,
    required this.userId,
    this.workspaceId,
    this.projectId,
    required this.action,
    required this.entityType,
    required this.entityId,
    this.details,
    this.metadata,
    this.ipAddress,
    this.userAgent,
    required this.createdAt,
    this.userName,
    this.userEmail,
    this.userAvatarUrl,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    workspaceId,
    projectId,
    action,
    entityType,
    entityId,
    details,
    metadata,
    ipAddress,
    userAgent,
    createdAt,
    userName,
    userEmail,
    userAvatarUrl,
  ];
}
