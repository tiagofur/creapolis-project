/// Hero animation tags para transiciones entre pantallas
///
/// Centraliza todos los tags para evitar colisiones y facilitar mantenimiento
class HeroTags {
  HeroTags._();

  // Workspace
  static String workspace(int workspaceId) => 'workspace_$workspaceId';
  static String workspaceIcon(int workspaceId) => 'workspace_icon_$workspaceId';
  static String workspaceTitle(int workspaceId) =>
      'workspace_title_$workspaceId';

  // Project
  static String project(int projectId) => 'project_$projectId';
  static String projectIcon(int projectId) => 'project_icon_$projectId';
  static String projectTitle(int projectId) => 'project_title_$projectId';

  // Task
  static String task(int taskId) => 'task_$taskId';
  static String taskIcon(int taskId) => 'task_icon_$taskId';
  static String taskTitle(int taskId) => 'task_title_$taskId';

  // Member
  static String memberAvatar(int userId) => 'member_avatar_$userId';
  static String memberName(int userId) => 'member_name_$userId';

  // User Profile
  static const String userAvatar = 'user_avatar';
  static const String userName = 'user_name';
}
