import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/custom_field.dart';
import '../../domain/repositories/custom_field_repository.dart';
import '../datasources/custom_field_remote_datasource.dart';
import '../models/custom_field_model.dart' as models;

/// Implementation of CustomFieldRepository
@LazySingleton(as: CustomFieldRepository)
class CustomFieldRepositoryImpl implements CustomFieldRepository {
  final CustomFieldRemoteDataSource _remoteDataSource;
  final ConnectivityService _connectivityService;

  CustomFieldRepositoryImpl(this._remoteDataSource, this._connectivityService);

  @override
  Future<Either<Failure, List<CustomFieldDefinition>>> getFieldDefinitions(
    int projectId, {
    bool includeInactive = false,
  }) async {
    try {
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final models = await _remoteDataSource.getFieldDefinitions(
        projectId,
        includeInactive: includeInactive,
      );

      return Right(models.map((m) => m.toEntity()).toList());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Error getting field definitions: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomFieldDefinition>> createFieldDefinition({
    required int projectId,
    required String name,
    required CustomFieldType type,
    String? description,
    bool isRequired = false,
    dynamic defaultValue,
    Map<String, dynamic>? options,
  }) async {
    try {
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(NetworkFailure('No internet connection'));
      }

      // Convert options map to list of choices if present
      List<String>? optionsList;
      if (options != null && options['choices'] != null) {
        optionsList = List<String>.from(options['choices'] as List);
      }

      final request = models.CreateCustomFieldRequest(
        name: name,
        fieldType: models.CustomFieldDefinitionModel.fromDomainType(type),
        description: description,
        isRequired: isRequired,
        defaultValue: defaultValue,
        options: optionsList,
      );

      final model = await _remoteDataSource.createFieldDefinition(
        projectId,
        request,
      );

      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Error creating field definition: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomFieldDefinition>> updateFieldDefinition({
    required int projectId,
    required int fieldId,
    String? name,
    String? description,
    bool? isRequired,
    bool? isActive,
    dynamic defaultValue,
    Map<String, dynamic>? options,
  }) async {
    try {
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (isRequired != null) data['isRequired'] = isRequired;
      if (isActive != null) data['isActive'] = isActive;
      if (defaultValue != null) data['defaultValue'] = defaultValue;
      if (options != null) {
        if (options['choices'] != null) {
          data['options'] = options['choices'];
        } else {
          data['options'] = options;
        }
      }

      final model = await _remoteDataSource.updateFieldDefinition(
        projectId,
        fieldId,
        data,
      );

      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Error updating field definition: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFieldDefinition(
    int projectId,
    int fieldId,
  ) async {
    try {
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(NetworkFailure('No internet connection'));
      }

      await _remoteDataSource.deleteFieldDefinition(projectId, fieldId);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Error deleting field definition: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> reorderFieldDefinitions(
    int projectId,
    List<int> orderedIds,
  ) async {
    try {
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(NetworkFailure('No internet connection'));
      }

      await _remoteDataSource.reorderFieldDefinitions(projectId, orderedIds);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Error reordering field definitions: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CustomFieldDefinition>>> copyFieldDefinitions(
    int targetProjectId,
    int sourceProjectId,
  ) async {
    try {
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final models = await _remoteDataSource.copyFieldDefinitions(
        targetProjectId,
        sourceProjectId,
      );

      return Right(models.map((m) => m.toEntity()).toList());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Error copying field definitions: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CustomFieldValue>>> getFieldValues(
    int taskId,
  ) async {
    try {
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final models = await _remoteDataSource.getFieldValues(taskId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Error getting field values: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CustomFieldValue>>> setFieldValues(
    int taskId,
    Map<int, dynamic> fieldValues,
  ) async {
    try {
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final fieldValuesList = fieldValues.entries
          .map((e) => {'fieldId': e.key, 'value': e.value})
          .toList();

      final models = await _remoteDataSource.setFieldValues(
        taskId,
        fieldValuesList,
      );

      return Right(models.map((m) => m.toEntity()).toList());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Error setting field values: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomFieldValue>> setFieldValue(
    int taskId,
    int fieldId,
    dynamic value,
  ) async {
    try {
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final model = await _remoteDataSource.setFieldValue(
        taskId,
        fieldId,
        value,
      );

      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Error setting field value: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFieldValue(
    int taskId,
    int fieldId,
  ) async {
    try {
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(NetworkFailure('No internet connection'));
      }

      await _remoteDataSource.deleteFieldValue(taskId, fieldId);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Error deleting field value: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }
}
