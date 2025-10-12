import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:creapolis_app/features/projects/presentation/blocs/project_bloc.dart';
import 'package:creapolis_app/features/projects/presentation/blocs/project_event.dart';
import 'package:creapolis_app/features/projects/presentation/blocs/project_state.dart';
import 'package:creapolis_app/features/projects/presentation/widgets/project_card.dart';
import 'package:creapolis_app/features/projects/presentation/widgets/create_project_dialog.dart';
import 'package:creapolis_app/features/projects/presentation/widgets/edit_project_dialog.dart';
import 'package:creapolis_app/domain/entities/project.dart';

/// Pantalla principal de gestión de proyectos
class ProjectsScreen extends StatefulWidget {
  final int workspaceId;

  const ProjectsScreen({
    super.key,
    required this.workspaceId,
  });

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  ProjectStatus? _currentFilter;
  bool _showSearch = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadProjects() {
    context.read<ProjectBloc>().add(LoadProjects(widget.workspaceId));
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _FilterBottomSheet(
        currentFilter: _currentFilter,
        onFilterSelected: (filter) {
          setState(() {
            _currentFilter = filter;
          });
          context.read<ProjectBloc>().add(
                FilterProjectsByStatus(filter),
              );
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showCreateProjectDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ProjectBloc>(),
        child: CreateProjectDialog(workspaceId: widget.workspaceId),
      ),
    );
  }

  void _showEditProjectDialog(Project project) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ProjectBloc>(),
        child: EditProjectDialog(project: project),
      ),
    );
  }

  void _showDeleteProjectDialog(Project project) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Proyecto'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${project.name}"?\n\n'
          'Esta acción no se puede deshacer y se eliminarán todas las tareas asociadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              context.read<ProjectBloc>().add(DeleteProject(project.id));
              Navigator.pop(dialogContext);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Buscar proyectos...',
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  context.read<ProjectBloc>().add(SearchProjects(query));
                },
              )
            : const Text('Proyectos'),
        actions: [
          if (_showSearch)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _showSearch = false;
                  _searchController.clear();
                });
                context.read<ProjectBloc>().add(SearchProjects(''));
              },
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _showSearch = true;
                });
              },
            ),
            IconButton(
              icon: Badge(
                isLabelVisible: _currentFilter != null,
                child: const Icon(Icons.filter_list),
              ),
              onPressed: _showFilterMenu,
            ),
          ],
        ],
      ),
      body: BlocConsumer<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.primary,
              ),
            );
          } else if (state is ProjectError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
                action: SnackBarAction(
                  label: 'Reintentar',
                  onPressed: _loadProjects,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProjectLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ProjectsLoaded) {
            final projects = state.filteredProjects;

            if (projects.isEmpty) {
              return _EmptyState(
                hasFilter: _currentFilter != null ||
                    (state.searchQuery?.isNotEmpty ?? false),
                onClearFilters: () {
                  setState(() {
                    _currentFilter = null;
                    _searchController.clear();
                  });
                  context.read<ProjectBloc>().add(
                        FilterProjectsByStatus(null),
                      );
                  context.read<ProjectBloc>().add(SearchProjects(''));
                },
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<ProjectBloc>()
                    .add(RefreshProjects(widget.workspaceId));
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return ProjectCard(
                    project: project,
                    onTap: () {
                      // TODO: Navegar a project detail
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ver detalles: ${project.name}'),
                        ),
                      );
                    },
                    onEdit: () => _showEditProjectDialog(project),
                    onDelete: () => _showDeleteProjectDialog(project),
                  );
                },
              ),
            );
          }

          if (state is ProjectError) {
            return _ErrorState(
              message: state.message,
              onRetry: _loadProjects,
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateProjectDialog,
        icon: const Icon(Icons.add),
        label: const Text('Crear Proyecto'),
      ),
    );
  }
}

/// Estado vacío cuando no hay proyectos
class _EmptyState extends StatelessWidget {
  final bool hasFilter;
  final VoidCallback onClearFilters;

  const _EmptyState({
    required this.hasFilter,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 16),
            Text(
              hasFilter
                  ? 'No hay proyectos con los filtros aplicados'
                  : 'No hay proyectos',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasFilter
                  ? 'Intenta cambiar los filtros de búsqueda'
                  : 'Crea tu primer proyecto para empezar',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasFilter) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpiar Filtros'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Estado de error
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar proyectos',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet para filtros
class _FilterBottomSheet extends StatelessWidget {
  final ProjectStatus? currentFilter;
  final void Function(ProjectStatus?) onFilterSelected;

  const _FilterBottomSheet({
    required this.currentFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Filtrar por estado',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _FilterOption(
            label: 'Todos',
            isSelected: currentFilter == null,
            onTap: () => onFilterSelected(null),
          ),
          _FilterOption(
            label: 'Planificado',
            isSelected: currentFilter == ProjectStatus.planned,
            onTap: () => onFilterSelected(ProjectStatus.planned),
            color: Colors.grey,
          ),
          _FilterOption(
            label: 'Activo',
            isSelected: currentFilter == ProjectStatus.active,
            onTap: () => onFilterSelected(ProjectStatus.active),
            color: Colors.green,
          ),
          _FilterOption(
            label: 'En Pausa',
            isSelected: currentFilter == ProjectStatus.paused,
            onTap: () => onFilterSelected(ProjectStatus.paused),
            color: Colors.orange,
          ),
          _FilterOption(
            label: 'Completado',
            isSelected: currentFilter == ProjectStatus.completed,
            onTap: () => onFilterSelected(ProjectStatus.completed),
            color: Colors.blue,
          ),
          _FilterOption(
            label: 'Cancelado',
            isSelected: currentFilter == ProjectStatus.cancelled,
            onTap: () => onFilterSelected(ProjectStatus.cancelled),
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}

/// Opción de filtro
class _FilterOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: color != null
          ? Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color!.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color!,
                  width: 2,
                ),
              ),
              child: Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            )
          : null,
      title: Text(label),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
            )
          : null,
      onTap: onTap,
    );
  }
}
