import 'package:dartz/dartz.dart' hide Task;
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../../core/utils/pagination_helper.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Use case para obtener tareas de un proyecto
@injectable
class GetTasksByProjectUseCase {
  final TaskRepository _repository;

  GetTasksByProjectUseCase(this._repository);

  /// Ejecuta el caso de uso sin paginación (para compatibilidad)
  Future<Either<Failure, List<Task>>> call(int projectId) async {
    return await _repository.getTasksByProject(projectId);
  }

  /// Ejecuta el caso de uso con paginación
  Future<Either<Failure, List<Task>>> paginated(
    int projectId, {
    required int page,
    required int limit,
  }) async {
    return await _repository.getTasksByProject(
      projectId,
      page: page,
      limit: limit,
    );
  }

  /// Ejecuta el caso de uso con paginación completa (incluye metadata)
  Future<Either<Failure, PaginatedResponse<Task>>> paginatedWithMetadata(
    int projectId, {
    required int page,
    required int limit,
  }) async {
    return await _repository.getTasksByProjectPaginated(
      projectId,
      page: page,
      limit: limit,
    );
  }
}
