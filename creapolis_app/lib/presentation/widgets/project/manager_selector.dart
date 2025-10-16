import 'package:flutter/material.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/workspace_member.dart';
import '../../../features/workspace/data/models/workspace_model.dart';

/// Widget para seleccionar el manager de un proyecto
///
/// **Características:**
/// - Dropdown con lista de miembros del workspace
/// - Filtrado por roles con permisos para ser manager
/// - Búsqueda por nombre
/// - Avatar y rol del usuario
/// - Callback al seleccionar
class ManagerSelector extends StatefulWidget {
  /// Lista de miembros del workspace disponibles
  final List<WorkspaceMember> members;

  /// ID del manager actualmente seleccionado
  final int? selectedManagerId;

  /// Callback cuando se selecciona un manager
  final ValueChanged<int?>? onManagerSelected;

  /// Si el selector está habilitado
  final bool enabled;

  /// Texto del label
  final String label;

  /// Permitir selección nula (sin manager)
  final bool allowNull;

  const ManagerSelector({
    super.key,
    required this.members,
    this.selectedManagerId,
    this.onManagerSelected,
    this.enabled = true,
    this.label = 'Manager del Proyecto',
    this.allowNull = false,
  });

  @override
  State<ManagerSelector> createState() => _ManagerSelectorState();
}

class _ManagerSelectorState extends State<ManagerSelector> {
  int? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.selectedManagerId;
  }

  @override
  void didUpdateWidget(ManagerSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedManagerId != oldWidget.selectedManagerId) {
      setState(() {
        _selectedId = widget.selectedManagerId;
      });
    }
  }

  /// Filtrar miembros que pueden ser managers
  /// Solo OWNER, ADMIN y MEMBER (no VIEWER)
  List<WorkspaceMember> get _eligibleManagers {
    return widget.members.where((member) {
      return member.role == WorkspaceRole.owner ||
          member.role == WorkspaceRole.admin ||
          member.role == WorkspaceRole.member;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_eligibleManagers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.error),
        ),
        child: Row(
          children: [
            Icon(Icons.warning, color: colorScheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No hay miembros elegibles para ser manager',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<int?>(
      value: _selectedId,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabled: widget.enabled,
      ),
      items: [
        // Opción "Sin manager" si allowNull
        if (widget.allowNull)
          const DropdownMenuItem<int?>(
            value: null,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  child: Icon(Icons.person_off, size: 16),
                ),
                SizedBox(width: 12),
                Expanded(child: Text('Sin manager asignado')),
              ],
            ),
          ),
        // Lista de managers elegibles
        ..._eligibleManagers.map((member) {
          return DropdownMenuItem<int?>(
            value: member.userId,
            child: _ManagerItem(member: member),
          );
        }),
      ],
      selectedItemBuilder: (context) {
        return [
          if (widget.allowNull)
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  child: Icon(Icons.person_off, size: 16),
                ),
                SizedBox(width: 12),
                Text('Sin manager'),
              ],
            ),
          ..._eligibleManagers.map((member) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: member.userAvatarUrl != null
                      ? NetworkImage(member.userAvatarUrl!)
                      : null,
                  child: member.userAvatarUrl == null
                      ? Text(
                          member.userName[0].toUpperCase(),
                          style: const TextStyle(fontSize: 14),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(member.userName, overflow: TextOverflow.ellipsis),
                ),
              ],
            );
          }),
        ];
      },
      onChanged: widget.enabled
          ? (newValue) {
              setState(() => _selectedId = newValue);
              AppLogger.info(
                'ManagerSelector: Manager seleccionado - '
                '${newValue != null ? _eligibleManagers.firstWhere((m) => m.userId == newValue).userName : "ninguno"}',
              );
              widget.onManagerSelected?.call(newValue);
            }
          : null,
      validator: !widget.allowNull
          ? (value) {
              if (value == null) {
                return 'Debes seleccionar un manager';
              }
              return null;
            }
          : null,
    );
  }
}

/// Widget para mostrar un item de manager en el dropdown
class _ManagerItem extends StatelessWidget {
  final WorkspaceMember member;

  const _ManagerItem({required this.member});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Avatar
        CircleAvatar(
          radius: 16,
          backgroundImage: member.userAvatarUrl != null
              ? NetworkImage(member.userAvatarUrl!)
              : null,
          child: member.userAvatarUrl == null
              ? Text(
                  member.userName[0].toUpperCase(),
                  style: const TextStyle(fontSize: 14),
                )
              : null,
        ),
        const SizedBox(width: 12),

        // Nombre y rol
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                member.userName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _getRoleLabel(member.role),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getRoleColor(member.role),
                ),
              ),
            ],
          ),
        ),

        // Badge de rol
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _getRoleColor(member.role).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            _getRoleShort(member.role),
            style: theme.textTheme.labelSmall?.copyWith(
              color: _getRoleColor(member.role),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  String _getRoleLabel(WorkspaceRole role) {
    switch (role) {
      case WorkspaceRole.owner:
        return 'Propietario';
      case WorkspaceRole.admin:
        return 'Administrador';
      case WorkspaceRole.member:
        return 'Miembro';
      case WorkspaceRole.guest:
        return 'Invitado';
    }
  }

  String _getRoleShort(WorkspaceRole role) {
    switch (role) {
      case WorkspaceRole.owner:
        return 'OWNER';
      case WorkspaceRole.admin:
        return 'ADMIN';
      case WorkspaceRole.member:
        return 'MEMBER';
      case WorkspaceRole.guest:
        return 'GUEST';
    }
  }

  Color _getRoleColor(WorkspaceRole role) {
    switch (role) {
      case WorkspaceRole.owner:
        return Colors.purple;
      case WorkspaceRole.admin:
        return Colors.orange;
      case WorkspaceRole.member:
        return Colors.blue;
      case WorkspaceRole.guest:
        return Colors.grey;
    }
  }
}
