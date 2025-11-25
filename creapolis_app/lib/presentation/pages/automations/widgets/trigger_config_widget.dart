import 'package:flutter/material.dart';

import '../../../../domain/entities/automation.dart';
import 'automation_form_dialog.dart';

/// Widget for configuring a trigger
class TriggerConfigWidget extends StatelessWidget {
  final TriggerConfig trigger;
  final Function(TriggerConfig) onUpdate;
  final VoidCallback onDelete;

  const TriggerConfigWidget({
    super.key,
    required this.trigger,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getTriggerIcon(trigger.triggerType),
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trigger.triggerType.displayName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        trigger.triggerType.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onDelete,
                  tooltip: 'Remove trigger',
                ),
              ],
            ),
            if (_hasConditions(trigger.triggerType)) ...[
              const Divider(height: 24),
              _buildConditionsEditor(context),
            ],
          ],
        ),
      ),
    );
  }

  bool _hasConditions(TriggerType type) {
    // These trigger types can have conditions
    return type == TriggerType.taskStatusChanged ||
        type == TriggerType.taskUpdated ||
        type == TriggerType.customFieldChanged ||
        type == TriggerType.taskDueDateApproaching;
  }

  Widget _buildConditionsEditor(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conditions (optional)',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 8),
        _buildTriggerConditionFields(context),
      ],
    );
  }

  Widget _buildTriggerConditionFields(BuildContext context) {
    final theme = Theme.of(context);

    switch (trigger.triggerType) {
      case TriggerType.taskStatusChanged:
        return _buildStatusCondition(context);
      case TriggerType.taskDueDateApproaching:
        return _buildDueDateCondition(context);
      case TriggerType.customFieldChanged:
        return _buildCustomFieldCondition(context);
      default:
        return Text(
          'Configure conditions when available',
          style: theme.textTheme.bodySmall?.copyWith(
            fontStyle: FontStyle.italic,
          ),
        );
    }
  }

  Widget _buildStatusCondition(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'From Status',
            isDense: true,
          ),
          initialValue: trigger.conditions?.rules.firstOrNull?.value,
          items: const [
            DropdownMenuItem(value: null, child: Text('Any')),
            DropdownMenuItem(value: 'BACKLOG', child: Text('Backlog')),
            DropdownMenuItem(value: 'TODO', child: Text('To Do')),
            DropdownMenuItem(value: 'IN_PROGRESS', child: Text('In Progress')),
            DropdownMenuItem(value: 'IN_REVIEW', child: Text('In Review')),
            DropdownMenuItem(value: 'DONE', child: Text('Done')),
          ],
          onChanged: (value) {
            // Update conditions
            final newConditions = TriggerConditions(
              operator: 'AND',
              rules: [
                if (value != null)
                  ConditionRule(
                    field: 'fromStatus',
                    op: 'equals',
                    value: value,
                  ),
              ],
            );
            onUpdate(trigger.copyWith(conditions: newConditions));
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'To Status',
            isDense: true,
          ),
          initialValue: null,
          items: const [
            DropdownMenuItem(value: null, child: Text('Any')),
            DropdownMenuItem(value: 'BACKLOG', child: Text('Backlog')),
            DropdownMenuItem(value: 'TODO', child: Text('To Do')),
            DropdownMenuItem(value: 'IN_PROGRESS', child: Text('In Progress')),
            DropdownMenuItem(value: 'IN_REVIEW', child: Text('In Review')),
            DropdownMenuItem(value: 'DONE', child: Text('Done')),
          ],
          onChanged: (value) {
            // Update conditions
          },
        ),
      ],
    );
  }

  Widget _buildDueDateCondition(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Days before due date',
        isDense: true,
        hintText: 'e.g., 3',
        suffixText: 'days',
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        final days = int.tryParse(value);
        if (days != null) {
          final newConditions = TriggerConditions(
            operator: 'AND',
            rules: [
              ConditionRule(
                field: 'daysBefore',
                op: 'equals',
                value: days.toString(),
              ),
            ],
          );
          onUpdate(trigger.copyWith(conditions: newConditions));
        }
      },
    );
  }

  Widget _buildCustomFieldCondition(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Field Name',
            isDense: true,
            hintText: 'Enter custom field name',
          ),
          onChanged: (value) {
            // Update conditions
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'New Value (optional)',
            isDense: true,
            hintText: 'Trigger when field changes to this value',
          ),
          onChanged: (value) {
            // Update conditions
          },
        ),
      ],
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
}
