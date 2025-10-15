import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/dashboard_widget_config.dart';
import '../constants/storage_keys.dart';
import '../utils/app_logger.dart';
import 'customization_metrics_service.dart';

/// Servicio para gestionar preferencias de widgets del dashboard
///
/// Maneja la persistencia de:
/// - Configuración de widgets (tipo, orden, visibilidad)
/// - Estado de personalización del dashboard
///
/// Utiliza SharedPreferences para persistir datos localmente.
class DashboardPreferencesService {
  DashboardPreferencesService._();

  static final DashboardPreferencesService _instance =
      DashboardPreferencesService._();

  /// Instancia singleton del servicio
  static DashboardPreferencesService get instance => _instance;

  SharedPreferences? _prefs;

  /// Inicializar el servicio cargando SharedPreferences
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      AppLogger.info(
        'DashboardPreferencesService: Inicializado correctamente',
      );
    } catch (e) {
      AppLogger.error(
        'DashboardPreferencesService: Error al inicializar',
        e,
      );
    }
  }

  /// Verificar si el servicio está inicializado
  bool get isInitialized => _prefs != null;

  // ============== DASHBOARD CONFIGURATION ==============

  /// Obtiene la configuración del dashboard guardada
  ///
  /// Si no existe configuración guardada, retorna la configuración por defecto
  DashboardConfig getDashboardConfig() {
    if (!isInitialized) {
      AppLogger.warning(
        'DashboardPreferencesService: Intentando leer sin inicializar',
      );
      return DashboardConfig.defaultConfig();
    }

    try {
      final configJson = _prefs!.getString(StorageKeys.dashboardWidgetConfig);

      if (configJson == null) {
        AppLogger.info(
          'DashboardPreferencesService: No hay configuración guardada, usando default',
        );
        return DashboardConfig.defaultConfig();
      }

      final config = DashboardConfig.fromJson(
        json.decode(configJson) as Map<String, dynamic>,
      );

      AppLogger.info(
        'DashboardPreferencesService: Configuración cargada (${config.widgets.length} widgets)',
      );

      return config;
    } catch (e) {
      AppLogger.error(
        'DashboardPreferencesService: Error al cargar configuración',
        e,
      );
      return DashboardConfig.defaultConfig();
    }
  }

  /// Guarda la configuración del dashboard
  Future<bool> saveDashboardConfig(DashboardConfig config) async {
    if (!isInitialized) {
      AppLogger.warning(
        'DashboardPreferencesService: Intentando escribir sin inicializar',
      );
      return false;
    }

    try {
      final configJson = json.encode(config.toJson());
      final success = await _prefs!.setString(
        StorageKeys.dashboardWidgetConfig,
        configJson,
      );

      if (success) {
        AppLogger.info(
          'DashboardPreferencesService: Configuración guardada (${config.widgets.length} widgets)',
        );
      }

      return success;
    } catch (e) {
      AppLogger.error(
        'DashboardPreferencesService: Error al guardar configuración',
        e,
      );
      return false;
    }
  }

  /// Resetea la configuración del dashboard a los valores por defecto
  Future<bool> resetDashboardConfig() async {
    if (!isInitialized) {
      AppLogger.warning(
        'DashboardPreferencesService: Intentando resetear sin inicializar',
      );
      return false;
    }

    try {
      final defaultConfig = DashboardConfig.defaultConfig();
      final success = await saveDashboardConfig(defaultConfig);

      if (success) {
        AppLogger.info(
          'DashboardPreferencesService: Configuración reseteada a default',
        );
        // Track metrics
        await CustomizationMetricsService.instance.trackDashboardReset();
      }

      return success;
    } catch (e) {
      AppLogger.error(
        'DashboardPreferencesService: Error al resetear configuración',
        e,
      );
      return false;
    }
  }

  /// Actualiza el orden de los widgets
  Future<bool> updateWidgetOrder(List<DashboardWidgetConfig> widgets) async {
    final currentConfig = getDashboardConfig();
    final updatedWidgets = <DashboardWidgetConfig>[];

    // Actualizar posiciones
    for (var i = 0; i < widgets.length; i++) {
      updatedWidgets.add(widgets[i].copyWith(position: i));
    }

    final newConfig = currentConfig.copyWith(
      widgets: updatedWidgets,
      lastModified: DateTime.now(),
    );

    final success = await saveDashboardConfig(newConfig);

    // Track metrics
    if (success) {
      await CustomizationMetricsService.instance.trackWidgetsReordered(
        widgets.map((w) => w.type.name).toList(),
      );
    }

    return success;
  }

  /// Añade un widget al dashboard
  Future<bool> addWidget(DashboardWidgetType type) async {
    final currentConfig = getDashboardConfig();

    // Verificar si el widget ya existe
    final exists = currentConfig.widgets.any((w) => w.type == type);
    if (exists) {
      AppLogger.warning(
        'DashboardPreferencesService: Widget ${type.name} ya existe',
      );
      return false;
    }

    final newWidget = DashboardWidgetConfig.defaultForType(
      type,
      currentConfig.widgets.length,
    );

    final newConfig = currentConfig.copyWith(
      widgets: [...currentConfig.widgets, newWidget],
      lastModified: DateTime.now(),
    );

    final success = await saveDashboardConfig(newConfig);

    // Track metrics
    if (success) {
      await CustomizationMetricsService.instance.trackWidgetAdded(type.name);
    }

    return success;
  }

  /// Elimina un widget del dashboard
  Future<bool> removeWidget(String widgetId) async {
    final currentConfig = getDashboardConfig();

    // Find the widget to track its type before removal
    final widgetToRemove = currentConfig.widgets
        .where((w) => w.id == widgetId)
        .firstOrNull;

    final updatedWidgets = currentConfig.widgets
        .where((w) => w.id != widgetId)
        .toList();

    // Reordenar posiciones
    for (var i = 0; i < updatedWidgets.length; i++) {
      updatedWidgets[i] = updatedWidgets[i].copyWith(position: i);
    }

    final newConfig = currentConfig.copyWith(
      widgets: updatedWidgets,
      lastModified: DateTime.now(),
    );

    final success = await saveDashboardConfig(newConfig);

    // Track metrics
    if (success && widgetToRemove != null) {
      await CustomizationMetricsService.instance.trackWidgetRemoved(
        widgetToRemove.type.name,
      );
    }

    return success;
  }

  /// Alterna la visibilidad de un widget
  Future<bool> toggleWidgetVisibility(String widgetId) async {
    final currentConfig = getDashboardConfig();

    final updatedWidgets = currentConfig.widgets.map((w) {
      if (w.id == widgetId) {
        return w.copyWith(isVisible: !w.isVisible);
      }
      return w;
    }).toList();

    final newConfig = currentConfig.copyWith(
      widgets: updatedWidgets,
      lastModified: DateTime.now(),
    );

    return saveDashboardConfig(newConfig);
  }

  /// Obtiene los tipos de widgets disponibles para añadir
  List<DashboardWidgetType> getAvailableWidgetTypes() {
    final currentConfig = getDashboardConfig();
    final usedTypes = currentConfig.widgets.map((w) => w.type).toSet();

    return DashboardWidgetType.values
        .where((type) => !usedTypes.contains(type))
        .toList();
  }
}



