import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/customization_event.dart';
import '../../domain/entities/customization_metrics.dart';
import '../constants/storage_keys.dart';
import '../utils/app_logger.dart';

/// Servicio para registrar y gestionar métricas de personalización de UI
///
/// Funcionalidades:
/// - Registro de eventos de personalización (anónimos)
/// - Agregación de estadísticas
/// - Persistencia local de eventos
/// - Privacidad y anonimización de datos
///
/// Privacidad:
/// - No almacena información personal identificable
/// - Solo guarda tipos de eventos y valores de configuración
/// - Los datos se mantienen en el dispositivo local
class CustomizationMetricsService {
  CustomizationMetricsService._();

  static final CustomizationMetricsService _instance =
      CustomizationMetricsService._();

  /// Instancia singleton del servicio
  static CustomizationMetricsService get instance => _instance;

  SharedPreferences? _prefs;
  List<CustomizationEvent> _events = [];

  /// Número máximo de eventos a almacenar (para evitar crecimiento ilimitado)
  static const int _maxEventsStored = 1000;

  /// Inicializar el servicio cargando SharedPreferences
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadEvents();
      AppLogger.info(
        'CustomizationMetricsService: Inicializado correctamente con ${_events.length} eventos',
      );
    } catch (e) {
      AppLogger.error(
        'CustomizationMetricsService: Error al inicializar',
        e,
      );
    }
  }

  /// Verificar si el servicio está inicializado
  bool get isInitialized => _prefs != null;

  // ============== REGISTRO DE EVENTOS ==============

  /// Registra un evento de cambio de tema
  Future<void> trackThemeChange(String previousTheme, String newTheme) async {
    await _trackEvent(
      CustomizationEvent.anonymized(
        type: CustomizationEventType.themeChanged,
        previousValue: previousTheme,
        newValue: newTheme,
      ),
    );
  }

  /// Registra un evento de cambio de layout
  Future<void> trackLayoutChange(
    String previousLayout,
    String newLayout,
  ) async {
    await _trackEvent(
      CustomizationEvent.anonymized(
        type: CustomizationEventType.layoutChanged,
        previousValue: previousLayout,
        newValue: newLayout,
      ),
    );
  }

  /// Registra un evento de widget añadido
  Future<void> trackWidgetAdded(String widgetType) async {
    await _trackEvent(
      CustomizationEvent.anonymized(
        type: CustomizationEventType.widgetAdded,
        newValue: widgetType,
      ),
    );
  }

  /// Registra un evento de widget eliminado
  Future<void> trackWidgetRemoved(String widgetType) async {
    await _trackEvent(
      CustomizationEvent.anonymized(
        type: CustomizationEventType.widgetRemoved,
        previousValue: widgetType,
      ),
    );
  }

  /// Registra un evento de widgets reordenados
  Future<void> trackWidgetsReordered(List<String> widgetOrder) async {
    await _trackEvent(
      CustomizationEvent.anonymized(
        type: CustomizationEventType.widgetReordered,
        metadata: {'widgetOrder': widgetOrder},
      ),
    );
  }

  /// Registra un evento de reset de dashboard
  Future<void> trackDashboardReset() async {
    await _trackEvent(
      CustomizationEvent.anonymized(
        type: CustomizationEventType.dashboardReset,
      ),
    );
  }

  /// Registra un evento de exportación de preferencias
  Future<void> trackPreferencesExported() async {
    await _trackEvent(
      CustomizationEvent.anonymized(
        type: CustomizationEventType.preferencesExported,
      ),
    );
  }

  /// Registra un evento de importación de preferencias
  Future<void> trackPreferencesImported() async {
    await _trackEvent(
      CustomizationEvent.anonymized(
        type: CustomizationEventType.preferencesImported,
      ),
    );
  }

  /// Registra un evento de personalización
  Future<void> _trackEvent(CustomizationEvent event) async {
    if (!isInitialized) {
      AppLogger.warning(
        'CustomizationMetricsService: Intentando registrar evento sin inicializar',
      );
      return;
    }

    try {
      _events.add(event);

      // Limitar el número de eventos almacenados
      if (_events.length > _maxEventsStored) {
        _events = _events.sublist(_events.length - _maxEventsStored);
      }

      await _saveEvents();

      AppLogger.info(
        'CustomizationMetricsService: Evento registrado - ${event.type.displayName}',
      );
    } catch (e) {
      AppLogger.error(
        'CustomizationMetricsService: Error al registrar evento',
        e,
      );
    }
  }

  // ============== CONSULTA DE MÉTRICAS ==============

  /// Obtiene todos los eventos registrados
  List<CustomizationEvent> getAllEvents() {
    return List.unmodifiable(_events);
  }

  /// Obtiene eventos dentro de un rango de fechas
  List<CustomizationEvent> getEventsBetween(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _events
        .where((e) =>
            e.timestamp.isAfter(startDate) && e.timestamp.isBefore(endDate))
        .toList();
  }

  /// Obtiene eventos de un tipo específico
  List<CustomizationEvent> getEventsByType(CustomizationEventType type) {
    return _events.where((e) => e.type == type).toList();
  }

  /// Genera métricas agregadas
  CustomizationMetrics generateMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    if (_events.isEmpty) {
      return CustomizationMetrics.empty();
    }

    final events = startDate != null && endDate != null
        ? getEventsBetween(startDate, endDate)
        : _events;

    if (events.isEmpty) {
      return CustomizationMetrics.empty();
    }

    // Calcular conteo de tipos de evento
    final eventTypeCount = <String, int>{};
    for (final event in events) {
      eventTypeCount[event.type.name] =
          (eventTypeCount[event.type.name] ?? 0) + 1;
    }

    // Calcular uso de temas
    final themeUsage = _calculateUsageStats(
      events
          .where((e) => e.type == CustomizationEventType.themeChanged)
          .where((e) => e.newValue != null)
          .map((e) => e.newValue!)
          .toList(),
    );

    // Calcular uso de layouts
    final layoutUsage = _calculateUsageStats(
      events
          .where((e) => e.type == CustomizationEventType.layoutChanged)
          .where((e) => e.newValue != null)
          .map((e) => e.newValue!)
          .toList(),
    );

    // Calcular uso de widgets
    final widgetUsage = _calculateUsageStats(
      [
        ...events
            .where((e) => e.type == CustomizationEventType.widgetAdded)
            .where((e) => e.newValue != null)
            .map((e) => e.newValue!),
        ...events
            .where((e) => e.type == CustomizationEventType.widgetRemoved)
            .where((e) => e.previousValue != null)
            .map((e) => e.previousValue!),
      ],
    );

    return CustomizationMetrics(
      totalEvents: events.length,
      totalUsers: 1, // Solo hay un usuario en el dispositivo local
      startDate: startDate ?? events.first.timestamp,
      endDate: endDate ?? events.last.timestamp,
      themeUsage: themeUsage,
      layoutUsage: layoutUsage,
      widgetUsage: widgetUsage,
      eventTypeCount: eventTypeCount,
      lastUpdated: DateTime.now(),
    );
  }

  /// Calcula estadísticas de uso de una lista de items
  List<UsageStats> _calculateUsageStats(List<String> items) {
    if (items.isEmpty) return [];

    final counts = <String, int>{};
    for (final item in items) {
      counts[item] = (counts[item] ?? 0) + 1;
    }

    final total = items.length;
    final stats = counts.entries
        .map(
          (entry) => UsageStats(
            item: entry.key,
            count: entry.value,
            percentage: (entry.value / total) * 100,
          ),
        )
        .toList();

    // Ordenar por uso descendente
    stats.sort((a, b) => b.count.compareTo(a.count));

    return stats;
  }

  // ============== PERSISTENCIA ==============

  /// Carga los eventos desde SharedPreferences
  Future<void> _loadEvents() async {
    if (!isInitialized) return;

    try {
      final eventsJson = _prefs!.getString(StorageKeys.customizationEvents);

      if (eventsJson == null) {
        _events = [];
        return;
      }

      final eventsList = json.decode(eventsJson) as List<dynamic>;
      _events = eventsList
          .map((e) => CustomizationEvent.fromJson(e as Map<String, dynamic>))
          .toList();

      AppLogger.info(
        'CustomizationMetricsService: ${_events.length} eventos cargados',
      );
    } catch (e) {
      AppLogger.error(
        'CustomizationMetricsService: Error al cargar eventos',
        e,
      );
      _events = [];
    }
  }

  /// Guarda los eventos en SharedPreferences
  Future<void> _saveEvents() async {
    if (!isInitialized) return;

    try {
      final eventsJson = json.encode(_events.map((e) => e.toJson()).toList());
      await _prefs!.setString(StorageKeys.customizationEvents, eventsJson);
    } catch (e) {
      AppLogger.error(
        'CustomizationMetricsService: Error al guardar eventos',
        e,
      );
    }
  }

  // ============== UTILIDADES ==============

  /// Limpia todos los eventos registrados
  Future<bool> clearAllEvents() async {
    if (!isInitialized) return false;

    try {
      _events.clear();
      final success = await _prefs!.remove(StorageKeys.customizationEvents);

      if (success) {
        AppLogger.info(
          'CustomizationMetricsService: Todos los eventos eliminados',
        );
      }

      return success;
    } catch (e) {
      AppLogger.error(
        'CustomizationMetricsService: Error al limpiar eventos',
        e,
      );
      return false;
    }
  }

  /// Obtiene el número total de eventos registrados
  int get totalEvents => _events.length;

  /// Obtiene la fecha del primer evento
  DateTime? get firstEventDate =>
      _events.isEmpty ? null : _events.first.timestamp;

  /// Obtiene la fecha del último evento
  DateTime? get lastEventDate =>
      _events.isEmpty ? null : _events.last.timestamp;
}
