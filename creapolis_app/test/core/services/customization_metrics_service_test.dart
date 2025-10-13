import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:creapolis_app/core/services/customization_metrics_service.dart';
import 'package:creapolis_app/domain/entities/customization_event.dart';

void main() {
  group('CustomizationMetricsService', () {
    late CustomizationMetricsService service;

    setUp(() async {
      // Inicializar SharedPreferences con valores vacíos
      SharedPreferences.setMockInitialValues({});
      service = CustomizationMetricsService.instance;
      await service.init();
    });

    tearDown(() async {
      await service.clearAllEvents();
    });

    test('debe inicializar correctamente', () {
      expect(service.isInitialized, true);
      expect(service.totalEvents, 0);
    });

    group('Registro de Eventos', () {
      test('debe registrar cambio de tema', () async {
        await service.trackThemeChange('light', 'dark');

        expect(service.totalEvents, 1);
        final events = service.getAllEvents();
        expect(events.first.type, CustomizationEventType.themeChanged);
        expect(events.first.previousValue, 'light');
        expect(events.first.newValue, 'dark');
      });

      test('debe registrar cambio de layout', () async {
        await service.trackLayoutChange('sidebar', 'bottomNavigation');

        expect(service.totalEvents, 1);
        final events = service.getAllEvents();
        expect(events.first.type, CustomizationEventType.layoutChanged);
        expect(events.first.previousValue, 'sidebar');
        expect(events.first.newValue, 'bottomNavigation');
      });

      test('debe registrar widget añadido', () async {
        await service.trackWidgetAdded('quickStats');

        expect(service.totalEvents, 1);
        final events = service.getAllEvents();
        expect(events.first.type, CustomizationEventType.widgetAdded);
        expect(events.first.newValue, 'quickStats');
      });

      test('debe registrar widget eliminado', () async {
        await service.trackWidgetRemoved('myTasks');

        expect(service.totalEvents, 1);
        final events = service.getAllEvents();
        expect(events.first.type, CustomizationEventType.widgetRemoved);
        expect(events.first.previousValue, 'myTasks');
      });

      test('debe registrar widgets reordenados', () async {
        await service.trackWidgetsReordered(['widget1', 'widget2', 'widget3']);

        expect(service.totalEvents, 1);
        final events = service.getAllEvents();
        expect(events.first.type, CustomizationEventType.widgetReordered);
        expect(events.first.metadata?['widgetOrder'], ['widget1', 'widget2', 'widget3']);
      });

      test('debe registrar reset de dashboard', () async {
        await service.trackDashboardReset();

        expect(service.totalEvents, 1);
        final events = service.getAllEvents();
        expect(events.first.type, CustomizationEventType.dashboardReset);
      });

      test('debe registrar múltiples eventos', () async {
        await service.trackThemeChange('light', 'dark');
        await service.trackLayoutChange('sidebar', 'bottomNavigation');
        await service.trackWidgetAdded('quickStats');

        expect(service.totalEvents, 3);
      });
    });

    group('Consulta de Eventos', () {
      test('debe obtener todos los eventos', () async {
        await service.trackThemeChange('light', 'dark');
        await service.trackWidgetAdded('quickStats');

        final events = service.getAllEvents();
        expect(events.length, 2);
      });

      test('debe obtener eventos por tipo', () async {
        await service.trackThemeChange('light', 'dark');
        await service.trackThemeChange('dark', 'system');
        await service.trackWidgetAdded('quickStats');

        final themeEvents = service.getEventsByType(CustomizationEventType.themeChanged);
        expect(themeEvents.length, 2);

        final widgetEvents = service.getEventsByType(CustomizationEventType.widgetAdded);
        expect(widgetEvents.length, 1);
      });

      test('debe obtener eventos entre fechas', () async {
        final startDate = DateTime.now();
        
        await service.trackThemeChange('light', 'dark');
        await Future.delayed(const Duration(milliseconds: 100));
        
        final midDate = DateTime.now();
        
        await service.trackWidgetAdded('quickStats');
        await Future.delayed(const Duration(milliseconds: 100));
        
        final endDate = DateTime.now();

        final eventsInRange = service.getEventsBetween(startDate, endDate);
        expect(eventsInRange.length, 2);

        final eventsBeforeMid = service.getEventsBetween(startDate, midDate);
        expect(eventsBeforeMid.length, 1);
      });
    });

    group('Generación de Métricas', () {
      test('debe generar métricas vacías cuando no hay eventos', () {
        final metrics = service.generateMetrics();

        expect(metrics.totalEvents, 0);
        expect(metrics.themeUsage, isEmpty);
        expect(metrics.layoutUsage, isEmpty);
        expect(metrics.widgetUsage, isEmpty);
      });

      test('debe calcular estadísticas de uso de temas', () async {
        await service.trackThemeChange('light', 'dark');
        await service.trackThemeChange('dark', 'light');
        await service.trackThemeChange('light', 'dark');

        final metrics = service.generateMetrics();

        expect(metrics.themeUsage.length, 2);
        expect(metrics.themeUsage.first.item, 'dark'); // Más usado
        expect(metrics.themeUsage.first.count, 2);
        expect(metrics.themeUsage.first.percentage, 66.66666666666666);
      });

      test('debe calcular estadísticas de uso de layouts', () async {
        await service.trackLayoutChange('sidebar', 'bottomNavigation');
        await service.trackLayoutChange('bottomNavigation', 'sidebar');
        await service.trackLayoutChange('sidebar', 'bottomNavigation');
        await service.trackLayoutChange('bottomNavigation', 'sidebar');

        final metrics = service.generateMetrics();

        expect(metrics.layoutUsage.length, 2);
        // Ambos tienen el mismo uso
        expect(metrics.layoutUsage[0].count, 2);
        expect(metrics.layoutUsage[1].count, 2);
      });

      test('debe calcular estadísticas de uso de widgets', () async {
        await service.trackWidgetAdded('quickStats');
        await service.trackWidgetAdded('myTasks');
        await service.trackWidgetAdded('quickStats');
        await service.trackWidgetRemoved('quickStats');

        final metrics = service.generateMetrics();

        expect(metrics.widgetUsage.length, 2);
        expect(metrics.widgetUsage.first.item, 'quickStats'); // Más usado
        expect(metrics.widgetUsage.first.count, 3); // 2 adds + 1 remove
      });

      test('debe contar tipos de eventos', () async {
        await service.trackThemeChange('light', 'dark');
        await service.trackThemeChange('dark', 'system');
        await service.trackWidgetAdded('quickStats');
        await service.trackDashboardReset();

        final metrics = service.generateMetrics();

        expect(metrics.eventTypeCount['themeChanged'], 2);
        expect(metrics.eventTypeCount['widgetAdded'], 1);
        expect(metrics.eventTypeCount['dashboardReset'], 1);
        expect(metrics.totalEvents, 4);
      });

      test('debe generar métricas para rango de fechas', () async {
        final startDate = DateTime.now();
        
        await service.trackThemeChange('light', 'dark');
        await Future.delayed(const Duration(milliseconds: 100));
        
        final midDate = DateTime.now();
        
        await service.trackWidgetAdded('quickStats');
        await service.trackWidgetAdded('myTasks');
        await Future.delayed(const Duration(milliseconds: 100));
        
        final endDate = DateTime.now();

        final allMetrics = service.generateMetrics();
        expect(allMetrics.totalEvents, 3);

        final rangeMetrics = service.generateMetrics(
          startDate: midDate,
          endDate: endDate,
        );
        expect(rangeMetrics.totalEvents, 2);
      });
    });

    group('Persistencia', () {
      test('debe persistir eventos entre reinicios', () async {
        await service.trackThemeChange('light', 'dark');
        await service.trackWidgetAdded('quickStats');

        expect(service.totalEvents, 2);

        // Simular reinicio creando nueva instancia
        final newService = CustomizationMetricsService.instance;
        await newService.init();

        expect(newService.totalEvents, 2);
        final events = newService.getAllEvents();
        expect(events.length, 2);
      });
    });

    group('Limpieza de Datos', () {
      test('debe limpiar todos los eventos', () async {
        await service.trackThemeChange('light', 'dark');
        await service.trackWidgetAdded('quickStats');

        expect(service.totalEvents, 2);

        final success = await service.clearAllEvents();

        expect(success, true);
        expect(service.totalEvents, 0);
      });

      test('debe respetar límite de eventos almacenados', () async {
        // Registrar más eventos del límite (1000)
        for (int i = 0; i < 1100; i++) {
          await service.trackThemeChange('light', 'dark');
        }

        // Debe mantener solo los últimos 1000
        expect(service.totalEvents, 1000);
      });
    });

    group('Fechas de Eventos', () {
      test('debe retornar null cuando no hay eventos', () {
        expect(service.firstEventDate, null);
        expect(service.lastEventDate, null);
      });

      test('debe retornar fechas correctas de primer y último evento', () async {
        await service.trackThemeChange('light', 'dark');
        await Future.delayed(const Duration(milliseconds: 100));
        await service.trackWidgetAdded('quickStats');

        expect(service.firstEventDate, isNotNull);
        expect(service.lastEventDate, isNotNull);
        expect(service.lastEventDate!.isAfter(service.firstEventDate!), true);
      });
    });

    group('Privacidad y Anonimización', () {
      test('no debe almacenar información personal identificable', () async {
        await service.trackThemeChange('light', 'dark');
        
        final events = service.getAllEvents();
        final event = events.first;

        // Verificar que no hay IDs de usuario o datos personales
        expect(event.metadata?.containsKey('userId'), false);
        expect(event.metadata?.containsKey('userName'), false);
        expect(event.metadata?.containsKey('email'), false);
      });

      test('debe generar IDs únicos para eventos', () async {
        await service.trackThemeChange('light', 'dark');
        await Future.delayed(const Duration(milliseconds: 1));
        await service.trackThemeChange('dark', 'light');

        final events = service.getAllEvents();
        expect(events[0].id != events[1].id, true);
      });
    });
  });
}
