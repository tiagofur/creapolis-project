import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/form_entity.dart';
import '../repositories/form_repository.dart';

@lazySingleton
class GetFormById implements UseCase<FormEntity, int> {
  final FormRepository repository;

  GetFormById(this.repository);

  @override
  Future<Either<Failure, FormEntity>> call(int formId) async {
    return await repository.getFormById(formId);
  }
}
