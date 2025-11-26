import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/form_entity.dart';
import '../../domain/repositories/form_repository.dart';
import '../datasources/form_remote_datasource.dart';
import '../models/form_model.dart';

@LazySingleton(as: FormRepository)
class FormRepositoryImpl implements FormRepository {
  final FormRemoteDataSource remoteDataSource;

  FormRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<FormEntity>>> getFormsByProject(
    int projectId,
  ) async {
    try {
      final forms = await remoteDataSource.getFormsByProject(projectId);
      return Right(forms.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FormEntity>> getFormById(int formId) async {
    try {
      final form = await remoteDataSource.getFormById(formId);
      return Right(form.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FormEntity>> getFormByPublicLink(
    String publicLink,
  ) async {
    try {
      final form = await remoteDataSource.getFormByPublicLink(publicLink);
      return Right(form.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FormEntity>> createForm({
    required int projectId,
    required String title,
    String? description,
    required List<FormField> fields,
    required FormSettings settings,
  }) async {
    try {
      final config = FormConfig(fields: fields, settings: settings);
      final configModel = FormConfigModel.fromEntity(config);

      final data = {
        'title': title,
        if (description != null) 'description': description,
        'config': configModel.toJson(),
      };

      final form = await remoteDataSource.createForm(projectId, data);
      return Right(form.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FormEntity>> updateForm({
    required int formId,
    String? title,
    String? description,
    bool? isActive,
    List<FormField>? fields,
    FormSettings? settings,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (isActive != null) data['isActive'] = isActive;

      if (fields != null || settings != null) {
        // Need to get current form to merge config
        final currentFormResult = await getFormById(formId);
        
        return await currentFormResult.fold(
          (failure) => Left(failure),
          (currentForm) async {
            final currentConfig = currentForm.config;
            final newConfig = FormConfig(
              fields: fields ?? currentConfig.fields,
              settings: settings ?? currentConfig.settings,
            );
            final configModel = FormConfigModel.fromEntity(newConfig);
            data['config'] = configModel.toJson();

            final form = await remoteDataSource.updateForm(formId, data);
            return Right(form.toEntity());
          },
        );
      } else {
        final form = await remoteDataSource.updateForm(formId, data);
        return Right(form.toEntity());
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteForm(int formId) async {
    try {
      await remoteDataSource.deleteForm(formId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> submitForm({
    required String publicLink,
    required Map<String, dynamic> data,
  }) async {
    try {
      final result = await remoteDataSource.submitForm(publicLink, data);
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getFormSubmissions({
    required int formId,
    int page = 1,
    int limit = 20,
    bool includeTask = false,
  }) async {
    try {
      final result = await remoteDataSource.getFormSubmissions(
        formId,
        page: page,
        limit: limit,
        includeTask: includeTask,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getFormAnalytics(
    int formId,
  ) async {
    try {
      final result = await remoteDataSource.getFormAnalytics(formId);
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(
          'Connection timeout. Please check your internet connection.',
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? error.message;
        
        if (statusCode == 401) {
          return const AuthFailure('Authentication failed');
        } else if (statusCode == 403) {
          return const AuthorizationFailure('Access denied');
        } else if (statusCode == 404) {
          return const NotFoundFailure('Resource not found');
        } else {
          return ServerFailure(
            message ?? 'Server error occurred',
          );
        }
      case DioExceptionType.cancel:
        return const ServerFailure('Request cancelled');
      case DioExceptionType.connectionError:
        return const NetworkFailure(
          'No internet connection. Please check your network.',
        );
      default:
        return ServerFailure(
          error.message ?? 'An unexpected error occurred',
        );
    }
  }
}
