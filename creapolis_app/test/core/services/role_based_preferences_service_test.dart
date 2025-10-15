import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:creapolis_app/core/services/role_based_preferences_service.dart';
import 'package:creapolis_app/domain/entities/dashboard_widget_config.dart';
import 'package:creapolis_app/domain/entities/role_based_ui_config.dart';
import 'package:creapolis_app/domain/entities/user.dart';

void main() {
  group('RoleBasedPreferencesService', () {
    late RoleBasedPreferencesService service;

    setUp(() async {
      // Inicializar SharedPreferences con valores vacíos
      SharedPreferences.setMockInitialValues({});
      service = RoleBasedPreferencesService.instance;
      await service.init();
    });

    tearDown(() async {
      await service.clearAllPreferences();
    });

    test('debe inicializar correctamente', () {
      expect(service.isInitialized, true);
    });

    group('loadUserPreferences', () {
      test('debe cargar preferencias por defecto para admin sin datos guardados',
          () async {
        final prefs = await service.loadUserPreferences(UserRole.admin);

        expect(prefs.userRole, UserRole.admin);
        expect(prefs.hasThemeOverride, false);
        expect(prefs.hasLayoutOverride, false);
        expect(prefs.hasDashboardOverride, false);
      });

      test(
          'debe cargar preferencias por defecto para projectManager sin datos guardados',
          () async {
        final prefs =
            await service.loadUserPreferences(UserRole.projectManager);

        expect(prefs.userRole, UserRole.projectManager);
        expect(prefs.hasThemeOverride, false);
        expect(prefs.hasLayoutOverride, false);
        expect(prefs.hasDashboardOverride, false);
      });

      test(
          'debe cargar preferencias por defecto para teamMember sin datos guardados',
          () async {
        final prefs = await service.loadUserPreferences(UserRole.teamMember);

        expect(prefs.userRole, UserRole.teamMember);
        expect(prefs.hasThemeOverride, false);
        expect(prefs.hasLayoutOverride, false);
        expect(prefs.hasDashboardOverride, false);
      });
    });

    group('Theme Overrides', () {
      test('debe establecer override de tema correctamente', () async {
        await service.loadUserPreferences(UserRole.admin);
        final success = await service.setThemeOverride('dark');

        expect(success, true);
        expect(service.currentUserPreferences?.hasThemeOverride, true);
        expect(service.currentUserPreferences?.themeModeOverride, 'dark');
      });

      test('debe limpiar override de tema correctamente', () async {
        await service.loadUserPreferences(UserRole.admin);
        await service.setThemeOverride('dark');
        final success = await service.clearThemeOverride();

        expect(success, true);
        expect(service.currentUserPreferences?.hasThemeOverride, false);
      });

      test('debe usar tema por defecto del rol cuando no hay override',
          () async {
        await service.loadUserPreferences(UserRole.admin);

        final effectiveTheme = service.getEffectiveThemeMode();
        final roleConfig = RoleBasedUIConfig.adminDefaults();

        expect(effectiveTheme, roleConfig.themeModeDefault);
      });

      test('debe usar tema override cuando está establecido', () async {
        await service.loadUserPreferences(UserRole.admin);
        await service.setThemeOverride('dark');

        final effectiveTheme = service.getEffectiveThemeMode();

        expect(effectiveTheme, 'dark');
      });
    });

    group('Dashboard Overrides', () {
      test('debe establecer override de dashboard correctamente', () async {
        await service.loadUserPreferences(UserRole.admin);

        final customConfig = DashboardConfig(
          widgets: [
            DashboardWidgetConfig.defaultForType(
              DashboardWidgetType.myTasks,
              0,
            ),
          ],
          lastModified: DateTime.now(),
        );

        final success = await service.setDashboardOverride(customConfig);

        expect(success, true);
        expect(service.currentUserPreferences?.hasDashboardOverride, true);
        expect(
          service.currentUserPreferences?.dashboardConfigOverride?.widgets
              .length,
          1,
        );
      });

      test('debe limpiar override de dashboard correctamente', () async {
        await service.loadUserPreferences(UserRole.admin);

        final customConfig = DashboardConfig.defaultConfig();
        await service.setDashboardOverride(customConfig);
        final success = await service.clearDashboardOverride();

        expect(success, true);
        expect(service.currentUserPreferences?.hasDashboardOverride, false);
      });
    });

    group('Role-Based Defaults', () {
      test('admin debe tener 6 widgets por defecto', () {
        final adminConfig = RoleBasedUIConfig.adminDefaults();
        expect(adminConfig.dashboardConfig.widgets.length, 6);
      });

      test('projectManager debe tener 5 widgets por defecto', () {
        final pmConfig = RoleBasedUIConfig.projectManagerDefaults();
        expect(pmConfig.dashboardConfig.widgets.length, 5);
      });

      test('teamMember debe tener 4 widgets por defecto', () {
        final tmConfig = RoleBasedUIConfig.teamMemberDefaults();
        expect(tmConfig.dashboardConfig.widgets.length, 4);
      });

      test('admin debe tener workspaceInfo como primer widget', () {
        final adminConfig = RoleBasedUIConfig.adminDefaults();
        expect(
          adminConfig.dashboardConfig.widgets[0].type,
          DashboardWidgetType.workspaceInfo,
        );
      });

      test('projectManager debe tener myProjects como segundo widget', () {
        final pmConfig = RoleBasedUIConfig.projectManagerDefaults();
        expect(
          pmConfig.dashboardConfig.widgets[1].type,
          DashboardWidgetType.myProjects,
        );
      });

      test('teamMember debe tener myTasks como segundo widget', () {
        final tmConfig = RoleBasedUIConfig.teamMemberDefaults();
        expect(
          tmConfig.dashboardConfig.widgets[1].type,
          DashboardWidgetType.myTasks,
        );
      });

      test('teamMember debe tener tema light por defecto', () {
        final tmConfig = RoleBasedUIConfig.teamMemberDefaults();
        expect(tmConfig.themeModeDefault, 'light');
      });

      test('admin debe tener tema system por defecto', () {
        final adminConfig = RoleBasedUIConfig.adminDefaults();
        expect(adminConfig.themeModeDefault, 'system');
      });
    });

    group('Reset to Role Defaults', () {
      test('debe resetear todas las preferencias correctamente', () async {
        await service.loadUserPreferences(UserRole.admin);

        // Establecer overrides
        await service.setThemeOverride('dark');
        await service.setLayoutOverride('sidebar');
        await service.setDashboardOverride(DashboardConfig.defaultConfig());

        // Resetear
        final success = await service.resetToRoleDefaults();

        expect(success, true);
        expect(service.currentUserPreferences?.hasThemeOverride, false);
        expect(service.currentUserPreferences?.hasLayoutOverride, false);
        expect(service.currentUserPreferences?.hasDashboardOverride, false);
      });
    });

    group('Persistence', () {
      test('debe persistir preferencias entre sesiones', () async {
        await service.loadUserPreferences(UserRole.admin);
        await service.setThemeOverride('dark');

        // Crear nueva instancia del servicio
        final newService = RoleBasedPreferencesService.instance;
        await newService.init();
        final prefs = await newService.loadUserPreferences(UserRole.admin);

        expect(prefs.hasThemeOverride, true);
        expect(prefs.themeModeOverride, 'dark');
      });

      test('debe limpiar todas las preferencias correctamente', () async {
        await service.loadUserPreferences(UserRole.admin);
        await service.setThemeOverride('dark');

        final success = await service.clearAllPreferences();

        expect(success, true);
        expect(service.currentUserPreferences, null);
      });
    });

    group('Role Change Handling', () {
      test('debe usar defaults del nuevo rol cuando el rol cambia', () async {
        // Cargar preferencias como admin
        await service.loadUserPreferences(UserRole.admin);
        await service.setThemeOverride('dark');
        await service.saveUserPreferences(service.currentUserPreferences!);

        // Cambiar a teamMember
        final newPrefs = await service.loadUserPreferences(UserRole.teamMember);

        // Debe tener rol actualizado sin overrides del admin
        expect(newPrefs.userRole, UserRole.teamMember);
        expect(newPrefs.hasThemeOverride, false);
      });
    });

    group('Layout Overrides', () {
      test('debe establecer override de layout correctamente', () async {
        await service.loadUserPreferences(UserRole.admin);
        final success = await service.setLayoutOverride('sidebar');

        expect(success, true);
        expect(service.currentUserPreferences?.hasLayoutOverride, true);
        expect(service.currentUserPreferences?.layoutTypeOverride, 'sidebar');
      });

      test('debe limpiar override de layout correctamente', () async {
        await service.loadUserPreferences(UserRole.admin);
        await service.setLayoutOverride('sidebar');
        final success = await service.clearLayoutOverride();

        expect(success, true);
        expect(service.currentUserPreferences?.hasLayoutOverride, false);
      });
    });

    group('Export and Import', () {
      test('debe exportar preferencias correctamente', () async {
        await service.loadUserPreferences(UserRole.admin);
        await service.setThemeOverride('dark');

        final filePath = await service.exportPreferences();

        expect(filePath, isNotNull);
        expect(filePath, contains('creapolis_preferences_'));
        expect(filePath, contains('.json'));
      });

      test('debe importar preferencias correctamente', () async {
        // Primero exportar
        await service.loadUserPreferences(UserRole.admin);
        await service.setThemeOverride('dark');
        await service.setLayoutOverride('sidebar');

        final exportPath = await service.exportPreferences();
        expect(exportPath, isNotNull);

        // Resetear a defaults
        await service.resetToRoleDefaults();
        expect(service.currentUserPreferences?.hasThemeOverride, false);

        // Importar
        final success = await service.importPreferences(exportPath!);
        expect(success, true);

        // Verificar que los overrides se restauraron
        expect(service.currentUserPreferences?.hasThemeOverride, true);
        expect(service.currentUserPreferences?.themeModeOverride, 'dark');
        expect(service.currentUserPreferences?.hasLayoutOverride, true);
        expect(service.currentUserPreferences?.layoutTypeOverride, 'sidebar');
      });

      test('debe fallar al importar archivo inexistente', () async {
        await service.loadUserPreferences(UserRole.admin);

        final success = await service.importPreferences('/path/to/nonexistent/file.json');
        expect(success, false);
      });

      test('debe obtener preferencias como JSON', () async {
        await service.loadUserPreferences(UserRole.admin);
        await service.setThemeOverride('dark');

        final jsonString = service.getPreferencesAsJson();

        expect(jsonString, isNotNull);
        expect(jsonString, contains('version'));
        expect(jsonString, contains('preferences'));
        expect(jsonString, contains('dark'));
      });

      test('debe importar preferencias desde JSON string', () async {
        await service.loadUserPreferences(UserRole.admin);
        await service.setThemeOverride('dark');

        final jsonString = service.getPreferencesAsJson();
        expect(jsonString, isNotNull);

        // Resetear
        await service.resetToRoleDefaults();
        expect(service.currentUserPreferences?.hasThemeOverride, false);

        // Importar desde string
        final success = await service.importPreferencesFromJson(jsonString!);
        expect(success, true);
        expect(service.currentUserPreferences?.hasThemeOverride, true);
        expect(service.currentUserPreferences?.themeModeOverride, 'dark');
      });

      test('debe fallar al importar JSON inválido', () async {
        await service.loadUserPreferences(UserRole.admin);

        final success = await service.importPreferencesFromJson('{"invalid": "json"}');
        expect(success, false);
      });

      test('debe exportar archivo con estructura correcta', () async {
        await service.loadUserPreferences(UserRole.projectManager);
        await service.setThemeOverride('light');

        final jsonString = service.getPreferencesAsJson();
        expect(jsonString, isNotNull);

        final decoded = json.decode(jsonString!);
        expect(decoded['version'], '1.0');
        expect(decoded['exportDate'], isNotNull);
        expect(decoded['preferences'], isNotNull);
        expect(decoded['preferences']['userRole'], 'projectManager');
        expect(decoded['preferences']['themeModeOverride'], 'light');
      });

      test('debe preservar todos los overrides al exportar/importar', () async {
        await service.loadUserPreferences(UserRole.teamMember);
        
        // Establecer múltiples overrides
        await service.setThemeOverride('dark');
        await service.setLayoutOverride('sidebar');
        final customDashboard = DashboardConfig(
          widgets: [
            DashboardWidgetConfig.defaultForType(DashboardWidgetType.myTasks, 0),
            DashboardWidgetConfig.defaultForType(DashboardWidgetType.quickStats, 1),
          ],
          lastModified: DateTime.now(),
        );
        await service.setDashboardOverride(customDashboard);

        // Exportar
        final jsonString = service.getPreferencesAsJson();
        expect(jsonString, isNotNull);

        // Resetear
        await service.resetToRoleDefaults();

        // Importar
        final success = await service.importPreferencesFromJson(jsonString!);
        expect(success, true);

        // Verificar todos los overrides
        expect(service.currentUserPreferences?.userRole, UserRole.teamMember);
        expect(service.currentUserPreferences?.hasThemeOverride, true);
        expect(service.currentUserPreferences?.themeModeOverride, 'dark');
        expect(service.currentUserPreferences?.hasLayoutOverride, true);
        expect(service.currentUserPreferences?.layoutTypeOverride, 'sidebar');
        expect(service.currentUserPreferences?.hasDashboardOverride, true);
        expect(service.currentUserPreferences?.dashboardConfigOverride?.widgets.length, 2);
      });
    });

    group('Effective Configuration', () {
      test(
          'getEffectiveDashboardConfig debe retornar override cuando existe',
          () async {
        await service.loadUserPreferences(UserRole.admin);

        final customConfig = DashboardConfig(
          widgets: [
            DashboardWidgetConfig.defaultForType(
              DashboardWidgetType.myTasks,
              0,
            ),
          ],
          lastModified: DateTime.now(),
        );

        await service.setDashboardOverride(customConfig);

        final effectiveConfig = service.getEffectiveDashboardConfig();
        expect(effectiveConfig?.widgets.length, 1);
      });

      test(
          'getEffectiveDashboardConfig debe retornar default del rol cuando no hay override',
          () async {
        await service.loadUserPreferences(UserRole.admin);

        final effectiveConfig = service.getEffectiveDashboardConfig();
        final adminDefault = RoleBasedUIConfig.adminDefaults();

        expect(
          effectiveConfig?.widgets.length,
          adminDefault.dashboardConfig.widgets.length,
        );
      });
    });
  });
}



