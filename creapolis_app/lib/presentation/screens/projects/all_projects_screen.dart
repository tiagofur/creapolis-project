// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:creapolis_app/presentation/widgets/common/common_widgets.dart';
import 'package:creapolis_app/presentation/providers/workspace_context.dart';
import 'package:creapolis_app/features/projects/presentation/blocs/project_bloc.dart';
import 'package:creapolis_app/features/projects/presentation/blocs/project_event.dart';
import 'package:creapolis_app/features/projects/presentation/blocs/project_state.dart';
import 'package:creapolis_app/domain/entities/project.dart';
import 'package:creapolis_app/features/projects/presentation/widgets/project_card.dart';
import 'package:creapolis_app/presentation/widgets/project/create_project_bottom_sheet.dart';
import 'package:creapolis_app/presentation/widgets/feedback/feedback_widgets.dart';
import 'package:creapolis_app/routes/app_router.dart';

/// Pantalla que muestra todos los proyectos del workspace activo.
///
/// Accesible desde: Bottom Navigation > Proyectos
///
/// Características:
/// - Lista de todos los proyectos (no solo recientes como en dashboard)
/// - Filtros por estado (activo, completado, pausado)
/// - Búsqueda de proyectos
/// - Validación de workspace activo
/// - Botón para crear nuevo proyecto
class AllProjectsScreen extends StatefulWidget {
  const AllProjectsScreen({super.key});

  @override
  State<AllProjectsScreen> createState() => _AllProjectsScreenState();
}

class _AllProjectsScreenState extends State<AllProjectsScreen> {
  ProjectStatus? _filterStatus;
  int? _lastLoadedWorkspaceId;
  String _searchQuery = '';
  List<Project> _cachedProjects = [];
  bool _hasLoadedProjects = false;
  ProjectStatus? _lastAppliedFilter;
  String? _lastAppliedSearch;

  @override
  void initState() {
    super.initState();

    // Cargar proyectos al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProjectsForActiveWorkspace();
    });
  }

  void _loadProjectsForActiveWorkspace() {
    final workspaceContext = context.read<WorkspaceContext>();
    final workspaceId = workspaceContext.activeWorkspace?.id;

    if (workspaceId != null && _lastLoadedWorkspaceId != workspaceId) {
      setState(() {
        _lastLoadedWorkspaceId = workspaceId;
        _filterStatus = null;
        _searchQuery = '';
      });
      _requestProjects(workspaceId);
    }
  }

  void _requestProjects(int workspaceId) {
    context.read<ProjectBloc>().add(
      LoadProjects(
        workspaceId,
        status: _filterStatus,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      ),
    );
  }

  void _applyFilter(ProjectStatus? status) {
    final workspaceId = context.read<WorkspaceContext>().activeWorkspace?.id;
    if (workspaceId == null) return;

    setState(() {
      _filterStatus = status;
    });

    _requestProjects(workspaceId);
  }

  void _applySearch(String query) {
    final workspaceId = context.read<WorkspaceContext>().activeWorkspace?.id;
    if (workspaceId == null) return;

    final trimmed = query.trim();

    setState(() {
      _searchQuery = trimmed;
    });

    _requestProjects(workspaceId);
  }

  void _clearSearch() {
    final workspaceId = context.read<WorkspaceContext>().activeWorkspace?.id;
    if (workspaceId == null || _searchQuery.isEmpty) return;

    setState(() {
      _searchQuery = '';
    });

    _requestProjects(workspaceId);
  }

  void _resetFilters() {
    final workspaceId = context.read<WorkspaceContext>().activeWorkspace?.id;
    if (workspaceId == null) return;

    setState(() {
      _filterStatus = null;
      _searchQuery = '';
    });

    _requestProjects(workspaceId);
  }

  @override
  Widget build(BuildContext context) {
    final workspaceContext = context.watch<WorkspaceContext>();
    final activeWorkspace = workspaceContext.activeWorkspace;

    // Recargar proyectos si cambia el workspace
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (activeWorkspace?.id != _lastLoadedWorkspaceId) {
        _loadProjectsForActiveWorkspace();
      }
    });

    return Scaffold(
      appBar: CreopolisAppBar(
        title: 'Proyectos',
        showWorkspaceSwitcher: true,
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearSearch,
              tooltip: 'Limpiar búsqueda',
            ),
          // Botón de búsqueda
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context);
            },
            tooltip: 'Buscar proyectos',
          ),
          // Botón de filtros
          PopupMenuButton<String>(
            icon: Badge(
              isLabelVisible: _filterStatus != null,
              child: const Icon(Icons.filter_list),
            ),
            tooltip: 'Filtrar proyectos',
            onSelected: (value) {
              if (value == 'all') {
                _applyFilter(null);
              } else {
                final selected = ProjectStatus.values.firstWhere(
                  (s) => s.name == value,
                  orElse: () => ProjectStatus.active,
                );
                _applyFilter(selected);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Todos')),
              const PopupMenuItem(value: 'active', child: Text('Activos')),
              const PopupMenuItem(value: 'planned', child: Text('Planeados')),
              const PopupMenuItem(value: 'paused', child: Text('Pausados')),
              const PopupMenuItem(
                value: 'completed',
                child: Text('Completados'),
              ),
              const PopupMenuItem(
                value: 'cancelled',
                child: Text('Cancelados'),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProjects,
        child: _buildContent(context, activeWorkspace),
      ),
    );
  }

  Widget _buildContent(BuildContext context, activeWorkspace) {
    if (activeWorkspace == null) {
      return _buildNoWorkspaceState(context);
    }

    return BlocConsumer<ProjectBloc, ProjectState>(
      listener: (context, state) {
        if (state is ProjectOperationSuccess) {
          context.showSuccess(state.message);
        } else if (state is ProjectError) {
          context.showError(state.message);
        }
      },
      builder: (context, state) {
        if (state is ProjectsLoaded) {
          _cachedProjects = List<Project>.from(state.filteredProjects);
          _lastAppliedFilter = state.currentFilter;
          _lastAppliedSearch = state.searchQuery;
          _hasLoadedProjects = true;
        } else if (state is ProjectOperationSuccess) {
          final project = state.project;
          if (project != null) {
            final existingIndex = _cachedProjects.indexWhere(
              (p) => p.id == project.id,
            );
            if (existingIndex >= 0) {
              _cachedProjects[existingIndex] = project;
            } else {
              _cachedProjects = [project, ..._cachedProjects];
            }
          }
        } else if (state is ProjectOperationInProgress) {
          _hasLoadedProjects = _hasLoadedProjects || _cachedProjects.isNotEmpty;
        }

        final bool isLoading =
            state is ProjectLoading || state is ProjectOperationInProgress;

        final List<Project> projectsToShow = state is ProjectsLoaded
            ? state.filteredProjects
            : List<Project>.from(_cachedProjects);

        final bool hasFilter = state is ProjectsLoaded
            ? state.currentFilter != null
            : _lastAppliedFilter != null;
        final bool hasSearch = state is ProjectsLoaded
            ? (state.searchQuery?.isNotEmpty ?? false)
            : (_lastAppliedSearch?.isNotEmpty ?? false);

        if (!_hasLoadedProjects && state is ProjectError) {
          return _buildErrorState(context, state.message);
        }

        if (!_hasLoadedProjects && isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (projectsToShow.isEmpty) {
          return Stack(
            children: [
              _buildEmptyState(
                context,
                hasFilter: hasFilter,
                hasSearch: hasSearch,
              ),
              if (isLoading)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(minHeight: 2),
                ),
            ],
          );
        }

        return Stack(
          children: [
            _buildProjectsList(context, projectsToShow),
            if (isLoading)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(minHeight: 2),
              ),
          ],
        );
      },
    );
  }

  Widget _buildProjectsList(BuildContext context, List<Project> projects) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        final workspaceId = context
            .read<WorkspaceContext>()
            .activeWorkspace
            ?.id;

        return ProjectCard(
          project: project,
          onTap: () => _navigateToProjectDetail(project),
          onViewTasks: workspaceId != null
              ? () => _navigateToTasks(workspaceId, project.id)
              : null,
          onEdit: () => _showEditProjectSheet(context, project),
          onDelete: () => _confirmDelete(context, project),
          showActions: true,
        );
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required bool hasFilter,
    required bool hasSearch,
  }) {
    final theme = Theme.of(context);
    final hasCriteria = hasFilter || hasSearch;
    final title = hasCriteria
        ? 'No hay proyectos que coincidan'
        : 'No hay proyectos aún';
    final subtitle = hasCriteria
        ? hasSearch && hasFilter
              ? 'Modifica la búsqueda o el filtro de estado'
              : hasSearch
              ? 'Intenta con otros términos de búsqueda'
              : 'Intenta con otro filtro o crea un nuevo proyecto'
        : 'Crea tu primer proyecto usando el botón +';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasCriteria ? Icons.filter_list_off : Icons.folder_open,
              size: 80,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasCriteria) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _resetFilters,
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpiar Búsqueda y Filtros'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: theme.colorScheme.error),
            const SizedBox(height: 24),
            Text(
              'Error al cargar proyectos',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _refreshProjects,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  /// Estado cuando no hay workspace seleccionado
  Widget _buildNoWorkspaceState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_off, size: 80, color: theme.colorScheme.outline),
            const SizedBox(height: 24),
            Text(
              'No hay workspace seleccionado',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Selecciona un workspace para ver tus proyectos',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                context.go(RoutePaths.workspaces);
              },
              icon: const Icon(Icons.business),
              label: const Text('Seleccionar Workspace'),
            ),
          ],
        ),
      ),
    );
  }

  /// Mostrar diálogo de búsqueda
  void _showSearchDialog(BuildContext context) {
    String searchQuery = _searchQuery;
    final controller = TextEditingController(text: _searchQuery);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar proyectos'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nombre del proyecto...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            searchQuery = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _applySearch(searchQuery);
            },
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }

  /// Refrescar lista de proyectos
  Future<void> _refreshProjects() async {
    final workspaceContext = context.read<WorkspaceContext>();
    final workspaceId = workspaceContext.activeWorkspace?.id;

    if (workspaceId != null) {
      context.read<ProjectBloc>().add(RefreshProjects(workspaceId));

      // Esperar a que se complete la recarga
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Proyectos actualizados'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _showEditProjectSheet(BuildContext context, Project project) {
    final projectBloc = context.read<ProjectBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => BlocProvider.value(
        value: projectBloc,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: CreateProjectBottomSheet(project: project),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Project project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Proyecto'),
        content: Text(
          '¿Eliminar "${project.name}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<ProjectBloc>().add(DeleteProject(project.id));
    }
  }

  void _navigateToProjectDetail(Project project) {
    final workspaceId = context.read<WorkspaceContext>().activeWorkspace?.id;
    if (workspaceId != null) {
      context.go(RoutePaths.projectDetail(workspaceId, project.id));
    }
  }

  void _navigateToTasks(int workspaceId, int projectId) {
    GoRouter.of(
      context,
    ).go('/more/workspaces/$workspaceId/projects/$projectId/tasks');
  }
}
