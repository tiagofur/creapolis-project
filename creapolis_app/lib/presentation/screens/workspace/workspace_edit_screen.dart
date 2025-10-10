import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/workspace.dart';
import '../../bloc/workspace/workspace_bloc.dart';
import '../../bloc/workspace/workspace_event.dart';
import '../../bloc/workspace/workspace_state.dart';

/// Pantalla para editar un workspace existente
class WorkspaceEditScreen extends StatefulWidget {
  final Workspace workspace;

  const WorkspaceEditScreen({super.key, required this.workspace});

  @override
  State<WorkspaceEditScreen> createState() => _WorkspaceEditScreenState();
}

class _WorkspaceEditScreenState extends State<WorkspaceEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late WorkspaceType _selectedType;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.workspace.name);
    _descriptionController = TextEditingController(
      text: widget.workspace.description ?? '',
    );
    _selectedType = widget.workspace.type;

    // Detectar cambios
    _nameController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    final hasChanges =
        _nameController.text.trim() != widget.workspace.name ||
        _descriptionController.text.trim() !=
            (widget.workspace.description ?? '') ||
        _selectedType != widget.workspace.type;

    if (hasChanges != _hasChanges) {
      setState(() => _hasChanges = hasChanges);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showDiscardDialog();
        if (shouldPop == true && mounted) {
          // ignore: use_build_context_synchronously
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Editar Workspace'),
          actions: [
            if (_hasChanges)
              TextButton(
                onPressed: _isLoading ? null : _handleSubmit,
                child: const Text(
                  'GUARDAR',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
        body: BlocListener<WorkspaceBloc, WorkspaceState>(
          listener: (context, state) {
            if (state is WorkspaceLoading) {
              setState(() => _isLoading = true);
            } else {
              setState(() => _isLoading = false);
            }

            if (state is WorkspaceUpdated) {
              AppLogger.info(
                'Workspace actualizado exitosamente: ${state.workspace.id}',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Workspace "${state.workspace.name}" actualizado',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              // Regresar con el workspace actualizado
              Navigator.of(context).pop(state.workspace);
            } else if (state is WorkspaceError) {
              AppLogger.error(
                'Error al actualizar workspace: ${state.message}',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Información
                  if (!widget.workspace.canManageSettings)
                    Card(
                      color: Colors.orange.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Solo los administradores y propietarios pueden editar la configuración del workspace.',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.orange.shade900),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Campo de nombre
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Workspace',
                      hintText: 'Ej: Mi Empresa, Equipo Frontend',
                      prefixIcon: Icon(Icons.workspaces),
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    enabled: widget.workspace.canManageSettings,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es requerido';
                      }
                      if (value.trim().length < 3) {
                        return 'El nombre debe tener al menos 3 caracteres';
                      }
                      if (value.trim().length > 50) {
                        return 'El nombre no puede tener más de 50 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo de descripción
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción (opcional)',
                      hintText: 'Describe el propósito de este workspace',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    maxLength: 200,
                    textCapitalization: TextCapitalization.sentences,
                    enabled: widget.workspace.canManageSettings,
                  ),
                  const SizedBox(height: 24),

                  // Selector de tipo
                  Text(
                    'Tipo de Workspace',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (!widget.workspace.canManageSettings)
                    Text(
                      'El tipo de workspace no puede ser modificado.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  const SizedBox(height: 12),
                  _buildTypeSelector(),
                  const SizedBox(height: 32),

                  // Información adicional
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información del Workspace',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.person,
                            'Propietario',
                            widget.workspace.owner?.name ?? 'Desconocido',
                          ),
                          const Divider(),
                          _buildInfoRow(
                            Icons.people,
                            'Miembros',
                            '${widget.workspace.memberCount}',
                          ),
                          const Divider(),
                          _buildInfoRow(
                            Icons.folder,
                            'Proyectos',
                            '${widget.workspace.projectCount}',
                          ),
                          const Divider(),
                          _buildInfoRow(
                            Icons.calendar_today,
                            'Creado',
                            _formatDate(widget.workspace.createdAt),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botones de acción
                  if (widget.workspace.canManageSettings)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading
                                ? null
                                : () => _handleCancel(),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading || !_hasChanges
                                ? null
                                : _handleSubmit,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text('Guardar Cambios'),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Construir selector de tipo de workspace
  Widget _buildTypeSelector() {
    final isEnabled = widget.workspace.canManageSettings;
    return RadioGroup<WorkspaceType>(
      groupValue: _selectedType,
      onChanged: (value) {
        if (isEnabled && value != null) {
          setState(() => _selectedType = value);
          _onFieldChanged();
        }
      },
      child: Column(
        children: [
          _buildTypeOption(
            WorkspaceType.personal,
            Icons.person,
            'Personal',
            'Para uso individual y proyectos personales',
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildTypeOption(
            WorkspaceType.team,
            Icons.group,
            'Equipo',
            'Para colaborar con un equipo pequeño o mediano',
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildTypeOption(
            WorkspaceType.enterprise,
            Icons.business,
            'Empresa',
            'Para organizaciones grandes con múltiples equipos',
            Colors.purple,
          ),
        ],
      ),
    );
  }

  /// Construir opción de tipo
  Widget _buildTypeOption(
    WorkspaceType type,
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    final isSelected = _selectedType == type;
    final isEnabled = widget.workspace.canManageSettings;

    return InkWell(
      onTap: isEnabled
          ? () {
              setState(() => _selectedType = type);
              _onFieldChanged();
            }
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? color
                : (isEnabled ? Colors.grey.shade300 : Colors.grey.shade200),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : (isEnabled ? Colors.transparent : Colors.grey.shade50),
        ),
        child: Row(
          children: [
            // Radio button
            Radio<WorkspaceType>(
              value: type,
              toggleable: !isEnabled,
              activeColor: color,
            ),
            // Icono
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isEnabled ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color.withValues(alpha: isEnabled ? 1.0 : 0.5),
              ),
            ),
            const SizedBox(width: 16),
            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? color
                          : (isEnabled ? null : Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isEnabled ? Colors.grey[600] : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construir fila de información
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// Formatear fecha
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 30) {
      return 'Hace ${difference.inDays} días';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Hace $months ${months == 1 ? "mes" : "meses"}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Hace $years ${years == 1 ? "año" : "años"}';
    }
  }

  /// Manejar cancelación
  void _handleCancel() async {
    if (_hasChanges) {
      final shouldPop = await _showDiscardDialog();
      if (shouldPop == true && mounted) {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  /// Manejar envío del formulario
  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    AppLogger.info('Actualizando workspace ${widget.workspace.id}');

    // Enviar evento al BLoC
    context.read<WorkspaceBloc>().add(
      UpdateWorkspaceEvent(
        workspaceId: widget.workspace.id,
        name: name != widget.workspace.name ? name : null,
        description: description != (widget.workspace.description ?? '')
            ? (description.isNotEmpty ? description : null)
            : null,
        type: _selectedType != widget.workspace.type ? _selectedType : null,
      ),
    );
  }

  /// Mostrar diálogo de descartar cambios
  Future<bool?> _showDiscardDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar cambios'),
        content: const Text(
          '¿Estás seguro de que deseas descartar los cambios realizados?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
  }
}
