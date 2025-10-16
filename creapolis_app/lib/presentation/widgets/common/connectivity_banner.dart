import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Banner que muestra el estado de conectividad y sincronización
/// Inspirado en apps como Notion, Todoist, Trello que muestran estado offline/online
class ConnectivityBanner extends StatelessWidget {
  final bool isFromCache;
  final DateTime? lastSync;
  final VoidCallback? onRefresh;
  final bool isLoading;

  const ConnectivityBanner({
    super.key,
    required this.isFromCache,
    this.lastSync,
    this.onRefresh,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // No mostrar banner si los datos son frescos del servidor
    if (!isFromCache) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final now = DateTime.now();
    final syncAge = lastSync != null ? now.difference(lastSync!) : null;

    // Determinar color y mensaje según antigüedad de datos
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String message;

    if (syncAge == null) {
      // No hay información de sincronización
      backgroundColor = Colors.grey.shade100;
      textColor = Colors.grey.shade700;
      icon = Icons.cloud_off_outlined;
      message = 'Mostrando datos guardados localmente';
    } else if (syncAge.inMinutes < 5) {
      // Menos de 5 minutos - Todo OK
      backgroundColor = Colors.blue.shade50;
      textColor = Colors.blue.shade700;
      icon = Icons.cloud_done_outlined;
      message = 'Sincronizado hace ${_formatDuration(syncAge)}';
    } else if (syncAge.inHours < 1) {
      // Menos de 1 hora - Warning suave
      backgroundColor = Colors.amber.shade50;
      textColor = Colors.amber.shade700;
      icon = Icons.cloud_queue_outlined;
      message = 'Última sincronización hace ${_formatDuration(syncAge)}';
    } else {
      // Más de 1 hora - Warning fuerte
      backgroundColor = Colors.orange.shade50;
      textColor = Colors.orange.shade700;
      icon = Icons.cloud_off_outlined;
      message = 'Sin sincronizar desde ${_formatDate(lastSync!)}';
    }

    return Material(
      color: backgroundColor,
      elevation: 2,
      child: InkWell(
        onTap: isLoading ? null : onRefresh,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Icono de estado
              Icon(icon, size: 20, color: textColor),
              const SizedBox(width: 12),

              // Mensaje
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Botón de refresh
              if (onRefresh != null) ...[
                const SizedBox(width: 8),
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                else
                  IconButton(
                    icon: Icon(Icons.refresh, size: 20, color: textColor),
                    onPressed: onRefresh,
                    tooltip: 'Sincronizar ahora',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Formatea duración de manera amigable
  String _formatDuration(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inHours}h';
    }
  }

  /// Formatea fecha de manera amigable
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      // Hoy - mostrar hora
      return DateFormat('HH:mm').format(date);
    } else if (difference.inDays == 1) {
      // Ayer
      return 'ayer a las ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      // Esta semana
      return 'hace ${difference.inDays} días';
    } else {
      // Fecha completa
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}

/// Versión compacta del banner para usar en AppBar
class CompactConnectivityIndicator extends StatelessWidget {
  final bool isFromCache;
  final DateTime? lastSync;
  final VoidCallback? onTap;

  const CompactConnectivityIndicator({
    super.key,
    required this.isFromCache,
    this.lastSync,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isFromCache) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final syncAge = lastSync != null ? now.difference(lastSync!) : null;

    // Determinar color según antigüedad
    Color color;
    IconData icon;

    if (syncAge == null || syncAge.inHours > 1) {
      color = Colors.orange;
      icon = Icons.cloud_off;
    } else if (syncAge.inMinutes > 5) {
      color = Colors.amber;
      icon = Icons.cloud_queue;
    } else {
      color = Colors.green;
      icon = Icons.cloud_done;
    }

    return IconButton(
      icon: Icon(icon, color: color, size: 22),
      onPressed: onTap,
      tooltip: 'Estado de sincronización',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    );
  }
}
