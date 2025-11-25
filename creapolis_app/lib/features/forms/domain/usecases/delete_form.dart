import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/form_repository.dart';

@lazySingleton
class DeleteForm implements UseCase<void, int> {
  final FormRepository repository;

  DeleteForm(this.repository);

  @override
  Future<Either<Failure, void>> call(int formId) async {
    return await repository.deleteForm(formId);
  }
}
