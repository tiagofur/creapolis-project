import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/project_role.dart';
import '../../bloc/role/role_bloc.dart';
import '../../bloc/role/role_event.dart';

/// Screen for creating a new project role
class CreateRoleScreen extends StatefulWidget {
  final int projectId;

  const CreateRoleScreen({
    super.key,
    required this.projectId,
  });

  @override
  State<CreateRoleScreen> createState() => _CreateRoleScreenState();
}

class _CreateRoleScreenState extends State<CreateRoleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isDefault = false;
  final Map<String, Map<String, bool>> _permissions = {};

  @override
  void initState() {
    super.initState();
    _initializePermissions();
  }

  void _initializePermissions() {
    for (final resource in PermissionResource.all) {
      _permissions[resource] = {};
      for (final action in PermissionAction.all) {
        _permissions[resource]![action] = false;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Rol'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBasicInfo(),
            const SizedBox(height: 24),
            _buildPermissionsSection(),
            const SizedBox(height: 24),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información Básica',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Rol *',
                hintText: 'Ej: Desarrollador, Diseñador, etc.',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                hintText: 'Describe las responsabilidades de este rol',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Rol por defecto'),
              subtitle: const Text(
                'Los nuevos miembros recibirán este rol automáticamente',
              ),
              value: _isDefault,
              onChanged: (value) {
                setState(() {
                  _isDefault = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Permisos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                TextButton(
                  onPressed: _selectAllPermissions,
                  child: const Text('Seleccionar todos'),
                ),
                TextButton(
                  onPressed: _deselectAllPermissions,
                  child: const Text('Deseleccionar todos'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Selecciona los permisos que tendrá este rol',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ...PermissionResource.all.map(_buildResourcePermissions),
          ],
        ),
      ),
    );
  }

  Widget _buildResourcePermissions(String resource) {
    return ExpansionTile(
      title: Text(PermissionResource.getDisplayName(resource)),
      subtitle: Text(
        '${_getSelectedActionsCount(resource)} de ${PermissionAction.all.length} permisos',
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: PermissionAction.all.map((action) {
              return CheckboxListTile(
                title: Text(PermissionAction.getDisplayName(action)),
                value: _permissions[resource]![action]!,
                onChanged: (value) {
                  setState(() {
                    _permissions[resource]![action] = value ?? false;
                  });
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  int _getSelectedActionsCount(String resource) {
    return _permissions[resource]!.values.where((v) => v).length;
  }

  void _selectAllPermissions() {
    setState(() {
      for (final resource in PermissionResource.all) {
        for (final action in PermissionAction.all) {
          _permissions[resource]![action] = true;
        }
      }
    });
  }

  void _deselectAllPermissions() {
    setState(() {
      for (final resource in PermissionResource.all) {
        for (final action in PermissionAction.all) {
          _permissions[resource]![action] = false;
        }
      }
    });
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _createRole,
            child: const Text('Crear Rol'),
          ),
        ),
      ],
    );
  }

  void _createRole() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final permissions = <Map<String, dynamic>>[];
    for (final resource in PermissionResource.all) {
      for (final action in PermissionAction.all) {
        if (_permissions[resource]![action]!) {
          permissions.add({
            'resource': resource,
            'action': action,
            'granted': true,
          });
        }
      }
    }

    context.read<RoleBloc>().add(
          CreateProjectRole(
            projectId: widget.projectId,
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            isDefault: _isDefault,
            permissions: permissions,
          ),
        );

    Navigator.of(context).pop();
  }
}



