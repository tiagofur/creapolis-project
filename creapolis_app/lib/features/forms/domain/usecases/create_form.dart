import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/form_entity.dart';
import '../repositories/form_repository.dart';

@lazySingleton
class CreateForm implements UseCase<FormEntity, CreateFormParams> {
  final FormRepository repository;

  CreateForm(this.repository);

  @override
  Future<Either<Failure, FormEntity>> call(CreateFormParams params) async {
    return await repository.createForm(
      params.projectId,
      params.title,
      params.description,
      params.config,
    );
  }
}

class CreateFormParams extends Equatable {
  final int projectId;
  final String title;
  final String? description;
  final FormConfig config;

  const CreateFormParams({
    required this.projectId,
    required this.title,
    this.description,
    required this.config,
  });

  @override
  List<Object?> get props => [projectId, title, description, config];
}
