import 'package:flutter/foundation.dart';

/// Provider para gestionar los filtros del dashboard
///
/// Maneja el estado de filtros por proyecto, fecha y usuario
/// para mostrar métricas y KPIs filtrados
class DashboardFilterProvider extends ChangeNotifier {
  String? _selectedProjectId;
  String? _selectedUserId;
  DateTime? _startDate;
  DateTime? _endDate;

  String? get selectedProjectId => _selectedProjectId;
  String? get selectedUserId => _selectedUserId;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  bool get hasActiveFilters =>
      _selectedProjectId != null ||
      _selectedUserId != null ||
      _startDate != null ||
      _endDate != null;

  void setProjectFilter(String? projectId) {
    _selectedProjectId = projectId;
    notifyListeners();
  }

  void setUserFilter(String? userId) {
    _selectedUserId = userId;
    notifyListeners();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  void clearFilters() {
    _selectedProjectId = null;
    _selectedUserId = null;
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  void clearProjectFilter() {
    _selectedProjectId = null;
    notifyListeners();
  }

  void clearUserFilter() {
    _selectedUserId = null;
    notifyListeners();
  }

  void clearDateFilter() {
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }
}
