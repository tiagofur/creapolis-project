import 'package:equatable/equatable.dart';

/// Model for user cursor position
class UserCursor extends Equatable {
  final int userId;
  final String userName;
  final String socketId;
  final CursorPosition position;

  const UserCursor({
    required this.userId,
    required this.userName,
    required this.socketId,
    required this.position,
  });

  factory UserCursor.fromJson(Map<String, dynamic> json) {
    return UserCursor(
      userId: json['userId'] as int,
      userName: json['userName'] as String,
      socketId: json['socketId'] as String,
      position: CursorPosition.fromJson(json['position'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'socketId': socketId,
      'position': position.toJson(),
    };
  }

  @override
  List<Object?> get props => [userId, userName, socketId, position];
}

/// Model for cursor position
class CursorPosition extends Equatable {
  final double x;
  final double y;
  final String? fieldId;

  const CursorPosition({
    required this.x,
    required this.y,
    this.fieldId,
  });

  factory CursorPosition.fromJson(Map<String, dynamic> json) {
    return CursorPosition(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      fieldId: json['fieldId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      if (fieldId != null) 'fieldId': fieldId,
    };
  }

  @override
  List<Object?> get props => [x, y, fieldId];
}

/// Model for active user in a collaboration room
class ActiveUser extends Equatable {
  final int userId;
  final String userName;

  const ActiveUser({
    required this.userId,
    required this.userName,
  });

  factory ActiveUser.fromJson(Map<String, dynamic> json) {
    return ActiveUser(
      userId: json['userId'] as int,
      userName: json['userName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
    };
  }

  @override
  List<Object?> get props => [userId, userName];
}

/// Model for typing indicator
class TypingIndicator extends Equatable {
  final int userId;
  final String userName;
  final String field;
  final bool isTyping;

  const TypingIndicator({
    required this.userId,
    required this.userName,
    required this.field,
    required this.isTyping,
  });

  factory TypingIndicator.fromJson(Map<String, dynamic> json) {
    return TypingIndicator(
      userId: json['userId'] as int,
      userName: json['userName'] as String,
      field: json['field'] as String,
      isTyping: json['isTyping'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'field': field,
      'isTyping': isTyping,
    };
  }

  @override
  List<Object?> get props => [userId, userName, field, isTyping];
}



