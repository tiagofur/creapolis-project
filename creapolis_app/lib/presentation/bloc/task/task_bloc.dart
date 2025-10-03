import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/repositories/task_repository.dart';
import '../../../domain/usecases/create_task_usecase.dart';
import '../../../domain/usecases/delete_task_usecase.dart';
import '../../../domain/usecases/get_task_by_id_usecase.dart';
import '../../../domain/usecases/get_tasks_by_project_usecase.dart';
import '../../../domain/usecases/update_task_usecase.dart';
import 'task_event.dart';
import 'task_state.dart';

/// BLoC para gestión de tareas
@injectable
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksByProjectUseCase _getTasksByProjectUseCase;
  final GetTaskByIdUseCase _getTaskByIdUseCase;
  final CreateTaskUseCase _createTaskUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;
  final TaskRepository _taskRepository;

  TaskBloc(
    this._getTasksByProjectUseCase,
    this._getTaskByIdUseCase,
    this._createTaskUseCase,
    this._updateTaskUseCase,
    this._deleteTaskUseCase,
    this._taskRepository,
  ) : super(const TaskInitial()) {
    on<LoadTasksByProjectEvent>(_onLoadTasksByProject);
    on<RefreshTasksEvent>(_onRefreshTasks);
    on<LoadTaskByIdEvent>(_onLoadTaskById);
    on<CreateTaskEvent>(_onCreateTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<FilterTasksByStatusEvent>(_onFilterByStatus);
    on<FilterTasksByAssigneeEvent>(_onFilterByAssignee);
    on<CalculateScheduleEvent>(_onCalculateSchedule);
    on<RescheduleProjectEvent>(_onRescheduleProject);
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

  /// Cargar una tarea por ID
  Future<void> _onLoadTaskById(
    LoadTaskByIdEvent event,
    Emitter<TaskState> emit,
  ) async {
    AppLogger.info('TaskBloc: Cargando tarea ${event.id}');
    emit(const TaskLoading());

    final result = await _getTaskByIdUseCase(event.id);

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
    emit(const TaskLoading());

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
      },
      (task) {
        AppLogger.info(
          'TaskBloc: Tarea "${task.title}" creada con ID ${task.id}',
        );
        emit(TaskCreated(task));
      },
    );
  }

  /// Actualizar una tarea
  Future<void> _onUpdateTask(
    UpdateTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    AppLogger.info('TaskBloc: Actualizando tarea ${event.id}');
    emit(const TaskLoading());

    final params = UpdateTaskParams(
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
    );

    final result = await _updateTaskUseCase(params);

    result.fold(
      (failure) {
        AppLogger.error(
          'TaskBloc: Error al actualizar tarea - ${failure.message}',
        );
        emit(TaskError(failure.message));
      },
      (task) {
        AppLogger.info('TaskBloc: Tarea ${task.id} actualizada');
        emit(TaskUpdated(task));
      },
    );
  }

  /// Eliminar una tarea
  Future<void> _onDeleteTask(
    DeleteTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    AppLogger.info('TaskBloc: Eliminando tarea ${event.id}');
    emit(const TaskLoading());

    final result = await _deleteTaskUseCase(event.id);

    result.fold(
      (failure) {
        AppLogger.error(
          'TaskBloc: Error al eliminar tarea - ${failure.message}',
        );
        emit(TaskError(failure.message));
      },
      (_) {
        AppLogger.info('TaskBloc: Tarea ${event.id} eliminada');
        emit(TaskDeleted(event.id));
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
