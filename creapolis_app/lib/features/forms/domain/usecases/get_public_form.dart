import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/form_entity.dart';
import '../repositories/form_repository.dart';

@lazySingleton
class GetPublicForm implements UseCase<FormEntity, String> {
  final FormRepository repository;

  GetPublicForm(this.repository);

  @override
  Future<Either<Failure, FormEntity>> call(String publicLink) async {
    return await repository.getPublicForm(publicLink);
  }
}
