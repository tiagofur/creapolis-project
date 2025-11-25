import 'package:dartz/dartz.dart' hide Task;
import 'package:creapolis_app/core/errors/failures.dart';
import 'package:creapolis_app/domain/entities/sprint.dart';
import 'package:creapolis_app/domain/entities/task.dart';

abstract class SprintRepository {
  Future<Either<Failure, List<Sprint>>> getSprintsByProject(
    int projectId, {
    SprintStatus? status,
  });
  Future<Either<Failure, Sprint>> getSprintById(int id);
  Future<Either<Failure, Sprint>> createSprint(
    int projectId,
    String name,
    DateTime startDate,
    DateTime endDate, {
    String? goal,
  });
  Future<Either<Failure, Sprint>> updateSprint(
    int id, {
    String? name,
    String? goal,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Either<Failure, void>> deleteSprint(int id);
  Future<Either<Failure, void>> addTasksToSprint(
    int sprintId,
    List<int> taskIds,
  );
  Future<Either<Failure, void>> removeTasksFromSprint(
    int sprintId,
    List<int> taskIds,
  );
  Future<Either<Failure, Sprint>> startSprint(int id);
  Future<Either<Failure, Sprint>> completeSprint(int id);
  Future<Either<Failure, List<Task>>> getBacklog(int projectId);
}
