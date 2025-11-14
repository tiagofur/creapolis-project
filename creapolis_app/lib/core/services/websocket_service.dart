import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:logger/logger.dart';

/// Service for managing WebSocket connections for real-time collaboration
class WebSocketService {
  io.Socket? _socket;
  final Logger _logger = Logger();
  final String baseUrl;
  bool _isConnected = false;

  // Callbacks
  Function(List<Map<String, dynamic>>)? onRoomUsersUpdated;
  Function(Map<String, dynamic>)? onCursorMoved;
  Function(Map<String, dynamic>)? onContentChanged;
  Function(Map<String, dynamic>)? onNewComment;
  Function(Map<String, dynamic>)? onUserTyping;

  WebSocketService({required this.baseUrl});

  /// Check if WebSocket is connected
  bool get isConnected => _isConnected;

  /// Connect to WebSocket server
  Future<void> connect({required String token}) async {
    try {
      _logger.i('Connecting to WebSocket server: $baseUrl');

      _socket = io.io(
        baseUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setReconnectionAttempts(5)
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .build(),
      );

      _setupEventHandlers();

      _socket?.connect();
    } catch (e) {
      _logger.e('Error connecting to WebSocket: $e');
    }
  }

  /// Setup event handlers
  void _setupEventHandlers() {
    _socket?.onConnect((_) {
      _isConnected = true;
      _logger.i('✅ WebSocket connected');
    });

    _socket?.onDisconnect((_) {
      _isConnected = false;
      _logger.w('🔌 WebSocket disconnected');
    });

    _socket?.onConnectError((error) {
      _logger.e('❌ WebSocket connection error: $error');
    });

    _socket?.onError((error) {
      _logger.e('❌ WebSocket error: $error');
    });

    // Room users updated
    _socket?.on('room_users_updated', (data) {
      _logger.d('👥 Room users updated: $data');
      if (onRoomUsersUpdated != null && data != null) {
        final activeUsers = (data['activeUsers'] as List)
            .map((user) => user as Map<String, dynamic>)
            .toList();
        onRoomUsersUpdated!(activeUsers);
      }
    });

    // Cursor moved
    _socket?.on('cursor_moved', (data) {
      _logger.d('🖱️ Cursor moved: $data');
      if (onCursorMoved != null && data != null) {
        onCursorMoved!(data as Map<String, dynamic>);
      }
    });

    // Content changed
    _socket?.on('content_changed', (data) {
      _logger.d('📝 Content changed: $data');
      if (onContentChanged != null && data != null) {
        onContentChanged!(data as Map<String, dynamic>);
      }
    });

    // New comment
    _socket?.on('new_comment', (data) {
      _logger.d('💬 New comment: $data');
      if (onNewComment != null && data != null) {
        onNewComment!(data as Map<String, dynamic>);
      }
    });

    // User typing
    _socket?.on('user_typing', (data) {
      _logger.d('⌨️ User typing: $data');
      if (onUserTyping != null && data != null) {
        onUserTyping!(data as Map<String, dynamic>);
      }
    });
  }

  /// Join a collaboration room
  void joinRoom({
    required String roomId,
    required int userId,
    required String userName,
  }) {
    if (!_isConnected) {
      _logger.w('Cannot join room: WebSocket not connected');
      return;
    }

    _logger.i('Joining room: $roomId as $userName');
    _socket?.emit('join_room', {
      'roomId': roomId,
      'userId': userId,
      'userName': userName,
    });
  }

  /// Leave a collaboration room
  void leaveRoom({required String roomId}) {
    if (!_isConnected) return;

    _logger.i('Leaving room: $roomId');
    _socket?.emit('leave_room', {'roomId': roomId});
  }

  /// Send cursor position update
  void updateCursor({
    required String roomId,
    required int userId,
    required String userName,
    required Map<String, dynamic> position,
  }) {
    if (!_isConnected) return;

    _socket?.emit('cursor_update', {
      'roomId': roomId,
      'userId': userId,
      'userName': userName,
      'position': position,
    });
  }

  /// Send content update
  void updateContent({
    required String roomId,
    required String contentType,
    required String contentId,
    required String content,
    required int userId,
    required String userName,
  }) {
    if (!_isConnected) return;

    _socket?.emit('content_update', {
      'roomId': roomId,
      'contentType': contentType,
      'contentId': contentId,
      'content': content,
      'userId': userId,
      'userName': userName,
    });
  }

  /// Add a comment
  void addComment({
    required String roomId,
    required Map<String, dynamic> comment,
    required int userId,
    required String userName,
  }) {
    if (!_isConnected) return;

    _socket?.emit('comment_added', {
      'roomId': roomId,
      'comment': comment,
      'userId': userId,
      'userName': userName,
    });
  }

  /// Start typing indicator
  void startTyping({
    required String roomId,
    required int userId,
    required String userName,
    required String field,
  }) {
    if (!_isConnected) return;

    _socket?.emit('typing_start', {
      'roomId': roomId,
      'userId': userId,
      'userName': userName,
      'field': field,
    });
  }

  /// Stop typing indicator
  void stopTyping({
    required String roomId,
    required int userId,
    required String userName,
    required String field,
  }) {
    if (!_isConnected) return;

    _socket?.emit('typing_stop', {
      'roomId': roomId,
      'userId': userId,
      'userName': userName,
      'field': field,
    });
  }

  /// Disconnect from WebSocket server
  void disconnect() {
    _logger.i('Disconnecting from WebSocket server');
    _socket?.disconnect();
    _socket?.dispose();
    _isConnected = false;
  }

  /// Dispose resources
  void dispose() {
    disconnect();
  }
}
