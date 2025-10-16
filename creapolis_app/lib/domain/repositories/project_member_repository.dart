import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/project_member.dart';

/// Repositorio de miembros de proyecto
abstract class ProjectMemberRepository {
  /// Obtener miembros de un proyecto
  ///
  /// Retorna lista de [ProjectMember] o [Failure]
  Future<Either<Failure, List<ProjectMember>>> getProjectMembers(int projectId);

  /// Agregar miembro a un proyecto
  ///
  /// [projectId] ID del proyecto
  /// [userId] ID del usuario a agregar
  /// [role] Rol del miembro (opcional, default: MEMBER)
  ///
  /// Retorna [ProjectMember] creado o [Failure]
  Future<Either<Failure, ProjectMember>> addMember({
    required int projectId,
    required int userId,
    ProjectMemberRole? role,
  });

  /// Actualizar rol de un miembro
  ///
  /// [projectId] ID del proyecto
  /// [userId] ID del usuario
  /// [role] Nuevo rol del miembro
  ///
  /// Retorna [ProjectMember] actualizado o [Failure]
  Future<Either<Failure, ProjectMember>> updateMemberRole({
    required int projectId,
    required int userId,
    required ProjectMemberRole role,
  });

  /// Remover miembro de un proyecto
  ///
  /// [projectId] ID del proyecto
  /// [userId] ID del usuario a remover
  ///
  /// Retorna [void] o [Failure]
  Future<Either<Failure, void>> removeMember({
    required int projectId,
    required int userId,
  });
}
