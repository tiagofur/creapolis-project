import 'package:equatable/equatable.dart';

/// Report entity representing generated reports
class Report extends Equatable {
  final String id;
  final String name;
  final ReportType type;
  final int entityId; // Project or Workspace ID
  final Map<String, dynamic> data;
  final DateTime generatedAt;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> metrics;
  final String? templateId;

  const Report({
    required this.id,
    required this.name,
    required this.type,
    required this.entityId,
    required this.data,
    required this.generatedAt,
    this.startDate,
    this.endDate,
    required this.metrics,
    this.templateId,
  });

  Report copyWith({
    String? id,
    String? name,
    ReportType? type,
    int? entityId,
    Map<String, dynamic>? data,
    DateTime? generatedAt,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? metrics,
    String? templateId,
  }) {
    return Report(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      entityId: entityId ?? this.entityId,
      data: data ?? this.data,
      generatedAt: generatedAt ?? this.generatedAt,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      metrics: metrics ?? this.metrics,
      templateId: templateId ?? this.templateId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        entityId,
        data,
        generatedAt,
        startDate,
        endDate,
        metrics,
        templateId,
      ];
}

/// Type of report
enum ReportType {
  project,
  workspace;

  String get label {
    switch (this) {
      case ReportType.project:
        return 'Proyecto';
      case ReportType.workspace:
        return 'Workspace';
    }
  }
}

/// Export format for reports
enum ReportExportFormat {
  json,
  csv,
  excel,
  pdf;

  String get label {
    switch (this) {
      case ReportExportFormat.json:
        return 'JSON';
      case ReportExportFormat.csv:
        return 'CSV';
      case ReportExportFormat.excel:
        return 'Excel';
      case ReportExportFormat.pdf:
        return 'PDF';
    }
  }

  String get fileExtension {
    switch (this) {
      case ReportExportFormat.json:
        return 'json';
      case ReportExportFormat.csv:
        return 'csv';
      case ReportExportFormat.excel:
        return 'xlsx';
      case ReportExportFormat.pdf:
        return 'pdf';
    }
  }

  String get mimeType {
    switch (this) {
      case ReportExportFormat.json:
        return 'application/json';
      case ReportExportFormat.csv:
        return 'text/csv';
      case ReportExportFormat.excel:
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case ReportExportFormat.pdf:
        return 'application/pdf';
    }
  }
}

/// Report metrics configuration
class ReportMetrics extends Equatable {
  final bool includeTasks;
  final bool includeProgress;
  final bool includeTime;
  final bool includeTeam;
  final bool includeProjects;
  final bool includeProductivity;

  const ReportMetrics({
    this.includeTasks = true,
    this.includeProgress = true,
    this.includeTime = true,
    this.includeTeam = true,
    this.includeProjects = false,
    this.includeProductivity = false,
  });

  /// Get list of metric names that are enabled
  List<String> get enabledMetrics {
    final List<String> metrics = [];
    if (includeTasks) metrics.add('tasks');
    if (includeProgress) metrics.add('progress');
    if (includeTime) metrics.add('time');
    if (includeTeam) metrics.add('team');
    if (includeProjects) metrics.add('projects');
    if (includeProductivity) metrics.add('productivity');
    return metrics;
  }

  ReportMetrics copyWith({
    bool? includeTasks,
    bool? includeProgress,
    bool? includeTime,
    bool? includeTeam,
    bool? includeProjects,
    bool? includeProductivity,
  }) {
    return ReportMetrics(
      includeTasks: includeTasks ?? this.includeTasks,
      includeProgress: includeProgress ?? this.includeProgress,
      includeTime: includeTime ?? this.includeTime,
      includeTeam: includeTeam ?? this.includeTeam,
      includeProjects: includeProjects ?? this.includeProjects,
      includeProductivity: includeProductivity ?? this.includeProductivity,
    );
  }

  @override
  List<Object?> get props => [
        includeTasks,
        includeProgress,
        includeTime,
        includeTeam,
        includeProjects,
        includeProductivity,
      ];
}



