import 'package:flutter/material.dart';

import '../../../domain/entities/report.dart';

/// Widget for selecting report metrics
class MetricsSelectorWidget extends StatelessWidget {
  final ReportMetrics metrics;
  final ReportType reportType;
  final ValueChanged<ReportMetrics> onChanged;

  const MetricsSelectorWidget({
    super.key,
    required this.metrics,
    required this.reportType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MetricCheckbox(
          label: 'Tareas',
          description: 'Métricas sobre tareas y su estado',
          icon: Icons.task_alt,
          value: metrics.includeTasks,
          onChanged: (value) {
            onChanged(metrics.copyWith(includeTasks: value));
          },
        ),
        _MetricCheckbox(
          label: 'Progreso',
          description: 'Análisis de progreso y velocidad',
          icon: Icons.trending_up,
          value: metrics.includeProgress,
          onChanged: (value) {
            onChanged(metrics.copyWith(includeProgress: value));
          },
        ),
        _MetricCheckbox(
          label: 'Tiempo',
          description: 'Seguimiento de horas y estimaciones',
          icon: Icons.access_time,
          value: metrics.includeTime,
          onChanged: (value) {
            onChanged(metrics.copyWith(includeTime: value));
          },
        ),
        _MetricCheckbox(
          label: 'Equipo',
          description: 'Desempeño y carga de trabajo del equipo',
          icon: Icons.group,
          value: metrics.includeTeam,
          onChanged: (value) {
            onChanged(metrics.copyWith(includeTeam: value));
          },
        ),
        if (reportType == ReportType.workspace) ...[
          _MetricCheckbox(
            label: 'Proyectos',
            description: 'Resumen de proyectos del workspace',
            icon: Icons.folder_open,
            value: metrics.includeProjects,
            onChanged: (value) {
              onChanged(metrics.copyWith(includeProjects: value));
            },
          ),
          _MetricCheckbox(
            label: 'Productividad',
            description: 'Análisis de productividad general',
            icon: Icons.speed,
            value: metrics.includeProductivity,
            onChanged: (value) {
              onChanged(metrics.copyWith(includeProductivity: value));
            },
          ),
        ],
      ],
    );
  }
}

/// Checkbox for individual metric
class _MetricCheckbox extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _MetricCheckbox({
    required this.label,
    required this.description,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: (val) => onChanged(val ?? false),
      title: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      subtitle: Text(
        description,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
