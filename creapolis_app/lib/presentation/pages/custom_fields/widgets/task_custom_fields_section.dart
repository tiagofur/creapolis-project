import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../domain/entities/custom_field.dart';
import '../../../../injection.dart';
import '../../../bloc/custom_field/custom_field_bloc.dart';
import '../../../bloc/custom_field/custom_field_event.dart';
import '../../../bloc/custom_field/custom_field_state.dart';

/// Widget for displaying and editing custom field values for a task
class TaskCustomFieldsSection extends StatelessWidget {
  final int taskId;
  final int projectId;
  final bool isEditable;

  const TaskCustomFieldsSection({
    super.key,
    required this.taskId,
    required this.projectId,
    this.isEditable = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<CustomFieldBloc>()
            ..add(LoadFieldDefinitionsEvent(projectId: projectId)),
      child: _TaskCustomFieldsSectionContent(
        taskId: taskId,
        projectId: projectId,
        isEditable: isEditable,
      ),
    );
  }
}

class _TaskCustomFieldsSectionContent extends StatefulWidget {
  final int taskId;
  final int projectId;
  final bool isEditable;

  const _TaskCustomFieldsSectionContent({
    required this.taskId,
    required this.projectId,
    required this.isEditable,
  });

  @override
  State<_TaskCustomFieldsSectionContent> createState() =>
      _TaskCustomFieldsSectionContentState();
}

class _TaskCustomFieldsSectionContentState
    extends State<_TaskCustomFieldsSectionContent> {
  List<CustomFieldDefinition> _definitions = [];
  List<CustomFieldValue> _values = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Load definitions first, then values
    final bloc = context.read<CustomFieldBloc>();
    bloc.add(LoadFieldDefinitionsEvent(projectId: widget.projectId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<CustomFieldBloc, CustomFieldState>(
      listener: (context, state) {
        if (state is FieldDefinitionsLoaded) {
          setState(() {
            _definitions = state.activeDefinitions;
          });
          // Now load values
          context.read<CustomFieldBloc>().add(
            LoadFieldValuesEvent(taskId: widget.taskId),
          );
        } else if (state is FieldValuesLoaded) {
          setState(() {
            _values = state.values;
            _isLoading = false;
          });
        } else if (state is FieldValueSet || state is FieldValuesSet) {
          // Reload values after update
          context.read<CustomFieldBloc>().add(
            LoadFieldValuesEvent(taskId: widget.taskId),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Field value saved'),
              duration: Duration(seconds: 1),
            ),
          );
        } else if (state is CustomFieldError) {
          setState(() {
            _error = state.message;
            _isLoading = false;
          });
        }
      },
      builder: (context, state) {
        if (_isLoading) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (_error != null) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _error!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          );
        }

        if (_definitions.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'No custom fields defined for this project',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.tune, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Custom Fields',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ..._definitions.map((definition) {
              final value = _values.firstWhere(
                (v) => v.fieldId == definition.id,
                orElse: () => CustomFieldValue(
                  id: 0,
                  taskId: widget.taskId,
                  fieldId: definition.id,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              );

              return _CustomFieldRow(
                definition: definition,
                value: value,
                isEditable: widget.isEditable,
                onValueChanged: (newValue) {
                  context.read<CustomFieldBloc>().add(
                    SetFieldValueEvent(
                      taskId: widget.taskId,
                      fieldId: definition.id,
                      value: newValue,
                    ),
                  );
                },
              );
            }),
          ],
        );
      },
    );
  }
}

class _CustomFieldRow extends StatelessWidget {
  final CustomFieldDefinition definition;
  final CustomFieldValue value;
  final bool isEditable;
  final ValueChanged<dynamic> onValueChanged;

  const _CustomFieldRow({
    required this.definition,
    required this.value,
    required this.isEditable,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      title: Row(
        children: [
          Text(definition.name, style: theme.textTheme.bodyMedium),
          if (definition.isRequired)
            Text(
              ' *',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
      subtitle: definition.description != null
          ? Text(
              definition.description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            )
          : null,
      trailing: SizedBox(width: 200, child: _buildFieldInput(context)),
    );
  }

  Widget _buildFieldInput(BuildContext context) {
    final theme = Theme.of(context);

    switch (definition.type) {
      case CustomFieldType.text:
      case CustomFieldType.textarea:
      case CustomFieldType.url:
      case CustomFieldType.email:
      case CustomFieldType.phone:
        return TextFormField(
          initialValue: value.value?.toString() ?? '',
          enabled: isEditable,
          decoration: InputDecoration(
            hintText: _getPlaceholder(),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            isDense: true,
          ),
          maxLines: definition.type == CustomFieldType.textarea ? 3 : 1,
          keyboardType: _getKeyboardType(),
          onFieldSubmitted: onValueChanged,
        );

      case CustomFieldType.number:
      case CustomFieldType.decimal:
      case CustomFieldType.currency:
      case CustomFieldType.percentage:
        return TextFormField(
          initialValue: value.value?.toString() ?? '',
          enabled: isEditable,
          decoration: InputDecoration(
            hintText: '0',
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            isDense: true,
            prefixText: definition.type == CustomFieldType.currency
                ? '${definition.currencyCode ?? '\$'} '
                : null,
            suffixText: definition.type == CustomFieldType.percentage
                ? '%'
                : null,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onFieldSubmitted: (val) {
            final parsed = definition.type == CustomFieldType.number
                ? int.tryParse(val)
                : double.tryParse(val);
            if (parsed != null) onValueChanged(parsed);
          },
        );

      case CustomFieldType.date:
        return InkWell(
          onTap: isEditable
              ? () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: value.value is DateTime
                        ? value.value as DateTime
                        : DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    onValueChanged(date.toIso8601String());
                  }
                }
              : null,
          child: InputDecorator(
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              isDense: true,
              suffixIcon: const Icon(Icons.calendar_today, size: 18),
            ),
            child: Text(
              _formatDate(value.value),
              style: theme.textTheme.bodyMedium,
            ),
          ),
        );

      case CustomFieldType.datetime:
        return InkWell(
          onTap: isEditable
              ? () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: value.value is DateTime
                        ? value.value as DateTime
                        : DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null && context.mounted) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      final dateTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                      onValueChanged(dateTime.toIso8601String());
                    }
                  }
                }
              : null,
          child: InputDecorator(
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              isDense: true,
              suffixIcon: const Icon(Icons.schedule, size: 18),
            ),
            child: Text(
              _formatDateTime(value.value),
              style: theme.textTheme.bodyMedium,
            ),
          ),
        );

      case CustomFieldType.checkbox:
        return Checkbox(
          value: value.value == true,
          onChanged: isEditable ? (val) => onValueChanged(val) : null,
        );

      case CustomFieldType.dropdown:
        final options = definition.dropdownOptions;
        return DropdownButtonFormField<String>(
          initialValue: options.contains(value.value?.toString())
              ? value.value?.toString()
              : null,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            isDense: true,
          ),
          items: options
              .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
              .toList(),
          onChanged: isEditable ? (val) => onValueChanged(val) : null,
          hint: const Text('Select...'),
        );

      case CustomFieldType.multiselect:
        final options = definition.dropdownOptions;
        final selectedValues =
            (value.value as List<dynamic>?)?.cast<String>() ?? [];

        return InkWell(
          onTap: isEditable
              ? () => _showMultiselectDialog(context, options, selectedValues)
              : null,
          child: InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
            child: Text(
              selectedValues.isEmpty ? 'Select...' : selectedValues.join(', '),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: selectedValues.isEmpty
                    ? theme.colorScheme.outline
                    : null,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );

      case CustomFieldType.user:
      case CustomFieldType.multiuser:
        // TODO: Implement user picker
        return Text(
          value.value?.toString() ?? 'Select user...',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        );
    }
  }

  String _getPlaceholder() {
    switch (definition.type) {
      case CustomFieldType.url:
        return 'https://...';
      case CustomFieldType.email:
        return 'email@example.com';
      case CustomFieldType.phone:
        return '+1 234 567 8900';
      default:
        return 'Enter value...';
    }
  }

  TextInputType _getKeyboardType() {
    switch (definition.type) {
      case CustomFieldType.url:
        return TextInputType.url;
      case CustomFieldType.email:
        return TextInputType.emailAddress;
      case CustomFieldType.phone:
        return TextInputType.phone;
      default:
        return TextInputType.text;
    }
  }

  String _formatDate(dynamic value) {
    if (value == null) return 'Select date...';
    final date = value is DateTime
        ? value
        : DateTime.tryParse(value.toString());
    if (date == null) return 'Select date...';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatDateTime(dynamic value) {
    if (value == null) return 'Select date & time...';
    final date = value is DateTime
        ? value
        : DateTime.tryParse(value.toString());
    if (date == null) return 'Select date & time...';
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }

  Future<void> _showMultiselectDialog(
    BuildContext context,
    List<String> options,
    List<String> currentSelection,
  ) async {
    final selected = List<String>.from(currentSelection);

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Select ${definition.name}'),
        content: SizedBox(
          width: 300,
          child: StatefulBuilder(
            builder: (context, setDialogState) => ListView(
              shrinkWrap: true,
              children: options
                  .map(
                    (opt) => CheckboxListTile(
                      title: Text(opt),
                      value: selected.contains(opt),
                      onChanged: (checked) {
                        setDialogState(() {
                          if (checked == true) {
                            selected.add(opt);
                          } else {
                            selected.remove(opt);
                          }
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onValueChanged(selected);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
