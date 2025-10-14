/// Estados posibles de sincronización
enum SyncState {
  /// Estado inactivo - no hay sincronización en progreso
  idle,

  /// Sincronización en progreso
  syncing,

  /// Sincronización completada
  completed,

  /// Error en sincronización
  error,

  /// Operación encolada (sin conexión)
  operationQueued,
}

/// Información del estado de sincronización
class SyncStatus {
  /// Estado actual de sincronización
  final SyncState state;

  /// Mensaje descriptivo (opcional)
  final String? message;

  /// Total de operaciones a sincronizar
  final int? total;

  /// Operaciones completadas
  final int? completed;

  /// Operaciones fallidas
  final int? failed;

  const SyncStatus({
    required this.state,
    this.message,
    this.total,
    this.completed,
    this.failed,
  });

  /// Constructor para estado idle
  factory SyncStatus.idle() {
    return const SyncStatus(state: SyncState.idle);
  }

  /// Constructor para estado syncing
  factory SyncStatus.syncing({
    required int total,
    int completed = 0,
    String? message,
  }) {
    return SyncStatus(
      state: SyncState.syncing,
      total: total,
      completed: completed,
      message: message,
    );
  }

  /// Constructor para estado completed
  factory SyncStatus.completed({
    required int completed,
    int failed = 0,
    String? message,
  }) {
    return SyncStatus(
      state: SyncState.completed,
      completed: completed,
      failed: failed,
      message: message,
    );
  }

  /// Constructor para estado error
  factory SyncStatus.error(String message) {
    return SyncStatus(
      state: SyncState.error,
      message: message,
    );
  }

  /// Constructor para operación encolada
  factory SyncStatus.operationQueued(String message) {
    return SyncStatus(
      state: SyncState.operationQueued,
      message: message,
    );
  }

  @override
  String toString() {
    return 'SyncStatus(state: $state, message: $message, total: $total, completed: $completed, failed: $failed)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SyncStatus &&
        other.state == state &&
        other.message == message &&
        other.total == total &&
        other.completed == completed &&
        other.failed == failed;
  }

  @override
  int get hashCode {
    return state.hashCode ^
        message.hashCode ^
        total.hashCode ^
        completed.hashCode ^
        failed.hashCode;
  }
}
