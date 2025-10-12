import 'package:dartz/dartz.dart' hide Task;
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Use case para obtener una tarea por ID
@injectable
class GetTaskByIdUseCase {
  final TaskRepository _repository;

  GetTaskByIdUseCase(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, Task>> call(int projectId, int taskId) async {
    return await _repository.getTaskById(projectId, taskId);
  }
}
