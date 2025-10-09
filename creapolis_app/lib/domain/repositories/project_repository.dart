import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/project.dart';

/// Repositorio de proyectos
///
/// Define los contratos para operaciones con proyectos.
abstract class ProjectRepository {
  /// Obtener lista de proyectos
  ///
  /// Si se proporciona [workspaceId], filtra por ese workspace.
  /// Retorna `Right(List<Project>)` si es exitoso.
  /// Retorna `Left(Failure)` si hay error.
  Future<Either<Failure, List<Project>>> getProjects({int? workspaceId});

  /// Obtener proyecto por ID
  ///
  /// Retorna `Right(Project)` si es exitoso.
  /// Retorna `Left(Failure)` si hay error o no se encuentra.
  Future<Either<Failure, Project>> getProjectById(int id);

  /// Crear nuevo proyecto
  ///
  /// Retorna `Right(Project)` con el proyecto creado.
  /// Retorna `Left(Failure)` si hay error de validación o servidor.
  Future<Either<Failure, Project>> createProject({
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required ProjectStatus status,
    int? managerId,
    required int workspaceId,
  });

  /// Actualizar proyecto existente
  ///
  /// Retorna `Right(Project)` con el proyecto actualizado.
  /// Retorna `Left(Failure)` si hay error.
  Future<Either<Failure, Project>> updateProject({
    required int id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    ProjectStatus? status,
    int? managerId,
  });

  /// Eliminar proyecto
  ///
  /// Retorna `Right(void)` si es exitoso.
  /// Retorna `Left(Failure)` si hay error.
  Future<Either<Failure, void>> deleteProject(int id);
}
