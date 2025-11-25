import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/automation.dart';
import '../../../injection.dart';
import '../../bloc/automation/automation_bloc.dart';
import 'widgets/automation_list_tile.dart';
import 'widgets/automation_form_dialog.dart';
import 'widgets/automation_logs_dialog.dart';

/// Screen to manage project automations
class AutomationsScreen extends StatelessWidget {
  final int projectId;
  final String projectName;

  const AutomationsScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<AutomationBloc>()
            ..add(LoadAutomations(projectId: projectId, includeInactive: true)),
      child: AutomationsView(projectId: projectId, projectName: projectName),
    );
  }
}

class AutomationsView extends StatefulWidget {
  final int projectId;
  final String projectName;

  const AutomationsView({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<AutomationsView> createState() => _AutomationsViewState();
}

class _AutomationsViewState extends State<AutomationsView> {
  bool _showInactive = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Automations'),
            Text(
              widget.projectName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        actions: [
          // Toggle inactive filter
          IconButton(
            icon: Icon(
              _showInactive ? Icons.visibility : Icons.visibility_off_outlined,
            ),
            tooltip: _showInactive ? 'Showing all' : 'Showing active only',
            onPressed: () {
              setState(() => _showInactive = !_showInactive);
              context.read<AutomationBloc>().add(
                LoadAutomations(
                  projectId: widget.projectId,
                  includeInactive: _showInactive,
                ),
              );
            },
          ),
          // Stats
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'View stats',
            onPressed: () {
              _showStats(context);
            },
          ),
        ],
      ),
      body: BlocConsumer<AutomationBloc, AutomationState>(
        listener: (context, state) {
          if (state is AutomationCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Automation "${state.automation.name}" created'),
                backgroundColor: Colors.green,
              ),
            );
            _reloadAutomations();
          } else if (state is AutomationUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Automation updated'),
                backgroundColor: Colors.green,
              ),
            );
            _reloadAutomations();
          } else if (state is AutomationDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Automation deleted'),
                backgroundColor: Colors.green,
              ),
            );
            _reloadAutomations();
          } else if (state is AutomationToggled) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.automation.isActive
                      ? 'Automation enabled'
                      : 'Automation disabled',
                ),
              ),
            );
            _reloadAutomations();
          } else if (state is AutomationDuplicated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Automation duplicated as "${state.automation.name}"',
                ),
                backgroundColor: Colors.green,
              ),
            );
            _reloadAutomations();
          } else if (state is AutomationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AutomationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AutomationsLoaded) {
            if (state.automations.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async => _reloadAutomations(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.automations.length,
                itemBuilder: (context, index) {
                  final automation = state.automations[index];
                  return AutomationListTile(
                    automation: automation,
                    onToggle: () => _toggleAutomation(automation),
                    onEdit: () => _editAutomation(automation),
                    onDuplicate: () => _duplicateAutomation(automation),
                    onDelete: () => _deleteAutomation(automation),
                    onViewLogs: () => _viewLogs(automation),
                  );
                },
              ),
            );
          }

          if (state is AutomationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading automations',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _reloadAutomations,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createAutomation(),
        icon: const Icon(Icons.add),
        label: const Text('Add Automation'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_fix_high,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text('No Automations Yet', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(
              'Create automations to automate repetitive tasks.\n'
              'For example: "When a task is completed, notify the project manager"',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _createAutomation(),
              icon: const Icon(Icons.add),
              label: const Text('Create First Automation'),
            ),
          ],
        ),
      ),
    );
  }

  void _reloadAutomations() {
    context.read<AutomationBloc>().add(
      LoadAutomations(
        projectId: widget.projectId,
        includeInactive: _showInactive,
      ),
    );
  }

  void _createAutomation() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AutomationFormDialog(projectId: widget.projectId),
    );

    if (result != null && mounted) {
      context.read<AutomationBloc>().add(
        CreateAutomation(
          projectId: widget.projectId,
          name: result['name'] as String,
          description: result['description'] as String?,
          triggers: result['triggers'] as List<AutomationTrigger>,
          actions: result['actions'] as List<AutomationAction>,
        ),
      );
    }
  }

  void _editAutomation(Automation automation) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AutomationFormDialog(
        projectId: widget.projectId,
        automation: automation,
      ),
    );

    if (result != null && mounted) {
      context.read<AutomationBloc>().add(
        UpdateAutomation(
          projectId: widget.projectId,
          automationId: automation.id,
          name: result['name'] as String?,
          description: result['description'] as String?,
          triggers: result['triggers'] as List<AutomationTrigger>?,
          actions: result['actions'] as List<AutomationAction>?,
        ),
      );
    }
  }

  void _toggleAutomation(Automation automation) {
    context.read<AutomationBloc>().add(
      ToggleAutomation(
        projectId: widget.projectId,
        automationId: automation.id,
      ),
    );
  }

  void _duplicateAutomation(Automation automation) {
    context.read<AutomationBloc>().add(
      DuplicateAutomation(
        projectId: widget.projectId,
        automationId: automation.id,
      ),
    );
  }

  void _deleteAutomation(Automation automation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Automation'),
        content: Text(
          'Are you sure you want to delete "${automation.name}"?\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<AutomationBloc>().add(
        DeleteAutomation(
          projectId: widget.projectId,
          automationId: automation.id,
        ),
      );
    }
  }

  void _viewLogs(Automation automation) {
    // Load logs for this automation
    context.read<AutomationBloc>().add(
      LoadAutomationLogs(automationId: automation.id),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<AutomationBloc>(),
        child: BlocBuilder<AutomationBloc, AutomationState>(
          builder: (ctx, state) {
            if (state is AutomationLogsLoaded) {
              return AutomationLogsDialog(
                logs: state.logs,
                automationName: automation.name,
              );
            }

            return const AlertDialog(
              content: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showStats(BuildContext context) {
    context.read<AutomationBloc>().add(
      LoadAutomationStats(projectId: widget.projectId),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<AutomationBloc>(),
        child: BlocBuilder<AutomationBloc, AutomationState>(
          builder: (context, state) {
            if (state is AutomationStatsLoaded) {
              return AlertDialog(
                title: const Text('Automation Statistics'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatRow(
                      'Total Executions',
                      state.stats.totalExecutions.toString(),
                    ),
                    _buildStatRow(
                      'Average Duration',
                      '${state.stats.averageDuration}ms',
                    ),
                    const Divider(),
                    const Text(
                      'By Status:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...state.stats.byStatus.entries.map(
                      (e) => _buildStatRow(e.key, e.value.toString()),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Close'),
                  ),
                ],
              );
            }

            return const AlertDialog(
              content: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
