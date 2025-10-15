import 'package:equatable/equatable.dart';

import 'workspace_model.dart';

/// Modelo de miembro del workspace
class WorkspaceMember extends Equatable {
  final int id;
  final int workspaceId;
  final int userId;
  final String userName;
  final String userEmail;
  final String? userAvatarUrl;
  final WorkspaceRole role;
  final DateTime joinedAt;
  final DateTime? lastActiveAt;
  final bool isActive;

  const WorkspaceMember({
    required this.id,
    required this.workspaceId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userAvatarUrl,
    required this.role,
    required this.joinedAt,
    this.lastActiveAt,
    required this.isActive,
  });

  factory WorkspaceMember.fromJson(Map<String, dynamic> json) {
    return WorkspaceMember(
      id: json['id'] as int,
      workspaceId: json['workspaceId'] as int,
      userId: json['userId'] as int,
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String,
      userAvatarUrl: json['userAvatarUrl'] as String?,
      role: WorkspaceRole.fromString(json['role'] as String),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      lastActiveAt: json['lastActiveAt'] != null
          ? DateTime.parse(json['lastActiveAt'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workspaceId': workspaceId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userAvatarUrl': userAvatarUrl,
      'role': role.value,
      'joinedAt': joinedAt.toIso8601String(),
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  WorkspaceMember copyWith({
    int? id,
    int? workspaceId,
    int? userId,
    String? userName,
    String? userEmail,
    String? userAvatarUrl,
    WorkspaceRole? role,
    DateTime? joinedAt,
    DateTime? lastActiveAt,
    bool? isActive,
  }) {
    return WorkspaceMember(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    workspaceId,
    userId,
    userName,
    userEmail,
    userAvatarUrl,
    role,
    joinedAt,
    lastActiveAt,
    isActive,
  ];
}

/// Modelo de invitación a workspace
class WorkspaceInvitation extends Equatable {
  final int id;
  final int workspaceId;
  final String workspaceName;
  final String? workspaceDescription;
  final String? workspaceAvatarUrl;
  final WorkspaceType workspaceType;
  final String inviterName;
  final String inviterEmail;
  final String? inviterAvatarUrl;
  final String inviteeEmail;
  final WorkspaceRole role;
  final String token;
  final InvitationStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;

  const WorkspaceInvitation({
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

  factory WorkspaceInvitation.fromJson(Map<String, dynamic> json) {
    String _stringOr(Map<String, dynamic> map, String key, String fallback) {
      final value = map[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
      return fallback;
    }

    final workspaceName = _stringOr(
      json,
      'workspaceName',
      'Workspace sin nombre',
    );
    final inviterName = _stringOr(json, 'inviterName', 'Miembro');
    final inviterEmail = _stringOr(
      json,
      'inviterEmail',
      'sin-correo@desconocido.com',
    );
    final inviteeEmail = _stringOr(
      json,
      'inviteeEmail',
      'sin-correo@desconocido.com',
    );
    final token = _stringOr(json, 'token', '');
    final status = _stringOr(json, 'status', InvitationStatus.pending.value);

    final roleValue = _stringOr(json, 'role', WorkspaceRole.member.value);
    final workspaceTypeValue = _stringOr(
      json,
      'workspaceType',
      WorkspaceType.team.value,
    );
    final createdAtRaw = _stringOr(
      json,
      'createdAt',
      DateTime.now().toIso8601String(),
    );
    final expiresAtRaw = _stringOr(
      json,
      'expiresAt',
      DateTime.now().toIso8601String(),
    );

    return WorkspaceInvitation(
      id: json['id'] as int,
      workspaceId: json['workspaceId'] as int,
      workspaceName: workspaceName,
      workspaceDescription: json['workspaceDescription'] as String?,
      workspaceAvatarUrl: json['workspaceAvatarUrl'] as String?,
      workspaceType: WorkspaceType.fromString(workspaceTypeValue),
      inviterName: inviterName,
      inviterEmail: inviterEmail,
      inviterAvatarUrl: json['inviterAvatarUrl'] as String?,
      inviteeEmail: inviteeEmail,
      role: WorkspaceRole.fromString(roleValue),
      token: token,
      status: InvitationStatus.fromString(status),
      createdAt: DateTime.parse(createdAtRaw),
      expiresAt: DateTime.parse(expiresAtRaw),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workspaceId': workspaceId,
      'workspaceName': workspaceName,
      'workspaceDescription': workspaceDescription,
      'workspaceAvatarUrl': workspaceAvatarUrl,
      'workspaceType': workspaceType.value,
      'inviterName': inviterName,
      'inviterEmail': inviterEmail,
      'inviterAvatarUrl': inviterAvatarUrl,
      'inviteeEmail': inviteeEmail,
      'role': role.value,
      'token': token,
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  /// Verifica si la invitación ha expirado
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [
    id,
    workspaceId,
    workspaceName,
    workspaceDescription,
    workspaceAvatarUrl,
    workspaceType,
    inviterName,
    inviterEmail,
    inviterAvatarUrl,
    inviteeEmail,
    role,
    token,
    status,
    createdAt,
    expiresAt,
  ];
}

/// Estado de la invitación
enum InvitationStatus {
  pending('PENDING'),
  accepted('ACCEPTED'),
  declined('DECLINED'),
  expired('EXPIRED');

  final String value;
  const InvitationStatus(this.value);

  static InvitationStatus fromString(String value) {
    return InvitationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => InvitationStatus.pending,
    );
  }
}
