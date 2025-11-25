import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../injection.dart';
import '../../../../presentation/widgets/common/common_widgets.dart';
import '../../domain/entities/form_entity.dart';
import '../bloc/form_bloc.dart';
import '../bloc/form_event.dart';
import '../bloc/form_state.dart' as bloc_state;
import '../widgets/form_field_editor.dart';

class FormBuilderPage extends StatelessWidget {
  final int projectId;
  final int? formId;

  const FormBuilderPage({super.key, required this.projectId, this.formId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = getIt<FormBloc>();
        if (formId != null) {
          bloc.add(GetFormByIdEvent(formId!));
        }
        return bloc;
      },
      child: _FormBuilderView(projectId: projectId, formId: formId),
    );
  }
}

class _FormBuilderView extends StatefulWidget {
  final int projectId;
  final int? formId;

  const _FormBuilderView({required this.projectId, this.formId});

  @override
  State<_FormBuilderView> createState() => _FormBuilderViewState();
}

class _FormBuilderViewState extends State<_FormBuilderView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _confirmationMessageController;

  List<FormFieldConfig> _fields = [];
  bool _isActive = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _confirmationMessageController = TextEditingController();

    if (widget.formId == null) {
      _isInitialized = true;
      // Add a default field for new forms
      _addField();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _confirmationMessageController.dispose();
    super.dispose();
  }

  void _addField() {
    setState(() {
      _fields.add(
        FormFieldConfig(
          id: const Uuid().v4(),
          type: 'text',
          label: 'Nuevo Campo',
          required: false,
        ),
      );
    });
  }

  void _removeField(int index) {
    setState(() {
      _fields.removeAt(index);
    });
  }

  void _updateField(int index, FormFieldConfig newConfig) {
    setState(() {
      _fields[index] = newConfig;
    });
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_fields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes agregar al menos un campo al formulario'),
        ),
      );
      return;
    }

    final config = FormConfig(
      fields: _fields,
      settings: FormSettings(
        confirmationMessage: _confirmationMessageController.text.isNotEmpty
            ? _confirmationMessageController.text
            : null,
      ),
    );

    if (widget.formId != null) {
      context.read<FormBloc>().add(
        UpdateFormEvent(
          formId: widget.formId!,
          title: _titleController.text,
          description: _descriptionController.text,
          config: config,
          isActive: _isActive,
        ),
      );
    } else {
      context.read<FormBloc>().add(
        CreateFormEvent(
          projectId: widget.projectId,
          title: _titleController.text,
          description: _descriptionController.text,
          config: config,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FormBloc, bloc_state.FormState>(
      listener: (context, state) {
        if (state.status == bloc_state.FormStatus.loaded &&
            state.selectedForm != null &&
            !_isInitialized) {
          final form = state.selectedForm!;
          _titleController.text = form.title;
          _descriptionController.text = form.description ?? '';
          _confirmationMessageController.text =
              form.config.settings.confirmationMessage ?? '';
          setState(() {
            _fields = List.from(form.config.fields);
            _isActive = form.isActive;
            _isInitialized = true;
          });
        } else if (state.status == bloc_state.FormStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Formulario guardado exitosamente')),
          );
          context.pop();
        } else if (state.status == bloc_state.FormStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Error al guardar')),
          );
        }
      },
      builder: (context, state) {
        if (state.status == bloc_state.FormStatus.loading && !_isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: CreopolisAppBar(
            title: widget.formId != null
                ? 'Editar Formulario'
                : 'Nuevo Formulario',
            actions: [
              TextButton.icon(
                onPressed: state.status == bloc_state.FormStatus.loading
                    ? null
                    : _saveForm,
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información General',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Título del Formulario',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa un título';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Descripción (Opcional)',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        if (widget.formId != null) ...[
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text('Formulario Activo'),
                            subtitle: const Text(
                              'Los usuarios pueden enviar respuestas',
                            ),
                            value: _isActive,
                            onChanged: (value) {
                              setState(() {
                                _isActive = value;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Campos del Formulario',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    FilledButton.icon(
                      onPressed: _addField,
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar Campo'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_fields.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('Agrega campos para construir tu formulario'),
                    ),
                  )
                else
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _fields.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final item = _fields.removeAt(oldIndex);
                        _fields.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      return KeyedSubtree(
                        key: ValueKey(_fields[index].id),
                        child: FormFieldEditor(
                          field: _fields[index],
                          onDelete: () => _removeField(index),
                          onChange: (newConfig) =>
                              _updateField(index, newConfig),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
