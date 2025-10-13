import 'dart:convert';

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
}
