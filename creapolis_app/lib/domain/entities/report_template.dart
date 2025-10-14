import 'package:equatable/equatable.dart';

/// Report template entity
class ReportTemplate extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<String> metrics;
  final String format;
  final ReportTemplateCategory category;

  const ReportTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.metrics,
    required this.format,
    required this.category,
  });

  /// Factory constructor from JSON
  factory ReportTemplate.fromJson(Map<String, dynamic> json) {
    return ReportTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      metrics: (json['metrics'] as List<dynamic>).map((e) => e as String).toList(),
      format: json['format'] as String,
      category: _getCategoryFromId(json['id'] as String),
    );
  }

  /// Get category from template ID
  static ReportTemplateCategory _getCategoryFromId(String id) {
    if (id.contains('team')) return ReportTemplateCategory.team;
    if (id.contains('time')) return ReportTemplateCategory.time;
    if (id.contains('executive')) return ReportTemplateCategory.executive;
    if (id.contains('workspace')) return ReportTemplateCategory.workspace;
    return ReportTemplateCategory.project;
  }

  @override
  List<Object?> get props => [id, name, description, metrics, format, category];
}

/// Category for report templates
enum ReportTemplateCategory {
  project,
  team,
  time,
  executive,
  workspace;

  String get label {
    switch (this) {
      case ReportTemplateCategory.project:
        return 'Proyecto';
      case ReportTemplateCategory.team:
        return 'Equipo';
      case ReportTemplateCategory.time:
        return 'Tiempo';
      case ReportTemplateCategory.executive:
        return 'Ejecutivo';
      case ReportTemplateCategory.workspace:
        return 'Workspace';
    }
  }

  String get icon {
    switch (this) {
      case ReportTemplateCategory.project:
        return '📊';
      case ReportTemplateCategory.team:
        return '👥';
      case ReportTemplateCategory.time:
        return '⏱️';
      case ReportTemplateCategory.executive:
        return '📈';
      case ReportTemplateCategory.workspace:
        return '🏢';
    }
  }
}

/// Scheduled report configuration
class ScheduledReport extends Equatable {
  final String id;
  final String name;
  final String templateId;
  final int entityId;
  final String entityType; // 'project' or 'workspace'
  final ReportScheduleFrequency frequency;
  final String exportFormat;
  final List<String> recipients;
  final bool isActive;
  final DateTime? lastSent;
  final DateTime? nextScheduled;

  const ScheduledReport({
    required this.id,
    required this.name,
    required this.templateId,
    required this.entityId,
    required this.entityType,
    required this.frequency,
    required this.exportFormat,
    required this.recipients,
    this.isActive = true,
    this.lastSent,
    this.nextScheduled,
  });

  ScheduledReport copyWith({
    String? id,
    String? name,
    String? templateId,
    int? entityId,
    String? entityType,
    ReportScheduleFrequency? frequency,
    String? exportFormat,
    List<String>? recipients,
    bool? isActive,
    DateTime? lastSent,
    DateTime? nextScheduled,
  }) {
    return ScheduledReport(
      id: id ?? this.id,
      name: name ?? this.name,
      templateId: templateId ?? this.templateId,
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
      frequency: frequency ?? this.frequency,
      exportFormat: exportFormat ?? this.exportFormat,
      recipients: recipients ?? this.recipients,
      isActive: isActive ?? this.isActive,
      lastSent: lastSent ?? this.lastSent,
      nextScheduled: nextScheduled ?? this.nextScheduled,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        templateId,
        entityId,
        entityType,
        frequency,
        exportFormat,
        recipients,
        isActive,
        lastSent,
        nextScheduled,
      ];
}

/// Frequency for scheduled reports
enum ReportScheduleFrequency {
  daily,
  weekly,
  biweekly,
  monthly;

  String get label {
    switch (this) {
      case ReportScheduleFrequency.daily:
        return 'Diario';
      case ReportScheduleFrequency.weekly:
        return 'Semanal';
      case ReportScheduleFrequency.biweekly:
        return 'Quincenal';
      case ReportScheduleFrequency.monthly:
        return 'Mensual';
    }
  }
}
