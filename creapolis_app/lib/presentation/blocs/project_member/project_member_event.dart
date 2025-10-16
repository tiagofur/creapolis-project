import 'package:equatable/equatable.dart';

import '../../../domain/entities/project_member.dart';

/// Eventos del ProjectMemberBloc
abstract class ProjectMemberEvent extends Equatable {
  const ProjectMemberEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar miembros de un proyecto
class LoadProjectMembers extends ProjectMemberEvent {
  final int projectId;

  const LoadProjectMembers(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

/// Agregar un miembro al proyecto
class AddProjectMember extends ProjectMemberEvent {
  final int projectId;
  final int userId;
  final ProjectMemberRole role;

  const AddProjectMember({
    required this.projectId,
    required this.userId,
    required this.role,
  });

  @override
  List<Object?> get props => [projectId, userId, role];
}

/// Actualizar el rol de un miembro
class UpdateProjectMemberRole extends ProjectMemberEvent {
  final int projectId;
  final int userId;
  final ProjectMemberRole newRole;

  const UpdateProjectMemberRole({
    required this.projectId,
    required this.userId,
    required this.newRole,
  });

  @override
  List<Object?> get props => [projectId, userId, newRole];
}

/// Remover un miembro del proyecto
class RemoveProjectMember extends ProjectMemberEvent {
  final int projectId;
  final int userId;

  const RemoveProjectMember({required this.projectId, required this.userId});

  @override
  List<Object?> get props => [projectId, userId];
}

/// Refrescar la lista de miembros
class RefreshProjectMembers extends ProjectMemberEvent {
  final int projectId;

  const RefreshProjectMembers(this.projectId);

  @override
  List<Object?> get props => [projectId];
}
