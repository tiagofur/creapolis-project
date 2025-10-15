import 'package:equatable/equatable.dart';

/// Tipo de evento de personalización
enum CustomizationEventType {
  themeChanged,
  layoutChanged,
  widgetAdded,
  widgetRemoved,
  widgetReordered,
  dashboardReset,
  preferencesExported,
  preferencesImported,
}

/// Extensión para obtener metadata de los tipos de evento
extension CustomizationEventTypeExtension on CustomizationEventType {
  /// Nombre legible del evento
  String get displayName {
    switch (this) {
      case CustomizationEventType.themeChanged:
        return 'Cambio de Tema';
      case CustomizationEventType.layoutChanged:
        return 'Cambio de Layout';
      case CustomizationEventType.widgetAdded:
        return 'Widget Añadido';
      case CustomizationEventType.widgetRemoved:
        return 'Widget Eliminado';
      case CustomizationEventType.widgetReordered:
        return 'Widgets Reordenados';
      case CustomizationEventType.dashboardReset:
        return 'Dashboard Reseteado';
      case CustomizationEventType.preferencesExported:
        return 'Preferencias Exportadas';
      case CustomizationEventType.preferencesImported:
        return 'Preferencias Importadas';
    }
  }
}

/// Evento de personalización de UI
///
/// Representa un cambio individual en la configuración de UI del usuario.
/// Los datos se anonimizan para proteger la privacidad.
class CustomizationEvent extends Equatable {
  final String id;
  final CustomizationEventType type;
  final DateTime timestamp;
  final String? previousValue;
  final String? newValue;
  final Map<String, dynamic>? metadata;

  const CustomizationEvent({
    required this.id,
    required this.type,
    required this.timestamp,
    this.previousValue,
    this.newValue,
    this.metadata,
  });

  /// Constructor con datos anonimizados
  factory CustomizationEvent.anonymized({
    required CustomizationEventType type,
    String? previousValue,
    String? newValue,
    Map<String, dynamic>? metadata,
  }) {
    return CustomizationEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      timestamp: DateTime.now(),
      previousValue: previousValue,
      newValue: newValue,
      metadata: metadata,
    );
  }

  /// Conversión desde JSON
  factory CustomizationEvent.fromJson(Map<String, dynamic> json) {
    return CustomizationEvent(
      id: json['id'] as String,
      type: CustomizationEventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CustomizationEventType.themeChanged,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      previousValue: json['previousValue'] as String?,
      newValue: json['newValue'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Conversión a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      if (previousValue != null) 'previousValue': previousValue,
      if (newValue != null) 'newValue': newValue,
      if (metadata != null) 'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
        id,
        type,
        timestamp,
        previousValue,
        newValue,
        metadata,
      ];
}



