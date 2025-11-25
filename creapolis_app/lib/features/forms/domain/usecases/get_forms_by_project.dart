import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/form_entity.dart';
import '../repositories/form_repository.dart';

@lazySingleton
class GetFormsByProject implements UseCase<List<FormEntity>, int> {
  final FormRepository repository;

  GetFormsByProject(this.repository);

  @override
  Future<Either<Failure, List<FormEntity>>> call(int projectId) async {
    return await repository.getFormsByProject(projectId);
  }
}
