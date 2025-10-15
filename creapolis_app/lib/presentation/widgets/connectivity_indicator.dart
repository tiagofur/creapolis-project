import 'package:flutter/material.dart';
import '../../core/services/connectivity_service.dart';
import '../../injection.dart';
import 'package:logger/logger.dart';

/// Widget que muestra el estado de conectividad (online/offline)
///
/// Escucha el stream de ConnectivityService y actualiza el icono
/// en tiempo real cuando cambia la conectividad.
///
/// Uso:
/// ```dart
/// AppBar(
///   actions: [
///     ConnectivityIndicator(),
///   ],
/// )
/// ```
class ConnectivityIndicator extends StatefulWidget {
  /// Color del icono cuando está online
  final Color? onlineColor;

  /// Color del icono cuando está offline
  final Color? offlineColor;

  /// Tamaño del icono
  final double iconSize;

  /// Mostrar tooltip con el estado
  final bool showTooltip;

  const ConnectivityIndicator({
    super.key,
    this.onlineColor,
    this.offlineColor,
    this.iconSize = 24.0,
    this.showTooltip = true,
  });

  @override
  State<ConnectivityIndicator> createState() => _ConnectivityIndicatorState();
}

class _ConnectivityIndicatorState extends State<ConnectivityIndicator> {
  final ConnectivityService _connectivityService = getIt<ConnectivityService>();

  @override
  Widget build(BuildContext context) {
    final defaultOnlineColor = widget.onlineColor ?? Colors.green;
    final defaultOfflineColor = widget.offlineColor ?? Colors.red;

    return StreamBuilder<bool>(
      stream: _connectivityService.connectionStream,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? false;
        final icon = isConnected ? Icons.cloud_done : Icons.cloud_off;
        final color = isConnected ? defaultOnlineColor : defaultOfflineColor;
        final tooltipMessage = isConnected ? 'En línea' : 'Sin conexión';

        Logger().d(
          'ConnectivityIndicator: Estado = ${isConnected ? "ONLINE" : "OFFLINE"}',
        );

        final iconWidget = Icon(icon, color: color, size: widget.iconSize);

        if (widget.showTooltip) {
          return Tooltip(
            message: tooltipMessage,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: iconWidget,
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: iconWidget,
        );
      },
    );
  }
}

/// Variante compacta del indicador de conectividad
///
/// Muestra un punto de color más discreto
class ConnectivityDot extends StatelessWidget {
  final double size;
  final Color? onlineColor;
  final Color? offlineColor;

  const ConnectivityDot({
    super.key,
    this.size = 12.0,
    this.onlineColor,
    this.offlineColor,
  });

  @override
  Widget build(BuildContext context) {
    final connectivityService = getIt<ConnectivityService>();
    final defaultOnlineColor = onlineColor ?? Colors.green;
    final defaultOfflineColor = offlineColor ?? Colors.red;

    return StreamBuilder<bool>(
      stream: connectivityService.connectionStream,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? false;
        final color = isConnected ? defaultOnlineColor : defaultOfflineColor;

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}



