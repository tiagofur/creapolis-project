import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/hive/hive_workspace.dart';
import '../../data/models/hive/hive_project.dart';
import '../../data/models/hive/hive_task.dart';
import '../../data/models/hive/hive_operation_queue.dart';
import '../utils/app_logger.dart';

/// Manager para inicialización y gestión de Hive
/// Configura la base de datos local para soporte offline
class HiveManager {
  // Nombres de los boxes
  static const String workspacesBox = 'workspaces';
  static const String projectsBox = 'projects';
  static const String tasksBox = 'tasks';
  static const String operationQueueBox = 'operation_queue';
  static const String cacheMetadataBox = 'cache_metadata';

  static bool _isInitialized = false;

  /// Inicializar Hive y abrir todos los boxes necesarios
  static Future<void> init() async {
    if (_isInitialized) {
      AppLogger.info('HiveManager: Ya inicializado, skip');
      return;
    }

    try {
      AppLogger.info('HiveManager: Inicializando Hive...');

      // 1. Inicializar Hive para Flutter
      await Hive.initFlutter();
      AppLogger.info('HiveManager: Hive.initFlutter() completado');

      // 2. Registrar adapters
      _registerAdapters();
      AppLogger.info('HiveManager: Adapters registrados');

      // 3. Abrir boxes
      await _openBoxes();
      AppLogger.info('HiveManager: Boxes abiertos');

      _isInitialized = true;
      AppLogger.info('HiveManager: ✅ Inicialización completada');
    } catch (e, stackTrace) {
      AppLogger.error('HiveManager: ❌ Error en inicialización', e, stackTrace);
      rethrow;
    }
  }

  /// Registrar todos los TypeAdapters de Hive
  static void _registerAdapters() {
    // Solo registrar si no están registrados
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HiveWorkspaceAdapter());
      AppLogger.info(
        'HiveManager: HiveWorkspaceAdapter registrado (typeId: 0)',
      );
    }

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(HiveProjectAdapter());
      AppLogger.info('HiveManager: HiveProjectAdapter registrado (typeId: 1)');
    }

    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(HiveTaskAdapter());
      AppLogger.info('HiveManager: HiveTaskAdapter registrado (typeId: 2)');
    }

    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(HiveOperationQueueAdapter());
      AppLogger.info(
        'HiveManager: HiveOperationQueueAdapter registrado (typeId: 10)',
      );
    }
  }

  /// Abrir todos los boxes necesarios
  static Future<void> _openBoxes() async {
    try {
      // Workspaces
      if (!Hive.isBoxOpen(workspacesBox)) {
        await Hive.openBox<HiveWorkspace>(workspacesBox);
        AppLogger.info('HiveManager: Box "$workspacesBox" abierto');
      }

      // Projects
      if (!Hive.isBoxOpen(projectsBox)) {
        await Hive.openBox<HiveProject>(projectsBox);
        AppLogger.info('HiveManager: Box "$projectsBox" abierto');
      }

      // Tasks
      if (!Hive.isBoxOpen(tasksBox)) {
        await Hive.openBox<HiveTask>(tasksBox);
        AppLogger.info('HiveManager: Box "$tasksBox" abierto');
      }

      // Operation Queue
      if (!Hive.isBoxOpen(operationQueueBox)) {
        await Hive.openBox<HiveOperationQueue>(operationQueueBox);
        AppLogger.info('HiveManager: Box "$operationQueueBox" abierto');
      }

      // Cache Metadata (no tipado - guarda timestamps)
      if (!Hive.isBoxOpen(cacheMetadataBox)) {
        await Hive.openBox(cacheMetadataBox);
        AppLogger.info('HiveManager: Box "$cacheMetadataBox" abierto');
      }
    } catch (e, stackTrace) {
      AppLogger.error('HiveManager: Error abriendo boxes', e, stackTrace);
      rethrow;
    }
  }

  /// Obtener box de workspaces
  static Box<HiveWorkspace> get workspaces {
    if (!Hive.isBoxOpen(workspacesBox)) {
      throw HiveError('Box "$workspacesBox" no está abierto');
    }
    return Hive.box<HiveWorkspace>(workspacesBox);
  }

  /// Obtener box de projects
  static Box<HiveProject> get projects {
    if (!Hive.isBoxOpen(projectsBox)) {
      throw HiveError('Box "$projectsBox" no está abierto');
    }
    return Hive.box<HiveProject>(projectsBox);
  }

  /// Obtener box de tasks
  static Box<HiveTask> get tasks {
    if (!Hive.isBoxOpen(tasksBox)) {
      throw HiveError('Box "$tasksBox" no está abierto');
    }
    return Hive.box<HiveTask>(tasksBox);
  }

  /// Obtener box de operation queue
  static Box<HiveOperationQueue> get operationQueue {
    if (!Hive.isBoxOpen(operationQueueBox)) {
      throw HiveError('Box "$operationQueueBox" no está abierto');
    }
    return Hive.box<HiveOperationQueue>(operationQueueBox);
  }

  /// Obtener box de cache metadata
  static Box get cacheMetadata {
    if (!Hive.isBoxOpen(cacheMetadataBox)) {
      throw HiveError('Box "$cacheMetadataBox" no está abierto');
    }
    return Hive.box(cacheMetadataBox);
  }

  /// Cerrar todos los boxes (útil para testing)
  static Future<void> closeAllBoxes() async {
    try {
      await Hive.close();
      _isInitialized = false;
      AppLogger.info('HiveManager: Todos los boxes cerrados');
    } catch (e, stackTrace) {
      AppLogger.error('HiveManager: Error cerrando boxes', e, stackTrace);
    }
  }

  /// Limpiar todos los datos (útil para logout o testing)
  static Future<void> clearAllData() async {
    try {
      AppLogger.info('HiveManager: Limpiando todos los datos...');

      await workspaces.clear();
      await projects.clear();
      await tasks.clear();
      await operationQueue.clear();
      await cacheMetadata.clear();

      AppLogger.info('HiveManager: ✅ Todos los datos limpiados');
    } catch (e, stackTrace) {
      AppLogger.error('HiveManager: Error limpiando datos', e, stackTrace);
    }
  }

  /// Obtener estadísticas de uso de caché
  static Future<Map<String, int>> getCacheStats() async {
    try {
      return {
        'workspaces': workspaces.length,
        'projects': projects.length,
        'tasks': tasks.length,
        'operationQueue': operationQueue.length,
        'cacheMetadata': cacheMetadata.length,
      };
    } catch (e) {
      AppLogger.error('HiveManager: Error obteniendo stats', e);
      return {};
    }
  }

  /// Verificar si Hive está inicializado
  static bool get isInitialized => _isInitialized;
}



