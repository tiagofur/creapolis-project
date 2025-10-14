import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/websocket_service.dart';
import '../../../data/models/collaboration_model.dart';

part 'collaboration_event.dart';
part 'collaboration_state.dart';

/// BLoC for managing real-time collaboration
class CollaborationBloc extends Bloc<CollaborationEvent, CollaborationState> {
  final WebSocketService _webSocketService;

  CollaborationBloc({required WebSocketService webSocketService})
      : _webSocketService = webSocketService,
        super(const CollaborationInitial()) {
    // Setup WebSocket callbacks
    _setupWebSocketCallbacks();

    // Event handlers
    on<ConnectToWebSocket>(_onConnectToWebSocket);
    on<DisconnectFromWebSocket>(_onDisconnectFromWebSocket);
    on<JoinCollaborationRoom>(_onJoinCollaborationRoom);
    on<LeaveCollaborationRoom>(_onLeaveCollaborationRoom);
    on<RoomUsersUpdated>(_onRoomUsersUpdated);
    on<CursorMoved>(_onCursorMoved);
    on<UpdateCursorPosition>(_onUpdateCursorPosition);
    on<ContentChanged>(_onContentChanged);
    on<UpdateContent>(_onUpdateContent);
    on<UserStartedTyping>(_onUserStartedTyping);
    on<UserStoppedTyping>(_onUserStoppedTyping);
    on<StartTyping>(_onStartTyping);
    on<StopTyping>(_onStopTyping);
  }

  /// Setup WebSocket callbacks
  void _setupWebSocketCallbacks() {
    _webSocketService.onRoomUsersUpdated = (users) {
      final activeUsers = users.map((u) => ActiveUser.fromJson(u)).toList();
      add(RoomUsersUpdated(activeUsers: activeUsers));
    };

    _webSocketService.onCursorMoved = (data) {
      final cursor = UserCursor.fromJson(data);
      add(CursorMoved(cursor: cursor));
    };

    _webSocketService.onContentChanged = (data) {
      add(ContentChanged(
        contentType: data['contentType'] as String,
        contentId: data['contentId'] as String,
        content: data['content'] as String,
        userId: data['userId'] as int,
        userName: data['userName'] as String,
        timestamp: DateTime.parse(data['timestamp'] as String),
      ));
    };

    _webSocketService.onUserTyping = (data) {
      final indicator = TypingIndicator.fromJson(data);
      if (indicator.isTyping) {
        add(UserStartedTyping(indicator: indicator));
      } else {
        add(UserStoppedTyping(indicator: indicator));
      }
    };
  }

  /// Handle connect to WebSocket
  Future<void> _onConnectToWebSocket(
    ConnectToWebSocket event,
    Emitter<CollaborationState> emit,
  ) async {
    emit(const CollaborationConnecting());
    try {
      await _webSocketService.connect(token: event.token);
      emit(const CollaborationConnected());
    } catch (e) {
      emit(CollaborationError(message: 'Failed to connect: $e'));
    }
  }

  /// Handle disconnect from WebSocket
  Future<void> _onDisconnectFromWebSocket(
    DisconnectFromWebSocket event,
    Emitter<CollaborationState> emit,
  ) async {
    _webSocketService.disconnect();
    emit(const CollaborationDisconnected());
  }

  /// Handle join collaboration room
  Future<void> _onJoinCollaborationRoom(
    JoinCollaborationRoom event,
    Emitter<CollaborationState> emit,
  ) async {
    _webSocketService.joinRoom(
      roomId: event.roomId,
      userId: event.userId,
      userName: event.userName,
    );

    if (state is CollaborationConnected) {
      emit((state as CollaborationConnected).copyWith(
        currentRoomId: event.roomId,
      ));
    }
  }

  /// Handle leave collaboration room
  Future<void> _onLeaveCollaborationRoom(
    LeaveCollaborationRoom event,
    Emitter<CollaborationState> emit,
  ) async {
    _webSocketService.leaveRoom(roomId: event.roomId);

    if (state is CollaborationConnected) {
      emit((state as CollaborationConnected).copyWith(
        currentRoomId: null,
        activeUsers: [],
        cursors: {},
        typingIndicators: {},
      ));
    }
  }

  /// Handle room users updated
  Future<void> _onRoomUsersUpdated(
    RoomUsersUpdated event,
    Emitter<CollaborationState> emit,
  ) async {
    if (state is CollaborationConnected) {
      emit((state as CollaborationConnected).copyWith(
        activeUsers: event.activeUsers,
      ));
    }
  }

  /// Handle cursor moved
  Future<void> _onCursorMoved(
    CursorMoved event,
    Emitter<CollaborationState> emit,
  ) async {
    if (state is CollaborationConnected) {
      final currentState = state as CollaborationConnected;
      final updatedCursors = Map<String, UserCursor>.from(currentState.cursors);
      updatedCursors[event.cursor.socketId] = event.cursor;

      emit(currentState.copyWith(cursors: updatedCursors));
    }
  }

  /// Handle update cursor position
  Future<void> _onUpdateCursorPosition(
    UpdateCursorPosition event,
    Emitter<CollaborationState> emit,
  ) async {
    _webSocketService.updateCursor(
      roomId: event.roomId,
      userId: event.userId,
      userName: event.userName,
      position: event.position.toJson(),
    );
  }

  /// Handle content changed
  Future<void> _onContentChanged(
    ContentChanged event,
    Emitter<CollaborationState> emit,
  ) async {
    if (state is CollaborationConnected) {
      final currentState = state as CollaborationConnected;
      emit(CollaborationContentUpdated(
        contentType: event.contentType,
        contentId: event.contentId,
        content: event.content,
        userId: event.userId,
        userName: event.userName,
        timestamp: event.timestamp,
        currentRoomId: currentState.currentRoomId,
        activeUsers: currentState.activeUsers,
        cursors: currentState.cursors,
        typingIndicators: currentState.typingIndicators,
      ));
    }
  }

  /// Handle update content
  Future<void> _onUpdateContent(
    UpdateContent event,
    Emitter<CollaborationState> emit,
  ) async {
    _webSocketService.updateContent(
      roomId: event.roomId,
      contentType: event.contentType,
      contentId: event.contentId,
      content: event.content,
      userId: event.userId,
      userName: event.userName,
    );
  }

  /// Handle user started typing
  Future<void> _onUserStartedTyping(
    UserStartedTyping event,
    Emitter<CollaborationState> emit,
  ) async {
    if (state is CollaborationConnected) {
      final currentState = state as CollaborationConnected;
      final updatedIndicators = Map<String, TypingIndicator>.from(currentState.typingIndicators);
      final key = '${event.indicator.userId}_${event.indicator.field}';
      updatedIndicators[key] = event.indicator;

      emit(currentState.copyWith(typingIndicators: updatedIndicators));
    }
  }

  /// Handle user stopped typing
  Future<void> _onUserStoppedTyping(
    UserStoppedTyping event,
    Emitter<CollaborationState> emit,
  ) async {
    if (state is CollaborationConnected) {
      final currentState = state as CollaborationConnected;
      final updatedIndicators = Map<String, TypingIndicator>.from(currentState.typingIndicators);
      final key = '${event.indicator.userId}_${event.indicator.field}';
      updatedIndicators.remove(key);

      emit(currentState.copyWith(typingIndicators: updatedIndicators));
    }
  }

  /// Handle start typing
  Future<void> _onStartTyping(
    StartTyping event,
    Emitter<CollaborationState> emit,
  ) async {
    _webSocketService.startTyping(
      roomId: event.roomId,
      userId: event.userId,
      userName: event.userName,
      field: event.field,
    );
  }

  /// Handle stop typing
  Future<void> _onStopTyping(
    StopTyping event,
    Emitter<CollaborationState> emit,
  ) async {
    _webSocketService.stopTyping(
      roomId: event.roomId,
      userId: event.userId,
      userName: event.userName,
      field: event.field,
    );
  }

  @override
  Future<void> close() {
    _webSocketService.dispose();
    return super.close();
  }
}
