import 'package:equatable/equatable.dart';

import '../../../features/workspace/data/models/workspace_model.dart';

/// Eventos del BLoC de miembros de workspace
abstract class WorkspaceMemberEvent extends Equatable {
  const WorkspaceMemberEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar miembros de un workspace
class LoadWorkspaceMembersEvent extends WorkspaceMemberEvent {
  final int workspaceId;

  const LoadWorkspaceMembersEvent(this.workspaceId);

  @override
  List<Object?> get props => [workspaceId];
}

/// Evento para refrescar miembros
class RefreshWorkspaceMembersEvent extends WorkspaceMemberEvent {
  final int workspaceId;

  const RefreshWorkspaceMembersEvent(this.workspaceId);

  @override
  List<Object?> get props => [workspaceId];
}

/// Evento para actualizar el rol de un miembro
class UpdateMemberRoleEvent extends WorkspaceMemberEvent {
  final int workspaceId;
  final int userId;
  final WorkspaceRole newRole;

  const UpdateMemberRoleEvent({
    required this.workspaceId,
    required this.userId,
    required this.newRole,
  });

  @override
  List<Object?> get props => [workspaceId, userId, newRole];
}

/// Evento para remover un miembro
class RemoveMemberEvent extends WorkspaceMemberEvent {
  final int workspaceId;
  final int userId;

  const RemoveMemberEvent({required this.workspaceId, required this.userId});

  @override
  List<Object?> get props => [workspaceId, userId];
}
