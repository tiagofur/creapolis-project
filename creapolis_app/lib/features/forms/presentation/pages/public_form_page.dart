import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../injection.dart';
import '../../domain/entities/form_entity.dart';
import '../bloc/form_bloc.dart';
import '../bloc/form_event.dart';
import '../bloc/form_state.dart' as bloc_state;

class PublicFormPage extends StatelessWidget {
  final String publicLink;

  const PublicFormPage({super.key, required this.publicLink});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<FormBloc>()..add(GetPublicFormEvent(publicLink)),
      child: _PublicFormView(publicLink: publicLink),
    );
  }
}

class _PublicFormView extends StatefulWidget {
  final String publicLink;

  const _PublicFormView({required this.publicLink});

  @override
  State<_PublicFormView> createState() => _PublicFormViewState();
}

class _PublicFormViewState extends State<_PublicFormView> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      context.read<FormBloc>().add(
        SubmitPublicFormEvent(publicLink: widget.publicLink, data: _formData),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Creapolis Forms'), centerTitle: true),
      body: BlocConsumer<FormBloc, bloc_state.FormState>(
        listener: (context, state) {
          if (state.status == bloc_state.FormStatus.success) {
            // Show success message and maybe redirect or clear form
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
                content: const Text(
                  '¡Formulario enviado con éxito!\nGracias por tu respuesta.',
                  textAlign: TextAlign.center,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      // Reset form or navigate away?
                      // For now, just reload the page to allow another submission or stay there
                      // Ideally, show a success state in the page itself.
                    },
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
            ).then((_) {
              // Reset state to loaded to show the form again, or keep success state
              // For now let's just keep the success state visible or reset
            });
          } else if (state.status == bloc_state.FormStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ?? 'Error al enviar el formulario',
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == bloc_state.FormStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == bloc_state.FormStatus.success) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 80,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '¡Enviado!',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.selectedForm?.config.settings.confirmationMessage ??
                          'Tu respuesta ha sido registrada correctamente.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: () {
                        // Reload the form to allow another submission
                        context.read<FormBloc>().add(
                          GetPublicFormEvent(widget.publicLink),
                        );
                      },
                      child: const Text('Enviar otra respuesta'),
                    ),
                  ],
                ),
              ),
            );
          }

          final form = state.selectedForm;
          if (form == null) {
            return const Center(child: Text('Formulario no encontrado'));
          }

          if (!form.isActive) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.block, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Este formulario ya no acepta respuestas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        form.title,
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      if (form.description != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          form.description!,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 32),
                      ...form.config.fields.map((field) => _buildField(field)),
                      const SizedBox(height: 32),
                      FilledButton(
                        onPressed: _submitForm,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Enviar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildField(FormFieldConfig field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${field.label}${field.required ? ' *' : ''}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          _buildInput(field),
        ],
      ),
    );
  }

  Widget _buildInput(FormFieldConfig field) {
    switch (field.type) {
      case 'textarea':
        return TextFormField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 4,
          validator: field.required
              ? (value) => value == null || value.isEmpty
                    ? 'Este campo es obligatorio'
                    : null
              : null,
          onSaved: (value) => _formData[field.id] = value,
        );
      case 'number':
        return TextFormField(
          decoration: const InputDecoration(border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
          validator: field.required
              ? (value) => value == null || value.isEmpty
                    ? 'Este campo es obligatorio'
                    : null
              : null,
          onSaved: (value) => _formData[field.id] = value,
        );
      case 'select':
        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: field.options?.map((option) {
            return DropdownMenuItem(value: option, child: Text(option));
          }).toList(),
          onChanged: (value) {
            _formData[field.id] = value;
          },
          validator: field.required
              ? (value) => value == null ? 'Selecciona una opción' : null
              : null,
        );
      case 'checkbox':
        return FormField<bool>(
          initialValue: false,
          validator: field.required
              ? (value) => value != true ? 'Debes marcar esta casilla' : null
              : null,
          onSaved: (value) => _formData[field.id] = value,
          builder: (state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckboxListTile(
                  title: Text(
                    field.label,
                  ), // Redundant label? Maybe hide main label for checkbox
                  value: state.value,
                  onChanged: state.didChange,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      state.errorText!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      case 'date':
        // Simple date picker implementation
        return FormField<String>(
          validator: field.required
              ? (value) => value == null || value.isEmpty
                    ? 'Selecciona una fecha'
                    : null
              : null,
          onSaved: (value) => _formData[field.id] = value,
          builder: (state) {
            return InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  state.didChange(date.toIso8601String().split('T')[0]);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  errorText: state.errorText,
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(state.value ?? 'Seleccionar fecha'),
              ),
            );
          },
        );
      case 'text':
      default:
        return TextFormField(
          decoration: const InputDecoration(border: OutlineInputBorder()),
          validator: field.required
              ? (value) => value == null || value.isEmpty
                    ? 'Este campo es obligatorio'
                    : null
              : null,
          onSaved: (value) => _formData[field.id] = value,
        );
    }
  }
}
