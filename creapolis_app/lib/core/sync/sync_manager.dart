import 'dart:async';
import 'dart:convert';
import 'package:injectable/injectable.dart';
import '../../data/models/hive/hive_operation_queue.dart';
import '../../core/database/hive_manager.dart';
import '../services/connectivity_service.dart';
import '../utils/app_logger.dart';
import 'sync_operation_executor.dart';
import 'sync_status.dart';

/// Manager de sincronización automática
///
/// Coordina la sincronización de operaciones pendientes cuando
/// se recupera la conexión. Se inicializa automáticamente en main.dart
/// y escucha cambios de conectividad.
///
/// Características:
/// - Auto-detección de conectividad
/// - Ejecución FIFO (First In First Out) de operaciones
/// - Retry logic (máximo 3 intentos por operación)
/// - Stream de estado para la UI
@lazySingleton
class SyncManager {
  final ConnectivityService _connectivityService;
  final SyncOperationExecutor _executor;

  // Stream controller para emitir estado de sincronización
  final _syncStatusController = StreamController<SyncStatus>.broadcast();

  // Suscripción al stream de conectividad
  StreamSubscription<bool>? _connectivitySubscription;

  // Flag para prevenir múltiples syncs simultáneos
  bool _isSyncing = false;

  SyncManager(
    this._connectivityService,
    this._executor,
  );

  /// Stream que emite el estado de sincronización
  ///
  /// La UI puede escuchar este stream para mostrar progreso,
  /// errores, o completitud de sincronización.
  ///
  /// Ejemplo:
  /// ```dart
  /// syncManager.syncStatusStream.listen((status) {
  ///   if (status.state == SyncState.syncing) {
  ///     print('Sincronizando ${status.completed}/${status.total}');
  ///   }
  /// });
  /// ```
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  /// Verificar si hay sincronización en progreso
  bool get isSyncing => _isSyncing;

  /// Obtener número de operaciones pendientes
  int get pendingOperationsCount {
    try {
      final queue = HiveManager.operationQueue;
      return queue.values.where((op) => !op.isCompleted).length;
    } catch (e) {
      AppLogger.error('Error obteniendo pendingOperationsCount', e);
      return 0;
    }
  }

  /// Obtener número de operaciones fallidas
  int get failedOperationsCount {
    try {
      final queue = HiveManager.operationQueue;
      return queue.values.where((op) => op.isFailed).length;
    } catch (e) {
      AppLogger.error('Error obteniendo failedOperationsCount', e);
      return 0;
    }
  }

  /// Iniciar auto-sincronización
  ///
  /// Debe llamarse en main.dart después de inicializar la app.
  /// Escucha cambios de conectividad y sincroniza automáticamente
  /// cuando se recupera la conexión.
  ///
  /// Ejemplo:
  /// ```dart
  /// // En main.dart
  /// await HiveManager.init();
  /// final syncManager = getIt<SyncManager>();
  /// syncManager.startAutoSync();
  /// ```
  void startAutoSync() {
    AppLogger.info('SyncManager: Iniciando auto-sync');

    // Emitir estado inicial
    _syncStatusController.add(SyncStatus.idle());

    // Escuchar cambios de conectividad
    _connectivitySubscription =
        _connectivityService.connectionStream.listen((isConnected) {
      if (isConnected) {
        AppLogger.info(
          'SyncManager: Conexión restaurada, iniciando sincronización',
        );
        syncPendingOperations();
      } else {
        AppLogger.info('SyncManager: Conexión perdida');
      }
    });

    AppLogger.info('SyncManager: Auto-sync activado');
  }

  /// Detener auto-sincronización
  ///
  /// Libera recursos. Debe llamarse al cerrar la app.
  void stopAutoSync() {
    AppLogger.info('SyncManager: Deteniendo auto-sync');
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// Encolar una operación para sincronización posterior
  ///
  /// Se usa cuando el usuario realiza una acción offline.
  /// La operación se guarda en Hive y se ejecutará cuando
  /// se recupere la conexión.
  ///
  /// Ejemplo:
  /// ```dart
  /// await syncManager.queueOperation(
  ///   type: 'create_workspace',
  ///   data: {'name': 'Mi Workspace', 'description': '...'},
  /// );
  /// ```
  Future<void> queueOperation({
    required String type,
    required Map<String, dynamic> data,
  }) async {
    try {
      AppLogger.info('SyncManager: Encolando operación $type');

      final operation = HiveOperationQueue(
        id: '${type}_${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        data: jsonEncode(data),
        timestamp: DateTime.now(),
        retries: 0,
        isCompleted: false,
      );

      final queue = HiveManager.operationQueue;
      await queue.put(operation.id, operation);

      // Emitir evento de operación encolada
      _syncStatusController.add(
        SyncStatus.operationQueued('Operación $type encolada'),
      );

      AppLogger.info('SyncManager: Operación encolada exitosamente - $type');
    } catch (e, stackTrace) {
      AppLogger.error('SyncManager: Error encolando operación', e, stackTrace);
    }
  }

  /// Sincronizar todas las operaciones pendientes
  ///
  /// Ejecuta todas las operaciones en la cola en orden FIFO
  /// (First In First Out). Gestiona reintentos y actualiza
  /// el estado a través del stream.
  ///
  /// Retorna el número de operaciones sincronizadas exitosamente.
  Future<int> syncPendingOperations() async {
    // Prevenir múltiples syncs simultáneos
    if (_isSyncing) {
      AppLogger.info('SyncManager: Ya hay una sincronización en progreso');
      return 0;
    }

    _isSyncing = true;

    try {
      AppLogger.info('SyncManager: Iniciando sincronización de operaciones');

      // Verificar conectividad
      final isConnected = await _connectivityService.isConnected;
      if (!isConnected) {
        AppLogger.info(
          'SyncManager: Sin conexión, cancelando sincronización',
        );
        _syncStatusController.add(SyncStatus.idle());
        return 0;
      }

      // Obtener operaciones pendientes
      final queue = HiveManager.operationQueue;
      final pendingOps = queue.values
          .where((op) => !op.isCompleted && op.shouldRetry)
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp)); // FIFO

      if (pendingOps.isEmpty) {
        AppLogger.info('SyncManager: No hay operaciones pendientes');
        _syncStatusController.add(SyncStatus.idle());
        return 0;
      }

      AppLogger.info(
        'SyncManager: ${pendingOps.length} operaciones pendientes',
      );

      // Emitir estado de sincronización iniciada
      _syncStatusController.add(SyncStatus.syncing(
        total: pendingOps.length,
        completed: 0,
      ));

      int completed = 0;
      int failed = 0;

      // Ejecutar cada operación
      for (final op in pendingOps) {
        try {
          AppLogger.info('SyncManager: Ejecutando ${op.type} (${op.id})');

          final success = await _executor.executeOperation(op);

          if (success) {
            // Marcar como completada y eliminar de la cola
            await op.markAsCompleted();
            await op.delete();
            completed++;

            AppLogger.info(
              'SyncManager: ✅ Operación ${op.type} completada exitosamente',
            );
          } else {
            // Incrementar reintentos
            await op.incrementRetries(
              errorMessage: 'Falló ejecución en intento ${op.retries + 1}',
            );
            failed++;

            AppLogger.warning(
              'SyncManager: ⚠️ Operación ${op.type} falló (intento ${op.retries}/3)',
            );

            // Si llegó al máximo de reintentos, marcar como completada (fallida)
            if (op.retries >= 3) {
              await op.markAsCompleted();
              AppLogger.error(
                'SyncManager: ❌ Operación ${op.type} falló después de 3 intentos',
              );
            }
          }

          // Emitir progreso
          _syncStatusController.add(SyncStatus.syncing(
            total: pendingOps.length,
            completed: completed,
          ));
        } catch (e, stackTrace) {
          AppLogger.error(
            'SyncManager: Error ejecutando operación ${op.type}',
            e,
            stackTrace,
          );
          await op.incrementRetries(errorMessage: e.toString());
          failed++;
        }
      }

      // Emitir estado completado
      _syncStatusController.add(SyncStatus.completed(
        completed: completed,
        failed: failed,
      ));

      AppLogger.info(
        'SyncManager: Sincronización completada - $completed OK, $failed fallos',
      );

      return completed;
    } catch (e, stackTrace) {
      AppLogger.error(
        'SyncManager: Error en sincronización general',
        e,
        stackTrace,
      );
      _syncStatusController.add(
        SyncStatus.error('Error en sincronización: $e'),
      );
      return 0;
    } finally {
      _isSyncing = false;
    }
  }

  /// Limpiar operaciones fallidas de la cola
  ///
  /// Elimina operaciones que fallaron después de 3 intentos.
  /// Útil para limpiar la cola manualmente desde la UI.
  Future<void> clearFailedOperations() async {
    try {
      AppLogger.info('SyncManager: Limpiando operaciones fallidas');

      final queue = HiveManager.operationQueue;
      final failedOps = queue.values.where((op) => op.isFailed).toList();

      for (final op in failedOps) {
        await op.delete();
      }

      AppLogger.info(
        'SyncManager: ${failedOps.length} operaciones fallidas eliminadas',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'SyncManager: Error limpiando operaciones fallidas',
        e,
        stackTrace,
      );
    }
  }

  /// Limpiar TODAS las operaciones de la cola
  ///
  /// ⚠️ PELIGROSO: Elimina todas las operaciones pendientes,
  /// incluyendo las que aún pueden sincronizarse.
  /// Solo usar en casos especiales (ej: logout, testing).
  Future<void> clearAllOperations() async {
    try {
      AppLogger.warning('SyncManager: Limpiando TODAS las operaciones');

      final queue = HiveManager.operationQueue;
      await queue.clear();

      _syncStatusController.add(SyncStatus.idle());

      AppLogger.info('SyncManager: Todas las operaciones eliminadas');
    } catch (e, stackTrace) {
      AppLogger.error(
        'SyncManager: Error limpiando todas las operaciones',
        e,
        stackTrace,
      );
    }
  }

  /// Obtener lista de operaciones pendientes para mostrar en UI
  List<HiveOperationQueue> getPendingOperations() {
    try {
      final queue = HiveManager.operationQueue;
      return queue.values
          .where((op) => !op.isCompleted)
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    } catch (e) {
      AppLogger.error('Error obteniendo operaciones pendientes', e);
      return [];
    }
  }

  /// Obtener lista de operaciones fallidas para mostrar en UI
  List<HiveOperationQueue> getFailedOperations() {
    try {
      final queue = HiveManager.operationQueue;
      return queue.values
          .where((op) => op.isFailed)
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    } catch (e) {
      AppLogger.error('Error obteniendo operaciones fallidas', e);
      return [];
    }
  }

  /// Liberar recursos
  ///
  /// Debe llamarse al cerrar la app para evitar memory leaks.
  void dispose() {
    AppLogger.info('SyncManager: Liberando recursos');
    stopAutoSync();
    _syncStatusController.close();
  }
}
