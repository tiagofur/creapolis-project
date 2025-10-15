import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/usecases/workspace/accept_invitation.dart';
import '../../../domain/usecases/workspace/create_invitation.dart';
import '../../../domain/usecases/workspace/get_pending_invitations.dart';
import 'workspace_invitation_event.dart';
import 'workspace_invitation_state.dart';

/// BLoC para manejo de invitaciones de workspace
@injectable
class WorkspaceInvitationBloc
    extends Bloc<WorkspaceInvitationEvent, WorkspaceInvitationState> {
  final GetPendingInvitationsUseCase _getPendingInvitationsUseCase;
  final CreateInvitationUseCase _createInvitationUseCase;
  final AcceptInvitationUseCase _acceptInvitationUseCase;

  WorkspaceInvitationBloc(
    this._getPendingInvitationsUseCase,
    this._createInvitationUseCase,
    this._acceptInvitationUseCase,
  ) : super(const WorkspaceInvitationInitial()) {
    on<LoadPendingInvitationsEvent>(_onLoadPendingInvitations);
    on<RefreshPendingInvitationsEvent>(_onRefreshPendingInvitations);
    on<CreateInvitationEvent>(_onCreateInvitation);
    on<AcceptInvitationEvent>(_onAcceptInvitation);
    on<DeclineInvitationEvent>(_onDeclineInvitation);
  }

  /// Manejar carga de invitaciones pendientes
  Future<void> _onLoadPendingInvitations(
    LoadPendingInvitationsEvent event,
    Emitter<WorkspaceInvitationState> emit,
  ) async {
    AppLogger.info('WorkspaceInvitationBloc: Cargando invitaciones pendientes');
    emit(const WorkspaceInvitationLoading());

    final result = await _getPendingInvitationsUseCase();

    result.fold(
      (failure) {
        AppLogger.error(
          'WorkspaceInvitationBloc: Error al cargar invitaciones - ${failure.message}',
        );
        emit(WorkspaceInvitationError(failure.message));
      },
      (invitations) {
        AppLogger.info(
          'WorkspaceInvitationBloc: ${invitations.length} invitaciones cargadas',
        );
        emit(PendingInvitationsLoaded(invitations));
      },
    );
  }

  /// Manejar refresco de invitaciones
  Future<void> _onRefreshPendingInvitations(
    RefreshPendingInvitationsEvent event,
    Emitter<WorkspaceInvitationState> emit,
  ) async {
    AppLogger.info(
      'WorkspaceInvitationBloc: Refrescando invitaciones pendientes',
    );

    final result = await _getPendingInvitationsUseCase();

    result.fold(
      (failure) {
        AppLogger.error(
          'WorkspaceInvitationBloc: Error al refrescar invitaciones - ${failure.message}',
        );
        emit(WorkspaceInvitationError(failure.message));
      },
      (invitations) {
        AppLogger.info(
          'WorkspaceInvitationBloc: ${invitations.length} invitaciones refrescadas',
        );
        emit(PendingInvitationsLoaded(invitations));
      },
    );
  }

  /// Manejar creación de invitación
  Future<void> _onCreateInvitation(
    CreateInvitationEvent event,
    Emitter<WorkspaceInvitationState> emit,
  ) async {
    AppLogger.info(
      'WorkspaceInvitationBloc: Creando invitación para ${event.email}',
    );
    emit(const WorkspaceInvitationLoading());

    final params = CreateInvitationParams(
      workspaceId: event.workspaceId,
      email: event.email,
      role: event.role,
    );

    final result = await _createInvitationUseCase(params);

    result.fold(
      (failure) {
        AppLogger.error(
          'WorkspaceInvitationBloc: Error al crear invitación - ${failure.message}',
        );
        emit(WorkspaceInvitationError(failure.message));
      },
      (invitation) {
        AppLogger.info(
          'WorkspaceInvitationBloc: Invitación creada con ID ${invitation.id}',
        );
        emit(InvitationCreated(invitation));

        // Recargar invitaciones después de crear
        add(const LoadPendingInvitationsEvent());
      },
    );
  }

  /// Manejar aceptación de invitación
  Future<void> _onAcceptInvitation(
    AcceptInvitationEvent event,
    Emitter<WorkspaceInvitationState> emit,
  ) async {
    AppLogger.info(
      'WorkspaceInvitationBloc: Aceptando invitación con token ${event.token}',
    );
    emit(const WorkspaceInvitationLoading());

    final params = AcceptInvitationParams(token: event.token);
    final result = await _acceptInvitationUseCase(params);

    result.fold(
      (failure) {
        AppLogger.error(
          'WorkspaceInvitationBloc: Error al aceptar invitación - ${failure.message}',
        );
        emit(WorkspaceInvitationError(failure.message));
      },
      (workspace) {
        AppLogger.info(
          'WorkspaceInvitationBloc: Invitación aceptada, workspace ${workspace.id}',
        );
        emit(InvitationAccepted(workspace));

        // Recargar invitaciones después de aceptar
        add(const LoadPendingInvitationsEvent());
      },
    );
  }

  /// Manejar rechazo de invitación
  Future<void> _onDeclineInvitation(
    DeclineInvitationEvent event,
    Emitter<WorkspaceInvitationState> emit,
  ) async {
    AppLogger.info(
      'WorkspaceInvitationBloc: Rechazando invitación con token ${event.token}',
    );
    emit(const WorkspaceInvitationLoading());

    // TODO: Implementar cuando se cree el DeclineInvitationUseCase
    AppLogger.warning(
      'WorkspaceInvitationBloc: DeclineInvitation no implementado aún',
    );
    emit(const WorkspaceInvitationError('Funcionalidad no implementada'));
  }
}



