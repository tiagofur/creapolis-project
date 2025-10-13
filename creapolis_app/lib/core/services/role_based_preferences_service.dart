import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/dashboard_widget_config.dart';
import '../../domain/entities/role_based_ui_config.dart';
import '../../domain/entities/user.dart';
import '../constants/storage_keys.dart';
import '../utils/app_logger.dart';

/// Servicio para gestionar preferencias de UI basadas en roles
///
/// Maneja:
/// - Configuración base por rol (admin, projectManager, teamMember)
/// - Overrides personales de usuario sobre la configuración del rol
/// - Persistencia de overrides en SharedPreferences
///
/// Flujo de uso:
/// 1. Al login, cargar preferencias del usuario con su rol
/// 2. Aplicar configuración base del rol
/// 3. Aplicar overrides personales si existen
/// 4. Permitir al usuario personalizar (crear overrides)
/// 5. Opción de resetear a defaults del rol
class RoleBasedPreferencesService {
  RoleBasedPreferencesService._();

  static final RoleBasedPreferencesService _instance =
      RoleBasedPreferencesService._();

  /// Instancia singleton del servicio
  static RoleBasedPreferencesService get instance => _instance;

  SharedPreferences? _prefs;
  UserUIPreferences? _currentUserPreferences;

  /// Inicializar el servicio cargando SharedPreferences
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      AppLogger.info(
        'RoleBasedPreferencesService: Inicializado correctamente',
      );
    } catch (e) {
      AppLogger.error(
        'RoleBasedPreferencesService: Error al inicializar',
        e,
      );
    }
  }

  /// Verificar si el servicio está inicializado
  bool get isInitialized => _prefs != null;

  /// Obtiene las preferencias actuales del usuario
  UserUIPreferences? get currentUserPreferences => _currentUserPreferences;

  // ============== GESTIÓN DE PREFERENCIAS DE USUARIO ==============

  /// Carga las preferencias del usuario basadas en su rol
  ///
  /// Si no existen preferencias guardadas, usa la configuración base del rol
  Future<UserUIPreferences> loadUserPreferences(UserRole userRole) async {
    if (!isInitialized) {
      AppLogger.warning(
        'RoleBasedPreferencesService: Intentando leer sin inicializar',
      );
      _currentUserPreferences = UserUIPreferences(userRole: userRole);
      return _currentUserPreferences!;
    }

    try {
      final prefsJson = _prefs!.getString(StorageKeys.roleBasedUIPreferences);

      if (prefsJson == null) {
        AppLogger.info(
          'RoleBasedPreferencesService: No hay preferencias guardadas para rol ${userRole.name}, usando defaults',
        );
        _currentUserPreferences = UserUIPreferences(userRole: userRole);
        return _currentUserPreferences!;
      }

      final prefs = UserUIPreferences.fromJson(
        json.decode(prefsJson) as Map<String, dynamic>,
      );

      // Verificar que el rol coincide, si no, usar defaults del nuevo rol
      if (prefs.userRole != userRole) {
        AppLogger.info(
          'RoleBasedPreferencesService: Rol cambió de ${prefs.userRole.name} a ${userRole.name}, usando defaults del nuevo rol',
        );
        _currentUserPreferences = UserUIPreferences(userRole: userRole);
        await saveUserPreferences(_currentUserPreferences!);
      } else {
        _currentUserPreferences = prefs;
      }

      AppLogger.info(
        'RoleBasedPreferencesService: Preferencias cargadas para rol ${userRole.name}',
      );
      AppLogger.info(
        '  - Theme override: ${_currentUserPreferences!.hasThemeOverride}',
      );
      AppLogger.info(
        '  - Layout override: ${_currentUserPreferences!.hasLayoutOverride}',
      );
      AppLogger.info(
        '  - Dashboard override: ${_currentUserPreferences!.hasDashboardOverride}',
      );

      return _currentUserPreferences!;
    } catch (e) {
      AppLogger.error(
        'RoleBasedPreferencesService: Error al cargar preferencias',
        e,
      );
      _currentUserPreferences = UserUIPreferences(userRole: userRole);
      return _currentUserPreferences!;
    }
  }

  /// Guarda las preferencias del usuario
  Future<bool> saveUserPreferences(UserUIPreferences preferences) async {
    if (!isInitialized) {
      AppLogger.warning(
        'RoleBasedPreferencesService: Intentando escribir sin inicializar',
      );
      return false;
    }

    try {
      final prefsJson = json.encode(preferences.toJson());
      final success = await _prefs!.setString(
        StorageKeys.roleBasedUIPreferences,
        prefsJson,
      );

      if (success) {
        _currentUserPreferences = preferences;
        AppLogger.info(
          'RoleBasedPreferencesService: Preferencias guardadas para rol ${preferences.userRole.name}',
        );
      }

      return success;
    } catch (e) {
      AppLogger.error(
        'RoleBasedPreferencesService: Error al guardar preferencias',
        e,
      );
      return false;
    }
  }

  // ============== OVERRIDES DE TEMA ==============

  /// Establece un override de tema para el usuario
  Future<bool> setThemeOverride(String themeMode) async {
    if (_currentUserPreferences == null) {
      AppLogger.warning(
        'RoleBasedPreferencesService: No hay preferencias cargadas',
      );
      return false;
    }

    final updatedPrefs = _currentUserPreferences!.copyWith(
      themeModeOverride: themeMode,
    );

    return saveUserPreferences(updatedPrefs);
  }

  /// Elimina el override de tema (vuelve al default del rol)
  Future<bool> clearThemeOverride() async {
    if (_currentUserPreferences == null) {
      AppLogger.warning(
        'RoleBasedPreferencesService: No hay preferencias cargadas',
      );
      return false;
    }

    final updatedPrefs = _currentUserPreferences!.copyWith(
      clearThemeOverride: true,
    );

    return saveUserPreferences(updatedPrefs);
  }

  // ============== OVERRIDES DE LAYOUT ==============

  /// Establece un override de layout para el usuario
  Future<bool> setLayoutOverride(String layoutType) async {
    if (_currentUserPreferences == null) {
      AppLogger.warning(
        'RoleBasedPreferencesService: No hay preferencias cargadas',
      );
      return false;
    }

    final updatedPrefs = _currentUserPreferences!.copyWith(
      layoutTypeOverride: layoutType,
    );

    return saveUserPreferences(updatedPrefs);
  }

  /// Elimina el override de layout (vuelve al default del rol)
  Future<bool> clearLayoutOverride() async {
    if (_currentUserPreferences == null) {
      AppLogger.warning(
        'RoleBasedPreferencesService: No hay preferencias cargadas',
      );
      return false;
    }

    final updatedPrefs = _currentUserPreferences!.copyWith(
      clearLayoutOverride: true,
    );

    return saveUserPreferences(updatedPrefs);
  }

  // ============== OVERRIDES DE DASHBOARD ==============

  /// Establece un override de dashboard para el usuario
  Future<bool> setDashboardOverride(DashboardConfig config) async {
    if (_currentUserPreferences == null) {
      AppLogger.warning(
        'RoleBasedPreferencesService: No hay preferencias cargadas',
      );
      return false;
    }

    final updatedPrefs = _currentUserPreferences!.copyWith(
      dashboardConfigOverride: config,
    );

    return saveUserPreferences(updatedPrefs);
  }

  /// Elimina el override de dashboard (vuelve al default del rol)
  Future<bool> clearDashboardOverride() async {
    if (_currentUserPreferences == null) {
      AppLogger.warning(
        'RoleBasedPreferencesService: No hay preferencias cargadas',
      );
      return false;
    }

    final updatedPrefs = _currentUserPreferences!.copyWith(
      clearDashboardOverride: true,
    );

    return saveUserPreferences(updatedPrefs);
  }

  // ============== RESETEO COMPLETO ==============

  /// Resetea todas las preferencias a los defaults del rol
  Future<bool> resetToRoleDefaults() async {
    if (_currentUserPreferences == null) {
      AppLogger.warning(
        'RoleBasedPreferencesService: No hay preferencias cargadas',
      );
      return false;
    }

    final defaultPrefs = UserUIPreferences(
      userRole: _currentUserPreferences!.userRole,
    );

    return saveUserPreferences(defaultPrefs);
  }

  // ============== INFORMACIÓN DEL ROL ==============

  /// Obtiene la configuración base del rol actual
  RoleBasedUIConfig? getRoleBaseConfig() {
    if (_currentUserPreferences == null) {
      return null;
    }

    return RoleBasedUIConfig.forRole(_currentUserPreferences!.userRole);
  }

  /// Obtiene la configuración efectiva de tema
  String? getEffectiveThemeMode() {
    return _currentUserPreferences?.getEffectiveThemeMode();
  }

  /// Obtiene la configuración efectiva de layout
  String? getEffectiveLayoutType() {
    return _currentUserPreferences?.getEffectiveLayoutType();
  }

  /// Obtiene la configuración efectiva de dashboard
  DashboardConfig? getEffectiveDashboardConfig() {
    return _currentUserPreferences?.getEffectiveDashboardConfig();
  }

  /// Limpia las preferencias (útil al hacer logout)
  Future<bool> clearAllPreferences() async {
    if (!isInitialized) {
      return false;
    }

    try {
      final success =
          await _prefs!.remove(StorageKeys.roleBasedUIPreferences);
      if (success) {
        _currentUserPreferences = null;
        AppLogger.info(
          'RoleBasedPreferencesService: Todas las preferencias eliminadas',
        );
      }
      return success;
    } catch (e) {
      AppLogger.error(
        'RoleBasedPreferencesService: Error al limpiar preferencias',
        e,
      );
      return false;
    }
  }

  // ============== EXPORTACIÓN E IMPORTACIÓN ==============

  /// Exporta las preferencias actuales a un archivo JSON
  ///
  /// Retorna la ruta del archivo creado o null si hay error
  Future<String?> exportPreferences() async {
    if (_currentUserPreferences == null) {
      AppLogger.warning(
        'RoleBasedPreferencesService: No hay preferencias para exportar',
      );
      return null;
    }

    try {
      // Obtener el directorio de documentos
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'creapolis_preferences_$timestamp.json';
      final filePath = '${directory.path}/$fileName';

      // Crear el contenido JSON
      final exportData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'preferences': _currentUserPreferences!.toJson(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // Escribir al archivo
      final file = File(filePath);
      await file.writeAsString(jsonString);

      AppLogger.info(
        'RoleBasedPreferencesService: Preferencias exportadas a $filePath',
      );

      return filePath;
    } catch (e) {
      AppLogger.error(
        'RoleBasedPreferencesService: Error al exportar preferencias',
        e,
      );
      return null;
    }
  }

  /// Importa preferencias desde un archivo JSON
  ///
  /// [filePath] - Ruta del archivo JSON a importar
  /// Retorna true si la importación fue exitosa
  Future<bool> importPreferences(String filePath) async {
    if (!isInitialized) {
      AppLogger.warning(
        'RoleBasedPreferencesService: Intentando importar sin inicializar',
      );
      return false;
    }

    try {
      // Leer el archivo
      final file = File(filePath);
      if (!await file.exists()) {
        AppLogger.warning(
          'RoleBasedPreferencesService: Archivo no existe: $filePath',
        );
        return false;
      }

      final jsonString = await file.readAsString();
      final importData = json.decode(jsonString) as Map<String, dynamic>;

      // Validar estructura del archivo
      if (!importData.containsKey('preferences')) {
        AppLogger.warning(
          'RoleBasedPreferencesService: Archivo JSON inválido - falta campo preferences',
        );
        return false;
      }

      // Parsear preferencias
      final preferences = UserUIPreferences.fromJson(
        importData['preferences'] as Map<String, dynamic>,
      );

      // Guardar las preferencias importadas
      final success = await saveUserPreferences(preferences);

      if (success) {
        AppLogger.info(
          'RoleBasedPreferencesService: Preferencias importadas correctamente desde $filePath',
        );
      }

      return success;
    } catch (e) {
      AppLogger.error(
        'RoleBasedPreferencesService: Error al importar preferencias',
        e,
      );
      return false;
    }
  }

  /// Obtiene las preferencias actuales como String JSON para compartir
  ///
  /// Útil para copiar/pegar o compartir por otros medios
  String? getPreferencesAsJson() {
    if (_currentUserPreferences == null) {
      return null;
    }

    try {
      final exportData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'preferences': _currentUserPreferences!.toJson(),
      };

      return const JsonEncoder.withIndent('  ').convert(exportData);
    } catch (e) {
      AppLogger.error(
        'RoleBasedPreferencesService: Error al convertir preferencias a JSON',
        e,
      );
      return null;
    }
  }

  /// Importa preferencias desde un String JSON
  ///
  /// [jsonString] - String JSON con las preferencias
  /// Retorna true si la importación fue exitosa
  Future<bool> importPreferencesFromJson(String jsonString) async {
    if (!isInitialized) {
      AppLogger.warning(
        'RoleBasedPreferencesService: Intentando importar sin inicializar',
      );
      return false;
    }

    try {
      final importData = json.decode(jsonString) as Map<String, dynamic>;

      // Validar estructura
      if (!importData.containsKey('preferences')) {
        AppLogger.warning(
          'RoleBasedPreferencesService: JSON inválido - falta campo preferences',
        );
        return false;
      }

      // Parsear preferencias
      final preferences = UserUIPreferences.fromJson(
        importData['preferences'] as Map<String, dynamic>,
      );

      // Guardar las preferencias importadas
      final success = await saveUserPreferences(preferences);

      if (success) {
        AppLogger.info(
          'RoleBasedPreferencesService: Preferencias importadas correctamente desde JSON',
        );
      }

      return success;
    } catch (e) {
      AppLogger.error(
        'RoleBasedPreferencesService: Error al importar preferencias desde JSON',
        e,
      );
      return false;
    }
  }
}
