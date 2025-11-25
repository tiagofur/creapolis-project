import 'package:equatable/equatable.dart';
import 'task.dart';

/// Estados posibles de un sprint
enum SprintStatus {
  planned,
  active,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case SprintStatus.planned:
        return 'Planificado';
      case SprintStatus.active:
        return 'Activo';
      case SprintStatus.completed:
        return 'Completado';
      case SprintStatus.cancelled:
        return 'Cancelado';
    }
  }
}

/// Entidad de dominio para Sprint
class Sprint extends Equatable {
  final int id;
  final String name;
  final String? goal;
  final int projectId;
  final DateTime startDate;
  final DateTime endDate;
  final SprintStatus status;
  final List<Task> tasks;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Sprint({
    required this.id,
    required this.name,
    this.goal,
    required this.projectId,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.tasks = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Verifica si el sprint está activo
  bool get isActive => status == SprintStatus.active;

  /// Verifica si el sprint está completado
  bool get isCompleted => status == SprintStatus.completed;

  /// Calcula la duración del sprint en días
  int get durationInDays => endDate.difference(startDate).inDays;

  /// Calcula cuántos días han transcurrido del sprint
  int get daysElapsed {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0;
    if (now.isAfter(endDate)) return durationInDays;
    return now.difference(startDate).inDays;
  }

  /// Calcula el progreso del sprint (0.0 a 1.0) basado en fechas
  double get progress {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0.0;
    if (now.isAfter(endDate)) return 1.0;

    final totalDuration = endDate.difference(startDate).inSeconds;
    final elapsed = now.difference(startDate).inSeconds;

    return elapsed / totalDuration;
  }

  /// Puntos de historia totales
  int get totalPoints =>
      tasks.fold(0, (sum, task) => sum + (task.storyPoints ?? 0));

  /// Puntos completados
  int get completedPoints => tasks
      .where((t) => t.isCompleted)
      .fold(0, (sum, task) => sum + (task.storyPoints ?? 0));

  /// Copia el sprint con nuevos valores
  Sprint copyWith({
    int? id,
    String? name,
    String? goal,
    int? projectId,
    DateTime? startDate,
    DateTime? endDate,
    SprintStatus? status,
    List<Task>? tasks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Sprint(
      id: id ?? this.id,
      name: name ?? this.name,
      goal: goal ?? this.goal,
      projectId: projectId ?? this.projectId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    goal,
    projectId,
    startDate,
    endDate,
    status,
    tasks,
    createdAt,
    updatedAt,
  ];
}
