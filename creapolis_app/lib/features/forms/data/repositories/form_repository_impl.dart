import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/form_entity.dart';
import '../../domain/repositories/form_repository.dart';
import '../datasources/form_remote_data_source.dart';
import '../models/form_model.dart';

@LazySingleton(as: FormRepository)
class FormRepositoryImpl implements FormRepository {
  final FormRemoteDataSource remoteDataSource;

  FormRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<FormEntity>>> getFormsByProject(
    int projectId,
  ) async {
    try {
      final forms = await remoteDataSource.getFormsByProject(projectId);
      return Right(forms);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FormEntity>> getFormById(int formId) async {
    try {
      final form = await remoteDataSource.getFormById(formId);
      return Right(form);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FormEntity>> createForm(
    int projectId,
    String title,
    String? description,
    FormConfig config,
  ) async {
    try {
      // Convert FormConfig to FormConfigModel
      final configModel = FormConfigModel(
        fields: config.fields
            .map(
              (e) => FormFieldConfigModel(
                id: e.id,
                type: e.type,
                label: e.label,
                required: e.required,
                mapTo: e.mapTo,
                options: e.options,
              ),
            )
            .toList(),
        settings: FormSettingsModel(
          defaultAssigneeId: config.settings.defaultAssigneeId,
          confirmationMessage: config.settings.confirmationMessage,
        ),
      );

      final form = await remoteDataSource.createForm(
        projectId,
        title,
        description,
        configModel,
      );
      return Right(form);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FormEntity>> updateForm(
    int formId, {
    String? title,
    String? description,
    FormConfig? config,
    bool? isActive,
  }) async {
    try {
      FormConfigModel? configModel;
      if (config != null) {
        configModel = FormConfigModel(
          fields: config.fields
              .map(
                (e) => FormFieldConfigModel(
                  id: e.id,
                  type: e.type,
                  label: e.label,
                  required: e.required,
                  mapTo: e.mapTo,
                  options: e.options,
                ),
              )
              .toList(),
          settings: FormSettingsModel(
            defaultAssigneeId: config.settings.defaultAssigneeId,
            confirmationMessage: config.settings.confirmationMessage,
          ),
        );
      }

      final form = await remoteDataSource.updateForm(
        formId,
        title: title,
        description: description,
        config: configModel,
        isActive: isActive,
      );
      return Right(form);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteForm(int formId) async {
    try {
      await remoteDataSource.deleteForm(formId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FormEntity>> getPublicForm(String publicLink) async {
    try {
      final form = await remoteDataSource.getPublicForm(publicLink);
      return Right(form);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitPublicForm(
    String publicLink,
    Map<String, dynamic> data,
  ) async {
    try {
      await remoteDataSource.submitPublicForm(publicLink, data);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
