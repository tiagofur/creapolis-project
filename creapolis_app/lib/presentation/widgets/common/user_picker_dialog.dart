import 'package:flutter/material.dart';

import '../../../domain/entities/workspace_member.dart';
import '../../../features/workspace/data/models/workspace_model.dart';

/// Resultado del diálogo de selección de usuario
class UserPickerResult {
  final List<int> selectedUserIds;
  final List<WorkspaceMember> selectedMembers;

  const UserPickerResult({
    required this.selectedUserIds,
    required this.selectedMembers,
  });

  /// Obtener un solo usuario (para single select)
  int? get singleUserId =>
      selectedUserIds.isNotEmpty ? selectedUserIds.first : null;
  WorkspaceMember? get singleMember =>
      selectedMembers.isNotEmpty ? selectedMembers.first : null;
}

/// Muestra un diálogo para seleccionar uno o múltiples usuarios
///
/// [members] - Lista de miembros del workspace disponibles
/// [selectedUserIds] - IDs de usuarios actualmente seleccionados
/// [multiSelect] - Si permite selección múltiple
/// [title] - Título del diálogo
/// [allowEmpty] - Si permite selección vacía
Future<UserPickerResult?> showUserPickerDialog({
  required BuildContext context,
  required List<WorkspaceMember> members,
  List<int> selectedUserIds = const [],
  bool multiSelect = false,
  String? title,
  bool allowEmpty = true,
}) {
  return showDialog<UserPickerResult>(
    context: context,
    builder: (context) => _UserPickerDialog(
      members: members,
      selectedUserIds: selectedUserIds,
      multiSelect: multiSelect,
      title:
          title ??
          (multiSelect ? 'Seleccionar usuarios' : 'Seleccionar usuario'),
      allowEmpty: allowEmpty,
    ),
  );
}

class _UserPickerDialog extends StatefulWidget {
  final List<WorkspaceMember> members;
  final List<int> selectedUserIds;
  final bool multiSelect;
  final String title;
  final bool allowEmpty;

  const _UserPickerDialog({
    required this.members,
    required this.selectedUserIds,
    required this.multiSelect,
    required this.title,
    required this.allowEmpty,
  });

  @override
  State<_UserPickerDialog> createState() => _UserPickerDialogState();
}

class _UserPickerDialogState extends State<_UserPickerDialog> {
  late List<int> _selectedIds;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedIds = List.from(widget.selectedUserIds);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<WorkspaceMember> get _filteredMembers {
    if (_searchQuery.isEmpty) return widget.members;

    final query = _searchQuery.toLowerCase();
    return widget.members.where((member) {
      return member.userName.toLowerCase().contains(query) ||
          member.userEmail.toLowerCase().contains(query);
    }).toList();
  }

  void _toggleSelection(int userId) {
    setState(() {
      if (widget.multiSelect) {
        if (_selectedIds.contains(userId)) {
          _selectedIds.remove(userId);
        } else {
          _selectedIds.add(userId);
        }
      } else {
        // Single select: solo uno a la vez
        if (_selectedIds.contains(userId)) {
          _selectedIds.clear();
        } else {
          _selectedIds = [userId];
        }
      }
    });
  }

  void _confirm() {
    final selectedMembers = widget.members
        .where((m) => _selectedIds.contains(m.userId))
        .toList();

    Navigator.of(context).pop(
      UserPickerResult(
        selectedUserIds: List.from(_selectedIds),
        selectedMembers: selectedMembers,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            widget.multiSelect ? Icons.people : Icons.person,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(widget.title)),
        ],
      ),
      content: SizedBox(
        width: 350,
        height: 400,
        child: Column(
          children: [
            // Barra de búsqueda
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                isDense: true,
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 12),

            // Contador de seleccionados
            if (widget.multiSelect && _selectedIds.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedIds.length} usuario(s) seleccionado(s)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _selectedIds.clear()),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Limpiar'),
                    ),
                  ],
                ),
              ),

            // Lista de usuarios
            Expanded(
              child: _filteredMembers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No hay usuarios disponibles'
                                : 'No se encontraron usuarios',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredMembers.length,
                      itemBuilder: (context, index) {
                        final member = _filteredMembers[index];
                        final isSelected = _selectedIds.contains(member.userId);

                        return _UserTile(
                          member: member,
                          isSelected: isSelected,
                          multiSelect: widget.multiSelect,
                          onTap: () => _toggleSelection(member.userId),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: (widget.allowEmpty || _selectedIds.isNotEmpty)
              ? _confirm
              : null,
          child: Text(widget.multiSelect ? 'Confirmar' : 'Seleccionar'),
        ),
      ],
    );
  }
}

/// Tile para mostrar un usuario en la lista
class _UserTile extends StatelessWidget {
  final WorkspaceMember member;
  final bool isSelected;
  final bool multiSelect;
  final VoidCallback onTap;

  const _UserTile({
    required this.member,
    required this.isSelected,
    required this.multiSelect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: member.userAvatarUrl != null
                ? NetworkImage(member.userAvatarUrl!)
                : null,
            backgroundColor: colorScheme.primaryContainer,
            child: member.userAvatarUrl == null
                ? Text(
                    member.userName[0].toUpperCase(),
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          if (isSelected)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.surface, width: 2),
                ),
                child: Icon(
                  Icons.check,
                  size: 10,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        member.userName,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      subtitle: Text(
        member.userEmail,
        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.outline),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Checkbox o indicador de selección
          if (multiSelect)
            Checkbox(value: isSelected, onChanged: (_) => onTap())
          else
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
        ],
      ),
    );
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
