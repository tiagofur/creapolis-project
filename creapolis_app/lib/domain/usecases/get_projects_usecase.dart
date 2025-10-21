import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

/// Use case para obtener lista de proyectos de un workspace
@injectable
class GetProjectsUseCase {
  final ProjectRepository repository;

  GetProjectsUseCase(this.repository);

  /// Ejecutar el caso de uso
  ///
  /// [workspaceId] ID del workspace (requerido para filtrar proyectos)
  /// Retorna `Right(List<Project>)` si es exitoso.
  /// Retorna `Left(Failure)` si hay error.
  Future<Either<Failure, List<Project>>> call({
    required int workspaceId,
    ProjectStatus? status,
    String? search,
  }) async {
    return await repository.getProjects(
      workspaceId: workspaceId,
      status: status,
      search: search,
    );
  }
}
