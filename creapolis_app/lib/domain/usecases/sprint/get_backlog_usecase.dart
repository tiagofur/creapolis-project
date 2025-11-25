import 'package:dartz/dartz.dart' hide Task;
import 'package:injectable/injectable.dart';
import 'package:creapolis_app/core/errors/failures.dart';
import 'package:creapolis_app/domain/entities/task.dart';
import 'package:creapolis_app/domain/repositories/sprint_repository.dart';

@injectable
class GetBacklogUseCase {
  final SprintRepository repository;

  GetBacklogUseCase(this.repository);

  Future<Either<Failure, List<Task>>> call(int projectId) async {
    return await repository.getBacklog(projectId);
  }
}
