import 'package:creapolis_app/domain/entities/sprint.dart';
import 'package:creapolis_app/data/models/task_model.dart';

class SprintModel extends Sprint {
  const SprintModel({
    required super.id,
    required super.name,
    super.goal,
    required super.projectId,
    required super.startDate,
    required super.endDate,
    required super.status,
    super.tasks,
    required super.createdAt,
    required super.updatedAt,
  });

  factory SprintModel.fromJson(Map<String, dynamic> json) {
    return SprintModel(
      id: json['id'],
      name: json['name'],
      goal: json['goal'],
      projectId: json['projectId'] ?? json['project_id'],
      startDate: DateTime.parse(json['startDate'] ?? json['start_date']),
      endDate: DateTime.parse(json['endDate'] ?? json['end_date']),
      status: _parseStatus(json['status']),
      tasks: json['tasks'] != null
          ? (json['tasks'] as List).map((e) => TaskModel.fromJson(e)).toList()
          : [],
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
      updatedAt: DateTime.parse(json['updatedAt'] ?? json['updated_at']),
    );
  }

  static SprintStatus _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PLANNED':
        return SprintStatus.planned;
      case 'ACTIVE':
        return SprintStatus.active;
      case 'COMPLETED':
        return SprintStatus.completed;
      default:
        return SprintStatus.planned;
    }
  }
}
