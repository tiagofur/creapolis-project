import 'package:flutter/material.dart';
import '../../core/sync/sync_manager.dart';
import '../../injection.dart';
import 'package:logger/logger.dart';
import 'sync_status_indicator.dart';

/// Botón que muestra el número de operaciones pendientes de sincronización
///
/// Muestra un badge con el número de operaciones pendientes.
/// Al presionar, muestra un diálogo con detalles y opción de sincronizar manualmente.
///
/// Uso:
/// ```dart
/// AppBar(
///   actions: [
///     PendingOperationsButton(),
///   ],
/// )
/// ```
class PendingOperationsButton extends StatelessWidget {
  /// Color del badge
  final Color? badgeColor;

  /// Color del icono
  final Color? iconColor;

  /// Tamaño del icono
  final double iconSize;

  const PendingOperationsButton({
    super.key,
    this.badgeColor,
    this.iconColor,
    this.iconSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final syncManager = getIt<SyncManager>();
    final theme = Theme.of(context);
    final defaultBadgeColor = badgeColor ?? Colors.red;
    final defaultIconColor = iconColor ?? theme.iconTheme.color;

    return StreamBuilder<SyncStatus>(
      stream: syncManager.syncStatusStream,
      builder: (context, snapshot) {
        final pendingCount = syncManager.pendingOperationsCount;
        final failedCount = syncManager.failedOperationsCount;

        // No mostrar si no hay operaciones pendientes o fallidas
        if (pendingCount == 0 && failedCount == 0) {
          return const SizedBox.shrink();
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.sync_problem,
                color: defaultIconColor,
                size: iconSize,
              ),
              onPressed: () => _showOperationsDialog(context),
              tooltip: 'Operaciones pendientes',
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: defaultBadgeColor,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Center(
                  child: Text(
                    '$pendingCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showOperationsDialog(BuildContext context) {
    final syncManager = getIt<SyncManager>();
    final pendingCount = syncManager.pendingOperationsCount;
    final failedCount = syncManager.failedOperationsCount;

    Logger().i(
      'PendingOperationsButton: Mostrando diálogo - Pendientes: $pendingCount, Fallidas: $failedCount',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Operaciones Pendientes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Operaciones pendientes: $pendingCount'),
            Text('Operaciones fallidas: $failedCount'),
            const SizedBox(height: 16),
            if (pendingCount > 0)
              const Text(
                'Las operaciones se sincronizarán automáticamente cuando haya conexión.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            if (failedCount > 0)
              const Text(
                'Las operaciones fallidas necesitan ser revisadas. '
                'Puedes intentar sincronizarlas manualmente o eliminarlas.',
                style: TextStyle(fontSize: 12, color: Colors.orange),
              ),
          ],
        ),
        actions: [
          if (failedCount > 0)
            TextButton(
              onPressed: () async {
                await syncManager.clearFailedOperations();
                Logger().i(
                  'PendingOperationsButton: Operaciones fallidas eliminadas',
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Operaciones fallidas eliminadas'),
                    ),
                  );
                }
              },
              child: const Text('Limpiar Fallidas'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          if (pendingCount > 0)
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                Logger().i(
                  'PendingOperationsButton: Sincronización manual iniciada',
                );
                SyncProgressDialog.show(context);
                await syncManager.syncPendingOperations();
              },
              child: const Text('Sincronizar Ahora'),
            ),
        ],
      ),
    );
  }
}

/// Widget compacto que muestra solo el número de operaciones pendientes
class PendingOperationsBadge extends StatelessWidget {
  final Color? backgroundColor;
  final Color? textColor;

  const PendingOperationsBadge({
    super.key,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final syncManager = getIt<SyncManager>();
    final defaultBackgroundColor = backgroundColor ?? Colors.orange;
    final defaultTextColor = textColor ?? Colors.white;

    return StreamBuilder<SyncStatus>(
      stream: syncManager.syncStatusStream,
      builder: (context, snapshot) {
        final pendingCount = syncManager.pendingOperationsCount;

        if (pendingCount == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: defaultBackgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$pendingCount pendiente${pendingCount > 1 ? 's' : ''}',
            style: TextStyle(
              color: defaultTextColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
