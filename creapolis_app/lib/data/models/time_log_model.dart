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
    final idValue = json['id'] ?? json['timeLogId'] ?? json['time_log_id'];
    final taskMap = json['task'];
    final userMap = json['user'];

    final taskIdValue =
        json['taskId'] ??
        json['task_id'] ??
        (taskMap is Map<String, dynamic> ? taskMap['id'] : null) ??
        (taskMap is Map<String, dynamic> ? taskMap['taskId'] : null) ??
        (taskMap is Map<String, dynamic> ? taskMap['task_id'] : null);

    final userIdValue =
        json['userId'] ??
        json['user_id'] ??
        (userMap is Map<String, dynamic> ? userMap['id'] : null) ??
        (userMap is Map<String, dynamic> ? userMap['userId'] : null) ??
        (userMap is Map<String, dynamic> ? userMap['user_id'] : null);

    final startTimeRaw = json['startTime'] ?? json['start_time'];
    final endTimeRaw = json['endTime'] ?? json['end_time'];
    final createdAtRaw =
        json['createdAt'] ?? json['created_at'] ?? startTimeRaw;
    final updatedAtRaw =
        json['updatedAt'] ?? json['updated_at'] ?? createdAtRaw;

    if (idValue == null) {
      throw FormatException(
        'TimeLog id is required but was null. Payload: $json',
      );
    }
    if (taskIdValue == null) {
      throw FormatException(
        'TimeLog taskId is required but was null. Payload: $json',
      );
    }
    if (startTimeRaw == null) {
      throw FormatException(
        'TimeLog startTime is required but was null. Payload: $json',
      );
    }
    if (createdAtRaw == null) {
      throw FormatException(
        'TimeLog createdAt is required but was null. Payload: $json',
      );
    }
    if (updatedAtRaw == null) {
      throw FormatException(
        'TimeLog updatedAt is required but was null. Payload: $json',
      );
    }

    return TimeLogModel(
      id: _parseInt(idValue, fieldName: 'id'),
      taskId: _parseInt(taskIdValue, fieldName: 'taskId'),
      userId: _parseIntOrNull(userIdValue, fieldName: 'userId'),
      startTime: _parseDate(startTimeRaw, fieldName: 'startTime'),
      endTime: _parseDateOrNull(endTimeRaw),
      durationInSeconds: _parseDurationInSeconds(json),
      createdAt: _parseDate(createdAtRaw, fieldName: 'createdAt'),
      updatedAt: _parseDate(updatedAtRaw, fieldName: 'updatedAt'),
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      if (userId != null) 'userId': userId,
      'startTime': startTime.toIso8601String(),
      if (endTime != null) 'endTime': endTime!.toIso8601String(),
      if (durationInSeconds != null) ...{
        'durationInSeconds': durationInSeconds,
        'duration': durationInSeconds! / 3600,
      },
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
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

int _parseInt(dynamic value, {required String fieldName}) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  if (value is String) {
    final parsedInt = int.tryParse(value);
    if (parsedInt != null) {
      return parsedInt;
    }

    final parsedNum = num.tryParse(value);
    if (parsedNum != null) {
      return parsedNum.toInt();
    }
  }

  throw FormatException('Invalid $fieldName value for TimeLog: $value');
}

int? _parseIntOrNull(dynamic value, {required String fieldName}) {
  if (value == null) {
    return null;
  }

  return _parseInt(value, fieldName: fieldName);
}

DateTime _parseDate(dynamic value, {required String fieldName}) {
  if (value is DateTime) {
    return value;
  }

  if (value is String) {
    return DateTime.parse(value);
  }

  throw FormatException('Invalid $fieldName value for TimeLog: $value');
}

DateTime? _parseDateOrNull(dynamic value) {
  if (value == null) {
    return null;
  }

  return _parseDate(value, fieldName: 'endTime');
}

num _parseNum(dynamic value, {required String fieldName}) {
  if (value is num) {
    return value;
  }

  if (value is String) {
    final parsed = num.tryParse(value.trim());
    if (parsed != null) {
      return parsed;
    }
  }

  throw FormatException('Invalid $fieldName value for TimeLog: $value');
}

int? _parseDurationInSeconds(Map<String, dynamic> json) {
  final durationSecondsRaw =
      json.containsKey('durationInSeconds') ||
          json.containsKey('duration_in_seconds')
      ? json['durationInSeconds'] ?? json['duration_in_seconds']
      : null;

  if (durationSecondsRaw != null) {
    return _parseInt(durationSecondsRaw, fieldName: 'durationInSeconds');
  }

  final durationRaw = json['duration'];
  if (durationRaw == null) {
    return null;
  }

  final durationInHours = _parseNum(durationRaw, fieldName: 'duration');
  return (durationInHours * 3600).round();
}
