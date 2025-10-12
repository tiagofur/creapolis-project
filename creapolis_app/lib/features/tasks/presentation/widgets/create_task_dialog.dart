import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:creapolis_app/features/tasks/presentation/blocs/task_bloc.dart';
import 'package:creapolis_app/features/tasks/presentation/blocs/task_event.dart';
import 'package:creapolis_app/domain/entities/task.dart';

/// Diálogo para crear una nueva tarea
class CreateTaskDialog extends StatefulWidget {
  final int projectId;

  const CreateTaskDialog({super.key, required this.projectId});

  @override
  State<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<CreateTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _estimatedHoursController = TextEditingController(text: '8');

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  TaskPriority _priority = TaskPriority.medium;
  TaskStatus _status = TaskStatus.planned;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedHoursController.dispose();
    super.dispose();
  }

  void _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        _startDate = date;
        // Si la fecha de inicio es posterior a la fecha de fin, ajustar
        if (_startDate.isAfter(_endDate)) {
          _endDate = _startDate.add(const Duration(days: 7));
        }
      });
    }
  }

  void _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate.isBefore(_startDate) ? _startDate : _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final estimatedHours =
          double.tryParse(_estimatedHoursController.text) ?? 8.0;

      context.read<TaskBloc>().add(
        CreateTask(
          projectId: widget.projectId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _priority,
          status: _status,
          estimatedHours: estimatedHours,
          startDate: _startDate,
          endDate: _endDate,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.task_alt,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Crear Tarea',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Título
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título de la tarea *',
                    hintText: 'Ej: Implementar login screen',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El título es obligatorio';
                    }
                    if (value.trim().length < 3) {
                      return 'El título debe tener al menos 3 caracteres';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 200,
                ),
                const SizedBox(height: 16),

                // Descripción
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                    hintText: 'Describe los detalles de la tarea...',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  maxLength: 1000,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

                // Prioridad
                DropdownButtonFormField<TaskPriority>(
                  value: _priority,
                  decoration: const InputDecoration(
                    labelText: 'Prioridad',
                    prefixIcon: Icon(Icons.flag),
                    border: OutlineInputBorder(),
                  ),
                  items: TaskPriority.values.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Row(
                        children: [
                          Icon(
                            _getPriorityIcon(priority),
                            color: _getPriorityColor(priority),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(priority.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _priority = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Estado
                DropdownButtonFormField<TaskStatus>(
                  value: _status,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    prefixIcon: Icon(Icons.timeline),
                    border: OutlineInputBorder(),
                  ),
                  items: TaskStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getStatusColor(status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(status.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _status = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Horas estimadas
                TextFormField(
                  controller: _estimatedHoursController,
                  decoration: const InputDecoration(
                    labelText: 'Horas estimadas *',
                    hintText: 'Ej: 8',
                    prefixIcon: Icon(Icons.schedule),
                    border: OutlineInputBorder(),
                    suffixText: 'horas',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Las horas estimadas son obligatorias';
                    }
                    final hours = double.tryParse(value);
                    if (hours == null || hours <= 0) {
                      return 'Ingresa un número válido mayor a 0';
                    }
                    if (hours > 1000) {
                      return 'Las horas no pueden exceder 1000';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Fecha de inicio
                InkWell(
                  onTap: _selectStartDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de inicio',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Fecha de fin
                InkWell(
                  onTap: _selectEndDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de fin',
                      prefixIcon: Icon(Icons.event),
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.check),
                      label: const Text('Crear Tarea'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.grey;
      case TaskPriority.medium:
        return Colors.blue;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.critical:
        return Colors.red;
    }
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Icons.arrow_downward;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.high:
        return Icons.arrow_upward;
      case TaskPriority.critical:
        return Icons.priority_high;
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.planned:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.blocked:
        return Colors.red;
      case TaskStatus.cancelled:
        return Colors.grey.shade400;
    }
  }
}
