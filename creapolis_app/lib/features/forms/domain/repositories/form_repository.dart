import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/form_entity.dart';

abstract class FormRepository {
  Future<Either<Failure, List<FormEntity>>> getFormsByProject(int projectId);
  Future<Either<Failure, FormEntity>> getFormById(int formId);
  Future<Either<Failure, FormEntity>> createForm(
    int projectId,
    String title,
    String? description,
    FormConfig config,
  );
  Future<Either<Failure, FormEntity>> updateForm(
    int formId, {
    String? title,
    String? description,
    FormConfig? config,
    bool? isActive,
  });
  Future<Either<Failure, void>> deleteForm(int formId);
  Future<Either<Failure, FormEntity>> getPublicForm(String publicLink);
  Future<Either<Failure, void>> submitPublicForm(
    String publicLink,
    Map<String, dynamic> data,
  );
}
