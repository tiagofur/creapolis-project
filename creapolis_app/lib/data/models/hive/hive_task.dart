import 'package:hive/hive.dart';
import '../../../domain/entities/task.dart';

part 'hive_task.g.dart';

/// Modelo Hive para almacenamiento local de Tasks
/// Versión simplificada para caché offline
@HiveType(typeId: 2)
class HiveTask extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int projectId;

  @HiveField(2)
  String title;

  @HiveField(3)
  String description;

  @HiveField(4)
  String status; // 'planned', 'inProgress', 'completed', 'blocked', 'cancelled'

  @HiveField(5)
  String priority; // 'low', 'medium', 'high', 'critical'

  @HiveField(6)
  double estimatedHours;

  @HiveField(7)
  double actualHours;

  @HiveField(8)
  int? assigneeId;

  @HiveField(9)
  String? assigneeName;

  @HiveField(10)
  DateTime startDate;

  @HiveField(11)
  DateTime endDate;

  @HiveField(12)
  List<int> dependencyIds;

  @HiveField(13)
  DateTime createdAt;

  @HiveField(14)
  DateTime updatedAt;

  @HiveField(15)
  DateTime? lastSyncedAt;

  @HiveField(16)
  bool isPendingSync;

  HiveTask({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.estimatedHours,
    this.actualHours = 0.0,
    this.assigneeId,
    this.assigneeName,
    required this.startDate,
    required this.endDate,
    this.dependencyIds = const [],
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
    this.isPendingSync = false,
  });

  /// Convertir desde Entity a Hive
  factory HiveTask.fromEntity(Task entity) {
    return HiveTask(
      id: entity.id,
      projectId: entity.projectId,
      title: entity.title,
      description: entity.description,
      status: entity.status.name,
      priority: entity.priority.name,
      estimatedHours: entity.estimatedHours,
      actualHours: entity.actualHours,
      assigneeId: entity.assignee?.id,
      assigneeName: entity.assignee?.name,
      startDate: entity.startDate,
      endDate: entity.endDate,
      dependencyIds: List.from(entity.dependencyIds),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      lastSyncedAt: DateTime.now(),
      isPendingSync: false,
    );
  }

  /// Convertir desde Hive a Entity
  Task toEntity() {
    return Task(
      id: id,
      projectId: projectId,
      title: title,
      description: description,
      status: _parseStatus(status),
      priority: _parsePriority(priority),
      estimatedHours: estimatedHours,
      actualHours: actualHours,
      assignee: null, // No guardamos el objeto User completo en caché
      startDate: startDate,
      endDate: endDate,
      dependencyIds: List.from(dependencyIds),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Parse status string to enum
  TaskStatus _parseStatus(String statusStr) {
    switch (statusStr.toLowerCase()) {
      case 'planned':
        return TaskStatus.planned;
      case 'inprogress':
        return TaskStatus.inProgress;
      case 'completed':
        return TaskStatus.completed;
      case 'blocked':
        return TaskStatus.blocked;
      case 'cancelled':
        return TaskStatus.cancelled;
      default:
        return TaskStatus.planned;
    }
  }

  /// Parse priority string to enum
  TaskPriority _parsePriority(String priorityStr) {
    switch (priorityStr.toLowerCase()) {
      case 'low':
        return TaskPriority.low;
      case 'medium':
        return TaskPriority.medium;
      case 'high':
        return TaskPriority.high;
      case 'critical':
        return TaskPriority.critical;
      default:
        return TaskPriority.medium;
    }
  }

  /// Convertir a JSON (para operation queue)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'estimatedHours': estimatedHours,
      'actualHours': actualHours,
      'assigneeId': assigneeId,
      'assigneeName': assigneeName,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'dependencyIds': dependencyIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'isPendingSync': isPendingSync,
    };
  }

  /// Crear desde JSON (para operation queue)
  factory HiveTask.fromJson(Map<String, dynamic> json) {
    return HiveTask(
      id: json['id'] as int,
      projectId: json['projectId'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      priority: json['priority'] as String,
      estimatedHours: (json['estimatedHours'] as num).toDouble(),
      actualHours: (json['actualHours'] as num?)?.toDouble() ?? 0.0,
      assigneeId: json['assigneeId'] as int?,
      assigneeName: json['assigneeName'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      dependencyIds:
          (json['dependencyIds'] as List<dynamic>?)?.cast<int>() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'] as String)
          : null,
      isPendingSync: json['isPendingSync'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'HiveTask(id: $id, title: $title, projectId: $projectId, isPendingSync: $isPendingSync)';
  }
}



