import 'package:equatable/equatable.dart';

import '../../features/workspace/data/models/workspace_model.dart';

/// Estados de invitación
enum InvitationStatus {
  pending('PENDING', 'Pendiente'),
  accepted('ACCEPTED', 'Aceptada'),
  declined('DECLINED', 'Rechazada'),
  expired('EXPIRED', 'Expirada');

  const InvitationStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static InvitationStatus fromString(String value) {
    return InvitationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => InvitationStatus.pending,
    );
  }
}

/// Invitación a workspace
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

  /// Verificar si la invitación ha expirado
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt) ||
        status == InvitationStatus.expired;
  }

  /// Verificar si la invitación está pendiente
  bool get isPending => status == InvitationStatus.pending && !isExpired;

  /// Obtener iniciales del invitador
  String get inviterInitials {
    final words = inviterName.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return inviterName.substring(0, 1).toUpperCase();
  }

  /// Obtener iniciales del workspace
  String get workspaceInitials {
    final words = workspaceName.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return workspaceName.substring(0, 1).toUpperCase();
  }

  /// Días restantes hasta la expiración
  int get daysUntilExpiration {
    if (isExpired) return 0;
    return expiresAt.difference(DateTime.now()).inDays;
  }

  WorkspaceInvitation copyWith({
    int? id,
    int? workspaceId,
    String? workspaceName,
    String? workspaceDescription,
    String? workspaceAvatarUrl,
    WorkspaceType? workspaceType,
    String? inviterName,
    String? inviterEmail,
    String? inviterAvatarUrl,
    String? inviteeEmail,
    WorkspaceRole? role,
    String? token,
    InvitationStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return WorkspaceInvitation(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      workspaceName: workspaceName ?? this.workspaceName,
      workspaceDescription: workspaceDescription ?? this.workspaceDescription,
      workspaceAvatarUrl: workspaceAvatarUrl ?? this.workspaceAvatarUrl,
      workspaceType: workspaceType ?? this.workspaceType,
      inviterName: inviterName ?? this.inviterName,
      inviterEmail: inviterEmail ?? this.inviterEmail,
      inviterAvatarUrl: inviterAvatarUrl ?? this.inviterAvatarUrl,
      inviteeEmail: inviteeEmail ?? this.inviteeEmail,
      role: role ?? this.role,
      token: token ?? this.token,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

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
