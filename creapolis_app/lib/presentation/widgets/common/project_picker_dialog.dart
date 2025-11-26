import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/project.dart';
import '../../../features/projects/presentation/blocs/project_bloc.dart';
import '../../../features/projects/presentation/blocs/project_event.dart';
import '../../../features/projects/presentation/blocs/project_state.dart';
import '../../../injection.dart';

/// Resultado del diálogo de selección de proyecto
class ProjectPickerResult {
  final Project project;

  const ProjectPickerResult({required this.project});
}

/// Muestra un diálogo para seleccionar un proyecto del workspace
///
/// [workspaceId] - ID del workspace actual
/// [excludeProjectId] - ID del proyecto a excluir (ej: el proyecto actual)
/// [title] - Título del diálogo
Future<ProjectPickerResult?> showProjectPickerDialog({
  required BuildContext context,
  required int workspaceId,
  int? excludeProjectId,
  String? title,
}) {
  return showDialog<ProjectPickerResult>(
    context: context,
    builder: (context) => BlocProvider(
      create: (_) => getIt<ProjectBloc>()..add(LoadProjects(workspaceId)),
      child: _ProjectPickerDialog(
        workspaceId: workspaceId,
        excludeProjectId: excludeProjectId,
        title: title ?? 'Seleccionar proyecto',
      ),
    ),
  );
}

class _ProjectPickerDialog extends StatefulWidget {
  final int workspaceId;
  final int? excludeProjectId;
  final String title;

  const _ProjectPickerDialog({
    required this.workspaceId,
    required this.excludeProjectId,
    required this.title,
  });

  @override
  State<_ProjectPickerDialog> createState() => _ProjectPickerDialogState();
}

class _ProjectPickerDialogState extends State<_ProjectPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Project? _selectedProject;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Project> _filterProjects(List<Project> projects) {
    // Excluir el proyecto actual si se especificó
    var filtered = projects.where((p) => p.id != widget.excludeProjectId);

    // Aplicar búsqueda
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where(
        (p) =>
            p.name.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query),
      );
    }

    return filtered.toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.folder_open, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(widget.title)),
        ],
      ),
      content: SizedBox(
        width: 400,
        height: 450,
        child: Column(
          children: [
            // Barra de búsqueda
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar proyecto...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                isDense: true,
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 16),

            // Lista de proyectos
            Expanded(
              child: BlocBuilder<ProjectBloc, ProjectState>(
                builder: (context, state) {
                  if (state is ProjectLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ProjectsLoaded) {
                    final projects = _filterProjects(state.projects);

                    if (projects.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isEmpty
                                  ? Icons.folder_off
                                  : Icons.search_off,
                              size: 48,
                              color: colorScheme.outline,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No hay otros proyectos disponibles'
                                  : 'No se encontraron proyectos',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.outline,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: projects.length,
                      itemBuilder: (context, index) {
                        final project = projects[index];
                        final isSelected = _selectedProject?.id == project.id;

                        return _ProjectTile(
                          project: project,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() => _selectedProject = project);
                          },
                        );
                      },
                    );
                  }

                  if (state is ProjectError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: colorScheme.error,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            state.message,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () {
                              context.read<ProjectBloc>().add(
                                LoadProjects(widget.workspaceId),
                              );
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _selectedProject != null
              ? () {
                  Navigator.of(
                    context,
                  ).pop(ProjectPickerResult(project: _selectedProject!));
                }
              : null,
          child: const Text('Seleccionar'),
        ),
      ],
    );
  }
}

/// Tile para mostrar un proyecto en la lista
class _ProjectTile extends StatelessWidget {
  final Project project;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProjectTile({
    required this.project,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 2 : 0,
      color: isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.5)
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icono del proyecto
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _getStatusColor(project.status).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getStatusIcon(project.status),
                  color: _getStatusColor(project.status),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Info del proyecto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Badge de estado
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              project.status,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getStatusLabel(project.status),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _getStatusColor(project.status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (project.description.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              project.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.outline,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Indicador de selección
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 16,
                    color: colorScheme.onPrimary,
                  ),
                )
              else
                Icon(Icons.radio_button_unchecked, color: colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return Colors.green;
      case ProjectStatus.planned:
        return Colors.blue;
      case ProjectStatus.paused:
        return Colors.orange;
      case ProjectStatus.completed:
        return Colors.purple;
      case ProjectStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return Icons.play_circle_outline;
      case ProjectStatus.planned:
        return Icons.edit_calendar;
      case ProjectStatus.paused:
        return Icons.pause_circle_outline;
      case ProjectStatus.completed:
        return Icons.check_circle_outline;
      case ProjectStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  String _getStatusLabel(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return 'Activo';
      case ProjectStatus.planned:
        return 'Planificado';
      case ProjectStatus.paused:
        return 'Pausado';
      case ProjectStatus.completed:
        return 'Completado';
      case ProjectStatus.cancelled:
        return 'Cancelado';
    }
  }
}
