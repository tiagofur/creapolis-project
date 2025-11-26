import 'package:equatable/equatable.dart';
import 'task_template.dart'; // Assuming TaskTemplate is in a separate file

class ProjectTemplate extends Equatable {
  final int id;
  final String name;
  final String? description;
  final int workspaceId;
  final int createdBy;
  final List<TaskTemplate> tasks; // List of task templates

  const ProjectTemplate({
    required this.id,
    required this.name,
    this.description,
    required this.workspaceId,
    required this.createdBy,
    required this.tasks,
  });

  factory ProjectTemplate.fromJson(Map<String, dynamic> json) {
    return ProjectTemplate(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      workspaceId: json['workspaceId'],
      createdBy: json['createdBy'],
      tasks: (json['tasks'] as List)
          .map((taskJson) => TaskTemplate.fromJson(taskJson))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, name, description, workspaceId, createdBy, tasks];
}
