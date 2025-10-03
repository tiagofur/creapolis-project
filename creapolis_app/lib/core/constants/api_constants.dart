/// Constantes de configuración de la API
class ApiConstants {
  ApiConstants._();

  // Base URL - Cambiar según el entorno
  static const String baseUrl = 'http://localhost:3000/api';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';

  // Projects Endpoints
  static const String projects = '/projects';
  static String projectById(int id) => '/projects/$id';

  // Tasks Endpoints
  static String projectTasks(int projectId) => '/projects/$projectId/tasks';
  static String taskById(int projectId, int taskId) =>
      '/projects/$projectId/tasks/$taskId';

  // Time Tracking Endpoints
  static String startTask(int taskId) => '/tasks/$taskId/start';
  static String stopTask(int taskId) => '/tasks/$taskId/stop';
  static String finishTask(int taskId) => '/tasks/$taskId/finish';

  // Headers
  static const String contentType = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
}
