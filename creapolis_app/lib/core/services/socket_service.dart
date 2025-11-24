import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../constants/storage_keys.dart';
import '../utils/app_logger.dart';
import '../config/environment_config.dart';

class SocketService {
  final FlutterSecureStorage _storage;
  io.Socket? _socket;

  SocketService(this._storage);

  // Get base URL from config, removing '/api' if present
  String get _baseUrl {
    final apiUrl = EnvironmentConfig.apiBaseUrl;
    if (apiUrl.endsWith('/api')) {
      return apiUrl.substring(0, apiUrl.length - 4);
    }
    if (apiUrl.endsWith('/api/')) {
      return apiUrl.substring(0, apiUrl.length - 5);
    }
    return apiUrl;
  }

  Future<void> init() async {
    final token = await _storage.read(key: StorageKeys.accessToken);

    if (token == null) {
      AppLogger.warning('SocketService: No token found, skipping connection');
      return;
    }

    _connect(token);
  }

  void _connect(String token) {
    if (_socket != null && _socket!.connected) return;

    AppLogger.info('SocketService: Connecting to $_baseUrl');

    _socket = io.io(
      _baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': token}) // Some backends expect auth object
          .setExtraHeaders({'Authorization': 'Bearer $token'}) // Others headers
          .build(),
    );

    _socket!.onConnect((_) {
      AppLogger.success('SocketService: Connected');
    });

    _socket!.onDisconnect((_) {
      AppLogger.warning('SocketService: Disconnected');
    });

    _socket!.onConnectError((data) {
      AppLogger.error('SocketService Connect Error: $data');
    });

    _socket!.onError((data) {
      AppLogger.error('SocketService Error: $data');
    });
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
    }
  }

  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  void off(String event) {
    _socket?.off(event);
  }

  bool get isConnected => _socket?.connected ?? false;
}
