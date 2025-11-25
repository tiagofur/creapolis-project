import 'package:flutter/material.dart';

import '../../../../domain/entities/custom_field.dart';

/// List tile for displaying a custom field definition
class CustomFieldListTile extends StatelessWidget {
  final CustomFieldDefinition field;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  const CustomFieldListTile({
    super.key,
    required this.field,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInactive = !field.isActive;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Opacity(
        opacity: isInactive ? 0.5 : 1.0,
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getFieldTypeColor(field.type).withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFieldTypeIcon(field.type),
              color: _getFieldTypeColor(field.type),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  field.name,
                  style: isInactive
                      ? theme.textTheme.titleMedium?.copyWith(
                          decoration: TextDecoration.lineThrough,
                        )
                      : theme.textTheme.titleMedium,
                ),
              ),
              if (field.isRequired)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Required',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field.type.displayName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              if (field.description != null && field.description!.isNotEmpty)
                Text(
                  field.description!,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Active/Inactive toggle
              IconButton(
                icon: Icon(
                  isInactive ? Icons.visibility_off : Icons.visibility,
                  color: isInactive
                      ? theme.colorScheme.outline
                      : theme.colorScheme.primary,
                ),
                tooltip: isInactive ? 'Activate' : 'Deactivate',
                onPressed: onToggleActive,
              ),
              // Edit button
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  color: theme.colorScheme.primary,
                ),
                tooltip: 'Edit',
                onPressed: onEdit,
              ),
              // Delete button
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                ),
                tooltip: 'Delete',
                onPressed: onDelete,
              ),
              // Drag handle
              ReorderableDragStartListener(
                index: 0, // Index will be set by parent
                child: Icon(
                  Icons.drag_handle,
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
          isThreeLine:
              field.description != null && field.description!.isNotEmpty,
        ),
      ),
    );
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
        return Icons.onetwothree;
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

  Color _getFieldTypeColor(CustomFieldType type) {
    switch (type) {
      case CustomFieldType.text:
      case CustomFieldType.textarea:
        return Colors.blue;
      case CustomFieldType.number:
      case CustomFieldType.decimal:
      case CustomFieldType.currency:
      case CustomFieldType.percentage:
        return Colors.purple;
      case CustomFieldType.date:
      case CustomFieldType.datetime:
        return Colors.orange;
      case CustomFieldType.checkbox:
        return Colors.green;
      case CustomFieldType.dropdown:
      case CustomFieldType.multiselect:
        return Colors.teal;
      case CustomFieldType.user:
      case CustomFieldType.multiuser:
        return Colors.indigo;
      case CustomFieldType.url:
      case CustomFieldType.email:
      case CustomFieldType.phone:
        return Colors.cyan;
    }
  }
}
