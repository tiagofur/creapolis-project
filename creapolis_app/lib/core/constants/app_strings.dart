/// Strings de la aplicación
/// TODO: Implementar internacionalización (i18n) en el futuro
class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'Creapolis';
  static const String appTagline = 'Gestión inteligente de proyectos';

  // Auth
  static const String login = 'Iniciar Sesión';
  static const String register = 'Registrarse';
  static const String logout = 'Cerrar Sesión';
  static const String email = 'Correo electrónico';
  static const String password = 'Contraseña';
  static const String name = 'Nombre completo';
  static const String confirmPassword = 'Confirmar contraseña';
  static const String forgotPassword = '¿Olvidaste tu contraseña?';
  static const String dontHaveAccount = '¿No tienes una cuenta?';
  static const String alreadyHaveAccount = '¿Ya tienes una cuenta?';

  // Projects
  static const String projects = 'Proyectos';
  static const String myProjects = 'Mis Proyectos';
  static const String createProject = 'Crear Proyecto';
  static const String projectName = 'Nombre del proyecto';
  static const String projectDescription = 'Descripción';
  static const String editProject = 'Editar Proyecto';
  static const String deleteProject = 'Eliminar Proyecto';

  // Tasks
  static const String tasks = 'Tareas';
  static const String createTask = 'Crear Tarea';
  static const String taskTitle = 'Título de la tarea';
  static const String taskDescription = 'Descripción';
  static const String estimatedHours = 'Horas estimadas';
  static const String actualHours = 'Horas reales';
  static const String assignee = 'Responsable';
  static const String status = 'Estado';

  // Task Status
  static const String planned = 'Planificada';
  static const String inProgress = 'En Progreso';
  static const String completed = 'Completada';

  // Time Tracking
  static const String start = 'Iniciar';
  static const String stop = 'Detener';
  static const String finish = 'Finalizar';

  // Common
  static const String save = 'Guardar';
  static const String cancel = 'Cancelar';
  static const String delete = 'Eliminar';
  static const String edit = 'Editar';
  static const String search = 'Buscar';
  static const String filter = 'Filtrar';
  static const String loading = 'Cargando...';
  static const String error = 'Error';
  static const String success = 'Éxito';
  static const String retry = 'Reintentar';
  static const String noData = 'No hay datos';

  // Validations
  static const String fieldRequired = 'Este campo es requerido';
  static const String invalidEmail = 'Correo electrónico inválido';
  static const String passwordTooShort =
      'La contraseña debe tener al menos 6 caracteres';
  static const String passwordsDontMatch = 'Las contraseñas no coinciden';
}



