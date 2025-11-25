import 'package:flutter/material.dart';

import '../../../../domain/entities/automation.dart';

/// List tile widget for displaying an automation
class AutomationListTile extends StatelessWidget {
  final Automation automation;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final VoidCallback onViewLogs;

  const AutomationListTile({
    super.key,
    required this.automation,
    required this.onToggle,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
    required this.onViewLogs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Switch(
          value: automation.isActive,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          automation.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: automation.isActive
                ? null
                : theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        subtitle: automation.description != null
            ? Text(
                automation.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: automation.isActive
                      ? null
                      : theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              )
            : null,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;
              case 'duplicate':
                onDuplicate();
                break;
              case 'logs':
                onViewLogs();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'duplicate',
              child: ListTile(
                leading: Icon(Icons.copy),
                title: Text('Duplicate'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'logs',
              child: ListTile(
                leading: Icon(Icons.history),
                title: Text('View Logs'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: theme.colorScheme.error),
                title: Text(
                  'Delete',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Triggers section
                _buildSectionHeader(context, 'When...', Icons.flash_on),
                const SizedBox(height: 8),
                ...automation.triggers.map(
                  (trigger) => _buildTriggerChip(context, trigger),
                ),
                const SizedBox(height: 16),

                // Actions section
                _buildSectionHeader(context, 'Then...', Icons.play_arrow),
                const SizedBox(height: 8),
                ...automation.actions.map(
                  (action) => _buildActionChip(context, action),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTriggerChip(BuildContext context, AutomationTrigger trigger) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getTriggerIcon(trigger.triggerType),
                  size: 16,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  trigger.triggerType.displayName,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (trigger.conditions != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${trigger.conditions!.rules.length} condition(s)',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionChip(BuildContext context, AutomationAction action) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '${action.order + 1}.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getActionIcon(action.actionType),
                  size: 16,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  action.actionType.displayName,
                  style: TextStyle(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTriggerIcon(TriggerType type) {
    switch (type) {
      case TriggerType.taskCreated:
        return Icons.add_task;
      case TriggerType.taskUpdated:
        return Icons.edit;
      case TriggerType.taskStatusChanged:
        return Icons.swap_horiz;
      case TriggerType.taskAssigned:
        return Icons.person_add;
      case TriggerType.taskDueDateApproaching:
        return Icons.schedule;
      case TriggerType.taskOverdue:
        return Icons.warning;
      case TriggerType.taskCompleted:
        return Icons.check_circle;
      case TriggerType.commentAdded:
        return Icons.comment;
      case TriggerType.customFieldChanged:
        return Icons.tune;
    }
  }

  IconData _getActionIcon(ActionType type) {
    switch (type) {
      case ActionType.updateStatus:
        return Icons.swap_horiz;
      case ActionType.updatePriority:
        return Icons.flag;
      case ActionType.assignUser:
        return Icons.person_add;
      case ActionType.unassignUser:
        return Icons.person_remove;
      case ActionType.addComment:
        return Icons.comment;
      case ActionType.sendNotification:
        return Icons.notifications;
      case ActionType.updateCustomField:
        return Icons.tune;
      case ActionType.moveToProject:
        return Icons.drive_file_move;
      case ActionType.createSubtask:
        return Icons.playlist_add;
      case ActionType.sendWebhook:
        return Icons.webhook;
      case ActionType.sendEmail:
        return Icons.email;
    }
  }
}
