import 'package:dartz/dartz.dart' hide Task;
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Use case para obtener tareas de un proyecto
@injectable
class GetTasksByProjectUseCase {
  final TaskRepository _repository;

  GetTasksByProjectUseCase(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, List<Task>>> call(int projectId) async {
    return await _repository.getTasksByProject(projectId);
  }
}
