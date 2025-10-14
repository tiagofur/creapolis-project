import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/report.dart';
import '../../services/report_service.dart';

/// Screen for previewing generated reports
class ReportPreviewScreen extends StatefulWidget {
  final Report report;
  final ReportService reportService;

  const ReportPreviewScreen({
    super.key,
    required this.report,
    required this.reportService,
  });

  @override
  State<ReportPreviewScreen> createState() => _ReportPreviewScreenState();
}

class _ReportPreviewScreenState extends State<ReportPreviewScreen> {
  bool _isExporting = false;

  Future<void> _exportReport(ReportExportFormat format) async {
    setState(() => _isExporting = true);

    try {
      final filePath = await widget.reportService.exportReport(
        report: widget.report,
        format: format,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reporte exportado: $filePath'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Ver',
            onPressed: () {
              // Could open file manager or share
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al exportar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _shareReport(ReportExportFormat format) async {
    setState(() => _isExporting = true);

    try {
      await widget.reportService.shareReport(
        report: widget.report,
        format: format,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al compartir: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Exportar Reporte',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Exportar como PDF'),
              onTap: () {
                Navigator.pop(context);
                _exportReport(ReportExportFormat.pdf);
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Exportar como Excel'),
              onTap: () {
                Navigator.pop(context);
                _exportReport(ReportExportFormat.excel);
              },
            ),
            ListTile(
              leading: const Icon(Icons.text_snippet),
              title: const Text('Exportar como CSV'),
              onTap: () {
                Navigator.pop(context);
                _exportReport(ReportExportFormat.csv);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Compartir'),
              onTap: () {
                Navigator.pop(context);
                _showShareOptions();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Compartir como',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF'),
              onTap: () {
                Navigator.pop(context);
                _shareReport(ReportExportFormat.pdf);
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Excel'),
              onTap: () {
                Navigator.pop(context);
                _shareReport(ReportExportFormat.excel);
              },
            ),
            ListTile(
              leading: const Icon(Icons.text_snippet),
              title: const Text('CSV'),
              onTap: () {
                Navigator.pop(context);
                _shareReport(ReportExportFormat.csv);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista Previa del Reporte'),
        actions: [
          if (_isExporting)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _showExportOptions,
              tooltip: 'Exportar',
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildMetricsCards(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.report.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generado: ${DateFormat('dd/MM/yyyy HH:mm').format(widget.report.generatedAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (widget.report.startDate != null && widget.report.endDate != null) ...[
              const SizedBox(height: 4),
              Text(
                'Período: ${DateFormat('dd/MM/yyyy').format(widget.report.startDate!)} - ${DateFormat('dd/MM/yyyy').format(widget.report.endDate!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsCards() {
    final metrics = widget.report.data['metrics'] as Map<String, dynamic>?;
    
    if (metrics == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No hay datos de métricas disponibles'),
        ),
      );
    }

    return Column(
      children: [
        if (metrics.containsKey('tasks'))
          _buildTasksMetric(metrics['tasks']),
        if (metrics.containsKey('progress'))
          _buildProgressMetric(metrics['progress']),
        if (metrics.containsKey('time'))
          _buildTimeMetric(metrics['time']),
        if (metrics.containsKey('team'))
          _buildTeamMetric(metrics['team']),
        if (metrics.containsKey('projects'))
          _buildProjectsMetric(metrics['projects']),
        if (metrics.containsKey('productivity'))
          _buildProductivityMetric(metrics['productivity']),
      ],
    );
  }

  Widget _buildTasksMetric(Map<String, dynamic> tasks) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.task_alt, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Tareas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(),
            _MetricRow(label: 'Total', value: tasks['total'].toString()),
            _MetricRow(label: 'Planificadas', value: tasks['byStatus']['planned'].toString()),
            _MetricRow(label: 'En Progreso', value: tasks['byStatus']['inProgress'].toString()),
            _MetricRow(label: 'Completadas', value: tasks['byStatus']['completed'].toString()),
            _MetricRow(label: 'Tasa de Completitud', value: '${tasks['completionRate']}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressMetric(Map<String, dynamic> progress) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Progreso',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(),
            _MetricRow(label: 'Progreso General', value: '${progress['overallProgress']}%'),
            _MetricRow(label: 'Velocidad', value: progress['velocity'].toString()),
            _MetricRow(label: 'Tareas Atrasadas', value: progress['overdueTasks'].toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeMetric(Map<String, dynamic> time) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Tiempo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(),
            _MetricRow(label: 'Horas Estimadas', value: '${time['totalEstimatedHours']} hrs'),
            _MetricRow(label: 'Horas Reales', value: '${time['totalActualHours']} hrs'),
            _MetricRow(label: 'Varianza', value: '${time['variance']} hrs'),
            _MetricRow(label: 'Eficiencia', value: '${time['efficiency']}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMetric(Map<String, dynamic> team) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.group, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Equipo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(),
            _MetricRow(label: 'Tamaño del Equipo', value: team['teamSize'].toString()),
            _MetricRow(label: 'Tareas Asignadas', value: team['assignedTasks'].toString()),
            _MetricRow(label: 'Tareas Sin Asignar', value: team['unassignedTasks'].toString()),
            _MetricRow(label: 'Promedio por Miembro', value: team['averageTasksPerMember'].toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsMetric(Map<String, dynamic> projects) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.folder_open, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Proyectos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(),
            _MetricRow(label: 'Total', value: projects['total'].toString()),
            _MetricRow(label: 'Con Tareas', value: projects['withTasks'].toString()),
            _MetricRow(label: 'Total de Tareas', value: projects['totalTasks'].toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildProductivityMetric(Map<String, dynamic> productivity) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.speed, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Productividad',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(),
            _MetricRow(label: 'Tareas Completadas', value: productivity['completedTasks'].toString()),
            _MetricRow(label: 'Horas Totales', value: '${productivity['totalHours']} hrs'),
            _MetricRow(label: 'Tasa de Productividad', value: '${productivity['productivityRate']}%'),
          ],
        ),
      ),
    );
  }
}

/// Metric row widget
class _MetricRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetricRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
