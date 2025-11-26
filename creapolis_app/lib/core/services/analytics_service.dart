import 'package:flutter/foundation.dart';
import '../utils/app_logger.dart';

/// Servicio de analytics para rastrear eventos de usuario.
///
/// Actualmente implementa logging local. Puede extenderse para integrar:
/// - Firebase Analytics
/// - Mixpanel
/// - Amplitude
/// - PostHog
/// - Cualquier otro proveedor de analytics
///
/// Uso:
/// ```dart
/// AnalyticsService.trackEvent(
///   AnalyticsEvent.onboardingPageViewed,
///   properties: {'page': 1, 'page_name': 'Welcome'},
/// );
/// ```
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  /// Flag para habilitar/deshabilitar analytics (útil para desarrollo)
  static bool _enabled = true;

  /// Lista de eventos registrados (útil para debugging y tests)
  static final List<AnalyticsEventRecord> _eventHistory = [];

  /// Habilitar o deshabilitar el tracking
  static void setEnabled(bool enabled) {
    _enabled = enabled;
    AppLogger.info(
      'AnalyticsService: Tracking ${enabled ? 'habilitado' : 'deshabilitado'}',
    );
  }

  /// Verificar si el tracking está habilitado
  static bool get isEnabled => _enabled;

  /// Obtener historial de eventos (útil para tests y debugging)
  static List<AnalyticsEventRecord> get eventHistory =>
      List.unmodifiable(_eventHistory);

  /// Limpiar historial de eventos
  static void clearHistory() {
    _eventHistory.clear();
  }

  /// Registrar un evento de analytics
  static void trackEvent(
    AnalyticsEvent event, {
    Map<String, dynamic>? properties,
  }) {
    if (!_enabled) return;

    final record = AnalyticsEventRecord(
      event: event,
      properties: properties ?? {},
      timestamp: DateTime.now(),
    );

    _eventHistory.add(record);

    // Log en desarrollo
    if (kDebugMode) {
      AppLogger.info(
        'Analytics: ${event.name} ${properties != null ? '- $properties' : ''}',
      );
    }

    // TODO: Aquí se integraría con el proveedor de analytics real
    // Por ejemplo:
    // FirebaseAnalytics.instance.logEvent(
    //   name: event.name,
    //   parameters: properties,
    // );
  }

  /// Identificar al usuario (para analytics con identificación)
  static void identifyUser({
    required String userId,
    Map<String, dynamic>? userProperties,
  }) {
    if (!_enabled) return;

    if (kDebugMode) {
      AppLogger.info(
        'Analytics: Identificar usuario $userId ${userProperties != null ? '- $userProperties' : ''}',
      );
    }

    // TODO: Aquí se integraría con el proveedor de analytics real
    // FirebaseAnalytics.instance.setUserId(id: userId);
  }

  /// Resetear identificación de usuario (para logout)
  static void resetUser() {
    if (!_enabled) return;

    if (kDebugMode) {
      AppLogger.info('Analytics: Usuario reseteado');
    }

    // TODO: Aquí se integraría con el proveedor de analytics real
    // FirebaseAnalytics.instance.setUserId(id: null);
  }

  /// Registrar pantalla vista
  static void trackScreen(String screenName, {String? screenClass}) {
    trackEvent(
      AnalyticsEvent.screenViewed,
      properties: {
        'screen_name': screenName,
        if (screenClass != null) 'screen_class': screenClass,
      },
    );
  }

  // ========== MÉTODOS DE CONVENIENCIA PARA ONBOARDING ==========

  /// Registrar inicio del onboarding
  static void trackOnboardingStarted() {
    trackEvent(AnalyticsEvent.onboardingStarted);
  }

  /// Registrar interés en una feature específica mostrada en onboarding
  static void trackFeatureInterest({
    required String featureName,
    required String featureCategory,
    required int pageIndex,
    int? interactionDurationMs,
  }) {
    trackEvent(
      AnalyticsEvent.featureInterest,
      properties: {
        'feature_name': featureName,
        'feature_category': featureCategory,
        'page_index': pageIndex,
        if (interactionDurationMs != null)
          'interaction_duration_ms': interactionDurationMs,
      },
    );
  }

  /// Registrar tiempo de lectura/visualización de una página del onboarding
  static void trackOnboardingPageEngagement({
    required int pageIndex,
    required String pageName,
    required int viewDurationMs,
    required int featuresViewed,
  }) {
    trackEvent(
      AnalyticsEvent.onboardingPageEngagement,
      properties: {
        'page_index': pageIndex,
        'page_name': pageName,
        'view_duration_ms': viewDurationMs,
        'features_viewed': featuresViewed,
        'avg_time_per_feature_ms': featuresViewed > 0
            ? (viewDurationMs / featuresViewed).round()
            : 0,
      },
    );
  }

  /// Obtener resumen de features más interesantes del onboarding
  static Map<String, int> getFeatureInterestSummary() {
    final featureInterests = _eventHistory
        .where((e) => e.event == AnalyticsEvent.featureInterest)
        .toList();

    final summary = <String, int>{};
    for (final record in featureInterests) {
      final featureName = record.properties['feature_name'] as String?;
      if (featureName != null) {
        summary[featureName] = (summary[featureName] ?? 0) + 1;
      }
    }
    return summary;
  }

  /// Obtener engagement promedio por página de onboarding
  static Map<int, double> getOnboardingEngagementByPage() {
    final engagements = _eventHistory
        .where((e) => e.event == AnalyticsEvent.onboardingPageEngagement)
        .toList();

    final summary = <int, List<int>>{};
    for (final record in engagements) {
      final pageIndex = record.properties['page_index'] as int?;
      final duration = record.properties['view_duration_ms'] as int?;
      if (pageIndex != null && duration != null) {
        summary[pageIndex] ??= [];
        summary[pageIndex]!.add(duration);
      }
    }

    return summary.map((page, durations) {
      final avg = durations.reduce((a, b) => a + b) / durations.length;
      return MapEntry(page, avg);
    });
  }

  /// Registrar página de onboarding vista
  static void trackOnboardingPageViewed({
    required int pageIndex,
    required String pageName,
    required int totalPages,
  }) {
    trackEvent(
      AnalyticsEvent.onboardingPageViewed,
      properties: {
        'page_index': pageIndex,
        'page_name': pageName,
        'total_pages': totalPages,
        'progress_percent': ((pageIndex + 1) / totalPages * 100).round(),
      },
    );
  }

  /// Registrar onboarding completado
  static void trackOnboardingCompleted({
    required int totalPagesViewed,
    required Duration timeSpent,
    required bool skipped,
  }) {
    trackEvent(
      AnalyticsEvent.onboardingCompleted,
      properties: {
        'total_pages_viewed': totalPagesViewed,
        'time_spent_seconds': timeSpent.inSeconds,
        'skipped': skipped,
        'completion_rate': skipped ? 0 : 100,
      },
    );
  }

  /// Registrar onboarding saltado
  static void trackOnboardingSkipped({
    required int currentPage,
    required int totalPages,
    required Duration timeSpent,
  }) {
    trackEvent(
      AnalyticsEvent.onboardingSkipped,
      properties: {
        'skipped_at_page': currentPage,
        'total_pages': totalPages,
        'pages_viewed': currentPage + 1,
        'time_spent_seconds': timeSpent.inSeconds,
        'completion_rate': ((currentPage + 1) / totalPages * 100).round(),
      },
    );
  }

  // ========== MÉTODOS DE CONVENIENCIA PARA AUTH ==========

  /// Registrar login exitoso
  static void trackLoginSuccess({String? method}) {
    trackEvent(
      AnalyticsEvent.loginSuccess,
      properties: {if (method != null) 'method': method},
    );
  }

  /// Registrar error de login
  static void trackLoginError({required String error}) {
    trackEvent(AnalyticsEvent.loginError, properties: {'error': error});
  }

  /// Registrar registro exitoso
  static void trackSignupSuccess() {
    trackEvent(AnalyticsEvent.signupSuccess);
  }

  /// Registrar logout
  static void trackLogout() {
    trackEvent(AnalyticsEvent.logout);
    resetUser();
  }

  // ========== MÉTODOS DE CONVENIENCIA PARA WORKSPACE ==========

  /// Registrar creación de workspace
  static void trackWorkspaceCreated({required String workspaceId}) {
    trackEvent(
      AnalyticsEvent.workspaceCreated,
      properties: {'workspace_id': workspaceId},
    );
  }

  // ========== MÉTODOS DE CONVENIENCIA PARA PROYECTOS ==========

  /// Registrar creación de proyecto
  static void trackProjectCreated({
    required String projectId,
    required String workspaceId,
  }) {
    trackEvent(
      AnalyticsEvent.projectCreated,
      properties: {'project_id': projectId, 'workspace_id': workspaceId},
    );
  }

  // ========== MÉTODOS DE CONVENIENCIA PARA TAREAS ==========

  /// Registrar creación de tarea
  static void trackTaskCreated({
    required String taskId,
    required String projectId,
  }) {
    trackEvent(
      AnalyticsEvent.taskCreated,
      properties: {'task_id': taskId, 'project_id': projectId},
    );
  }

  /// Registrar tarea completada
  static void trackTaskCompleted({
    required String taskId,
    required String projectId,
  }) {
    trackEvent(
      AnalyticsEvent.taskCompleted,
      properties: {'task_id': taskId, 'project_id': projectId},
    );
  }
}

/// Eventos de analytics disponibles
enum AnalyticsEvent {
  // General
  screenViewed,
  appOpened,
  appBackgrounded,

  // Onboarding
  onboardingStarted,
  onboardingPageViewed,
  onboardingCompleted,
  onboardingSkipped,
  onboardingPageEngagement,
  featureInterest,

  // Auth
  loginSuccess,
  loginError,
  signupSuccess,
  signupError,
  logout,
  passwordResetRequested,

  // Workspace
  workspaceCreated,
  workspaceDeleted,
  workspaceMemberInvited,
  workspaceMemberRemoved,

  // Project
  projectCreated,
  projectUpdated,
  projectDeleted,
  projectViewed,

  // Task
  taskCreated,
  taskUpdated,
  taskCompleted,
  taskDeleted,
  taskViewed,
  taskAssigned,

  // Search
  searchPerformed,
  searchResultClicked,

  // Settings
  themeChanged,
  languageChanged,
  notificationsToggled,
}

/// Registro de un evento de analytics
class AnalyticsEventRecord {
  final AnalyticsEvent event;
  final Map<String, dynamic> properties;
  final DateTime timestamp;

  const AnalyticsEventRecord({
    required this.event,
    required this.properties,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'AnalyticsEventRecord(event: ${event.name}, properties: $properties, timestamp: $timestamp)';
  }
}
