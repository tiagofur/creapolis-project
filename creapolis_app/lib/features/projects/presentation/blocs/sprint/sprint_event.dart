part of 'sprint_bloc.dart';

abstract class SprintEvent extends Equatable {
  const SprintEvent();

  @override
  List<Object?> get props => [];
}

class LoadSprints extends SprintEvent {
  final int projectId;
  final SprintStatus? status;

  const LoadSprints(this.projectId, {this.status});

  @override
  List<Object?> get props => [projectId, status];
}

class LoadBacklog extends SprintEvent {
  final int projectId;

  const LoadBacklog(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class CreateSprint extends SprintEvent {
  final int projectId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String? goal;

  const CreateSprint({
    required this.projectId,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.goal,
  });

  @override
  List<Object?> get props => [projectId, name, startDate, endDate, goal];
}

class UpdateSprint extends SprintEvent {
  final int id;
  final String? name;
  final String? goal;
  final DateTime? startDate;
  final DateTime? endDate;

  const UpdateSprint(
    this.id, {
    this.name,
    this.goal,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [id, name, goal, startDate, endDate];
}

class DeleteSprint extends SprintEvent {
  final int id;

  const DeleteSprint(this.id);

  @override
  List<Object?> get props => [id];
}

class StartSprint extends SprintEvent {
  final int id;

  const StartSprint(this.id);

  @override
  List<Object?> get props => [id];
}

class CompleteSprint extends SprintEvent {
  final int id;

  const CompleteSprint(this.id);

  @override
  List<Object?> get props => [id];
}

class AddTasksToSprint extends SprintEvent {
  final int sprintId;
  final List<int> taskIds;

  const AddTasksToSprint(this.sprintId, this.taskIds);

  @override
  List<Object?> get props => [sprintId, taskIds];
}

class RemoveTasksFromSprint extends SprintEvent {
  final int sprintId;
  final List<int> taskIds;

  const RemoveTasksFromSprint(this.sprintId, this.taskIds);

  @override
  List<Object?> get props => [sprintId, taskIds];
}
