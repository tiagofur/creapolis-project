import 'package:equatable/equatable.dart';

/// Types of custom fields available
enum CustomFieldType {
  text,
  textarea,
  number,
  decimal,
  currency,
  percentage,
  date,
  datetime,
  checkbox,
  dropdown,
  multiselect,
  user,
  multiuser,
  url,
  email,
  phone;

  String get displayName {
    switch (this) {
      case CustomFieldType.text:
        return 'Text';
      case CustomFieldType.textarea:
        return 'Long Text';
      case CustomFieldType.number:
        return 'Number';
      case CustomFieldType.decimal:
        return 'Decimal';
      case CustomFieldType.currency:
        return 'Currency';
      case CustomFieldType.percentage:
        return 'Percentage';
      case CustomFieldType.date:
        return 'Date';
      case CustomFieldType.datetime:
        return 'Date & Time';
      case CustomFieldType.checkbox:
        return 'Checkbox';
      case CustomFieldType.dropdown:
        return 'Dropdown';
      case CustomFieldType.multiselect:
        return 'Multi-select';
      case CustomFieldType.user:
        return 'User';
      case CustomFieldType.multiuser:
        return 'Multiple Users';
      case CustomFieldType.url:
        return 'URL';
      case CustomFieldType.email:
        return 'Email';
      case CustomFieldType.phone:
        return 'Phone';
    }
  }
}

/// Definition of a custom field for a project
class CustomFieldDefinition extends Equatable {
  final int id;
  final String name;
  final String? description;
  final CustomFieldType type;
  final bool isRequired;
  final bool isActive;
  final dynamic defaultValue;
  final Map<String, dynamic>? options;
  final int order;
  final int projectId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomFieldDefinition({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    this.isRequired = false,
    this.isActive = true,
    this.defaultValue,
    this.options,
    required this.order,
    required this.projectId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get dropdown/multiselect options as a list
  List<String> get dropdownOptions {
    if (options == null) return [];
    final choices = options!['choices'] as List<dynamic>?;
    return choices?.map((e) => e.toString()).toList() ?? [];
  }

  /// Get currency code if applicable
  String? get currencyCode {
    if (type != CustomFieldType.currency) return null;
    return options?['currency'] as String? ?? 'USD';
  }

  /// Get min/max values for number fields
  num? get minValue => options?['min'] as num?;
  num? get maxValue => options?['max'] as num?;

  CustomFieldDefinition copyWith({
    int? id,
    String? name,
    String? description,
    CustomFieldType? type,
    bool? isRequired,
    bool? isActive,
    dynamic defaultValue,
    Map<String, dynamic>? options,
    int? order,
    int? projectId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomFieldDefinition(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      isRequired: isRequired ?? this.isRequired,
      isActive: isActive ?? this.isActive,
      defaultValue: defaultValue ?? this.defaultValue,
      options: options ?? this.options,
      order: order ?? this.order,
      projectId: projectId ?? this.projectId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    type,
    isRequired,
    isActive,
    defaultValue,
    options,
    order,
    projectId,
    createdAt,
    updatedAt,
  ];
}

/// Value of a custom field for a specific task
class CustomFieldValue extends Equatable {
  final int id;
  final int taskId;
  final int fieldId;
  final dynamic value;
  final CustomFieldDefinition? fieldDefinition;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomFieldValue({
    required this.id,
    required this.taskId,
    required this.fieldId,
    this.value,
    this.fieldDefinition,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get value formatted as string based on field type
  String get displayValue {
    if (value == null) return '';
    if (fieldDefinition == null) return value.toString();

    switch (fieldDefinition!.type) {
      case CustomFieldType.checkbox:
        return value == true ? 'Yes' : 'No';
      case CustomFieldType.currency:
        final currency = fieldDefinition!.currencyCode ?? 'USD';
        return '$currency ${value.toString()}';
      case CustomFieldType.percentage:
        return '${value.toString()}%';
      case CustomFieldType.multiselect:
      case CustomFieldType.multiuser:
        if (value is List) {
          return (value as List).join(', ');
        }
        return value.toString();
      case CustomFieldType.date:
        if (value is DateTime) {
          return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
        }
        return value.toString();
      case CustomFieldType.datetime:
        if (value is DateTime) {
          return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
        }
        return value.toString();
      default:
        return value.toString();
    }
  }

  CustomFieldValue copyWith({
    int? id,
    int? taskId,
    int? fieldId,
    dynamic value,
    CustomFieldDefinition? fieldDefinition,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomFieldValue(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      fieldId: fieldId ?? this.fieldId,
      value: value ?? this.value,
      fieldDefinition: fieldDefinition ?? this.fieldDefinition,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    taskId,
    fieldId,
    value,
    fieldDefinition,
    createdAt,
    updatedAt,
  ];
}
