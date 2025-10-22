import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:creapolis_app/features/projects/presentation/blocs/project_bloc.dart';
import 'package:creapolis_app/features/projects/presentation/blocs/project_event.dart';
import 'package:creapolis_app/features/projects/presentation/blocs/project_state.dart';
import 'package:creapolis_app/presentation/providers/workspace_context.dart';
import 'package:creapolis_app/routes/app_router.dart';
import 'package:creapolis_app/domain/entities/project.dart';

/// Widget que muestra los proyectos del usuario en el Dashboard.
///
/// Características:
/// - Muestra proyectos activos
/// - Indicador visual de progreso
/// - Navegación a detalle de proyecto
/// - Acceso rápido a "Ver todos"
class MyProjectsWidget extends StatefulWidget {
  const MyProjectsWidget({super.key});

  @override
  State<MyProjectsWidget> createState() => _MyProjectsWidgetState();
}

class _MyProjectsWidgetState extends State<MyProjectsWidget> {
  int? _lastRequestedWorkspaceId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workspaceContext = context.watch<WorkspaceContext>();
    final activeWorkspace = workspaceContext.activeWorkspace;

    final workspaceId = activeWorkspace?.id;
    if (workspaceId == null && _lastRequestedWorkspaceId != null) {
      _lastRequestedWorkspaceId = null;
    }

    if (workspaceId != null && workspaceId != _lastRequestedWorkspaceId) {
      _lastRequestedWorkspaceId = workspaceId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ProjectBloc>().add(LoadProjects(workspaceId));
      });
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.folder,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Mis Proyectos',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: activeWorkspace != null
                      ? () => GoRouter.of(context).go(RoutePaths.allProjects)
                      : null,
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (workspaceId == null)
              _buildNoWorkspaceState(theme)
            else
              BlocBuilder<ProjectBloc, ProjectState>(
                buildWhen: (previous, current) =>
                    current is ProjectLoading ||
                    current is ProjectsLoaded ||
                    current is ProjectError,
                builder: (context, state) {
                  if (state is ProjectLoading) {
                    return _buildLoadingState(theme);
                  }

                  if (state is ProjectError) {
                    final fallback = state.currentProjects
                        ?.where((project) => project.workspaceId == workspaceId)
                        .toList();

                    if (fallback != null && fallback.isNotEmpty) {
                      final projects = _selectProjects(fallback);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWarningBanner(theme, state.message),
                          const SizedBox(height: 12),
                          _buildProjectsGrid(context, projects, workspaceId),
                        ],
                      );
                    }

                    return _buildErrorState(theme, state.message, workspaceId);
                  }

                  if (state is ProjectsLoaded) {
                    if (state.workspaceId != workspaceId) {
                      return _buildLoadingState(theme);
                    }

                    final projects = _selectProjects(state.projects);
                    if (projects.isEmpty) {
                      return _buildEmptyProjectsState(theme);
                    }

                    return _buildProjectsGrid(context, projects, workspaceId);
                  }

                  return _buildLoadingState(theme);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsGrid(
    BuildContext context,
    List<Project> projects,
    int workspaceId,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return _buildProjectCard(context, project, workspaceId);
      },
    );
  }

  Widget _buildProjectCard(
    BuildContext context,
    Project project,
    int workspaceId,
  ) {
    final theme = Theme.of(context);

    // Calcular progreso (mock)
    // TODO: Calcular progreso real basado en tareas completadas
    final progress = _calculateProgress(project);

    // Colores dinámicos según progreso
    Color progressColor;
    if (progress < 0.33) {
      progressColor = Colors.red;
    } else if (progress < 0.66) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.green;
    }

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: InkWell(
        onTap: () {
          GoRouter.of(
            context,
          ).go(RoutePaths.projectDetail(workspaceId, project.id));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono y nombre
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.folder,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      project.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Barra de progreso
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progreso',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: progressColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: theme.colorScheme.outline.withValues(
                        alpha: 0.2,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Calcular progreso del proyecto
  /// TODO: Implementar cálculo real basado en tareas
  double _calculateProgress(Project project) {
    // Usar progreso calculado por fechas por ahora
    return project.progress;
  }

  List<Project> _selectProjects(List<Project> projects) {
    final activeProjects = projects
        .where((project) => project.status == ProjectStatus.active)
        .toList();

    final source = activeProjects.isNotEmpty ? activeProjects : projects;
    final sorted = List<Project>.from(source)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return sorted.take(4).toList();
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildEmptyProjectsState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 8),
            Text(
              'No hay proyectos',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoWorkspaceState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.workspaces_outline,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona un workspace para ver tus proyectos',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String message, int workspaceId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 40, color: theme.colorScheme.error),
          const SizedBox(height: 8),
          Text(
            'No se pudieron cargar los proyectos',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {
              context.read<ProjectBloc>().add(LoadProjects(workspaceId));
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBanner(ThemeData theme, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
