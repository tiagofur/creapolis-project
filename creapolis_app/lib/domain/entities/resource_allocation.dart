import 'package:equatable/equatable.dart';

/// Entidad de dominio para Asignación de Recursos
class ResourceAllocation extends Equatable {
  final int userId;
  final String userName;
  final Map<DateTime, double> dailyHours; // fecha -> horas asignadas
  final double totalHours;
  final bool isOverloaded;
  final List<TaskAllocation> taskAllocations;

  const ResourceAllocation({
    required this.userId,
    required this.userName,
    required this.dailyHours,
    required this.totalHours,
    required this.isOverloaded,
    required this.taskAllocations,
  });

  /// Obtiene las horas asignadas para una fecha específica
  double getHoursForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return dailyHours[normalizedDate] ?? 0.0;
  }

  /// Verifica si está sobrecargado en una fecha específica
  bool isOverloadedOnDate(DateTime date, {double maxHoursPerDay = 8.0}) {
    return getHoursForDate(date) > maxHoursPerDay;
  }

  /// Obtiene el nivel de carga para color coding
  /// - 'low': < 6 horas (verde)
  /// - 'medium': 6-8 horas (amarillo)
  /// - 'high': > 8 horas (rojo)
  String getLoadLevel(DateTime date) {
    final hours = getHoursForDate(date);
    if (hours > 8.0) return 'high';
    if (hours >= 6.0) return 'medium';
    return 'low';
  }

  /// Obtiene el promedio de horas por día
  double get averageHoursPerDay {
    if (dailyHours.isEmpty) return 0.0;
    return totalHours / dailyHours.length;
  }

  /// Obtiene el número de días con asignaciones
  int get daysWithAllocations => dailyHours.length;

  /// Obtiene el número de días sobrecargados
  int get overloadedDaysCount {
    return dailyHours.values.where((hours) => hours > 8.0).length;
  }

  @override
  List<Object?> get props => [
    userId,
    userName,
    dailyHours,
    totalHours,
    isOverloaded,
    taskAllocations,
  ];
}

/// Entidad para asignación de tarea individual
class TaskAllocation extends Equatable {
  final int taskId;
  final String taskTitle;
  final DateTime startDate;
  final DateTime endDate;
  final double estimatedHours;
  final String status;

  const TaskAllocation({
    required this.taskId,
    required this.taskTitle,
    required this.startDate,
    required this.endDate,
    required this.estimatedHours,
    required this.status,
  });

  /// Duración en días
  int get durationInDays {
    return endDate.difference(startDate).inDays + 1;
  }

  /// Horas por día
  double get hoursPerDay {
    return estimatedHours / durationInDays;
  }

  @override
  List<Object?> get props => [
    taskId,
    taskTitle,
    startDate,
    endDate,
    estimatedHours,
    status,
  ];
}



