import 'package:equatable/equatable.dart';

import '../../../domain/entities/workspace.dart';

/// Eventos del BLoC de workspaces
abstract class WorkspaceEvent extends Equatable {
  const WorkspaceEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar workspaces del usuario
class LoadUserWorkspacesEvent extends WorkspaceEvent {
  const LoadUserWorkspacesEvent();
}

/// Evento para refrescar workspaces
class RefreshWorkspacesEvent extends WorkspaceEvent {
  const RefreshWorkspacesEvent();
}

/// Evento para cargar un workspace por ID
class LoadWorkspaceByIdEvent extends WorkspaceEvent {
  final int workspaceId;

  const LoadWorkspaceByIdEvent(this.workspaceId);

  @override
  List<Object?> get props => [workspaceId];
}

/// Evento para crear un nuevo workspace
class CreateWorkspaceEvent extends WorkspaceEvent {
  final String name;
  final String? description;
  final String? avatarUrl;
  final WorkspaceType type;
  final WorkspaceSettings? settings;

  const CreateWorkspaceEvent({
    required this.name,
    this.description,
    this.avatarUrl,
    required this.type,
    this.settings,
  });

  @override
  List<Object?> get props => [name, description, avatarUrl, type, settings];
}

/// Evento para actualizar un workspace
class UpdateWorkspaceEvent extends WorkspaceEvent {
  final int workspaceId;
  final String? name;
  final String? description;
  final String? avatarUrl;
  final WorkspaceType? type;
  final WorkspaceSettings? settings;

  const UpdateWorkspaceEvent({
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

/// Evento para eliminar un workspace
class DeleteWorkspaceEvent extends WorkspaceEvent {
  final int workspaceId;

  const DeleteWorkspaceEvent(this.workspaceId);

  @override
  List<Object?> get props => [workspaceId];
}

/// Evento para establecer workspace activo
class SetActiveWorkspaceEvent extends WorkspaceEvent {
  final int workspaceId;

  const SetActiveWorkspaceEvent(this.workspaceId);

  @override
  List<Object?> get props => [workspaceId];
}

/// Evento para cargar el workspace activo
class LoadActiveWorkspaceEvent extends WorkspaceEvent {
  const LoadActiveWorkspaceEvent();
}

/// Evento para limpiar el workspace activo
class ClearActiveWorkspaceEvent extends WorkspaceEvent {
  const ClearActiveWorkspaceEvent();
}
