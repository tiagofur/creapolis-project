import 'package:equatable/equatable.dart';

/// Entidad de dominio para Proyecto
class Project extends Equatable {
  final int id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final ProjectStatus status;
  final int? managerId;
  final String? managerName;
  final int workspaceId; // ID del workspace al que pertenece
  final DateTime createdAt;
  final DateTime updatedAt;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.managerId,
    this.managerName,
    required this.workspaceId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Verifica si el proyecto está activo
  bool get isActive => status == ProjectStatus.active;

  /// Verifica si el proyecto está completado
  bool get isCompleted => status == ProjectStatus.completed;

  /// Verifica si el proyecto está en pausa
  bool get isPaused => status == ProjectStatus.paused;

  /// Calcula la duración del proyecto en días
  int get durationInDays => endDate.difference(startDate).inDays;

  /// Verifica si el proyecto está retrasado
  bool get isOverdue {
    if (status == ProjectStatus.completed) return false;
    return DateTime.now().isAfter(endDate);
  }

  /// Calcula el progreso del proyecto (0.0 a 1.0) basado en fechas
  double get progress {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0.0;
    if (now.isAfter(endDate)) return 1.0;

    final totalDuration = endDate.difference(startDate).inSeconds;
    final elapsed = now.difference(startDate).inSeconds;

    return elapsed / totalDuration;
  }

  /// Copia el proyecto con nuevos valores
  Project copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    ProjectStatus? status,
    int? managerId,
    String? managerName,
    int? workspaceId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      managerId: managerId ?? this.managerId,
      managerName: managerName ?? this.managerName,
      workspaceId: workspaceId ?? this.workspaceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    startDate,
    endDate,
    status,
    managerId,
    managerName,
    workspaceId,
    createdAt,
    updatedAt,
  ];
}

/// Estados posibles de un proyecto
enum ProjectStatus {
  /// Proyecto planificado pero no iniciado
  planned,

  /// Proyecto activo en desarrollo
  active,

  /// Proyecto pausado temporalmente
  paused,

  /// Proyecto completado
  completed,

  /// Proyecto cancelado
  cancelled;

  /// Obtiene el label en español para el estado
  String get label {
    switch (this) {
      case ProjectStatus.planned:
        return 'Planificado';
      case ProjectStatus.active:
        return 'Activo';
      case ProjectStatus.paused:
        return 'Pausado';
      case ProjectStatus.completed:
        return 'Completado';
      case ProjectStatus.cancelled:
        return 'Cancelado';
    }
  }

  /// Convierte string a ProjectStatus
  static ProjectStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'planned':
        return ProjectStatus.planned;
      case 'active':
        return ProjectStatus.active;
      case 'paused':
        return ProjectStatus.paused;
      case 'completed':
        return ProjectStatus.completed;
      case 'cancelled':
        return ProjectStatus.cancelled;
      default:
        return ProjectStatus.planned;
    }
  }
}
