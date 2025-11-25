import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:creapolis_app/features/projects/presentation/blocs/sprint/sprint_bloc.dart';
import 'package:creapolis_app/injection.dart';
import 'package:creapolis_app/domain/entities/sprint.dart';
import 'package:creapolis_app/domain/entities/task.dart';

class SprintBoardScreen extends StatefulWidget {
  final int projectId;

  const SprintBoardScreen({Key? key, required this.projectId})
    : super(key: key);

  @override
  State<SprintBoardScreen> createState() => _SprintBoardScreenState();
}

class _SprintBoardScreenState extends State<SprintBoardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<SprintBloc>()..add(LoadSprints(widget.projectId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Agile Board'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Active Sprint'),
              Tab(text: 'Backlog'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _ActiveSprintTab(projectId: widget.projectId),
            _BacklogTab(projectId: widget.projectId),
          ],
        ),
      ),
    );
  }
}

class _ActiveSprintTab extends StatelessWidget {
  final int projectId;

  const _ActiveSprintTab({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SprintBloc, SprintState>(
      buildWhen: (previous, current) =>
          current is SprintsLoaded || current is SprintLoading,
      builder: (context, state) {
        if (state is SprintLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SprintsLoaded) {
          final activeSprint = state.sprints
              .where((s) => s.status == SprintStatus.active)
              .firstOrNull;

          if (activeSprint == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No active sprint'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to backlog or show create sprint dialog
                    },
                    child: const Text('Go to Backlog'),
                  ),
                ],
              ),
            );
          }

          return _KanbanBoard(sprint: activeSprint);
        }
        return const Center(child: Text('Something went wrong'));
      },
    );
  }
}

class _KanbanBoard extends StatelessWidget {
  final Sprint sprint;

  const _KanbanBoard({required this.sprint});

  @override
  Widget build(BuildContext context) {
    // Group tasks by status
    final todoTasks = sprint.tasks
        .where((t) => t.status == TaskStatus.planned)
        .toList();
    final inProgressTasks = sprint.tasks
        .where((t) => t.status == TaskStatus.inProgress)
        .toList();
    final doneTasks = sprint.tasks
        .where((t) => t.status == TaskStatus.completed)
        .toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _KanbanColumn(title: 'To Do', tasks: todoTasks),
          _KanbanColumn(title: 'In Progress', tasks: inProgressTasks),
          _KanbanColumn(title: 'Done', tasks: doneTasks),
        ],
      ),
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  final String title;
  final List<Task> tasks;

  const _KanbanColumn({required this.title, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(task.title),
                    subtitle: Text('${task.storyPoints ?? 0} pts'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BacklogTab extends StatelessWidget {
  final int projectId;

  const _BacklogTab({required this.projectId});

  @override
  Widget build(BuildContext context) {
    // Trigger load backlog when this tab is built
    context.read<SprintBloc>().add(LoadBacklog(projectId));

    return BlocBuilder<SprintBloc, SprintState>(
      buildWhen: (previous, current) =>
          current is BacklogLoaded || current is SprintLoading,
      builder: (context, state) {
        if (state is SprintLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is BacklogLoaded) {
          return ListView.builder(
            itemCount: state.tasks.length,
            itemBuilder: (context, index) {
              final task = state.tasks[index];
              return ListTile(
                title: Text(task.title),
                subtitle: Text('Priority: ${task.priority.name}'),
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    // Add to next sprint
                  },
                ),
              );
            },
          );
        }
        return const Center(child: Text('Backlog empty'));
      },
    );
  }
}
