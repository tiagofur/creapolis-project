import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/form_repository.dart';

@lazySingleton
class SubmitPublicForm implements UseCase<void, SubmitPublicFormParams> {
  final FormRepository repository;

  SubmitPublicForm(this.repository);

  @override
  Future<Either<Failure, void>> call(SubmitPublicFormParams params) async {
    return await repository.submitPublicForm(params.publicLink, params.data);
  }
}

class SubmitPublicFormParams extends Equatable {
  final String publicLink;
  final Map<String, dynamic> data;

  const SubmitPublicFormParams({required this.publicLink, required this.data});

  @override
  List<Object?> get props => [publicLink, data];
}
