import 'package:equatable/equatable.dart';

import '../../data/models/workspace_member_model.dart';
import '../../data/models/workspace_model.dart';

/// Estados del WorkspaceBloc
abstract class WorkspaceState extends Equatable {
  const WorkspaceState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class WorkspaceInitial extends WorkspaceState {
  const WorkspaceInitial();
}

/// Cargando workspaces
class WorkspaceLoading extends WorkspaceState {
  const WorkspaceLoading();
}

/// Workspaces cargados exitosamente
class WorkspaceLoaded extends WorkspaceState {
  final List<Workspace> workspaces;
  final Workspace? activeWorkspace;
  final List<WorkspaceMember>? members;
  final List<WorkspaceInvitation>? pendingInvitations;

  const WorkspaceLoaded({
    required this.workspaces,
    this.activeWorkspace,
    this.members,
    this.pendingInvitations,
  });

  WorkspaceLoaded copyWith({
    List<Workspace>? workspaces,
    Workspace? activeWorkspace,
    List<WorkspaceMember>? members,
    List<WorkspaceInvitation>? pendingInvitations,
  }) {
    return WorkspaceLoaded(
      workspaces: workspaces ?? this.workspaces,
      activeWorkspace: activeWorkspace ?? this.activeWorkspace,
      members: members ?? this.members,
      pendingInvitations: pendingInvitations ?? this.pendingInvitations,
    );
  }

  @override
  List<Object?> get props => [
    workspaces,
    activeWorkspace,
    members,
    pendingInvitations,
  ];
}

/// Operación en progreso (crear, actualizar, eliminar)
class WorkspaceOperationInProgress extends WorkspaceState {
  final String operation; // 'creating', 'updating', 'deleting', 'inviting'
  final List<Workspace> workspaces;
  final Workspace? activeWorkspace;

  const WorkspaceOperationInProgress({
    required this.operation,
    required this.workspaces,
    this.activeWorkspace,
  });

  @override
  List<Object?> get props => [operation, workspaces, activeWorkspace];
}

/// Operación completada exitosamente
class WorkspaceOperationSuccess extends WorkspaceState {
  final String message;
  final List<Workspace> workspaces;
  final Workspace? activeWorkspace;
  final Workspace? updatedWorkspace; // El workspace creado/actualizado

  const WorkspaceOperationSuccess({
    required this.message,
    required this.workspaces,
    this.activeWorkspace,
    this.updatedWorkspace,
  });

  @override
  List<Object?> get props => [
    message,
    workspaces,
    activeWorkspace,
    updatedWorkspace,
  ];
}

/// Error al operar con workspaces
class WorkspaceError extends WorkspaceState {
  final String message;
  final List<Workspace>? workspaces; // Mantener workspaces previos si existen
  final Workspace? activeWorkspace;
  final Map<String, dynamic>? fieldErrors; // Errores de validación por campo

  const WorkspaceError({
    required this.message,
    this.workspaces,
    this.activeWorkspace,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [
    message,
    workspaces,
    activeWorkspace,
    fieldErrors,
  ];
}

/// Miembros cargados exitosamente
class WorkspaceMembersLoaded extends WorkspaceState {
  final List<WorkspaceMember> members;
  final int workspaceId;

  const WorkspaceMembersLoaded({
    required this.members,
    required this.workspaceId,
  });

  @override
  List<Object?> get props => [members, workspaceId];
}

/// Invitaciones pendientes cargadas
class PendingInvitationsLoaded extends WorkspaceState {
  final List<WorkspaceInvitation> invitations;

  const PendingInvitationsLoaded(this.invitations);

  @override
  List<Object?> get props => [invitations];
}

/// Invitación aceptada/rechazada exitosamente
class InvitationHandled extends WorkspaceState {
  final String message;
  final bool accepted; // true = aceptada, false = rechazada

  const InvitationHandled({required this.message, required this.accepted});

  @override
  List<Object?> get props => [message, accepted];
}



