import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../repositories/task_repository.dart';

/// Use case para eliminar una tarea
@injectable
class DeleteTaskUseCase {
  final TaskRepository _repository;

  DeleteTaskUseCase(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, void>> call(int projectId, int taskId) async {
    return await _repository.deleteTask(projectId, taskId);
  }
}



