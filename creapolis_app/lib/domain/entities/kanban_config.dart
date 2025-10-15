import 'package:equatable/equatable.dart';
import 'task.dart';

/// Configuración de WIP limits para una columna Kanban
class KanbanColumnConfig extends Equatable {
  final TaskStatus status;
  final int? wipLimit;
  final bool showWipAlert;

  const KanbanColumnConfig({
    required this.status,
    this.wipLimit,
    this.showWipAlert = true,
  });

  /// Verifica si el WIP limit está excedido
  bool isWipExceeded(int currentCount) {
    if (wipLimit == null) return false;
    return currentCount > wipLimit!;
  }

  /// Copia la configuración con nuevos valores
  KanbanColumnConfig copyWith({
    TaskStatus? status,
    int? wipLimit,
    bool? showWipAlert,
  }) {
    return KanbanColumnConfig(
      status: status ?? this.status,
      wipLimit: wipLimit ?? this.wipLimit,
      showWipAlert: showWipAlert ?? this.showWipAlert,
    );
  }

  @override
  List<Object?> get props => [status, wipLimit, showWipAlert];
}

/// Métricas de una columna Kanban
class KanbanColumnMetrics extends Equatable {
  final TaskStatus status;
  final int taskCount;
  final double averageLeadTime; // en días
  final double averageCycleTime; // en días
  final DateTime? lastUpdated;

  const KanbanColumnMetrics({
    required this.status,
    required this.taskCount,
    required this.averageLeadTime,
    required this.averageCycleTime,
    this.lastUpdated,
  });

  @override
  List<Object?> get props => [
        status,
        taskCount,
        averageLeadTime,
        averageCycleTime,
        lastUpdated,
      ];
}

/// Configuración de swimlane
class KanbanSwimlane extends Equatable {
  final String id;
  final String name;
  final String? description;
  final SwimlaneCriteria criteria;
  final int order;
  final bool isVisible;

  const KanbanSwimlane({
    required this.id,
    required this.name,
    this.description,
    required this.criteria,
    required this.order,
    this.isVisible = true,
  });

  /// Verifica si una tarea pertenece a este swimlane
  bool matchesTask(Task task) {
    return criteria.matches(task);
  }

  KanbanSwimlane copyWith({
    String? id,
    String? name,
    String? description,
    SwimlaneCriteria? criteria,
    int? order,
    bool? isVisible,
  }) {
    return KanbanSwimlane(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      criteria: criteria ?? this.criteria,
      order: order ?? this.order,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  @override
  List<Object?> get props => [id, name, description, criteria, order, isVisible];
}

/// Criterio para agrupar tareas en swimlanes
class SwimlaneCriteria extends Equatable {
  final SwimlaneCriteriaType type;
  final dynamic value;

  const SwimlaneCriteria({
    required this.type,
    this.value,
  });

  bool matches(Task task) {
    switch (type) {
      case SwimlaneCriteriaType.priority:
        return value == null || task.priority == value;
      case SwimlaneCriteriaType.assignee:
        return value == null || task.assignee?.id == value;
      case SwimlaneCriteriaType.unassigned:
        return task.assignee == null;
      case SwimlaneCriteriaType.all:
        return true;
    }
  }

  @override
  List<Object?> get props => [type, value];
}

/// Tipos de criterios para swimlanes
enum SwimlaneCriteriaType {
  all,
  priority,
  assignee,
  unassigned,
}

/// Configuración completa del tablero Kanban
class KanbanBoardConfig extends Equatable {
  final Map<TaskStatus, KanbanColumnConfig> columnConfigs;
  final List<KanbanSwimlane> swimlanes;
  final bool swimlanesEnabled;

  const KanbanBoardConfig({
    required this.columnConfigs,
    this.swimlanes = const [],
    this.swimlanesEnabled = false,
  });

  /// Obtiene la configuración de una columna
  KanbanColumnConfig? getColumnConfig(TaskStatus status) {
    return columnConfigs[status];
  }

  /// Obtiene swimlanes visibles ordenados
  List<KanbanSwimlane> get visibleSwimlanes {
    final lanes = swimlanes.where((s) => s.isVisible).toList();
    lanes.sort((a, b) => a.order.compareTo(b.order));
    return lanes;
  }

  KanbanBoardConfig copyWith({
    Map<TaskStatus, KanbanColumnConfig>? columnConfigs,
    List<KanbanSwimlane>? swimlanes,
    bool? swimlanesEnabled,
  }) {
    return KanbanBoardConfig(
      columnConfigs: columnConfigs ?? this.columnConfigs,
      swimlanes: swimlanes ?? this.swimlanes,
      swimlanesEnabled: swimlanesEnabled ?? this.swimlanesEnabled,
    );
  }

  @override
  List<Object?> get props => [columnConfigs, swimlanes, swimlanesEnabled];
}



