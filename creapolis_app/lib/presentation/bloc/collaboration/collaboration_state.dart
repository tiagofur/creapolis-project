part of 'collaboration_bloc.dart';

/// Base class for collaboration states
abstract class CollaborationState extends Equatable {
  const CollaborationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CollaborationInitial extends CollaborationState {
  const CollaborationInitial();
}

/// WebSocket connecting
class CollaborationConnecting extends CollaborationState {
  const CollaborationConnecting();
}

/// WebSocket connected
class CollaborationConnected extends CollaborationState {
  final String? currentRoomId;
  final List<ActiveUser> activeUsers;
  final Map<String, UserCursor> cursors;
  final Map<String, TypingIndicator> typingIndicators;

  const CollaborationConnected({
    this.currentRoomId,
    this.activeUsers = const [],
    this.cursors = const {},
    this.typingIndicators = const {},
  });

  @override
  List<Object?> get props => [currentRoomId, activeUsers, cursors, typingIndicators];

  CollaborationConnected copyWith({
    String? currentRoomId,
    List<ActiveUser>? activeUsers,
    Map<String, UserCursor>? cursors,
    Map<String, TypingIndicator>? typingIndicators,
  }) {
    return CollaborationConnected(
      currentRoomId: currentRoomId ?? this.currentRoomId,
      activeUsers: activeUsers ?? this.activeUsers,
      cursors: cursors ?? this.cursors,
      typingIndicators: typingIndicators ?? this.typingIndicators,
    );
  }
}

/// WebSocket disconnected
class CollaborationDisconnected extends CollaborationState {
  const CollaborationDisconnected();
}

/// WebSocket error
class CollaborationError extends CollaborationState {
  final String message;

  const CollaborationError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Content update received
class CollaborationContentUpdated extends CollaborationConnected {
  final String contentType;
  final String contentId;
  final String content;
  final int userId;
  final String userName;
  final DateTime timestamp;

  const CollaborationContentUpdated({
    required this.contentType,
    required this.contentId,
    required this.content,
    required this.userId,
    required this.userName,
    required this.timestamp,
    super.currentRoomId,
    super.activeUsers,
    super.cursors,
    super.typingIndicators,
  });

  @override
  List<Object?> get props => [
        contentType,
        contentId,
        content,
        userId,
        userName,
        timestamp,
        currentRoomId,
        activeUsers,
        cursors,
        typingIndicators,
      ];
}
