import 'package:equatable/equatable.dart';

import '../../../features/workspace/data/models/workspace_model.dart';
import '../../../domain/entities/workspace_invitation.dart';

/// Estados del BLoC de invitaciones
abstract class WorkspaceInvitationState extends Equatable {
  const WorkspaceInvitationState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class WorkspaceInvitationInitial extends WorkspaceInvitationState {
  const WorkspaceInvitationInitial();
}

/// Estado de carga
class WorkspaceInvitationLoading extends WorkspaceInvitationState {
  const WorkspaceInvitationLoading();
}

/// Estado de invitaciones pendientes cargadas
class PendingInvitationsLoaded extends WorkspaceInvitationState {
  final List<WorkspaceInvitation> invitations;

  const PendingInvitationsLoaded(this.invitations);

  @override
  List<Object?> get props => [invitations];

  /// Obtener invitaciones por estado
  List<WorkspaceInvitation> getByStatus(InvitationStatus status) {
    return invitations.where((i) => i.status == status).toList();
  }

  /// Copiar con nuevos valores
  PendingInvitationsLoaded copyWith({List<WorkspaceInvitation>? invitations}) {
    return PendingInvitationsLoaded(invitations ?? this.invitations);
  }
}

/// Estado de invitación creada exitosamente
class InvitationCreated extends WorkspaceInvitationState {
  final WorkspaceInvitation invitation;

  const InvitationCreated(this.invitation);

  @override
  List<Object?> get props => [invitation];
}

/// Estado de invitación aceptada exitosamente
class InvitationAccepted extends WorkspaceInvitationState {
  final Workspace workspace;

  const InvitationAccepted(this.workspace);

  @override
  List<Object?> get props => [workspace];
}

/// Estado de invitación rechazada exitosamente
class InvitationDeclined extends WorkspaceInvitationState {
  final String token;

  const InvitationDeclined(this.token);

  @override
  List<Object?> get props => [token];
}

/// Estado de error
class WorkspaceInvitationError extends WorkspaceInvitationState {
  final String message;

  const WorkspaceInvitationError(this.message);

  @override
  List<Object?> get props => [message];
}
