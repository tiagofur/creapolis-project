import 'package:equatable/equatable.dart';

/// Entidad de dominio para Registro de Tiempo
class TimeLog extends Equatable {
  final int id;
  final int taskId;
  final int? userId;
  final DateTime startTime;
  final DateTime? endTime;
  final int? durationInSeconds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TimeLog({
    required this.id,
    required this.taskId,
    this.userId,
    required this.startTime,
    this.endTime,
    this.durationInSeconds,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Verifica si el registro de tiempo está activo (sin endTime)
  bool get isActive => endTime == null;

  /// Obtiene la duración calculada
  Duration get duration {
    if (durationInSeconds != null) {
      return Duration(seconds: durationInSeconds!);
    }
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    // Si está activo, calcular duración hasta ahora
    return DateTime.now().difference(startTime);
  }

  /// Calcula la duración en horas
  double get durationInHours {
    return duration.inSeconds / 3600.0;
  }

  /// Calcula la duración en minutos
  int get durationInMinutes {
    return duration.inMinutes;
  }

  /// Calcula la duración en segundos
  int get durationInSecondsCalculated {
    return duration.inSeconds;
  }

  /// Formatea la duración como string (HH:MM:SS)
  String get formattedDuration {
    final d = duration;
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Formatea la duración de forma corta (2h 30m)
  String get shortFormattedDuration {
    final d = duration;
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Copia el TimeLog con nuevos valores
  TimeLog copyWith({
    int? id,
    int? taskId,
    int? userId,
    DateTime? startTime,
    DateTime? endTime,
    int? durationInSeconds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TimeLog(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationInSeconds: durationInSeconds ?? this.durationInSeconds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    taskId,
    userId,
    startTime,
    endTime,
    durationInSeconds,
    createdAt,
    updatedAt,
  ];
}
