import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:creapolis_app/domain/entities/sprint.dart';
import 'package:creapolis_app/domain/entities/task.dart';
import 'package:creapolis_app/domain/usecases/sprint/get_sprints_by_project_usecase.dart';
import 'package:creapolis_app/domain/usecases/sprint/create_sprint_usecase.dart';
import 'package:creapolis_app/domain/usecases/sprint/manage_sprint_usecase.dart';
import 'package:creapolis_app/domain/usecases/sprint/manage_sprint_tasks_usecase.dart';
import 'package:creapolis_app/domain/usecases/sprint/get_backlog_usecase.dart';

part 'sprint_event.dart';
part 'sprint_state.dart';

@injectable
class SprintBloc extends Bloc<SprintEvent, SprintState> {
  final GetSprintsByProjectUseCase getSprints;
  final CreateSprintUseCase createSprint;
  final ManageSprintUseCase manageSprint;
  final ManageSprintTasksUseCase manageSprintTasks;
  final GetBacklogUseCase getBacklog;

  SprintBloc({
    required this.getSprints,
    required this.createSprint,
    required this.manageSprint,
    required this.manageSprintTasks,
    required this.getBacklog,
  }) : super(SprintInitial()) {
    on<LoadSprints>(_onLoadSprints);
    on<LoadBacklog>(_onLoadBacklog);
    on<CreateSprint>(_onCreateSprint);
    on<UpdateSprint>(_onUpdateSprint);
    on<DeleteSprint>(_onDeleteSprint);
    on<StartSprint>(_onStartSprint);
    on<CompleteSprint>(_onCompleteSprint);
    on<AddTasksToSprint>(_onAddTasksToSprint);
    on<RemoveTasksFromSprint>(_onRemoveTasksFromSprint);
  }

  Future<void> _onLoadSprints(
    LoadSprints event,
    Emitter<SprintState> emit,
  ) async {
    emit(SprintLoading());
    final result = await getSprints(event.projectId, status: event.status);
    result.fold(
      (failure) => emit(SprintError(failure.message)),
      (sprints) => emit(SprintsLoaded(sprints)),
    );
  }

  Future<void> _onLoadBacklog(
    LoadBacklog event,
    Emitter<SprintState> emit,
  ) async {
    emit(SprintLoading());
    final result = await getBacklog(event.projectId);
    result.fold(
      (failure) => emit(SprintError(failure.message)),
      (tasks) => emit(BacklogLoaded(tasks)),
    );
  }

  Future<void> _onCreateSprint(
    CreateSprint event,
    Emitter<SprintState> emit,
  ) async {
    emit(SprintLoading());
    final result = await createSprint(
      event.projectId,
      event.name,
      event.startDate,
      event.endDate,
      goal: event.goal,
    );
    result.fold(
      (failure) => emit(SprintError(failure.message)),
      (sprint) => emit(
        SprintOperationSuccess('Sprint created successfully', sprint: sprint),
      ),
    );
  }

  Future<void> _onUpdateSprint(
    UpdateSprint event,
    Emitter<SprintState> emit,
  ) async {
    emit(SprintLoading());
    final result = await manageSprint.updateSprint(
      event.id,
      name: event.name,
      goal: event.goal,
      startDate: event.startDate,
      endDate: event.endDate,
    );
    result.fold(
      (failure) => emit(SprintError(failure.message)),
      (sprint) => emit(
        SprintOperationSuccess('Sprint updated successfully', sprint: sprint),
      ),
    );
  }

  Future<void> _onDeleteSprint(
    DeleteSprint event,
    Emitter<SprintState> emit,
  ) async {
    emit(SprintLoading());
    final result = await manageSprint.deleteSprint(event.id);
    result.fold(
      (failure) => emit(SprintError(failure.message)),
      (_) => emit(const SprintOperationSuccess('Sprint deleted successfully')),
    );
  }

  Future<void> _onStartSprint(
    StartSprint event,
    Emitter<SprintState> emit,
  ) async {
    emit(SprintLoading());
    final result = await manageSprint.startSprint(event.id);
    result.fold(
      (failure) => emit(SprintError(failure.message)),
      (sprint) => emit(
        SprintOperationSuccess('Sprint started successfully', sprint: sprint),
      ),
    );
  }

  Future<void> _onCompleteSprint(
    CompleteSprint event,
    Emitter<SprintState> emit,
  ) async {
    emit(SprintLoading());
    final result = await manageSprint.completeSprint(event.id);
    result.fold(
      (failure) => emit(SprintError(failure.message)),
      (sprint) => emit(
        SprintOperationSuccess('Sprint completed successfully', sprint: sprint),
      ),
    );
  }

  Future<void> _onAddTasksToSprint(
    AddTasksToSprint event,
    Emitter<SprintState> emit,
  ) async {
    emit(SprintLoading());
    final result = await manageSprintTasks.addTasks(
      event.sprintId,
      event.taskIds,
    );
    result.fold(
      (failure) => emit(SprintError(failure.message)),
      (_) => emit(const SprintOperationSuccess('Tasks added to sprint')),
    );
  }

  Future<void> _onRemoveTasksFromSprint(
    RemoveTasksFromSprint event,
    Emitter<SprintState> emit,
  ) async {
    emit(SprintLoading());
    final result = await manageSprintTasks.removeTasks(
      event.sprintId,
      event.taskIds,
    );
    result.fold(
      (failure) => emit(SprintError(failure.message)),
      (_) => emit(const SprintOperationSuccess('Tasks removed from sprint')),
    );
  }
}
