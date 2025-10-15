import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import 'package:creapolis_app/presentation/providers/theme_provider.dart';
import 'package:creapolis_app/core/constants/storage_keys.dart';

void main() {
  late SharedPreferences prefs;
  late ThemeProvider themeProvider;

  setUp(() async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  tearDown(() async {
    await prefs.clear();
  });

  group('ThemeProvider', () {
    test('initializes with system theme mode by default', () async {
      themeProvider = ThemeProvider(prefs);
      
      // Wait for initialization
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(themeProvider.themeMode, AppThemeMode.system);
      expect(themeProvider.effectiveThemeMode, ThemeMode.system);
      expect(themeProvider.isSystemMode, true);
      expect(themeProvider.isLightMode, false);
      expect(themeProvider.isDarkMode, false);
    });

    test('loads saved theme mode from preferences', () async {
      // Pre-populate preferences
      await prefs.setString(StorageKeys.themeMode, 'dark');
      
      themeProvider = ThemeProvider(prefs);
      
      // Wait for initialization
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(themeProvider.themeMode, AppThemeMode.dark);
      expect(themeProvider.effectiveThemeMode, ThemeMode.dark);
      expect(themeProvider.isDarkMode, true);
    });

    test('sets and persists theme mode', () async {
      themeProvider = ThemeProvider(prefs);
      
      await themeProvider.setThemeMode(AppThemeMode.light);
      
      expect(themeProvider.themeMode, AppThemeMode.light);
      expect(themeProvider.effectiveThemeMode, ThemeMode.light);
      expect(themeProvider.isLightMode, true);
      
      // Verify persistence
      final savedMode = prefs.getString(StorageKeys.themeMode);
      expect(savedMode, 'light');
    });

    test('toggles between light and dark mode', () async {
      themeProvider = ThemeProvider(prefs);
      
      // Set to light first
      await themeProvider.setThemeMode(AppThemeMode.light);
      expect(themeProvider.isLightMode, true);
      
      // Toggle to dark
      await themeProvider.toggleTheme();
      expect(themeProvider.isDarkMode, true);
      
      // Toggle back to light
      await themeProvider.toggleTheme();
      expect(themeProvider.isLightMode, true);
    });

    test('sets and persists color palette', () async {
      themeProvider = ThemeProvider(prefs);
      
      await themeProvider.setColorPalette(ColorPalette.defaultPalette);
      
      expect(themeProvider.colorPalette, ColorPalette.defaultPalette);
      
      // Verify persistence
      final savedPalette = prefs.getString(StorageKeys.colorPalette);
      expect(savedPalette, '0');
    });

    test('sets and persists layout type', () async {
      themeProvider = ThemeProvider(prefs);
      
      await themeProvider.setLayoutType(LayoutType.sidebar);
      
      expect(themeProvider.layoutType, LayoutType.sidebar);
      
      // Verify persistence
      final savedLayout = prefs.getString(StorageKeys.layoutType);
      expect(savedLayout, '0');
    });

    test('loads all saved preferences', () async {
      // Pre-populate all preferences
      await prefs.setString(StorageKeys.themeMode, 'dark');
      await prefs.setString(StorageKeys.colorPalette, '0');
      await prefs.setString(StorageKeys.layoutType, '1');
      
      themeProvider = ThemeProvider(prefs);
      
      // Wait for initialization
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(themeProvider.themeMode, AppThemeMode.dark);
      expect(themeProvider.colorPalette, ColorPalette.defaultPalette);
      expect(themeProvider.layoutType, LayoutType.bottomNavigation);
    });

    test('resets to defaults', () async {
      themeProvider = ThemeProvider(prefs);
      
      // Set non-default values
      await themeProvider.setThemeMode(AppThemeMode.light);
      await themeProvider.setLayoutType(LayoutType.sidebar);
      
      // Reset to defaults
      await themeProvider.resetToDefaults();
      
      expect(themeProvider.themeMode, AppThemeMode.system);
      expect(themeProvider.colorPalette, ColorPalette.defaultPalette);
      expect(themeProvider.layoutType, LayoutType.bottomNavigation);
    });

    test('AppThemeMode.fromString handles all valid values', () {
      expect(AppThemeMode.fromString('light'), AppThemeMode.light);
      expect(AppThemeMode.fromString('dark'), AppThemeMode.dark);
      expect(AppThemeMode.fromString('system'), AppThemeMode.system);
      expect(AppThemeMode.fromString('invalid'), AppThemeMode.system);
    });

    test('AppThemeMode.toThemeMode converts correctly', () {
      expect(AppThemeMode.light.toThemeMode(), ThemeMode.light);
      expect(AppThemeMode.dark.toThemeMode(), ThemeMode.dark);
      expect(AppThemeMode.system.toThemeMode(), ThemeMode.system);
    });
  });
}



