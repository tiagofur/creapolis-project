import 'package:equatable/equatable.dart';

/// Tipos de notificación
enum NotificationType {
  mention,
  commentReply,
  taskAssigned,
  taskUpdated,
  projectUpdated,
  system;

  String get displayName {
    switch (this) {
      case NotificationType.mention:
        return 'Mención';
      case NotificationType.commentReply:
        return 'Respuesta';
      case NotificationType.taskAssigned:
        return 'Tarea asignada';
      case NotificationType.taskUpdated:
        return 'Tarea actualizada';
      case NotificationType.projectUpdated:
        return 'Proyecto actualizado';
      case NotificationType.system:
        return 'Sistema';
    }
  }

  /// Parse from backend string
  static NotificationType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'MENTION':
        return NotificationType.mention;
      case 'COMMENT_REPLY':
        return NotificationType.commentReply;
      case 'TASK_ASSIGNED':
        return NotificationType.taskAssigned;
      case 'TASK_UPDATED':
        return NotificationType.taskUpdated;
      case 'PROJECT_UPDATED':
        return NotificationType.projectUpdated;
      case 'SYSTEM':
        return NotificationType.system;
      default:
        return NotificationType.system;
    }
  }

  /// Convert to backend string
  String toBackendString() {
    switch (this) {
      case NotificationType.mention:
        return 'MENTION';
      case NotificationType.commentReply:
        return 'COMMENT_REPLY';
      case NotificationType.taskAssigned:
        return 'TASK_ASSIGNED';
      case NotificationType.taskUpdated:
        return 'TASK_UPDATED';
      case NotificationType.projectUpdated:
        return 'PROJECT_UPDATED';
      case NotificationType.system:
        return 'SYSTEM';
    }
  }
}

/// Entidad de dominio para Notificación
class Notification extends Equatable {
  final int id;
  final int userId;
  final NotificationType type;
  final String title;
  final String message;
  final bool isRead;
  final int? relatedId;
  final String? relatedType;
  final DateTime createdAt;
  final DateTime? readAt;

  const Notification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.isRead = false,
    this.relatedId,
    this.relatedType,
    required this.createdAt,
    this.readAt,
  });

  /// Copia la notificación con nuevos valores
  Notification copyWith({
    int? id,
    int? userId,
    NotificationType? type,
    String? title,
    String? message,
    bool? isRead,
    int? relatedId,
    String? relatedType,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId ?? this.relatedId,
      relatedType: relatedType ?? this.relatedType,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        title,
        message,
        isRead,
        relatedId,
        relatedType,
        createdAt,
        readAt,
      ];
}



