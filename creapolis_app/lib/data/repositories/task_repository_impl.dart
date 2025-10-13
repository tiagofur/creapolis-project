import 'package:dartz/dartz.dart' hide Task;
import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/utils/pagination_helper.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local/task_cache_datasource.dart';
import '../datasources/task_remote_datasource.dart';

/// Implementación del repositorio de tareas con soporte offline
@LazySingleton(as: TaskRepository)
class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _remoteDataSource;
  final TaskCacheDataSource _cacheDataSource;
  final ConnectivityService _connectivityService;

  TaskRepositoryImpl(
    this._remoteDataSource,
    this._cacheDataSource,
    this._connectivityService,
  );

  @override
  Future<Either<Failure, List<Task>>> getTasksByProject(
    int projectId, {
    int? page,
    int? limit,
  }) async {
    try {
      // Si se solicita paginación, no usar caché para evitar inconsistencias
      if (page != null && limit != null) {
        // Paginación siempre requiere conexión
        final isOnline = await _connectivityService.isConnected;
        if (!isOnline) {
          return const Left(
            NetworkFailure('Paginación requiere conexión a internet'),
          );
        }

        final tasks = await _remoteDataSource.getTasksByProject(
          projectId,
          page: page,
          limit: limit,
        );
        return Right(tasks);
      }

      // Comportamiento normal sin paginación (con caché)
      // 1. Verificar si el caché tiene datos válidos para este proyecto
      final hasValidCache = await _cacheDataSource.hasValidCache(projectId);
      if (hasValidCache) {
        final cachedTasks = await _cacheDataSource.getCachedTasks(
          projectId: projectId,
        );
        return Right(cachedTasks);
      }

      // 2. Verificar conectividad
      final isOnline = await _connectivityService.isConnected;

      if (isOnline) {
        // 3a. Online: obtener de API y actualizar caché
        final tasks = await _remoteDataSource.getTasksByProject(projectId);

        // Cachear las tareas obtenidas
        await _cacheDataSource.cacheTasks(tasks, projectId: projectId);

        return Right(tasks);
      } else {
        // 3b. Offline: usar caché aunque esté expirado
        final cachedTasks = await _cacheDataSource.getCachedTasks(
          projectId: projectId,
        );
        if (cachedTasks.isNotEmpty) {
          return Right(cachedTasks);
        }

        // No hay caché y no hay conexión
        return const Left(
          NetworkFailure('Sin conexión a internet y sin datos en caché'),
        );
      }
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      // En caso de error de red, usar caché
      final cachedTasks = await _cacheDataSource.getCachedTasks(
        projectId: projectId,
      );
      if (cachedTasks.isNotEmpty) {
        return Right(cachedTasks);
      }
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      // En caso de error del servidor, intentar usar caché
      final cachedTasks = await _cacheDataSource.getCachedTasks(
        projectId: projectId,
      );
      if (cachedTasks.isNotEmpty) {
        return Right(cachedTasks);
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedResponse<Task>>>
      getTasksByProjectPaginated(
    int projectId, {
    required int page,
    required int limit,
  }) async {
    try {
      // Paginación siempre requiere conexión
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(
          NetworkFailure('Paginación requiere conexión a internet'),
        );
      }

      final response = await _remoteDataSource.getTasksByProjectPaginated(
        projectId,
        page: page,
        limit: limit,
      );

      return Right(response);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Task>> getTaskById(int projectId, int taskId) async {
    try {
      // 1. Intentar obtener del caché primero
      final cachedTask = await _cacheDataSource.getCachedTaskById(taskId);
      if (cachedTask != null) {
        // Verificar si el caché del proyecto de esta tarea es válido
        final hasValidCache = await _cacheDataSource.hasValidCache(projectId);
        if (hasValidCache) {
          return Right(cachedTask);
        }
      }

      // 2. Verificar conectividad
      final isOnline = await _connectivityService.isConnected;

      if (isOnline) {
        // 3a. Online: obtener de API y actualizar caché
        final task = await _remoteDataSource.getTaskById(projectId, taskId);

        // Cachear la tarea obtenida
        await _cacheDataSource.cacheTask(task);

        return Right(task);
      } else {
        // 3b. Offline: usar caché aunque esté expirado si existe
        if (cachedTask != null) {
          return Right(cachedTask);
        }

        // No hay caché y no hay conexión
        return const Left(
          NetworkFailure(
            'Sin conexión a internet y sin datos en caché para esta tarea',
          ),
        );
      }
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      // En caso de error de red, usar caché
      final cachedTask = await _cacheDataSource.getCachedTaskById(taskId);
      if (cachedTask != null) {
        return Right(cachedTask);
      }
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      // En caso de error del servidor, intentar usar caché
      final cachedTask = await _cacheDataSource.getCachedTaskById(taskId);
      if (cachedTask != null) {
        return Right(cachedTask);
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Task>> createTask({
    required String title,
    required String description,
    required TaskStatus status,
    required TaskPriority priority,
    required DateTime startDate,
    required DateTime endDate,
    required double estimatedHours,
    required int projectId,
    int? assignedUserId,
    List<int>? dependencyIds,
  }) async {
    try {
      final task = await _remoteDataSource.createTask(
        title: title,
        description: description,
        status: status,
        priority: priority,
        startDate: startDate,
        endDate: endDate,
        estimatedHours: estimatedHours,
        projectId: projectId,
        assignedUserId: assignedUserId,
        dependencyIds: dependencyIds,
      );
      return Right(task);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Task>> updateTask({
    required int projectId,
    required int taskId,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? startDate,
    DateTime? endDate,
    double? estimatedHours,
    double? actualHours,
    int? assignedUserId,
    List<int>? dependencyIds,
  }) async {
    try {
      final task = await _remoteDataSource.updateTask(
        projectId: projectId,
        taskId: taskId,
        title: title,
        description: description,
        status: status,
        priority: priority,
        startDate: startDate,
        endDate: endDate,
        estimatedHours: estimatedHours,
        actualHours: actualHours,
        assignedUserId: assignedUserId,
        dependencyIds: dependencyIds,
      );
      return Right(task);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(int projectId, int taskId) async {
    try {
      await _remoteDataSource.deleteTask(projectId, taskId);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TaskDependency>>> getTaskDependencies(
    int projectId,
    int taskId,
  ) async {
    try {
      final dependencies = await _remoteDataSource.getTaskDependencies(
        projectId,
        taskId,
      );
      return Right(dependencies);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskDependency>> createDependency({
    required int projectId,
    required int taskId,
    required int predecessorId,
    required String type,
  }) async {
    try {
      final dependency = await _remoteDataSource.createDependency(
        projectId: projectId,
        taskId: taskId,
        predecessorId: predecessorId,
        type: type,
      );
      return Right(dependency);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDependency({
    required int projectId,
    required int taskId,
    required int predecessorId,
  }) async {
    try {
      await _remoteDataSource.deleteDependency(
        projectId: projectId,
        taskId: taskId,
        predecessorId: predecessorId,
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> calculateSchedule(int projectId) async {
    try {
      final tasks = await _remoteDataSource.calculateSchedule(projectId);
      return Right(tasks);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> rescheduleProject(
    int projectId,
    int triggerTaskId,
  ) async {
    try {
      final tasks = await _remoteDataSource.rescheduleProject(
        projectId,
        triggerTaskId,
      );
      return Right(tasks);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
