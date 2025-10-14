# 🔧 Especificaciones Técnicas - Componentes Clave

## 📋 Índice

1. [DashboardScreen](#dashboardscreen)
2. [MainShell con Bottom Navigation](#mainshell-con-bottom-navigation)
3. [AllTasksScreen](#alltasksscreen)
4. [QuickCreateMenu](#quickcreatemenu)
5. [ProfileScreen](#profilescreen)
6. [Extension Methods de Navegación](#extension-methods-de-navegación)
7. [Router Configuration](#router-configuration)

---

## 🏠 DashboardScreen

### Responsabilidades

- Mostrar resumen del día del usuario
- Punto de entrada principal después del login
- Hub de navegación rápida

### Jerarquía de Widgets

```
DashboardScreen (StatelessWidget)
└── Scaffold
    ├── AppBar
    │   ├── Title: "Buen día, [Nombre]"
    │   └── Actions: [Notifications, Settings]
    └── Body: SingleChildScrollView
        └── Padding
            └── Column
                ├── WorkspaceQuickInfo
                ├── SizedBox(height: 16)
                ├── DailySummaryCard
                ├── SizedBox(height: 16)
                ├── QuickActionsGrid
                ├── SizedBox(height: 16)
                └── RecentActivityList
```

### Código Base

```dart
// lib/presentation/screens/dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workspace_context.dart';
import 'widgets/workspace_quick_info.dart';
import 'widgets/daily_summary_card.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/recent_activity_list.dart';

/// Pantalla principal de la aplicación (Dashboard).
///
/// Muestra un resumen del día actual para el usuario, incluyendo:
/// - Información rápida del workspace activo
/// - Resumen de tareas pendientes y proyectos activos
/// - Acciones rápidas para crear contenido
/// - Actividad reciente del workspace
///
/// URL: `/dashboard` o `/`
///
/// Requiere: Usuario autenticado. Workspace activo opcional.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: _buildGreeting(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _showNotifications(context),
            tooltip: 'Notificaciones',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _navigateToSettings(context),
            tooltip: 'Configuración',
          ),
        ],
      ),
      body: Consumer<WorkspaceContext>(
        builder: (context, workspaceContext, child) {
          // Si no hay workspace activo, mostrar empty state
          if (!workspaceContext.hasActiveWorkspace) {
            return _buildNoWorkspaceState(context);
          }

          // Dashboard completo con workspace
          return RefreshIndicator(
            onRefresh: () => _refreshDashboard(context),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Workspace info
                  WorkspaceQuickInfo(
                    workspace: workspaceContext.activeWorkspace!,
                  ),

                  const SizedBox(height: 16),

                  // Daily summary
                  const DailySummaryCard(),

                  const SizedBox(height: 16),

                  // Quick actions
                  const QuickActionsGrid(),

                  const SizedBox(height: 16),

                  // Recent activity
                  const RecentActivityList(),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Buenos días';
    } else if (hour < 18) {
      greeting = 'Buenas tardes';
    } else {
      greeting = 'Buenas noches';
    }

    // TODO: Obtener nombre del usuario desde AuthBloc/UserProfile
    return Text('$greeting 👋');
  }

  Widget _buildNoWorkspaceState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: Agregar ilustración
            const Icon(
              Icons.business_outlined,
              size: 120,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              'Bienvenido a Creapolis',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Crea o únete a un workspace para comenzar a organizar tus proyectos y tareas',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _createWorkspace(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Crear Workspace'),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => _viewInvitations(context),
                  icon: const Icon(Icons.mail_outline),
                  label: const Text('Ver Invitaciones'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshDashboard(BuildContext context) async {
    // TODO: Implementar refresh de datos
    // - Recargar proyectos
    // - Recargar tareas
    // - Recargar actividad reciente
    await Future.delayed(const Duration(seconds: 1));
  }

  void _showNotifications(BuildContext context) {
    // TODO: Implementar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notificaciones próximamente')),
    );
  }

  void _navigateToSettings(BuildContext context) {
    // TODO: Usar extension method
    Navigator.pushNamed(context, '/settings');
  }

  void _createWorkspace(BuildContext context) {
    // TODO: Navegar a crear workspace
  }

  void _viewInvitations(BuildContext context) {
    // TODO: Navegar a invitaciones
  }
}
```

### Widgets Hijos

#### WorkspaceQuickInfo

```dart
// lib/presentation/screens/dashboard/widgets/workspace_quick_info.dart

import 'package:flutter/material.dart';
import '../../../../domain/entities/workspace.dart';

/// Widget que muestra información rápida del workspace activo.
///
/// Incluye:
/// - Avatar del workspace
/// - Nombre del workspace
/// - Rol del usuario (badge)
/// - Botón para cambiar workspace
class WorkspaceQuickInfo extends StatelessWidget {
  final Workspace workspace;

  const WorkspaceQuickInfo({
    super.key,
    required this.workspace,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                workspace.name[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workspace.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // TODO: Obtener rol del usuario en este workspace
                  Chip(
                    label: const Text('Owner'),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            // Cambiar workspace button
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              onPressed: () => _changeWorkspace(context),
              tooltip: 'Cambiar workspace',
            ),
          ],
        ),
      ),
    );
  }

  void _changeWorkspace(BuildContext context) {
    // TODO: Navegar a lista de workspaces o mostrar bottom sheet
  }
}
```

#### DailySummaryCard

```dart
// lib/presentation/screens/dashboard/widgets/daily_summary_card.dart

import 'package:flutter/material.dart';

/// Card que muestra el resumen del día.
///
/// Incluye:
/// - Tareas pendientes (top 5)
/// - Proyectos activos
/// - Progreso general
class DailySummaryCard extends StatelessWidget {
  const DailySummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Resumen del Día',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => _viewAllTasks(context),
                  child: const Text('Ver todo'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Stats
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.task_alt,
                    label: 'Tareas',
                    value: '5',
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.folder,
                    label: 'Proyectos',
                    value: '3',
                    color: Colors.orange,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.check_circle,
                    label: 'Completadas',
                    value: '12',
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Progreso general
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progreso General',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: 0.65,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 4),
                Text(
                  '65% completado',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Próximas tareas
            Text(
              'Próximas Tareas',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            // TODO: Cargar tareas reales desde BLoC
            _buildTaskListItem(context, 'Revisar PRs pendientes', 'Alta'),
            _buildTaskListItem(context, 'Actualizar documentación', 'Media'),
            _buildTaskListItem(context, 'Meeting con equipo', 'Alta'),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskListItem(BuildContext context, String title, String priority) {
    final theme = Theme.of(context);
    Color priorityColor;

    switch (priority) {
      case 'Alta':
        priorityColor = Colors.red;
        break;
      case 'Media':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.green;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(
        Icons.circle,
        size: 12,
        color: priorityColor,
      ),
      title: Text(title),
      trailing: Chip(
        label: Text(
          priority,
          style: const TextStyle(fontSize: 11),
        ),
        visualDensity: VisualDensity.compact,
        backgroundColor: priorityColor.withOpacity(0.1),
      ),
      onTap: () => _openTask(context),
    );
  }

  void _viewAllTasks(BuildContext context) {
    // TODO: Navegar a todas las tareas
  }

  void _openTask(BuildContext context) {
    // TODO: Navegar a detalle de tarea
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
```

#### QuickActionsGrid

```dart
// lib/presentation/screens/dashboard/widgets/quick_actions_grid.dart

import 'package:flutter/material.dart';

/// Grid de acciones rápidas en el dashboard.
///
/// Muestra botones grandes para las acciones más comunes:
/// - Crear Tarea
/// - Crear Proyecto
/// - Ver Tareas
/// - Ver Proyectos
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _QuickActionCard(
              icon: Icons.add_task,
              label: 'Nueva Tarea',
              color: Colors.blue,
              onTap: () => _createTask(context),
            ),
            _QuickActionCard(
              icon: Icons.create_new_folder,
              label: 'Nuevo Proyecto',
              color: Colors.orange,
              onTap: () => _createProject(context),
            ),
            _QuickActionCard(
              icon: Icons.list_alt,
              label: 'Ver Tareas',
              color: Colors.green,
              onTap: () => _viewTasks(context),
            ),
            _QuickActionCard(
              icon: Icons.folder_open,
              label: 'Ver Proyectos',
              color: Colors.purple,
              onTap: () => _viewProjects(context),
            ),
          ],
        ),
      ],
    );
  }

  void _createTask(BuildContext context) {
    // TODO: Mostrar bottom sheet o navegar
  }

  void _createProject(BuildContext context) {
    // TODO: Mostrar bottom sheet o navegar
  }

  void _viewTasks(BuildContext context) {
    // TODO: Navegar a todas las tareas
  }

  void _viewProjects(BuildContext context) {
    // TODO: Navegar a proyectos
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 🧭 MainShell con Bottom Navigation

### Responsabilidades

- Proveer navegación inferior persistente
- Mantener estado de pantallas al cambiar tabs
- Gestionar visibilidad del bottom nav según ruta

### Jerarquía de Widgets

```
MainShell (StatefulWidget)
└── Scaffold
    ├── Body: child (pantalla actual)
    └── BottomNavigationBar: NavigationBar
        └── List<NavigationDestination>
```

### Código Base

```dart
// lib/presentation/widgets/navigation/main_shell.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../routes/route_builder.dart';
import '../../providers/workspace_context.dart';
import 'quick_create_menu.dart';

/// Shell principal de la aplicación con bottom navigation.
///
/// Provee navegación inferior persistente en toda la app.
///
/// El bottom nav tiene 4 tabs:
/// 1. Home (Dashboard)
/// 2. Projects
/// 3. Tasks
/// 4. More (Drawer)
class MainShell extends StatefulWidget {
  /// Child widget (la pantalla actual)
  final Widget child;

  /// Ubicación actual del router
  final String location;

  const MainShell({
    super.key,
    required this.child,
    required this.location,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  void didUpdateWidget(MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.location != oldWidget.location) {
      _updateIndexFromLocation();
    }
  }

  void _updateIndexFromLocation() {
    final location = widget.location;

    if (location == '/' || location.startsWith('/dashboard')) {
      setState(() => _currentIndex = 0);
    } else if (location.contains('/projects')) {
      setState(() => _currentIndex = 1);
    } else if (location.contains('/tasks')) {
      setState(() => _currentIndex = 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verificar si debemos mostrar bottom nav
    final shouldShowBottomNav = _shouldShowBottomNav(widget.location);
    final shouldShowFAB = _shouldShowFAB(widget.location);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: shouldShowBottomNav
          ? NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onDestinationSelected,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.folder_outlined),
                  selectedIcon: Icon(Icons.folder),
                  label: 'Proyectos',
                ),
                NavigationDestination(
                  icon: Icon(Icons.task_alt_outlined),
                  selectedIcon: Icon(Icons.task_alt),
                  label: 'Tareas',
                ),
                NavigationDestination(
                  icon: Icon(Icons.more_horiz),
                  selectedIcon: Icon(Icons.menu),
                  label: 'Más',
                ),
              ],
            )
          : null,
      floatingActionButton: shouldShowFAB
          ? FloatingActionButton(
              onPressed: () => _showQuickCreateMenu(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  bool _shouldShowBottomNav(String location) {
    // No mostrar en auth screens
    if (location.startsWith('/auth')) return false;

    // No mostrar en splash
    if (location.startsWith('/splash')) return false;

    // No mostrar en onboarding
    if (location.startsWith('/onboarding')) return false;

    // No mostrar en pantallas de detalle profundas
    // TODO: Ajustar según necesidad

    return true;
  }

  bool _shouldShowFAB(String location) {
    // Mostrar en dashboard, projects, tasks
    return location == '/' ||
           location.startsWith('/dashboard') ||
           location.contains('/projects') ||
           location.contains('/tasks');
  }

  void _onDestinationSelected(int index) {
    setState(() => _currentIndex = index);

    final workspaceContext = context.read<WorkspaceContext>();
    final workspaceId = workspaceContext.activeWorkspace?.id;

    switch (index) {
      case 0:
        // Home
        context.go('/dashboard');
        break;

      case 1:
        // Projects
        if (workspaceId != null) {
          context.goToProjects(workspaceId);
        } else {
          context.goToWorkspaces();
          _showNoWorkspaceMessage(context);
        }
        break;

      case 2:
        // Tasks
        if (workspaceId != null) {
          context.goToAllTasks(workspaceId);
        } else {
          context.goToWorkspaces();
          _showNoWorkspaceMessage(context);
        }
        break;

      case 3:
        // More - Abrir drawer
        Scaffold.of(context).openDrawer();
        break;
    }
  }

  void _showQuickCreateMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const QuickCreateMenu(),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  void _showNoWorkspaceMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Selecciona un workspace primero'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
```

### Integración con GoRouter

```dart
// En app_router.dart

static final GoRouter router = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: RoutePaths.splash,
  redirect: _handleRedirect,
  routes: [
    // Rutas sin shell (auth, splash)
    GoRoute(
      path: RoutePaths.splash,
      name: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RoutePaths.login,
      name: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),

    // Shell con bottom navigation
    ShellRoute(
      builder: (context, state, child) {
        return MainShell(
          child: child,
          location: state.location,
        );
      },
      routes: [
        // Dashboard
        GoRoute(
          path: '/',
          name: RouteNames.dashboard,
          builder: (context, state) => const DashboardScreen(),
        ),

        // Workspaces y rutas anidadas
        GoRoute(
          path: RoutePaths.workspaces,
          name: RouteNames.workspaces,
          builder: (context, state) => const WorkspaceListScreen(),
          routes: [
            // ... rutas anidadas de workspaces
          ],
        ),

        // Settings
        GoRoute(
          path: RoutePaths.settings,
          name: RouteNames.settings,
          builder: (context, state) => const SettingsScreen(),
        ),

        // Profile
        GoRoute(
          path: '/profile',
          name: RouteNames.profile,
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);
```

---

## 📱 Extension Methods de Navegación

### Archivo: route_builder.dart

```dart
// lib/routes/route_builder.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Extension methods para navegación type-safe.
///
/// Centraliza toda la lógica de navegación en un solo lugar,
/// facilitando mantenimiento y evitando errores de typos en URLs.
extension NavigationExtensions on BuildContext {
  // ============================================================
  // DASHBOARD
  // ============================================================

  /// Navega al dashboard principal.
  ///
  /// URL: `/dashboard` o `/`
  void goToDashboard() => go('/');

  // ============================================================
  // WORKSPACES
  // ============================================================

  /// Navega a la lista de workspaces.
  ///
  /// URL: `/workspaces`
  void goToWorkspaces() => go('/workspaces');

  /// Navega a crear un nuevo workspace.
  ///
  /// URL: `/workspaces/create`
  void goToWorkspaceCreate() => go('/workspaces/create');

  /// Navega a las invitaciones pendientes.
  ///
  /// URL: `/workspaces/invitations`
  void goToInvitations() => go('/workspaces/invitations');

  /// Navega a los miembros de un workspace.
  ///
  /// URL: `/workspaces/:wId/members`
  void goToWorkspaceMembers(int workspaceId) =>
      go('/workspaces/$workspaceId/members');

  /// Navega a la configuración de un workspace.
  ///
  /// URL: `/workspaces/:wId/settings`
  void goToWorkspaceSettings(int workspaceId) =>
      go('/workspaces/$workspaceId/settings');

  // ============================================================
  // PROJECTS
  // ============================================================

  /// Navega a la lista de proyectos de un workspace.
  ///
  /// URL: `/workspaces/:wId/projects`
  void goToProjects(int workspaceId) =>
      go('/workspaces/$workspaceId/projects');

  /// Navega al detalle de un proyecto.
  ///
  /// URL: `/workspaces/:wId/projects/:pId`
  void goToProjectDetail(int workspaceId, int projectId) =>
      go('/workspaces/$workspaceId/projects/$projectId');

  /// Push al detalle de un proyecto (mantiene stack).
  ///
  /// Útil cuando quieres permitir "back" a la pantalla anterior.
  void pushToProjectDetail(int workspaceId, int projectId) =>
      push('/workspaces/$workspaceId/projects/$projectId');

  /// Navega a la vista Gantt de un proyecto.
  ///
  /// URL: `/workspaces/:wId/projects/:pId/gantt`
  void goToGantt(int workspaceId, int projectId) =>
      go('/workspaces/$workspaceId/projects/$projectId/gantt');

  /// Navega a la vista Workload de un proyecto.
  ///
  /// URL: `/workspaces/:wId/projects/:pId/workload`
  void goToWorkload(int workspaceId, int projectId) =>
      go('/workspaces/$workspaceId/projects/$projectId/workload');

  // ============================================================
  // TASKS
  // ============================================================

  /// Navega a todas las tareas de un workspace.
  ///
  /// URL: `/workspaces/:wId/tasks`
  void goToAllTasks(int workspaceId) =>
      go('/workspaces/$workspaceId/tasks');

  /// Navega al detalle de una tarea.
  ///
  /// URL: `/workspaces/:wId/projects/:pId/tasks/:tId`
  void goToTaskDetail(int workspaceId, int projectId, int taskId) =>
      go('/workspaces/$workspaceId/projects/$projectId/tasks/$taskId');

  /// Push al detalle de una tarea (mantiene stack).
  void pushToTask(int workspaceId, int projectId, int taskId) =>
      push('/workspaces/$workspaceId/projects/$projectId/tasks/$taskId');

  // ============================================================
  // PROFILE & SETTINGS
  // ============================================================

  /// Navega al perfil del usuario.
  ///
  /// URL: `/profile`
  void goToProfile() => go('/profile');

  /// Navega a la configuración de la app.
  ///
  /// URL: `/settings`
  void goToSettings() => go('/settings');

  // ============================================================
  // AUTH
  // ============================================================

  /// Navega al login.
  ///
  /// URL: `/auth/login`
  void goToLogin() => go('/auth/login');

  /// Navega al registro.
  ///
  /// URL: `/auth/register`
  void goToRegister() => go('/auth/register');

  // ============================================================
  // ONBOARDING
  // ============================================================

  /// Navega al onboarding (primera vez).
  ///
  /// URL: `/onboarding`
  void goToOnboarding() => go('/onboarding');
}

/// Helper para validar workspace antes de navegar.
///
/// Si no hay workspace activo, muestra mensaje y redirige a seleccionar workspace.
bool validateWorkspaceBeforeNavigation(
  BuildContext context,
  int? workspaceId,
) {
  if (workspaceId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Selecciona un workspace primero'),
        duration: Duration(seconds: 2),
      ),
    );
    context.goToWorkspaces();
    return false;
  }
  return true;
}
```

---

## 📝 Resumen de Archivos a Crear

### Nuevos Archivos (24 archivos)

```
lib/presentation/screens/dashboard/
├── dashboard_screen.dart                    [✅ ESPECIFICADO]
└── widgets/
    ├── workspace_quick_info.dart           [✅ ESPECIFICADO]
    ├── daily_summary_card.dart             [✅ ESPECIFICADO]
    ├── quick_actions_grid.dart             [✅ ESPECIFICADO]
    └── recent_activity_list.dart           [⏳ PENDIENTE]

lib/presentation/widgets/navigation/
├── main_shell.dart                          [✅ ESPECIFICADO]
├── quick_create_menu.dart                   [⏳ PENDIENTE]
└── nav_destination_config.dart              [⏳ PENDIENTE]

lib/presentation/screens/tasks/
└── all_tasks_screen.dart                    [⏳ PENDIENTE]

lib/presentation/screens/profile/
├── profile_screen.dart                      [⏳ PENDIENTE]
└── widgets/
    ├── user_info_card.dart                  [⏳ PENDIENTE]
    ├── user_stats_card.dart                 [⏳ PENDIENTE]
    └── user_workspaces_list.dart            [⏳ PENDIENTE]

lib/presentation/screens/onboarding/
├── onboarding_screen.dart                   [⏳ PENDIENTE]
└── widgets/
    ├── onboarding_page.dart                 [⏳ PENDIENTE]
    └── onboarding_page_indicator.dart       [⏳ PENDIENTE]

lib/presentation/widgets/common/
└── improved_empty_state.dart                [⏳ PENDIENTE]

lib/core/utils/
└── dialog_helpers.dart                      [⏳ PENDIENTE]
```

### Archivos a Modificar (6 archivos)

```
lib/routes/
├── app_router.dart                          [Agregar ShellRoute]
└── route_builder.dart                       [✅ ACTUALIZADO con todos los extension methods]

lib/presentation/screens/auth/
├── login_screen.dart                        [Cambiar redirect]
└── register_screen.dart                     [Cambiar redirect]

lib/presentation/screens/workspace/
└── workspace_list_screen.dart               [Mejorar empty state]

lib/presentation/screens/projects/
└── projects_list_screen.dart                [Mejorar empty state]
```

---

**Documento creado**: 2025-01-11
**Última actualización**: 2025-01-11
**Versión**: 1.0
**Estado**: 📋 ESPECIFICACIONES TÉCNICAS COMPLETAS
