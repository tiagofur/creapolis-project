import 'package:injectable/injectable.dart';

import '../../../core/database/cache_manager.dart';
import '../../../core/database/hive_manager.dart';
import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/project.dart';
import '../../models/hive/hive_project.dart';

/// Interface para el datasource de caché local de proyectos (Hive)
///
/// Este datasource gestiona el almacenamiento en caché de proyectos usando Hive.
/// Soporta filtrado por workspace para optimizar las consultas.
abstract class ProjectCacheDataSource {
  // ======================== READ ========================

  /// Obtener proyectos desde el caché local
  /// Si [workspaceId] se proporciona, filtra por ese workspace
  Future<List<Project>> getCachedProjects({int? workspaceId});

  /// Obtener un proyecto específico por ID desde el caché
  Future<Project?> getCachedProjectById(int id);

  // ======================== WRITE ========================

  /// Guardar un proyecto en el caché local
  Future<void> cacheProject(Project project);

  /// Guardar múltiples proyectos en el caché local
  /// [workspaceId] es requerido para actualizar el timestamp correcto
  Future<void> cacheProjects(
    List<Project> projects, {
    required int workspaceId,
  });

  // ======================== DELETE ========================

  /// Eliminar un proyecto del caché local
  Future<void> deleteCachedProject(int id);

  /// Limpiar el caché de proyectos
  /// Si [workspaceId] se proporciona, solo limpia proyectos de ese workspace
  Future<void> clearProjectCache({int? workspaceId});

  // ======================== SYNC ========================

  /// Marcar un proyecto como pendiente de sincronización
  Future<void> markAsPendingSync(int id);

  /// Obtener todos los proyectos pendientes de sincronización
  Future<List<Project>> getPendingSyncProjects();

  // ======================== CACHE MANAGEMENT ========================

  /// Verificar si el caché de proyectos de un workspace es válido
  Future<bool> hasValidCache(int workspaceId);

  /// Invalidar el caché de proyectos
  /// Si [workspaceId] se proporciona, solo invalida ese workspace
  Future<void> invalidateCache(int? workspaceId);
}

/// Implementación del datasource de caché de proyectos usando Hive
@LazySingleton(as: ProjectCacheDataSource)
class ProjectCacheDataSourceImpl implements ProjectCacheDataSource {
  final CacheManager _cacheManager;

  ProjectCacheDataSourceImpl(this._cacheManager);

  // ======================== READ ========================

  @override
  Future<List<Project>> getCachedProjects({int? workspaceId}) async {
    try {
      final box = HiveManager.projects;
      var hiveProjects = box.values.toList();

      // Filtrar por workspaceId si se proporciona
      if (workspaceId != null) {
        hiveProjects = hiveProjects
            .where((p) => p.workspaceId == workspaceId)
            .toList();
      }

      if (hiveProjects.isEmpty) {
        final workspaceInfo = workspaceId != null
            ? ' para workspace $workspaceId'
            : '';
        AppLogger.info(
          'ProjectCacheDS: No hay proyectos en caché$workspaceInfo',
        );
        return [];
      }

      final projects = hiveProjects.map((h) => h.toEntity()).toList();

      AppLogger.info(
        'ProjectCacheDS: ${projects.length} proyectos obtenidos desde caché'
        '${workspaceId != null ? ' (workspace $workspaceId)' : ''}',
      );

      return projects;
    } catch (e, stackTrace) {
      AppLogger.error(
        'ProjectCacheDS: Error al leer proyectos desde caché',
        e,
        stackTrace,
      );
      return [];
    }
  }

  @override
  Future<Project?> getCachedProjectById(int id) async {
    try {
      final box = HiveManager.projects;
      final hiveProject = box.get(id);

      if (hiveProject == null) {
        AppLogger.warning(
          'ProjectCacheDS: Proyecto $id no encontrado en caché',
        );
        return null;
      }

      AppLogger.debug('ProjectCacheDS: Proyecto $id obtenido desde caché');

      return hiveProject.toEntity();
    } catch (e, stackTrace) {
      AppLogger.error(
        'ProjectCacheDS: Error al leer proyecto $id desde caché',
        e,
        stackTrace,
      );
      return null;
    }
  }

  // ======================== WRITE ========================

  @override
  Future<void> cacheProject(Project project) async {
    try {
      final hiveModel = HiveProject.fromEntity(project);
      final box = HiveManager.projects;

      await box.put(project.id, hiveModel);

      // Actualizar timestamp individual del proyecto
      await _cacheManager.setCacheTimestamp(
        CacheManager.projectKey(project.id),
      );

      AppLogger.debug(
        'ProjectCacheDS: Proyecto ${project.id} (${project.name}) cacheado correctamente',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'ProjectCacheDS: Error al cachear proyecto ${project.id}',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> cacheProjects(
    List<Project> projects, {
    required int workspaceId,
  }) async {
    try {
      final hiveModels = projects
          .map((p) => HiveProject.fromEntity(p))
          .toList();

      final box = HiveManager.projects;
      final map = {for (var p in hiveModels) p.id: p};

      await box.putAll(map);

      // Actualizar timestamp específico del workspace
      await _cacheManager.setCacheTimestamp(
        CacheManager.projectsListKey(workspaceId),
      );

      AppLogger.info(
        'ProjectCacheDS: ${projects.length} proyectos cacheados para workspace $workspaceId',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'ProjectCacheDS: Error al cachear lista de proyectos (workspace $workspaceId)',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  // ======================== DELETE ========================

  @override
  Future<void> deleteCachedProject(int id) async {
    try {
      final box = HiveManager.projects;

      // Obtener el proyecto antes de eliminarlo para invalidar caché correctamente
      final hiveProject = box.get(id);
      final workspaceId = hiveProject?.workspaceId;

      await box.delete(id);

      // Invalidar caché del proyecto
      await _cacheManager.invalidateProject(id);

      // Si conocemos el workspace, también invalidar su lista
      if (workspaceId != null) {
        await _cacheManager.invalidateCache(
          CacheManager.projectsListKey(workspaceId),
        );
      }

      AppLogger.info('ProjectCacheDS: Proyecto $id eliminado del caché');
    } catch (e, stackTrace) {
      AppLogger.error(
        'ProjectCacheDS: Error al eliminar proyecto $id del caché',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> clearProjectCache({int? workspaceId}) async {
    try {
      final box = HiveManager.projects;

      if (workspaceId != null) {
        // Eliminar solo proyectos del workspace específico
        final projectsToDelete = box.values
            .where((p) => p.workspaceId == workspaceId)
            .map((p) => p.id)
            .toList();

        for (final id in projectsToDelete) {
          await box.delete(id);
        }

        // Invalidar caché del workspace
        await _cacheManager.invalidateCachePattern(
          'projects_list_workspace_$workspaceId',
        );

        AppLogger.info(
          'ProjectCacheDS: ${projectsToDelete.length} proyectos de workspace $workspaceId eliminados del caché',
        );
      } else {
        // Limpiar todo el caché de proyectos
        await box.clear();
        await _cacheManager.invalidateCachePattern('project');

        AppLogger.info('ProjectCacheDS: Caché completo de proyectos limpiado');
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'ProjectCacheDS: Error al limpiar caché de proyectos',
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
      final box = HiveManager.projects;
      final hiveProject = box.get(id);

      if (hiveProject == null) {
        throw Exception('Proyecto $id no existe en caché local');
      }

      // Marcar como pendiente de sincronización
      hiveProject.isPendingSync = true;
      hiveProject.lastSyncedAt = null;
      await hiveProject.save();

      AppLogger.info(
        'ProjectCacheDS: Proyecto $id marcado como pendiente de sincronización',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'ProjectCacheDS: Error al marcar proyecto $id como pendiente de sync',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<List<Project>> getPendingSyncProjects() async {
    try {
      final box = HiveManager.projects;
      final pendingProjects = box.values
          .where((p) => p.isPendingSync)
          .map((h) => h.toEntity())
          .toList();

      AppLogger.info(
        'ProjectCacheDS: ${pendingProjects.length} proyectos pendientes de sincronización',
      );

      return pendingProjects;
    } catch (e, stackTrace) {
      AppLogger.error(
        'ProjectCacheDS: Error al obtener proyectos pendientes de sync',
        e,
        stackTrace,
      );
      return [];
    }
  }

  // ======================== CACHE MANAGEMENT ========================

  @override
  Future<bool> hasValidCache(int workspaceId) async {
    try {
      final isValid = await _cacheManager.isProjectsListValid(workspaceId);

      AppLogger.debug(
        'ProjectCacheDS: Validez del caché de proyectos (workspace $workspaceId): $isValid',
      );

      return isValid;
    } catch (e, stackTrace) {
      AppLogger.error(
        'ProjectCacheDS: Error al verificar validez del caché',
        e,
        stackTrace,
      );
      return false;
    }
  }

  @override
  Future<void> invalidateCache(int? workspaceId) async {
    try {
      if (workspaceId != null) {
        await _cacheManager.invalidateProject(workspaceId);
        AppLogger.info(
          'ProjectCacheDS: Caché de proyectos de workspace $workspaceId invalidado',
        );
      } else {
        await _cacheManager.invalidateCachePattern('project');
        AppLogger.info(
          'ProjectCacheDS: Caché completo de proyectos invalidado',
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'ProjectCacheDS: Error al invalidar caché de proyectos',
        e,
        stackTrace,
      );
      rethrow;
    }
  }
}



