import 'package:equatable/equatable.dart';

/// Tipo de conflicto detectado durante sincronización
enum ConflictType {
  /// Ambas partes modificaron el mismo recurso
  updateConflict,

  /// Cliente actualizó pero servidor eliminó
  deleteConflict,

  /// Cliente creó pero ya existe en servidor
  duplicateConflict,

  /// Dependencia circular o recurso padre eliminado
  dependencyConflict,
}

/// Estrategia de resolución de conflictos
enum ConflictResolutionStrategy {
  /// El servidor gana automáticamente
  serverWins,

  /// El cliente gana automáticamente
  clientWins,

  /// Requiere intervención manual del usuario
  manual,

  /// Fusionar cambios (merge)
  merge,

  /// Crear copia del cliente como nuevo recurso
  keepBoth,
}

/// Tipo de recurso en conflicto
enum ConflictResourceType {
  workspace,
  project,
  task,
  comment,
  customFieldValue,
}

/// Representa un conflicto de sincronización detectado
class SyncConflict extends Equatable {
  /// ID único del conflicto
  final String id;

  /// Tipo de conflicto
  final ConflictType type;

  /// Tipo de recurso en conflicto
  final ConflictResourceType resourceType;

  /// ID del recurso en conflicto
  final int resourceId;

  /// ID del workspace (para contexto)
  final int? workspaceId;

  /// ID del proyecto (para contexto)
  final int? projectId;

  /// Versión del cliente (datos locales)
  final Map<String, dynamic> clientVersion;

  /// Versión del servidor (datos remotos)
  final Map<String, dynamic> serverVersion;

  /// Versión base (antes de cambios locales, si se tiene)
  final Map<String, dynamic>? baseVersion;

  /// Timestamp cuando el cliente modificó
  final DateTime clientModifiedAt;

  /// Timestamp cuando el servidor modificó
  final DateTime serverModifiedAt;

  /// ID del usuario que modificó en servidor
  final int? serverModifiedBy;

  /// Nombre del usuario que modificó en servidor
  final String? serverModifiedByName;

  /// Campos específicos en conflicto
  final List<String> conflictingFields;

  /// Estrategia de resolución elegida (null si aún no se resuelve)
  final ConflictResolutionStrategy? resolution;

  /// Datos resultantes de la resolución
  final Map<String, dynamic>? resolvedData;

  /// Timestamp de detección del conflicto
  final DateTime detectedAt;

  /// Timestamp de resolución (null si no resuelto)
  final DateTime? resolvedAt;

  /// Mensaje de error adicional
  final String? errorMessage;

  /// Si el conflicto está resuelto
  bool get isResolved => resolution != null && resolvedAt != null;

  /// Nombre legible del tipo de recurso
  String get resourceTypeName {
    switch (resourceType) {
      case ConflictResourceType.workspace:
        return 'Workspace';
      case ConflictResourceType.project:
        return 'Proyecto';
      case ConflictResourceType.task:
        return 'Tarea';
      case ConflictResourceType.comment:
        return 'Comentario';
      case ConflictResourceType.customFieldValue:
        return 'Campo personalizado';
    }
  }

  /// Título del recurso (del cliente)
  String get resourceTitle {
    return clientVersion['title'] as String? ??
        clientVersion['name'] as String? ??
        'Sin título';
  }

  /// Descripción corta del conflicto
  String get shortDescription {
    switch (type) {
      case ConflictType.updateConflict:
        return '$resourceTypeName modificado por ambas partes';
      case ConflictType.deleteConflict:
        return '$resourceTypeName eliminado en servidor pero modificado localmente';
      case ConflictType.duplicateConflict:
        return '$resourceTypeName ya existe en servidor';
      case ConflictType.dependencyConflict:
        return 'Conflicto de dependencias en $resourceTypeName';
    }
  }

  const SyncConflict({
    required this.id,
    required this.type,
    required this.resourceType,
    required this.resourceId,
    this.workspaceId,
    this.projectId,
    required this.clientVersion,
    required this.serverVersion,
    this.baseVersion,
    required this.clientModifiedAt,
    required this.serverModifiedAt,
    this.serverModifiedBy,
    this.serverModifiedByName,
    required this.conflictingFields,
    this.resolution,
    this.resolvedData,
    required this.detectedAt,
    this.resolvedAt,
    this.errorMessage,
  });

  /// Crear copia con resolución aplicada
  SyncConflict copyWithResolution({
    required ConflictResolutionStrategy resolution,
    required Map<String, dynamic> resolvedData,
  }) {
    return SyncConflict(
      id: id,
      type: type,
      resourceType: resourceType,
      resourceId: resourceId,
      workspaceId: workspaceId,
      projectId: projectId,
      clientVersion: clientVersion,
      serverVersion: serverVersion,
      baseVersion: baseVersion,
      clientModifiedAt: clientModifiedAt,
      serverModifiedAt: serverModifiedAt,
      serverModifiedBy: serverModifiedBy,
      serverModifiedByName: serverModifiedByName,
      conflictingFields: conflictingFields,
      resolution: resolution,
      resolvedData: resolvedData,
      detectedAt: detectedAt,
      resolvedAt: DateTime.now(),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    resourceType,
    resourceId,
    workspaceId,
    projectId,
    clientModifiedAt,
    serverModifiedAt,
    resolution,
    resolvedAt,
  ];
}

/// Resultado de la detección de conflictos para una operación
class ConflictDetectionResult extends Equatable {
  /// Si hay conflicto
  final bool hasConflict;

  /// El conflicto detectado (null si no hay conflicto)
  final SyncConflict? conflict;

  /// Si la operación puede proceder sin intervención
  final bool canProceed;

  /// Mensaje informativo
  final String? message;

  const ConflictDetectionResult({
    required this.hasConflict,
    this.conflict,
    required this.canProceed,
    this.message,
  });

  /// Sin conflicto, puede proceder
  factory ConflictDetectionResult.noConflict() {
    return const ConflictDetectionResult(hasConflict: false, canProceed: true);
  }

  /// Conflicto detectado
  factory ConflictDetectionResult.withConflict(SyncConflict conflict) {
    return ConflictDetectionResult(
      hasConflict: true,
      conflict: conflict,
      canProceed: false,
      message: conflict.shortDescription,
    );
  }

  /// Conflicto resuelto automáticamente
  factory ConflictDetectionResult.autoResolved({
    required SyncConflict conflict,
    required String message,
  }) {
    return ConflictDetectionResult(
      hasConflict: true,
      conflict: conflict,
      canProceed: true,
      message: message,
    );
  }

  @override
  List<Object?> get props => [hasConflict, conflict, canProceed, message];
}

/// Configuración de resolución de conflictos por tipo de recurso
class ConflictResolutionConfig extends Equatable {
  /// Estrategia para conflictos de actualización
  final ConflictResolutionStrategy updateStrategy;

  /// Estrategia para conflictos de eliminación
  final ConflictResolutionStrategy deleteStrategy;

  /// Estrategia para conflictos de duplicados
  final ConflictResolutionStrategy duplicateStrategy;

  /// Estrategia para conflictos de dependencias
  final ConflictResolutionStrategy dependencyStrategy;

  /// Si mostrar notificación en resolución automática
  final bool notifyOnAutoResolve;

  const ConflictResolutionConfig({
    this.updateStrategy = ConflictResolutionStrategy.manual,
    this.deleteStrategy = ConflictResolutionStrategy.serverWins,
    this.duplicateStrategy = ConflictResolutionStrategy.keepBoth,
    this.dependencyStrategy = ConflictResolutionStrategy.serverWins,
    this.notifyOnAutoResolve = true,
  });

  /// Configuración por defecto (manual para updates, servidor para deletes)
  factory ConflictResolutionConfig.defaultConfig() {
    return const ConflictResolutionConfig();
  }

  /// Configuración agresiva cliente (cliente siempre gana)
  factory ConflictResolutionConfig.clientWins() {
    return const ConflictResolutionConfig(
      updateStrategy: ConflictResolutionStrategy.clientWins,
      deleteStrategy: ConflictResolutionStrategy.clientWins,
      duplicateStrategy: ConflictResolutionStrategy.clientWins,
      dependencyStrategy: ConflictResolutionStrategy.clientWins,
    );
  }

  /// Configuración agresiva servidor (servidor siempre gana)
  factory ConflictResolutionConfig.serverWins() {
    return const ConflictResolutionConfig(
      updateStrategy: ConflictResolutionStrategy.serverWins,
      deleteStrategy: ConflictResolutionStrategy.serverWins,
      duplicateStrategy: ConflictResolutionStrategy.serverWins,
      dependencyStrategy: ConflictResolutionStrategy.serverWins,
    );
  }

  /// Obtener estrategia para un tipo de conflicto
  ConflictResolutionStrategy getStrategyForConflictType(ConflictType type) {
    switch (type) {
      case ConflictType.updateConflict:
        return updateStrategy;
      case ConflictType.deleteConflict:
        return deleteStrategy;
      case ConflictType.duplicateConflict:
        return duplicateStrategy;
      case ConflictType.dependencyConflict:
        return dependencyStrategy;
    }
  }

  @override
  List<Object?> get props => [
    updateStrategy,
    deleteStrategy,
    duplicateStrategy,
    dependencyStrategy,
    notifyOnAutoResolve,
  ];
}

/// Campo en conflicto con sus valores
class ConflictingField extends Equatable {
  /// Nombre del campo
  final String fieldName;

  /// Etiqueta para mostrar en UI
  final String displayLabel;

  /// Valor del cliente
  final dynamic clientValue;

  /// Valor del servidor
  final dynamic serverValue;

  /// Valor base (antes de modificaciones)
  final dynamic baseValue;

  /// Tipo de dato del campo
  final String fieldType;

  const ConflictingField({
    required this.fieldName,
    required this.displayLabel,
    required this.clientValue,
    required this.serverValue,
    this.baseValue,
    this.fieldType = 'string',
  });

  /// Si el cliente modificó el campo desde la base
  bool get clientModified => baseValue != null && clientValue != baseValue;

  /// Si el servidor modificó el campo desde la base
  bool get serverModified => baseValue != null && serverValue != baseValue;

  @override
  List<Object?> get props => [
    fieldName,
    displayLabel,
    clientValue,
    serverValue,
    baseValue,
    fieldType,
  ];
}
