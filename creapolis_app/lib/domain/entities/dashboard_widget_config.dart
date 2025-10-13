import 'package:equatable/equatable.dart';

/// Tipos de widgets disponibles para el dashboard
enum DashboardWidgetType {
  quickStats,
  myTasks,
  myProjects,
  recentActivity,
  quickActions,
  workspaceInfo,
}

/// Extensión para obtener metadata de los widgets
extension DashboardWidgetTypeExtension on DashboardWidgetType {
  /// Nombre legible del widget
  String get displayName {
    switch (this) {
      case DashboardWidgetType.quickStats:
        return 'Resumen del Día';
      case DashboardWidgetType.myTasks:
        return 'Mis Tareas';
      case DashboardWidgetType.myProjects:
        return 'Mis Proyectos';
      case DashboardWidgetType.recentActivity:
        return 'Actividad Reciente';
      case DashboardWidgetType.quickActions:
        return 'Acciones Rápidas';
      case DashboardWidgetType.workspaceInfo:
        return 'Info del Workspace';
    }
  }

  /// Descripción del widget
  String get description {
    switch (this) {
      case DashboardWidgetType.quickStats:
        return 'Resumen de tareas y proyectos del día';
      case DashboardWidgetType.myTasks:
        return 'Lista de tus tareas activas';
      case DashboardWidgetType.myProjects:
        return 'Lista de proyectos recientes';
      case DashboardWidgetType.recentActivity:
        return 'Actividad reciente en tus proyectos';
      case DashboardWidgetType.quickActions:
        return 'Acceso rápido a acciones comunes';
      case DashboardWidgetType.workspaceInfo:
        return 'Información del workspace activo';
    }
  }

  /// Icono representativo del widget
  String get iconName {
    switch (this) {
      case DashboardWidgetType.quickStats:
        return 'insights';
      case DashboardWidgetType.myTasks:
        return 'task_alt';
      case DashboardWidgetType.myProjects:
        return 'folder';
      case DashboardWidgetType.recentActivity:
        return 'history';
      case DashboardWidgetType.quickActions:
        return 'grid_view';
      case DashboardWidgetType.workspaceInfo:
        return 'business';
    }
  }
}

/// Entidad que representa la configuración de un widget individual
class DashboardWidgetConfig extends Equatable {
  final String id;
  final DashboardWidgetType type;
  final int position;
  final bool isVisible;

  const DashboardWidgetConfig({
    required this.id,
    required this.type,
    required this.position,
    this.isVisible = true,
  });

  /// Constructor por defecto para cada tipo de widget
  factory DashboardWidgetConfig.defaultForType(
    DashboardWidgetType type,
    int position,
  ) {
    return DashboardWidgetConfig(
      id: '${type.name}_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      position: position,
      isVisible: true,
    );
  }

  /// Copia con nuevos valores
  DashboardWidgetConfig copyWith({
    String? id,
    DashboardWidgetType? type,
    int? position,
    bool? isVisible,
  }) {
    return DashboardWidgetConfig(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  /// Conversión desde JSON
  factory DashboardWidgetConfig.fromJson(Map<String, dynamic> json) {
    return DashboardWidgetConfig(
      id: json['id'] as String,
      type: DashboardWidgetType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DashboardWidgetType.quickStats,
      ),
      position: json['position'] as int,
      isVisible: json['isVisible'] as bool? ?? true,
    );
  }

  /// Conversión a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'position': position,
      'isVisible': isVisible,
    };
  }

  @override
  List<Object?> get props => [id, type, position, isVisible];
}

/// Configuración completa del dashboard
class DashboardConfig extends Equatable {
  final List<DashboardWidgetConfig> widgets;
  final DateTime lastModified;

  const DashboardConfig({
    required this.widgets,
    required this.lastModified,
  });

  /// Configuración por defecto del dashboard
  factory DashboardConfig.defaultConfig() {
    return DashboardConfig(
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
          DashboardWidgetType.myTasks,
          3,
        ),
        DashboardWidgetConfig.defaultForType(
          DashboardWidgetType.myProjects,
          4,
        ),
        DashboardWidgetConfig.defaultForType(
          DashboardWidgetType.recentActivity,
          5,
        ),
      ],
      lastModified: DateTime.now(),
    );
  }

  /// Obtener widgets visibles ordenados por posición
  List<DashboardWidgetConfig> get visibleWidgets {
    final visible = widgets.where((w) => w.isVisible).toList();
    visible.sort((a, b) => a.position.compareTo(b.position));
    return visible;
  }

  /// Copia con nuevos valores
  DashboardConfig copyWith({
    List<DashboardWidgetConfig>? widgets,
    DateTime? lastModified,
  }) {
    return DashboardConfig(
      widgets: widgets ?? this.widgets,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  /// Conversión desde JSON
  factory DashboardConfig.fromJson(Map<String, dynamic> json) {
    return DashboardConfig(
      widgets: (json['widgets'] as List<dynamic>)
          .map((w) => DashboardWidgetConfig.fromJson(w as Map<String, dynamic>))
          .toList(),
      lastModified: DateTime.parse(json['lastModified'] as String),
    );
  }

  /// Conversión a JSON
  Map<String, dynamic> toJson() {
    return {
      'widgets': widgets.map((w) => w.toJson()).toList(),
      'lastModified': lastModified.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [widgets, lastModified];
}
