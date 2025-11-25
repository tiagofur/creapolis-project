import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:creapolis_app/core/errors/failures.dart';
import 'package:creapolis_app/domain/repositories/sprint_repository.dart';

@injectable
class ManageSprintTasksUseCase {
  final SprintRepository repository;

  ManageSprintTasksUseCase(this.repository);

  Future<Either<Failure, void>> addTasks(
    int sprintId,
    List<int> taskIds,
  ) async {
    return await repository.addTasksToSprint(sprintId, taskIds);
  }

  Future<Either<Failure, void>> removeTasks(
    int sprintId,
    List<int> taskIds,
  ) async {
    return await repository.removeTasksFromSprint(sprintId, taskIds);
  }
}
