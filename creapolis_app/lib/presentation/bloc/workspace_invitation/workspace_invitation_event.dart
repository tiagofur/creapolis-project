import 'package:equatable/equatable.dart';

import '../../../domain/entities/workspace.dart';

/// Eventos del BLoC de invitaciones
abstract class WorkspaceInvitationEvent extends Equatable {
  const WorkspaceInvitationEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar invitaciones pendientes
class LoadPendingInvitationsEvent extends WorkspaceInvitationEvent {
  const LoadPendingInvitationsEvent();
}

/// Evento para refrescar invitaciones
class RefreshPendingInvitationsEvent extends WorkspaceInvitationEvent {
  const RefreshPendingInvitationsEvent();
}

/// Evento para crear una invitación
class CreateInvitationEvent extends WorkspaceInvitationEvent {
  final int workspaceId;
  final String email;
  final WorkspaceRole role;

  const CreateInvitationEvent({
    required this.workspaceId,
    required this.email,
    required this.role,
  });

  @override
  List<Object?> get props => [workspaceId, email, role];
}

/// Evento para aceptar una invitación
class AcceptInvitationEvent extends WorkspaceInvitationEvent {
  final String token;

  const AcceptInvitationEvent(this.token);

  @override
  List<Object?> get props => [token];
}

/// Evento para rechazar una invitación
class DeclineInvitationEvent extends WorkspaceInvitationEvent {
  final String token;

  const DeclineInvitationEvent(this.token);

  @override
  List<Object?> get props => [token];
}
