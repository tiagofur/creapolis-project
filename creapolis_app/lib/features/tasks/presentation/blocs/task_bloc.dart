import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:injectable/injectable.dart';
import 'task_event.dart';
import 'task_state.dart';
import 'package:creapolis_app/domain/repositories/task_repository.dart';
import 'package:creapolis_app/domain/entities/task.dart';

/// BLoC para gestionar tareas
@injectable
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository taskRepository;
  final Logger logger = Logger();

  TaskBloc({required this.taskRepository}) : super(const TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<LoadAllTasks>(_onLoadAllTasks);
    on<LoadTaskById>(_onLoadTaskById);
    on<CreateTask>(_onCreateTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<RefreshTasks>(_onRefreshTasks);
    on<FilterTasksByStatus>(_onFilterTasksByStatus);
    on<FilterTasksByPriority>(_onFilterTasksByPriority);
    on<SearchTasks>(_onSearchTasks);
    on<UpdateTaskStatus>(_onUpdateTaskStatus);
  }

  /// Cargar tareas de un proyecto
  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    try {
      emit(const TaskLoading());
      logger.i('Loading tasks for project: ${event.projectId}');

      final result = await taskRepository.getTasksByProject(event.projectId);

      result.fold(
        (failure) {
          logger.e('Failed to load tasks: ${failure.message}');
          emit(TaskError(failure.message));
        },
        (tasks) {
          logger.i('Tasks loaded successfully: ${tasks.length} tasks');
          emit(
            TasksLoaded(
              projectId: event.projectId,
              tasks: tasks,
              filteredTasks: tasks,
            ),
          );
        },
      );
    } catch (e) {
      logger.e('Exception loading tasks: $e');
      emit(TaskError('Error inesperado al cargar tareas: $e'));
    }
  }

  /// Cargar todas las tareas del usuario
  Future<void> _onLoadAllTasks(
    LoadAllTasks event,
    Emitter<TaskState> emit,
  ) async {
    try {
      emit(const TaskLoading());
      logger.i('Loading all tasks');
      final result = await taskRepository.getAllTasks();
      result.fold(
        (failure) {
          logger.e('Failed to load all tasks: ${failure.message}');
          emit(TaskError(failure.message));
        },
        (tasks) {
          logger.i('All tasks loaded successfully: ${tasks.length} tasks');
          emit(
            TasksLoaded(
              projectId: 0,
              tasks: tasks,
              filteredTasks: tasks,
            ),
          );
        },
      );
    } catch (e) {
      logger.e('Exception loading all tasks: $e');
      emit(TaskError('Error inesperado al cargar todas las tareas: $e'));
    }
  }

  /// Cargar tarea específica por ID
  Future<void> _onLoadTaskById(
    LoadTaskById event,
    Emitter<TaskState> emit,
  ) async {
    try {
      logger.i('Loading task by ID: ${event.taskId}');

      // Obtener projectId del state actual si existe
      int projectId = 0;
      if (state is TasksLoaded) {
        projectId = (state as TasksLoaded).projectId;
      }

      final result = await taskRepository.getTaskById(projectId, event.taskId);

      result.fold(
        (failure) {
          logger.e('Failed to load task: ${failure.message}');

          // Mantener el estado actual si existe
          if (state is TasksLoaded) {
            final currentState = state as TasksLoaded;
            emit(TaskError(failure.message, currentTasks: currentState.tasks));
          } else {
            emit(TaskError(failure.message));
          }
        },
        (task) {
          logger.i('Task loaded successfully: ${task.title}');

          if (state is TasksLoaded) {
            final currentState = state as TasksLoaded;

            // Actualizar o agregar la tarea a la lista actual
            final updatedTasks = List<Task>.from(currentState.tasks);
            final index = updatedTasks.indexWhere((t) => t.id == task.id);

            if (index != -1) {
              updatedTasks[index] = task;
            } else {
              updatedTasks.add(task);
            }

            emit(
              currentState.copyWith(
                tasks: updatedTasks,
                filteredTasks: updatedTasks,
                selectedTask: task,
              ),
            );
          } else {
            emit(
              TasksLoaded(
                projectId: task.projectId, // Usar projectId de la tarea
                tasks: [task],
                filteredTasks: [task],
                selectedTask: task,
              ),
            );
          }
        },
      );
    } catch (e) {
      logger.e('Exception loading task by ID: $e');
      emit(TaskError('Error inesperado al cargar tarea: $e'));
    }
  }

  /// Crear nueva tarea
  Future<void> _onCreateTask(CreateTask event, Emitter<TaskState> emit) async {
    try {
      final previousState = state;
      final tasksState = previousState is TasksLoaded ? previousState : null;

      emit(const TaskOperationInProgress('Creando tarea...'));
      logger.i('Creating task: ${event.title}');

      final result = await taskRepository.createTask(
        projectId: event.projectId,
        title: event.title,
        description: event.description,
        priority: event.priority,
        status: event.status,
        estimatedHours: event.estimatedHours,
        startDate: event.startDate,
        endDate: event.endDate,
        assignedUserId: event.assigneeId,
      );

      result.fold(
        (failure) {
          logger.e('Failed to create task: ${failure.message}');
          emit(TaskError(failure.message, currentTasks: tasksState?.tasks));
        },
        (task) {
          logger.i('Task created successfully: ${task.title}');

          // Emitir éxito temporalmente
          emit(TaskOperationSuccess('Tarea creada exitosamente', task: task));

          // Actualizar lista de tareas
          if (tasksState != null) {
            final updatedTasks = List<Task>.from(tasksState.tasks)..add(task);
            final filteredTasks = _rebuildFilteredTasks(
              tasksState,
              updatedTasks,
            );

            emit(
              tasksState.copyWith(
                tasks: updatedTasks,
                filteredTasks: filteredTasks,
                selectedTask: task,
              ),
            );
          } else {
            emit(
              TasksLoaded(
                projectId: task.projectId,
                tasks: [task],
                filteredTasks: [task],
                selectedTask: task,
              ),
            );
          }
        },
      );
    } catch (e) {
      logger.e('Exception creating task: $e');
      emit(TaskError('Error inesperado al crear tarea: $e'));
    }
  }

  /// Actualizar tarea existente
  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      final previousState = state;
      final tasksState = previousState is TasksLoaded ? previousState : null;

      emit(const TaskOperationInProgress('Actualizando tarea...'));
      logger.i('Updating task: ${event.id}');

      // Obtener projectId del state actual
      if (tasksState == null) {
        emit(
          const TaskError('No hay contexto de proyecto para actualizar tarea'),
        );
        return;
      }

      final result = await taskRepository.updateTask(
        projectId: tasksState.projectId,
        taskId: event.id,
        title: event.title,
        description: event.description,
        priority: event.priority,
        status: event.status,
        estimatedHours: event.estimatedHours,
        actualHours: event.actualHours,
        startDate: event.startDate,
        endDate: event.endDate,
        assignedUserId: event.assigneeId,
      );

      result.fold(
        (failure) {
          logger.e('Failed to update task: ${failure.message}');
          emit(TaskError(failure.message, currentTasks: tasksState.tasks));
        },
        (task) {
          logger.i('Task updated successfully: ${task.title}');

          // Emitir éxito
          emit(
            TaskOperationSuccess('Tarea actualizada exitosamente', task: task),
          );

          // Actualizar en la lista
          final updatedTasks = tasksState.tasks
              .map((t) => t.id == task.id ? task : t)
              .toList();
          final filteredTasks = _rebuildFilteredTasks(tasksState, updatedTasks);

          emit(
            tasksState.copyWith(
              tasks: updatedTasks,
              filteredTasks: filteredTasks,
              selectedTask: task,
            ),
          );
        },
      );
    } catch (e) {
      logger.e('Exception updating task: $e');
      emit(TaskError('Error inesperado al actualizar tarea: $e'));
    }
  }

  /// Eliminar tarea
  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      final previousState = state;
      final tasksState = previousState is TasksLoaded ? previousState : null;

      emit(const TaskOperationInProgress('Eliminando tarea...'));
      logger.i('Deleting task: ${event.taskId}');

      // Obtener projectId del state actual
      if (tasksState == null) {
        emit(
          const TaskError('No hay contexto de proyecto para eliminar tarea'),
        );
        return;
      }

      final result = await taskRepository.deleteTask(
        tasksState.projectId,
        event.taskId,
      );

      result.fold(
        (failure) {
          logger.e('Failed to delete task: ${failure.message}');
          emit(TaskError(failure.message, currentTasks: tasksState.tasks));
        },
        (_) {
          logger.i('Task deleted successfully');

          // Emitir éxito
          emit(const TaskOperationSuccess('Tarea eliminada exitosamente'));

          // Remover de la lista
          final updatedTasks = tasksState.tasks
              .where((t) => t.id != event.taskId)
              .toList();
          final filteredTasks = _rebuildFilteredTasks(tasksState, updatedTasks);

          emit(
            tasksState.copyWith(
              tasks: updatedTasks,
              filteredTasks: filteredTasks,
              clearSelectedTask: tasksState.selectedTask?.id == event.taskId,
            ),
          );
        },
      );
    } catch (e) {
      logger.e('Exception deleting task: $e');
      emit(TaskError('Error inesperado al eliminar tarea: $e'));
    }
  }

  /// Refrescar tareas
  Future<void> _onRefreshTasks(
    RefreshTasks event,
    Emitter<TaskState> emit,
  ) async {
    // Reutilizar la lógica de LoadTasks
    add(LoadTasks(event.projectId));
  }

  /// Filtrar tareas por estado
  void _onFilterTasksByStatus(
    FilterTasksByStatus event,
    Emitter<TaskState> emit,
  ) {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;

      List<Task> filtered;
      if (event.status == null) {
        // Sin filtro, mostrar todas
        filtered = currentState.tasks;
      } else {
        // Filtrar por estado
        filtered = currentState.tasks
            .where((task) => task.status == event.status)
            .toList();
      }

      logger.i(
        'Filtered tasks by status: ${event.status} - ${filtered.length} tasks',
      );

      emit(
        currentState.copyWith(
          filteredTasks: filtered,
          currentStatusFilter: event.status,
          clearStatusFilter: event.status == null,
        ),
      );
    }
  }

  /// Filtrar tareas por prioridad
  void _onFilterTasksByPriority(
    FilterTasksByPriority event,
    Emitter<TaskState> emit,
  ) {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;

      List<Task> filtered;
      if (event.priority == null) {
        // Sin filtro, mostrar todas
        filtered = currentState.tasks;
      } else {
        // Filtrar por prioridad
        filtered = currentState.tasks
            .where((task) => task.priority == event.priority)
            .toList();
      }

      logger.i(
        'Filtered tasks by priority: ${event.priority} - ${filtered.length} tasks',
      );

      emit(
        currentState.copyWith(
          filteredTasks: filtered,
          currentPriorityFilter: event.priority,
          clearPriorityFilter: event.priority == null,
        ),
      );
    }
  }

  /// Buscar tareas
  void _onSearchTasks(SearchTasks event, Emitter<TaskState> emit) {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;

      List<Task> filtered;
      if (event.query.isEmpty) {
        // Sin búsqueda, aplicar filtros actuales
        filtered = _applyCurrentFilters(
          currentState.tasks,
          currentState.currentStatusFilter,
          currentState.currentPriorityFilter,
        );
      } else {
        // Buscar por título o descripción
        final query = event.query.toLowerCase();
        filtered = currentState.tasks
            .where(
              (task) =>
                  task.title.toLowerCase().contains(query) ||
                  task.description.toLowerCase().contains(query),
            )
            .toList();

        // Aplicar también los filtros actuales
        filtered = _applyCurrentFilters(
          filtered,
          currentState.currentStatusFilter,
          currentState.currentPriorityFilter,
        );
      }

      logger.i('Search tasks: "${event.query}" - ${filtered.length} results');

      emit(
        currentState.copyWith(
          filteredTasks: filtered,
          searchQuery: event.query.isEmpty ? null : event.query,
          clearSearchQuery: event.query.isEmpty,
        ),
      );
    }
  }

  /// Actualizar solo el estado de una tarea (quick action)
  Future<void> _onUpdateTaskStatus(
    UpdateTaskStatus event,
    Emitter<TaskState> emit,
  ) async {
    try {
      logger.i('Updating task status: ${event.taskId} -> ${event.newStatus}');

      // Obtener projectId del state actual
      if (state is! TasksLoaded) {
        emit(
          const TaskError('No hay contexto de proyecto para actualizar estado'),
        );
        return;
      }

      final currentState = state as TasksLoaded;

      final result = await taskRepository.updateTask(
        projectId: currentState.projectId,
        taskId: event.taskId,
        status: event.newStatus,
      );

      result.fold(
        (failure) {
          logger.e('Failed to update task status: ${failure.message}');
          emit(TaskError(failure.message));
        },
        (task) {
          logger.i('Task status updated successfully');

          // Actualizar en la lista sin mensaje de éxito
          if (state is TasksLoaded) {
            final currentState = state as TasksLoaded;
            final updatedTasks = currentState.tasks
                .map((t) => t.id == task.id ? task : t)
                .toList();

            emit(
              currentState.copyWith(
                tasks: updatedTasks,
                filteredTasks: updatedTasks,
              ),
            );
          }
        },
      );
    } catch (e) {
      logger.e('Exception updating task status: $e');
      emit(TaskError('Error inesperado al actualizar estado: $e'));
    }
  }

  /// Aplicar filtros actuales a una lista de tareas
  List<Task> _applyCurrentFilters(
    List<Task> tasks,
    TaskStatus? statusFilter,
    TaskPriority? priorityFilter,
  ) {
    var filtered = tasks;

    if (statusFilter != null) {
      filtered = filtered.where((task) => task.status == statusFilter).toList();
    }

    if (priorityFilter != null) {
      filtered = filtered
          .where((task) => task.priority == priorityFilter)
          .toList();
    }

    return filtered;
  }

  List<Task> _rebuildFilteredTasks(TasksLoaded baseState, List<Task> allTasks) {
    var filtered = _applyCurrentFilters(
      allTasks,
      baseState.currentStatusFilter,
      baseState.currentPriorityFilter,
    );

    final query = baseState.searchQuery;
    if (query != null && query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      filtered = filtered
          .where(
            (task) =>
                task.title.toLowerCase().contains(lowerQuery) ||
                task.description.toLowerCase().contains(lowerQuery),
          )
          .toList();
    }

    return filtered;
  }
}
