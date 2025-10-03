import '../../domain/entities/time_log.dart';

/// Modelo de datos para TimeLog
class TimeLogModel extends TimeLog {
  const TimeLogModel({
    required super.id,
    required super.taskId,
    super.userId,
    required super.startTime,
    super.endTime,
    super.durationInSeconds,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Crear desde JSON
  factory TimeLogModel.fromJson(Map<String, dynamic> json) {
    return TimeLogModel(
      id: json['id'] as int,
      taskId: json['task_id'] as int,
      userId: json['user_id'] as int?,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      durationInSeconds: json['duration_in_seconds'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      if (userId != null) 'user_id': userId,
      'start_time': startTime.toIso8601String(),
      if (endTime != null) 'end_time': endTime!.toIso8601String(),
      if (durationInSeconds != null) 'duration_in_seconds': durationInSeconds,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crear desde entidad
  factory TimeLogModel.fromEntity(TimeLog timeLog) {
    return TimeLogModel(
      id: timeLog.id,
      taskId: timeLog.taskId,
      userId: timeLog.userId,
      startTime: timeLog.startTime,
      endTime: timeLog.endTime,
      durationInSeconds: timeLog.durationInSeconds,
      createdAt: timeLog.createdAt,
      updatedAt: timeLog.updatedAt,
    );
  }
}
