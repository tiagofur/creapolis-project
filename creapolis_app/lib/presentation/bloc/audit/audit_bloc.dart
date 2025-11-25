import 'package:bloc/bloc.dart';
import 'package:creapolis_app/domain/entities/audit_log.dart';
import 'package:creapolis_app/domain/repositories/audit_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

// Events
abstract class AuditEvent extends Equatable {
  const AuditEvent();

  @override
  List<Object?> get props => [];
}

class LoadWorkspaceLogs extends AuditEvent {
  final int workspaceId;
  final int? projectId;
  final int? userId;
  final String? action;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool refresh;

  const LoadWorkspaceLogs({
    required this.workspaceId,
    this.projectId,
    this.userId,
    this.action,
    this.startDate,
    this.endDate,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [
    workspaceId,
    projectId,
    userId,
    action,
    startDate,
    endDate,
    refresh,
  ];
}

class LoadMoreLogs extends AuditEvent {
  final int workspaceId;

  const LoadMoreLogs(this.workspaceId);

  @override
  List<Object?> get props => [workspaceId];
}

// States
abstract class AuditState extends Equatable {
  const AuditState();

  @override
  List<Object?> get props => [];
}

class AuditInitial extends AuditState {}

class AuditLoading extends AuditState {}

class AuditLoaded extends AuditState {
  final List<AuditLog> logs;
  final bool hasReachedMax;
  final int workspaceId;

  const AuditLoaded({
    required this.logs,
    this.hasReachedMax = false,
    required this.workspaceId,
  });

  AuditLoaded copyWith({
    List<AuditLog>? logs,
    bool? hasReachedMax,
    int? workspaceId,
  }) {
    return AuditLoaded(
      logs: logs ?? this.logs,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }

  @override
  List<Object?> get props => [logs, hasReachedMax, workspaceId];
}

class AuditError extends AuditState {
  final String message;

  const AuditError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
@injectable
class AuditBloc extends Bloc<AuditEvent, AuditState> {
  final AuditRepository repository;
  int _offset = 0;
  final int _limit = 50;

  // Keep track of filters for pagination
  int? _currentProjectId;
  int? _currentUserId;
  String? _currentAction;
  DateTime? _currentStartDate;
  DateTime? _currentEndDate;

  AuditBloc({required this.repository}) : super(AuditInitial()) {
    on<LoadWorkspaceLogs>(_onLoadWorkspaceLogs);
    on<LoadMoreLogs>(_onLoadMoreLogs);
  }

  Future<void> _onLoadWorkspaceLogs(
    LoadWorkspaceLogs event,
    Emitter<AuditState> emit,
  ) async {
    if (event.refresh) {
      _offset = 0;
    } else {
      emit(AuditLoading());
    }

    _currentProjectId = event.projectId;
    _currentUserId = event.userId;
    _currentAction = event.action;
    _currentStartDate = event.startDate;
    _currentEndDate = event.endDate;

    try {
      final logs = await repository.getWorkspaceLogs(
        event.workspaceId,
        limit: _limit,
        offset: _offset,
        projectId: event.projectId,
        userId: event.userId,
        action: event.action,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      _offset += logs.length;

      emit(
        AuditLoaded(
          logs: logs,
          hasReachedMax: logs.length < _limit,
          workspaceId: event.workspaceId,
        ),
      );
    } catch (e) {
      emit(AuditError(e.toString()));
    }
  }

  Future<void> _onLoadMoreLogs(
    LoadMoreLogs event,
    Emitter<AuditState> emit,
  ) async {
    final currentState = state;
    if (currentState is AuditLoaded && !currentState.hasReachedMax) {
      try {
        final logs = await repository.getWorkspaceLogs(
          event.workspaceId,
          limit: _limit,
          offset: _offset,
          projectId: _currentProjectId,
          userId: _currentUserId,
          action: _currentAction,
          startDate: _currentStartDate,
          endDate: _currentEndDate,
        );

        if (logs.isEmpty) {
          emit(currentState.copyWith(hasReachedMax: true));
        } else {
          _offset += logs.length;
          emit(
            currentState.copyWith(
              logs: currentState.logs + logs,
              hasReachedMax: logs.length < _limit,
            ),
          );
        }
      } catch (e) {
        // Don't emit error state on pagination failure, just show snackbar or ignore
        // emit(AuditError(e.toString()));
      }
    }
  }
}
