import '../../domain/entities/project.dart';

/// Modelo de datos para Project
///
/// Extiende la entidad Project y agrega funcionalidades de serialización.
class ProjectModel extends Project {
  const ProjectModel({
    required super.id,
    required super.name,
    required super.description,
    required super.startDate,
    required super.endDate,
    required super.status,
    super.managerId,
    super.managerName,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Crear ProjectModel desde JSON
  ///
  /// Usado para deserializar respuestas de la API.
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: _statusFromString(json['status'] as String),
      managerId: json['managerId'] as int?,
      managerName: json['managerName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convertir ProjectModel a JSON
  ///
  /// Usado para serializar datos para enviar a la API.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': _statusToString(status),
      if (managerId != null) 'managerId': managerId,
      if (managerName != null) 'managerName': managerName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Crear ProjectModel desde una entidad Project
  factory ProjectModel.fromEntity(Project project) {
    return ProjectModel(
      id: project.id,
      name: project.name,
      description: project.description,
      startDate: project.startDate,
      endDate: project.endDate,
      status: project.status,
      managerId: project.managerId,
      managerName: project.managerName,
      createdAt: project.createdAt,
      updatedAt: project.updatedAt,
    );
  }

  /// Convertir string a ProjectStatus
  static ProjectStatus _statusFromString(String status) {
    switch (status.toUpperCase()) {
      case 'PLANNED':
        return ProjectStatus.planned;
      case 'ACTIVE':
        return ProjectStatus.active;
      case 'PAUSED':
        return ProjectStatus.paused;
      case 'COMPLETED':
        return ProjectStatus.completed;
      case 'CANCELLED':
        return ProjectStatus.cancelled;
      default:
        return ProjectStatus.planned;
    }
  }

  /// Convertir ProjectStatus a string
  static String _statusToString(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planned:
        return 'PLANNED';
      case ProjectStatus.active:
        return 'ACTIVE';
      case ProjectStatus.paused:
        return 'PAUSED';
      case ProjectStatus.completed:
        return 'COMPLETED';
      case ProjectStatus.cancelled:
        return 'CANCELLED';
    }
  }

  /// Copiar con nuevos valores
  @override
  ProjectModel copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    ProjectStatus? status,
    int? managerId,
    String? managerName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      managerId: managerId ?? this.managerId,
      managerName: managerName ?? this.managerName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
