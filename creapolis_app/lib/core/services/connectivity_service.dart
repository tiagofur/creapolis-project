import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
import '../utils/app_logger.dart';

/// Servicio para monitorear el estado de conectividad de la aplicación.
///
/// Proporciona acceso al estado actual de conectividad y un stream para
/// monitorear cambios en tiempo real. Utiliza connectivity_plus para
/// detectar cambios de red (WiFi, Mobile, None).
///
/// Ejemplo de uso:
/// ```dart
/// final isOnline = await connectivityService.isConnected;
/// if (isOnline) {
///   // Realizar operación que requiere red
/// } else {
///   // Usar caché local
/// }
///
/// // Monitorear cambios de conectividad
/// connectivityService.connectionStream.listen((isConnected) {
///   if (isConnected) {
///     // Se restauró la conexión - sincronizar datos
///   } else {
///     // Se perdió la conexión - cambiar a modo offline
///   }
/// });
/// ```
@lazySingleton
class ConnectivityService {
  final Connectivity _connectivity;

  // Stream controller para emitir cambios de conectividad
  final _connectionController = StreamController<bool>.broadcast();

  // Caché del último estado conocido
  bool? _lastKnownState;

  // Suscripción al stream de connectivity_plus
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  ConnectivityService(this._connectivity) {
    _initConnectivityMonitoring();
  }

  /// Inicializa el monitoreo de conectividad.
  ///
  /// Suscribe al stream de connectivity_plus y emite cambios cuando
  /// el estado de la red cambia.
  void _initConnectivityMonitoring() {
    AppLogger.info('Inicializando monitoreo de conectividad');

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      final isConnected = _isConnectedFromResults(results);

      // Solo emitir si el estado cambió
      if (_lastKnownState != isConnected) {
        AppLogger.info(
          'Estado de conectividad cambió: ${isConnected ? "Online" : "Offline"}',
        );
        _lastKnownState = isConnected;
        _connectionController.add(isConnected);
      }
    });
  }

  /// Verifica si hay conexión a internet actualmente.
  ///
  /// Devuelve `true` si hay conexión WiFi o móvil, `false` si no hay conexión.
  ///
  /// Este método consulta el estado actual de conectividad. Para monitoreo
  /// en tiempo real, usa [connectionStream].
  Future<bool> get isConnected async {
    try {
      final results = await _connectivity.checkConnectivity();
      final connected = _isConnectedFromResults(results);

      // Actualizar caché si es la primera verificación
      _lastKnownState ??= connected;

      return connected;
    } catch (e, stackTrace) {
      AppLogger.error('Error al verificar conectividad', e, stackTrace);
      // En caso de error, asumir sin conexión (fail-safe)
      return false;
    }
  }

  /// Stream que emite cambios en el estado de conectividad.
  ///
  /// Emite `true` cuando se establece conexión y `false` cuando se pierde.
  /// Útil para reaccionar a cambios de red en tiempo real.
  ///
  /// Ejemplo:
  /// ```dart
  /// connectivityService.connectionStream.listen((isConnected) {
  ///   if (isConnected) {
  ///     // Iniciar sincronización automática
  ///     syncManager.syncPendingOperations();
  ///   }
  /// });
  /// ```
  Stream<bool> get connectionStream => _connectionController.stream;

  /// Determina si hay conexión basado en los resultados de connectivity_plus.
  ///
  /// Considera conectado si hay WiFi, mobile, ethernet, bluetooth o VPN.
  /// Solo considera desconectado si el resultado es `none`.
  bool _isConnectedFromResults(List<ConnectivityResult> results) {
    return results.any(
      (result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.vpn ||
          result == ConnectivityResult.bluetooth,
    );
  }

  /// Obtiene el tipo de conexión actual como string para logging.
  ///
  /// Útil para debugging y análisis de conectividad.
  Future<String> get connectionType async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (results.isEmpty) {
        return 'none';
      }
      return results.map((r) => r.name).join(', ');
    } catch (e) {
      return 'unknown';
    }
  }

  /// Cierra el servicio y libera recursos.
  ///
  /// Debe llamarse cuando la aplicación se cierra para evitar memory leaks.
  void dispose() {
    AppLogger.info('Cerrando ConnectivityService');
    _connectivitySubscription?.cancel();
    _connectionController.close();
  }
}



