import '../../domain/entities/form_entity.dart';

class FormModel extends FormEntity {
  const FormModel({
    required super.id,
    required super.projectId,
    required super.title,
    super.description,
    required super.isActive,
    required super.publicLink,
    required FormConfigModel super.config,
    required super.viewCount,
    required super.submitCount,
    required super.createdAt,
  });

  factory FormModel.fromJson(Map<String, dynamic> json) {
    return FormModel(
      id: json['id'],
      projectId: json['projectId'],
      title: json['title'],
      description: json['description'],
      isActive: json['isActive'] ?? true,
      publicLink: json['publicLink'],
      config: FormConfigModel.fromJson(json['config']),
      viewCount: json['viewCount'] ?? 0,
      submitCount: json['submitCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'description': description,
      'isActive': isActive,
      'publicLink': publicLink,
      'config': (config as FormConfigModel).toJson(),
      'viewCount': viewCount,
      'submitCount': submitCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class FormConfigModel extends FormConfig {
  const FormConfigModel({
    required List<FormFieldConfigModel> super.fields,
    required FormSettingsModel super.settings,
  });

  factory FormConfigModel.fromJson(Map<String, dynamic> json) {
    return FormConfigModel(
      fields: (json['fields'] as List)
          .map((e) => FormFieldConfigModel.fromJson(e))
          .toList(),
      settings: FormSettingsModel.fromJson(json['settings']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fields': fields
          .map((e) => (e as FormFieldConfigModel).toJson())
          .toList(),
      'settings': (settings as FormSettingsModel).toJson(),
    };
  }
}

class FormFieldConfigModel extends FormFieldConfig {
  const FormFieldConfigModel({
    required super.id,
    required super.type,
    required super.label,
    super.required,
    super.mapTo,
    super.options,
  });

  factory FormFieldConfigModel.fromJson(Map<String, dynamic> json) {
    return FormFieldConfigModel(
      id: json['id'],
      type: json['type'],
      label: json['label'],
      required: json['required'] ?? false,
      mapTo: json['mapTo'],
      options: (json['options'] as List?)?.map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'label': label,
      'required': required,
      'mapTo': mapTo,
      'options': options,
    };
  }
}

class FormSettingsModel extends FormSettings {
  const FormSettingsModel({super.defaultAssigneeId, super.confirmationMessage});

  factory FormSettingsModel.fromJson(Map<String, dynamic> json) {
    return FormSettingsModel(
      defaultAssigneeId: json['defaultAssigneeId'],
      confirmationMessage: json['confirmationMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultAssigneeId': defaultAssigneeId,
      'confirmationMessage': confirmationMessage,
    };
  }
}
