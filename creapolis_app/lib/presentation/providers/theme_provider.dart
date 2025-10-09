import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/utils/app_logger.dart';

/// Enum para los modos de tema disponibles
enum AppThemeMode {
  light,
  dark,
  system;

  String get name {
    switch (this) {
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
      case AppThemeMode.system:
        return 'system';
    }
  }

  static AppThemeMode fromString(String value) {
    switch (value) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
        return AppThemeMode.system;
      default:
        return AppThemeMode.system;
    }
  }

  ThemeMode toThemeMode() {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

/// Enum para las paletas de colores disponibles
enum ColorPalette {
  defaultPalette,
  // Futuras paletas se pueden agregar aquí
  // oceanBlue,
  // forestGreen,
  // sunset,
}

/// Enum para los tipos de layout disponibles
enum LayoutType {
  sidebar,
  bottomNavigation,
  // Futuros layouts se pueden agregar aquí
}

/// Provider para gestionar el tema y layout de la aplicación
/// Persiste las preferencias del usuario y notifica cambios
@injectable
class ThemeProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  AppThemeMode _themeMode;
  ColorPalette _colorPalette;
  LayoutType _layoutType;
  bool _isLoading = false;

  ThemeProvider(this._prefs)
      : _themeMode = AppThemeMode.system,
        _colorPalette = ColorPalette.defaultPalette,
        _layoutType = LayoutType.bottomNavigation {
    _loadPreferences();
  }

  // Getters
  AppThemeMode get themeMode => _themeMode;
  ColorPalette get colorPalette => _colorPalette;
  LayoutType get layoutType => _layoutType;
  bool get isLoading => _isLoading;

  ThemeMode get effectiveThemeMode => _themeMode.toThemeMode();

  bool get isDarkMode => _themeMode == AppThemeMode.dark;
  bool get isLightMode => _themeMode == AppThemeMode.light;
  bool get isSystemMode => _themeMode == AppThemeMode.system;

  /// Cargar preferencias guardadas
  Future<void> _loadPreferences() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Cargar tema
      final themeModeString = _prefs.getString(StorageKeys.themeMode);
      if (themeModeString != null) {
        _themeMode = AppThemeMode.fromString(themeModeString);
        AppLogger.info('[ThemeProvider] Tema cargado: ${_themeMode.name}');
      }

      // Cargar paleta de colores
      final colorPaletteString = _prefs.getString(StorageKeys.colorPalette);
      if (colorPaletteString != null) {
        final paletteIndex = int.tryParse(colorPaletteString) ?? 0;
        _colorPalette = ColorPalette.values[paletteIndex];
        AppLogger.info('[ThemeProvider] Paleta cargada: $_colorPalette');
      }

      // Cargar tipo de layout
      final layoutTypeString = _prefs.getString(StorageKeys.layoutType);
      if (layoutTypeString != null) {
        final layoutIndex = int.tryParse(layoutTypeString) ?? 1;
        _layoutType = LayoutType.values[layoutIndex];
        AppLogger.info('[ThemeProvider] Layout cargado: $_layoutType');
      }
    } catch (e) {
      AppLogger.error('[ThemeProvider] Error al cargar preferencias: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cambiar modo de tema
  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    try {
      await _prefs.setString(StorageKeys.themeMode, mode.name);
      AppLogger.info('[ThemeProvider] Tema guardado: ${mode.name}');
    } catch (e) {
      AppLogger.error('[ThemeProvider] Error al guardar tema: $e');
    }
  }

  /// Cambiar paleta de colores
  Future<void> setColorPalette(ColorPalette palette) async {
    if (_colorPalette == palette) return;

    _colorPalette = palette;
    notifyListeners();

    try {
      await _prefs.setString(StorageKeys.colorPalette, palette.index.toString());
      AppLogger.info('[ThemeProvider] Paleta guardada: $palette');
    } catch (e) {
      AppLogger.error('[ThemeProvider] Error al guardar paleta: $e');
    }
  }

  /// Cambiar tipo de layout
  Future<void> setLayoutType(LayoutType layout) async {
    if (_layoutType == layout) return;

    _layoutType = layout;
    notifyListeners();

    try {
      await _prefs.setString(StorageKeys.layoutType, layout.index.toString());
      AppLogger.info('[ThemeProvider] Layout guardado: $layout');
    } catch (e) {
      AppLogger.error('[ThemeProvider] Error al guardar layout: $e');
    }
  }

  /// Alternar entre modo claro y oscuro
  Future<void> toggleTheme() async {
    final newMode = _themeMode == AppThemeMode.light
        ? AppThemeMode.dark
        : AppThemeMode.light;
    await setThemeMode(newMode);
  }

  /// Resetear preferencias a valores por defecto
  Future<void> resetToDefaults() async {
    await setThemeMode(AppThemeMode.system);
    await setColorPalette(ColorPalette.defaultPalette);
    await setLayoutType(LayoutType.bottomNavigation);
    AppLogger.info('[ThemeProvider] Preferencias reseteadas a valores por defecto');
  }
}
