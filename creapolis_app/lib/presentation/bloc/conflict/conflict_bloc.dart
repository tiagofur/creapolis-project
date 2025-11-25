import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../core/sync/conflict_resolution_service.dart';
import '../../../domain/entities/sync_conflict.dart';
import 'conflict_event.dart';
import 'conflict_state.dart';

/// BLoC for managing sync conflict resolution UI
@injectable
class ConflictBloc extends Bloc<ConflictEvent, ConflictState> {
  final ConflictResolutionService _conflictService;

  ConflictBloc(this._conflictService) : super(const ConflictInitial()) {
    on<LoadPendingConflicts>(_onLoadPendingConflicts);
    on<LoadResolvedConflicts>(_onLoadResolvedConflicts);
    on<LoadConflictDetails>(_onLoadConflictDetails);
    on<ResolveConflict>(_onResolveConflict);
    on<ResolveAllConflicts>(_onResolveAllConflicts);
    on<UpdateConflictConfig>(_onUpdateConflictConfig);
    on<CleanupOldConflicts>(_onCleanupOldConflicts);
    on<DismissConflict>(_onDismissConflict);
  }

  /// Load pending conflicts
  Future<void> _onLoadPendingConflicts(
    LoadPendingConflicts event,
    Emitter<ConflictState> emit,
  ) async {
    emit(const ConflictLoading());

    try {
      final conflicts = _conflictService.getPendingConflicts();
      final config = _conflictService.config;

      if (conflicts.isEmpty) {
        emit(const NoConflicts());
      } else {
        emit(
          PendingConflictsLoaded(
            conflicts: conflicts,
            totalCount: conflicts.length,
            config: config,
          ),
        );
      }
    } catch (e) {
      emit(ConflictError('Error cargando conflictos: $e'));
    }
  }

  /// Load resolved conflicts history
  Future<void> _onLoadResolvedConflicts(
    LoadResolvedConflicts event,
    Emitter<ConflictState> emit,
  ) async {
    emit(const ConflictLoading());

    try {
      final conflicts = _conflictService.getResolvedConflicts(
        limit: event.limit,
      );
      emit(ResolvedConflictsLoaded(conflicts));
    } catch (e) {
      emit(ConflictError('Error cargando historial: $e'));
    }
  }

  /// Load conflict details
  Future<void> _onLoadConflictDetails(
    LoadConflictDetails event,
    Emitter<ConflictState> emit,
  ) async {
    emit(const ConflictLoading());

    try {
      final conflict = _conflictService.getConflictById(event.conflictId);

      if (conflict == null) {
        emit(const ConflictError('Conflicto no encontrado'));
        return;
      }

      // Build conflicting fields with details
      final conflictingFields = _buildConflictingFields(conflict);

      emit(
        ConflictDetailsLoaded(
          conflict: conflict,
          conflictingFields: conflictingFields,
        ),
      );
    } catch (e) {
      emit(ConflictError('Error cargando detalles: $e'));
    }
  }

  /// Resolve a single conflict
  Future<void> _onResolveConflict(
    ResolveConflict event,
    Emitter<ConflictState> emit,
  ) async {
    emit(const ConflictLoading());

    try {
      final resolved = await _conflictService.resolveConflict(
        conflictId: event.conflictId,
        strategy: event.strategy,
        customMergedData: event.customMergedData,
      );

      if (resolved == null) {
        emit(const ConflictError('No se pudo resolver el conflicto'));
        return;
      }

      final strategyName = _getStrategyDisplayName(event.strategy);
      emit(
        ConflictResolved(
          resolvedConflict: resolved,
          message: 'Conflicto resuelto: $strategyName',
        ),
      );

      // Reload pending conflicts
      add(const LoadPendingConflicts());
    } catch (e) {
      emit(ConflictError('Error resolviendo conflicto: $e'));
    }
  }

  /// Resolve all pending conflicts
  Future<void> _onResolveAllConflicts(
    ResolveAllConflicts event,
    Emitter<ConflictState> emit,
  ) async {
    emit(const ConflictLoading());

    try {
      final resolvedCount = await _conflictService.resolveAllConflicts(
        event.strategy,
      );

      final strategyName = _getStrategyDisplayName(event.strategy);
      emit(
        AllConflictsResolved(
          resolvedCount: resolvedCount,
          message: '$resolvedCount conflictos resueltos con $strategyName',
        ),
      );

      // Reload pending conflicts
      add(const LoadPendingConflicts());
    } catch (e) {
      emit(ConflictError('Error resolviendo todos los conflictos: $e'));
    }
  }

  /// Update conflict resolution config
  Future<void> _onUpdateConflictConfig(
    UpdateConflictConfig event,
    Emitter<ConflictState> emit,
  ) async {
    try {
      _conflictService.setConfig(event.config);
      emit(ConflictConfigUpdated(event.config));

      // Reload with new config
      add(const LoadPendingConflicts());
    } catch (e) {
      emit(ConflictError('Error actualizando configuración: $e'));
    }
  }

  /// Clean up old resolved conflicts
  Future<void> _onCleanupOldConflicts(
    CleanupOldConflicts event,
    Emitter<ConflictState> emit,
  ) async {
    try {
      await _conflictService.cleanupOldConflicts(daysOld: event.daysOld);
      emit(OldConflictsCleaned(event.daysOld));
    } catch (e) {
      emit(ConflictError('Error limpiando conflictos antiguos: $e'));
    }
  }

  /// Dismiss a conflict (resolve with server wins)
  Future<void> _onDismissConflict(
    DismissConflict event,
    Emitter<ConflictState> emit,
  ) async {
    // Dismiss = accept server version
    add(
      ResolveConflict(
        conflictId: event.conflictId,
        strategy: ConflictResolutionStrategy.serverWins,
      ),
    );
  }

  /// Build list of conflicting fields with display info
  List<ConflictingField> _buildConflictingFields(SyncConflict conflict) {
    final fields = <ConflictingField>[];

    for (final fieldName in conflict.conflictingFields) {
      final displayLabel = _getFieldDisplayLabel(fieldName);
      final fieldType = _getFieldType(fieldName);

      fields.add(
        ConflictingField(
          fieldName: fieldName,
          displayLabel: displayLabel,
          clientValue: conflict.clientVersion[fieldName],
          serverValue: conflict.serverVersion[fieldName],
          baseValue: conflict.baseVersion?[fieldName],
          fieldType: fieldType,
        ),
      );
    }

    return fields;
  }

  /// Get display label for a field
  String _getFieldDisplayLabel(String fieldName) {
    const labels = {
      'title': 'Título',
      'name': 'Nombre',
      'description': 'Descripción',
      'status': 'Estado',
      'priority': 'Prioridad',
      'startDate': 'Fecha inicio',
      'endDate': 'Fecha fin',
      'estimatedHours': 'Horas estimadas',
      'assignedUserId': 'Asignado a',
      'managerId': 'Manager',
      'progress': 'Progreso',
    };
    return labels[fieldName] ?? fieldName;
  }

  /// Get field type for display
  String _getFieldType(String fieldName) {
    const dateFields = {'startDate', 'endDate', 'createdAt', 'updatedAt'};
    const numberFields = {
      'estimatedHours',
      'progress',
      'assignedUserId',
      'managerId',
    };

    if (dateFields.contains(fieldName)) return 'date';
    if (numberFields.contains(fieldName)) return 'number';
    return 'string';
  }

  /// Get display name for resolution strategy
  String _getStrategyDisplayName(ConflictResolutionStrategy strategy) {
    switch (strategy) {
      case ConflictResolutionStrategy.serverWins:
        return 'Servidor gana';
      case ConflictResolutionStrategy.clientWins:
        return 'Local gana';
      case ConflictResolutionStrategy.merge:
        return 'Fusión automática';
      case ConflictResolutionStrategy.keepBoth:
        return 'Mantener ambos';
      case ConflictResolutionStrategy.manual:
        return 'Selección manual';
    }
  }
}
