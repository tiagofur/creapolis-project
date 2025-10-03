import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

/// Use case para obtener proyecto por ID
@injectable
class GetProjectByIdUseCase {
  final ProjectRepository repository;

  GetProjectByIdUseCase(this.repository);

  /// Ejecutar el caso de uso
  ///
  /// Retorna `Right(Project)` si es exitoso.
  /// Retorna `Left(Failure)` si hay error o no se encuentra.
  Future<Either<Failure, Project>> call(int id) async {
    return await repository.getProjectById(id);
  }
}
