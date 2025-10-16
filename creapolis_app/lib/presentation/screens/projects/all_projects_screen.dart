import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:creapolis_app/presentation/widgets/common/common_widgets.dart';
import 'package:creapolis_app/presentation/providers/workspace_context.dart';
import 'package:creapolis_app/features/projects/presentation/blocs/project_bloc.dart';
import 'package:creapolis_app/features/projects/presentation/blocs/project_event.dart';
import 'package:creapolis_app/features/projects/presentation/blocs/project_state.dart';
import 'package:creapolis_app/domain/entities/project.dart';
import 'package:creapolis_app/presentation/widgets/project/project_card.dart';
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
      _lastLoadedWorkspaceId = workspaceId;
      context.read<ProjectBloc>().add(LoadProjects(workspaceId));
    }
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
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrar proyectos',
            onSelected: (value) {
              setState(() {
                if (value == 'all') {
                  _filterStatus = null;
                } else {
                  _filterStatus = ProjectStatus.values.firstWhere(
                    (s) => s.name == value,
                    orElse: () => ProjectStatus.active,
                  );
                }
              });

              if (activeWorkspace != null) {
                if (_filterStatus != null) {
                  context.read<ProjectBloc>().add(
                    FilterProjectsByStatus(_filterStatus),
                  );
                } else {
                  context.read<ProjectBloc>().add(
                    LoadProjects(activeWorkspace.id),
                  );
                }
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

    return BlocBuilder<ProjectBloc, ProjectState>(
      builder: (context, state) {
        if (state is ProjectLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProjectError) {
          return _buildErrorState(context, state.message);
        }

        if (state is ProjectsLoaded) {
          final projects = state.filteredProjects;

          if (projects.isEmpty) {
            return _buildEmptyState(context, _filterStatus != null);
          }

          return _buildProjectsList(context, projects);
        }

        // Estado inicial
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildProjectsList(BuildContext context, List<Project> projects) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            height: 180, // Altura fija para evitar problemas de constraints
            child: ProjectCard(
              project: project,
              onTap: () {
                final workspaceId = context
                    .read<WorkspaceContext>()
                    .activeWorkspace
                    ?.id;
                if (workspaceId != null) {
                  context.go(RoutePaths.projectDetail(workspaceId, project.id));
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool hasFilter) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilter ? Icons.filter_list_off : Icons.folder_open,
              size: 80,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              hasFilter
                  ? 'No hay proyectos con este filtro'
                  : 'No hay proyectos aún',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              hasFilter
                  ? 'Intenta con otro filtro o crea un nuevo proyecto'
                  : 'Crea tu primer proyecto usando el botón +',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasFilter) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  setState(() => _filterStatus = null);
                  final workspaceId = context
                      .read<WorkspaceContext>()
                      .activeWorkspace
                      ?.id;
                  if (workspaceId != null) {
                    context.read<ProjectBloc>().add(LoadProjects(workspaceId));
                  }
                },
                icon: const Icon(Icons.clear),
                label: const Text('Limpiar Filtro'),
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
    String searchQuery = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar proyectos'),
        content: TextField(
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
              if (searchQuery.isNotEmpty) {
                context.read<ProjectBloc>().add(SearchProjects(searchQuery));
              }
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
}
