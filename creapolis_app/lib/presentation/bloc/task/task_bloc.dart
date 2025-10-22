import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/utils/app_logger.dart';
import '../../../core/utils/pagination_helper.dart';
import '../../../domain/entities/project.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/repositories/task_repository.dart';
import '../../../domain/usecases/create_task_usecase.dart';
import '../../../domain/usecases/delete_task_usecase.dart';
import '../../../domain/usecases/get_task_by_id_usecase.dart';
import '../../../domain/usecases/get_tasks_by_project_usecase.dart';
import '../../../domain/usecases/get_workspace_tasks_usecase.dart';
import '../../../domain/usecases/update_task_usecase.dart';
import 'task_event.dart';
import 'task_state.dart';

/// BLoC para gestión de tareas
@injectable
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksByProjectUseCase _getTasksByProjectUseCase;
  final GetWorkspaceTasksUseCase _getWorkspaceTasksUseCase;
  final GetTaskByIdUseCase _getTaskByIdUseCase;
  final CreateTaskUseCase _createTaskUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;
  final TaskRepository _taskRepository;

  TaskBloc(
    this._getTasksByProjectUseCase,
    this._getWorkspaceTasksUseCase,
    this._getTaskByIdUseCase,
    this._createTaskUseCase,
    this._updateTaskUseCase,
    this._deleteTaskUseCase,
    this._taskRepository,
  ) : super(const TaskInitial()) {
    on<LoadTasksByProjectEvent>(_onLoadTasksByProject);
    on<RefreshTasksEvent>(_onRefreshTasks);
    on<LoadWorkspaceTasksEvent>(_onLoadWorkspaceTasks);
    on<RefreshWorkspaceTasksEvent>(_onRefreshWorkspaceTasks);
    on<LoadTaskByIdEvent>(_onLoadTaskById);
    on<CreateTaskEvent>(_onCreateTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<FilterTasksByStatusEvent>(_onFilterByStatus);
    on<FilterTasksByAssigneeEvent>(_onFilterByAssignee);
    on<CalculateScheduleEvent>(_onCalculateSchedule);
    on<RescheduleProjectEvent>(_onRescheduleProject);
    on<LoadMoreTasksEvent>(_onLoadMoreTasks);
    on<ResetTasksPaginationEvent>(_onResetPagination);
  }

  /// Cargar tareas de un proyecto
  Future<void> _onLoadTasksByProject(
    LoadTasksByProjectEvent event,
    Emitter<TaskState> emit,
  ) async {
    AppLogger.info('TaskBloc: Cargando tareas del proyecto ${event.projectId}');
    emit(const TaskLoading());

    final result = await _getTasksByProjectUseCase(event.projectId);

    result.fold(
      (failure) {
        AppLogger.error(
          'TaskBloc: Error al cargar tareas - ${failure.message}',
        );
        emit(TaskError(failure.message));
      },
      (tasks) {
        AppLogger.info('TaskBloc: ${tasks.length} tareas cargadas');
        emit(TasksLoaded(tasks));
      },
    );
  }

  /// Refrescar tareas (sin loading)
  Future<void> _onRefreshTasks(
    RefreshTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    AppLogger.info(
      'TaskBloc: Refrescando tareas del proyecto ${event.projectId}',
    );

    final result = await _getTasksByProjectUseCase(event.projectId);

    result.fold(
      (failure) {
        AppLogger.error(
          'TaskBloc: Error al refrescar tareas - ${failure.message}',
        );
        emit(TaskError(failure.message));
      },
      (tasks) {
        AppLogger.info('TaskBloc: ${tasks.length} tareas refrescadas');
        emit(TasksLoaded(tasks));
      },
    );
  }

  /// Cargar tareas agregadas de un workspace
  Future<void> _onLoadWorkspaceTasks(
    LoadWorkspaceTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    AppLogger.info(
      'TaskBloc: Cargando tareas agregadas del workspace ${event.workspaceId}',
    );
    emit(const TaskLoading());

    final result = await _getWorkspaceTasksUseCase(
      workspaceId: event.workspaceId,
    );

    result.fold(
      (failure) {
        AppLogger.error(
          'TaskBloc: Error al cargar tareas de workspace - ${failure.message}',
        );
        emit(TaskError(failure.message));
      },
      (data) {
        AppLogger.info(
          'TaskBloc: ${data.tasks.length} tareas agregadas cargadas '
          'para workspace ${event.workspaceId}',
        );
        emit(
          WorkspaceTasksLoaded(
            workspaceId: event.workspaceId,
            tasks: List<Task>.from(data.tasks),
            projectById: Map<int, Project>.unmodifiable({
              for (final project in data.projects) project.id: project,
            }),
          ),
        );
      },
    );
  }

  /// Refrescar tareas agregadas de un workspace
  Future<void> _onRefreshWorkspaceTasks(
    RefreshWorkspaceTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    AppLogger.info(
      'TaskBloc: Refrescando tareas agregadas del workspace '
      '${event.workspaceId}',
    );

    final currentState = state;
    WorkspaceTasksLoaded? workspaceState;
    if (currentState is WorkspaceTasksLoaded &&
        currentState.workspaceId == event.workspaceId) {
      workspaceState = currentState;
      emit(workspaceState.copyWith(isRefreshing: true));
    } else {
      emit(const TaskLoading());
    }

    final result = await _getWorkspaceTasksUseCase(
      workspaceId: event.workspaceId,
    );

    result.fold(
      (failure) {
        AppLogger.error(
          'TaskBloc: Error al refrescar tareas de workspace - '
          '${failure.message}',
        );
        emit(TaskError(failure.message));
        if (workspaceState != null) {
          emit(workspaceState.copyWith(isRefreshing: false));
        }
      },
      (data) {
        AppLogger.info(
          'TaskBloc: ${data.tasks.length} tareas agregadas refrescadas '
          'para workspace ${event.workspaceId}',
        );
        emit(
          WorkspaceTasksLoaded(
            workspaceId: event.workspaceId,
            tasks: List<Task>.from(data.tasks),
            projectById: Map<int, Project>.unmodifiable({
              for (final project in data.projects) project.id: project,
            }),
          ),
        );
      },
    );
  }

  /// Cargar más tareas (lazy loading)
  Future<void> _onLoadMoreTasks(
    LoadMoreTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    final currentState = state;

    // Solo cargar más si estamos en estado TasksLoaded
    if (currentState is! TasksLoaded) {
      AppLogger.warning(
        'TaskBloc: Intento de cargar más tareas fuera de estado TasksLoaded',
      );
      return;
    }

    // Si ya estamos cargando más o no hay más datos, no hacer nada
    if (currentState.isLoadingMore ||
        !currentState.paginationState.hasMoreData) {
      AppLogger.info(
        'TaskBloc: Ya cargando más o no hay más datos disponibles',
      );
      return;
    }

    AppLogger.info(
      'TaskBloc: Cargando más tareas del proyecto ${event.projectId} '
      '(página ${currentState.paginationState.currentPage + 1})',
    );

    // Emitir estado indicando que estamos cargando más
    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.paginationState.currentPage + 1;
    final result = await _getTasksByProjectUseCase.paginatedWithMetadata(
      event.projectId,
      page: nextPage,
      limit: currentState.paginationState.pageSize,
    );

    result.fold(
      (failure) {
        AppLogger.error(
          'TaskBloc: Error al cargar más tareas - ${failure.message}',
        );
        // Volver al estado anterior sin isLoadingMore
        emit(currentState.copyWith(isLoadingMore: false));
      },
      (paginatedResponse) {
        AppLogger.info(
          'TaskBloc: ${paginatedResponse.items.length} tareas adicionales cargadas',
        );

        // Combinar tareas existentes con las nuevas
        final allTasks = [...currentState.tasks, ...paginatedResponse.items];

        // Actualizar estado de paginación
        final newPaginationState = currentState.paginationState.copyWith(
          currentPage: paginatedResponse.metadata.page,
          hasMoreData: paginatedResponse.hasMore,
          totalItems: paginatedResponse.metadata.total,
        );

        emit(
          TasksLoaded(
            allTasks,
            statusFilter: currentState.statusFilter,
            assigneeFilter: currentState.assigneeFilter,
            paginationState: newPaginationState,
            isLoadingMore: false,
          ),
        );
      },
    );
  }

  /// Reset paginación y cargar primera página
  Future<void> _onResetPagination(
    ResetTasksPaginationEvent event,
    Emitter<TaskState> emit,
  ) async {
    AppLogger.info(
      'TaskBloc: Reseteando paginación para proyecto ${event.projectId}',
    );

    emit(const TaskLoading());

    final result = await _getTasksByProjectUseCase.paginatedWithMetadata(
      event.projectId,
      page: 1,
      limit: PaginationHelper.defaultPageSize,
    );

    result.fold(
      (failure) {
        AppLogger.error(
          'TaskBloc: Error al cargar primera página - ${failure.message}',
        );
        emit(TaskError(failure.message));
      },
      (paginatedResponse) {
        AppLogger.info(
          'TaskBloc: Primera página cargada con ${paginatedResponse.items.length} tareas',
        );

        final paginationState = PaginationState(
          currentPage: paginatedResponse.metadata.page,
          pageSize: paginatedResponse.metadata.limit,
          hasMoreData: paginatedResponse.hasMore,
          totalItems: paginatedResponse.metadata.total,
        );

        emit(
          TasksLoaded(
            paginatedResponse.items,
            paginationState: paginationState,
          ),
        );
      },
    );
  }

  /// Cargar una tarea por ID
  Future<void> _onLoadTaskById(
    LoadTaskByIdEvent event,
    Emitter<TaskState> emit,
  ) async {
    AppLogger.info('TaskBloc: Cargando tarea ${event.id}');
    emit(const TaskLoading());

    final result = await _getTaskByIdUseCase(event.projectId, event.id);

    result.fold(
      (failure) {
        AppLogger.error('TaskBloc: Error al cargar tarea - ${failure.message}');
        emit(TaskError(failure.message));
      },
      (task) {
        AppLogger.info('TaskBloc: Tarea ${task.title} cargada');
        emit(TaskLoaded(task));
      },
    );
  }

  /// Crear una nueva tarea
  Future<void> _onCreateTask(
    CreateTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    AppLogger.info('TaskBloc: Creando tarea "${event.title}"');
    final previousState = state;
    final workspaceState = previousState is WorkspaceTasksLoaded
        ? previousState
        : null;

    if (workspaceState == null) {
      emit(const TaskLoading());
    }

    final params = CreateTaskParams(
      title: event.title,
      description: event.description,
      status: event.status,
      priority: event.priority,
      startDate: event.startDate,
      endDate: event.endDate,
      estimatedHours: event.estimatedHours,
      projectId: event.projectId,
      assignedUserId: event.assignedUserId,
      dependencyIds: event.dependencyIds,
    );

    final result = await _createTaskUseCase(params);

    result.fold(
      (failure) {
        AppLogger.error('TaskBloc: Error al crear tarea - ${failure.message}');
        emit(TaskError(failure.message));
        if (workspaceState != null) {
          emit(workspaceState);
        }
      },
      (task) {
        AppLogger.info(
          'TaskBloc: Tarea "${task.title}" creada con ID ${task.id}',
        );
        emit(TaskCreated(task));
        if (workspaceState != null) {
          final updatedTasks = List<Task>.from(workspaceState.tasks)..add(task);
          emit(workspaceState.copyWith(tasks: updatedTasks));
        }
      },
    );
  }

  /// Actualizar una tarea
  Future<void> _onUpdateTask(
    UpdateTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    AppLogger.info('TaskBloc: Actualizando tarea ${event.id}');
    final previousState = state;
    final workspaceState = previousState is WorkspaceTasksLoaded
        ? previousState
        : null;

    if (workspaceState == null) {
      emit(const TaskLoading());
    }

    final params = UpdateTaskParams(
      projectId: event.projectId,
      id: event.id,
      title: event.title,
      description: event.description,
      status: event.status,
      priority: event.priority,
      startDate: event.startDate,
      endDate: event.endDate,
      estimatedHours: event.estimatedHours,
      actualHours: event.actualHours,
      assignedUserId: event.assignedUserId,
      dependencyIds: event.dependencyIds,
      updateAssignee: event.updateAssignee,
    );

    final result = await _updateTaskUseCase(params);

    result.fold(
      (failure) {
        AppLogger.error(
          'TaskBloc: Error al actualizar tarea - ${failure.message}',
        );
        emit(TaskError(failure.message));
        if (workspaceState != null) {
          emit(workspaceState);
        }
      },
      (task) {
        AppLogger.info('TaskBloc: Tarea ${task.id} actualizada');
        emit(TaskUpdated(task));
        if (workspaceState != null) {
          final updatedTasks = workspaceState.tasks
              .map((t) => t.id == task.id ? task : t)
              .toList(growable: false);
          emit(workspaceState.copyWith(tasks: updatedTasks));
        }
      },
    );
  }

  /// Eliminar una tarea
  Future<void> _onDeleteTask(
    DeleteTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    AppLogger.info('TaskBloc: Eliminando tarea ${event.id}');
    final previousState = state;
    final workspaceState = previousState is WorkspaceTasksLoaded
        ? previousState
        : null;

    if (workspaceState == null) {
      emit(const TaskLoading());
    }

    final result = await _deleteTaskUseCase(event.projectId, event.id);

    result.fold(
      (failure) {
        AppLogger.error(
          'TaskBloc: Error al eliminar tarea - ${failure.message}',
        );
        emit(TaskError(failure.message));
        if (workspaceState != null) {
          emit(workspaceState);
        }
      },
      (_) {
        AppLogger.info('TaskBloc: Tarea ${event.id} eliminada');
        emit(TaskDeleted(event.id));
        if (workspaceState != null) {
          final updatedTasks = workspaceState.tasks
              .where((t) => t.id != event.id)
              .toList(growable: false);
          emit(workspaceState.copyWith(tasks: updatedTasks));
        }
      },
    );
  }

  /// Filtrar tareas por estado
  Future<void> _onFilterByStatus(
    FilterTasksByStatusEvent event,
    Emitter<TaskState> emit,
  ) async {
    AppLogger.info('TaskBloc: Filtrando tareas por estado ${event.status}');

    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;
      emit(
        TasksLoaded(
          currentState.tasks,
          statusFilter: event.status,
          assigneeFilter: currentState.assigneeFilter,
        ),
      );
    } else {
      // Si no hay tareas cargadas, cargarlas primero
      add(LoadTasksByProjectEvent(event.projectId));
    }
  }

  /// Filtrar tareas por asignado
  Future<void> _onFilterByAssignee(
    FilterTasksByAssigneeEvent event,
    Emitter<TaskState> emit,
  ) async {
    AppLogger.info(
      'TaskBloc: Filtrando tareas por asignado ${event.assigneeId}',
    );

    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;
      emit(
        TasksLoaded(
          currentState.tasks,
          statusFilter: currentState.statusFilter,
          assigneeFilter: event.assigneeId,
        ),
      );
    } else {
      // Si no hay tareas cargadas, cargarlas primero
      add(LoadTasksByProjectEvent(event.projectId));
    }
  }

  /// Calcular cronograma del proyecto
  Future<void> _onCalculateSchedule(
    CalculateScheduleEvent event,
    Emitter<TaskState> emit,
  ) async {
    AppLogger.info(
      'TaskBloc: Calculando cronograma del proyecto ${event.projectId}',
    );
    emit(const TaskScheduleCalculating());

    final result = await _taskRepository.calculateSchedule(event.projectId);

    result.fold(
      (failure) {
        AppLogger.error(
          'TaskBloc: Error al calcular cronograma - ${failure.message}',
        );
        emit(TaskError(failure.message));
      },
      (tasks) {
        AppLogger.info(
          'TaskBloc: Cronograma calculado con ${tasks.length} tareas',
        );
        emit(
          TaskScheduleCalculated(tasks, 'Cronograma calculado exitosamente'),
        );
      },
    );
  }

  /// Replanificar proyecto desde una tarea
  Future<void> _onRescheduleProject(
    RescheduleProjectEvent event,
    Emitter<TaskState> emit,
  ) async {
    AppLogger.info(
      'TaskBloc: Replanificando proyecto ${event.projectId} desde tarea ${event.triggerTaskId}',
    );
    emit(const TaskRescheduling());

    final result = await _taskRepository.rescheduleProject(
      event.projectId,
      event.triggerTaskId,
    );

    result.fold(
      (failure) {
        AppLogger.error('TaskBloc: Error al replanificar - ${failure.message}');
        emit(TaskError(failure.message));
      },
      (tasks) {
        AppLogger.info(
          'TaskBloc: Proyecto replanificado con ${tasks.length} tareas',
        );
        emit(TaskRescheduled(tasks, 'Proyecto replanificado exitosamente'));
      },
    );
  }
}
