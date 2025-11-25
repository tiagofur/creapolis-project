import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:creapolis_app/core/errors/failures.dart';
import 'package:creapolis_app/domain/entities/sprint.dart';
import 'package:creapolis_app/domain/repositories/sprint_repository.dart';

@injectable
class ManageSprintUseCase {
  final SprintRepository repository;

  ManageSprintUseCase(this.repository);

  Future<Either<Failure, Sprint>> startSprint(int id) async {
    return await repository.startSprint(id);
  }

  Future<Either<Failure, Sprint>> completeSprint(int id) async {
    return await repository.completeSprint(id);
  }

  Future<Either<Failure, Sprint>> updateSprint(
    int id, {
    String? name,
    String? goal,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await repository.updateSprint(
      id,
      name: name,
      goal: goal,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<Either<Failure, void>> deleteSprint(int id) async {
    return await repository.deleteSprint(id);
  }
}
