import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/usecases/get_resource_allocation_usecase.dart';
import '../../../domain/usecases/get_user_workload_usecase.dart';
import '../../../domain/usecases/get_workload_stats_usecase.dart';
import 'workload_event.dart';
import 'workload_state.dart';

/// BLoC para gestión de workload
@injectable
class WorkloadBloc extends Bloc<WorkloadEvent, WorkloadState> {
  final GetResourceAllocationUseCase _getResourceAllocationUseCase;
  final GetUserWorkloadUseCase _getUserWorkloadUseCase;
  final GetWorkloadStatsUseCase _getWorkloadStatsUseCase;

  WorkloadBloc(
    this._getResourceAllocationUseCase,
    this._getUserWorkloadUseCase,
    this._getWorkloadStatsUseCase,
  ) : super(const WorkloadInitial()) {
    on<LoadResourceAllocationEvent>(_onLoadResourceAllocation);
    on<LoadUserWorkloadEvent>(_onLoadUserWorkload);
    on<LoadWorkloadStatsEvent>(_onLoadWorkloadStats);
    on<ChangeDateRangeEvent>(_onChangeDateRange);
    on<RefreshWorkloadEvent>(_onRefreshWorkload);
  }

  /// Cargar resource allocation
  Future<void> _onLoadResourceAllocation(
    LoadResourceAllocationEvent event,
    Emitter<WorkloadState> emit,
  ) async {
    AppLogger.info(
      'WorkloadBloc: Cargando resource allocation para proyecto ${event.projectId}',
    );

    emit(const WorkloadLoading());

    final result = await _getResourceAllocationUseCase(
      event.projectId,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) {
        AppLogger.error(
          'WorkloadBloc: Error al cargar resource allocation',
          failure,
        );
        emit(WorkloadError(failure.message));
      },
      (allocations) async {
        AppLogger.info(
          'WorkloadBloc: Resource allocation cargado - ${allocations.length} miembros',
        );

        // Cargar stats también
        final statsResult = await _getWorkloadStatsUseCase(event.projectId);

        statsResult.fold(
          (failure) {
            // Emitir sin stats si falla
            emit(
              ResourceAllocationLoaded(
                allocations: allocations,
                startDate: event.startDate,
                endDate: event.endDate,
              ),
            );
          },
          (stats) {
            emit(
              ResourceAllocationLoaded(
                allocations: allocations,
                stats: stats,
                startDate: event.startDate,
                endDate: event.endDate,
              ),
            );
          },
        );
      },
    );
  }

  /// Cargar workload de usuario
  Future<void> _onLoadUserWorkload(
    LoadUserWorkloadEvent event,
    Emitter<WorkloadState> emit,
  ) async {
    AppLogger.info(
      'WorkloadBloc: Cargando workload para usuario ${event.userId}',
    );

    emit(const WorkloadLoading());

    final result = await _getUserWorkloadUseCase(
      event.userId,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) {
        AppLogger.error(
          'WorkloadBloc: Error al cargar workload de usuario',
          failure,
        );
        emit(WorkloadError(failure.message));
      },
      (workload) {
        AppLogger.info('WorkloadBloc: Workload de usuario cargado');
        emit(UserWorkloadLoaded(workload));
      },
    );
  }

  /// Cargar estadísticas de workload
  Future<void> _onLoadWorkloadStats(
    LoadWorkloadStatsEvent event,
    Emitter<WorkloadState> emit,
  ) async {
    AppLogger.info(
      'WorkloadBloc: Cargando stats para proyecto ${event.projectId}',
    );

    // Mantener estado actual si existe
    if (state is ResourceAllocationLoaded) {
      final currentState = state as ResourceAllocationLoaded;

      final result = await _getWorkloadStatsUseCase(event.projectId);

      result.fold(
        (failure) {
          AppLogger.error('WorkloadBloc: Error al cargar stats', failure);
          // Mantener estado actual
        },
        (stats) {
          AppLogger.info('WorkloadBloc: Stats cargado');
          emit(
            ResourceAllocationLoaded(
              allocations: currentState.allocations,
              stats: stats,
              startDate: currentState.startDate,
              endDate: currentState.endDate,
            ),
          );
        },
      );
    }
  }

  /// Cambiar rango de fechas
  Future<void> _onChangeDateRange(
    ChangeDateRangeEvent event,
    Emitter<WorkloadState> emit,
  ) async {
    AppLogger.info(
      'WorkloadBloc: Cambiando rango de fechas: ${event.startDate} - ${event.endDate}',
    );

    add(
      LoadResourceAllocationEvent(
        event.projectId,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );
  }

  /// Refrescar workload
  Future<void> _onRefreshWorkload(
    RefreshWorkloadEvent event,
    Emitter<WorkloadState> emit,
  ) async {
    AppLogger.info(
      'WorkloadBloc: Refrescando workload para proyecto ${event.projectId}',
    );

    // Mantener rango de fechas actual si existe
    DateTime? startDate;
    DateTime? endDate;

    if (state is ResourceAllocationLoaded) {
      final currentState = state as ResourceAllocationLoaded;
      startDate = currentState.startDate;
      endDate = currentState.endDate;
    }

    add(
      LoadResourceAllocationEvent(
        event.projectId,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }
}
