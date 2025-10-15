import 'package:flutter_test/flutter_test.dart';
import 'package:creapolis_app/presentation/providers/dashboard_filter_provider.dart';

void main() {
  group('DashboardFilterProvider', () {
    late DashboardFilterProvider provider;

    setUp(() {
      provider = DashboardFilterProvider();
    });

    test('debe inicializar sin filtros activos', () {
      expect(provider.hasActiveFilters, false);
      expect(provider.selectedProjectId, null);
      expect(provider.selectedUserId, null);
      expect(provider.startDate, null);
      expect(provider.endDate, null);
    });

    group('Filtro de Proyecto', () {
      test('debe establecer filtro de proyecto', () {
        provider.setProjectFilter('project-123');

        expect(provider.selectedProjectId, 'project-123');
        expect(provider.hasActiveFilters, true);
      });

      test('debe limpiar filtro de proyecto', () {
        provider.setProjectFilter('project-123');
        provider.clearProjectFilter();

        expect(provider.selectedProjectId, null);
        expect(provider.hasActiveFilters, false);
      });
    });

    group('Filtro de Usuario', () {
      test('debe establecer filtro de usuario', () {
        provider.setUserFilter('user-456');

        expect(provider.selectedUserId, 'user-456');
        expect(provider.hasActiveFilters, true);
      });

      test('debe limpiar filtro de usuario', () {
        provider.setUserFilter('user-456');
        provider.clearUserFilter();

        expect(provider.selectedUserId, null);
        expect(provider.hasActiveFilters, false);
      });
    });

    group('Filtro de Rango de Fechas', () {
      test('debe establecer rango de fechas', () {
        final start = DateTime(2025, 1, 1);
        final end = DateTime(2025, 1, 31);

        provider.setDateRange(start, end);

        expect(provider.startDate, start);
        expect(provider.endDate, end);
        expect(provider.hasActiveFilters, true);
      });

      test('debe limpiar rango de fechas', () {
        final start = DateTime(2025, 1, 1);
        final end = DateTime(2025, 1, 31);

        provider.setDateRange(start, end);
        provider.clearDateFilter();

        expect(provider.startDate, null);
        expect(provider.endDate, null);
        expect(provider.hasActiveFilters, false);
      });

      test('debe permitir fecha de inicio sin fecha de fin', () {
        final start = DateTime(2025, 1, 1);

        provider.setDateRange(start, null);

        expect(provider.startDate, start);
        expect(provider.endDate, null);
        expect(provider.hasActiveFilters, true);
      });

      test('debe permitir fecha de fin sin fecha de inicio', () {
        final end = DateTime(2025, 1, 31);

        provider.setDateRange(null, end);

        expect(provider.startDate, null);
        expect(provider.endDate, end);
        expect(provider.hasActiveFilters, true);
      });
    });

    group('Limpiar Todos los Filtros', () {
      test('debe limpiar todos los filtros activos', () {
        provider.setProjectFilter('project-123');
        provider.setUserFilter('user-456');
        provider.setDateRange(DateTime(2025, 1, 1), DateTime(2025, 1, 31));

        expect(provider.hasActiveFilters, true);

        provider.clearFilters();

        expect(provider.selectedProjectId, null);
        expect(provider.selectedUserId, null);
        expect(provider.startDate, null);
        expect(provider.endDate, null);
        expect(provider.hasActiveFilters, false);
      });
    });

    group('Múltiples Filtros Activos', () {
      test('debe detectar filtros activos con proyecto y usuario', () {
        provider.setProjectFilter('project-123');
        provider.setUserFilter('user-456');

        expect(provider.hasActiveFilters, true);
        expect(provider.selectedProjectId, 'project-123');
        expect(provider.selectedUserId, 'user-456');
      });

      test('debe detectar filtros activos con proyecto y fecha', () {
        provider.setProjectFilter('project-123');
        provider.setDateRange(DateTime(2025, 1, 1), DateTime(2025, 1, 31));

        expect(provider.hasActiveFilters, true);
        expect(provider.selectedProjectId, 'project-123');
        expect(provider.startDate, isNotNull);
      });

      test('debe mantener otros filtros al limpiar uno específico', () {
        provider.setProjectFilter('project-123');
        provider.setUserFilter('user-456');
        provider.setDateRange(DateTime(2025, 1, 1), DateTime(2025, 1, 31));

        provider.clearProjectFilter();

        expect(provider.selectedProjectId, null);
        expect(provider.selectedUserId, 'user-456');
        expect(provider.startDate, isNotNull);
        expect(provider.hasActiveFilters, true);
      });
    });
  });
}



