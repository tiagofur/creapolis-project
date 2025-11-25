import 'package:equatable/equatable.dart';
import '../../../domain/entities/sync_conflict.dart';

/// Events for Conflict Resolution BLoC
abstract class ConflictEvent extends Equatable {
  const ConflictEvent();

  @override
  List<Object?> get props => [];
}

/// Load pending conflicts
class LoadPendingConflicts extends ConflictEvent {
  const LoadPendingConflicts();
}

/// Load resolved conflicts history
class LoadResolvedConflicts extends ConflictEvent {
  final int limit;

  const LoadResolvedConflicts({this.limit = 50});

  @override
  List<Object?> get props => [limit];
}

/// Load a specific conflict by ID
class LoadConflictDetails extends ConflictEvent {
  final String conflictId;

  const LoadConflictDetails(this.conflictId);

  @override
  List<Object?> get props => [conflictId];
}

/// Resolve a conflict
class ResolveConflict extends ConflictEvent {
  final String conflictId;
  final ConflictResolutionStrategy strategy;
  final Map<String, dynamic>? customMergedData;

  const ResolveConflict({
    required this.conflictId,
    required this.strategy,
    this.customMergedData,
  });

  @override
  List<Object?> get props => [conflictId, strategy, customMergedData];
}

/// Resolve all pending conflicts with a strategy
class ResolveAllConflicts extends ConflictEvent {
  final ConflictResolutionStrategy strategy;

  const ResolveAllConflicts(this.strategy);

  @override
  List<Object?> get props => [strategy];
}

/// Update conflict resolution configuration
class UpdateConflictConfig extends ConflictEvent {
  final ConflictResolutionConfig config;

  const UpdateConflictConfig(this.config);

  @override
  List<Object?> get props => [config];
}

/// Clean up old resolved conflicts
class CleanupOldConflicts extends ConflictEvent {
  final int daysOld;

  const CleanupOldConflicts({this.daysOld = 7});

  @override
  List<Object?> get props => [daysOld];
}

/// Dismiss a conflict (mark as resolved without action)
class DismissConflict extends ConflictEvent {
  final String conflictId;

  const DismissConflict(this.conflictId);

  @override
  List<Object?> get props => [conflictId];
}
