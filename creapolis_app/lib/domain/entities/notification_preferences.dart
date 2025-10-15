import 'package:equatable/equatable.dart';

/// Entidad de preferencias de notificación
class NotificationPreferences extends Equatable {
  final int id;
  final int userId;
  final bool pushEnabled;
  final bool emailEnabled;
  final bool mentionNotifications;
  final bool commentReplyNotifications;
  final bool taskAssignedNotifications;
  final bool taskUpdatedNotifications;
  final bool projectUpdatedNotifications;
  final bool systemNotifications;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationPreferences({
    required this.id,
    required this.userId,
    required this.pushEnabled,
    required this.emailEnabled,
    required this.mentionNotifications,
    required this.commentReplyNotifications,
    required this.taskAssignedNotifications,
    required this.taskUpdatedNotifications,
    required this.projectUpdatedNotifications,
    required this.systemNotifications,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        pushEnabled,
        emailEnabled,
        mentionNotifications,
        commentReplyNotifications,
        taskAssignedNotifications,
        taskUpdatedNotifications,
        projectUpdatedNotifications,
        systemNotifications,
        createdAt,
        updatedAt,
      ];

  NotificationPreferences copyWith({
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
    return NotificationPreferences(
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



