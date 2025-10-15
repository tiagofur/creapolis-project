import '../../domain/entities/kanban_config.dart';
import '../../domain/entities/task.dart';

/// Utilidad para calcular métricas del tablero Kanban
class KanbanMetricsCalculator {
  /// Calcula las métricas de una columna
  static KanbanColumnMetrics calculateColumnMetrics(
    TaskStatus status,
    List<Task> tasks,
  ) {
    final columnTasks = tasks.where((t) => t.status == status).toList();

    return KanbanColumnMetrics(
      status: status,
      taskCount: columnTasks.length,
      averageLeadTime: _calculateAverageLeadTime(columnTasks),
      averageCycleTime: _calculateAverageCycleTime(columnTasks),
      lastUpdated: DateTime.now(),
    );
  }

  /// Calcula el Lead Time promedio (desde creación hasta completado)
  /// Solo considera tareas completadas
  static double _calculateAverageLeadTime(List<Task> tasks) {
    final completedTasks = tasks.where((t) => t.isCompleted).toList();
    
    if (completedTasks.isEmpty) return 0.0;

    final totalLeadTime = completedTasks.fold<int>(
      0,
      (sum, task) => sum + task.updatedAt.difference(task.createdAt).inDays,
    );

    return totalLeadTime / completedTasks.length;
  }

  /// Calcula el Cycle Time promedio (desde inicio hasta completado)
  /// Solo considera tareas completadas
  static double _calculateAverageCycleTime(List<Task> tasks) {
    final completedTasks = tasks.where((t) => t.isCompleted).toList();
    
    if (completedTasks.isEmpty) return 0.0;

    final totalCycleTime = completedTasks.fold<int>(
      0,
      (sum, task) => sum + task.endDate.difference(task.startDate).inDays,
    );

    return totalCycleTime / completedTasks.length;
  }

  /// Calcula las métricas de todas las columnas
  static Map<TaskStatus, KanbanColumnMetrics> calculateAllMetrics(
    List<Task> tasks,
  ) {
    final metrics = <TaskStatus, KanbanColumnMetrics>{};

    for (final status in TaskStatus.values) {
      metrics[status] = calculateColumnMetrics(status, tasks);
    }

    return metrics;
  }

  /// Calcula el throughput (tareas completadas en un período)
  static int calculateThroughput(
    List<Task> tasks,
    DateTime startDate,
    DateTime endDate,
  ) {
    return tasks
        .where(
          (t) =>
              t.isCompleted &&
              t.updatedAt.isAfter(startDate) &&
              t.updatedAt.isBefore(endDate),
        )
        .length;
  }

  /// Calcula el WIP total (Work In Progress)
  static int calculateWip(List<Task> tasks) {
    return tasks.where((t) => t.isInProgress || t.isBlocked).length;
  }
}



