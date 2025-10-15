import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/kanban_config.dart';
import '../../domain/entities/task.dart';
import '../constants/storage_keys.dart';
import '../utils/app_logger.dart';

/// Servicio para gestionar la configuración del tablero Kanban
class KanbanPreferencesService {
  KanbanPreferencesService._();

  static final KanbanPreferencesService _instance =
      KanbanPreferencesService._();

  /// Instancia singleton del servicio
  static KanbanPreferencesService get instance => _instance;

  SharedPreferences? _prefs;

  /// Inicializar el servicio
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      AppLogger.info('KanbanPreferencesService: Inicializado correctamente');
    } catch (e) {
      AppLogger.error('KanbanPreferencesService: Error al inicializar', e);
    }
  }

  /// Verificar si el servicio está inicializado
  bool get isInitialized => _prefs != null;

  // ============== WIP LIMITS ==============

  /// Obtiene el WIP limit de una columna
  int? getWipLimit(int projectId, TaskStatus status) {
    if (!isInitialized) return null;

    try {
      final key = _getWipLimitKey(projectId, status);
      return _prefs!.getInt(key);
    } catch (e) {
      AppLogger.error(
        'KanbanPreferencesService: Error al leer WIP limit',
        e,
      );
      return null;
    }
  }

  /// Guarda el WIP limit de una columna
  Future<bool> setWipLimit(
    int projectId,
    TaskStatus status,
    int? wipLimit,
  ) async {
    if (!isInitialized) return false;

    try {
      final key = _getWipLimitKey(projectId, status);
      
      if (wipLimit == null) {
        return await _prefs!.remove(key);
      }
      
      final success = await _prefs!.setInt(key, wipLimit);

      if (success) {
        AppLogger.info(
          'KanbanPreferencesService: WIP limit guardado para ${status.displayName}: $wipLimit',
        );
      }

      return success;
    } catch (e) {
      AppLogger.error(
        'KanbanPreferencesService: Error al guardar WIP limit',
        e,
      );
      return false;
    }
  }

  /// Obtiene todas las configuraciones de columnas para un proyecto
  Map<TaskStatus, KanbanColumnConfig> getColumnConfigs(int projectId) {
    final configs = <TaskStatus, KanbanColumnConfig>{};
    
    for (final status in TaskStatus.values) {
      final wipLimit = getWipLimit(projectId, status);
      configs[status] = KanbanColumnConfig(
        status: status,
        wipLimit: wipLimit,
        showWipAlert: true,
      );
    }
    
    return configs;
  }

  // ============== SWIMLANES ==============

  /// Obtiene si los swimlanes están habilitados
  bool getSwimlanesEnabled(int projectId) {
    if (!isInitialized) return false;

    try {
      final key = _getSwimlanesEnabledKey(projectId);
      return _prefs!.getBool(key) ?? false;
    } catch (e) {
      AppLogger.error(
        'KanbanPreferencesService: Error al leer swimlanes enabled',
        e,
      );
      return false;
    }
  }

  /// Guarda si los swimlanes están habilitados
  Future<bool> setSwimlanesEnabled(int projectId, bool enabled) async {
    if (!isInitialized) return false;

    try {
      final key = _getSwimlanesEnabledKey(projectId);
      final success = await _prefs!.setBool(key, enabled);

      if (success) {
        AppLogger.info(
          'KanbanPreferencesService: Swimlanes ${enabled ? 'habilitados' : 'deshabilitados'}',
        );
      }

      return success;
    } catch (e) {
      AppLogger.error(
        'KanbanPreferencesService: Error al guardar swimlanes enabled',
        e,
      );
      return false;
    }
  }

  /// Obtiene los swimlanes configurados
  List<KanbanSwimlane> getSwimlanes(int projectId) {
    if (!isInitialized) return _getDefaultSwimlanes();

    try {
      final key = _getSwimlanesKey(projectId);
      final jsonString = _prefs!.getString(key);
      
      if (jsonString == null) {
        return _getDefaultSwimlanes();
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => _swimlaneFromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error(
        'KanbanPreferencesService: Error al leer swimlanes',
        e,
      );
      return _getDefaultSwimlanes();
    }
  }

  /// Guarda los swimlanes configurados
  Future<bool> setSwimlanes(
    int projectId,
    List<KanbanSwimlane> swimlanes,
  ) async {
    if (!isInitialized) return false;

    try {
      final key = _getSwimlanesKey(projectId);
      final jsonList = swimlanes.map((s) => _swimlaneToJson(s)).toList();
      final jsonString = json.encode(jsonList);
      
      final success = await _prefs!.setString(key, jsonString);

      if (success) {
        AppLogger.info(
          'KanbanPreferencesService: ${swimlanes.length} swimlanes guardados',
        );
      }

      return success;
    } catch (e) {
      AppLogger.error(
        'KanbanPreferencesService: Error al guardar swimlanes',
        e,
      );
      return false;
    }
  }

  /// Obtiene la configuración completa del tablero
  KanbanBoardConfig getBoardConfig(int projectId) {
    return KanbanBoardConfig(
      columnConfigs: getColumnConfigs(projectId),
      swimlanes: getSwimlanes(projectId),
      swimlanesEnabled: getSwimlanesEnabled(projectId),
    );
  }

  // ============== KEYS ==============

  String _getWipLimitKey(int projectId, TaskStatus status) {
    return '${StorageKeys.kanbanWipLimit}_${projectId}_${status.name}';
  }

  String _getSwimlanesEnabledKey(int projectId) {
    return '${StorageKeys.kanbanSwimlanesEnabled}_$projectId';
  }

  String _getSwimlanesKey(int projectId) {
    return '${StorageKeys.kanbanSwimlanes}_$projectId';
  }

  // ============== DEFAULTS ==============

  List<KanbanSwimlane> _getDefaultSwimlanes() {
    return [
      const KanbanSwimlane(
        id: 'all',
        name: 'Todas las tareas',
        criteria: SwimlaneCriteria(type: SwimlaneCriteriaType.all),
        order: 0,
        isVisible: true,
      ),
    ];
  }

  // ============== SERIALIZATION ==============

  Map<String, dynamic> _swimlaneToJson(KanbanSwimlane swimlane) {
    return {
      'id': swimlane.id,
      'name': swimlane.name,
      'description': swimlane.description,
      'criteriaType': swimlane.criteria.type.name,
      'criteriaValue': swimlane.criteria.value,
      'order': swimlane.order,
      'isVisible': swimlane.isVisible,
    };
  }

  KanbanSwimlane _swimlaneFromJson(Map<String, dynamic> json) {
    final criteriaType = SwimlaneCriteriaType.values.firstWhere(
      (e) => e.name == json['criteriaType'],
      orElse: () => SwimlaneCriteriaType.all,
    );

    return KanbanSwimlane(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      criteria: SwimlaneCriteria(
        type: criteriaType,
        value: json['criteriaValue'],
      ),
      order: json['order'],
      isVisible: json['isVisible'] ?? true,
    );
  }

  // ============== UTILIDADES ==============

  /// Limpia todas las preferencias de Kanban de un proyecto
  Future<bool> clearProjectConfig(int projectId) async {
    if (!isInitialized) return false;

    try {
      final keys = _prefs!.getKeys();
      final projectKeys = keys.where(
        (key) =>
            key.contains('kanban_') && key.contains('_$projectId'),
      );

      for (final key in projectKeys) {
        await _prefs!.remove(key);
      }

      AppLogger.info(
        'KanbanPreferencesService: Configuración del proyecto $projectId limpiada',
      );
      return true;
    } catch (e) {
      AppLogger.error(
        'KanbanPreferencesService: Error al limpiar configuración',
        e,
      );
      return false;
    }
  }
}



