/// Claves para almacenamiento local
class StorageKeys {
  StorageKeys._();

  // Auth
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String userRole = 'user_role';

  // App Settings
  static const String themeMode = 'theme_mode';
  static const String colorPalette = 'color_palette';
  static const String layoutType = 'layout_type';
  static const String languageCode = 'language_code';
  static const String isFirstLaunch = 'is_first_launch';
  static const String hasSeenOnboarding = 'has_seen_onboarding';

  // Dashboard Widgets
  static const String dashboardWidgetConfig = 'dashboard_widget_config';

  // Role-Based UI Preferences
  static const String roleBasedUIPreferences = 'role_based_ui_preferences';

  // Customization Metrics
  static const String customizationEvents = 'customization_events';

  // Kanban Board Configuration
  static const String kanbanWipLimit = 'kanban_wip_limit';
  static const String kanbanSwimlanesEnabled = 'kanban_swimlanes_enabled';
  static const String kanbanSwimlanes = 'kanban_swimlanes';
}
