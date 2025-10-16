import 'package:equatable/equatable.dart';

import '../../features/workspace/data/models/workspace_model.dart';

/// Miembro de workspace
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
    this.isActive = true,
  });

  /// Obtener iniciales para avatar
  String get initials {
    final words = userName.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return userName.substring(0, 1).toUpperCase();
  }

  /// Verificar si está activo recientemente (últimas 24 horas)
  bool get isRecentlyActive {
    if (lastActiveAt == null) return false;
    final difference = DateTime.now().difference(lastActiveAt!);
    return difference.inHours < 24;
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
