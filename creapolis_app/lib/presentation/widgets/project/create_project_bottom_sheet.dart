import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/project.dart';
import '../../../features/projects/presentation/blocs/project_bloc.dart';
import '../../../features/projects/presentation/blocs/project_event.dart';
import '../../bloc/workspace_member/workspace_member_bloc.dart';
import '../../bloc/workspace_member/workspace_member_event.dart';
import '../../bloc/workspace_member/workspace_member_state.dart';
import '../../providers/workspace_context.dart';
import 'manager_selector.dart';
import 'project_date_picker.dart';

/// Bottom sheet para crear o editar un proyecto
class CreateProjectBottomSheet extends StatefulWidget {
  final Project? project;

  const CreateProjectBottomSheet({super.key, this.project});

  @override
  State<CreateProjectBottomSheet> createState() =>
      _CreateProjectBottomSheetState();
}

class _CreateProjectBottomSheetState extends State<CreateProjectBottomSheet> {
  final _formKey = GlobalKey<FormBuilderState>();
  ProjectStatus _selectedStatus = ProjectStatus.planned;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  int? _selectedManagerId;

  @override
  void initState() {
    super.initState();

    // Validar que haya workspace activo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final workspaceContext = context.read<WorkspaceContext>();
      if (!workspaceContext.hasActiveWorkspace) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Debes crear o seleccionar un workspace antes de crear proyectos',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        // Cargar miembros del workspace
        context.read<WorkspaceMemberBloc>().add(
          LoadWorkspaceMembersEvent(workspaceContext.activeWorkspace!.id),
        );
      }
    });

    if (widget.project != null) {
      _selectedStatus = widget.project!.status;
      _startDate = widget.project!.startDate;
      _endDate = widget.project!.endDate;
      _selectedManagerId = widget.project!.managerId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.project != null;

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
            'name': widget.project?.name ?? '',
            'description': widget.project?.description ?? '',
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
                    isEditing ? 'Editar Proyecto' : 'Nuevo Proyecto',
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

              // Nombre
              FormBuilderTextField(
                name: 'name',
                decoration: InputDecoration(
                  labelText: 'Nombre del Proyecto *',
                  hintText: 'Ej: Desarrollo Urbano Centro',
                  prefixIcon: const Icon(Icons.business),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'El nombre es requerido',
                  ),
                  FormBuilderValidators.minLength(
                    3,
                    errorText: 'El nombre debe tener al menos 3 caracteres',
                  ),
                ]),
              ),
              const SizedBox(height: 16),

              // Descripción
              FormBuilderTextField(
                name: 'description',
                decoration: InputDecoration(
                  labelText: 'Descripción *',
                  hintText: 'Describe el proyecto...',
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

              // Estado
              DropdownButtonFormField<ProjectStatus>(
                initialValue: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Estado',
                  prefixIcon: const Icon(Icons.flag),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: ProjectStatus.values.map((status) {
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
                        const SizedBox(width: 8),
                        Text(status.label),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedStatus = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Fechas con nuevo widget
              ProjectDatePicker(
                startDate: _startDate,
                endDate: _endDate,
                onStartDateChanged: (date) {
                  if (date != null) {
                    setState(() => _startDate = date);
                  }
                },
                onEndDateChanged: (date) {
                  if (date != null) {
                    setState(() => _endDate = date);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Manager Selector
              BlocBuilder<WorkspaceMemberBloc, WorkspaceMemberState>(
                builder: (context, state) {
                  if (state is WorkspaceMembersLoaded) {
                    return ManagerSelector(
                      members: state.members,
                      selectedManagerId: _selectedManagerId,
                      onManagerSelected: (userId) {
                        setState(() => _selectedManagerId = userId);
                        AppLogger.info(
                          'CreateProjectBottomSheet: Manager seleccionado: $userId',
                        );
                      },
                      allowNull: true,
                    );
                  } else if (state is WorkspaceMemberLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (state is WorkspaceMemberError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Error al cargar miembros: ${state.message}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
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

  /// Manejar envío del formulario
  void _handleSubmit() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      final name = values['name'] as String;
      final description = values['description'] as String;

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

      // Obtener workspace activo
      final workspaceContext = context.read<WorkspaceContext>();
      final activeWorkspace = workspaceContext.activeWorkspace;

      if (activeWorkspace == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay un workspace activo'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (widget.project != null) {
        // Actualizar
        AppLogger.info(
          'CreateProjectBottomSheet: Actualizando proyecto ${widget.project!.id}',
        );
        context.read<ProjectBloc>().add(
          UpdateProject(
            id: widget.project!.id,
            name: name,
            description: description,
            startDate: _startDate,
            endDate: _endDate,
            status: _selectedStatus,
            managerId: _selectedManagerId,
          ),
        );
      } else {
        // Crear
        AppLogger.info(
          'CreateProjectBottomSheet: Creando nuevo proyecto en workspace ${activeWorkspace.id}',
        );
        context.read<ProjectBloc>().add(
          CreateProject(
            name: name,
            description: description,
            startDate: _startDate,
            endDate: _endDate,
            status: _selectedStatus,
            managerId: _selectedManagerId,
            workspaceId: activeWorkspace.id,
          ),
        );
      }

      Navigator.of(context).pop();
    }
  }

  /// Obtiene el color según el estado
  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planned:
        return Colors.blue;
      case ProjectStatus.active:
        return Colors.green;
      case ProjectStatus.paused:
        return Colors.orange;
      case ProjectStatus.completed:
        return Colors.teal;
      case ProjectStatus.cancelled:
        return Colors.red;
    }
  }
}
