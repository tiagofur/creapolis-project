import 'package:flutter/material.dart';
import 'dart:async';

import '../../../features/workspace/data/models/workspace_model.dart';

/// Opciones de filtrado de workspaces
enum WorkspaceFilter {
  all('Todos', Icons.workspaces),
  owner('Propietario', Icons.star),
  member('Miembro', Icons.person),
  personal('Personal', Icons.person_outline),
  team('Equipo', Icons.group),
  enterprise('Empresa', Icons.business);

  const WorkspaceFilter(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Barra de búsqueda y filtrado para workspaces
/// Inspirado en: Notion, Slack, Microsoft Teams
class WorkspaceSearchBar extends StatefulWidget {
  final List<Workspace> workspaces;
  final Function(List<Workspace>) onFiltered;
  final VoidCallback? onClear;

  const WorkspaceSearchBar({
    super.key,
    required this.workspaces,
    required this.onFiltered,
    this.onClear,
  });

  @override
  State<WorkspaceSearchBar> createState() => _WorkspaceSearchBarState();
}

class _WorkspaceSearchBarState extends State<WorkspaceSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounceTimer;
  WorkspaceFilter _selectedFilter = WorkspaceFilter.all;
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Barra de búsqueda principal
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icono de búsqueda
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.search,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 22,
                ),
              ),

              // Campo de texto
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Buscar workspaces...',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  style: theme.textTheme.bodyLarge,
                ),
              ),

              // Botón de limpiar
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onPressed: _clearSearch,
                  tooltip: 'Limpiar búsqueda',
                ),

              // Botón de filtros
              Container(
                margin: const EdgeInsets.only(right: 4),
                child: IconButton(
                  icon: Badge(
                    isLabelVisible: _selectedFilter != WorkspaceFilter.all,
                    backgroundColor: theme.colorScheme.primary,
                    child: Icon(
                      _showFilters
                          ? Icons.filter_list
                          : Icons.filter_list_outlined,
                      color: _selectedFilter != WorkspaceFilter.all
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      size: 22,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                  tooltip: 'Filtros',
                ),
              ),
            ],
          ),
        ),

        // Chips de filtros (solo si están expandidos)
        if (_showFilters)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: WorkspaceFilter.values.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            filter.icon,
                            size: 16,
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(filter.label),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                        _applyFilters();
                      },
                      selectedColor: theme.colorScheme.primary,
                      checkmarkColor: theme.colorScheme.onPrimary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

        // Indicador de resultados
        if (_searchController.text.isNotEmpty ||
            _selectedFilter != WorkspaceFilter.all)
          _buildResultsIndicator(theme),
      ],
    );
  }

  /// Widget indicador de resultados filtrados
  Widget _buildResultsIndicator(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            _buildResultsText(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              _clearSearch();
              setState(() {
                _selectedFilter = WorkspaceFilter.all;
              });
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Limpiar',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  /// Construir texto de resultados
  String _buildResultsText() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty && _selectedFilter != WorkspaceFilter.all) {
      return 'Buscando "$query" en ${_selectedFilter.label.toLowerCase()}';
    } else if (query.isNotEmpty) {
      return 'Buscando: "$query"';
    } else {
      return 'Filtrando por: ${_selectedFilter.label}';
    }
  }

  /// Manejar cambio en búsqueda con debounce
  void _onSearchChanged(String query) {
    setState(() {}); // Para actualizar UI del botón clear

    // Cancelar timer anterior
    _debounceTimer?.cancel();

    // Crear nuevo timer (debounce de 300ms)
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _applyFilters();
    });
  }

  /// Aplicar filtros de búsqueda y filtro seleccionado
  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();

    List<Workspace> filtered = widget.workspaces;

    // Aplicar filtro de tipo/rol
    if (_selectedFilter != WorkspaceFilter.all) {
      filtered = filtered.where((workspace) {
        switch (_selectedFilter) {
          case WorkspaceFilter.owner:
            return workspace.userRole == WorkspaceRole.owner;
          case WorkspaceFilter.member:
            return workspace.userRole == WorkspaceRole.member ||
                workspace.userRole == WorkspaceRole.admin;
          case WorkspaceFilter.personal:
            return workspace.type == WorkspaceType.personal;
          case WorkspaceFilter.team:
            return workspace.type == WorkspaceType.team;
          case WorkspaceFilter.enterprise:
            return workspace.type == WorkspaceType.enterprise;
          case WorkspaceFilter.all:
            return true;
        }
      }).toList();
    }

    // Aplicar búsqueda por texto
    if (query.isNotEmpty) {
      filtered = filtered.where((workspace) {
        final name = workspace.name.toLowerCase();
        final description = workspace.description?.toLowerCase() ?? '';
        final owner = workspace.owner.name.toLowerCase();

        return name.contains(query) ||
            description.contains(query) ||
            owner.contains(query);
      }).toList();
    }

    widget.onFiltered(filtered);
  }

  /// Limpiar búsqueda
  void _clearSearch() {
    _searchController.clear();
    _focusNode.unfocus();
    setState(() {});
    _applyFilters();
    widget.onClear?.call();
  }
}
