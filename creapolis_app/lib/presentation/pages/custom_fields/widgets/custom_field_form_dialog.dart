import 'package:flutter/material.dart';

import '../../../../domain/entities/custom_field.dart';

/// Dialog for creating or editing a custom field definition
class CustomFieldFormDialog extends StatefulWidget {
  final int projectId;
  final CustomFieldDefinition? existingField;
  final void Function(
    String name,
    CustomFieldType type,
    String? description,
    bool isRequired,
    dynamic defaultValue,
    Map<String, dynamic>? options,
  )
  onSave;

  const CustomFieldFormDialog({
    super.key,
    required this.projectId,
    this.existingField,
    required this.onSave,
  });

  @override
  State<CustomFieldFormDialog> createState() => _CustomFieldFormDialogState();
}

class _CustomFieldFormDialogState extends State<CustomFieldFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _optionsController;
  late CustomFieldType _selectedType;
  late bool _isRequired;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingField?.name ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingField?.description ?? '',
    );
    _selectedType = widget.existingField?.type ?? CustomFieldType.text;
    _isRequired = widget.existingField?.isRequired ?? false;

    // Initialize options controller for dropdown/multiselect
    final existingOptions = widget.existingField?.dropdownOptions ?? [];
    _optionsController = TextEditingController(
      text: existingOptions.join('\n'),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _optionsController.dispose();
    super.dispose();
  }

  bool get _needsOptions =>
      _selectedType == CustomFieldType.dropdown ||
      _selectedType == CustomFieldType.multiselect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existingField != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Field' : 'Add Custom Field'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Field Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Field Name',
                    hintText: 'e.g., Priority Score, Client Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Field name is required';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Field Type
                DropdownButtonFormField<CustomFieldType>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Field Type',
                    border: OutlineInputBorder(),
                  ),
                  items: CustomFieldType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Icon(
                                _getFieldTypeIcon(type),
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(type.displayName),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: isEditing
                      ? null // Can't change type after creation
                      : (value) {
                          if (value != null) {
                            setState(() => _selectedType = value);
                          }
                        },
                ),
                if (isEditing)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Field type cannot be changed after creation',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Options for dropdown/multiselect
                if (_needsOptions) ...[
                  TextFormField(
                    controller: _optionsController,
                    decoration: InputDecoration(
                      labelText: 'Options',
                      hintText: 'Enter one option per line',
                      border: const OutlineInputBorder(),
                      helperText:
                          'Enter each option on a new line (e.g., Low\\nMedium\\nHigh)',
                      helperMaxLines: 2,
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (_needsOptions &&
                          (value == null || value.trim().isEmpty)) {
                        return 'At least one option is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Help text for users filling this field',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Required checkbox
                CheckboxListTile(
                  value: _isRequired,
                  onChanged: (value) {
                    setState(() => _isRequired = value ?? false);
                  },
                  title: const Text('Required field'),
                  subtitle: const Text(
                    'Users must fill this field when creating tasks',
                  ),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _onSave,
          child: Text(isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    Map<String, dynamic>? options;
    if (_needsOptions) {
      final optionsList = _optionsController.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      options = {'choices': optionsList};
    }

    widget.onSave(
      _nameController.text.trim(),
      _selectedType,
      _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      _isRequired,
      null, // defaultValue - could be added later
      options,
    );

    Navigator.pop(context);
  }

  IconData _getFieldTypeIcon(CustomFieldType type) {
    switch (type) {
      case CustomFieldType.text:
        return Icons.short_text;
      case CustomFieldType.textarea:
        return Icons.notes;
      case CustomFieldType.number:
        return Icons.numbers;
      case CustomFieldType.decimal:
        return Icons.calculate;
      case CustomFieldType.currency:
        return Icons.attach_money;
      case CustomFieldType.percentage:
        return Icons.percent;
      case CustomFieldType.date:
        return Icons.calendar_today;
      case CustomFieldType.datetime:
        return Icons.schedule;
      case CustomFieldType.checkbox:
        return Icons.check_box_outlined;
      case CustomFieldType.dropdown:
        return Icons.arrow_drop_down_circle_outlined;
      case CustomFieldType.multiselect:
        return Icons.checklist;
      case CustomFieldType.user:
        return Icons.person;
      case CustomFieldType.multiuser:
        return Icons.people;
      case CustomFieldType.url:
        return Icons.link;
      case CustomFieldType.email:
        return Icons.email;
      case CustomFieldType.phone:
        return Icons.phone;
    }
  }
}
