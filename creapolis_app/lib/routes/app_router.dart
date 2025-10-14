import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/storage_keys.dart';
import '../core/services/last_route_service.dart';
import '../core/utils/app_logger.dart';
import '../injection.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../presentation/screens/gantt/gantt_chart_screen.dart';
import '../presentation/screens/main_shell/main_shell.dart';
import '../presentation/screens/more/more_screen.dart';
import '../presentation/screens/onboarding/onboarding_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/projects/all_projects_screen.dart';
import '../presentation/screens/projects/project_detail_screen.dart';
import '../features/projects/presentation/screens/projects_screen.dart';
import '../features/tasks/presentation/screens/tasks_screen.dart';
import '../features/tasks/presentation/blocs/task_bloc.dart';
import '../features/tasks/presentation/blocs/task_event.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/settings/role_based_preferences_screen.dart';
import '../presentation/screens/customization_metrics_screen.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/tasks/all_tasks_screen.dart';
import '../presentation/screens/tasks/task_detail_screen.dart';
import '../presentation/screens/workload/workload_screen.dart';
import '../presentation/screens/resource_map/resource_allocation_map_screen.dart';
import '../presentation/screens/workspace/workspace_create_screen.dart';
import '../presentation/screens/workspace/workspace_invitations_screen.dart';
import '../presentation/screens/workspace/workspace_list_screen.dart';

/// Configuración de rutas de la aplicación
class AppRouter {
  static final _secureStorage = getIt<FlutterSecureStorage>();
  static final _lastRouteService = getIt<LastRouteService>();

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

      // Onboarding Route
      GoRoute(
        path: RoutePaths.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Settings Routes (global)
      GoRoute(
        path: RoutePaths.settings,
        name: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),

      // Profile Route (global)
      GoRoute(
        path: RoutePaths.profile,
        name: RouteNames.profile,
        builder: (context, state) => const ProfileScreen(),
      ),

      // Role-Based Preferences Route
      GoRoute(
        path: RoutePaths.rolePreferences,
        name: RouteNames.rolePreferences,
        builder: (context, state) => const RoleBasedPreferencesScreen(),
      ),

      // Customization Metrics Route (admin only)
      GoRoute(
        path: RoutePaths.customizationMetrics,
        name: RouteNames.customizationMetrics,
        builder: (context, state) => const CustomizationMetricsScreen(),
      ),

      // Main Shell con Bottom Navigation (4 tabs)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(
            navigationShell: navigationShell,
            child: navigationShell,
          );
        },
        branches: [
          // Branch 0: Dashboard (Home)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.dashboard,
                name: RouteNames.dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          // Branch 1: All Projects
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.allProjects,
                name: RouteNames.allProjects,
                builder: (context, state) => const AllProjectsScreen(),
              ),
            ],
          ),

          // Branch 2: All Tasks
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.allTasks,
                name: RouteNames.allTasks,
                builder: (context, state) => const AllTasksScreen(),
              ),
            ],
          ),

          // Branch 3: More (Menu)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.more,
                name: RouteNames.more,
                builder: (context, state) => const MoreScreen(),
              ),
            ],
          ),
        ],
      ),

      // Workspace Routes con rutas anidadas
      GoRoute(
        path: RoutePaths.workspaces,
        name: RouteNames.workspaces,
        builder: (context, state) => const WorkspaceListScreen(),
        routes: [
          // Create workspace (no requiere ID)
          GoRoute(
            path: 'create',
            name: RouteNames.workspaceCreate,
            builder: (context, state) => const WorkspaceCreateScreen(),
          ),

          // Invitations (global de workspaces)
          GoRoute(
            path: 'invitations',
            name: RouteNames.invitations,
            builder: (context, state) => const WorkspaceInvitationsScreen(),
          ),

          // Rutas específicas de un workspace (anidadas bajo :wId)
          GoRoute(
            path: ':wId',
            name: RouteNames.workspaceDetail,
            builder: (context, state) {
              // TODO: Cargar workspace por ID
              return const WorkspaceListScreen(); // Temporal
            },
            routes: [
              // Members del workspace
              GoRoute(
                path: 'members',
                name: RouteNames.workspaceMembers,
                builder: (context, state) {
                  // TODO: Cargar workspace por ID y pasar a MembersScreen
                  return const WorkspaceListScreen(); // Temporal
                },
              ),

              // Settings del workspace
              GoRoute(
                path: 'settings',
                name: RouteNames.workspaceSettings,
                builder: (context, state) {
                  // TODO: Cargar workspace por ID y pasar a SettingsScreen
                  return const WorkspaceListScreen(); // Temporal
                },
              ),

              // Projects list dentro de un workspace
              GoRoute(
                path: 'projects',
                name: RouteNames.projects,
                builder: (context, state) {
                  final wId = state.pathParameters['wId'] ?? '0';
                  return ProjectsScreen(workspaceId: int.parse(wId));
                },
                routes: [
                  // Project detail con todas sus sub-rutas
                  GoRoute(
                    path: ':pId',
                    name: RouteNames.projectDetail,
                    builder: (context, state) {
                      final id = state.pathParameters['pId'] ?? '0';
                      return ProjectDetailScreen(projectId: id);
                    },
                    routes: [
                      // Tasks list del proyecto
                      GoRoute(
                        path: 'tasks',
                        name: RouteNames.tasks,
                        builder: (context, state) {
                          final pId = state.pathParameters['pId'] ?? '0';
                          return BlocProvider(
                            create: (context) =>
                                getIt<TaskBloc>()
                                  ..add(LoadTasks(int.parse(pId))),
                            child: TasksScreen(projectId: int.parse(pId)),
                          );
                        },
                      ),

                      // Gantt chart del proyecto
                      GoRoute(
                        path: 'gantt',
                        name: RouteNames.gantt,
                        builder: (context, state) {
                          final projectId = state.pathParameters['pId'] ?? '0';
                          return GanttChartScreen(
                            projectId: int.parse(projectId),
                          );
                        },
                      ),

                      // Workload del proyecto
                      GoRoute(
                        path: 'workload',
                        name: RouteNames.workload,
                        builder: (context, state) {
                          final projectId = state.pathParameters['pId'] ?? '0';
                          return WorkloadScreen(
                            projectId: int.parse(projectId),
                          );
                        },
                      ),

                      // Mapa de recursos del proyecto
                      GoRoute(
                        path: 'resource-map',
                        name: RouteNames.resourceMap,
                        builder: (context, state) {
                          final projectId = state.pathParameters['pId'] ?? '0';
                          return ResourceAllocationMapScreen(
                            projectId: int.parse(projectId),
                          );
                        },
                      ),

                      // Task detail dentro del proyecto
                      GoRoute(
                        path: 'tasks/:tId',
                        name: RouteNames.taskDetail,
                        builder: (context, state) {
                          final projectId = state.pathParameters['pId'] ?? '0';
                          final taskId = state.pathParameters['tId'] ?? '0';
                          return TaskDetailScreen(
                            taskId: int.parse(taskId),
                            projectId: int.parse(projectId),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  /// Manejar redirecciones basadas en autenticación y permisos
  static Future<String?> _handleRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final currentPath = state.matchedLocation;

    AppLogger.info('AppRouter: Evaluando redirect para: $currentPath');

    // Si está en splash, permitir
    if (currentPath == RoutePaths.splash) {
      return null;
    }

    // Verificar si tiene token de autenticación
    final hasToken = await _hasValidToken();
    final isAuthRoute = currentPath.startsWith('/auth');

    // **Caso 1: Sin token y no en ruta de auth**
    if (!hasToken && !isAuthRoute) {
      AppLogger.info(
        'AppRouter: Sin token, guardando ruta y redirigiendo a login',
      );

      // Guardar la ruta que intentaba visitar para restaurar después del login
      if (_lastRouteService.isValidRoute(currentPath)) {
        await _lastRouteService.saveLastRoute(currentPath);

        // Guardar workspace ID si la ruta lo contiene
        final workspaceId = _lastRouteService.extractWorkspaceId(currentPath);
        if (workspaceId != null) {
          await _lastRouteService.saveLastWorkspace(workspaceId);
        }
      }

      return RoutePaths.login;
    }

    // **Caso 2: Con token y en ruta de auth**
    if (hasToken && isAuthRoute) {
      AppLogger.info(
        'AppRouter: Con token en ruta de auth, intentando restaurar última ruta',
      );

      // Intentar restaurar la última ruta visitada
      final lastRoute = await _lastRouteService.getLastRoute();

      if (lastRoute != null && _lastRouteService.isValidRoute(lastRoute)) {
        AppLogger.info('AppRouter: Restaurando última ruta: $lastRoute');

        // TODO: Aquí se podría validar permisos de workspace antes de restaurar
        // Por ahora, simplemente restauramos la ruta

        return lastRoute;
      }

      // Si no hay ruta guardada, ir a dashboard
      AppLogger.info(
        'AppRouter: No hay ruta guardada, redirigiendo a dashboard',
      );
      return RoutePaths.dashboard;
    }

    // **Caso 3: Con token y en ruta protegida con workspace**
    if (hasToken && _lastRouteService.requiresWorkspace(currentPath)) {
      // Guardar la ruta actual como última visitada
      await _lastRouteService.saveLastRoute(currentPath);

      // Guardar workspace ID
      final workspaceId = _lastRouteService.extractWorkspaceId(currentPath);
      if (workspaceId != null) {
        await _lastRouteService.saveLastWorkspace(workspaceId);
      }

      // TODO: Aquí se podría validar si el usuario tiene acceso al workspace
      // Por ahora, permitimos el acceso y dejamos que el screen maneje el error
    }

    // **Caso 4: Guardar ruta válida para futuras referencias**
    if (hasToken && _lastRouteService.isValidRoute(currentPath)) {
      await _lastRouteService.saveLastRoute(currentPath);
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

  /// Navegar a workspaces y limpiar stack
  static void goToWorkspaces(BuildContext context) {
    context.go(RoutePaths.workspaces);
  }

  /// Navegar a projects de un workspace
  static void goToProjects(BuildContext context, int workspaceId) {
    context.go(RoutePaths.projects(workspaceId));
  }

  /// Logout y limpiar token
  static Future<void> logout(BuildContext context) async {
    AppLogger.info('AppRouter: Ejecutando logout y limpiando datos');

    // Limpiar tokens de autenticación
    await _secureStorage.delete(key: StorageKeys.accessToken);
    await _secureStorage.delete(key: StorageKeys.refreshToken);

    // Limpiar rutas guardadas
    await _lastRouteService.clearAll();

    // Redirigir a login si el context está montado
    if (context.mounted) {
      goToLogin(context);
    }
  }
}

/// Rutas de la aplicación
class RoutePaths {
  static const String splash = '/splash';
  static const String dashboard = '/';
  static const String allProjects = '/projects';
  static const String allTasks = '/tasks';
  static const String more = '/more';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String onboarding = '/onboarding';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String rolePreferences = '/role-preferences';
  static const String customizationMetrics = '/customization-metrics';

  // Workspace routes
  static const String workspaces = '/workspaces';
  static const String workspaceCreate = '/workspaces/create';
  static const String invitations = '/workspaces/invitations';

  // Dynamic workspace routes (requieren workspaceId)
  static String workspaceDetail(int wId) => '/workspaces/$wId';
  static String workspaceMembers(int wId) => '/workspaces/$wId/members';
  static String workspaceSettings(int wId) => '/workspaces/$wId/settings';

  // Project routes (requieren workspaceId)
  static String projects(int wId) => '/workspaces/$wId/projects';
  static String projectDetail(int wId, int pId) =>
      '/workspaces/$wId/projects/$pId';

  // Project views (requieren workspaceId y projectId)
  static String gantt(int wId, int pId) =>
      '/workspaces/$wId/projects/$pId/gantt';
  static String workload(int wId, int pId) =>
      '/workspaces/$wId/projects/$pId/workload';
  static String resourceMap(int wId, int pId) =>
      '/workspaces/$wId/projects/$pId/resource-map';

  // Task routes (requieren workspaceId, projectId y taskId)
  static String taskDetail(int wId, int pId, int tId) =>
      '/workspaces/$wId/projects/$pId/tasks/$tId';
}

/// Nombres de rutas para navegación con nombre
class RouteNames {
  static const String splash = 'splash';
  static const String dashboard = 'dashboard';
  static const String allProjects = 'all-projects';
  static const String allTasks = 'all-tasks';
  static const String more = 'more';
  static const String login = 'login';
  static const String register = 'register';
  static const String onboarding = 'onboarding';
  static const String projects = 'projects';
  static const String projectDetail = 'project-detail';
  static const String tasks = 'tasks';
  static const String taskDetail = 'task-detail';
  static const String gantt = 'gantt';
  static const String timeTracking = 'time-tracking';
  static const String workload = 'workload';
  static const String resourceMap = 'resource-map';
  static const String settings = 'settings';
  static const String profile = 'profile';
  static const String rolePreferences = 'role-preferences';
  static const String customizationMetrics = 'customization-metrics';

  // Workspace route names
  static const String workspaces = 'workspaces';
  static const String workspaceDetail = 'workspace-detail';
  static const String workspaceCreate = 'workspace-create';
  static const String workspaceEdit = 'workspace-edit';
  static const String workspaceMembers = 'workspace-members';
  static const String workspaceSettings = 'workspace-settings';
  static const String invitations = 'invitations';
}
