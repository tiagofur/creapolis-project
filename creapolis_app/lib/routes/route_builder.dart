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

  // Workspace routes
  static String workspaces() => '/workspaces';

  static String workspaceDetail(int workspaceId) => '/workspaces/$workspaceId';

  static String workspaceCreate() => '/workspaces/create';

  static String workspaceMembers(int workspaceId) =>
      '/workspaces/$workspaceId/members';

  static String workspaceSettings(int workspaceId) =>
      '/workspaces/$workspaceId/settings';

  static String workspaceInvitations() => '/workspaces/invitations';

  // Project routes
  static String projects(int workspaceId) =>
      '/workspaces/$workspaceId/projects';

  static String projectDetail(int workspaceId, int projectId) =>
      '/workspaces/$workspaceId/projects/$projectId';

  static String projectCreate(int workspaceId) =>
      '/workspaces/$workspaceId/projects/create';

  // Task routes
  static String taskDetail(int workspaceId, int projectId, int taskId) =>
      '/workspaces/$workspaceId/projects/$projectId/tasks/$taskId';

  // Other project views
  static String gantt(int workspaceId, int projectId) =>
      '/workspaces/$workspaceId/projects/$projectId/gantt';

  static String workload(int workspaceId, int projectId) =>
      '/workspaces/$workspaceId/projects/$projectId/workload';

  // Settings
  static String settings() => '/settings';
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

  // Settings navigation
  void goToSettings() => go(RouteBuilder.settings());

  // Push variants (para mantener en el stack)
  void pushToProject(int workspaceId, int projectId) =>
      push(RouteBuilder.projectDetail(workspaceId, projectId));
  void pushToTask(int workspaceId, int projectId, int taskId) =>
      push(RouteBuilder.taskDetail(workspaceId, projectId, taskId));
}
