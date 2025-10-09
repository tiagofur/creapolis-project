import 'package:equatable/equatable.dart';

import '../../../domain/entities/workspace.dart';

/// Estados del BLoC de workspaces
abstract class WorkspaceState extends Equatable {
  const WorkspaceState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class WorkspaceInitial extends WorkspaceState {
  const WorkspaceInitial();
}

/// Estado de carga
class WorkspaceLoading extends WorkspaceState {
  const WorkspaceLoading();
}

/// Estado de workspaces cargados
class WorkspacesLoaded extends WorkspaceState {
  final List<Workspace> workspaces;
  final int? activeWorkspaceId;

  const WorkspacesLoaded({required this.workspaces, this.activeWorkspaceId});

  @override
  List<Object?> get props => [workspaces, activeWorkspaceId];

  /// Helper para obtener el workspace activo
  Workspace? get activeWorkspace {
    if (activeWorkspaceId == null) return null;
    try {
      return workspaces.firstWhere((w) => w.id == activeWorkspaceId);
    } catch (e) {
      return null;
    }
  }

  /// Copiar con nuevos valores
  WorkspacesLoaded copyWith({
    List<Workspace>? workspaces,
    int? activeWorkspaceId,
    bool clearActiveWorkspace = false,
  }) {
    return WorkspacesLoaded(
      workspaces: workspaces ?? this.workspaces,
      activeWorkspaceId: clearActiveWorkspace
          ? null
          : (activeWorkspaceId ?? this.activeWorkspaceId),
    );
  }
}

/// Estado de workspace único cargado
class WorkspaceLoaded extends WorkspaceState {
  final Workspace workspace;

  const WorkspaceLoaded(this.workspace);

  @override
  List<Object?> get props => [workspace];
}

/// Estado de workspace creado exitosamente
class WorkspaceCreated extends WorkspaceState {
  final Workspace workspace;

  const WorkspaceCreated(this.workspace);

  @override
  List<Object?> get props => [workspace];
}

/// Estado de workspace actualizado exitosamente
class WorkspaceUpdated extends WorkspaceState {
  final Workspace workspace;

  const WorkspaceUpdated(this.workspace);

  @override
  List<Object?> get props => [workspace];
}

/// Estado de workspace eliminado exitosamente
class WorkspaceDeleted extends WorkspaceState {
  final int workspaceId;

  const WorkspaceDeleted(this.workspaceId);

  @override
  List<Object?> get props => [workspaceId];
}

/// Estado de workspace activo establecido
class ActiveWorkspaceSet extends WorkspaceState {
  final int workspaceId;
  final Workspace? workspace;

  const ActiveWorkspaceSet({required this.workspaceId, this.workspace});

  @override
  List<Object?> get props => [workspaceId, workspace];
}

/// Estado de workspace activo limpiado
class ActiveWorkspaceCleared extends WorkspaceState {
  const ActiveWorkspaceCleared();
}

/// Estado de error
class WorkspaceError extends WorkspaceState {
  final String message;

  const WorkspaceError(this.message);

  @override
  List<Object?> get props => [message];
}
