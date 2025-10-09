import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/usecases/workspace/get_workspace_members.dart';
import 'workspace_member_event.dart';
import 'workspace_member_state.dart';

/// BLoC para manejo de miembros de workspace
@injectable
class WorkspaceMemberBloc
    extends Bloc<WorkspaceMemberEvent, WorkspaceMemberState> {
  final GetWorkspaceMembersUseCase _getWorkspaceMembersUseCase;

  WorkspaceMemberBloc(this._getWorkspaceMembersUseCase)
    : super(const WorkspaceMemberInitial()) {
    on<LoadWorkspaceMembersEvent>(_onLoadWorkspaceMembers);
    on<RefreshWorkspaceMembersEvent>(_onRefreshWorkspaceMembers);
    on<UpdateMemberRoleEvent>(_onUpdateMemberRole);
    on<RemoveMemberEvent>(_onRemoveMember);
  }

  /// Manejar carga de miembros
  Future<void> _onLoadWorkspaceMembers(
    LoadWorkspaceMembersEvent event,
    Emitter<WorkspaceMemberState> emit,
  ) async {
    AppLogger.info(
      'WorkspaceMemberBloc: Cargando miembros del workspace ${event.workspaceId}',
    );
    emit(const WorkspaceMemberLoading());

    final params = GetWorkspaceMembersParams(workspaceId: event.workspaceId);
    final result = await _getWorkspaceMembersUseCase(params);

    result.fold(
      (failure) {
        AppLogger.error(
          'WorkspaceMemberBloc: Error al cargar miembros - ${failure.message}',
        );
        emit(WorkspaceMemberError(failure.message));
      },
      (members) {
        AppLogger.info(
          'WorkspaceMemberBloc: ${members.length} miembros cargados',
        );
        emit(
          WorkspaceMembersLoaded(
            members: members,
            workspaceId: event.workspaceId,
          ),
        );
      },
    );
  }

  /// Manejar refresco de miembros
  Future<void> _onRefreshWorkspaceMembers(
    RefreshWorkspaceMembersEvent event,
    Emitter<WorkspaceMemberState> emit,
  ) async {
    AppLogger.info(
      'WorkspaceMemberBloc: Refrescando miembros del workspace ${event.workspaceId}',
    );

    final params = GetWorkspaceMembersParams(workspaceId: event.workspaceId);
    final result = await _getWorkspaceMembersUseCase(params);

    result.fold(
      (failure) {
        AppLogger.error(
          'WorkspaceMemberBloc: Error al refrescar miembros - ${failure.message}',
        );
        emit(WorkspaceMemberError(failure.message));
      },
      (members) {
        AppLogger.info(
          'WorkspaceMemberBloc: ${members.length} miembros refrescados',
        );
        emit(
          WorkspaceMembersLoaded(
            members: members,
            workspaceId: event.workspaceId,
          ),
        );
      },
    );
  }

  /// Manejar actualización de rol
  Future<void> _onUpdateMemberRole(
    UpdateMemberRoleEvent event,
    Emitter<WorkspaceMemberState> emit,
  ) async {
    AppLogger.info(
      'WorkspaceMemberBloc: Actualizando rol del usuario ${event.userId} a ${event.newRole}',
    );
    emit(const WorkspaceMemberLoading());

    // TODO: Implementar cuando se cree el UpdateMemberRoleUseCase
    AppLogger.warning(
      'WorkspaceMemberBloc: UpdateMemberRole no implementado aún',
    );
    emit(const WorkspaceMemberError('Funcionalidad no implementada'));
  }

  /// Manejar remoción de miembro
  Future<void> _onRemoveMember(
    RemoveMemberEvent event,
    Emitter<WorkspaceMemberState> emit,
  ) async {
    AppLogger.info(
      'WorkspaceMemberBloc: Removiendo usuario ${event.userId} del workspace ${event.workspaceId}',
    );
    emit(const WorkspaceMemberLoading());

    // TODO: Implementar cuando se cree el RemoveMemberUseCase
    AppLogger.warning('WorkspaceMemberBloc: RemoveMember no implementado aún');
    emit(const WorkspaceMemberError('Funcionalidad no implementada'));
  }
}
