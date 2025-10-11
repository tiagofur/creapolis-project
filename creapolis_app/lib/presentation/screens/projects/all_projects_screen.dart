import 'package:flutter/material.dart';

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
///
/// TODO: Conectar con ProjectsBloc para obtener datos reales
class AllProjectsScreen extends StatefulWidget {
  const AllProjectsScreen({super.key});

  @override
  State<AllProjectsScreen> createState() => _AllProjectsScreenState();
}

class _AllProjectsScreenState extends State<AllProjectsScreen> {
  // TODO: Implementar búsqueda y filtros cuando se integre con backend
  // String _searchQuery = '';
  // String _filterStatus = 'all'; // all, active, completed, paused

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proyectos'),
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
              // TODO: Implementar filtrado cuando se integre con backend
              // setState(() {
              //   _filterStatus = value;
              // });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Todos')),
              const PopupMenuItem(value: 'active', child: Text('Activos')),
              const PopupMenuItem(
                value: 'completed',
                child: Text('Completados'),
              ),
              const PopupMenuItem(value: 'paused', child: Text('Pausados')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProjects,
        child: _buildContent(context),
      ),
      // FAB removido: Ahora está en MainShell como Speed Dial global
    );
  }

  Widget _buildContent(BuildContext context) {
    // TODO: Verificar si hay workspace activo
    final hasWorkspace = false; // Temporal

    if (!hasWorkspace) {
      return _buildNoWorkspaceState(context);
    }

    // TODO: Obtener proyectos del BLoC
    // final projects = <dynamic>[]; // Temporal: lista vacía
    //
    // if (projects.isEmpty) {
    //   return _buildEmptyState(context);
    // }
    //
    // return ListView.builder(...);

    // Por ahora siempre mostramos empty state
    return _buildEmptyState(context);
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
                // TODO: Navegar a selección de workspace
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Seleccionar workspace - Por implementar'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.business),
              label: const Text('Seleccionar Workspace'),
            ),
          ],
        ),
      ),
    );
  }

  /// Estado cuando no hay proyectos
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 80, color: theme.colorScheme.outline),
            const SizedBox(height: 24),
            Text(
              'No hay proyectos',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Crea tu primer proyecto para comenzar a organizar tareas',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                // TODO: Navegar a crear proyecto
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Crear proyecto - Por implementar'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Crear Proyecto'),
            ),
          ],
        ),
      ),
    );
  }

  /// Mostrar diálogo de búsqueda
  void _showSearchDialog(BuildContext context) {
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
            // TODO: Implementar búsqueda cuando se integre con backend
            // setState(() {
            //   _searchQuery = value;
            // });
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Aplicar búsqueda
            },
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }

  /// Refrescar lista de proyectos
  Future<void> _refreshProjects() async {
    // TODO: Recargar proyectos desde BLoC
    await Future.delayed(const Duration(seconds: 1));
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
