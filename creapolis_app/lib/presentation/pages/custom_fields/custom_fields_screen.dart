import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/custom_field.dart';
import '../../../injection.dart';
import '../../bloc/custom_field/custom_field_bloc.dart';
import '../../bloc/custom_field/custom_field_event.dart';
import '../../bloc/custom_field/custom_field_state.dart';
import '../../providers/workspace_context.dart';
import '../../shared/widgets/error_widget.dart' as app;
import '../../shared/widgets/loading_widget.dart';
import '../../widgets/common/project_picker_dialog.dart';
import 'widgets/custom_field_form_dialog.dart';
import 'widgets/custom_field_list_tile.dart';

/// Screen for managing custom field definitions for a project
class CustomFieldsScreen extends StatelessWidget {
  final int projectId;
  final String projectName;

  const CustomFieldsScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CustomFieldBloc>()
        ..add(
          LoadFieldDefinitionsEvent(
            projectId: projectId,
            includeInactive: true,
          ),
        ),
      child: _CustomFieldsScreenContent(
        projectId: projectId,
        projectName: projectName,
      ),
    );
  }
}

class _CustomFieldsScreenContent extends StatelessWidget {
  final int projectId;
  final String projectName;

  const _CustomFieldsScreenContent({
    required this.projectId,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Custom Fields'),
            Text(
              projectName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(178),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy from another project',
            onPressed: () => _showCopyDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Field'),
      ),
      body: BlocConsumer<CustomFieldBloc, CustomFieldState>(
        listener: (context, state) {
          if (state is FieldDefinitionCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Field "${state.definition.name}" created'),
                backgroundColor: Colors.green,
              ),
            );
            // Reload definitions
            context.read<CustomFieldBloc>().add(
              LoadFieldDefinitionsEvent(
                projectId: projectId,
                includeInactive: true,
              ),
            );
          } else if (state is FieldDefinitionUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Field "${state.definition.name}" updated'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<CustomFieldBloc>().add(
              LoadFieldDefinitionsEvent(
                projectId: projectId,
                includeInactive: true,
              ),
            );
          } else if (state is FieldDefinitionDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Field deleted'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<CustomFieldBloc>().add(
              LoadFieldDefinitionsEvent(
                projectId: projectId,
                includeInactive: true,
              ),
            );
          } else if (state is FieldDefinitionsCopied) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.definitions.length} fields copied'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<CustomFieldBloc>().add(
              LoadFieldDefinitionsEvent(
                projectId: projectId,
                includeInactive: true,
              ),
            );
          } else if (state is CustomFieldError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CustomFieldLoading) {
            return const LoadingWidget(message: 'Loading custom fields...');
          }

          if (state is FieldDefinitionsLoaded) {
            if (state.definitions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.tune,
                      size: 64,
                      color: theme.colorScheme.onSurface.withAlpha(77),
                    ),
                    const SizedBox(height: 16),
                    Text('No Custom Fields', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      'Add custom fields to track additional\ninformation on tasks.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(153),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => _showCreateDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Field'),
                    ),
                  ],
                ),
              );
            }

            return ReorderableListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: state.definitions.length,
              onReorder: (oldIndex, newIndex) {
                if (oldIndex < newIndex) newIndex--;
                final orderedIds = state.definitions.map((d) => d.id).toList();
                final id = orderedIds.removeAt(oldIndex);
                orderedIds.insert(newIndex, id);
                context.read<CustomFieldBloc>().add(
                  ReorderFieldDefinitionsEvent(
                    projectId: projectId,
                    orderedIds: orderedIds,
                  ),
                );
              },
              itemBuilder: (context, index) {
                final field = state.definitions[index];
                return CustomFieldListTile(
                  key: ValueKey(field.id),
                  field: field,
                  onEdit: () => _showEditDialog(context, field),
                  onDelete: () => _confirmDelete(context, field),
                  onToggleActive: () {
                    context.read<CustomFieldBloc>().add(
                      UpdateFieldDefinitionEvent(
                        projectId: projectId,
                        fieldId: field.id,
                        isActive: !field.isActive,
                      ),
                    );
                  },
                );
              },
            );
          }

          if (state is CustomFieldError) {
            return app.ErrorWidget(
              message: state.message,
              onRetry: () => context.read<CustomFieldBloc>().add(
                LoadFieldDefinitionsEvent(
                  projectId: projectId,
                  includeInactive: true,
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => CustomFieldFormDialog(
        projectId: projectId,
        onSave: (name, type, description, isRequired, defaultValue, options) {
          context.read<CustomFieldBloc>().add(
            CreateFieldDefinitionEvent(
              projectId: projectId,
              name: name,
              type: type,
              description: description,
              isRequired: isRequired,
              defaultValue: defaultValue,
              options: options,
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, CustomFieldDefinition field) {
    showDialog(
      context: context,
      builder: (dialogContext) => CustomFieldFormDialog(
        projectId: projectId,
        existingField: field,
        onSave: (name, type, description, isRequired, defaultValue, options) {
          context.read<CustomFieldBloc>().add(
            UpdateFieldDefinitionEvent(
              projectId: projectId,
              fieldId: field.id,
              name: name,
              description: description,
              isRequired: isRequired,
              defaultValue: defaultValue,
              options: options,
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, CustomFieldDefinition field) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Field'),
        content: Text(
          'Are you sure you want to delete "${field.name}"? '
          'This will also delete all values set for this field on tasks.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CustomFieldBloc>().add(
                DeleteFieldDefinitionEvent(
                  projectId: projectId,
                  fieldId: field.id,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCopyDialog(BuildContext context) async {
    // Obtener el workspace actual
    final workspaceContext = context.read<WorkspaceContext>();
    final workspaceId = workspaceContext.activeWorkspace?.id;

    if (workspaceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active workspace selected'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Mostrar diálogo de selección de proyecto
    final result = await showProjectPickerDialog(
      context: context,
      workspaceId: workspaceId,
      excludeProjectId: projectId,
      title: 'Copy fields from project',
    );

    if (result == null || !context.mounted) return;

    // Confirmar la copia
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Copy Custom Fields'),
        content: Text(
          'Copy all custom fields from "${result.project.name}" to "$projectName"?\n\n'
          'This will add new fields without removing existing ones.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Copy Fields'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<CustomFieldBloc>().add(
        CopyFieldDefinitionsEvent(
          sourceProjectId: result.project.id,
          targetProjectId: projectId,
        ),
      );
    }
  }
}
