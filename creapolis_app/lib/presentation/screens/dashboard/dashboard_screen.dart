import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../core/services/dashboard_preferences_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/dashboard_widget_config.dart';
import '../../bloc/project/project_bloc.dart';
import '../../bloc/project/project_event.dart';
import '../../providers/workspace_context.dart';
import 'widgets/add_widget_bottom_sheet.dart';
import 'widgets/dashboard_widget_factory.dart';

/// Pantalla principal del Dashboard.
///
/// Punto de entrada principal de la aplicación después del login.
/// Muestra un resumen del workspace activo, tareas, proyectos y actividad reciente.
///
/// URL: `/` (raíz)
///
/// Características:
/// - Información rápida del workspace activo
/// - Resumen diario de tareas y proyectos
/// - Acciones rápidas (nueva tarea, nuevo proyecto, buscar, notificaciones)
/// - Mis tareas activas
/// - Mis proyectos recientes
/// - Actividad reciente
/// - Integrado con WorkspaceContext para filtrar por workspace activo
/// - **NUEVO**: Widgets personalizables con drag & drop
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _preferencesService = DashboardPreferencesService.instance;
  DashboardConfig _dashboardConfig = DashboardConfig.defaultConfig();
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
    // Cargar datos del workspace activo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  void _loadConfiguration() {
    setState(() {
      _dashboardConfig = _preferencesService.getDashboardConfig();
    });
    AppLogger.info(
      'Dashboard: Configuración cargada (${_dashboardConfig.widgets.length} widgets)',
    );
  }

  void _loadDashboardData() {
    final workspaceContext = context.read<WorkspaceContext>();
    final activeWorkspace = workspaceContext.activeWorkspace;

    if (activeWorkspace != null) {
      AppLogger.info(
        'Dashboard: Cargando datos del workspace ${activeWorkspace.id}',
      );
      // Cargar proyectos del workspace activo
      context.read<ProjectBloc>().add(
        LoadProjectsEvent(workspaceId: activeWorkspace.id),
      );
    } else {
      AppLogger.warning('Dashboard: No hay workspace activo');
    }
  }

  Future<void> _refreshDashboard() async {
    final workspaceContext = context.read<WorkspaceContext>();
    final activeWorkspace = workspaceContext.activeWorkspace;

    if (activeWorkspace != null) {
      AppLogger.info('Dashboard: Refrescando datos');
      context.read<ProjectBloc>().add(
        RefreshProjectsEvent(workspaceId: activeWorkspace.id),
      );
    }

    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _toggleEditMode() async {
    setState(() {
      _isEditMode = !_isEditMode;
    });

    if (!_isEditMode) {
      // Save configuration when exiting edit mode
      final success = await _preferencesService.saveDashboardConfig(
        _dashboardConfig,
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuración guardada'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _addWidget() async {
    final selectedType = await AddWidgetBottomSheet.show(context);

    if (selectedType != null) {
      final success = await _preferencesService.addWidget(selectedType);

      if (success) {
        _loadConfiguration();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Widget "${selectedType.displayName}" añadido'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  Future<void> _removeWidget(String widgetId) async {
    final success = await _preferencesService.removeWidget(widgetId);

    if (success) {
      _loadConfiguration();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Widget eliminado'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _resetConfiguration() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetear Configuración'),
        content: const Text(
          '¿Estás seguro de que quieres restaurar la configuración por defecto del dashboard?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Resetear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _preferencesService.resetDashboardConfig();

      if (success) {
        _loadConfiguration();
        setState(() {
          _isEditMode = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Configuración reseteada'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final widgets = List<DashboardWidgetConfig>.from(
        _dashboardConfig.visibleWidgets,
      );
      final item = widgets.removeAt(oldIndex);
      widgets.insert(newIndex, item);

      // Update positions
      for (var i = 0; i < widgets.length; i++) {
        widgets[i] = widgets[i].copyWith(position: i);
      }

      _dashboardConfig = _dashboardConfig.copyWith(
        widgets: widgets,
        lastModified: DateTime.now(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Creapolis'),
        actions: [
          // Edit mode toggle
          IconButton(
            icon: Icon(_isEditMode ? Icons.check : Icons.edit),
            onPressed: _toggleEditMode,
            tooltip: _isEditMode ? 'Guardar' : 'Personalizar',
          ),
          // Reset configuration
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.restore),
              onPressed: _resetConfiguration,
              tooltip: 'Resetear configuración',
            ),
          // Notifications
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notificaciones - Por implementar'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          // Profile
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Perfil - Por implementar'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: _isEditMode ? _buildEditModeView() : _buildNormalView(),
      ),
      floatingActionButton: _isEditMode
          ? FloatingActionButton.extended(
              onPressed: _addWidget,
              icon: const Icon(Icons.add),
              label: const Text('Añadir Widget'),
            )
          : null,
    );
  }

  Widget _buildNormalView() {
    final visibleWidgets = _dashboardConfig.visibleWidgets;

    if (visibleWidgets.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var config in visibleWidgets) ...[
            DashboardWidgetFactory.buildWidget(context, config),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildEditModeView() {
    final visibleWidgets = _dashboardConfig.visibleWidgets;

    if (visibleWidgets.isEmpty) {
      return _buildEmptyState();
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16.0),
      onReorder: _onReorder,
      itemCount: visibleWidgets.length,
      itemBuilder: (context, index) {
        final config = visibleWidgets[index];
        return Padding(
          key: ValueKey(config.id),
          padding: const EdgeInsets.only(bottom: 16),
          child: DashboardWidgetFactory.buildWidget(
            context,
            config,
            onRemove: () => _removeWidget(config.id),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.widgets_outlined,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Tu dashboard está vacío',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Añade widgets para personalizar tu experiencia',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _addWidget,
              icon: const Icon(Icons.add),
              label: const Text('Añadir Widget'),
            ),
          ],
        ),
      ),
    );
  }
}
