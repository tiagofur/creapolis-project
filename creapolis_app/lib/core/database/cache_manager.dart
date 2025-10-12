import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../utils/app_logger.dart';
import 'hive_manager.dart';

/// Manager para gestión de caché con TTL (Time To Live)
/// Controla cuando los datos en caché están obsoletos y deben refrescarse
@LazySingleton()
class CacheManager {
  // TTL por defecto: 5 minutos
  static const Duration defaultTTL = Duration(minutes: 5);

  /// TTL específicos por tipo de recurso
  static const Duration workspacesTTL = Duration(minutes: 10); // Cambian poco
  static const Duration projectsTTL = Duration(
    minutes: 5,
  ); // Cambian moderadamente
  static const Duration tasksTTL = Duration(
    minutes: 2,
  ); // Cambian frecuentemente
  static const Duration dashboardTTL = Duration(minutes: 1); // Debe ser actual

  final Box _cacheMetadataBox;

  CacheManager() : _cacheMetadataBox = HiveManager.cacheMetadata;

  /// Guardar timestamp de caché para una key
  Future<void> setCacheTimestamp(String key, {DateTime? timestamp}) async {
    try {
      final time = timestamp ?? DateTime.now();
      await _cacheMetadataBox.put(key, time.toIso8601String());
      AppLogger.info('CacheManager: Timestamp guardado para "$key"');
    } catch (e, stackTrace) {
      AppLogger.error('CacheManager: Error guardando timestamp', e, stackTrace);
    }
  }

  /// Verificar si el caché es válido (no ha expirado)
  Future<bool> isCacheValid(String key, {Duration? ttl}) async {
    try {
      final timestampStr = _cacheMetadataBox.get(key) as String?;

      if (timestampStr == null) {
        AppLogger.info('CacheManager: No hay timestamp para "$key" - INVÁLIDO');
        return false;
      }

      final cacheTime = DateTime.parse(timestampStr);
      final now = DateTime.now();
      final ttlDuration = ttl ?? defaultTTL;

      final isValid = now.difference(cacheTime) < ttlDuration;

      if (isValid) {
        final remaining = ttlDuration - now.difference(cacheTime);
        AppLogger.info(
          'CacheManager: Caché "$key" VÁLIDO (expira en ${remaining.inSeconds}s)',
        );
      } else {
        AppLogger.info('CacheManager: Caché "$key" EXPIRADO');
      }

      return isValid;
    } catch (e, stackTrace) {
      AppLogger.error(
        'CacheManager: Error verificando validez de "$key"',
        e,
        stackTrace,
      );
      return false; // En caso de error, considerar caché inválido
    }
  }

  /// Invalidar caché (eliminar timestamp)
  Future<void> invalidateCache(String key) async {
    try {
      await _cacheMetadataBox.delete(key);
      AppLogger.info('CacheManager: Caché "$key" invalidado');
    } catch (e, stackTrace) {
      AppLogger.error('CacheManager: Error invalidando "$key"', e, stackTrace);
    }
  }

  /// Invalidar múltiples cachés por patrón
  Future<void> invalidateCachePattern(String pattern) async {
    try {
      final keys = _cacheMetadataBox.keys
          .cast<String>()
          .where((key) => key.contains(pattern))
          .toList();

      for (final key in keys) {
        await _cacheMetadataBox.delete(key);
      }

      AppLogger.info(
        'CacheManager: ${keys.length} cachés con patrón "$pattern" invalidados',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'CacheManager: Error invalidando patrón "$pattern"',
        e,
        stackTrace,
      );
    }
  }

  /// Invalidar todo el caché
  Future<void> invalidateAll() async {
    try {
      await _cacheMetadataBox.clear();
      AppLogger.info('CacheManager: Todo el caché invalidado');
    } catch (e, stackTrace) {
      AppLogger.error('CacheManager: Error invalidando todo', e, stackTrace);
    }
  }

  /// Obtener tiempo restante antes de expiración
  Duration? getTimeToExpiration(String key, {Duration? ttl}) {
    try {
      final timestampStr = _cacheMetadataBox.get(key) as String?;

      if (timestampStr == null) return null;

      final cacheTime = DateTime.parse(timestampStr);
      final now = DateTime.now();
      final ttlDuration = ttl ?? defaultTTL;

      final elapsed = now.difference(cacheTime);
      if (elapsed >= ttlDuration) return Duration.zero;

      return ttlDuration - elapsed;
    } catch (e) {
      AppLogger.error('CacheManager: Error obteniendo TTL de "$key"', e);
      return null;
    }
  }

  /// Obtener todas las keys de caché
  List<String> getAllCacheKeys() {
    try {
      return _cacheMetadataBox.keys.cast<String>().toList();
    } catch (e) {
      AppLogger.error('CacheManager: Error obteniendo keys', e);
      return [];
    }
  }

  /// Obtener estadísticas de caché
  Map<String, dynamic> getCacheStats() {
    try {
      final keys = getAllCacheKeys();
      final validKeys = keys.where((key) {
        final timestampStr = _cacheMetadataBox.get(key) as String?;
        if (timestampStr == null) return false;

        final cacheTime = DateTime.parse(timestampStr);
        final now = DateTime.now();
        return now.difference(cacheTime) < defaultTTL;
      }).toList();

      return {
        'total': keys.length,
        'valid': validKeys.length,
        'expired': keys.length - validKeys.length,
        'keys': keys,
      };
    } catch (e) {
      AppLogger.error('CacheManager: Error obteniendo stats', e);
      return {'total': 0, 'valid': 0, 'expired': 0, 'keys': []};
    }
  }

  // ============== MÉTODOS DE CONVENIENCIA ==============

  /// Keys de caché comunes

  // Workspaces
  static const String workspacesListKey = 'workspaces_list';
  static String workspaceKey(int id) => 'workspace_$id';

  // Projects
  static String projectsListKey(int workspaceId) =>
      'projects_list_workspace_$workspaceId';
  static String projectKey(int id) => 'project_$id';

  // Tasks
  static String tasksListKey(int projectId) => 'tasks_list_project_$projectId';
  static String taskKey(int id) => 'task_$id';

  // Dashboard
  static String dashboardStatsKey(int workspaceId) =>
      'dashboard_stats_workspace_$workspaceId';

  /// Verificar validez de caché de workspaces
  Future<bool> isWorkspacesListValid() async {
    return isCacheValid(workspacesListKey, ttl: workspacesTTL);
  }

  /// Verificar validez de caché de projects por workspace
  Future<bool> isProjectsListValid(int workspaceId) async {
    return isCacheValid(projectsListKey(workspaceId), ttl: projectsTTL);
  }

  /// Verificar validez de caché de tasks por proyecto
  Future<bool> isTasksListValid(int projectId) async {
    return isCacheValid(tasksListKey(projectId), ttl: tasksTTL);
  }

  /// Invalidar caché de un workspace específico y sus datos relacionados
  Future<void> invalidateWorkspace(int workspaceId) async {
    await invalidateCache(workspaceKey(workspaceId));
    await invalidateCachePattern('workspace_$workspaceId');
    AppLogger.info(
      'CacheManager: Workspace $workspaceId y datos relacionados invalidados',
    );
  }

  /// Invalidar caché de un proyecto específico y sus datos relacionados
  Future<void> invalidateProject(int projectId) async {
    await invalidateCache(projectKey(projectId));
    await invalidateCachePattern('project_$projectId');
    AppLogger.info(
      'CacheManager: Project $projectId y datos relacionados invalidados',
    );
  }
}
