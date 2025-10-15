import 'package:equatable/equatable.dart';

/// Estadísticas de uso de un elemento específico
class UsageStats extends Equatable {
  final String item;
  final int count;
  final double percentage;

  const UsageStats({
    required this.item,
    required this.count,
    required this.percentage,
  });

  factory UsageStats.fromJson(Map<String, dynamic> json) {
    return UsageStats(
      item: json['item'] as String,
      count: json['count'] as int,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': item,
      'count': count,
      'percentage': percentage,
    };
  }

  @override
  List<Object?> get props => [item, count, percentage];
}

/// Métricas agregadas de personalización
class CustomizationMetrics extends Equatable {
  final int totalEvents;
  final int totalUsers;
  final DateTime startDate;
  final DateTime endDate;
  final List<UsageStats> themeUsage;
  final List<UsageStats> layoutUsage;
  final List<UsageStats> widgetUsage;
  final Map<String, int> eventTypeCount;
  final DateTime lastUpdated;

  const CustomizationMetrics({
    required this.totalEvents,
    required this.totalUsers,
    required this.startDate,
    required this.endDate,
    required this.themeUsage,
    required this.layoutUsage,
    required this.widgetUsage,
    required this.eventTypeCount,
    required this.lastUpdated,
  });

  /// Métricas vacías
  factory CustomizationMetrics.empty() {
    final now = DateTime.now();
    return CustomizationMetrics(
      totalEvents: 0,
      totalUsers: 0,
      startDate: now,
      endDate: now,
      themeUsage: [],
      layoutUsage: [],
      widgetUsage: [],
      eventTypeCount: {},
      lastUpdated: now,
    );
  }

  factory CustomizationMetrics.fromJson(Map<String, dynamic> json) {
    return CustomizationMetrics(
      totalEvents: json['totalEvents'] as int,
      totalUsers: json['totalUsers'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      themeUsage: (json['themeUsage'] as List<dynamic>)
          .map((e) => UsageStats.fromJson(e as Map<String, dynamic>))
          .toList(),
      layoutUsage: (json['layoutUsage'] as List<dynamic>)
          .map((e) => UsageStats.fromJson(e as Map<String, dynamic>))
          .toList(),
      widgetUsage: (json['widgetUsage'] as List<dynamic>)
          .map((e) => UsageStats.fromJson(e as Map<String, dynamic>))
          .toList(),
      eventTypeCount: Map<String, int>.from(json['eventTypeCount'] as Map),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalEvents': totalEvents,
      'totalUsers': totalUsers,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'themeUsage': themeUsage.map((e) => e.toJson()).toList(),
      'layoutUsage': layoutUsage.map((e) => e.toJson()).toList(),
      'widgetUsage': widgetUsage.map((e) => e.toJson()).toList(),
      'eventTypeCount': eventTypeCount,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        totalEvents,
        totalUsers,
        startDate,
        endDate,
        themeUsage,
        layoutUsage,
        widgetUsage,
        eventTypeCount,
        lastUpdated,
      ];
}



