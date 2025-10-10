import 'package:flutter/material.dart';

import '../../../domain/entities/workspace.dart';

/// Pantalla para invitar a un nuevo miembro al workspace
/// TODO: Implementar cuando el backend tenga el endpoint de invitaciones
class WorkspaceInviteMemberScreen extends StatefulWidget {
  final Workspace workspace;

  const WorkspaceInviteMemberScreen({super.key, required this.workspace});

  @override
  State<WorkspaceInviteMemberScreen> createState() =>
      _WorkspaceInviteMemberScreenState();
}

class _WorkspaceInviteMemberScreenState
    extends State<WorkspaceInviteMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  WorkspaceRole _selectedRole = WorkspaceRole.member;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleInvite() {
    if (!_formKey.currentState!.validate()) return;

    // TODO: Implementar cuando tengamos el usecase de invitaciones
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Funcionalidad de invitaciones próximamente (requiere backend)',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invitar Miembro'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info del workspace
              _buildWorkspaceInfo(),
              const SizedBox(height: 32),

              // Email input
              _buildEmailField(),
              const SizedBox(height: 24),

              // Role selector
              _buildRoleSelector(),
              const SizedBox(height: 32),

              // Info sobre roles
              _buildRoleInfo(),
              const SizedBox(height: 32),

              // Botón de invitar
              _buildInviteButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkspaceInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              backgroundImage: widget.workspace.avatarUrl != null
                  ? NetworkImage(widget.workspace.avatarUrl!)
                  : null,
              child: widget.workspace.avatarUrl == null
                  ? Text(
                      widget.workspace.initials,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.workspace.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.workspace.memberCount} miembros',
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

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email del invitado',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'ejemplo@correo.com',
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa un email';
            }

            final emailRegex = RegExp(
              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
            );

            if (!emailRegex.hasMatch(value)) {
              return 'Por favor ingresa un email válido';
            }

            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rol en el workspace',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        RadioGroup<WorkspaceRole>(
          groupValue: _selectedRole,
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedRole = value);
            }
          },
          child: Column(
            children: [
              ...WorkspaceRole.values.map((role) {
                // No permitir invitar como owner
                if (role == WorkspaceRole.owner) return const SizedBox.shrink();

                return RadioListTile<WorkspaceRole>(
                  title: Text(role.displayName),
                  subtitle: Text(_getRoleDescription(role)),
                  value: role,
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleInfo() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Permisos por rol',
                  style: TextStyle(
                    color: Colors.blue[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildPermissionItem(
              'Administrador',
              'Gestión completa excepto eliminar workspace',
            ),
            _buildPermissionItem(
              'Miembro',
              'Crear y gestionar proyectos y tareas',
            ),
            _buildPermissionItem('Invitado', 'Solo visualización de contenido'),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionItem(String role, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.blue[900], fontSize: 13),
                children: [
                  TextSpan(
                    text: '$role: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteButton() {
    return ElevatedButton.icon(
      onPressed: _handleInvite,
      icon: const Icon(Icons.send),
      label: const Text('Enviar Invitación'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  String _getRoleDescription(WorkspaceRole role) {
    switch (role) {
      case WorkspaceRole.admin:
        return 'Puede gestionar miembros y configuración';
      case WorkspaceRole.member:
        return 'Puede crear y gestionar proyectos';
      case WorkspaceRole.guest:
        return 'Solo puede visualizar contenido';
      case WorkspaceRole.owner:
        return 'Control total del workspace';
    }
  }
}
