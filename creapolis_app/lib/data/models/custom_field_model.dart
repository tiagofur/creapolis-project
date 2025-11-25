import 'package:equatable/equatable.dart';

import '../../domain/entities/custom_field.dart' as domain;

/// Types of custom fields available
enum CustomFieldType {
  text,
  textarea,
  number,
  date,
  datetime,
  dropdown,
  multiSelect,
  checkbox,
  user,
  url,
  email,
  phone,
  currency,
  percentage,
  rating,
  labels;

  String get displayName {
    switch (this) {
      case CustomFieldType.text:
        return 'Text';
      case CustomFieldType.textarea:
        return 'Text Area';
      case CustomFieldType.number:
        return 'Number';
      case CustomFieldType.date:
        return 'Date';
      case CustomFieldType.datetime:
        return 'Date & Time';
      case CustomFieldType.dropdown:
        return 'Dropdown';
      case CustomFieldType.multiSelect:
        return 'Multi-Select';
      case CustomFieldType.checkbox:
        return 'Checkbox';
      case CustomFieldType.user:
        return 'User';
      case CustomFieldType.url:
        return 'URL';
      case CustomFieldType.email:
        return 'Email';
      case CustomFieldType.phone:
        return 'Phone';
      case CustomFieldType.currency:
        return 'Currency';
      case CustomFieldType.percentage:
        return 'Percentage';
      case CustomFieldType.rating:
        return 'Rating';
      case CustomFieldType.labels:
        return 'Labels';
    }
  }

  static CustomFieldType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'TEXT':
        return CustomFieldType.text;
      case 'TEXTAREA':
        return CustomFieldType.textarea;
      case 'NUMBER':
        return CustomFieldType.number;
      case 'DATE':
        return CustomFieldType.date;
      case 'DATETIME':
        return CustomFieldType.datetime;
      case 'DROPDOWN':
        return CustomFieldType.dropdown;
      case 'MULTI_SELECT':
        return CustomFieldType.multiSelect;
      case 'CHECKBOX':
        return CustomFieldType.checkbox;
      case 'USER':
        return CustomFieldType.user;
      case 'URL':
        return CustomFieldType.url;
      case 'EMAIL':
        return CustomFieldType.email;
      case 'PHONE':
        return CustomFieldType.phone;
      case 'CURRENCY':
        return CustomFieldType.currency;
      case 'PERCENTAGE':
        return CustomFieldType.percentage;
      case 'RATING':
        return CustomFieldType.rating;
      case 'LABELS':
        return CustomFieldType.labels;
      default:
        return CustomFieldType.text;
    }
  }

  String toApiString() {
    switch (this) {
      case CustomFieldType.text:
        return 'TEXT';
      case CustomFieldType.textarea:
        return 'TEXTAREA';
      case CustomFieldType.number:
        return 'NUMBER';
      case CustomFieldType.date:
        return 'DATE';
      case CustomFieldType.datetime:
        return 'DATETIME';
      case CustomFieldType.dropdown:
        return 'DROPDOWN';
      case CustomFieldType.multiSelect:
        return 'MULTI_SELECT';
      case CustomFieldType.checkbox:
        return 'CHECKBOX';
      case CustomFieldType.user:
        return 'USER';
      case CustomFieldType.url:
        return 'URL';
      case CustomFieldType.email:
        return 'EMAIL';
      case CustomFieldType.phone:
        return 'PHONE';
      case CustomFieldType.currency:
        return 'CURRENCY';
      case CustomFieldType.percentage:
        return 'PERCENTAGE';
      case CustomFieldType.rating:
        return 'RATING';
      case CustomFieldType.labels:
        return 'LABELS';
    }
  }
}

/// Definition of a custom field (at project level)
class CustomFieldDefinitionModel extends Equatable {
  final int id;
  final int projectId;
  final String name;
  final CustomFieldType fieldType;
  final String? description;
  final bool isRequired;
  final dynamic defaultValue;
  final List<String>? options;
  final int order;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomFieldDefinitionModel({
    required this.id,
    required this.projectId,
    required this.name,
    required this.fieldType,
    this.description,
    required this.isRequired,
    this.defaultValue,
    this.options,
    required this.order,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomFieldDefinitionModel.fromJson(Map<String, dynamic> json) {
    return CustomFieldDefinitionModel(
      id: json['id'] as int,
      projectId: json['projectId'] as int,
      name: json['name'] as String,
      fieldType: CustomFieldType.fromString(json['fieldType'] as String),
      description: json['description'] as String?,
      isRequired: json['isRequired'] as bool? ?? false,
      defaultValue: json['defaultValue'],
      options: json['options'] != null
          ? List<String>.from(json['options'] as List)
          : null,
      order: json['order'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'name': name,
      'fieldType': fieldType.toApiString(),
      'description': description,
      'isRequired': isRequired,
      'defaultValue': defaultValue,
      'options': options,
      'order': order,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  CustomFieldDefinitionModel copyWith({
    int? id,
    int? projectId,
    String? name,
    CustomFieldType? fieldType,
    String? description,
    bool? isRequired,
    dynamic defaultValue,
    List<String>? options,
    int? order,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomFieldDefinitionModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      fieldType: fieldType ?? this.fieldType,
      description: description ?? this.description,
      isRequired: isRequired ?? this.isRequired,
      defaultValue: defaultValue ?? this.defaultValue,
      options: options ?? this.options,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    projectId,
    name,
    fieldType,
    description,
    isRequired,
    defaultValue,
    options,
    order,
    isActive,
    createdAt,
    updatedAt,
  ];

  /// Convert to domain entity
  domain.CustomFieldDefinition toEntity() {
    return domain.CustomFieldDefinition(
      id: id,
      name: name,
      description: description,
      type: _toDomainType(fieldType),
      isRequired: isRequired,
      isActive: isActive,
      defaultValue: defaultValue,
      options: options != null ? {'choices': options} : null,
      order: order,
      projectId: projectId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static domain.CustomFieldType _toDomainType(CustomFieldType type) {
    switch (type) {
      case CustomFieldType.text:
        return domain.CustomFieldType.text;
      case CustomFieldType.textarea:
        return domain.CustomFieldType.textarea;
      case CustomFieldType.number:
        return domain.CustomFieldType.number;
      case CustomFieldType.date:
        return domain.CustomFieldType.date;
      case CustomFieldType.datetime:
        return domain.CustomFieldType.datetime;
      case CustomFieldType.dropdown:
        return domain.CustomFieldType.dropdown;
      case CustomFieldType.multiSelect:
        return domain.CustomFieldType.multiselect;
      case CustomFieldType.checkbox:
        return domain.CustomFieldType.checkbox;
      case CustomFieldType.user:
        return domain.CustomFieldType.user;
      case CustomFieldType.url:
        return domain.CustomFieldType.url;
      case CustomFieldType.email:
        return domain.CustomFieldType.email;
      case CustomFieldType.phone:
        return domain.CustomFieldType.phone;
      case CustomFieldType.currency:
        return domain.CustomFieldType.currency;
      case CustomFieldType.percentage:
        return domain.CustomFieldType.percentage;
      case CustomFieldType.rating:
        return domain.CustomFieldType.number;
      case CustomFieldType.labels:
        return domain.CustomFieldType.multiselect;
    }
  }

  static CustomFieldType fromDomainType(domain.CustomFieldType type) {
    switch (type) {
      case domain.CustomFieldType.text:
        return CustomFieldType.text;
      case domain.CustomFieldType.textarea:
        return CustomFieldType.textarea;
      case domain.CustomFieldType.number:
      case domain.CustomFieldType.decimal:
        return CustomFieldType.number;
      case domain.CustomFieldType.date:
        return CustomFieldType.date;
      case domain.CustomFieldType.datetime:
        return CustomFieldType.datetime;
      case domain.CustomFieldType.dropdown:
        return CustomFieldType.dropdown;
      case domain.CustomFieldType.multiselect:
        return CustomFieldType.multiSelect;
      case domain.CustomFieldType.checkbox:
        return CustomFieldType.checkbox;
      case domain.CustomFieldType.user:
      case domain.CustomFieldType.multiuser:
        return CustomFieldType.user;
      case domain.CustomFieldType.url:
        return CustomFieldType.url;
      case domain.CustomFieldType.email:
        return CustomFieldType.email;
      case domain.CustomFieldType.phone:
        return CustomFieldType.phone;
      case domain.CustomFieldType.currency:
        return CustomFieldType.currency;
      case domain.CustomFieldType.percentage:
        return CustomFieldType.percentage;
    }
  }
}

/// Value of a custom field for a specific task
class CustomFieldValueModel extends Equatable {
  final int fieldId;
  final String fieldName;
  final CustomFieldType fieldType;
  final dynamic value;
  final List<String>? options;

  const CustomFieldValueModel({
    required this.fieldId,
    required this.fieldName,
    required this.fieldType,
    this.value,
    this.options,
  });

  factory CustomFieldValueModel.fromJson(Map<String, dynamic> json) {
    return CustomFieldValueModel(
      fieldId: json['fieldId'] as int,
      fieldName: json['fieldName'] as String,
      fieldType: CustomFieldType.fromString(json['fieldType'] as String),
      value: json['value'],
      options: json['options'] != null
          ? List<String>.from(json['options'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fieldId': fieldId,
      'fieldName': fieldName,
      'fieldType': fieldType.toApiString(),
      'value': value,
      'options': options,
    };
  }

  CustomFieldValueModel copyWith({
    int? fieldId,
    String? fieldName,
    CustomFieldType? fieldType,
    dynamic value,
    List<String>? options,
  }) {
    return CustomFieldValueModel(
      fieldId: fieldId ?? this.fieldId,
      fieldName: fieldName ?? this.fieldName,
      fieldType: fieldType ?? this.fieldType,
      value: value ?? this.value,
      options: options ?? this.options,
    );
  }

  /// Get formatted display value
  String get displayValue {
    if (value == null) return '-';

    switch (fieldType) {
      case CustomFieldType.checkbox:
        return value == true ? 'Yes' : 'No';
      case CustomFieldType.date:
        final date = DateTime.tryParse(value.toString());
        if (date != null) {
          return '${date.day}/${date.month}/${date.year}';
        }
        return value.toString();
      case CustomFieldType.datetime:
        final dateTime = DateTime.tryParse(value.toString());
        if (dateTime != null) {
          return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
        }
        return value.toString();
      case CustomFieldType.multiSelect:
      case CustomFieldType.labels:
        if (value is List) {
          return (value as List).join(', ');
        }
        return value.toString();
      case CustomFieldType.percentage:
        return '$value%';
      case CustomFieldType.currency:
        return '\$$value';
      case CustomFieldType.rating:
        return '⭐' * (value as int? ?? 0);
      default:
        return value.toString();
    }
  }

  @override
  List<Object?> get props => [fieldId, fieldName, fieldType, value, options];

  /// Convert to domain entity
  domain.CustomFieldValue toEntity() {
    return domain.CustomFieldValue(
      id: 0, // Value model doesn't have ID in current structure
      taskId: 0, // Not available in current model
      fieldId: fieldId,
      value: value,
      fieldDefinition: null, // Would need to be populated separately
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

/// Request model for creating/updating a custom field definition
class CreateCustomFieldRequest {
  final String name;
  final CustomFieldType fieldType;
  final String? description;
  final bool isRequired;
  final dynamic defaultValue;
  final List<String>? options;
  final int? order;

  CreateCustomFieldRequest({
    required this.name,
    required this.fieldType,
    this.description,
    this.isRequired = false,
    this.defaultValue,
    this.options,
    this.order,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'fieldType': fieldType.toApiString(),
      if (description != null) 'description': description,
      'isRequired': isRequired,
      if (defaultValue != null) 'defaultValue': defaultValue,
      if (options != null) 'options': options,
      if (order != null) 'order': order,
    };
  }
}
