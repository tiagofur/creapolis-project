import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../core/animations/list_animations.dart';
import '../../../core/constants/view_constants.dart';
import '../../../core/services/view_preferences_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/project.dart';
import '../../../routes/route_builder.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/project/project_bloc.dart';
import '../../bloc/project/project_event.dart';
import '../../bloc/project/project_state.dart';
import '../../bloc/workspace/workspace_bloc.dart';
import '../../bloc/workspace/workspace_event.dart';
import '../../bloc/workspace/workspace_state.dart';
import '../../providers/workspace_context.dart';
import '../../widgets/common/main_drawer.dart';
import '../../widgets/loading/skeleton_list.dart';
import '../../widgets/project/create_project_bottom_sheet.dart';
import '../../widgets/project/project_card.dart';
import '../../widgets/workspace/workspace_switcher.dart';
import '../../widgets/error/friendly_error_widget.dart';
import '../../widgets/feedback/feedback_widgets.dart';
import '../workspace/workspace_create_screen.dart';

/// Pantalla de lista de proyectos con Progressive Disclosure
class ProjectsListScreen extends StatefulWidget {
  const ProjectsListScreen({super.key});

  @override
  State<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends State<ProjectsListScreen> {
  int? _lastLoadedWorkspaceId;
  late ProjectViewDensity _currentDensity;
  final _viewPrefs = ViewPreferencesService.instance;

  @override
  void initState() {
    super.initState();

    // Inicializar servicio de preferencias si no está inicializado
    if (!_viewPrefs.isInitialized) {
      _viewPrefs.init().then((_) {
        if (mounted) {
          setState(() {
            _currentDensity = _viewPrefs.getProjectViewDensity();
          });
        }
      });
    } else {
      _currentDensity = _viewPrefs.getProjectViewDensity();
    }

    // Cargar workspaces y workspace activo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // IMPORTANTE: Cargar workspace activo ANTES que la lista de workspaces
      // Esto permite que el BLoC use el ID pendiente cuando cargue los workspaces
      context.read<WorkspaceBloc>().add(const LoadActiveWorkspaceEvent());

      // Luego cargar lista de workspaces (que usará el ID activo si existe)
      context.read<WorkspaceBloc>().add(const LoadUserWorkspacesEvent());

      // NO cargar proyectos aquí - se cargarán cuando se establezca el workspace activo
    });
  }

  /// Cargar proyectos cuando cambie el workspace activo
  void _loadProjectsForActiveWorkspace(int? workspaceId) {
    if (_lastLoadedWorkspaceId != workspaceId) {
      _lastLoadedWorkspaceId = workspaceId;

      // Solo cargar proyectos si hay un workspace activo
      if (workspaceId != null) {
        context.read<ProjectBloc>().add(
          LoadProjectsEvent(workspaceId: workspaceId),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final workspaceContext = context.watch<WorkspaceContext>();
    final activeWorkspace = workspaceContext.activeWorkspace;

    // Cargar proyectos cuando cambie el workspace activo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProjectsForActiveWorkspace(activeWorkspace?.id);
    });

    return Scaffold(
      drawer: const MainDrawer(),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Proyectos'),
            if (activeWorkspace != null)
              Text(
                activeWorkspace.name,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
          ],
        ),
        actions: [
          // Selector de workspace
          const WorkspaceSwitcher(compact: true),
          const SizedBox(width: 8),

          // Toggle de densidad de vista
          PopupMenuButton<ProjectViewDensity>(
            icon: Icon(
              _currentDensity == ProjectViewDensity.compact
                  ? Icons.view_compact
                  : Icons.view_comfortable,
            ),
            tooltip: 'Cambiar densidad de vista',
            onSelected: (density) {
              setState(() {
                _currentDensity = density;
              });
              _viewPrefs.setProjectViewDensity(density);
              AppLogger.info(
                'ProjectsListScreen: Densidad cambiada a ${density.label}',
              );
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: ProjectViewDensity.compact,
                child: Row(
                  children: [
                    Icon(
                      Icons.view_compact,
                      size: 20,
                      color: _currentDensity == ProjectViewDensity.compact
                          ? colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      ProjectViewDensity.compact.label,
                      style: TextStyle(
                        color: _currentDensity == ProjectViewDensity.compact
                            ? colorScheme.primary
                            : null,
                        fontWeight:
                            _currentDensity == ProjectViewDensity.compact
                            ? FontWeight.bold
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ProjectViewDensity.comfortable,
                child: Row(
                  children: [
                    Icon(
                      Icons.view_comfortable,
                      size: 20,
                      color: _currentDensity == ProjectViewDensity.comfortable
                          ? colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      ProjectViewDensity.comfortable.label,
                      style: TextStyle(
                        color: _currentDensity == ProjectViewDensity.comfortable
                            ? colorScheme.primary
                            : null,
                        fontWeight:
                            _currentDensity == ProjectViewDensity.comfortable
                            ? FontWeight.bold
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implementar búsqueda en siguiente iteración
              context.showInfo('Búsqueda próximamente');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.goToSettings(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: BlocConsumer<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectCreated) {
            context.showSuccess(
              'Proyecto "${state.project.name}" creado exitosamente',
            );
            // Recargar lista filtrada por workspace activo
            final workspaceContext = context.read<WorkspaceContext>();
            final activeWorkspace = workspaceContext.activeWorkspace;
            if (activeWorkspace != null) {
              context.read<ProjectBloc>().add(
                LoadProjectsEvent(workspaceId: activeWorkspace.id),
              );
            }
          } else if (state is ProjectDeleted) {
            context.showSuccess('Proyecto eliminado exitosamente');
            // Recargar lista filtrada por workspace activo
            final workspaceContext = context.read<WorkspaceContext>();
            final activeWorkspace = workspaceContext.activeWorkspace;
            if (activeWorkspace != null) {
              context.read<ProjectBloc>().add(
                LoadProjectsEvent(workspaceId: activeWorkspace.id),
              );
            }
          } else if (state is ProjectError) {
            context.showError(state.message);
          }
        },
        builder: (context, state) {
          // SIEMPRE verificar primero si hay workspace activo
          final workspaceContext = context.watch<WorkspaceContext>();
          final hasActiveWorkspace = workspaceContext.hasActiveWorkspace;

          // Si no hay workspace activo, mostrar estado vacío
          if (!hasActiveWorkspace) {
            return _buildEmptyState(context);
          }

          // Si hay workspace activo, mostrar el estado normal
          if (state is ProjectLoading && state is! ProjectsLoaded) {
            // Mostrar skeleton grid para proyectos
            return SkeletonGrid(
              type: SkeletonType.project,
              itemCount: 6,
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              childAspectRatio: 1.2,
            );
          }

          if (state is ProjectsLoaded) {
            return _buildProjectsList(context, state.projects);
          }

          if (state is ProjectError) {
            return _buildErrorState(context, state.message);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: Consumer<WorkspaceContext>(
        builder: (context, workspaceContext, _) {
          final hasWorkspace = workspaceContext.hasActiveWorkspace;
          return FloatingActionButton.extended(
            onPressed: hasWorkspace
                ? () => _showCreateProjectSheet(context)
                : () => _showNoWorkspaceMessage(context),
            icon: const Icon(Icons.add),
            label: const Text('Nuevo Proyecto'),
          );
        },
      ),
    );
  }

  /// Construir lista de proyectos
  Widget _buildProjectsList(BuildContext context, List<Project> projects) {
    if (projects.isEmpty) {
      return _buildEmptyState(context);
    }

    // Obtener el ID del usuario actual
    final authState = context.watch<AuthBloc>().state;
    final currentUserId = authState is AuthAuthenticated
        ? authState.user.id
        : null;

    return RefreshIndicator(
      onRefresh: () async {
        final workspace = context.read<WorkspaceContext>().activeWorkspace;
        if (workspace != null) {
          context.read<ProjectBloc>().add(
            RefreshProjectsEvent(workspaceId: workspace.id),
          );
          // Esperar a que se complete
          await Future.delayed(const Duration(seconds: 1));
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive: usar grid en tablets/desktop
          final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return StaggeredListAnimation(
                index: index,
                delay: const Duration(milliseconds: 40),
                duration: const Duration(milliseconds: 350),
                child: ProjectCard(
                  project: project,
                  currentUserId: currentUserId,
                  hasOtherMembers: false, // TODO: Obtener del backend
                  density: _currentDensity,
                  onTap: () => _navigateToDetail(context, project.id),
                  onEdit: () => _showEditProjectSheet(context, project),
                  onDelete: () => _confirmDelete(context, project),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Estado vacío
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final workspaceContext = context.watch<WorkspaceContext>();
    final hasWorkspace = workspaceContext.hasActiveWorkspace;
    final hasAvailableWorkspaces = workspaceContext.userWorkspaces.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasWorkspace ? Icons.folder_open : Icons.workspaces_outlined,
            size: 80,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            hasWorkspace
                ? 'No hay proyectos'
                : hasAvailableWorkspaces
                ? 'Selecciona un workspace'
                : 'No hay workspace activo',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasWorkspace
                ? 'Crea tu primer proyecto para comenzar'
                : hasAvailableWorkspaces
                ? 'Selecciona un workspace para ver sus proyectos'
                : 'Crea tu primer workspace para comenzar',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: hasWorkspace
                ? () => _showCreateProjectSheet(context)
                : () => _handleWorkspaceSelection(context),
            icon: Icon(
              hasWorkspace
                  ? Icons.add
                  : hasAvailableWorkspaces
                  ? Icons.workspaces
                  : Icons.add_business,
            ),
            label: Text(
              hasWorkspace
                  ? 'Crear Proyecto'
                  : hasAvailableWorkspaces
                  ? 'Seleccionar Workspace'
                  : 'Crear Workspace',
            ),
          ),
        ],
      ),
    );
  }

  /// Estado de error
  Widget _buildErrorState(BuildContext context, String message) {
    final workspaceContext = context.read<WorkspaceContext>();
    final activeWorkspace = workspaceContext.activeWorkspace;

    return NoConnectionWidget(
      onRetry: () {
        if (activeWorkspace != null) {
          context.read<ProjectBloc>().add(
            LoadProjectsEvent(workspaceId: activeWorkspace.id),
          );
        }
      },
    );
  }

  /// Mostrar sheet para crear proyecto
  void _showCreateProjectSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const CreateProjectBottomSheet(),
    );
  }

  /// Mostrar sheet para editar proyecto
  void _showEditProjectSheet(BuildContext context, Project project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CreateProjectBottomSheet(project: project),
    );
  }

  /// Navegar a detalle del proyecto
  void _navigateToDetail(BuildContext context, int projectId) {
    final workspaceContext = context.read<WorkspaceContext>();
    final workspaceId = workspaceContext.activeWorkspace?.id;

    if (workspaceId == null) {
      AppLogger.warning(
        'ProjectsListScreen: No hay workspace activo, redirigiendo a lista de workspaces',
      );
      context.goToWorkspaces();
      return;
    }

    AppLogger.info(
      'ProjectsListScreen: Navegando a detalle del proyecto $projectId en workspace $workspaceId',
    );
    context.goToProject(workspaceId, projectId);
  }

  /// Confirmar eliminación de proyecto
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
      AppLogger.info('ProjectsListScreen: Eliminando proyecto ${project.id}');
      context.read<ProjectBloc>().add(DeleteProjectEvent(project.id));
    }
  }

  /// Manejar logout
  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Importar AuthBloc aquí para evitar dependencia circular
      final authBloc = context
          .read<dynamic>(); // Se puede mejorar con un tipo más específico
      if (authBloc.runtimeType.toString() == 'AuthBloc') {
        // authBloc.add(const LogoutEvent());
      }
      context.goToLogin();
    }
  }

  /// Mostrar mensaje cuando no hay workspace activo
  void _showNoWorkspaceMessage(BuildContext context) {
    context.showWarning(
      'Selecciona un workspace para comenzar a crear proyectos',
    );
  }

  /// Mostrar sheet para crear workspace
  void _showCreateWorkspaceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: const WorkspaceCreateScreen(),
        ),
      ),
    );
  }

  /// Lógica inteligente para seleccionar workspace
  void _handleWorkspaceSelection(BuildContext context) {
    final workspaceContext = context.read<WorkspaceContext>();
    final workspaceBloc = context.read<WorkspaceBloc>();
    final currentState = workspaceBloc.state;

    // Verificar si hay workspaces disponibles
    bool hasWorkspaces = false;
    if (currentState is WorkspacesLoaded) {
      hasWorkspaces = currentState.workspaces.isNotEmpty;
    } else if (workspaceContext.userWorkspaces.isNotEmpty) {
      hasWorkspaces = true;
    }

    if (hasWorkspaces) {
      // Hay workspaces, ir a la pantalla de selección
      context.goToWorkspaces();
    } else {
      // No hay workspaces o no se han cargado, mostrar modal de crear
      _showCreateWorkspaceSheet(context);
    }
  }
}



