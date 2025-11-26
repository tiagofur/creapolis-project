import 'package:equatable/equatable.dart';

class TaskTemplate extends Equatable {
  final int id;
  final int projectTemplateId;
  final String title;
  final String? description;
  final String? category; // Assuming TaskCategory enum as string
  final double? estimatedHours;

  const TaskTemplate({
    required this.id,
    required this.projectTemplateId,
    required this.title,
    this.description,
    this.category,
    this.estimatedHours,
  });

  factory TaskTemplate.fromJson(Map<String, dynamic> json) {
    return TaskTemplate(
      id: json['id'],
      projectTemplateId: json['projectTemplateId'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      estimatedHours: (json['estimatedHours'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        projectTemplateId,
        title,
        description,
        category,
        estimatedHours,
      ];
}
