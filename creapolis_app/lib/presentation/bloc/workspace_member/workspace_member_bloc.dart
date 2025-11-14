import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/usecases/workspace/get_workspace_members.dart';
import '../../../domain/usecases/workspace/update_member_role.dart';
import '../../../domain/usecases/workspace/remove_member.dart';
import '../../../injection.dart';
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

    final usecase = getIt<UpdateMemberRoleUseCase>();
    final params = UpdateMemberRoleParams(
      workspaceId: event.workspaceId,
      userId: event.userId,
      newRole: event.newRole,
    );

    final result = await usecase(params);
    result.fold(
      (failure) {
        AppLogger.error(
          'WorkspaceMemberBloc: Error al actualizar rol - ${failure.message}',
        );
        emit(WorkspaceMemberError(failure.message));
      },
      (member) {
        AppLogger.info('WorkspaceMemberBloc: Rol actualizado exitosamente');

        if (state is WorkspaceMembersLoaded) {
          final current = state as WorkspaceMembersLoaded;
          final updated = current.members
              .map((m) => m.userId == member.userId ? member : m)
              .toList();
          emit(current.copyWith(members: updated));
        } else {
          emit(MemberRoleUpdated(member));
        }
      },
    );
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

    final usecase = getIt<RemoveMemberUseCase>();
    final params = RemoveMemberParams(
      workspaceId: event.workspaceId,
      userId: event.userId,
    );

    final result = await usecase(params);
    result.fold(
      (failure) {
        AppLogger.error(
          'WorkspaceMemberBloc: Error al remover miembro - ${failure.message}',
        );
        emit(WorkspaceMemberError(failure.message));
      },
      (_) {
        AppLogger.info('WorkspaceMemberBloc: Miembro removido exitosamente');

        if (state is WorkspaceMembersLoaded) {
          final current = state as WorkspaceMembersLoaded;
          final updated = current.members
              .where((m) => m.userId != event.userId)
              .toList();
          emit(current.copyWith(members: updated));
        } else {
          emit(
            MemberRemoved(
              userId: event.userId,
              workspaceId: event.workspaceId,
            ),
          );
        }
      },
    );
  }
}



