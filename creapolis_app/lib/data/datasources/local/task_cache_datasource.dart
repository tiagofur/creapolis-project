import 'package:injectable/injectable.dart';

import '../../../core/database/cache_manager.dart';
import '../../../core/database/hive_manager.dart';
import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/task.dart';
import '../../models/hive/hive_task.dart';

/// Interface para el datasource de caché local de tareas (Hive)
///
/// Este datasource gestiona el almacenamiento en caché de tareas usando Hive.
/// Soporta filtrado múltiple (projectId, status), búsqueda local, y updates parciales.
abstract class TaskCacheDataSource {
  // ======================== READ ========================

  /// Obtener tareas desde el caché local
  /// Filtra por [projectId] y/o [status] si se proporcionan
  Future<List<Task>> getCachedTasks({int? projectId, TaskStatus? status});

  /// Obtener una tarea específica por ID desde el caché
  Future<Task?> getCachedTaskById(int id);

  /// Buscar tareas localmente por texto (title o description)
  Future<List<Task>> searchTasks(String query);

  // ======================== WRITE ========================

  /// Guardar una tarea en el caché local
  Future<void> cacheTask(Task task);

  /// Guardar múltiples tareas en el caché local
  /// [projectId] es requerido para actualizar el timestamp correcto
  Future<void> cacheTasks(List<Task> tasks, {required int projectId});

  // ======================== UPDATE ========================

  /// Actualizar el status de una tarea (marca automáticamente como pending sync)
  Future<void> updateTaskStatus(int id, TaskStatus status);

  /// Actualizar el progreso de una tarea (actualHours)
  Future<void> updateTaskProgress(int id, double actualHours);

  // ======================== DELETE ========================

  /// Eliminar una tarea del caché local
  Future<void> deleteCachedTask(int id);

  /// Limpiar el caché de tareas
  /// Si [projectId] se proporciona, solo limpia tareas de ese proyecto
  Future<void> clearTaskCache({int? projectId});

  // ======================== SYNC ========================

  /// Marcar una tarea como pendiente de sincronización
  Future<void> markAsPendingSync(int id);

  /// Obtener todas las tareas pendientes de sincronización
  Future<List<Task>> getPendingSyncTasks();

  // ======================== CACHE MANAGEMENT ========================

  /// Verificar si el caché de tareas de un proyecto es válido
  Future<bool> hasValidCache(int projectId);

  /// Invalidar el caché de tareas
  /// Si [projectId] se proporciona, solo invalida ese proyecto
  Future<void> invalidateCache(int? projectId);
}

/// Implementación del datasource de caché de tareas usando Hive
@LazySingleton(as: TaskCacheDataSource)
class TaskCacheDataSourceImpl implements TaskCacheDataSource {
  final CacheManager _cacheManager;

  TaskCacheDataSourceImpl(this._cacheManager);

  // ======================== READ ========================

  @override
  Future<List<Task>> getCachedTasks({
    int? projectId,
    TaskStatus? status,
  }) async {
    try {
      final box = HiveManager.tasks;
      var hiveTasks = box.values.toList();

      // Filtrar por projectId si se proporciona
      if (projectId != null) {
        hiveTasks = hiveTasks.where((t) => t.projectId == projectId).toList();
      }

      // Convertir a entidades
      var tasks = hiveTasks.map((h) => h.toEntity()).toList();

      // Filtrar por status si se proporciona
      if (status != null) {
        tasks = tasks.where((t) => t.status == status).toList();
      }

      if (tasks.isEmpty) {
        final filterInfo = [
          if (projectId != null) 'proyecto $projectId',
          if (status != null) 'status $status',
        ].join(', ');

        AppLogger.info(
          'TaskCacheDS: No hay tareas en caché${filterInfo.isNotEmpty ? ' ($filterInfo)' : ''}',
        );
        return [];
      }

      AppLogger.info(
        'TaskCacheDS: ${tasks.length} tareas obtenidas desde caché',
      );

      return tasks;
    } catch (e, stackTrace) {
      AppLogger.error(
        'TaskCacheDS: Error al leer tareas desde caché',
        e,
        stackTrace,
      );
      return [];
    }
  }

  @override
  Future<Task?> getCachedTaskById(int id) async {
    try {
      final box = HiveManager.tasks;
      final hiveTask = box.get(id);

      if (hiveTask == null) {
        AppLogger.warning('TaskCacheDS: Tarea $id no encontrada en caché');
        return null;
      }

      AppLogger.debug('TaskCacheDS: Tarea $id obtenida desde caché');

      return hiveTask.toEntity();
    } catch (e, stackTrace) {
      AppLogger.error(
        'TaskCacheDS: Error al leer tarea $id desde caché',
        e,
        stackTrace,
      );
      return null;
    }
  }

  @override
  Future<List<Task>> searchTasks(String query) async {
    try {
      if (query.isEmpty) {
        AppLogger.warning(
          'TaskCacheDS: Query de búsqueda vacío, retornando lista vacía',
        );
        return [];
      }

      final box = HiveManager.tasks;
      final lowerQuery = query.toLowerCase();

      final hiveTasks = box.values
          .where(
            (t) =>
                t.title.toLowerCase().contains(lowerQuery) ||
                t.description.toLowerCase().contains(lowerQuery),
          )
          .toList();

      final tasks = hiveTasks.map((h) => h.toEntity()).toList();

      AppLogger.info(
        'TaskCacheDS: ${tasks.length} tareas encontradas para búsqueda "$query"',
      );

      return tasks;
    } catch (e, stackTrace) {
      AppLogger.error(
        'TaskCacheDS: Error en búsqueda local de tareas',
        e,
        stackTrace,
      );
      return [];
    }
  }

  // ======================== WRITE ========================

  @override
  Future<void> cacheTask(Task task) async {
    try {
      final hiveModel = HiveTask.fromEntity(task);
      final box = HiveManager.tasks;

      await box.put(task.id, hiveModel);

      // Actualizar timestamp individual de la tarea
      await _cacheManager.setCacheTimestamp(CacheManager.taskKey(task.id));

      AppLogger.debug(
        'TaskCacheDS: Tarea ${task.id} (${task.title}) cacheada correctamente',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'TaskCacheDS: Error al cachear tarea ${task.id}',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> cacheTasks(List<Task> tasks, {required int projectId}) async {
    try {
      final hiveModels = tasks.map((t) => HiveTask.fromEntity(t)).toList();

      final box = HiveManager.tasks;
      final map = {for (var t in hiveModels) t.id: t};

      await box.putAll(map);

      // Actualizar timestamp específico del proyecto
      await _cacheManager.setCacheTimestamp(
        CacheManager.tasksListKey(projectId),
      );

      AppLogger.info(
        'TaskCacheDS: ${tasks.length} tareas cacheadas para proyecto $projectId',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'TaskCacheDS: Error al cachear lista de tareas (proyecto $projectId)',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  // ======================== UPDATE ========================

  @override
  Future<void> updateTaskStatus(int id, TaskStatus status) async {
    try {
      final box = HiveManager.tasks;
      final hiveTask = box.get(id);

      if (hiveTask == null) {
        throw Exception('Tarea $id no existe en caché local');
      }

      // Actualizar status y marcar para sincronización
      hiveTask.status = status.toString().split('.').last.toUpperCase();
      hiveTask.updatedAt = DateTime.now();
      hiveTask.isPendingSync = true;

      await hiveTask.save();

      AppLogger.info(
        'TaskCacheDS: Status de tarea $id actualizado a $status (pendiente de sync)',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'TaskCacheDS: Error al actualizar status de tarea $id',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> updateTaskProgress(int id, double actualHours) async {
    try {
      final box = HiveManager.tasks;
      final hiveTask = box.get(id);

      if (hiveTask == null) {
        throw Exception('Tarea $id no existe en caché local');
      }

      // Actualizar progreso y marcar para sincronización
      hiveTask.actualHours = actualHours;
      hiveTask.updatedAt = DateTime.now();
      hiveTask.isPendingSync = true;

      await hiveTask.save();

      AppLogger.info(
        'TaskCacheDS: Progreso de tarea $id actualizado a $actualHours horas (pendiente de sync)',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'TaskCacheDS: Error al actualizar progreso de tarea $id',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  // ======================== DELETE ========================

  @override
  Future<void> deleteCachedTask(int id) async {
    try {
      final box = HiveManager.tasks;

      // Obtener la tarea antes de eliminarla para invalidar caché correctamente
      final hiveTask = box.get(id);
      final projectId = hiveTask?.projectId;

      await box.delete(id);

      // Invalidar caché de la tarea
      await _cacheManager.invalidateCache(CacheManager.taskKey(id));

      // Si conocemos el proyecto, también invalidar su lista
      if (projectId != null) {
        await _cacheManager.invalidateCache(
          CacheManager.tasksListKey(projectId),
        );
      }

      AppLogger.info('TaskCacheDS: Tarea $id eliminada del caché');
    } catch (e, stackTrace) {
      AppLogger.error(
        'TaskCacheDS: Error al eliminar tarea $id del caché',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> clearTaskCache({int? projectId}) async {
    try {
      final box = HiveManager.tasks;

      if (projectId != null) {
        // Eliminar solo tareas del proyecto específico
        final tasksToDelete = box.values
            .where((t) => t.projectId == projectId)
            .map((t) => t.id)
            .toList();

        for (final id in tasksToDelete) {
          await box.delete(id);
        }

        // Invalidar caché del proyecto
        await _cacheManager.invalidateCachePattern(
          'tasks_list_project_$projectId',
        );

        AppLogger.info(
          'TaskCacheDS: ${tasksToDelete.length} tareas de proyecto $projectId eliminadas del caché',
        );
      } else {
        // Limpiar todo el caché de tareas
        await box.clear();
        await _cacheManager.invalidateCachePattern('task');

        AppLogger.info('TaskCacheDS: Caché completo de tareas limpiado');
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'TaskCacheDS: Error al limpiar caché de tareas',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  // ======================== SYNC ========================

  @override
  Future<void> markAsPendingSync(int id) async {
    try {
      final box = HiveManager.tasks;
      final hiveTask = box.get(id);

      if (hiveTask == null) {
        throw Exception('Tarea $id no existe en caché local');
      }

      // Marcar como pendiente de sincronización
      hiveTask.isPendingSync = true;
      hiveTask.lastSyncedAt = null;
      await hiveTask.save();

      AppLogger.info(
        'TaskCacheDS: Tarea $id marcada como pendiente de sincronización',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'TaskCacheDS: Error al marcar tarea $id como pendiente de sync',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<List<Task>> getPendingSyncTasks() async {
    try {
      final box = HiveManager.tasks;
      final pendingTasks = box.values
          .where((t) => t.isPendingSync)
          .map((h) => h.toEntity())
          .toList();

      AppLogger.info(
        'TaskCacheDS: ${pendingTasks.length} tareas pendientes de sincronización',
      );

      return pendingTasks;
    } catch (e, stackTrace) {
      AppLogger.error(
        'TaskCacheDS: Error al obtener tareas pendientes de sync',
        e,
        stackTrace,
      );
      return [];
    }
  }

  // ======================== CACHE MANAGEMENT ========================

  @override
  Future<bool> hasValidCache(int projectId) async {
    try {
      final isValid = await _cacheManager.isTasksListValid(projectId);

      AppLogger.debug(
        'TaskCacheDS: Validez del caché de tareas (proyecto $projectId): $isValid',
      );

      return isValid;
    } catch (e, stackTrace) {
      AppLogger.error(
        'TaskCacheDS: Error al verificar validez del caché',
        e,
        stackTrace,
      );
      return false;
    }
  }

  @override
  Future<void> invalidateCache(int? projectId) async {
    try {
      if (projectId != null) {
        await _cacheManager.invalidateCachePattern(
          'tasks_list_project_$projectId',
        );
        AppLogger.info(
          'TaskCacheDS: Caché de tareas de proyecto $projectId invalidado',
        );
      } else {
        await _cacheManager.invalidateCachePattern('task');
        AppLogger.info('TaskCacheDS: Caché completo de tareas invalidado');
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'TaskCacheDS: Error al invalidar caché de tareas',
        e,
        stackTrace,
      );
      rethrow;
    }
  }
}



