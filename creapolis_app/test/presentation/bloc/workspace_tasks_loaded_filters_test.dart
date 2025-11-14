import 'package:flutter_test/flutter_test.dart';
import 'package:creapolis_app/presentation/bloc/task/task_state.dart';
import 'package:creapolis_app/domain/entities/task.dart';
import 'package:creapolis_app/domain/entities/project.dart';

Task _task({
  required int id,
  required String title,
  String description = '',
  TaskStatus status = TaskStatus.planned,
  TaskPriority priority = TaskPriority.medium,
  int projectId = 1,
}) {
  return Task(
    id: id,
    title: title,
    description: description,
    status: status,
    priority: priority,
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 1)),
    estimatedHours: 1,
    actualHours: 0,
    projectId: projectId,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    updatedAt: DateTime.now(),
  );
}

void main() {
  test('WorkspaceTasksLoaded filteredTasks by search/status/priority', () {
    final tasks = [
      _task(id: 1, title: 'Plan design', description: 'UI', status: TaskStatus.planned, priority: TaskPriority.high),
      _task(id: 2, title: 'Implement feature', description: 'API', status: TaskStatus.inProgress, priority: TaskPriority.critical),
      _task(id: 3, title: 'Write docs', description: 'Readme', status: TaskStatus.completed, priority: TaskPriority.low),
    ];

    final state = WorkspaceTasksLoaded(
      workspaceId: 10,
      tasks: tasks,
      projectById: {
        1: Project(
          id: 1,
          name: 'P1',
          description: 'Test',
          startDate: DateTime.now().subtract(const Duration(days: 10)),
          endDate: DateTime.now().add(const Duration(days: 10)),
          status: ProjectStatus.active,
          workspaceId: 10,
          createdAt: DateTime.now().subtract(const Duration(days: 11)),
          updatedAt: DateTime.now(),
        )
      },
    );

    // Search by "imp"
    final s1 = state.copyWith(searchQuery: 'imp');
    expect(s1.filteredTasks.length, 1);
    expect(s1.filteredTasks.first.id, 2);

    // Filter by status
    final s2 = state.copyWith(currentStatusFilter: TaskStatus.completed);
    expect(s2.filteredTasks.length, 1);
    expect(s2.filteredTasks.first.id, 3);

    // Filter by priority
    final s3 = state.copyWith(currentPriorityFilter: TaskPriority.high);
    expect(s3.filteredTasks.length, 1);
    expect(s3.filteredTasks.first.id, 1);

    // Combined search + status
    final s4 = state.copyWith(searchQuery: 'docs', currentStatusFilter: TaskStatus.completed);
    expect(s4.filteredTasks.length, 1);
    expect(s4.filteredTasks.first.id, 3);

    // Clear filters
    final s5 = s4.copyWith(clearSearchQuery: true, clearStatusFilter: true);
    expect(s5.filteredTasks.length, 3);
  });
}
