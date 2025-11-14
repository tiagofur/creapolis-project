import 'package:flutter/material.dart';
import 'package:creapolis_app/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/workspace/data/models/workspace_model.dart';
import '../../../features/workspace/presentation/bloc/workspace_bloc.dart';
import '../../../features/workspace/presentation/bloc/workspace_event.dart';

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
    final email = _emailController.text.trim();
    context.read<WorkspaceBloc>().add(
          InviteMember(
            workspaceId: widget.workspace.id,
            email: email,
            role: _selectedRole,
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)?.invitationSentTo(email) ?? 'Invitación enviada a $email'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)?.inviteMember ?? 'Invitar Miembro'), elevation: 0),
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
                    AppLocalizations.of(context)?.membersCount(widget.workspace.memberCount) ?? '${widget.workspace.memberCount} miembros',
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
          AppLocalizations.of(context)?.inviteeEmailLabel ?? 'Email del invitado',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)?.inviteeEmailHint ?? 'ejemplo@correo.com',
            prefixIcon: const Icon(Icons.email_outlined),
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)?.enterEmailMessage ?? 'Por favor ingresa un email';
            }

            final emailRegex = RegExp(
              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
            );

            if (!emailRegex.hasMatch(value)) {
              return AppLocalizations.of(context)?.enterValidEmailMessage ?? 'Por favor ingresa un email válido';
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
          AppLocalizations.of(context)?.workspaceRoleLabel ?? 'Rol en el workspace',
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
                  AppLocalizations.of(context)?.rolePermissionsTitle ?? 'Permisos por rol',
                  style: TextStyle(
                    color: Colors.blue[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildPermissionItem(
              AppLocalizations.of(context)?.adminsRoleLabel ?? 'Administrador',
              AppLocalizations.of(context)?.adminRoleDesc ?? 'Gestión completa excepto eliminar workspace',
            ),
            _buildPermissionItem(
              AppLocalizations.of(context)?.membersRoleLabel ?? 'Miembro',
              AppLocalizations.of(context)?.memberRoleDesc ?? 'Crear y gestionar proyectos y tareas',
            ),
            _buildPermissionItem(AppLocalizations.of(context)?.guestsRoleLabel ?? 'Invitado', AppLocalizations.of(context)?.guestRoleDesc ?? 'Solo visualización de contenido'),
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
      label: Text(AppLocalizations.of(context)?.sendInvitation ?? 'Enviar Invitación'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  String _getRoleDescription(WorkspaceRole role) {
    switch (role) {
      case WorkspaceRole.admin:
        return AppLocalizations.of(context)?.adminRoleCapability ?? 'Puede gestionar miembros y configuración';
      case WorkspaceRole.member:
        return AppLocalizations.of(context)?.memberRoleCapability ?? 'Puede crear y gestionar proyectos';
      case WorkspaceRole.guest:
        return AppLocalizations.of(context)?.guestRoleCapability ?? 'Solo puede visualizar contenido';
      case WorkspaceRole.owner:
        return AppLocalizations.of(context)?.ownerRoleCapability ?? 'Control total del workspace';
    }
  }
}
