import 'package:flutter/material.dart';
import '../../domain/entities/form_entity.dart';

class FormFieldEditor extends StatefulWidget {
  final FormFieldConfig field;
  final VoidCallback onDelete;
  final ValueChanged<FormFieldConfig> onChange;

  const FormFieldEditor({
    super.key,
    required this.field,
    required this.onDelete,
    required this.onChange,
  });

  @override
  State<FormFieldEditor> createState() => _FormFieldEditorState();
}

class _FormFieldEditorState extends State<FormFieldEditor> {
  late TextEditingController _labelController;
  late String _selectedType;
  late bool _isRequired;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.field.label);
    _selectedType = widget.field.type;
    _isRequired = widget.field.required;
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _updateField() {
    widget.onChange(
      FormFieldConfig(
        id: widget.field.id,
        type: _selectedType,
        label: _labelController.text,
        required: _isRequired,
        mapTo: widget.field.mapTo,
        options: widget.field.options,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.drag_handle, color: Colors.grey[400]),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _labelController,
                    decoration: const InputDecoration(
                      labelText: 'Etiqueta del campo',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => _updateField(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(width: 36), // Align with text field
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de campo',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'text',
                        child: Text('Texto Corto'),
                      ),
                      DropdownMenuItem(
                        value: 'textarea',
                        child: Text('Texto Largo'),
                      ),
                      DropdownMenuItem(value: 'number', child: Text('Número')),
                      DropdownMenuItem(value: 'date', child: Text('Fecha')),
                      DropdownMenuItem(
                        value: 'select',
                        child: Text('Selección'),
                      ),
                      DropdownMenuItem(
                        value: 'checkbox',
                        child: Text('Casilla'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedType = value;
                        });
                        _updateField();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                FilterChip(
                  label: const Text('Obligatorio'),
                  selected: _isRequired,
                  onSelected: (value) {
                    setState(() {
                      _isRequired = value;
                    });
                    _updateField();
                  },
                ),
              ],
            ),
            if (_selectedType == 'select') ...[
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.only(left: 36),
                child: Text('Opciones (separadas por coma):'),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 36, top: 4),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Opción 1, Opción 2, Opción 3',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  controller: TextEditingController(
                    text: widget.field.options?.join(', ') ?? '',
                  ),
                  onChanged: (value) {
                    final options = value
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();
                    widget.onChange(
                      FormFieldConfig(
                        id: widget.field.id,
                        type: _selectedType,
                        label: _labelController.text,
                        required: _isRequired,
                        mapTo: widget.field.mapTo,
                        options: options,
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
