import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/project.dart';
import '../../../domain/entities/report.dart';
import '../../../domain/entities/workspace.dart';
import '../../services/report_service.dart';
import '../widgets/metrics_selector_widget.dart';
import 'report_preview_screen.dart';

/// Screen for building custom reports
class ReportBuilderScreen extends StatefulWidget {
  final ReportService reportService;
  final Project? project;
  final Workspace? workspace;

  const ReportBuilderScreen({
    super.key,
    required this.reportService,
    this.project,
    this.workspace,
  });

  @override
  State<ReportBuilderScreen> createState() => _ReportBuilderScreenState();
}

class _ReportBuilderScreenState extends State<ReportBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _reportName = '';
  ReportMetrics _metrics = const ReportMetrics();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isGenerating = false;

  ReportType get _reportType {
    if (widget.project != null) return ReportType.project;
    return ReportType.workspace;
  }

  String get _entityName {
    if (widget.project != null) return widget.project!.name;
    if (widget.workspace != null) return widget.workspace!.name;
    return 'N/A';
  }

  int get _entityId {
    if (widget.project != null) return widget.project!.id;
    if (widget.workspace != null) return widget.workspace!.id;
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _reportName = 'Reporte de $_entityName';
  }

  Future<void> _generateReport() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isGenerating = true);

    try {
      Report report;
      
      if (_reportType == ReportType.project) {
        report = await widget.reportService.generateProjectReport(
          projectId: _entityId,
          metrics: _metrics.enabledMetrics,
          startDate: _startDate,
          endDate: _endDate,
        );
      } else {
        report = await widget.reportService.generateWorkspaceReport(
          workspaceId: _entityId,
          metrics: _metrics.enabledMetrics,
          startDate: _startDate,
          endDate: _endDate,
        );
      }

      if (!mounted) return;

      // Navigate to preview
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ReportPreviewScreen(
            report: report,
            reportService: widget.reportService,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar reporte: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Reporte'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelp,
            tooltip: 'Ayuda',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildEntityCard(),
            const SizedBox(height: 16),
            _buildReportNameField(),
            const SizedBox(height: 16),
            _buildDateRangeSelector(),
            const SizedBox(height: 16),
            _buildMetricsSelector(),
            const SizedBox(height: 24),
            _buildGenerateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEntityCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reporte para',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _reportType == ReportType.project
                      ? Icons.folder_outlined
                      : Icons.business_outlined,
                  size: 32,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _entityName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _reportType.label,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportNameField() {
    return TextFormField(
      initialValue: _reportName,
      decoration: const InputDecoration(
        labelText: 'Nombre del Reporte',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.edit),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingrese un nombre para el reporte';
        }
        return null;
      },
      onSaved: (value) => _reportName = value!,
    );
  }

  Widget _buildDateRangeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rango de Fechas (Opcional)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DatePickerButton(
                    label: 'Desde',
                    date: _startDate,
                    onDateSelected: (date) => setState(() => _startDate = date),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _DatePickerButton(
                    label: 'Hasta',
                    date: _endDate,
                    onDateSelected: (date) => setState(() => _endDate = date),
                  ),
                ),
              ],
            ),
            if (_startDate != null || _endDate != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('Limpiar fechas'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Métricas a Incluir',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            MetricsSelectorWidget(
              metrics: _metrics,
              reportType: _reportType,
              onChanged: (metrics) => setState(() => _metrics = metrics),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return ElevatedButton.icon(
      onPressed: _isGenerating ? null : _generateReport,
      icon: _isGenerating
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.analytics),
      label: Text(_isGenerating ? 'Generando...' : 'Generar Reporte'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        textStyle: const TextStyle(fontSize: 16),
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayuda - Creador de Reportes'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. Nombre del Reporte',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Asigne un nombre descriptivo a su reporte.'),
              SizedBox(height: 12),
              Text(
                '2. Rango de Fechas',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Opcionalmente, filtre los datos por un rango de fechas específico.',
              ),
              SizedBox(height: 12),
              Text(
                '3. Métricas',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Seleccione las métricas que desea incluir en el reporte.',
              ),
              SizedBox(height: 12),
              Text(
                '4. Generar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Click en "Generar Reporte" para ver el resultado y exportarlo en el formato deseado.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}

/// Date picker button widget
class _DatePickerButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final ValueChanged<DateTime?> onDateSelected;

  const _DatePickerButton({
    required this.label,
    required this.date,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        onDateSelected(pickedDate);
      },
      icon: const Icon(Icons.calendar_today),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          Text(
            date != null ? DateFormat('dd/MM/yyyy').format(date!) : 'Seleccionar',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}



