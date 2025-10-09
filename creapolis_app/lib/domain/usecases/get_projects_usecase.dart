import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

/// Use case para obtener lista de proyectos
@injectable
class GetProjectsUseCase {
  final ProjectRepository repository;

  GetProjectsUseCase(this.repository);

  /// Ejecutar el caso de uso
  ///
  /// Si se proporciona [workspaceId], filtra por ese workspace.
  /// Retorna `Right(List<Project>)` si es exitoso.
  /// Retorna `Left(Failure)` si hay error.
  Future<Either<Failure, List<Project>>> call({int? workspaceId}) async {
    return await repository.getProjects(workspaceId: workspaceId);
  }
}
