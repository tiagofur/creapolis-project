import 'dart:convert';
import '../../domain/entities/form_entity.dart';

class FormFieldModel {
  final String id;
  final String type;
  final String label;
  final String? placeholder;
  final String? helpText;
  final bool required;
  final String? mapTo;
  final List<String>? options;
  final int? minLength;
  final int? maxLength;
  final dynamic min;
  final dynamic max;
  final String? pattern;
  final dynamic defaultValue;
  final int order;

  FormFieldModel({
    required this.id,
    required this.type,
    required this.label,
    this.placeholder,
    this.helpText,
    this.required = false,
    this.mapTo,
    this.options,
    this.minLength,
    this.maxLength,
    this.min,
    this.max,
    this.pattern,
    this.defaultValue,
    this.order = 0,
  });

  factory FormFieldModel.fromJson(Map<String, dynamic> json) {
    return FormFieldModel(
      id: json['id'] as String,
      type: json['type'] as String,
      label: json['label'] as String,
      placeholder: json['placeholder'] as String?,
      helpText: json['helpText'] as String?,
      required: json['required'] as bool? ?? false,
      mapTo: json['mapTo'] as String?,
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      minLength: json['minLength'] as int?,
      maxLength: json['maxLength'] as int?,
      min: json['min'],
      max: json['max'],
      pattern: json['pattern'] as String?,
      defaultValue: json['defaultValue'],
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'label': label,
      if (placeholder != null) 'placeholder': placeholder,
      if (helpText != null) 'helpText': helpText,
      'required': required,
      if (mapTo != null) 'mapTo': mapTo,
      if (options != null) 'options': options,
      if (minLength != null) 'minLength': minLength,
      if (maxLength != null) 'maxLength': maxLength,
      if (min != null) 'min': min,
      if (max != null) 'max': max,
      if (pattern != null) 'pattern': pattern,
      if (defaultValue != null) 'defaultValue': defaultValue,
      'order': order,
    };
  }

  FormField toEntity() {
    return FormField(
      id: id,
      type: FormFieldType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => FormFieldType.text,
      ),
      label: label,
      placeholder: placeholder,
      helpText: helpText,
      required: required,
      mapTo: mapTo,
      options: options,
      minLength: minLength,
      maxLength: maxLength,
      min: min,
      max: max,
      pattern: pattern,
      defaultValue: defaultValue,
      order: order,
    );
  }

  factory FormFieldModel.fromEntity(FormField field) {
    return FormFieldModel(
      id: field.id,
      type: field.type.name,
      label: field.label,
      placeholder: field.placeholder,
      helpText: field.helpText,
      required: field.required,
      mapTo: field.mapTo,
      options: field.options,
      minLength: field.minLength,
      maxLength: field.maxLength,
      min: field.min,
      max: field.max,
      pattern: field.pattern,
      defaultValue: field.defaultValue,
      order: field.order,
    );
  }
}

class FormSettingsModel {
  final int? defaultAssigneeId;
  final String? defaultPriority;
  final String? defaultStatus;
  final String confirmationMessage;
  final bool autoCreateTask;
  final bool notifyOnSubmission;

  FormSettingsModel({
    this.defaultAssigneeId,
    this.defaultPriority,
    this.defaultStatus,
    this.confirmationMessage = 'Thank you for your submission!',
    this.autoCreateTask = true,
    this.notifyOnSubmission = false,
  });

  factory FormSettingsModel.fromJson(Map<String, dynamic> json) {
    return FormSettingsModel(
      defaultAssigneeId: json['defaultAssigneeId'] as int?,
      defaultPriority: json['defaultPriority'] as String?,
      defaultStatus: json['defaultStatus'] as String?,
      confirmationMessage: json['confirmationMessage'] as String? ??
          'Thank you for your submission!',
      autoCreateTask: json['autoCreateTask'] as bool? ?? true,
      notifyOnSubmission: json['notifyOnSubmission'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (defaultAssigneeId != null) 'defaultAssigneeId': defaultAssigneeId,
      if (defaultPriority != null) 'defaultPriority': defaultPriority,
      if (defaultStatus != null) 'defaultStatus': defaultStatus,
      'confirmationMessage': confirmationMessage,
      'autoCreateTask': autoCreateTask,
      'notifyOnSubmission': notifyOnSubmission,
    };
  }

  FormSettings toEntity() {
    return FormSettings(
      defaultAssigneeId: defaultAssigneeId,
      defaultPriority: defaultPriority,
      defaultStatus: defaultStatus,
      confirmationMessage: confirmationMessage,
      autoCreateTask: autoCreateTask,
      notifyOnSubmission: notifyOnSubmission,
    );
  }

  factory FormSettingsModel.fromEntity(FormSettings settings) {
    return FormSettingsModel(
      defaultAssigneeId: settings.defaultAssigneeId,
      defaultPriority: settings.defaultPriority,
      defaultStatus: settings.defaultStatus,
      confirmationMessage: settings.confirmationMessage,
      autoCreateTask: settings.autoCreateTask,
      notifyOnSubmission: settings.notifyOnSubmission,
    );
  }
}

class FormConfigModel {
  final List<FormFieldModel> fields;
  final FormSettingsModel settings;

  FormConfigModel({
    required this.fields,
    required this.settings,
  });

  factory FormConfigModel.fromJson(Map<String, dynamic> json) {
    return FormConfigModel(
      fields: (json['fields'] as List<dynamic>?)
              ?.map((e) => FormFieldModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      settings: FormSettingsModel.fromJson(
          json['settings'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fields': fields.map((f) => f.toJson()).toList(),
      'settings': settings.toJson(),
    };
  }

  FormConfig toEntity() {
    return FormConfig(
      fields: fields.map((f) => f.toEntity()).toList(),
      settings: settings.toEntity(),
    );
  }

  factory FormConfigModel.fromEntity(FormConfig config) {
    return FormConfigModel(
      fields: config.fields.map((f) => FormFieldModel.fromEntity(f)).toList(),
      settings: FormSettingsModel.fromEntity(config.settings),
    );
  }
}

class FormModel {
  final int id;
  final int projectId;
  final String title;
  final String? description;
  final bool isActive;
  final String publicLink;
  final String config; // JSON string
  final int viewCount;
  final int submitCount;
  final int createdBy;
  final String createdAt;
  final String updatedAt;
  final int? submissionCount;

  FormModel({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    required this.isActive,
    required this.publicLink,
    required this.config,
    required this.viewCount,
    required this.submitCount,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.submissionCount,
  });

  factory FormModel.fromJson(Map<String, dynamic> json) {
    // Handle both string and object config formats
    final configData = json['config'];
    final configString = configData is String
        ? configData
        : (configData is Map ? jsonEncode(configData) : '{}');

    return FormModel(
      id: json['id'] as int,
      projectId: json['projectId'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      publicLink: json['publicLink'] as String,
      config: configString,
      viewCount: json['viewCount'] as int? ?? 0,
      submitCount: json['submitCount'] as int? ?? 0,
      createdBy: json['createdBy'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      submissionCount: json['submissionCount'] as int? ??
          json['_count']?['submissions'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      if (description != null) 'description': description,
      'isActive': isActive,
      'publicLink': publicLink,
      'config': config,
      'viewCount': viewCount,
      'submitCount': submitCount,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      if (submissionCount != null) 'submissionCount': submissionCount,
    };
  }

  FormEntity toEntity() {
    late FormConfigModel configModel;
    try {
      final Map<String, dynamic> configJson = jsonDecode(config);
      configModel = FormConfigModel.fromJson(configJson);
    } catch (e) {
      // Fallback to empty config
      configModel = FormConfigModel(
        fields: [],
        settings: FormSettingsModel(),
      );
    }

    return FormEntity(
      id: id,
      projectId: projectId,
      title: title,
      description: description,
      isActive: isActive,
      publicLink: publicLink,
      config: configModel.toEntity(),
      viewCount: viewCount,
      submitCount: submitCount,
      createdBy: createdBy,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      submissionCount: submissionCount,
    );
  }

  factory FormModel.fromEntity(FormEntity entity) {
    final configModel = FormConfigModel.fromEntity(entity.config);
    return FormModel(
      id: entity.id,
      projectId: entity.projectId,
      title: entity.title,
      description: entity.description,
      isActive: entity.isActive,
      publicLink: entity.publicLink,
      config: jsonEncode(configModel.toJson()),
      viewCount: entity.viewCount,
      submitCount: entity.submitCount,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
      submissionCount: entity.submissionCount,
    );
  }
}

class FormSubmissionModel {
  final int id;
  final int formId;
  final int? taskId;
  final String data; // JSON string
  final String? ipAddress;
  final String? userAgent;
  final String createdAt;

  FormSubmissionModel({
    required this.id,
    required this.formId,
    this.taskId,
    required this.data,
    this.ipAddress,
    this.userAgent,
    required this.createdAt,
  });

  factory FormSubmissionModel.fromJson(Map<String, dynamic> json) {
    final dataField = json['data'];
    final dataString = dataField is String
        ? dataField
        : (dataField is Map ? jsonEncode(dataField) : '{}');

    return FormSubmissionModel(
      id: json['id'] as int,
      formId: json['formId'] as int,
      taskId: json['taskId'] as int?,
      data: dataString,
      ipAddress: json['ipAddress'] as String?,
      userAgent: json['userAgent'] as String?,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'formId': formId,
      if (taskId != null) 'taskId': taskId,
      'data': data,
      if (ipAddress != null) 'ipAddress': ipAddress,
      if (userAgent != null) 'userAgent': userAgent,
      'createdAt': createdAt,
    };
  }

  FormSubmissionEntity toEntity() {
    late Map<String, dynamic> dataMap;
    try {
      dataMap = jsonDecode(data);
    } catch (e) {
      dataMap = {};
    }

    return FormSubmissionEntity(
      id: id,
      formId: formId,
      taskId: taskId,
      data: dataMap,
      ipAddress: ipAddress,
      userAgent: userAgent,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
