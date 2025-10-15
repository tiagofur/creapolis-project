import 'package:flutter/foundation.dart';

import '../../../../domain/entities/project.dart';
import '../../../../domain/entities/task.dart';

/// Provider para manejar filtros del dashboard
class DashboardFilterProvider extends ChangeNotifier {
  Project? _selectedProject;
  TaskStatus? _selectedStatus;
  TaskPriority? _selectedPriority;
  DateTime? _startDate;
  DateTime? _endDate;

  // Getters
  Project? get selectedProject => _selectedProject;
  int? get selectedProjectId => _selectedProject?.id;
  TaskStatus? get selectedStatus => _selectedStatus;
  TaskPriority? get selectedPriority => _selectedPriority;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  /// Verifica si hay filtros activos
  bool get hasActiveFilters {
    return _selectedProject != null ||
        _selectedStatus != null ||
        _selectedPriority != null ||
        _startDate != null ||
        _endDate != null;
  }

  /// Cantidad de filtros activos
  int get activeFilterCount {
    int count = 0;
    if (_selectedProject != null) count++;
    if (_selectedStatus != null) count++;
    if (_selectedPriority != null) count++;
    if (_startDate != null || _endDate != null) count++;
    return count;
  }

  /// Establecer filtro de proyecto
  void setProjectFilter(Project? project) {
    if (_selectedProject != project) {
      _selectedProject = project;
      notifyListeners();
    }
  }

  /// Establecer filtro de estado
  void setStatusFilter(TaskStatus? status) {
    if (_selectedStatus != status) {
      _selectedStatus = status;
      notifyListeners();
    }
  }

  /// Establecer filtro de prioridad
  void setPriorityFilter(TaskPriority? priority) {
    if (_selectedPriority != priority) {
      _selectedPriority = priority;
      notifyListeners();
    }
  }

  /// Establecer filtro de rango de fechas
  void setDateRangeFilter(DateTime? startDate, DateTime? endDate) {
    if (_startDate != startDate || _endDate != endDate) {
      _startDate = startDate;
      _endDate = endDate;
      notifyListeners();
    }
  }

  /// Establecer filtro de rango de fechas (alias para compatibilidad)
  void setDateRange(DateTime startDate, DateTime endDate) {
    setDateRangeFilter(startDate, endDate);
  }

  /// Limpiar todos los filtros (alias para compatibilidad)
  void clearFilters() => clearAllFilters();

  void clearAllFilters() {
    if (hasActiveFilters) {
      _selectedProject = null;
      _selectedStatus = null;
      _selectedPriority = null;
      _startDate = null;
      _endDate = null;
      notifyListeners();
    }
  }

  /// Limpiar filtro específico
  void clearProjectFilter() => setProjectFilter(null);
  void clearStatusFilter() => setStatusFilter(null);
  void clearPriorityFilter() => setPriorityFilter(null);
  void clearDateRangeFilter() => setDateRangeFilter(null, null);
  void clearDateFilter() =>
      clearDateRangeFilter(); // Alias para compatibilidad  /// Aplicar filtros a una lista de tareas
  List<Task> applyFilters(List<Task> tasks) {
    return tasks.where((task) {
      // Filtro por proyecto
      if (_selectedProject != null && task.projectId != _selectedProject!.id) {
        return false;
      }

      // Filtro por estado
      if (_selectedStatus != null && task.status != _selectedStatus) {
        return false;
      }

      // Filtro por prioridad
      if (_selectedPriority != null && task.priority != _selectedPriority) {
        return false;
      }

      // Filtro por fecha de inicio
      if (_startDate != null && task.startDate.isBefore(_startDate!)) {
        return false;
      }

      // Filtro por fecha de fin
      if (_endDate != null && task.endDate.isAfter(_endDate!)) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Obtener descripción de filtros activos
  String getActiveFiltersDescription() {
    final descriptions = <String>[];

    if (_selectedProject != null) {
      descriptions.add('Proyecto: ${_selectedProject!.name}');
    }

    if (_selectedStatus != null) {
      descriptions.add('Estado: ${_selectedStatus!.name}');
    }

    if (_selectedPriority != null) {
      descriptions.add('Prioridad: ${_selectedPriority!.name}');
    }

    if (_startDate != null || _endDate != null) {
      if (_startDate != null && _endDate != null) {
        descriptions.add(
          'Fechas: ${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}',
        );
      } else if (_startDate != null) {
        descriptions.add('Desde: ${_formatDate(_startDate!)}');
      } else if (_endDate != null) {
        descriptions.add('Hasta: ${_formatDate(_endDate!)}');
      }
    }

    return descriptions.join(' • ');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}



