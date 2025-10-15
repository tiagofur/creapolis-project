import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/workspace.dart';
import '../../../bloc/workspace_invitation/workspace_invitation_bloc.dart';
import '../../../bloc/workspace_invitation/workspace_invitation_event.dart';
import '../../../bloc/workspace_invitation/workspace_invitation_state.dart';

class InviteMemberResult {
  final bool success;
  final String message;

  const InviteMemberResult({required this.success, required this.message});
}

Future<InviteMemberResult?> showInviteMemberDialog({
  required BuildContext context,
  required int workspaceId,
  required WorkspaceRole currentUserRole,
}) {
  return showDialog<InviteMemberResult>(
    context: context,
    builder: (dialogContext) => BlocProvider.value(
      value: context.read<WorkspaceInvitationBloc>(),
      child: _InviteMemberDialog(
        workspaceId: workspaceId,
        currentUserRole: currentUserRole,
      ),
    ),
  );
}

class _InviteMemberDialog extends StatefulWidget {
  final int workspaceId;
  final WorkspaceRole currentUserRole;

  const _InviteMemberDialog({
    required this.workspaceId,
    required this.currentUserRole,
  });

  @override
  State<_InviteMemberDialog> createState() => _InviteMemberDialogState();
}

class _InviteMemberDialogState extends State<_InviteMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  late WorkspaceRole _selectedRole;
  String? _errorMessage;
  bool _isSubmitting = false;

  List<WorkspaceRole> get _availableRoles {
    if (widget.currentUserRole == WorkspaceRole.owner ||
        widget.currentUserRole == WorkspaceRole.admin) {
      return const [
        WorkspaceRole.admin,
        WorkspaceRole.member,
        WorkspaceRole.guest,
      ];
    }
    return const [WorkspaceRole.member, WorkspaceRole.guest];
  }

  @override
  void initState() {
    super.initState();
    final roles = _availableRoles;
    _selectedRole = roles.contains(WorkspaceRole.member)
        ? WorkspaceRole.member
        : roles.first;
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roles = _availableRoles;

    return BlocListener<WorkspaceInvitationBloc, WorkspaceInvitationState>(
      listener: (context, state) {
        if (!mounted) return;

        if (state is InvitationCreated &&
            state.invitation.workspaceId == widget.workspaceId) {
          Navigator.of(context).pop(
            InviteMemberResult(
              success: true,
              message: 'Invitación enviada a ${state.invitation.inviteeEmail}',
            ),
          );
        } else if (state is WorkspaceInvitationError && _isSubmitting) {
          setState(() {
            _errorMessage = state.message;
            _isSubmitting = false;
          });
        } else if (state is PendingInvitationsLoaded && _isSubmitting) {
          setState(() => _isSubmitting = false);
        }
      },
      child: AlertDialog(
        title: const Text('Invitar miembro'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _emailController,
                enabled: !_isSubmitting,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  hintText: 'usuario@ejemplo.com',
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty) {
                    return 'El correo es obligatorio';
                  }
                  final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                  if (!emailRegex.hasMatch(email)) {
                    return 'Ingresa un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<WorkspaceRole>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Rol'),
                items: roles
                    .map(
                      (role) => DropdownMenuItem(
                        value: role,
                        child: Text(role.displayName),
                      ),
                    )
                    .toList(),
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _selectedRole = value);
                        }
                      },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Enviar invitación'),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    context.read<WorkspaceInvitationBloc>().add(
      CreateInvitationEvent(
        workspaceId: widget.workspaceId,
        email: _emailController.text.trim(),
        role: _selectedRole,
      ),
    );
  }
}
