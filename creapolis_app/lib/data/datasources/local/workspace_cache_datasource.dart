import 'package:injectable/injectable.dart';

import '../../../core/database/cache_manager.dart';
import '../../../core/database/hive_manager.dart';
import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/workspace.dart';
import '../../models/hive/hive_workspace.dart';

/// Interface para el datasource de caché local de workspaces (Hive)
///
/// Este datasource gestiona el almacenamiento en caché de workspaces usando Hive.
/// Es diferente de WorkspaceLocalDataSource (SharedPreferences) que solo guarda
/// el workspace activo.
abstract class WorkspaceCacheDataSource {
  // ======================== READ ========================

  /// Obtener todos los workspaces desde el caché local
  Future<List<Workspace>> getCachedWorkspaces();

  /// Obtener un workspace específico por ID desde el caché
  Future<Workspace?> getCachedWorkspaceById(int id);

  // ======================== WRITE ========================

  /// Guardar un workspace en el caché local
  Future<void> cacheWorkspace(Workspace workspace);

  /// Guardar múltiples workspaces en el caché local
  Future<void> cacheWorkspaces(List<Workspace> workspaces);

  // ======================== DELETE ========================

  /// Eliminar un workspace del caché local
  Future<void> deleteCachedWorkspace(int id);

  /// Limpiar todo el caché de workspaces
  Future<void> clearWorkspaceCache();

  // ======================== SYNC ========================

  /// Marcar un workspace como pendiente de sincronización
  /// (usado cuando se modifica offline)
  Future<void> markAsPendingSync(int id);

  /// Obtener todos los workspaces pendientes de sincronización
  Future<List<Workspace>> getPendingSyncWorkspaces();

  // ======================== CACHE MANAGEMENT ========================

  /// Verificar si el caché de workspaces es válido (no expirado)
  Future<bool> hasValidCache();

  /// Invalidar el caché de workspaces
  Future<void> invalidateCache();
}

/// Implementación del datasource de caché usando Hive
@LazySingleton(as: WorkspaceCacheDataSource)
class WorkspaceCacheDataSourceImpl implements WorkspaceCacheDataSource {
  final CacheManager _cacheManager;

  WorkspaceCacheDataSourceImpl(this._cacheManager);

  // ======================== READ ========================

  @override
  Future<List<Workspace>> getCachedWorkspaces() async {
    try {
      final box = HiveManager.workspaces;
      final hiveWorkspaces = box.values.toList();

      if (hiveWorkspaces.isEmpty) {
        AppLogger.info('WorkspaceCacheDS: No hay workspaces en caché');
        return [];
      }

      final workspaces = hiveWorkspaces.map((h) => h.toEntity()).toList();

      AppLogger.info(
        'WorkspaceCacheDS: ${workspaces.length} workspaces obtenidos desde caché',
      );
      return workspaces;
    } catch (e, stackTrace) {
      AppLogger.error(
        'WorkspaceCacheDS: Error al leer workspaces desde caché',
        e,
        stackTrace,
      );
      return [];
    }
  }

  @override
  Future<Workspace?> getCachedWorkspaceById(int id) async {
    try {
      final box = HiveManager.workspaces;
      final hiveWorkspace = box.get(id);

      if (hiveWorkspace == null) {
        AppLogger.warning(
          'WorkspaceCacheDS: Workspace $id no encontrado en caché',
        );
        return null;
      }

      AppLogger.debug('WorkspaceCacheDS: Workspace $id obtenido desde caché');
      return hiveWorkspace.toEntity();
    } catch (e, stackTrace) {
      AppLogger.error(
        'WorkspaceCacheDS: Error al leer workspace $id desde caché',
        e,
        stackTrace,
      );
      return null;
    }
  }

  // ======================== WRITE ========================

  @override
  Future<void> cacheWorkspace(Workspace workspace) async {
    try {
      final hiveModel = HiveWorkspace.fromEntity(workspace);
      final box = HiveManager.workspaces;

      await box.put(workspace.id, hiveModel);

      // Actualizar timestamp individual del workspace
      await _cacheManager.setCacheTimestamp(
        CacheManager.workspaceKey(workspace.id),
      );

      AppLogger.debug(
        'WorkspaceCacheDS: Workspace ${workspace.id} (${workspace.name}) cacheado correctamente',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'WorkspaceCacheDS: Error al cachear workspace ${workspace.id}',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> cacheWorkspaces(List<Workspace> workspaces) async {
    try {
      final hiveModels = workspaces
          .map((w) => HiveWorkspace.fromEntity(w))
          .toList();

      final box = HiveManager.workspaces;
      final map = {for (var w in hiveModels) w.id: w};

      await box.putAll(map);

      // Actualizar timestamp de la lista completa
      await _cacheManager.setCacheTimestamp(CacheManager.workspacesListKey);

      AppLogger.info(
        'WorkspaceCacheDS: ${workspaces.length} workspaces cacheados correctamente',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'WorkspaceCacheDS: Error al cachear lista de workspaces',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  // ======================== DELETE ========================

  @override
  Future<void> deleteCachedWorkspace(int id) async {
    try {
      final box = HiveManager.workspaces;
      await box.delete(id);

      // Invalidar caché del workspace y datos relacionados
      await _cacheManager.invalidateWorkspace(id);

      AppLogger.info('WorkspaceCacheDS: Workspace $id eliminado del caché');
    } catch (e, stackTrace) {
      AppLogger.error(
        'WorkspaceCacheDS: Error al eliminar workspace $id del caché',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> clearWorkspaceCache() async {
    try {
      final box = HiveManager.workspaces;
      await box.clear();

      // Invalidar todos los timestamps relacionados con workspaces
      await _cacheManager.invalidateCachePattern('workspace');

      AppLogger.info('WorkspaceCacheDS: Caché completo de workspaces limpiado');
    } catch (e, stackTrace) {
      AppLogger.error(
        'WorkspaceCacheDS: Error al limpiar caché de workspaces',
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
      final box = HiveManager.workspaces;
      final hiveWorkspace = box.get(id);

      if (hiveWorkspace == null) {
        throw Exception('Workspace $id no existe en caché local');
      }

      // Marcar como pendiente de sincronización
      hiveWorkspace.isPendingSync = true;
      hiveWorkspace.lastSyncedAt = null;
      await hiveWorkspace.save();

      AppLogger.info(
        'WorkspaceCacheDS: Workspace $id marcado como pendiente de sincronización',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'WorkspaceCacheDS: Error al marcar workspace $id como pendiente de sync',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<List<Workspace>> getPendingSyncWorkspaces() async {
    try {
      final box = HiveManager.workspaces;
      final pendingWorkspaces = box.values
          .where((w) => w.isPendingSync)
          .map((h) => h.toEntity())
          .toList();

      AppLogger.info(
        'WorkspaceCacheDS: ${pendingWorkspaces.length} workspaces pendientes de sincronización',
      );

      return pendingWorkspaces;
    } catch (e, stackTrace) {
      AppLogger.error(
        'WorkspaceCacheDS: Error al obtener workspaces pendientes de sync',
        e,
        stackTrace,
      );
      return [];
    }
  }

  // ======================== CACHE MANAGEMENT ========================

  @override
  Future<bool> hasValidCache() async {
    try {
      final isValid = await _cacheManager.isWorkspacesListValid();

      AppLogger.debug(
        'WorkspaceCacheDS: Validez del caché de workspaces: $isValid',
      );

      return isValid;
    } catch (e, stackTrace) {
      AppLogger.error(
        'WorkspaceCacheDS: Error al verificar validez del caché',
        e,
        stackTrace,
      );
      return false;
    }
  }

  @override
  Future<void> invalidateCache() async {
    try {
      await _cacheManager.invalidateCachePattern('workspace');

      AppLogger.info('WorkspaceCacheDS: Caché de workspaces invalidado');
    } catch (e, stackTrace) {
      AppLogger.error(
        'WorkspaceCacheDS: Error al invalidar caché de workspaces',
        e,
        stackTrace,
      );
      rethrow;
    }
  }
}
