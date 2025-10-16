import 'package:flutter/material.dart';

import '../../../domain/entities/project.dart';
import '../../../domain/entities/report_template.dart';
import '../../../features/workspace/data/models/workspace_model.dart';
import '../../services/report_service.dart';
import 'report_preview_screen.dart';

/// Screen for browsing and selecting report templates
class ReportTemplatesScreen extends StatefulWidget {
  final ReportService reportService;
  final Project? project;
  final Workspace? workspace;

  const ReportTemplatesScreen({
    super.key,
    required this.reportService,
    this.project,
    this.workspace,
  });

  @override
  State<ReportTemplatesScreen> createState() => _ReportTemplatesScreenState();
}

class _ReportTemplatesScreenState extends State<ReportTemplatesScreen> {
  List<ReportTemplate> _templates = [];
  bool _isLoading = true;
  String? _error;
  ReportTemplateCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final templates = await widget.reportService.getTemplates();
      setState(() {
        _templates = templates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _generateFromTemplate(ReportTemplate template) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final entityType = widget.project != null ? 'project' : 'workspace';
      final entityId = widget.project?.id ?? widget.workspace!.id;

      final report = await widget.reportService.generateCustomReport(
        templateId: template.id,
        entityType: entityType,
        entityId: entityId,
      );

      if (!mounted) return;

      Navigator.of(context).pop(); // Close loading dialog

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

      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar reporte: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<ReportTemplate> get _filteredTemplates {
    if (_selectedCategory == null) return _templates;
    return _templates.where((t) => t.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plantillas de Reportes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTemplates,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _CategoryChip(
              label: 'Todos',
              icon: '📊',
              isSelected: _selectedCategory == null,
              onTap: () => setState(() => _selectedCategory = null),
            ),
            ...ReportTemplateCategory.values.map((category) {
              return _CategoryChip(
                label: category.label,
                icon: category.icon,
                isSelected: _selectedCategory == category,
                onTap: () => setState(() => _selectedCategory = category),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTemplates,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_templates.isEmpty) {
      return const Center(child: Text('No hay plantillas disponibles'));
    }

    final templates = _filteredTemplates;

    if (templates.isEmpty) {
      return const Center(child: Text('No hay plantillas en esta categoría'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return _TemplateCard(
          template: template,
          onTap: () => _generateFromTemplate(template),
        );
      },
    );
  }
}

/// Category filter chip
class _CategoryChip extends StatelessWidget {
  final String label;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [Text(icon), const SizedBox(width: 4), Text(label)],
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

/// Template card widget
class _TemplateCard extends StatelessWidget {
  final ReportTemplate template;
  final VoidCallback onTap;

  const _TemplateCard({required this.template, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    template.category.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          template.description,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: template.metrics.map((metric) {
                  return Chip(
                    label: Text(
                      _getMetricLabel(metric),
                      style: const TextStyle(fontSize: 12),
                    ),
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMetricLabel(String metric) {
    switch (metric) {
      case 'tasks':
        return 'Tareas';
      case 'progress':
        return 'Progreso';
      case 'time':
        return 'Tiempo';
      case 'team':
        return 'Equipo';
      case 'projects':
        return 'Proyectos';
      case 'productivity':
        return 'Productividad';
      case 'dependencies':
        return 'Dependencias';
      default:
        return metric;
    }
  }
}
