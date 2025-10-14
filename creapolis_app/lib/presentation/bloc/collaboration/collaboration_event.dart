part of 'collaboration_bloc.dart';

/// Base class for collaboration events
abstract class CollaborationEvent extends Equatable {
  const CollaborationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to connect to WebSocket
class ConnectToWebSocket extends CollaborationEvent {
  final String token;

  const ConnectToWebSocket({required this.token});

  @override
  List<Object?> get props => [token];
}

/// Event to disconnect from WebSocket
class DisconnectFromWebSocket extends CollaborationEvent {
  const DisconnectFromWebSocket();
}

/// Event to join a collaboration room
class JoinCollaborationRoom extends CollaborationEvent {
  final String roomId;
  final int userId;
  final String userName;

  const JoinCollaborationRoom({
    required this.roomId,
    required this.userId,
    required this.userName,
  });

  @override
  List<Object?> get props => [roomId, userId, userName];
}

/// Event to leave a collaboration room
class LeaveCollaborationRoom extends CollaborationEvent {
  final String roomId;

  const LeaveCollaborationRoom({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

/// Event when room users are updated
class RoomUsersUpdated extends CollaborationEvent {
  final List<ActiveUser> activeUsers;

  const RoomUsersUpdated({required this.activeUsers});

  @override
  List<Object?> get props => [activeUsers];
}

/// Event when a cursor is moved
class CursorMoved extends CollaborationEvent {
  final UserCursor cursor;

  const CursorMoved({required this.cursor});

  @override
  List<Object?> get props => [cursor];
}

/// Event to update own cursor position
class UpdateCursorPosition extends CollaborationEvent {
  final String roomId;
  final int userId;
  final String userName;
  final CursorPosition position;

  const UpdateCursorPosition({
    required this.roomId,
    required this.userId,
    required this.userName,
    required this.position,
  });

  @override
  List<Object?> get props => [roomId, userId, userName, position];
}

/// Event when content is changed
class ContentChanged extends CollaborationEvent {
  final String contentType;
  final String contentId;
  final String content;
  final int userId;
  final String userName;
  final DateTime timestamp;

  const ContentChanged({
    required this.contentType,
    required this.contentId,
    required this.content,
    required this.userId,
    required this.userName,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [contentType, contentId, content, userId, userName, timestamp];
}

/// Event to update content
class UpdateContent extends CollaborationEvent {
  final String roomId;
  final String contentType;
  final String contentId;
  final String content;
  final int userId;
  final String userName;

  const UpdateContent({
    required this.roomId,
    required this.contentType,
    required this.contentId,
    required this.content,
    required this.userId,
    required this.userName,
  });

  @override
  List<Object?> get props => [roomId, contentType, contentId, content, userId, userName];
}

/// Event when a user starts typing
class UserStartedTyping extends CollaborationEvent {
  final TypingIndicator indicator;

  const UserStartedTyping({required this.indicator});

  @override
  List<Object?> get props => [indicator];
}

/// Event when a user stops typing
class UserStoppedTyping extends CollaborationEvent {
  final TypingIndicator indicator;

  const UserStoppedTyping({required this.indicator});

  @override
  List<Object?> get props => [indicator];
}

/// Event to start typing
class StartTyping extends CollaborationEvent {
  final String roomId;
  final int userId;
  final String userName;
  final String field;

  const StartTyping({
    required this.roomId,
    required this.userId,
    required this.userName,
    required this.field,
  });

  @override
  List<Object?> get props => [roomId, userId, userName, field];
}

/// Event to stop typing
class StopTyping extends CollaborationEvent {
  final String roomId;
  final int userId;
  final String userName;
  final String field;

  const StopTyping({
    required this.roomId,
    required this.userId,
    required this.userName,
    required this.field,
  });

  @override
  List<Object?> get props => [roomId, userId, userName, field];
}
