import '../../domain/entities/calendar_event.dart';
import '../../domain/repositories/calendar_repository.dart';

/// Modelo de datos para CalendarEvent
class CalendarEventModel extends CalendarEvent {
  const CalendarEventModel({
    required super.id,
    required super.title,
    super.description,
    required super.startTime,
    required super.endTime,
    super.location,
    super.isAllDay,
    super.attendees,
    super.htmlLink,
  });

  /// Crea desde JSON
  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    return CalendarEventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      location: json['location'] as String?,
      isAllDay: json['isAllDay'] as bool? ?? false,
      attendees: json['attendees'] != null
          ? List<String>.from(json['attendees'] as List)
          : [],
      htmlLink: json['htmlLink'] as String?,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'location': location,
      'isAllDay': isAllDay,
      'attendees': attendees,
      'htmlLink': htmlLink,
    };
  }
}

/// Modelo de datos para CalendarConnection
class CalendarConnectionModel extends CalendarConnection {
  const CalendarConnectionModel({
    required super.status,
    super.userEmail,
    super.connectedAt,
    super.errorMessage,
  });

  /// Crea desde JSON
  factory CalendarConnectionModel.fromJson(Map<String, dynamic> json) {
    return CalendarConnectionModel(
      status: _parseStatus(json['status'] as String?),
      userEmail: json['userEmail'] as String?,
      connectedAt: json['connectedAt'] != null
          ? DateTime.parse(json['connectedAt'] as String)
          : null,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'status': _statusToString(status),
      'userEmail': userEmail,
      'connectedAt': connectedAt?.toIso8601String(),
      'errorMessage': errorMessage,
    };
  }

  /// Parsea el estado desde string
  static CalendarConnectionStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'connected':
        return CalendarConnectionStatus.connected;
      case 'connecting':
        return CalendarConnectionStatus.connecting;
      case 'error':
        return CalendarConnectionStatus.error;
      default:
        return CalendarConnectionStatus.disconnected;
    }
  }

  /// Convierte el estado a string
  static String _statusToString(CalendarConnectionStatus status) {
    switch (status) {
      case CalendarConnectionStatus.connected:
        return 'connected';
      case CalendarConnectionStatus.connecting:
        return 'connecting';
      case CalendarConnectionStatus.error:
        return 'error';
      case CalendarConnectionStatus.disconnected:
        return 'disconnected';
    }
  }
}

/// Modelo de datos para TimeSlot
class TimeSlotModel extends TimeSlot {
  const TimeSlotModel({
    required super.startTime,
    required super.endTime,
    required super.isAvailable,
  });

  /// Crea desde JSON
  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      isAvailable: json['isAvailable'] as bool,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isAvailable': isAvailable,
    };
  }
}



