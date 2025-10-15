import 'package:hive/hive.dart';
import '../../../domain/entities/project.dart';

part 'hive_project.g.dart';

/// Modelo Hive para almacenamiento local de Projects
/// Versión simplificada para caché offline
@HiveType(typeId: 1)
class HiveProject extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime startDate;

  @HiveField(4)
  DateTime endDate;

  @HiveField(5)
  String status; // 'PLANNING', 'ACTIVE', 'PAUSED', 'COMPLETED', 'CANCELLED'

  @HiveField(6)
  int? managerId;

  @HiveField(7)
  String? managerName;

  @HiveField(8)
  int workspaceId;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  DateTime updatedAt;

  @HiveField(11)
  DateTime? lastSyncedAt;

  @HiveField(12)
  bool isPendingSync;

  HiveProject({
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
    this.lastSyncedAt,
    this.isPendingSync = false,
  });

  /// Convertir desde Entity a Hive
  factory HiveProject.fromEntity(Project entity) {
    return HiveProject(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      startDate: entity.startDate,
      endDate: entity.endDate,
      status: entity.status.name.toUpperCase(),
      managerId: entity.managerId,
      managerName: entity.managerName,
      workspaceId: entity.workspaceId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      lastSyncedAt: DateTime.now(),
      isPendingSync: false,
    );
  }

  /// Convertir desde Hive a Entity
  Project toEntity() {
    return Project(
      id: id,
      name: name,
      description: description,
      startDate: startDate,
      endDate: endDate,
      status: _parseStatus(status),
      managerId: managerId,
      managerName: managerName,
      workspaceId: workspaceId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Parse status string to enum
  ProjectStatus _parseStatus(String statusStr) {
    switch (statusStr.toUpperCase()) {
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

  /// Convertir a JSON (para operation queue)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
      'managerId': managerId,
      'managerName': managerName,
      'workspaceId': workspaceId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'isPendingSync': isPendingSync,
    };
  }

  /// Crear desde JSON (para operation queue)
  factory HiveProject.fromJson(Map<String, dynamic> json) {
    return HiveProject(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: json['status'] as String,
      managerId: json['managerId'] as int?,
      managerName: json['managerName'] as String?,
      workspaceId: json['workspaceId'] as int,
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
    return 'HiveProject(id: $id, name: $name, workspaceId: $workspaceId, isPendingSync: $isPendingSync)';
  }
}



