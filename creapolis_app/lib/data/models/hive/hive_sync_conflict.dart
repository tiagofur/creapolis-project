import 'dart:convert';
import 'package:hive/hive.dart';

part 'hive_sync_conflict.g.dart';

/// Modelo Hive para almacenar conflictos de sincronización pendientes
/// Los conflictos que requieren resolución manual se almacenan aquí
@HiveType(typeId: 11)
class HiveSyncConflict extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String type; // 'updateConflict', 'deleteConflict', 'duplicateConflict', 'dependencyConflict'

  @HiveField(2)
  String resourceType; // 'workspace', 'project', 'task', 'comment', 'customFieldValue'

  @HiveField(3)
  int resourceId;

  @HiveField(4)
  int? workspaceId;

  @HiveField(5)
  int? projectId;

  @HiveField(6)
  String clientVersionJson; // JSON encoded

  @HiveField(7)
  String serverVersionJson; // JSON encoded

  @HiveField(8)
  String? baseVersionJson; // JSON encoded (nullable)

  @HiveField(9)
  DateTime clientModifiedAt;

  @HiveField(10)
  DateTime serverModifiedAt;

  @HiveField(11)
  int? serverModifiedBy;

  @HiveField(12)
  String? serverModifiedByName;

  @HiveField(13)
  String conflictingFieldsJson; // JSON encoded list

  @HiveField(14)
  String? resolution; // 'serverWins', 'clientWins', 'manual', 'merge', 'keepBoth'

  @HiveField(15)
  String? resolvedDataJson; // JSON encoded

  @HiveField(16)
  DateTime detectedAt;

  @HiveField(17)
  DateTime? resolvedAt;

  @HiveField(18)
  String? errorMessage;

  @HiveField(19)
  String operationId; // ID de la operación que causó el conflicto

  HiveSyncConflict({
    required this.id,
    required this.type,
    required this.resourceType,
    required this.resourceId,
    this.workspaceId,
    this.projectId,
    required this.clientVersionJson,
    required this.serverVersionJson,
    this.baseVersionJson,
    required this.clientModifiedAt,
    required this.serverModifiedAt,
    this.serverModifiedBy,
    this.serverModifiedByName,
    required this.conflictingFieldsJson,
    this.resolution,
    this.resolvedDataJson,
    required this.detectedAt,
    this.resolvedAt,
    this.errorMessage,
    required this.operationId,
  });

  /// Si el conflicto está resuelto
  bool get isResolved => resolution != null && resolvedAt != null;

  /// Obtener versión del cliente como Map
  Map<String, dynamic> get clientVersion {
    try {
      return jsonDecode(clientVersionJson) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  /// Obtener versión del servidor como Map
  Map<String, dynamic> get serverVersion {
    try {
      return jsonDecode(serverVersionJson) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  /// Obtener versión base como Map
  Map<String, dynamic>? get baseVersion {
    if (baseVersionJson == null) return null;
    try {
      return jsonDecode(baseVersionJson!) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Obtener campos en conflicto como List
  List<String> get conflictingFields {
    try {
      return (jsonDecode(conflictingFieldsJson) as List).cast<String>();
    } catch (e) {
      return [];
    }
  }

  /// Obtener datos resueltos como Map
  Map<String, dynamic>? get resolvedData {
    if (resolvedDataJson == null) return null;
    try {
      return jsonDecode(resolvedDataJson!) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Título del recurso para mostrar
  String get resourceTitle {
    final cv = clientVersion;
    return cv['title'] as String? ?? cv['name'] as String? ?? 'Sin título';
  }

  /// Aplicar resolución
  Future<void> applyResolution({
    required String resolutionStrategy,
    required Map<String, dynamic> resolvedData,
  }) async {
    resolution = resolutionStrategy;
    resolvedDataJson = jsonEncode(resolvedData);
    resolvedAt = DateTime.now();
    await save();
  }

  /// Crear desde datos
  factory HiveSyncConflict.create({
    required String type,
    required String resourceType,
    required int resourceId,
    int? workspaceId,
    int? projectId,
    required Map<String, dynamic> clientVersion,
    required Map<String, dynamic> serverVersion,
    Map<String, dynamic>? baseVersion,
    required DateTime clientModifiedAt,
    required DateTime serverModifiedAt,
    int? serverModifiedBy,
    String? serverModifiedByName,
    required List<String> conflictingFields,
    String? errorMessage,
    required String operationId,
  }) {
    final now = DateTime.now();
    return HiveSyncConflict(
      id: 'conflict_${resourceType}_${resourceId}_${now.millisecondsSinceEpoch}',
      type: type,
      resourceType: resourceType,
      resourceId: resourceId,
      workspaceId: workspaceId,
      projectId: projectId,
      clientVersionJson: jsonEncode(clientVersion),
      serverVersionJson: jsonEncode(serverVersion),
      baseVersionJson: baseVersion != null ? jsonEncode(baseVersion) : null,
      clientModifiedAt: clientModifiedAt,
      serverModifiedAt: serverModifiedAt,
      serverModifiedBy: serverModifiedBy,
      serverModifiedByName: serverModifiedByName,
      conflictingFieldsJson: jsonEncode(conflictingFields),
      detectedAt: now,
      errorMessage: errorMessage,
      operationId: operationId,
    );
  }

  @override
  String toString() {
    return 'HiveSyncConflict(id: $id, type: $type, resourceType: $resourceType, '
        'resourceId: $resourceId, isResolved: $isResolved)';
  }
}
