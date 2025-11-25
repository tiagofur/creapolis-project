import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:creapolis_app/core/errors/failures.dart';
import 'package:creapolis_app/domain/entities/sprint.dart';
import 'package:creapolis_app/domain/repositories/sprint_repository.dart';

@injectable
class GetSprintsByProjectUseCase {
  final SprintRepository repository;

  GetSprintsByProjectUseCase(this.repository);

  Future<Either<Failure, List<Sprint>>> call(
    int projectId, {
    SprintStatus? status,
  }) async {
    return await repository.getSprintsByProject(projectId, status: status);
  }
}
