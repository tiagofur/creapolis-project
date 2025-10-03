import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/project.dart';
import '../../bloc/project/project_bloc.dart';
import '../../bloc/project/project_event.dart';
import '../../bloc/project/project_state.dart';
import '../../widgets/project/create_project_bottom_sheet.dart';
import '../tasks/tasks_list_screen.dart';

/// Pantalla de detalle del proyecto
class ProjectDetailScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar proyecto
    final id = int.tryParse(widget.projectId);
    if (id != null) {
      context.read<ProjectBloc>().add(LoadProjectByIdEvent(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: BlocConsumer<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Proyecto actualizado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            // Recargar proyecto
            final id = int.tryParse(widget.projectId);
            if (id != null) {
              context.read<ProjectBloc>().add(LoadProjectByIdEvent(id));
            }
          } else if (state is ProjectDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Proyecto eliminado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            context.go('/projects');
          } else if (state is ProjectError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProjectLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProjectLoaded) {
            return _buildProjectDetail(context, state.project);
          }

          if (state is ProjectError) {
            return _buildErrorState(context, state.message);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  /// Construir detalle del proyecto
  Widget _buildProjectDetail(BuildContext context, Project project) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomScrollView(
      slivers: [
        // AppBar
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(project.name),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getStatusColor(project.status),
                    _getStatusColor(project.status).withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 60,
                    right: 16,
                    child: Icon(
                      Icons.business,
                      size: 100,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditSheet(context, project),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDelete(context, project),
            ),
          ],
        ),

        // Contenido
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Estado y Progreso
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Chip(
                              label: Text(
                                project.status.label,
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: _getStatusColor(project.status),
                            ),
                            if (project.isOverdue)
                              const Chip(
                                label: Text('Retrasado'),
                                backgroundColor: Colors.red,
                                labelStyle: TextStyle(color: Colors.white),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('Progreso', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: project.progress,
                          minHeight: 10,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getStatusColor(project.status),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(project.progress * 100).toStringAsFixed(0)}%',
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Descripción
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Descripción',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          project.description,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Información
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          context,
                          Icons.calendar_today,
                          'Fecha Inicio',
                          _formatDate(project.startDate),
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          context,
                          Icons.event,
                          'Fecha Fin',
                          _formatDate(project.endDate),
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          context,
                          Icons.schedule,
                          'Duración',
                          '${project.durationInDays} días',
                        ),
                        if (project.managerName != null) ...[
                          const Divider(height: 24),
                          _buildInfoRow(
                            context,
                            Icons.person,
                            'Manager',
                            project.managerName!,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tareas del proyecto
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tareas',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    context.push(
                                      '/projects/${project.id}/gantt',
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.view_timeline,
                                    size: 18,
                                  ),
                                  label: const Text('Gantt'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    context.push(
                                      '/projects/${project.id}/workload',
                                    );
                                  },
                                  icon: const Icon(Icons.people, size: 18),
                                  label: const Text('Workload'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Integrar TasksListScreen sin scaffold
                        SizedBox(
                          height: 400,
                          child: TasksListScreen(projectId: project.id),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Construir fila de información
  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Estado de error
  Widget _buildErrorState(BuildContext context, String message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: colorScheme.error),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go('/projects'),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver a Proyectos'),
            ),
          ],
        ),
      ),
    );
  }

  /// Mostrar sheet para editar
  void _showEditSheet(BuildContext context, Project project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CreateProjectBottomSheet(project: project),
    );
  }

  /// Confirmar eliminación
  Future<void> _confirmDelete(BuildContext context, Project project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Proyecto'),
        content: Text(
          '¿Estás seguro de que deseas eliminar el proyecto "${project.name}"?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      AppLogger.info('ProjectDetailScreen: Eliminando proyecto ${project.id}');
      context.read<ProjectBloc>().add(DeleteProjectEvent(project.id));
    }
  }

  /// Obtiene el color según el estado
  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planned:
        return Colors.blue;
      case ProjectStatus.active:
        return Colors.green;
      case ProjectStatus.paused:
        return Colors.orange;
      case ProjectStatus.completed:
        return Colors.teal;
      case ProjectStatus.cancelled:
        return Colors.red;
    }
  }

  /// Formatea fecha
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
