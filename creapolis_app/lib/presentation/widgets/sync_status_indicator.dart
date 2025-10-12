import 'package:flutter/material.dart';
import '../../core/sync/sync_manager.dart';
import '../../injection.dart';
import 'package:logger/logger.dart';

/// Widget que muestra el estado de sincronización
///
/// Escucha el stream de SyncManager y muestra una barra/snackbar
/// cuando hay sincronización en progreso.
///
/// Uso:
/// ```dart
/// Scaffold(
///   body: Column(
///     children: [
///       SyncStatusIndicator(),
///       // resto del contenido
///     ],
///   ),
/// )
/// ```
class SyncStatusIndicator extends StatefulWidget {
  /// Mostrar como barra permanente o como notificación temporal
  final bool persistent;

  /// Altura de la barra
  final double height;

  const SyncStatusIndicator({
    super.key,
    this.persistent = true,
    this.height = 4.0,
  });

  @override
  State<SyncStatusIndicator> createState() => _SyncStatusIndicatorState();
}

class _SyncStatusIndicatorState extends State<SyncStatusIndicator> {
  final SyncManager _syncManager = getIt<SyncManager>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncStatus>(
      stream: _syncManager.syncStatusStream,
      builder: (context, snapshot) {
        final status = snapshot.data;

        // Solo mostrar cuando está sincronizando
        if (status == null || status.state != SyncState.syncing) {
          return const SizedBox.shrink();
        }

        Logger().d('SyncStatusIndicator: Sincronizando...');

        if (widget.persistent) {
          // Barra de progreso persistente
          return Container(
            height: widget.height,
            child: LinearProgressIndicator(
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          );
        } else {
          // Mostrar snackbar (requiere ScaffoldMessenger)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('Sincronizando operaciones...'),
                  ],
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          });
          return const SizedBox.shrink();
        }
      },
    );
  }
}

/// Banner que muestra información detallada del estado de sincronización
class SyncStatusBanner extends StatelessWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final syncManager = getIt<SyncManager>();

    return StreamBuilder<SyncStatus>(
      stream: syncManager.syncStatusStream,
      builder: (context, snapshot) {
        final status = snapshot.data;

        if (status == null) {
          return const SizedBox.shrink();
        }

        // Determinar mensaje y color según el estado
        String message;
        Color backgroundColor;
        IconData icon;

        switch (status.state) {
          case SyncState.syncing:
            message = 'Sincronizando operaciones pendientes...';
            backgroundColor = Colors.blue;
            icon = Icons.sync;
            break;
          case SyncState.completed:
            message = 'Sincronización completada';
            backgroundColor = Colors.green;
            icon = Icons.check_circle;
            break;
          case SyncState.error:
            message = 'Error en sincronización: ${status.message}';
            backgroundColor = Colors.red;
            icon = Icons.error;
            break;
          case SyncState.operationQueued:
            message = 'Operación en cola (sin conexión)';
            backgroundColor = Colors.orange;
            icon = Icons.cloud_off;
            break;
          case SyncState.idle:
            return const SizedBox.shrink(); // No mostrar nada en idle
        }

        Logger().i('SyncStatusBanner: $message');

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: backgroundColor,
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              if (status.state == SyncState.syncing)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Diálogo que muestra progreso detallado de sincronización
class SyncProgressDialog extends StatelessWidget {
  const SyncProgressDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const SyncProgressDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final syncManager = getIt<SyncManager>();

    return StreamBuilder<SyncStatus>(
      stream: syncManager.syncStatusStream,
      builder: (context, snapshot) {
        final status = snapshot.data;
        final pendingCount = syncManager.pendingOperationsCount;
        final failedCount = syncManager.failedOperationsCount;

        // Auto-cerrar cuando termine
        if (status != null &&
            status.state == SyncState.completed &&
            pendingCount == 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pop();
          });
        }

        return AlertDialog(
          title: const Text('Sincronización'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (status != null) ...[
                if (status.state == SyncState.syncing) ...[
                  const LinearProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Sincronizando operaciones pendientes...'),
                ] else if (status.state == SyncState.completed) ...[
                  const Icon(Icons.check_circle, color: Colors.green, size: 48),
                  const SizedBox(height: 16),
                  const Text('¡Sincronización completada!'),
                ] else if (status.state == SyncState.error) ...[
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: ${status.message}'),
                ],
              ],
              const SizedBox(height: 16),
              Text('Pendientes: $pendingCount'),
              Text('Fallidas: $failedCount'),
            ],
          ),
          actions: [
            if (status == null || status.state != SyncState.syncing)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
          ],
        );
      },
    );
  }
}
