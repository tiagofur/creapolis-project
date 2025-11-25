import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:creapolis_app/core/errors/failures.dart';
import 'package:creapolis_app/domain/entities/sprint.dart';
import 'package:creapolis_app/domain/repositories/sprint_repository.dart';

@injectable
class CreateSprintUseCase {
  final SprintRepository repository;

  CreateSprintUseCase(this.repository);

  Future<Either<Failure, Sprint>> call(
    int projectId,
    String name,
    DateTime startDate,
    DateTime endDate, {
    String? goal,
  }) async {
    return await repository.createSprint(
      projectId,
      name,
      startDate,
      endDate,
      goal: goal,
    );
  }
}
