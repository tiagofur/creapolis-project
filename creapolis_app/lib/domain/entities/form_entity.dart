import 'package:equatable/equatable.dart';

/// Tipos de campos de formulario
enum FormFieldType {
  text,
  textarea,
  number,
  email,
  phone,
  url,
  date,
  time,
  datetime,
  dropdown,
  radio,
  checkbox,
  file,
  rating,
}

/// Campo de formulario
class FormField extends Equatable {
  final String id;
  final FormFieldType type;
  final String label;
  final String? placeholder;
  final String? helpText;
  final bool required;
  final String? mapTo; // Field to map in Task (title, description, priority, etc.)
  final List<String>? options; // For dropdown, radio, checkbox
  final int? minLength;
  final int? maxLength;
  final dynamic min; // For number fields
  final dynamic max; // For number fields
  final String? pattern; // Regex pattern for validation
  final dynamic defaultValue;
  final int order;

  const FormField({
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

  @override
  List<Object?> get props => [
        id,
        type,
        label,
        placeholder,
        helpText,
        required,
        mapTo,
        options,
        minLength,
        maxLength,
        min,
        max,
        pattern,
        defaultValue,
        order,
      ];

  FormField copyWith({
    String? id,
    FormFieldType? type,
    String? label,
    String? placeholder,
    String? helpText,
    bool? required,
    String? mapTo,
    List<String>? options,
    int? minLength,
    int? maxLength,
    dynamic min,
    dynamic max,
    String? pattern,
    dynamic defaultValue,
    int? order,
  }) {
    return FormField(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      placeholder: placeholder ?? this.placeholder,
      helpText: helpText ?? this.helpText,
      required: required ?? this.required,
      mapTo: mapTo ?? this.mapTo,
      options: options ?? this.options,
      minLength: minLength ?? this.minLength,
      maxLength: maxLength ?? this.maxLength,
      min: min ?? this.min,
      max: max ?? this.max,
      pattern: pattern ?? this.pattern,
      defaultValue: defaultValue ?? this.defaultValue,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'label': label,
      'placeholder': placeholder,
      'helpText': helpText,
      'required': required,
      'mapTo': mapTo,
      'options': options,
      'minLength': minLength,
      'maxLength': maxLength,
      'min': min,
      'max': max,
      'pattern': pattern,
      'defaultValue': defaultValue,
      'order': order,
    };
  }

  factory FormField.fromJson(Map<String, dynamic> json) {
    return FormField(
      id: json['id'] as String,
      type: FormFieldType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FormFieldType.text,
      ),
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
}

/// Configuración del formulario
class FormConfig extends Equatable {
  final List<FormField> fields;
  final FormSettings settings;

  const FormConfig({
    required this.fields,
    required this.settings,
  });

  @override
  List<Object?> get props => [fields, settings];

  FormConfig copyWith({
    List<FormField>? fields,
    FormSettings? settings,
  }) {
    return FormConfig(
      fields: fields ?? this.fields,
      settings: settings ?? this.settings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fields': fields.map((f) => f.toJson()).toList(),
      'settings': settings.toJson(),
    };
  }

  factory FormConfig.fromJson(Map<String, dynamic> json) {
    return FormConfig(
      fields: (json['fields'] as List<dynamic>?)
              ?.map((e) => FormField.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      settings: FormSettings.fromJson(
          json['settings'] as Map<String, dynamic>? ?? {}),
    );
  }
}

/// Configuración adicional del formulario
class FormSettings extends Equatable {
  final int? defaultAssigneeId;
  final String? defaultPriority;
  final String? defaultStatus;
  final String confirmationMessage;
  final bool autoCreateTask;
  final bool notifyOnSubmission;

  const FormSettings({
    this.defaultAssigneeId,
    this.defaultPriority = 'MEDIUM',
    this.defaultStatus = 'PLANNED',
    this.confirmationMessage = 'Thank you for your submission!',
    this.autoCreateTask = true,
    this.notifyOnSubmission = false,
  });

  @override
  List<Object?> get props => [
        defaultAssigneeId,
        defaultPriority,
        defaultStatus,
        confirmationMessage,
        autoCreateTask,
        notifyOnSubmission,
      ];

  FormSettings copyWith({
    int? defaultAssigneeId,
    String? defaultPriority,
    String? defaultStatus,
    String? confirmationMessage,
    bool? autoCreateTask,
    bool? notifyOnSubmission,
  }) {
    return FormSettings(
      defaultAssigneeId: defaultAssigneeId ?? this.defaultAssigneeId,
      defaultPriority: defaultPriority ?? this.defaultPriority,
      defaultStatus: defaultStatus ?? this.defaultStatus,
      confirmationMessage: confirmationMessage ?? this.confirmationMessage,
      autoCreateTask: autoCreateTask ?? this.autoCreateTask,
      notifyOnSubmission: notifyOnSubmission ?? this.notifyOnSubmission,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultAssigneeId': defaultAssigneeId,
      'defaultPriority': defaultPriority,
      'defaultStatus': defaultStatus,
      'confirmationMessage': confirmationMessage,
      'autoCreateTask': autoCreateTask,
      'notifyOnSubmission': notifyOnSubmission,
    };
  }

  factory FormSettings.fromJson(Map<String, dynamic> json) {
    return FormSettings(
      defaultAssigneeId: json['defaultAssigneeId'] as int?,
      defaultPriority: json['defaultPriority'] as String? ?? 'MEDIUM',
      defaultStatus: json['defaultStatus'] as String? ?? 'PLANNED',
      confirmationMessage: json['confirmationMessage'] as String? ??
          'Thank you for your submission!',
      autoCreateTask: json['autoCreateTask'] as bool? ?? true,
      notifyOnSubmission: json['notifyOnSubmission'] as bool? ?? false,
    );
  }
}

/// Entidad de Formulario
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
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? submissionCount;

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
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.submissionCount,
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
        createdBy,
        createdAt,
        updatedAt,
        submissionCount,
      ];

  FormEntity copyWith({
    int? id,
    int? projectId,
    String? title,
    String? description,
    bool? isActive,
    String? publicLink,
    FormConfig? config,
    int? viewCount,
    int? submitCount,
    int? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? submissionCount,
  }) {
    return FormEntity(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      publicLink: publicLink ?? this.publicLink,
      config: config ?? this.config,
      viewCount: viewCount ?? this.viewCount,
      submitCount: submitCount ?? this.submitCount,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      submissionCount: submissionCount ?? this.submissionCount,
    );
  }

  String getPublicUrl(String baseUrl) {
    return '$baseUrl/forms/$publicLink';
  }

  double get completionRate {
    if (viewCount == 0) return 0.0;
    return (submitCount / viewCount) * 100;
  }
}

/// Entidad de Submission
class FormSubmissionEntity extends Equatable {
  final int id;
  final int formId;
  final int? taskId;
  final Map<String, dynamic> data;
  final String? ipAddress;
  final String? userAgent;
  final DateTime createdAt;

  const FormSubmissionEntity({
    required this.id,
    required this.formId,
    this.taskId,
    required this.data,
    this.ipAddress,
    this.userAgent,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        formId,
        taskId,
        data,
        ipAddress,
        userAgent,
        createdAt,
      ];

  bool get hasTask => taskId != null;
}
