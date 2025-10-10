import 'package:shared_preferences/shared_preferences.dart';

import '../constants/view_constants.dart';
import '../utils/app_logger.dart';

/// Servicio para gestionar preferencias de vista del usuario
///
/// Maneja la persistencia de:
/// - Densidad de vista de proyectos (compacta/cómoda)
/// - Estado de secciones colapsables (expandidas/colapsadas)
/// - Otras preferencias de UI
///
/// Utiliza SharedPreferences para persistir datos localmente.
class ViewPreferencesService {
  ViewPreferencesService._();

  static final ViewPreferencesService _instance = ViewPreferencesService._();

  /// Instancia singleton del servicio
  static ViewPreferencesService get instance => _instance;

  SharedPreferences? _prefs;

  /// Inicializar el servicio cargando SharedPreferences
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      AppLogger.info('ViewPreferencesService: Inicializado correctamente');
    } catch (e) {
      AppLogger.error('ViewPreferencesService: Error al inicializar', e);
    }
  }

  /// Verificar si el servicio está inicializado
  bool get isInitialized => _prefs != null;

  // ============== DENSIDAD DE VISTA ==============

  /// Obtiene la densidad de vista guardada
  ///
  /// Por defecto retorna [ProjectViewDensity.compact]
  ProjectViewDensity getProjectViewDensity() {
    if (!isInitialized) {
      AppLogger.warning(
        'ViewPreferencesService: Intentando leer sin inicializar',
      );
      return ProjectViewDensity.compact;
    }

    try {
      final value = _prefs!.getString(ViewConstants.prefKeyViewDensity);

      if (value == null) {
        return ProjectViewDensity.compact;
      }

      // Convertir string a enum
      return ProjectViewDensity.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ProjectViewDensity.compact,
      );
    } catch (e) {
      AppLogger.error('ViewPreferencesService: Error al leer densidad', e);
      return ProjectViewDensity.compact;
    }
  }

  /// Guarda la densidad de vista
  Future<bool> setProjectViewDensity(ProjectViewDensity density) async {
    if (!isInitialized) {
      AppLogger.warning(
        'ViewPreferencesService: Intentando escribir sin inicializar',
      );
      return false;
    }

    try {
      final success = await _prefs!.setString(
        ViewConstants.prefKeyViewDensity,
        density.name,
      );

      if (success) {
        AppLogger.info(
          'ViewPreferencesService: Densidad guardada: ${density.label}',
        );
      }

      return success;
    } catch (e) {
      AppLogger.error('ViewPreferencesService: Error al guardar densidad', e);
      return false;
    }
  }

  // ============== SECCIONES COLAPSABLES ==============

  /// Obtiene si una sección está expandida
  ///
  /// [key] identificador único de la sección
  /// [defaultValue] valor por defecto si no hay preferencia guardada
  bool getSectionExpanded(String key, {bool defaultValue = true}) {
    if (!isInitialized) {
      return defaultValue;
    }

    try {
      final storageKey = _getSectionStorageKey(key);
      final value = _prefs!.getBool(storageKey);

      return value ?? defaultValue;
    } catch (e) {
      AppLogger.error(
        'ViewPreferencesService: Error al leer estado de sección $key',
        e,
      );
      return defaultValue;
    }
  }

  /// Guarda si una sección está expandida
  ///
  /// [key] identificador único de la sección
  /// [expanded] true si está expandida, false si está colapsada
  Future<bool> setSectionExpanded(String key, bool expanded) async {
    if (!isInitialized) {
      AppLogger.warning(
        'ViewPreferencesService: Intentando escribir sección sin inicializar',
      );
      return false;
    }

    try {
      final storageKey = _getSectionStorageKey(key);
      final success = await _prefs!.setBool(storageKey, expanded);

      if (success) {
        AppLogger.debug(
          'ViewPreferencesService: Estado sección "$key": $expanded',
        );
      }

      return success;
    } catch (e) {
      AppLogger.error(
        'ViewPreferencesService: Error al guardar estado de sección $key',
        e,
      );
      return false;
    }
  }

  /// Genera la key de storage para una sección
  String _getSectionStorageKey(String key) {
    return '${ViewConstants.prefKeyCollapsedSectionPrefix}$key';
  }

  // ============== UTILIDADES ==============

  /// Limpia todas las preferencias de vista
  Future<bool> clearAll() async {
    if (!isInitialized) {
      return false;
    }

    try {
      // Obtener todas las keys
      final keys = _prefs!.getKeys();

      // Filtrar solo las keys de preferencias de vista
      final viewKeys = keys.where(
        (key) =>
            key == ViewConstants.prefKeyViewDensity ||
            key.startsWith(ViewConstants.prefKeyCollapsedSectionPrefix),
      );

      // Eliminar cada key
      for (final key in viewKeys) {
        await _prefs!.remove(key);
      }

      AppLogger.info(
        'ViewPreferencesService: Todas las preferencias limpiadas',
      );
      return true;
    } catch (e) {
      AppLogger.error(
        'ViewPreferencesService: Error al limpiar preferencias',
        e,
      );
      return false;
    }
  }

  /// Resetea la densidad de vista al valor por defecto
  Future<bool> resetDensity() async {
    return setProjectViewDensity(ProjectViewDensity.compact);
  }

  /// Resetea todas las secciones al estado por defecto (expandidas)
  Future<bool> resetSections() async {
    if (!isInitialized) {
      return false;
    }

    try {
      final keys = _prefs!.getKeys();
      final sectionKeys = keys.where(
        (key) => key.startsWith(ViewConstants.prefKeyCollapsedSectionPrefix),
      );

      for (final key in sectionKeys) {
        await _prefs!.remove(key);
      }

      AppLogger.info('ViewPreferencesService: Secciones reseteadas');
      return true;
    } catch (e) {
      AppLogger.error('ViewPreferencesService: Error al resetear secciones', e);
      return false;
    }
  }

  /// Obtiene un resumen de las preferencias actuales (para debug)
  Map<String, dynamic> getPreferencesSummary() {
    if (!isInitialized) {
      return {'initialized': false};
    }

    try {
      final keys = _prefs!.getKeys();
      final viewKeys = keys.where(
        (key) =>
            key == ViewConstants.prefKeyViewDensity ||
            key.startsWith(ViewConstants.prefKeyCollapsedSectionPrefix),
      );

      final summary = <String, dynamic>{
        'initialized': true,
        'density': getProjectViewDensity().label,
        'sections': <String, bool>{},
      };

      for (final key in viewKeys) {
        if (key.startsWith(ViewConstants.prefKeyCollapsedSectionPrefix)) {
          final sectionName = key.replaceFirst(
            ViewConstants.prefKeyCollapsedSectionPrefix,
            '',
          );
          summary['sections'][sectionName] = _prefs!.getBool(key) ?? true;
        }
      }

      return summary;
    } catch (e) {
      AppLogger.error('ViewPreferencesService: Error al obtener resumen', e);
      return {'initialized': true, 'error': e.toString()};
    }
  }
}
