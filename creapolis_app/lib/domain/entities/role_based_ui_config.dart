import 'package:equatable/equatable.dart';

import 'dashboard_widget_config.dart';
import 'user.dart';

/// Configuración base de UI para un rol específico
class RoleBasedUIConfig extends Equatable {
  final UserRole role;
  final String themeModeDefault; // 'light', 'dark', 'system'
  final String layoutTypeDefault; // 'sidebar', 'bottomNavigation'
  final DashboardConfig dashboardConfig;

  const RoleBasedUIConfig({
    required this.role,
    required this.themeModeDefault,
    required this.layoutTypeDefault,
    required this.dashboardConfig,
  });

  /// Configuración por defecto para Administrador
  factory RoleBasedUIConfig.adminDefaults() {
    return RoleBasedUIConfig(
      role: UserRole.admin,
      themeModeDefault: 'system',
      layoutTypeDefault: 'bottomNavigation',
      dashboardConfig: DashboardConfig(
        widgets: [
          DashboardWidgetConfig.defaultForType(
            DashboardWidgetType.workspaceInfo,
            0,
          ),
          DashboardWidgetConfig.defaultForType(
            DashboardWidgetType.quickStats,
            1,
          ),
          DashboardWidgetConfig.defaultForType(
            DashboardWidgetType.quickActions,
            2,
          ),
          DashboardWidgetConfig.defaultForType(
            DashboardWidgetType.myProjects,
            3,
          ),
          DashboardWidgetConfig.defaultForType(
            DashboardWidgetType.myTasks,
            4,
          ),
          DashboardWidgetConfig.defaultForType(
            DashboardWidgetType.recentActivity,
            5,
          ),
        ],
        lastModified: DateTime.now(),
      ),
    );
  }

  /// Configuración por defecto para Gestor de Proyecto
  factory RoleBasedUIConfig.projectManagerDefaults() {
    return RoleBasedUIConfig(
      role: UserRole.projectManager,
      themeModeDefault: 'system',
      layoutTypeDefault: 'bottomNavigation',
      dashboardConfig: DashboardConfig(
        widgets: [
          DashboardWidgetConfig.defaultForType(
            DashboardWidgetType.workspaceInfo,
            0,
          ),
          DashboardWidgetConfig.defaultForType(
            DashboardWidgetType.myProjects,
            1,
          ),
          DashboardWidgetConfig.defaultForType(
            DashboardWidgetType.quickStats,
            2,
          ),
          DashboardWidgetConfig.defaultForType(
            DashboardWidgetType.myTasks,
            3,
          ),
          DashboardWidgetConfig.defaultForType(
            DashboardWidgetType.recentActivity,
            4,
          ),
        ],
        lastModified: DateTime.now(),
      ),
    );
  }

  /// Configuración por defecto para Miembro del Equipo
  factory RoleBasedUIConfig.teamMemberDefaults() {
    return RoleBasedUIConfig(
      role: UserRole.teamMember,
      themeModeDefault: 'light',
      layoutTypeDefault: 'bottomNavigation',
      dashboardConfig: DashboardConfig(
        widgets: [
          DashboardWidgetConfig.defaultForType(
            DashboardWidgetType.workspaceInfo,
            0,
          ),
          DashboardWidgetConfig.defaultForType(
            DashboardWidgetType.myTasks,
            1,
          ),
          DashboardWidgetConfig.defaultForType(
            DashboardWidgetType.quickStats,
            2,
          ),
          DashboardWidgetConfig.defaultForType(
            DashboardWidgetType.myProjects,
            3,
          ),
        ],
        lastModified: DateTime.now(),
      ),
    );
  }

  /// Obtiene la configuración por defecto según el rol
  factory RoleBasedUIConfig.forRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return RoleBasedUIConfig.adminDefaults();
      case UserRole.projectManager:
        return RoleBasedUIConfig.projectManagerDefaults();
      case UserRole.teamMember:
        return RoleBasedUIConfig.teamMemberDefaults();
    }
  }

  @override
  List<Object?> get props => [
        role,
        themeModeDefault,
        layoutTypeDefault,
        dashboardConfig,
      ];
}

/// Configuración de usuario con soporte para overrides
class UserUIPreferences extends Equatable {
  final UserRole userRole;
  final String? themeModeOverride; // null = usar default del rol
  final String? layoutTypeOverride; // null = usar default del rol
  final DashboardConfig? dashboardConfigOverride; // null = usar default del rol

  const UserUIPreferences({
    required this.userRole,
    this.themeModeOverride,
    this.layoutTypeOverride,
    this.dashboardConfigOverride,
  });

  /// Obtiene el tema efectivo (override o default del rol)
  String getEffectiveThemeMode() {
    if (themeModeOverride != null) {
      return themeModeOverride!;
    }
    return RoleBasedUIConfig.forRole(userRole).themeModeDefault;
  }

  /// Obtiene el layout efectivo (override o default del rol)
  String getEffectiveLayoutType() {
    if (layoutTypeOverride != null) {
      return layoutTypeOverride!;
    }
    return RoleBasedUIConfig.forRole(userRole).layoutTypeDefault;
  }

  /// Obtiene la configuración de dashboard efectiva (override o default del rol)
  DashboardConfig getEffectiveDashboardConfig() {
    if (dashboardConfigOverride != null) {
      return dashboardConfigOverride!;
    }
    return RoleBasedUIConfig.forRole(userRole).dashboardConfig;
  }

  /// Verifica si el tema está siendo overrideado
  bool get hasThemeOverride => themeModeOverride != null;

  /// Verifica si el layout está siendo overrideado
  bool get hasLayoutOverride => layoutTypeOverride != null;

  /// Verifica si el dashboard está siendo overrideado
  bool get hasDashboardOverride => dashboardConfigOverride != null;

  /// Copia con nuevos valores
  UserUIPreferences copyWith({
    UserRole? userRole,
    String? themeModeOverride,
    String? layoutTypeOverride,
    DashboardConfig? dashboardConfigOverride,
    bool clearThemeOverride = false,
    bool clearLayoutOverride = false,
    bool clearDashboardOverride = false,
  }) {
    return UserUIPreferences(
      userRole: userRole ?? this.userRole,
      themeModeOverride: clearThemeOverride
          ? null
          : (themeModeOverride ?? this.themeModeOverride),
      layoutTypeOverride: clearLayoutOverride
          ? null
          : (layoutTypeOverride ?? this.layoutTypeOverride),
      dashboardConfigOverride: clearDashboardOverride
          ? null
          : (dashboardConfigOverride ?? this.dashboardConfigOverride),
    );
  }

  /// Conversión desde JSON
  factory UserUIPreferences.fromJson(Map<String, dynamic> json) {
    return UserUIPreferences(
      userRole: UserRole.values.firstWhere(
        (e) => e.name == json['userRole'],
        orElse: () => UserRole.teamMember,
      ),
      themeModeOverride: json['themeModeOverride'] as String?,
      layoutTypeOverride: json['layoutTypeOverride'] as String?,
      dashboardConfigOverride: json['dashboardConfigOverride'] != null
          ? DashboardConfig.fromJson(
              json['dashboardConfigOverride'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Conversión a JSON
  Map<String, dynamic> toJson() {
    return {
      'userRole': userRole.name,
      if (themeModeOverride != null) 'themeModeOverride': themeModeOverride,
      if (layoutTypeOverride != null)
        'layoutTypeOverride': layoutTypeOverride,
      if (dashboardConfigOverride != null)
        'dashboardConfigOverride': dashboardConfigOverride!.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        userRole,
        themeModeOverride,
        layoutTypeOverride,
        dashboardConfigOverride,
      ];
}



