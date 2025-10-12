import 'package:hive/hive.dart';

part 'hive_operation_queue.g.dart';

/// Modelo Hive para almacenar operaciones pendientes de sincronización
/// Cuando el usuario trabaja offline, las operaciones se encolan aquí
@HiveType(typeId: 10)
class HiveOperationQueue extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String type; // 'create_workspace', 'update_project', 'delete_task', etc.

  @HiveField(2)
  String data; // JSON encoded - datos de la operación

  @HiveField(3)
  DateTime timestamp;

  @HiveField(4)
  int retries;

  @HiveField(5)
  String? error; // Último error si la operación falló

  @HiveField(6)
  bool isCompleted;

  HiveOperationQueue({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
    this.retries = 0,
    this.error,
    this.isCompleted = false,
  });

  /// Crear desde datos simples
  factory HiveOperationQueue.create({
    required String type,
    required Map<String, dynamic> data,
  }) {
    return HiveOperationQueue(
      id: '${type}_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      data: _encodeData(data),
      timestamp: DateTime.now(),
      retries: 0,
      isCompleted: false,
    );
  }

  /// Encode data map to JSON string
  static String _encodeData(Map<String, dynamic> data) {
    try {
      return data.toString(); // Simplified - use jsonEncode in production
    } catch (e) {
      return '{}';
    }
  }

  /// Decode JSON string to data map
  Map<String, dynamic> getDataMap() {
    // Simplified - use jsonDecode in production
    return {}; // Placeholder
  }

  /// Marcar como completada
  Future<void> markAsCompleted() async {
    isCompleted = true;
    await save();
  }

  /// Incrementar contador de reintentos
  Future<void> incrementRetries({String? errorMessage}) async {
    retries++;
    error = errorMessage;
    await save();
  }

  /// Verificar si debe reintentarse
  bool get shouldRetry => retries < 3 && !isCompleted;

  /// Verificar si está fallida (más de 3 reintentos)
  bool get isFailed => retries >= 3 && !isCompleted;

  @override
  String toString() {
    return 'HiveOperationQueue(id: $id, type: $type, retries: $retries, isCompleted: $isCompleted)';
  }
}
