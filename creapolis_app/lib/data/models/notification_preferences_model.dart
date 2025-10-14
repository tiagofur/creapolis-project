import '../../domain/entities/notification_preferences.dart';

/// Modelo de preferencias de notificación
class NotificationPreferencesModel extends NotificationPreferences {
  const NotificationPreferencesModel({
    required super.id,
    required super.userId,
    required super.pushEnabled,
    required super.emailEnabled,
    required super.mentionNotifications,
    required super.commentReplyNotifications,
    required super.taskAssignedNotifications,
    required super.taskUpdatedNotifications,
    required super.projectUpdatedNotifications,
    required super.systemNotifications,
    required super.createdAt,
    required super.updatedAt,
  });

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      pushEnabled: json['pushEnabled'] as bool,
      emailEnabled: json['emailEnabled'] as bool,
      mentionNotifications: json['mentionNotifications'] as bool,
      commentReplyNotifications: json['commentReplyNotifications'] as bool,
      taskAssignedNotifications: json['taskAssignedNotifications'] as bool,
      taskUpdatedNotifications: json['taskUpdatedNotifications'] as bool,
      projectUpdatedNotifications: json['projectUpdatedNotifications'] as bool,
      systemNotifications: json['systemNotifications'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'pushEnabled': pushEnabled,
      'emailEnabled': emailEnabled,
      'mentionNotifications': mentionNotifications,
      'commentReplyNotifications': commentReplyNotifications,
      'taskAssignedNotifications': taskAssignedNotifications,
      'taskUpdatedNotifications': taskUpdatedNotifications,
      'projectUpdatedNotifications': projectUpdatedNotifications,
      'systemNotifications': systemNotifications,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  NotificationPreferencesModel copyWith({
    int? id,
    int? userId,
    bool? pushEnabled,
    bool? emailEnabled,
    bool? mentionNotifications,
    bool? commentReplyNotifications,
    bool? taskAssignedNotifications,
    bool? taskUpdatedNotifications,
    bool? projectUpdatedNotifications,
    bool? systemNotifications,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationPreferencesModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      mentionNotifications: mentionNotifications ?? this.mentionNotifications,
      commentReplyNotifications:
          commentReplyNotifications ?? this.commentReplyNotifications,
      taskAssignedNotifications:
          taskAssignedNotifications ?? this.taskAssignedNotifications,
      taskUpdatedNotifications:
          taskUpdatedNotifications ?? this.taskUpdatedNotifications,
      projectUpdatedNotifications:
          projectUpdatedNotifications ?? this.projectUpdatedNotifications,
      systemNotifications: systemNotifications ?? this.systemNotifications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
