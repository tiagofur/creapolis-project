import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/form_entity.dart';
import '../repositories/form_repository.dart';

@lazySingleton
class UpdateForm implements UseCase<FormEntity, UpdateFormParams> {
  final FormRepository repository;

  UpdateForm(this.repository);

  @override
  Future<Either<Failure, FormEntity>> call(UpdateFormParams params) async {
    return await repository.updateForm(
      params.formId,
      title: params.title,
      description: params.description,
      config: params.config,
      isActive: params.isActive,
    );
  }
}

class UpdateFormParams extends Equatable {
  final int formId;
  final String? title;
  final String? description;
  final FormConfig? config;
  final bool? isActive;

  const UpdateFormParams({
    required this.formId,
    this.title,
    this.description,
    this.config,
    this.isActive,
  });

  @override
  List<Object?> get props => [formId, title, description, config, isActive];
}
