import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/workspace.dart';
import '../../bloc/workspace/workspace_bloc.dart';
import '../../bloc/workspace/workspace_event.dart';
import '../../bloc/workspace/workspace_state.dart';

/// Pantalla para crear un nuevo workspace
class WorkspaceCreateScreen extends StatefulWidget {
  const WorkspaceCreateScreen({super.key});

  @override
  State<WorkspaceCreateScreen> createState() => _WorkspaceCreateScreenState();
}

class _WorkspaceCreateScreenState extends State<WorkspaceCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  WorkspaceType _selectedType = WorkspaceType.team;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Workspace')),
      body: BlocListener<WorkspaceBloc, WorkspaceState>(
        listener: (context, state) {
          if (state is WorkspaceLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }

          if (state is WorkspaceCreated) {
            AppLogger.info(
              'Workspace creado exitosamente: ${state.workspace.id}',
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Workspace "${state.workspace.name}" creado exitosamente',
                ),
                backgroundColor: Colors.green,
              ),
            );
            // Regresar a la pantalla anterior después de crear
            Navigator.of(context).pop(state.workspace);
          } else if (state is WorkspaceError) {
            AppLogger.error('Error al crear workspace: ${state.message}');
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
                // Información del formulario
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Crea un workspace para organizar tus proyectos y colaborar con tu equipo.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

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
                ),
                const SizedBox(height: 24),

                // Selector de tipo
                Text(
                  'Tipo de Workspace',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTypeSelector(),
                const SizedBox(height: 32),

                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
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
                            : const Text('Crear Workspace'),
                      ),
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

  /// Construir selector de tipo de workspace
  Widget _buildTypeSelector() {
    return Column(
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

    return InkWell(
      onTap: () => setState(() => _selectedType = type),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
        ),
        child: Row(
          children: [
            // Radio button
            Radio<WorkspaceType>(
              value: type,
              groupValue: _selectedType,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
              activeColor: color,
            ),
            // Icono
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
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
                      color: isSelected ? color : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Manejar envío del formulario
  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();

      AppLogger.info('Creando workspace: $name (${_selectedType.displayName})');

      // Enviar evento al BLoC
      context.read<WorkspaceBloc>().add(
        CreateWorkspaceEvent(
          name: name,
          description: description.isNotEmpty ? description : null,
          type: _selectedType,
          settings: const WorkspaceSettings(), // Configuración por defecto
        ),
      );
    }
  }
}
