import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/storage_keys.dart';
import '../injection.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/gantt/gantt_chart_screen.dart';
import '../presentation/screens/projects/project_detail_screen.dart';
import '../presentation/screens/projects/projects_list_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/tasks/task_detail_screen.dart';
import '../presentation/screens/workload/workload_screen.dart';
import '../presentation/screens/workspace/workspace_create_screen.dart';
import '../presentation/screens/workspace/workspace_detail_screen.dart';
import '../presentation/screens/workspace/workspace_edit_screen.dart';
import '../presentation/screens/workspace/workspace_invitations_screen.dart';
import '../presentation/screens/workspace/workspace_list_screen.dart';
import '../presentation/screens/workspace/workspace_members_screen.dart';
import '../presentation/screens/workspace/workspace_settings_screen.dart';

/// Configuración de rutas de la aplicación
class AppRouter {
  static final _secureStorage = getIt<FlutterSecureStorage>();

  /// Instancia de GoRouter
  static final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: RoutePaths.splash,
    redirect: _handleRedirect,
    routes: [
      // Splash Screen
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Projects Routes
      GoRoute(
        path: RoutePaths.projects,
        name: RouteNames.projects,
        builder: (context, state) => const ProjectsListScreen(),
      ),
      GoRoute(
        path: RoutePaths.projectDetail,
        name: RouteNames.projectDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '0';
          return ProjectDetailScreen(projectId: id);
        },
      ),

      // Gantt Routes
      GoRoute(
        path: RoutePaths.gantt,
        name: RouteNames.gantt,
        builder: (context, state) {
          final projectId = state.pathParameters['projectId'] ?? '0';
          return GanttChartScreen(projectId: int.parse(projectId));
        },
      ),

      // Task Detail Route
      GoRoute(
        path: RoutePaths.taskDetail,
        name: RouteNames.taskDetail,
        builder: (context, state) {
          final projectId = state.pathParameters['projectId'] ?? '0';
          final taskId = state.pathParameters['taskId'] ?? '0';
          return TaskDetailScreen(
            taskId: int.parse(taskId),
            projectId: int.parse(projectId),
          );
        },
      ),

      // Workload Route
      GoRoute(
        path: RoutePaths.workload,
        name: RouteNames.workload,
        builder: (context, state) {
          final projectId = state.pathParameters['projectId'] ?? '0';
          return WorkloadScreen(projectId: int.parse(projectId));
        },
      ),

      // Settings Routes
      GoRoute(
        path: RoutePaths.settings,
        name: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),

      // Workspace Routes
      GoRoute(
        path: RoutePaths.workspaces,
        name: RouteNames.workspaces,
        builder: (context, state) => const WorkspaceListScreen(),
      ),
      GoRoute(
        path: RoutePaths.workspaceDetail,
        name: RouteNames.workspaceDetail,
        builder: (context, state) {
          // TODO: Cargar workspace por ID
          return const WorkspaceListScreen(); // Temporal
        },
      ),
      GoRoute(
        path: RoutePaths.workspaceCreate,
        name: RouteNames.workspaceCreate,
        builder: (context, state) => const WorkspaceCreateScreen(),
      ),
      GoRoute(
        path: RoutePaths.workspaceMembers,
        name: RouteNames.workspaceMembers,
        builder: (context, state) {
          // TODO: Cargar workspace por ID y pasar a MembersScreen
          return const WorkspaceListScreen(); // Temporal
        },
      ),
      GoRoute(
        path: RoutePaths.workspaceSettings,
        name: RouteNames.workspaceSettings,
        builder: (context, state) {
          // TODO: Cargar workspace por ID y pasar a SettingsScreen
          return const WorkspaceListScreen(); // Temporal
        },
      ),
      GoRoute(
        path: RoutePaths.invitations,
        name: RouteNames.invitations,
        builder: (context, state) => const WorkspaceInvitationsScreen(),
      ),
    ],
  );

  /// Manejar redirecciones basadas en autenticación
  static Future<String?> _handleRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final currentPath = state.matchedLocation;

    // Si está en splash, permitir
    if (currentPath == RoutePaths.splash) {
      return null;
    }

    // Verificar si tiene token de autenticación
    final hasToken = await _hasValidToken();

    final isAuthRoute = currentPath.startsWith('/auth');

    // Si no tiene token y no está en ruta de auth, redirigir a login
    if (!hasToken && !isAuthRoute) {
      return RoutePaths.login;
    }

    // Si tiene token y está en ruta de auth, redirigir a projects
    if (hasToken && isAuthRoute) {
      return RoutePaths.projects;
    }

    // No redirigir
    return null;
  }

  /// Verificar si existe un token válido
  static Future<bool> _hasValidToken() async {
    try {
      final token = await _secureStorage.read(key: StorageKeys.accessToken);
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Navegar a login y limpiar stack
  static void goToLogin(BuildContext context) {
    context.go(RoutePaths.login);
  }

  /// Navegar a projects y limpiar stack
  static void goToProjects(BuildContext context) {
    context.go(RoutePaths.projects);
  }

  /// Logout y limpiar token
  static Future<void> logout(BuildContext context) async {
    await _secureStorage.delete(key: StorageKeys.accessToken);
    await _secureStorage.delete(key: StorageKeys.refreshToken);
    if (context.mounted) {
      goToLogin(context);
    }
  }
}

/// Rutas de la aplicación
class RoutePaths {
  static const String splash = '/splash';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String projects = '/projects';
  static const String projectDetail = '/projects/:id';
  static const String tasks = '/projects/:projectId/tasks';
  static const String taskDetail = '/projects/:projectId/tasks/:taskId';
  static const String gantt = '/projects/:projectId/gantt';
  static const String workload = '/projects/:projectId/workload';
  static const String timeTracking = '/time-tracking';
  static const String settings = '/settings';

  // Workspace routes
  static const String workspaces = '/workspaces';
  static const String workspaceDetail = '/workspaces/:id';
  static const String workspaceCreate = '/workspaces/create';
  static const String workspaceEdit = '/workspaces/:id/edit';
  static const String workspaceMembers = '/workspaces/:id/members';
  static const String workspaceSettings = '/workspaces/:id/settings';
  static const String invitations = '/invitations';
}

/// Nombres de rutas para navegación con nombre
class RouteNames {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String projects = 'projects';
  static const String projectDetail = 'project-detail';
  static const String tasks = 'tasks';
  static const String taskDetail = 'task-detail';
  static const String gantt = 'gantt';
  static const String timeTracking = 'time-tracking';
  static const String workload = 'workload';
  static const String settings = 'settings';

  // Workspace route names
  static const String workspaces = 'workspaces';
  static const String workspaceDetail = 'workspace-detail';
  static const String workspaceCreate = 'workspace-create';
  static const String workspaceEdit = 'workspace-edit';
  static const String workspaceMembers = 'workspace-members';
  static const String workspaceSettings = 'workspace-settings';
  static const String invitations = 'invitations';
}
