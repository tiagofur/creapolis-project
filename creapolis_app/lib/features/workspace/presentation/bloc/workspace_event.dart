import 'package:equatable/equatable.dart';

import '../../data/models/workspace_model.dart';

/// Eventos del WorkspaceBloc
abstract class WorkspaceEvent extends Equatable {
  const WorkspaceEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar todos los workspaces del usuario
class LoadWorkspaces extends WorkspaceEvent {
  const LoadWorkspaces();
}

/// Cargar un workspace específico por ID
class LoadWorkspaceById extends WorkspaceEvent {
  final int workspaceId;

  const LoadWorkspaceById(this.workspaceId);

  @override
  List<Object?> get props => [workspaceId];
}

/// Crear un nuevo workspace
class CreateWorkspace extends WorkspaceEvent {
  final String name;
  final String? description;
  final String? avatarUrl;
  final WorkspaceType type;
  final WorkspaceSettings? settings;

  const CreateWorkspace({
    required this.name,
    this.description,
    this.avatarUrl,
    this.type = WorkspaceType.team,
    this.settings,
  });

  @override
  List<Object?> get props => [name, description, avatarUrl, type, settings];
}

/// Actualizar un workspace existente
class UpdateWorkspace extends WorkspaceEvent {
  final int workspaceId;
  final String? name;
  final String? description;
  final String? avatarUrl;
  final WorkspaceType? type;
  final WorkspaceSettings? settings;

  const UpdateWorkspace({
    required this.workspaceId,
    this.name,
    this.description,
    this.avatarUrl,
    this.type,
    this.settings,
  });

  @override
  List<Object?> get props => [
    workspaceId,
    name,
    description,
    avatarUrl,
    type,
    settings,
  ];
}

/// Eliminar un workspace
class DeleteWorkspace extends WorkspaceEvent {
  final int workspaceId;

  const DeleteWorkspace(this.workspaceId);

  @override
  List<Object?> get props => [workspaceId];
}

/// Seleccionar workspace activo
class SelectWorkspace extends WorkspaceEvent {
  final int workspaceId;

  const SelectWorkspace(this.workspaceId);

  @override
  List<Object?> get props => [workspaceId];
}

/// Cargar miembros de un workspace
class LoadWorkspaceMembers extends WorkspaceEvent {
  final int workspaceId;

  const LoadWorkspaceMembers(this.workspaceId);

  @override
  List<Object?> get props => [workspaceId];
}

/// Invitar un miembro al workspace
class InviteMember extends WorkspaceEvent {
  final int workspaceId;
  final String email;
  final WorkspaceRole role;

  const InviteMember({
    required this.workspaceId,
    required this.email,
    required this.role,
  });

  @override
  List<Object?> get props => [workspaceId, email, role];
}

/// Actualizar rol de un miembro
class UpdateMemberRole extends WorkspaceEvent {
  final int workspaceId;
  final int userId;
  final WorkspaceRole role;

  const UpdateMemberRole({
    required this.workspaceId,
    required this.userId,
    required this.role,
  });

  @override
  List<Object?> get props => [workspaceId, userId, role];
}

/// Remover un miembro del workspace
class RemoveMember extends WorkspaceEvent {
  final int workspaceId;
  final int userId;

  const RemoveMember({required this.workspaceId, required this.userId});

  @override
  List<Object?> get props => [workspaceId, userId];
}

/// Cargar invitaciones pendientes
class LoadPendingInvitations extends WorkspaceEvent {
  const LoadPendingInvitations();
}

/// Aceptar una invitación
class AcceptInvitation extends WorkspaceEvent {
  final String token;

  const AcceptInvitation(this.token);

  @override
  List<Object?> get props => [token];
}

/// Rechazar una invitación
class DeclineInvitation extends WorkspaceEvent {
  final String token;

  const DeclineInvitation(this.token);

  @override
  List<Object?> get props => [token];
}
