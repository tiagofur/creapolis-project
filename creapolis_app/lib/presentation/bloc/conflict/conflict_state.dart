import 'package:equatable/equatable.dart';
import '../../../domain/entities/sync_conflict.dart';

/// States for Conflict Resolution BLoC
abstract class ConflictState extends Equatable {
  const ConflictState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ConflictInitial extends ConflictState {
  const ConflictInitial();
}

/// Loading conflicts
class ConflictLoading extends ConflictState {
  const ConflictLoading();
}

/// Pending conflicts loaded
class PendingConflictsLoaded extends ConflictState {
  final List<SyncConflict> conflicts;
  final int totalCount;
  final ConflictResolutionConfig config;

  const PendingConflictsLoaded({
    required this.conflicts,
    required this.totalCount,
    required this.config,
  });

  @override
  List<Object?> get props => [conflicts, totalCount, config];
}

/// Resolved conflicts history loaded
class ResolvedConflictsLoaded extends ConflictState {
  final List<SyncConflict> conflicts;

  const ResolvedConflictsLoaded(this.conflicts);

  @override
  List<Object?> get props => [conflicts];
}

/// Single conflict details loaded
class ConflictDetailsLoaded extends ConflictState {
  final SyncConflict conflict;
  final List<ConflictingField> conflictingFields;

  const ConflictDetailsLoaded({
    required this.conflict,
    required this.conflictingFields,
  });

  @override
  List<Object?> get props => [conflict, conflictingFields];
}

/// Conflict resolved successfully
class ConflictResolved extends ConflictState {
  final SyncConflict resolvedConflict;
  final String message;

  const ConflictResolved({
    required this.resolvedConflict,
    required this.message,
  });

  @override
  List<Object?> get props => [resolvedConflict, message];
}

/// All conflicts resolved
class AllConflictsResolved extends ConflictState {
  final int resolvedCount;
  final String message;

  const AllConflictsResolved({
    required this.resolvedCount,
    required this.message,
  });

  @override
  List<Object?> get props => [resolvedCount, message];
}

/// Configuration updated
class ConflictConfigUpdated extends ConflictState {
  final ConflictResolutionConfig config;

  const ConflictConfigUpdated(this.config);

  @override
  List<Object?> get props => [config];
}

/// Error state
class ConflictError extends ConflictState {
  final String message;

  const ConflictError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Old conflicts cleaned up
class OldConflictsCleaned extends ConflictState {
  final int cleanedCount;

  const OldConflictsCleaned(this.cleanedCount);

  @override
  List<Object?> get props => [cleanedCount];
}

/// No pending conflicts
class NoConflicts extends ConflictState {
  const NoConflicts();
}
