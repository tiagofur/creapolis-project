import 'package:equatable/equatable.dart';

/// Entidad que representa un insight de productividad
class ProductivityInsight extends Equatable {
  final String type;
  final String message;
  final String icon;

  const ProductivityInsight({
    required this.type,
    required this.message,
    required this.icon,
  });

  factory ProductivityInsight.fromJson(Map<String, dynamic> json) {
    return ProductivityInsight(
      type: json['type'] as String,
      message: json['message'] as String,
      icon: json['icon'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'message': message,
      'icon': icon,
    };
  }

  @override
  List<Object?> get props => [type, message, icon];
}

/// Entidad que representa un slot productivo
class ProductiveSlot extends Equatable {
  final int day;
  final int hour;
  final double hours;

  const ProductiveSlot({
    required this.day,
    required this.hour,
    required this.hours,
  });

  factory ProductiveSlot.fromJson(Map<String, dynamic> json) {
    return ProductiveSlot(
      day: json['day'] as int,
      hour: json['hour'] as int,
      hours: (json['hours'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'hour': hour,
      'hours': hours,
    };
  }

  @override
  List<Object?> get props => [day, hour, hours];
}

/// Entidad que representa los datos del heatmap de productividad
class ProductivityHeatmap extends Equatable {
  final List<double> hourlyData;
  final List<double> weeklyData;
  final List<List<double>> hourlyWeeklyMatrix;
  final double totalHours;
  final double avgHoursPerDay;
  final int peakHour;
  final int peakDay;
  final List<ProductiveSlot> topProductiveSlots;
  final List<ProductivityInsight> insights;
  final int totalLogs;

  const ProductivityHeatmap({
    required this.hourlyData,
    required this.weeklyData,
    required this.hourlyWeeklyMatrix,
    required this.totalHours,
    required this.avgHoursPerDay,
    required this.peakHour,
    required this.peakDay,
    required this.topProductiveSlots,
    required this.insights,
    required this.totalLogs,
  });

  factory ProductivityHeatmap.fromJson(Map<String, dynamic> json) {
    return ProductivityHeatmap(
      hourlyData: (json['hourlyData'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      weeklyData: (json['weeklyData'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      hourlyWeeklyMatrix: (json['hourlyWeeklyMatrix'] as List<dynamic>)
          .map((row) => (row as List<dynamic>)
              .map((e) => (e as num).toDouble())
              .toList())
          .toList(),
      totalHours: (json['totalHours'] as num).toDouble(),
      avgHoursPerDay: (json['avgHoursPerDay'] as num).toDouble(),
      peakHour: json['peakHour'] as int,
      peakDay: json['peakDay'] as int,
      topProductiveSlots: (json['topProductiveSlots'] as List<dynamic>)
          .map((e) => ProductiveSlot.fromJson(e as Map<String, dynamic>))
          .toList(),
      insights: (json['insights'] as List<dynamic>)
          .map((e) => ProductivityInsight.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalLogs: json['totalLogs'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hourlyData': hourlyData,
      'weeklyData': weeklyData,
      'hourlyWeeklyMatrix': hourlyWeeklyMatrix,
      'totalHours': totalHours,
      'avgHoursPerDay': avgHoursPerDay,
      'peakHour': peakHour,
      'peakDay': peakDay,
      'topProductiveSlots': topProductiveSlots.map((e) => e.toJson()).toList(),
      'insights': insights.map((e) => e.toJson()).toList(),
      'totalLogs': totalLogs,
    };
  }

  @override
  List<Object?> get props => [
        hourlyData,
        weeklyData,
        hourlyWeeklyMatrix,
        totalHours,
        avgHoursPerDay,
        peakHour,
        peakDay,
        topProductiveSlots,
        insights,
        totalLogs,
      ];
}
