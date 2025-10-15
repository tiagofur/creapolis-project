import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../bloc/project/project_bloc.dart';
import '../../../bloc/project/project_state.dart';
import '../providers/dashboard_filter_provider.dart';

/// Barra de filtros para el dashboard
///
/// Permite filtrar métricas y gráficos por:
/// - Proyecto
/// - Rango de fechas
/// - Usuario (futuro)
class DashboardFilterBar extends StatelessWidget {
  const DashboardFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filterProvider = context.watch<DashboardFilterProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.filter_list,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Filtros',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (filterProvider.hasActiveFilters)
                  TextButton.icon(
                    onPressed: () => filterProvider.clearFilters(),
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Limpiar'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Project filter
                _ProjectFilterChip(),
                // Date range filter
                _DateRangeFilterChip(),
                // Active filters display
                if (filterProvider.selectedProjectId != null)
                  _ActiveFilterChip(
                    label: 'Proyecto seleccionado',
                    onRemove: () => filterProvider.clearProjectFilter(),
                  ),
                if (filterProvider.startDate != null ||
                    filterProvider.endDate != null)
                  _ActiveFilterChip(
                    label: _formatDateRange(
                      filterProvider.startDate,
                      filterProvider.endDate,
                    ),
                    onRemove: () => filterProvider.clearDateFilter(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    final formatter = DateFormat('dd/MM');
    if (start != null && end != null) {
      return '${formatter.format(start)} - ${formatter.format(end)}';
    } else if (start != null) {
      return 'Desde ${formatter.format(start)}';
    } else if (end != null) {
      return 'Hasta ${formatter.format(end)}';
    }
    return 'Rango de fechas';
  }
}

class _ProjectFilterChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filterProvider = context.read<DashboardFilterProvider>();

    return BlocBuilder<ProjectBloc, ProjectState>(
      builder: (context, state) {
        if (state is! ProjectsLoaded || state.projects.isEmpty) {
          return const SizedBox.shrink();
        }

        return ActionChip(
          avatar: Icon(
            Icons.folder,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          label: const Text('Proyecto'),
          onPressed: () {
            _showProjectPicker(context, state.projects, filterProvider);
          },
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
        );
      },
    );
  }

  void _showProjectPicker(
    BuildContext context,
    List<dynamic> projects,
    DashboardFilterProvider filterProvider,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Seleccionar Proyecto',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListView.builder(
                shrinkWrap: true,
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return ListTile(
                    leading: const Icon(Icons.folder),
                    title: Text(project.name),
                    selected: filterProvider.selectedProjectId == project.id,
                    onTap: () {
                      filterProvider.setProjectFilter(project.id);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DateRangeFilterChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filterProvider = context.read<DashboardFilterProvider>();

    return ActionChip(
      avatar: Icon(
        Icons.calendar_today,
        size: 16,
        color: theme.colorScheme.primary,
      ),
      label: const Text('Fecha'),
      onPressed: () async {
        final now = DateTime.now();
        final firstDate = DateTime(now.year - 1);
        final lastDate = DateTime(now.year + 1);

        final pickedRange = await showDateRangePicker(
          context: context,
          firstDate: firstDate,
          lastDate: lastDate,
          initialDateRange:
              filterProvider.startDate != null && filterProvider.endDate != null
              ? DateTimeRange(
                  start: filterProvider.startDate!,
                  end: filterProvider.endDate!,
                )
              : null,
          builder: (context, child) {
            return Theme(data: Theme.of(context), child: child!);
          },
        );

        if (pickedRange != null) {
          filterProvider.setDateRange(pickedRange.start, pickedRange.end);
        }
      },
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _ActiveFilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onRemove,
      visualDensity: VisualDensity.compact,
      backgroundColor: theme.colorScheme.primaryContainer,
      labelStyle: TextStyle(color: theme.colorScheme.onPrimaryContainer),
    );
  }
}



