// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Creapolis';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get notificationsSubtitle => 'Gestionar notificaciones';

  @override
  String get themeTitle => 'Tema';

  @override
  String get themeSubtitle => 'Modo claro/oscuro';

  @override
  String get helpTitle => 'Ayuda';

  @override
  String get helpSubtitle => 'Centro de ayuda y soporte';

  @override
  String get privacyTitle => 'Privacidad';

  @override
  String get privacySubtitle => 'Política de privacidad';

  @override
  String get privacyContent => 'Gestionamos tus datos conforme a las mejores prácticas.\n- Uso de datos limitado a funcionalidades.\n- Sin compartir con terceros sin consentimiento.\n- Puedes gestionar tus preferencias en Ajustes.\n\nPara más detalle, consulta el sitio oficial.';

  @override
  String get close => 'Cerrar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get workspaceActive => 'Workspace Activo';

  @override
  String get workspaceRequiredTitle => 'Workspace requerido';

  @override
  String get workspaceRequiredMessage => 'Para crear tareas, primero debes seleccionar o crear un workspace.';

  @override
  String get createWorkspace => 'Crear Workspace';

  @override
  String get selectProject => 'Selecciona un proyecto';

  @override
  String get addWidgetCreateProject => 'Añadir Widget / Crear Proyecto';

  @override
  String get updatingProjectsSnack => 'Actualizando lista de proyectos...';

  @override
  String get newTaskTooltip => 'Nueva tarea';

  @override
  String get open => 'Abrir';

  @override
  String taskCreatedSnack(Object title) {
    return 'Tarea \"$title\" creada';
  }

  @override
  String get viewMore => 'Ver más';

  @override
  String percentageCompleted(Object percent) {
    return '$percent% completado';
  }

  @override
  String get moreTitle => 'Más opciones';

  @override
  String get managementSection => 'Gestión';

  @override
  String get infoSection => 'Información';

  @override
  String get workspacesTitle => 'Workspaces';

  @override
  String get workspacesSubtitle => 'Gestionar workspaces';

  @override
  String get invitationsTitle => 'Invitaciones';

  @override
  String get invitationsSubtitle => 'Ver invitaciones pendientes';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSubtitle => 'Configuración de la aplicación';

  @override
  String get customizationMetricsTitle => 'Métricas de Personalización';

  @override
  String get customizationMetricsSubtitle => 'Estadísticas de uso de UI';

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String get aboutSubtitle => 'Información de la aplicación';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get helpContent => 'Visita nuestro centro de ayuda para guías y soporte. Próximamente integraremos enlaces directos desde la app.';

  @override
  String get recentActivityTitle => 'Actividad Reciente';

  @override
  String get viewAll => 'Ver todo';

  @override
  String get noRecentActivity => 'No hay actividad reciente';

  @override
  String get activityCompleted => 'Tarea completada';

  @override
  String get activityUpdated => 'Tarea actualizada';

  @override
  String minutesAgo(Object count) {
    return 'Hace $count minutos';
  }

  @override
  String hoursAgo(Object count) {
    return 'Hace $count horas';
  }

  @override
  String daysAgo(Object count) {
    return 'Hace $count días';
  }

  @override
  String get myTasksTitle => 'Mis Tareas';

  @override
  String get allClear => '¡Todo al día!';

  @override
  String get myProjectsTitle => 'Mis Proyectos';

  @override
  String get progressLabel => 'Progreso';

  @override
  String get dailySummaryTitle => 'Resumen del Día';

  @override
  String get tasksLabel => 'Tareas';

  @override
  String get projectsLabel => 'Proyectos';

  @override
  String get completedLabel => 'Completadas';

  @override
  String get overallProgress => 'Progreso General';

  @override
  String get upcomingTasksTitle => 'Próximas Tareas';

  @override
  String get noPendingTasks => '¡No hay tareas pendientes! 🎉';

  @override
  String get tasksTitle => 'Tareas';

  @override
  String get myTasksTab => 'Mis Tareas';

  @override
  String get allTasksTab => 'Todas';

  @override
  String get createTaskTooltip => 'Crear tarea';

  @override
  String get searchTasksTooltip => 'Buscar tareas';

  @override
  String get filtersTooltip => 'Filtros';

  @override
  String get sortTooltip => 'Ordenar';

  @override
  String get sortByDate => 'Por fecha';

  @override
  String get sortByPriority => 'Por prioridad';

  @override
  String get sortByName => 'Por nombre';

  @override
  String get selectWorkspaceTitle => 'Selecciona un workspace';

  @override
  String get selectWorkspaceMessage => 'Elige un workspace desde el selector superior para ver las tareas disponibles.';

  @override
  String get retry => 'Reintentar';

  @override
  String get loadTasksErrorTitle => 'No se pudieron cargar las tareas';

  @override
  String get loginRequiredTitle => 'Inicia sesión para ver tus tareas';

  @override
  String get loginRequiredMessage => 'Necesitas iniciar sesión para ver las tareas asignadas a ti.';

  @override
  String get goToLogin => 'Ir al login';

  @override
  String get today => 'Hoy';

  @override
  String get thisWeek => 'Esta Semana';

  @override
  String get upcoming => 'Próximas';

  @override
  String get noDateGroup => 'Vencidas o sin fecha';

  @override
  String get all => 'Todas';

  @override
  String get inProgress => 'En progreso';

  @override
  String get planned => 'Planificadas';

  @override
  String get completed => 'Completadas';

  @override
  String get priorityCritical => 'Crítica';

  @override
  String get priorityHigh => 'Alta';

  @override
  String get priorityMedium => 'Media';

  @override
  String get priorityLow => 'Baja';

  @override
  String get priorityLabel => 'Prioridad';

  @override
  String get search => 'Buscar';

  @override
  String get apply => 'Aplicar';

  @override
  String get clear => 'Limpiar';

  @override
  String get noResultsTitle => 'Sin resultados';

  @override
  String get noResultsMessage => 'No encontramos tareas con los filtros actuales.';

  @override
  String get clearFilters => 'Limpiar filtros';

  @override
  String get noAssignedTasksTitle => 'Sin tareas asignadas';

  @override
  String get noAssignedTasksMessage => 'No tienes tareas asignadas en este workspace.';

  @override
  String get createTask => 'Crear tarea';

  @override
  String get confirmCompleteTitle => 'Completar Tarea';

  @override
  String confirmCompleteMessage(Object title) {
    return '¿Marcar \"$title\" como completada?';
  }

  @override
  String get confirmDeleteTitle => 'Eliminar Tarea';

  @override
  String confirmDeleteMessage(Object title) {
    return '¿Eliminar \"$title\"?\n\nEsta acción no se puede deshacer.';
  }

  @override
  String get complete => 'Completar';

  @override
  String get delete => 'Eliminar';

  @override
  String get tasksUpdatedSnack => 'Tareas actualizadas';

  @override
  String get tasksUpdateFailedSnack => 'No pudimos actualizar las tareas. Intenta de nuevo.';

  @override
  String get taskAlreadyCompleted => 'La tarea ya está completada';

  @override
  String get noPermissionsCreateTasks => 'No tienes permisos para crear tareas en este workspace.';

  @override
  String get updatingWorkspaceTasks => 'Estamos actualizando las tareas del workspace. Intenta de nuevo en unos segundos.';

  @override
  String get mustSelectWorkspaceMessage => 'Debes seleccionar un workspace activo antes de crear tareas.';

  @override
  String get viewWorkspaces => 'Ver workspaces';

  @override
  String get needProjectTitle => 'Necesitas un proyecto';

  @override
  String get needProjectMessage => 'Crea un proyecto primero para poder registrar tareas en este workspace.';

  @override
  String get goToProjects => 'Ir a proyectos';

  @override
  String get quickActionsTitle => 'Acciones Rápidas';

  @override
  String get createProject => 'Crear proyecto';

  @override
  String get inviteMember => 'Invitar Miembro';

  @override
  String get loadDataError => 'Error al cargar datos';

  @override
  String get noTasksToShow => 'No hay tareas para mostrar';

  @override
  String get noDataWithFilters => 'No hay datos con los filtros aplicados';

  @override
  String get priorityDistributionTitle => 'Distribución por Prioridad';

  @override
  String get weeklyProgressTitle => 'Progreso Semanal';

  @override
  String get tasksCompletedPerDay => 'Tareas completadas por día';

  @override
  String tasksCount(Object count) {
    return '$count tareas';
  }

  @override
  String get taskMetricsTitle => 'Métricas de Tareas';

  @override
  String get filteredLabel => 'Filtrado';

  @override
  String get loadMetricsError => 'Error al cargar métricas';

  @override
  String completedOfTotalTasks(Object completed, Object total) {
    return '$completed de $total tareas';
  }

  @override
  String tasksDelayedCount(Object count) {
    return '$count retrasadas';
  }

  @override
  String get notificationPreferencesTitle => 'Preferencias de Notificación';

  @override
  String get notificationChannels => 'Canales de Notificación';

  @override
  String get pushNotificationsTitle => 'Notificaciones Push';

  @override
  String get pushNotificationsSubtitle => 'Recibir notificaciones en tiempo real en este dispositivo';

  @override
  String get emailNotificationsTitle => 'Notificaciones por Email';

  @override
  String get emailNotificationsSubtitle => 'Recibir resúmenes y alertas por correo electrónico';

  @override
  String get notificationTypes => 'Tipos de Notificación';

  @override
  String get notificationTypesSubtitle => 'Selecciona qué eventos quieres recibir notificaciones';

  @override
  String get mentionNotifications => 'Menciones';

  @override
  String get mentionNotificationsSubtitle => 'Cuando alguien te menciona en un comentario';

  @override
  String get commentReplyNotifications => 'Respuestas a Comentarios';

  @override
  String get commentReplyNotificationsSubtitle => 'Cuando alguien responde a tu comentario';

  @override
  String get taskAssignedNotifications => 'Tareas Asignadas';

  @override
  String get taskAssignedNotificationsSubtitle => 'Cuando te asignan una nueva tarea';

  @override
  String get taskUpdatedNotifications => 'Actualizaciones de Tareas';

  @override
  String get taskUpdatedNotificationsSubtitle => 'Cuando se actualiza una tarea que sigues';

  @override
  String get projectUpdatedNotifications => 'Actualizaciones de Proyectos';

  @override
  String get projectUpdatedNotificationsSubtitle => 'Cuando se actualiza un proyecto';

  @override
  String get systemNotifications => 'Notificaciones del Sistema';

  @override
  String get systemNotificationsSubtitle => 'Actualizaciones y anuncios importantes';

  @override
  String get preferencesUpdated => 'Preferencias actualizadas';

  @override
  String preferencesLoadError(Object error) {
    return 'Error al cargar preferencias: $error';
  }

  @override
  String preferencesUpdateError(Object error) {
    return 'Error al actualizar preferencias: $error';
  }

  @override
  String get pushPermissionsHint => 'Las notificaciones push requieren permisos del sistema. Si no recibes notificaciones, verifica la configuración de tu dispositivo.';

  @override
  String get selectTimezoneTitle => 'Selecciona zona horaria';

  @override
  String get timeTrackingTitle => 'Time Tracking';

  @override
  String get workSessionsTitle => 'Sesiones de Trabajo';

  @override
  String get noPermissionsTrackTime => 'No tienes permisos para registrar tiempo en este workspace';

  @override
  String get startLabel => 'Iniciar';

  @override
  String get stopLabel => 'Detener';

  @override
  String get finishLabel => 'Finalizar';

  @override
  String get hoursProgressLabel => 'Progreso de Horas';

  @override
  String get overtimeHoursLabel => 'Horas excedidas';

  @override
  String get finishTaskTitle => 'Finalizar Tarea';

  @override
  String get finishTaskMessage => '¿Estás seguro de que deseas finalizar esta tarea? Esto detendrá cualquier timer activo y marcará la tarea como completada.';

  @override
  String get taskFinishedSuccessSnack => '¡Tarea finalizada exitosamente!';

  @override
  String get taskDetailTitle => 'Detalle de Tarea';

  @override
  String get overviewTab => 'Overview';

  @override
  String get timeTrackingTab => 'Time Tracking';

  @override
  String get dependenciesTab => 'Dependencies';

  @override
  String get loadTaskErrorTitle => 'Error al cargar tarea';

  @override
  String get dependenciesTitle => 'Dependencias';

  @override
  String dependenciesCount(Object count) {
    return '$count dependencias';
  }

  @override
  String taskNumber(Object id) {
    return 'Tarea #$id';
  }

  @override
  String get noDependencies => 'No hay dependencias';

  @override
  String get descriptionTitle => 'Descripción';

  @override
  String get datesAndDurationTitle => 'Fechas y Duración';

  @override
  String get startDateLabel => 'Inicio';

  @override
  String get endDateLabel => 'Fin';

  @override
  String get durationLabel => 'Duración';

  @override
  String durationInDays(Object count) {
    return '$count días';
  }

  @override
  String get assignedToLabel => 'Asignado a';

  @override
  String get pendingInvitationsTitle => 'Invitaciones Pendientes';

  @override
  String get refresh => 'Refrescar';

  @override
  String joinedWorkspaceSnack(Object workspace) {
    return 'Te has unido a \"$workspace\"';
  }

  @override
  String get invitationDeclinedSnack => 'Invitación rechazada';

  @override
  String get noPendingInvitationsTitle => 'No tienes invitaciones pendientes';

  @override
  String get noPendingInvitationsMessage => 'Cuando alguien te invite a un workspace\naparecerá aquí';

  @override
  String get invitedByLabel => 'Invitado por';

  @override
  String invitedAt(Object value) {
    return 'Invitado $value';
  }

  @override
  String get invitationExpired => 'Expirada';

  @override
  String expiresAt(Object value) {
    return 'Expira $value';
  }

  @override
  String get reject => 'Rechazar';

  @override
  String get accept => 'Aceptar';

  @override
  String get invitationExpiredMessage => 'Esta invitación ha expirado';

  @override
  String get acceptInvitationTitle => 'Aceptar Invitación';

  @override
  String acceptInvitationMessage(Object role, Object workspace) {
    return '¿Deseas unirte a \"$workspace\" como $role?';
  }

  @override
  String get declineInvitationTitle => 'Rechazar Invitación';

  @override
  String declineInvitationMessage(Object workspace) {
    return '¿Estás seguro de que deseas rechazar la invitación de \"$workspace\"?';
  }

  @override
  String get declineInvitationNote => 'El administrador puede enviarte una nueva invitación en el futuro.';

  @override
  String get confirmDeclineLabel => 'Sí, Rechazar';

  @override
  String get tomorrow => 'mañana';

  @override
  String get yesterday => 'ayer';

  @override
  String inHours(Object count, Object unit) {
    return 'en $count $unit';
  }

  @override
  String inMinutes(Object count, Object unit) {
    return 'en $count $unit';
  }

  @override
  String inDays(Object count, Object unit) {
    return 'en $count $unit';
  }

  @override
  String get workspaceMembersTitle => 'Miembros del Workspace';

  @override
  String get closeSearch => 'Cerrar búsqueda';

  @override
  String get filterByRole => 'Filtrar por rol';

  @override
  String get ownersRoleLabel => 'Propietarios';

  @override
  String get adminsRoleLabel => 'Administradores';

  @override
  String get membersRoleLabel => 'Miembros';

  @override
  String get guestsRoleLabel => 'Invitados';

  @override
  String memberRoleUpdated(Object role, Object user) {
    return 'Rol de $user actualizado a $role';
  }

  @override
  String get memberRemovedSnack => 'Miembro removido del workspace';

  @override
  String get youChip => 'Tú';

  @override
  String get activeChip => 'Activo';

  @override
  String get changeRoleAction => 'Cambiar Rol';

  @override
  String get removeAction => 'Remover';

  @override
  String get noMembersWithRole => 'No hay miembros con ese rol';

  @override
  String get noMembersInWorkspace => 'No hay miembros en este workspace';

  @override
  String get tryAnotherFilter => 'Prueba con otro filtro';

  @override
  String get invitePeopleToCollaborate => 'Invita a personas para colaborar';

  @override
  String changeRoleTitle(Object name) {
    return 'Cambiar rol de $name';
  }

  @override
  String get removeMemberTitle => 'Remover Miembro';

  @override
  String removeMemberConfirm(Object name) {
    return '¿Estás seguro de que deseas remover a $name del workspace?';
  }

  @override
  String get removeMemberNote => 'El usuario perderá acceso a todos los proyectos y tareas de este workspace.';

  @override
  String get removeMemberInviteAgainNote => 'Podrás invitarlo nuevamente en el futuro.';

  @override
  String get confirmRemoveLabel => 'Sí, Remover';

  @override
  String get searchMembersHint => 'Buscar miembros...';

  @override
  String invitationSentTo(Object email) {
    return 'Invitación enviada a $email';
  }

  @override
  String membersCount(Object count) {
    return '$count miembros';
  }

  @override
  String get inviteeEmailLabel => 'Email del invitado';

  @override
  String get inviteeEmailHint => 'ejemplo@correo.com';

  @override
  String get enterEmailMessage => 'Por favor ingresa un email';

  @override
  String get enterValidEmailMessage => 'Por favor ingresa un email válido';

  @override
  String get workspaceRoleLabel => 'Rol en el workspace';

  @override
  String get rolePermissionsTitle => 'Permisos por rol';

  @override
  String get adminRoleDesc => 'Gestión completa excepto eliminar workspace';

  @override
  String get memberRoleDesc => 'Crear y gestionar proyectos y tareas';

  @override
  String get guestRoleDesc => 'Solo visualización de contenido';

  @override
  String get sendInvitation => 'Enviar Invitación';

  @override
  String get adminRoleCapability => 'Puede gestionar miembros y configuración';

  @override
  String get memberRoleCapability => 'Puede crear y gestionar proyectos';

  @override
  String get guestRoleCapability => 'Solo puede visualizar contenido';

  @override
  String get ownerRoleCapability => 'Control total del workspace';

  @override
  String get emailRequired => 'El correo es obligatorio';

  @override
  String get emailInvalid => 'Ingresa un correo válido';

  @override
  String get roleLabel => 'Rol';

  @override
  String loadRolePrefsError(Object error) {
    return 'Error al cargar preferencias: $error';
  }

  @override
  String get resetConfigTitle => 'Resetear Configuración';

  @override
  String get resetConfigMessage => '¿Deseas resetear toda tu configuración a los valores por defecto de tu rol?\n\nEsto eliminará todas tus personalizaciones.';

  @override
  String get reset => 'Resetear';

  @override
  String get resetConfigSuccess => 'Configuración reseteada correctamente';

  @override
  String get resetConfigError => 'Error al resetear configuración';

  @override
  String get exportSuccessTitle => 'Exportación Exitosa';

  @override
  String get exportSuccessMessage => 'Tus preferencias han sido exportadas correctamente.';

  @override
  String get share => 'Compartir';

  @override
  String get shareSubject => 'Mis preferencias de Creapolis';

  @override
  String get shareText => 'Archivo de preferencias exportado desde Creapolis';

  @override
  String exportPrefsError(Object error) {
    return 'Error al exportar preferencias: $error';
  }

  @override
  String get importPrefsTitle => 'Importar Preferencias';

  @override
  String get importPrefsMessage => 'Importar preferencias reemplazará tu configuración actual.\n\n¿Deseas continuar?';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get selectPrefsFileTitle => 'Seleccionar archivo de preferencias';

  @override
  String get filePathError => 'No se pudo obtener la ruta del archivo';

  @override
  String get importPrefsSuccess => 'Preferencias importadas correctamente';

  @override
  String get importPrefsError => 'Error al importar preferencias - Verifica el archivo';

  @override
  String importPrefsErrorDetail(Object error) {
    return 'Error al importar preferencias: $error';
  }

  @override
  String get rolePreferencesTitle => 'Preferencias por Rol';

  @override
  String get moreOptions => 'Más opciones';

  @override
  String get resetToDefaults => 'Resetear a defaults';

  @override
  String get exportPreferences => 'Exportar preferencias';

  @override
  String get importPreferences => 'Importar preferencias';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String currentThemeLabel(Object theme) {
    return 'Tema actual: $theme';
  }

  @override
  String usingCustomizationDefault(Object defaultTheme) {
    return 'Estás usando tu personalización (default: $defaultTheme)';
  }

  @override
  String get usingRoleDefault => 'Usando el default de tu rol';

  @override
  String get revertToRoleDefault => 'Volver a default del rol';

  @override
  String get customizeTheme => 'Personalizar tema';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String widgetsConfigured(Object count) {
    return '$count widgets configurados';
  }

  @override
  String get usingCustomization => 'Estás usando tu personalización';

  @override
  String get usingRoleDashboardDefault => 'Usando el dashboard por defecto de tu rol';

  @override
  String get customizeDashboard => 'Personalizar dashboard';

  @override
  String get exportImportTitle => 'Exportar / Importar';

  @override
  String get exportImportDescription => 'Guarda o restaura tu configuración completa. Útil para respaldar preferencias o transferirlas entre dispositivos.';

  @override
  String get export => 'Exportar';

  @override
  String get import => 'Importar';

  @override
  String get howItWorksTitle => '¿Cómo funciona?';

  @override
  String get howItWorksStep1Title => '1. Configuración Base';

  @override
  String get howItWorksStep1Desc => 'Cada rol tiene una configuración por defecto optimizada.';

  @override
  String get howItWorksStep2Title => '2. Personalización';

  @override
  String get howItWorksStep2Desc => 'Puedes cambiar cualquier configuración según tus preferencias.';

  @override
  String get howItWorksStep3Title => '3. Indicadores';

  @override
  String get howItWorksStep3Desc => 'Los elementos \"Personalizado\" muestran qué has modificado.';

  @override
  String get howItWorksStep4Title => '4. Resetear';

  @override
  String get howItWorksStep4Desc => 'Usa el botón de resetear para volver a los defaults del rol.';

  @override
  String get howItWorksStep5Title => '5. Exportar/Importar';

  @override
  String get howItWorksStep5Desc => 'Respalda tu configuración o transfiérela entre dispositivos.';

  @override
  String get applicationLegalese => '© 2025 Creapolis. Todos los derechos reservados.';

  @override
  String get aboutContent => 'Creapolis es una herramienta de gestión de proyectos y tareas diseñada para ayudar a equipos a colaborar de manera efectiva.';

  @override
  String get confirmLogoutMessage => '¿Estás seguro de que deseas cerrar sesión?';

  @override
  String get roleCustomizationTitle => 'Personalización por Rol';

  @override
  String get roleCustomizationSubtitle => 'Personaliza tu experiencia según tu rol';

  @override
  String get appearanceTitle => 'Apariencia';

  @override
  String get navigationTypeTitle => 'Tipo de navegación';

  @override
  String get navigationTypeDescription => 'Selecciona cómo prefieres navegar por la aplicación';

  @override
  String get sidebarTitle => 'Barra lateral';

  @override
  String get sidebarSubtitle => 'Menú de navegación en el lateral';

  @override
  String get bottomNavigationTitle => 'Navegación inferior';

  @override
  String get bottomNavigationSubtitle => 'Menú de navegación en la parte inferior';

  @override
  String get integrationsTitle => 'Integraciones';

  @override
  String get googleCalendarTitle => 'Google Calendar';

  @override
  String get googleCalendarSubtitle => 'Sincroniza tus eventos y disponibilidad';

  @override
  String get connected => 'Conectado';

  @override
  String get disconnected => 'Desconectado';

  @override
  String get disconnect => 'Desconectar';

  @override
  String get connectGoogleCalendar => 'Conectar Google Calendar';

  @override
  String connectedOn(Object date) {
    return 'Conectado el $date';
  }

  @override
  String get cannotOpenBrowser => 'No se pudo abrir el navegador';

  @override
  String get googleCalendarAuthTitle => 'Autorización de Google Calendar';

  @override
  String get googleCalendarAuthInstructions => 'Se ha abierto tu navegador. Por favor autoriza la aplicación y copia el código de autorización aquí:';

  @override
  String get authorizationCodeLabel => 'Código de autorización';

  @override
  String get authorizationCodeHint => 'Pega el código aquí';

  @override
  String get connect => 'Conectar';

  @override
  String get disconnectGoogleCalendarTitle => 'Desconectar Google Calendar';

  @override
  String get notificationsComingSoon => 'Configuración de notificaciones próximamente';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileComingSoon => 'Configuración de perfil próximamente';

  @override
  String get aboutComingSoon => 'Información de la app próximamente';

  @override
  String get googleCalendarConnected => 'Google Calendar conectado exitosamente';

  @override
  String get googleCalendarDisconnected => 'Google Calendar desconectado';

  @override
  String get profileUserTitle => 'Perfil de usuario';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get selectLanguageTitle => 'Selecciona idioma';

  @override
  String get systemLanguageLabel => 'Predeterminado del sistema';

  @override
  String get spanishLabel => 'Español';

  @override
  String get englishLabel => 'English';
}
