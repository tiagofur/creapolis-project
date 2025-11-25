part of 'sprint_bloc.dart';

abstract class SprintState extends Equatable {
  const SprintState();

  @override
  List<Object?> get props => [];
}

class SprintInitial extends SprintState {}

class SprintLoading extends SprintState {}

class SprintsLoaded extends SprintState {
  final List<Sprint> sprints;

  const SprintsLoaded(this.sprints);

  @override
  List<Object?> get props => [sprints];
}

class BacklogLoaded extends SprintState {
  final List<Task> tasks;

  const BacklogLoaded(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class SprintOperationSuccess extends SprintState {
  final String message;
  final Sprint? sprint; // Optional updated sprint

  const SprintOperationSuccess(this.message, {this.sprint});

  @override
  List<Object?> get props => [message, sprint];
}

class SprintError extends SprintState {
  final String message;

  const SprintError(this.message);

  @override
  List<Object?> get props => [message];
}
