import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/repositories/project_member_repository.dart';
import 'project_member_event.dart';
import 'project_member_state.dart';

@injectable
class ProjectMemberBloc extends Bloc<ProjectMemberEvent, ProjectMemberState> {
  final ProjectMemberRepository _repository;

  ProjectMemberBloc(this._repository) : super(const ProjectMemberInitial()) {
    on<LoadProjectMembers>(_onLoadProjectMembers);
    on<AddProjectMember>(_onAddProjectMember);
    on<UpdateProjectMemberRole>(_onUpdateProjectMemberRole);
    on<RemoveProjectMember>(_onRemoveProjectMember);
    on<RefreshProjectMembers>(_onRefreshProjectMembers);
  }

  /// Cargar miembros de un proyecto
  Future<void> _onLoadProjectMembers(
    LoadProjectMembers event,
    Emitter<ProjectMemberState> emit,
  ) async {
    AppLogger.info('Loading project members for project ${event.projectId}');
    emit(const ProjectMemberLoading());

    final result = await _repository.getProjectMembers(event.projectId);

    result.fold(
      (failure) {
        AppLogger.error('Failed to load project members: ${failure.message}');
        emit(ProjectMemberError(failure.message));
      },
      (members) {
        AppLogger.info('Loaded ${members.length} project members');
        emit(ProjectMemberLoaded(members: members, projectId: event.projectId));
      },
    );
  }

  /// Agregar un miembro al proyecto
  Future<void> _onAddProjectMember(
    AddProjectMember event,
    Emitter<ProjectMemberState> emit,
  ) async {
    AppLogger.info(
      'Adding member ${event.userId} with role ${event.role.name} to project ${event.projectId}',
    );

    // Mantener el estado actual mientras se procesa
    final currentState = state;
    if (currentState is ProjectMemberLoaded) {
      emit(
        ProjectMemberOperationInProgress(
          currentMembers: currentState.members,
          projectId: event.projectId,
          operation: 'adding',
        ),
      );
    }

    final result = await _repository.addMember(
      projectId: event.projectId,
      userId: event.userId,
      role: event.role,
    );

    await result.fold(
      (failure) async {
        AppLogger.error('Failed to add member: ${failure.message}');
        emit(ProjectMemberError(failure.message));

        // Volver al estado anterior después de 2 segundos
        await Future.delayed(const Duration(seconds: 2));
        if (currentState is ProjectMemberLoaded) {
          emit(currentState);
        }
      },
      (member) async {
        AppLogger.info('Member added successfully: ${member.userName}');

        // Recargar la lista completa
        final membersResult = await _repository.getProjectMembers(
          event.projectId,
        );

        membersResult.fold(
          (failure) {
            emit(ProjectMemberError(failure.message));
          },
          (members) {
            emit(
              ProjectMemberOperationSuccess(
                message:
                    'Miembro ${member.userName} agregado como ${member.role.displayName}',
                members: members,
                projectId: event.projectId,
              ),
            );
          },
        );
      },
    );
  }

  /// Actualizar el rol de un miembro
  Future<void> _onUpdateProjectMemberRole(
    UpdateProjectMemberRole event,
    Emitter<ProjectMemberState> emit,
  ) async {
    AppLogger.info(
      'Updating role for member ${event.userId} to ${event.newRole.name} in project ${event.projectId}',
    );

    final currentState = state;
    if (currentState is ProjectMemberLoaded) {
      emit(
        ProjectMemberOperationInProgress(
          currentMembers: currentState.members,
          projectId: event.projectId,
          operation: 'updating',
        ),
      );
    }

    final result = await _repository.updateMemberRole(
      projectId: event.projectId,
      userId: event.userId,
      role: event.newRole,
    );

    await result.fold(
      (failure) async {
        AppLogger.error('Failed to update member role: ${failure.message}');
        emit(ProjectMemberError(failure.message));

        await Future.delayed(const Duration(seconds: 2));
        if (currentState is ProjectMemberLoaded) {
          emit(currentState);
        }
      },
      (member) async {
        AppLogger.info('Member role updated successfully: ${member.role.name}');

        // Recargar la lista completa
        final membersResult = await _repository.getProjectMembers(
          event.projectId,
        );

        membersResult.fold(
          (failure) {
            emit(ProjectMemberError(failure.message));
          },
          (members) {
            emit(
              ProjectMemberOperationSuccess(
                message: 'Rol actualizado a ${member.role.displayName}',
                members: members,
                projectId: event.projectId,
              ),
            );
          },
        );
      },
    );
  }

  /// Remover un miembro del proyecto
  Future<void> _onRemoveProjectMember(
    RemoveProjectMember event,
    Emitter<ProjectMemberState> emit,
  ) async {
    AppLogger.info(
      'Removing member ${event.userId} from project ${event.projectId}',
    );

    final currentState = state;
    if (currentState is ProjectMemberLoaded) {
      emit(
        ProjectMemberOperationInProgress(
          currentMembers: currentState.members,
          projectId: event.projectId,
          operation: 'removing',
        ),
      );
    }

    final result = await _repository.removeMember(
      projectId: event.projectId,
      userId: event.userId,
    );

    await result.fold(
      (failure) async {
        AppLogger.error('Failed to remove member: ${failure.message}');
        emit(ProjectMemberError(failure.message));

        await Future.delayed(const Duration(seconds: 2));
        if (currentState is ProjectMemberLoaded) {
          emit(currentState);
        }
      },
      (_) async {
        AppLogger.info('Member removed successfully');

        // Recargar la lista completa
        final membersResult = await _repository.getProjectMembers(
          event.projectId,
        );

        membersResult.fold(
          (failure) {
            emit(ProjectMemberError(failure.message));
          },
          (members) {
            emit(
              ProjectMemberOperationSuccess(
                message: 'Miembro removido del proyecto',
                members: members,
                projectId: event.projectId,
              ),
            );
          },
        );
      },
    );
  }

  /// Refrescar la lista de miembros
  Future<void> _onRefreshProjectMembers(
    RefreshProjectMembers event,
    Emitter<ProjectMemberState> emit,
  ) async {
    AppLogger.info('Refreshing project members for project ${event.projectId}');

    final result = await _repository.getProjectMembers(event.projectId);

    result.fold(
      (failure) {
        AppLogger.error(
          'Failed to refresh project members: ${failure.message}',
        );
        emit(ProjectMemberError(failure.message));
      },
      (members) {
        AppLogger.info('Refreshed ${members.length} project members');
        emit(ProjectMemberLoaded(members: members, projectId: event.projectId));
      },
    );
  }
}
