import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/view_preferences_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/project.dart';
import '../../../routes/route_builder.dart';
import '../../bloc/project/project_bloc.dart';
import '../../bloc/project/project_event.dart';
import '../../bloc/project/project_state.dart';
import '../../providers/workspace_context.dart';
import '../../widgets/common/collapsible_section.dart';
import '../../widgets/project/create_project_bottom_sheet.dart';
import '../tasks/tasks_list_screen.dart';

/// Pantalla de detalle del proyecto con Progressive Disclosure y Tabs
class ProjectDetailScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _viewPrefs = ViewPreferencesService.instance;

  @override
  void initState() {
    super.initState();

    // Inicializar tab controller
    _tabController = TabController(length: 3, vsync: this);

    // Inicializar servicio de preferencias si no está inicializado
    if (!_viewPrefs.isInitialized) {
      _viewPrefs.init();
    }

    // Cargar proyecto
    final id = int.tryParse(widget.projectId);
    if (id != null) {
      context.read<ProjectBloc>().add(LoadProjectByIdEvent(id));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Navegar de vuelta a la lista de proyectos
  void _navigateToProjects() {
    final workspaceContext = context.read<WorkspaceContext>();
    final workspaceId = workspaceContext.activeWorkspace?.id;

    if (workspaceId != null) {
      context.goToProjects(workspaceId);
    } else {
      // Si no hay workspace activo, ir a la lista de workspaces
      context.goToWorkspaces();
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
            _navigateToProjects();
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

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // AppBar compacto con info crítica
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _navigateToProjects,
              tooltip: 'Volver a proyectos',
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(project.name, style: const TextStyle(fontSize: 16)),
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
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditSheet(context, project),
                tooltip: 'Editar proyecto',
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(context, project),
                tooltip: 'Eliminar proyecto',
              ),
            ],
          ),

          // Barra de estado y progreso (siempre visible)
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(
                        label: Text(
                          project.status.label,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: _getStatusColor(project.status),
                      ),
                      const SizedBox(width: 8),
                      if (project.isOverdue)
                        const Chip(
                          label: Text('Retrasado'),
                          backgroundColor: Colors.red,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                    '${(project.progress * 100).toStringAsFixed(0)}% completado',
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          ),

          // TabBar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.info_outline), text: 'Overview'),
                  Tab(icon: Icon(Icons.task_alt), text: 'Tareas'),
                  Tab(icon: Icon(Icons.timeline), text: 'Timeline'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Overview
            _buildOverviewTab(context, project),

            // Tab 2: Tareas
            _buildTasksTab(context, project),

            // Tab 3: Timeline
            _buildTimelineTab(context, project),
          ],
        ),
      ),
    );
  }

  /// Tab de Overview con secciones colapsables
  Widget _buildOverviewTab(BuildContext context, Project project) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Descripción (colapsable)
        CollapsibleSection(
          title: 'Descripción',
          icon: Icons.description,
          storageKey: 'project_${project.id}_description',
          initiallyExpanded: project.description.length <= 150,
          child: ExpandableDescription(
            text: project.description,
            textStyle: theme.textTheme.bodyMedium,
          ),
        ),

        // Detalles del proyecto (colapsable)
        CollapsibleSection(
          title: 'Detalles del Proyecto',
          icon: Icons.info,
          storageKey: 'project_${project.id}_details',
          initiallyExpanded: false,
          itemCount: 4,
          child: Column(
            children: [
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

        // Estadísticas (expandido por defecto)
        CollapsibleSection(
          title: 'Estadísticas',
          icon: Icons.bar_chart,
          storageKey: 'project_${project.id}_stats',
          initiallyExpanded: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow(
                context,
                Icons.check_circle,
                'Progreso',
                '${(project.progress * 100).toStringAsFixed(0)}%',
                colorScheme.primary,
              ),
              const SizedBox(height: 12),
              _buildStatRow(
                context,
                Icons.timelapse,
                'Días restantes',
                '${_calculateRemainingDays(project)} días',
                _calculateRemainingDays(project) < 0
                    ? colorScheme.error
                    : colorScheme.tertiary,
              ),
              const SizedBox(height: 12),
              _buildStatRow(
                context,
                Icons.trending_up,
                'Estado',
                project.status.label,
                _getStatusColor(project.status),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Tab de Tareas (más espacio que antes)
  Widget _buildTasksTab(BuildContext context, Project project) {
    final workspaceContext = context.read<WorkspaceContext>();
    final workspaceId = workspaceContext.activeWorkspace?.id;

    return Column(
      children: [
        // Toolbar de acciones
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: workspaceId != null
                    ? () => context.goToGantt(workspaceId, project.id)
                    : null,
                icon: const Icon(Icons.view_timeline, size: 18),
                label: const Text('Ver Gantt'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: workspaceId != null
                    ? () => context.goToWorkload(workspaceId, project.id)
                    : null,
                icon: const Icon(Icons.people, size: 18),
                label: const Text('Workload'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: workspaceId != null
                    ? () => context.goToResourceMap(workspaceId, project.id)
                    : null,
                icon: const Icon(Icons.grid_view, size: 18),
                label: const Text('Mapa de Recursos'),
              ),
            ],
          ),
        ),

        // Lista de tareas (toma todo el espacio disponible)
        Expanded(child: TasksListScreen(projectId: project.id)),
      ],
    );
  }

  /// Tab de Timeline
  Widget _buildTimelineTab(BuildContext context, Project project) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Línea de Tiempo',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTimelineItem(
                  context,
                  'Inicio del proyecto',
                  _formatDate(project.startDate),
                  Icons.play_circle,
                  Colors.green,
                ),
                _buildTimelineItem(
                  context,
                  'Fecha actual',
                  _formatDate(DateTime.now()),
                  Icons.today,
                  Colors.blue,
                ),
                _buildTimelineItem(
                  context,
                  'Fin del proyecto',
                  _formatDate(project.endDate),
                  Icons.flag,
                  project.isOverdue ? Colors.red : Colors.orange,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Métricas de Tiempo',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  context,
                  Icons.calendar_month,
                  'Duración Total',
                  '${project.durationInDays} días',
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  context,
                  Icons.access_time,
                  'Días Transcurridos',
                  '${_calculateElapsedDays(project)} días',
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  context,
                  Icons.hourglass_empty,
                  'Días Restantes',
                  '${_calculateRemainingDays(project)} días',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Construir item de timeline
  Widget _buildTimelineItem(
    BuildContext context,
    String title,
    String date,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  date,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construir fila de estadística
  Widget _buildStatRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Calcular días transcurridos
  int _calculateElapsedDays(Project project) {
    final now = DateTime.now();
    return now.difference(project.startDate).inDays;
  }

  /// Calcular días restantes
  int _calculateRemainingDays(Project project) {
    final now = DateTime.now();
    return project.endDate.difference(now).inDays;
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
              onPressed: _navigateToProjects,
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

/// Delegate para mantener el TabBar sticky
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}



