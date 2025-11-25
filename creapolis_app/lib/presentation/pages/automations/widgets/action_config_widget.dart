import 'package:flutter/material.dart';

import '../../../../domain/entities/automation.dart';
import 'automation_form_dialog.dart';

/// Widget for configuring an action
class ActionConfigWidget extends StatelessWidget {
  final ActionConfig action;
  final int order;
  final Function(ActionConfig) onUpdate;
  final VoidCallback onDelete;

  const ActionConfigWidget({
    super.key,
    required this.action,
    required this.order,
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
                // Drag handle
                ReorderableDragStartListener(
                  index: order,
                  child: const Icon(Icons.drag_handle),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${order + 1}',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  _getActionIcon(action.actionType),
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.actionType.displayName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        action.actionType.description,
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
                  tooltip: 'Remove action',
                ),
              ],
            ),
            const Divider(height: 24),
            _buildActionConfigFields(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionConfigFields(BuildContext context) {
    switch (action.actionType) {
      case ActionType.updateStatus:
        return _buildStatusConfig(context);
      case ActionType.updatePriority:
        return _buildPriorityConfig(context);
      case ActionType.assignUser:
        return _buildAssignUserConfig(context);
      case ActionType.unassignUser:
        return _buildUnassignUserConfig(context);
      case ActionType.addComment:
        return _buildCommentConfig(context);
      case ActionType.sendNotification:
        return _buildNotificationConfig(context);
      case ActionType.updateCustomField:
        return _buildCustomFieldConfig(context);
      case ActionType.moveToProject:
        return _buildMoveToProjectConfig(context);
      case ActionType.createSubtask:
        return _buildCreateSubtaskConfig(context);
      case ActionType.sendWebhook:
        return _buildWebhookConfig(context);
      case ActionType.sendEmail:
        return _buildEmailConfig(context);
    }
  }

  Widget _buildStatusConfig(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'New Status', isDense: true),
      initialValue: action.config?['status'],
      items: const [
        DropdownMenuItem(value: 'BACKLOG', child: Text('Backlog')),
        DropdownMenuItem(value: 'TODO', child: Text('To Do')),
        DropdownMenuItem(value: 'IN_PROGRESS', child: Text('In Progress')),
        DropdownMenuItem(value: 'IN_REVIEW', child: Text('In Review')),
        DropdownMenuItem(value: 'DONE', child: Text('Done')),
      ],
      onChanged: (value) {
        onUpdate(action.copyWith(config: {'status': value}));
      },
    );
  }

  Widget _buildPriorityConfig(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'New Priority',
        isDense: true,
      ),
      initialValue: action.config?['priority'],
      items: const [
        DropdownMenuItem(value: 'LOW', child: Text('Low')),
        DropdownMenuItem(value: 'MEDIUM', child: Text('Medium')),
        DropdownMenuItem(value: 'HIGH', child: Text('High')),
        DropdownMenuItem(value: 'URGENT', child: Text('Urgent')),
      ],
      onChanged: (value) {
        onUpdate(action.copyWith(config: {'priority': value}));
      },
    );
  }

  Widget _buildAssignUserConfig(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'User ID or Email',
        isDense: true,
        hintText: 'Enter user ID or email address',
        prefixIcon: Icon(Icons.person_add),
      ),
      initialValue: action.config?['userId'],
      onChanged: (value) {
        onUpdate(action.copyWith(config: {'userId': value}));
      },
    );
  }

  Widget _buildUnassignUserConfig(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          title: const Text('Remove all assignees'),
          value: action.config?['removeAll'] ?? false,
          onChanged: (value) {
            onUpdate(action.copyWith(config: {'removeAll': value}));
          },
          contentPadding: EdgeInsets.zero,
        ),
        if (!(action.config?['removeAll'] ?? false))
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Specific User ID (optional)',
              isDense: true,
              hintText: 'Leave empty to remove current assignee',
            ),
            initialValue: action.config?['userId'],
            onChanged: (value) {
              final config = Map<String, dynamic>.from(action.config ?? {});
              config['userId'] = value;
              onUpdate(action.copyWith(config: config));
            },
          ),
      ],
    );
  }

  Widget _buildCommentConfig(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Comment Text',
        isDense: true,
        hintText: 'Use {{task.title}}, {{user.name}} for variables',
        prefixIcon: Icon(Icons.comment),
      ),
      initialValue: action.config?['text'],
      maxLines: 3,
      onChanged: (value) {
        onUpdate(action.copyWith(config: {'text': value}));
      },
    );
  }

  Widget _buildNotificationConfig(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Send To',
            isDense: true,
          ),
          initialValue: action.config?['recipient'] ?? 'assignee',
          items: const [
            DropdownMenuItem(value: 'assignee', child: Text('Task Assignee')),
            DropdownMenuItem(value: 'creator', child: Text('Task Creator')),
            DropdownMenuItem(
              value: 'project_members',
              child: Text('All Project Members'),
            ),
            DropdownMenuItem(value: 'specific', child: Text('Specific User')),
          ],
          onChanged: (value) {
            final config = Map<String, dynamic>.from(action.config ?? {});
            config['recipient'] = value;
            onUpdate(action.copyWith(config: config));
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Message',
            isDense: true,
            hintText: 'Notification message',
            prefixIcon: Icon(Icons.notifications),
          ),
          initialValue: action.config?['message'],
          maxLines: 2,
          onChanged: (value) {
            final config = Map<String, dynamic>.from(action.config ?? {});
            config['message'] = value;
            onUpdate(action.copyWith(config: config));
          },
        ),
      ],
    );
  }

  Widget _buildCustomFieldConfig(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Field Name',
            isDense: true,
            hintText: 'Name of the custom field',
          ),
          initialValue: action.config?['fieldName'],
          onChanged: (value) {
            final config = Map<String, dynamic>.from(action.config ?? {});
            config['fieldName'] = value;
            onUpdate(action.copyWith(config: config));
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'New Value',
            isDense: true,
            hintText: 'Value to set for the field',
          ),
          initialValue: action.config?['value'],
          onChanged: (value) {
            final config = Map<String, dynamic>.from(action.config ?? {});
            config['value'] = value;
            onUpdate(action.copyWith(config: config));
          },
        ),
      ],
    );
  }

  Widget _buildMoveToProjectConfig(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Target Project ID',
        isDense: true,
        hintText: 'Enter the project ID to move task to',
        prefixIcon: Icon(Icons.drive_file_move),
      ),
      initialValue: action.config?['projectId'],
      onChanged: (value) {
        onUpdate(action.copyWith(config: {'projectId': value}));
      },
    );
  }

  Widget _buildCreateSubtaskConfig(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Subtask Title',
            isDense: true,
            hintText: 'Title for the new subtask',
            prefixIcon: Icon(Icons.playlist_add),
          ),
          initialValue: action.config?['title'],
          onChanged: (value) {
            final config = Map<String, dynamic>.from(action.config ?? {});
            config['title'] = value;
            onUpdate(action.copyWith(config: config));
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Description (optional)',
            isDense: true,
          ),
          initialValue: action.config?['description'],
          maxLines: 2,
          onChanged: (value) {
            final config = Map<String, dynamic>.from(action.config ?? {});
            config['description'] = value;
            onUpdate(action.copyWith(config: config));
          },
        ),
      ],
    );
  }

  Widget _buildWebhookConfig(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Webhook URL',
            isDense: true,
            hintText: 'https://api.example.com/webhook',
            prefixIcon: Icon(Icons.webhook),
          ),
          initialValue: action.config?['url'],
          onChanged: (value) {
            final config = Map<String, dynamic>.from(action.config ?? {});
            config['url'] = value;
            onUpdate(action.copyWith(config: config));
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'HTTP Method',
            isDense: true,
          ),
          initialValue: action.config?['method'] ?? 'POST',
          items: const [
            DropdownMenuItem(value: 'POST', child: Text('POST')),
            DropdownMenuItem(value: 'PUT', child: Text('PUT')),
            DropdownMenuItem(value: 'PATCH', child: Text('PATCH')),
          ],
          onChanged: (value) {
            final config = Map<String, dynamic>.from(action.config ?? {});
            config['method'] = value;
            onUpdate(action.copyWith(config: config));
          },
        ),
      ],
    );
  }

  Widget _buildEmailConfig(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Recipient Email',
            isDense: true,
            hintText: 'email@example.com',
            prefixIcon: Icon(Icons.email),
          ),
          initialValue: action.config?['email'],
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            final config = Map<String, dynamic>.from(action.config ?? {});
            config['email'] = value;
            onUpdate(action.copyWith(config: config));
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Subject',
            isDense: true,
            hintText: 'Email subject line',
          ),
          initialValue: action.config?['subject'],
          onChanged: (value) {
            final config = Map<String, dynamic>.from(action.config ?? {});
            config['subject'] = value;
            onUpdate(action.copyWith(config: config));
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Body',
            isDense: true,
            hintText: 'Email body content',
          ),
          initialValue: action.config?['body'],
          maxLines: 3,
          onChanged: (value) {
            final config = Map<String, dynamic>.from(action.config ?? {});
            config['body'] = value;
            onUpdate(action.copyWith(config: config));
          },
        ),
      ],
    );
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
