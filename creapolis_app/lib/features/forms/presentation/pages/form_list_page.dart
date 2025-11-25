import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../injection.dart';
import '../../../../presentation/widgets/common/common_widgets.dart';
import '../../../../routes/app_router.dart';
import '../../domain/entities/form_entity.dart';
import '../bloc/form_bloc.dart';
import '../bloc/form_event.dart';
import '../bloc/form_state.dart' as bloc_state;

class FormListPage extends StatelessWidget {
  final int projectId;
  final int workspaceId;

  const FormListPage({
    super.key,
    required this.projectId,
    required this.workspaceId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<FormBloc>()..add(GetFormsByProjectEvent(projectId)),
      child: _FormListView(workspaceId: workspaceId, projectId: projectId),
    );
  }
}

class _FormListView extends StatelessWidget {
  final int workspaceId;
  final int projectId;

  const _FormListView({
    required this.workspaceId,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CreopolisAppBar(title: 'Formularios'),
      body: BlocConsumer<FormBloc, bloc_state.FormState>(
        listener: (context, state) {
          if (state.status == bloc_state.FormStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Error desconocido'),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == bloc_state.FormStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.forms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay formularios',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea un formulario para empezar a recibir respuestas',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.forms.length,
            itemBuilder: (context, index) {
              final form = state.forms[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    form.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (form.description != null) ...[
                        Text(
                          form.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                      ],
                      Row(
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            size: 16,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${form.viewCount}',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.send_outlined,
                            size: 16,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${form.submitCount}',
                            style: theme.textTheme.bodySmall,
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: form.isActive
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: form.isActive
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),
                            child: Text(
                              form.isActive ? 'Activo' : 'Inactivo',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: form.isActive
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'copy_link',
                        child: Row(
                          children: [
                            Icon(Icons.link, size: 20),
                            SizedBox(width: 8),
                            Text('Copiar enlace'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Eliminar',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteDialog(context, form);
                      } else if (value == 'copy_link') {
                        Clipboard.setData(ClipboardData(
                          text: 'https://creapolis.app/forms/public/${form.publicLink}',
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Enlace copiado al portapapeles'),
                          ),
                        );
                      } else if (value == 'edit') {
                        context.pushNamed(
                          RouteNames.editForm,
                          pathParameters: {
                            'wId': workspaceId.toString(),
                            'pId': form.projectId.toString(),
                            'formId': form.id.toString(),
                          },
                        );
                      }
                    },
                  ),
                  onTap: () {
                    context.pushNamed(
                      RouteNames.editForm,
                      pathParameters: {
                        'wId': workspaceId.toString(),
                        'pId': form.projectId.toString(),
                        'formId': form.id.toString(),
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed(
            RouteNames.createForm,
            pathParameters: {
              'wId': workspaceId.toString(),
              'pId': projectId.toString(),
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, FormEntity form) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Formulario'),
        content: Text('¿Estás seguro de que deseas eliminar "${form.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              context.read<FormBloc>().add(DeleteFormEvent(form.id));
              Navigator.pop(dialogContext);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
