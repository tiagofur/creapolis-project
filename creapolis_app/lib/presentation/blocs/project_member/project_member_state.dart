import 'package:equatable/equatable.dart';

import '../../../domain/entities/project_member.dart';

/// Estados del ProjectMemberBloc
abstract class ProjectMemberState extends Equatable {
  const ProjectMemberState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ProjectMemberInitial extends ProjectMemberState {
  const ProjectMemberInitial();
}

/// Cargando miembros
class ProjectMemberLoading extends ProjectMemberState {
  const ProjectMemberLoading();
}

/// Miembros cargados exitosamente
class ProjectMemberLoaded extends ProjectMemberState {
  final List<ProjectMember> members;
  final int projectId;

  const ProjectMemberLoaded({required this.members, required this.projectId});

  @override
  List<Object?> get props => [members, projectId];

  /// Copia con nuevos valores
  ProjectMemberLoaded copyWith({List<ProjectMember>? members, int? projectId}) {
    return ProjectMemberLoaded(
      members: members ?? this.members,
      projectId: projectId ?? this.projectId,
    );
  }
}

/// Operación exitosa (add, update, remove)
class ProjectMemberOperationSuccess extends ProjectMemberState {
  final String message;
  final List<ProjectMember> members;
  final int projectId;

  const ProjectMemberOperationSuccess({
    required this.message,
    required this.members,
    required this.projectId,
  });

  @override
  List<Object?> get props => [message, members, projectId];
}

/// Error al cargar o manipular miembros
class ProjectMemberError extends ProjectMemberState {
  final String message;

  const ProjectMemberError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Operación en progreso (para add, update, remove)
class ProjectMemberOperationInProgress extends ProjectMemberState {
  final List<ProjectMember> currentMembers;
  final int projectId;
  final String operation; // 'adding', 'updating', 'removing'

  const ProjectMemberOperationInProgress({
    required this.currentMembers,
    required this.projectId,
    required this.operation,
  });

  @override
  List<Object?> get props => [currentMembers, projectId, operation];
}
