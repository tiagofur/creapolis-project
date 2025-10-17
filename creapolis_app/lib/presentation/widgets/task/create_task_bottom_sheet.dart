import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/task.dart';
import '../../bloc/task/task_bloc.dart';
import '../../bloc/task/task_event.dart';
import '../../blocs/project_member/project_member_bloc.dart';
import '../../blocs/project_member/project_member_event.dart';
import '../../blocs/project_member/project_member_state.dart';
import '../../../domain/entities/project_member.dart';

/// Bottom sheet para crear o editar una tarea
class CreateTaskBottomSheet extends StatefulWidget {
  final int projectId;
  final Task? task;

  const CreateTaskBottomSheet({super.key, required this.projectId, this.task});

  @override
  State<CreateTaskBottomSheet> createState() => _CreateTaskBottomSheetState();
}

class _CreateTaskBottomSheetState extends State<CreateTaskBottomSheet> {
  final _formKey = GlobalKey<FormBuilderState>();
  TaskStatus _selectedStatus = TaskStatus.planned;
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  int? _selectedAssigneeId;
  int? _initialAssigneeId;

  ProjectMemberBloc? _projectMemberBloc;
  bool _membersRequested = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _selectedStatus = widget.task!.status;
      _selectedPriority = widget.task!.priority;
      _startDate = widget.task!.startDate;
      _endDate = widget.task!.endDate;
      _selectedAssigneeId = widget.task!.assignee?.id;
    }
    _initialAssigneeId = _selectedAssigneeId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_projectMemberBloc == null) {
      try {
        _projectMemberBloc = context.read<ProjectMemberBloc>();
      } catch (_) {
        _projectMemberBloc = null;
      }
    }

    if (!_membersRequested && _projectMemberBloc != null) {
      _projectMemberBloc!.add(LoadProjectMembers(widget.projectId));
      _membersRequested = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.task != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: FormBuilder(
          key: _formKey,
          initialValue: {
            'title': widget.task?.title ?? '',
            'description': widget.task?.description ?? '',
            'estimatedHours': widget.task?.estimatedHours.toString() ?? '8',
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Editar Tarea' : 'Nueva Tarea',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Título
              FormBuilderTextField(
                name: 'title',
                decoration: InputDecoration(
                  labelText: 'Título *',
                  hintText: 'Ej: Implementar autenticación',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'El título es requerido',
                  ),
                  FormBuilderValidators.minLength(
                    3,
                    errorText: 'El título debe tener al menos 3 caracteres',
                  ),
                ]),
              ),
              const SizedBox(height: 16),

              // Descripción
              FormBuilderTextField(
                name: 'description',
                decoration: InputDecoration(
                  labelText: 'Descripción *',
                  hintText: 'Describe la tarea...',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                validator: FormBuilderValidators.required(
                  errorText: 'La descripción es requerida',
                ),
              ),
              const SizedBox(height: 16),

              // Estado y Prioridad
              Row(
                children: [
                  // Estado
                  Expanded(
                    child: DropdownButtonFormField<TaskStatus>(
                      initialValue: _selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'Estado',
                        prefixIcon: const Icon(Icons.flag),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: TaskStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedStatus = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Prioridad
                  Expanded(
                    child: DropdownButtonFormField<TaskPriority>(
                      initialValue: _selectedPriority,
                      decoration: InputDecoration(
                        labelText: 'Prioridad',
                        prefixIcon: const Icon(Icons.priority_high),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: TaskPriority.values.map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text(priority.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedPriority = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Asignación
              _buildAssigneeSelector(context),
              const SizedBox(height: 16),

              // Fechas
              Row(
                children: [
                  // Fecha inicio
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectStartDate(context),
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Fecha Inicio',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Fecha fin
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectEndDate(context),
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Fecha Fin',
                          prefixIcon: const Icon(Icons.event),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Horas estimadas
              FormBuilderTextField(
                name: 'estimatedHours',
                decoration: InputDecoration(
                  labelText: 'Horas Estimadas *',
                  hintText: 'Ej: 8',
                  prefixIcon: const Icon(Icons.schedule),
                  suffixText: 'horas',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'Las horas estimadas son requeridas',
                  ),
                  FormBuilderValidators.numeric(
                    errorText: 'Debe ser un número válido',
                  ),
                  FormBuilderValidators.min(
                    0.5,
                    errorText: 'Debe ser al menos 0.5 horas',
                  ),
                ]),
              ),
              const SizedBox(height: 24),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: _handleSubmit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(isEditing ? 'Actualizar' : 'Crear'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Seleccionar fecha de inicio
  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 7));
        }
      });
    }
  }

  /// Seleccionar fecha de fin
  Future<void> _selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != _endDate) {
      setState(() => _endDate = picked);
    }
  }

  /// Manejar envío del formulario
  void _handleSubmit() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      final title = values['title'] as String;
      final description = values['description'] as String;
      final estimatedHours = double.parse(values['estimatedHours'] as String);
      final assigneeChanged = _initialAssigneeId != _selectedAssigneeId;
      final assigneeIdForRequest = assigneeChanged ? _selectedAssigneeId : null;

      // Validar fechas
      if (_endDate.isBefore(_startDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'La fecha de fin debe ser posterior a la fecha de inicio',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (widget.task != null) {
        // Actualizar
        AppLogger.info(
          'CreateTaskBottomSheet: Actualizando tarea ${widget.task!.id}',
        );
        context.read<TaskBloc>().add(
          UpdateTaskEvent(
            projectId: widget.projectId,
            id: widget.task!.id,
            title: title,
            description: description,
            status: _selectedStatus,
            priority: _selectedPriority,
            startDate: _startDate,
            endDate: _endDate,
            estimatedHours: estimatedHours,
            assignedUserId: assigneeIdForRequest,
            updateAssignee: assigneeChanged,
          ),
        );
      } else {
        // Crear
        AppLogger.info('CreateTaskBottomSheet: Creando nueva tarea');
        context.read<TaskBloc>().add(
          CreateTaskEvent(
            title: title,
            description: description,
            status: _selectedStatus,
            priority: _selectedPriority,
            startDate: _startDate,
            endDate: _endDate,
            estimatedHours: estimatedHours,
            projectId: widget.projectId,
            assignedUserId: assigneeIdForRequest,
          ),
        );
      }

      Navigator.of(context).pop();
    }
  }

  Widget _buildAssigneeSelector(BuildContext context) {
    if (_projectMemberBloc == null) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<ProjectMemberBloc, ProjectMemberState>(
      builder: (context, state) {
        final members = _extractMembers(state);
        final isLoading =
            state is ProjectMemberLoading ||
            state is ProjectMemberInitial ||
            state is ProjectMemberOperationInProgress;
        final errorMessage = state is ProjectMemberError ? state.message : null;

        if (isLoading && members.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (errorMessage != null && members.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'No se pudieron cargar los miembros del proyecto.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  _projectMemberBloc?.add(LoadProjectMembers(widget.projectId));
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          );
        }

        if (members.isEmpty) {
          return InputDecorator(
            decoration: InputDecoration(
              labelText: 'Responsable',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'No hay miembros disponibles para asignar.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        return DropdownButtonFormField<int?>(
          initialValue: _selectedAssigneeId,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Responsable',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          hint: const Text('Selecciona un responsable (opcional)'),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('Sin asignar'),
            ),
            ...members.map(
              (member) => DropdownMenuItem<int?>(
                value: member.userId,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      child: Text(
                        member.userName.isNotEmpty
                            ? member.userName[0].toUpperCase()
                            : '?',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(member.userName)),
                  ],
                ),
              ),
            ),
          ],
          onChanged: (value) {
            setState(() => _selectedAssigneeId = value);
          },
        );
      },
    );
  }

  List<ProjectMember> _extractMembers(ProjectMemberState state) {
    if (state is ProjectMemberLoaded) {
      return state.members;
    }
    if (state is ProjectMemberOperationSuccess) {
      return state.members;
    }
    if (state is ProjectMemberOperationInProgress) {
      return state.currentMembers;
    }
    return const [];
  }
}
