import 'package:equatable/equatable.dart';

class FormEntity extends Equatable {
  final int id;
  final int projectId;
  final String title;
  final String? description;
  final bool isActive;
  final String publicLink;
  final FormConfig config;
  final int viewCount;
  final int submitCount;
  final DateTime createdAt;

  const FormEntity({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    required this.isActive,
    required this.publicLink,
    required this.config,
    required this.viewCount,
    required this.submitCount,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    projectId,
    title,
    description,
    isActive,
    publicLink,
    config,
    viewCount,
    submitCount,
    createdAt,
  ];
}

class FormConfig extends Equatable {
  final List<FormFieldConfig> fields;
  final FormSettings settings;

  const FormConfig({required this.fields, required this.settings});

  @override
  List<Object?> get props => [fields, settings];
}

class FormFieldConfig extends Equatable {
  final String id;
  final String type;
  final String label;
  final bool required;
  final String? mapTo;
  final List<String>? options;

  const FormFieldConfig({
    required this.id,
    required this.type,
    required this.label,
    this.required = false,
    this.mapTo,
    this.options,
  });

  @override
  List<Object?> get props => [id, type, label, required, mapTo, options];
}

class FormSettings extends Equatable {
  final int? defaultAssigneeId;
  final String? confirmationMessage;

  const FormSettings({this.defaultAssigneeId, this.confirmationMessage});

  @override
  List<Object?> get props => [defaultAssigneeId, confirmationMessage];
}
