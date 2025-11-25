import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/automation.dart';
import '../../domain/repositories/automation_repository.dart';
import '../datasources/automation_remote_datasource.dart';
import '../models/automation_model.dart';

@LazySingleton(as: AutomationRepository)
class AutomationRepositoryImpl implements AutomationRepository {
  final AutomationRemoteDataSource _remoteDataSource;
  final ConnectivityService _connectivityService;

  AutomationRepositoryImpl(this._remoteDataSource, this._connectivityService);

  @override
  Future<Either<Failure, List<Automation>>> getAutomations({
    required int projectId,
    bool includeInactive = false,
    bool includeLogs = false,
  }) async {
    try {
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final models = await _remoteDataSource.getAutomations(
        projectId,
        includeInactive: includeInactive,
        includeLogs: includeLogs,
      );

      return Right(models.map((m) => m.toEntity()).toList());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Error getting automations: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Automation>> getAutomationById({
    required int automationId,
    bool includeLogs = false,
    int logsLimit = 50,
  }) async {
    try {
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final model = await _remoteDataSource.getAutomationById(
        automationId,
        includeLogs: includeLogs,
        logsLimit: logsLimit,
      );

      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Error getting automation: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Automation>> createAutomation({
    required int projectId,
    required String name,
    String? description,
    required List<AutomationTrigger> triggers,
    required List<AutomationAction> actions,
  }) async {
    try {
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final request = CreateAutomationRequest(
        name: name,
        description: description,
        triggers: triggers.map((t) {
          return CreateTriggerRequest(
            triggerType: t.triggerType,
            conditions: t.conditions != null
                ? TriggerConditionsModel.fromEntity(t.conditions!)
                : null,
          );
        }).toList(),
        actions: actions.map((a) {
          return CreateActionRequest(
            actionType: a.actionType,
            actionData: a.actionData,
          );
        }).toList(),
      );

      final model = await _remoteDataSource.createAutomation(
        projectId,
        request,
      );
      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Error creating automation: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Automation>> updateAutomation({
    required int projectId,
    required int automationId,
    String? name,
    String? description,
    bool? isActive,
    List<AutomationTrigger>? triggers,
    List<AutomationAction>? actions,
  }) async {
    try {
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (isActive != null) data['isActive'] = isActive;
      if (triggers != null) {
        data['triggers'] = triggers.map((t) {
          return {
            'triggerType': t.triggerType.value,
            if (t.conditions != null)
              'conditions': TriggerConditionsModel.fromEntity(
                t.conditions!,
              ).toJson(),
          };
        }).toList();
      }
      if (actions != null) {
        data['actions'] = actions.map((a) {
          return {'actionType': a.actionType.value, 'actionData': a.actionData};
        }).toList();
      }

      final model = await _remoteDataSource.updateAutomation(
        projectId,
        automationId,
        data,
      );

      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Error updating automation: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAutomation({
    required int projectId,
    required int automationId,
  }) async {
    try {
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(NetworkFailure('No internet connection'));
      }

      await _remoteDataSource.deleteAutomation(projectId, automationId);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Error deleting automation: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Automation>> toggleAutomation({
    required int projectId,
    required int automationId,
  }) async {
    try {
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final model = await _remoteDataSource.toggleAutomation(
        projectId,
        automationId,
      );

      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Error toggling automation: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Automation>> duplicateAutomation({
    required int projectId,
    required int automationId,
  }) async {
    try {
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final model = await _remoteDataSource.duplicateAutomation(
        projectId,
        automationId,
      );

      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Error duplicating automation: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AutomationLogsResult>> getAutomationLogs({
    required int automationId,
    int limit = 50,
    int offset = 0,
    AutomationLogStatus? status,
  }) async {
    try {
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final response = await _remoteDataSource.getAutomationLogs(
        automationId,
        limit: limit,
        offset: offset,
        status: status?.value,
      );

      return Right(
        AutomationLogsResult(
          logs: response.logs.map((m) => m.toEntity()).toList(),
          total: response.total,
          hasMore: response.hasMore,
        ),
      );
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Error getting automation logs: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AutomationStats>> getAutomationStats({
    required int projectId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final model = await _remoteDataSource.getAutomationStats(
        projectId,
        startDate: startDate,
        endDate: endDate,
      );

      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Error getting automation stats: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }
}
