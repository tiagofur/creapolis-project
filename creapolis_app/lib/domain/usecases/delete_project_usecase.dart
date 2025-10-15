import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../repositories/project_repository.dart';

/// Use case para eliminar un proyecto
@injectable
class DeleteProjectUseCase {
  final ProjectRepository repository;

  DeleteProjectUseCase(this.repository);

  /// Ejecutar el caso de uso
  ///
  /// Retorna `Right(void)` si es exitoso.
  /// Retorna `Left(Failure)` si hay error.
  Future<Either<Failure, void>> call(int id) async {
    return await repository.deleteProject(id);
  }
}



