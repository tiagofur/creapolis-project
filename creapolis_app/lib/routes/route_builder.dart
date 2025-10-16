import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Helper class para construir rutas con parámetros
class RouteBuilder {
  RouteBuilder._();

  // Auth routes
  static String login() => '/auth/login';
  static String register() => '/auth/register';

  // Onboarding route
  static String onboarding() => '/onboarding';

  // Dashboard route
  static String dashboard() => '/';

  // Bottom Navigation routes
  static String allProjects() => '/projects';
  static String allTasks() => '/tasks';
  static String more() => '/more';

  // Workspace routes (anidados bajo More)
  static String workspaces() => '/more/workspaces';

  static String workspaceDetail(int workspaceId) =>
      '/more/workspaces/$workspaceId';

  static String workspaceCreate() => '/more/workspaces/create';

  static String workspaceMembers(int workspaceId) =>
      '/more/workspaces/$workspaceId/members';

  static String workspaceSettings(int workspaceId) =>
      '/more/workspaces/$workspaceId/settings';

  static String workspaceInvitations() => '/more/workspaces/invitations';

  // Project routes (anidados bajo More/Workspaces)
  static String projects(int workspaceId) =>
      '/more/workspaces/$workspaceId/projects';

  static String projectDetail(int workspaceId, int projectId) =>
      '/more/workspaces/$workspaceId/projects/$projectId';

  static String projectCreate(int workspaceId) =>
      '/more/workspaces/$workspaceId/projects/create';

  // Task routes (anidados bajo More/Workspaces/Projects)
  static String taskDetail(int workspaceId, int projectId, int taskId) =>
      '/more/workspaces/$workspaceId/projects/$projectId/tasks/$taskId';

  // Other project views (anidados bajo More/Workspaces/Projects)
  static String gantt(int workspaceId, int projectId) =>
      '/more/workspaces/$workspaceId/projects/$projectId/gantt';

  static String workload(int workspaceId, int projectId) =>
      '/more/workspaces/$workspaceId/projects/$projectId/workload';

  static String resourceMap(int workspaceId, int projectId) =>
      '/more/workspaces/$workspaceId/projects/$projectId/resource-map';

  // Settings and More sub-routes
  static String settings() => '/more/settings';
  static String profile() => '/more/profile';
  static String rolePreferences() => '/more/role-preferences';
  static String customizationMetrics() => '/more/customization-metrics';
}

/// Extension methods para facilitar navegación desde cualquier BuildContext
extension RouteNavigationExtension on BuildContext {
  // Auth navigation
  void goToLogin() => go(RouteBuilder.login());
  void goToRegister() => go(RouteBuilder.register());

  // Onboarding navigation
  void goToOnboarding() => go(RouteBuilder.onboarding());

  // Dashboard navigation
  void goToDashboard() => go(RouteBuilder.dashboard());

  // Bottom Navigation
  void goToAllProjects() => go(RouteBuilder.allProjects());
  void goToAllTasks() => go(RouteBuilder.allTasks());
  void goToMore() => go(RouteBuilder.more());

  // Workspace navigation
  void goToWorkspaces() => go(RouteBuilder.workspaces());
  void goToWorkspace(int workspaceId) =>
      go(RouteBuilder.workspaceDetail(workspaceId));
  void goToWorkspaceCreate() => go(RouteBuilder.workspaceCreate());
  void goToWorkspaceMembers(int workspaceId) =>
      go(RouteBuilder.workspaceMembers(workspaceId));
  void goToWorkspaceSettings(int workspaceId) =>
      go(RouteBuilder.workspaceSettings(workspaceId));
  void goToInvitations() => go(RouteBuilder.workspaceInvitations());

  // Project navigation
  void goToProjects(int workspaceId) => go(RouteBuilder.projects(workspaceId));
  void goToProject(int workspaceId, int projectId) =>
      go(RouteBuilder.projectDetail(workspaceId, projectId));

  // Task navigation
  void goToTask(int workspaceId, int projectId, int taskId) =>
      go(RouteBuilder.taskDetail(workspaceId, projectId, taskId));

  // Project views navigation
  void goToGantt(int workspaceId, int projectId) =>
      go(RouteBuilder.gantt(workspaceId, projectId));
  void goToWorkload(int workspaceId, int projectId) =>
      go(RouteBuilder.workload(workspaceId, projectId));
  void goToResourceMap(int workspaceId, int projectId) =>
      go(RouteBuilder.resourceMap(workspaceId, projectId));

  // Settings and More navigation
  void goToSettings() => go(RouteBuilder.settings());
  void goToProfile() => go(RouteBuilder.profile());
  void goToRolePreferences() => go(RouteBuilder.rolePreferences());
  void goToCustomizationMetrics() => go(RouteBuilder.customizationMetrics());

  // Push variants (para mantener en el stack)
  void pushToProject(int workspaceId, int projectId) =>
      push(RouteBuilder.projectDetail(workspaceId, projectId));
  void pushToTask(int workspaceId, int projectId, int taskId) =>
      push(RouteBuilder.taskDetail(workspaceId, projectId, taskId));
}
