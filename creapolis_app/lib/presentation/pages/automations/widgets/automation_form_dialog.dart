import 'package:flutter/material.dart';

import '../../../../domain/entities/automation.dart';
import 'trigger_config_widget.dart';
import 'action_config_widget.dart';

/// Dialog for creating or editing an automation
class AutomationFormDialog extends StatefulWidget {
  final Automation? automation;
  final int projectId;

  const AutomationFormDialog({
    super.key,
    this.automation,
    required this.projectId,
  });

  @override
  State<AutomationFormDialog> createState() => _AutomationFormDialogState();
}

class _AutomationFormDialogState extends State<AutomationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<TriggerConfig> _triggers = [];
  List<ActionConfig> _actions = [];

  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    if (widget.automation != null) {
      _nameController.text = widget.automation!.name;
      _descriptionController.text = widget.automation!.description ?? '';
      _triggers = widget.automation!.triggers.map((t) {
        return TriggerConfig(
          triggerType: t.triggerType,
          conditions: t.conditions,
        );
      }).toList();
      _actions = widget.automation!.actions.map((a) {
        return ActionConfig(actionType: a.actionType, config: a.actionData);
      }).toList();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.automation != null;

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Automation' : 'Create Automation'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            TextButton(
              onPressed: _canSave() ? _handleSave : null,
              child: const Text('Save'),
            ),
          ],
        ),
        body: Stepper(
          currentStep: _currentStep,
          onStepContinue: _onStepContinue,
          onStepCancel: _onStepCancel,
          onStepTapped: (step) => setState(() => _currentStep = step),
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  if (details.currentStep < 2)
                    FilledButton(
                      onPressed: details.onStepContinue,
                      child: const Text('Continue'),
                    ),
                  if (details.currentStep > 0) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back'),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            // Step 1: Basic info
            Step(
              title: const Text('Basic Info'),
              subtitle: const Text('Name and description'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: _buildBasicInfoStep(theme),
            ),
            // Step 2: Triggers
            Step(
              title: const Text('Triggers'),
              subtitle: Text(
                _triggers.isEmpty
                    ? 'Add at least one trigger'
                    : '${_triggers.length} trigger(s)',
              ),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 && _triggers.isNotEmpty
                  ? StepState.complete
                  : StepState.indexed,
              content: _buildTriggersStep(theme),
            ),
            // Step 3: Actions
            Step(
              title: const Text('Actions'),
              subtitle: Text(
                _actions.isEmpty
                    ? 'Add at least one action'
                    : '${_actions.length} action(s)',
              ),
              isActive: _currentStep >= 2,
              state: _actions.isNotEmpty
                  ? StepState.complete
                  : StepState.indexed,
              content: _buildActionsStep(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoStep(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Automation Name',
              hintText: 'e.g., Auto-assign high priority tasks',
              prefixIcon: Icon(Icons.bolt),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              hintText: 'Describe what this automation does',
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTriggersStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'When should this automation run?',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 16),
        ..._triggers.asMap().entries.map((entry) {
          final index = entry.key;
          final trigger = entry.value;

          return TriggerConfigWidget(
            key: ValueKey('trigger_$index'),
            trigger: trigger,
            onUpdate: (updated) {
              setState(() {
                _triggers[index] = updated;
              });
            },
            onDelete: () {
              setState(() {
                _triggers.removeAt(index);
              });
            },
          );
        }),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _addTrigger,
          icon: const Icon(Icons.add),
          label: const Text('Add Trigger'),
        ),
      ],
    );
  }

  Widget _buildActionsStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What should happen when the automation runs?',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 16),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) newIndex--;
              final item = _actions.removeAt(oldIndex);
              _actions.insert(newIndex, item);
            });
          },
          children: _actions.asMap().entries.map((entry) {
            final index = entry.key;
            final action = entry.value;

            return ActionConfigWidget(
              key: ValueKey('action_$index'),
              action: action,
              order: index,
              onUpdate: (updated) {
                setState(() {
                  _actions[index] = updated;
                });
              },
              onDelete: () {
                setState(() {
                  _actions.removeAt(index);
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _addAction,
          icon: const Icon(Icons.add),
          label: const Text('Add Action'),
        ),
      ],
    );
  }

  void _addTrigger() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _TriggerTypeSelector(
        onSelect: (type) {
          Navigator.pop(context);
          setState(() {
            _triggers.add(TriggerConfig(triggerType: type));
          });
        },
      ),
    );
  }

  void _addAction() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ActionTypeSelector(
        onSelect: (type) {
          Navigator.pop(context);
          setState(() {
            _actions.add(ActionConfig(actionType: type));
          });
        },
      ),
    );
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  bool _canSave() {
    return _nameController.text.isNotEmpty &&
        _triggers.isNotEmpty &&
        _actions.isNotEmpty;
  }

  void _handleSave() {
    // Convert TriggerConfig list to AutomationTrigger list
    final triggers = _triggers.asMap().entries.map((entry) {
      return AutomationTrigger(
        id: 0, // Will be assigned by server
        triggerType: entry.value.triggerType,
        conditions: entry.value.conditions,
      );
    }).toList();

    // Convert ActionConfig list to AutomationAction list
    final actions = _actions.asMap().entries.map((entry) {
      return AutomationAction(
        id: 0, // Will be assigned by server
        actionType: entry.value.actionType,
        actionData: entry.value.config ?? {},
        order: entry.key,
      );
    }).toList();

    Navigator.pop(context, {
      'name': _nameController.text,
      'description': _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      'triggers': triggers,
      'actions': actions,
    });
  }
}

/// Trigger type selector bottom sheet
class _TriggerTypeSelector extends StatelessWidget {
  final Function(TriggerType) onSelect;

  const _TriggerTypeSelector({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Select Trigger Type',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: TriggerType.values.length,
              itemBuilder: (context, index) {
                final type = TriggerType.values[index];
                return ListTile(
                  leading: Icon(_getTriggerIcon(type)),
                  title: Text(type.displayName),
                  subtitle: Text(type.description),
                  onTap: () => onSelect(type),
                );
              },
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
}

/// Action type selector bottom sheet
class _ActionTypeSelector extends StatelessWidget {
  final Function(ActionType) onSelect;

  const _ActionTypeSelector({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Select Action Type',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: ActionType.values.length,
              itemBuilder: (context, index) {
                final type = ActionType.values[index];
                return ListTile(
                  leading: Icon(_getActionIcon(type)),
                  title: Text(type.displayName),
                  subtitle: Text(type.description),
                  onTap: () => onSelect(type),
                );
              },
            ),
          ),
        ],
      ),
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

/// Configuration for a trigger
class TriggerConfig {
  final TriggerType triggerType;
  final TriggerConditions? conditions;

  TriggerConfig({required this.triggerType, this.conditions});

  TriggerConfig copyWith({
    TriggerType? triggerType,
    TriggerConditions? conditions,
  }) {
    return TriggerConfig(
      triggerType: triggerType ?? this.triggerType,
      conditions: conditions ?? this.conditions,
    );
  }
}

/// Configuration for an action
class ActionConfig {
  final ActionType actionType;
  final Map<String, dynamic>? config;

  ActionConfig({required this.actionType, this.config});

  ActionConfig copyWith({
    ActionType? actionType,
    Map<String, dynamic>? config,
  }) {
    return ActionConfig(
      actionType: actionType ?? this.actionType,
      config: config ?? this.config,
    );
  }
}
