import 'dart:convert';
import '../../domain/entities/notification.dart';

/// Modelo de datos para Notificación
class NotificationModel {
  final int id;
  final int userId;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final int? relatedId;
  final String? relatedType;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.isRead = false,
    this.relatedId,
    this.relatedType,
    this.data,
    required this.createdAt,
    this.readAt,
  });

  /// Convierte desde JSON del backend
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? parsedData;
    if (json['data'] != null) {
      if (json['data'] is String) {
        try {
          parsedData =
              jsonDecode(json['data'] as String) as Map<String, dynamic>;
        } catch (_) {}
      } else if (json['data'] is Map) {
        parsedData = json['data'] as Map<String, dynamic>;
      }
    }

    return NotificationModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      isRead: json['isRead'] as bool? ?? false,
      relatedId: json['relatedId'] as int?,
      relatedType: json['relatedType'] as String?,
      data: parsedData,
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
    );
  }

  /// Convierte a JSON para el backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      'isRead': isRead,
      if (relatedId != null) 'relatedId': relatedId,
      if (relatedType != null) 'relatedType': relatedType,
      if (data != null) 'data': jsonEncode(data),
      'createdAt': createdAt.toIso8601String(),
      if (readAt != null) 'readAt': readAt!.toIso8601String(),
    };
  }

  /// Convierte a entidad de dominio
  Notification toEntity() {
    return Notification(
      id: id,
      userId: userId,
      type: NotificationType.fromString(type),
      title: title,
      message: message,
      isRead: isRead,
      relatedId: relatedId,
      relatedType: relatedType,
      data: data,
      createdAt: createdAt,
      readAt: readAt,
    );
  }

  /// Crea desde entidad de dominio
  factory NotificationModel.fromEntity(Notification notification) {
    return NotificationModel(
      id: notification.id,
      userId: notification.userId,
      type: notification.type.toBackendString(),
      title: notification.title,
      message: notification.message,
      isRead: notification.isRead,
      relatedId: notification.relatedId,
      relatedType: notification.relatedType,
      data: notification.data,
      createdAt: notification.createdAt,
      readAt: notification.readAt,
    );
  }
}
