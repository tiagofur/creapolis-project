import 'package:flutter/material.dart';
import 'package:creapolis_app/domain/entities/search_result.dart';

/// Bottom sheet for advanced search filters
class SearchFilterSheet extends StatefulWidget {
  final SearchFilters currentFilters;
  final Function(SearchFilters) onApplyFilters;

  const SearchFilterSheet({
    super.key,
    required this.currentFilters,
    required this.onApplyFilters,
  });

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  late List<String> _selectedTypes;
  String? _selectedStatus;
  String? _selectedPriority;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _selectedTypes = List.from(widget.currentFilters.entityTypes);
    _selectedStatus = widget.currentFilters.status;
    _selectedPriority = widget.currentFilters.priority;
    if (widget.currentFilters.startDate != null &&
        widget.currentFilters.endDate != null) {
      _dateRange = DateTimeRange(
        start: widget.currentFilters.startDate!,
        end: widget.currentFilters.endDate!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildEntityTypeFilter(),
                    const SizedBox(height: 24),
                    _buildStatusFilter(),
                    const SizedBox(height: 24),
                    _buildPriorityFilter(),
                    const SizedBox(height: 24),
                    _buildDateRangeFilter(),
                  ],
                ),
              ),
              _buildActionButtons(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 24),
          const SizedBox(width: 12),
          const Text(
            'Filtros Avanzados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEntityTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Resultado',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip(
              label: 'Tareas',
              icon: Icons.task_alt,
              isSelected: _selectedTypes.contains('task'),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTypes.add('task');
                  } else {
                    _selectedTypes.remove('task');
                  }
                });
              },
            ),
            _buildFilterChip(
              label: 'Proyectos',
              icon: Icons.folder,
              isSelected: _selectedTypes.contains('project'),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTypes.add('project');
                  } else {
                    _selectedTypes.remove('project');
                  }
                });
              },
            ),
            _buildFilterChip(
              label: 'Usuarios',
              icon: Icons.person,
              isSelected: _selectedTypes.contains('user'),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTypes.add('user');
                  } else {
                    _selectedTypes.remove('user');
                  }
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estado (Tareas)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip(
              label: 'Por hacer',
              isSelected: _selectedStatus == 'TODO',
              onSelected: (selected) {
                setState(() {
                  _selectedStatus = selected ? 'TODO' : null;
                });
              },
            ),
            _buildFilterChip(
              label: 'En progreso',
              isSelected: _selectedStatus == 'IN_PROGRESS',
              onSelected: (selected) {
                setState(() {
                  _selectedStatus = selected ? 'IN_PROGRESS' : null;
                });
              },
            ),
            _buildFilterChip(
              label: 'Completada',
              isSelected: _selectedStatus == 'COMPLETED',
              onSelected: (selected) {
                setState(() {
                  _selectedStatus = selected ? 'COMPLETED' : null;
                });
              },
            ),
            _buildFilterChip(
              label: 'Bloqueada',
              isSelected: _selectedStatus == 'BLOCKED',
              onSelected: (selected) {
                setState(() {
                  _selectedStatus = selected ? 'BLOCKED' : null;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prioridad (Tareas)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip(
              label: 'Baja',
              isSelected: _selectedPriority == 'LOW',
              color: Colors.green,
              onSelected: (selected) {
                setState(() {
                  _selectedPriority = selected ? 'LOW' : null;
                });
              },
            ),
            _buildFilterChip(
              label: 'Media',
              isSelected: _selectedPriority == 'MEDIUM',
              color: Colors.orange,
              onSelected: (selected) {
                setState(() {
                  _selectedPriority = selected ? 'MEDIUM' : null;
                });
              },
            ),
            _buildFilterChip(
              label: 'Alta',
              isSelected: _selectedPriority == 'HIGH',
              color: Colors.deepOrange,
              onSelected: (selected) {
                setState(() {
                  _selectedPriority = selected ? 'HIGH' : null;
                });
              },
            ),
            _buildFilterChip(
              label: 'Crítica',
              isSelected: _selectedPriority == 'CRITICAL',
              color: Colors.red,
              onSelected: (selected) {
                setState(() {
                  _selectedPriority = selected ? 'CRITICAL' : null;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rango de Fechas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _selectDateRange,
          icon: const Icon(Icons.date_range),
          label: Text(
            _dateRange != null
                ? '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}'
                : 'Seleccionar rango',
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        if (_dateRange != null)
          TextButton.icon(
            onPressed: () {
              setState(() {
                _dateRange = null;
              });
            },
            icon: const Icon(Icons.clear),
            label: const Text('Limpiar rango'),
          ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    IconData? icon,
    required bool isSelected,
    required Function(bool) onSelected,
    Color? color,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: (color ?? Theme.of(context).primaryColor).withValues(alpha: 0.2),
      checkmarkColor: color ?? Theme.of(context).primaryColor,
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _clearAllFilters,
              child: const Text('Limpiar Todo'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _applyFilters,
              child: const Text('Aplicar'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _clearAllFilters() {
    setState(() {
      _selectedTypes = ['task', 'project', 'user'];
      _selectedStatus = null;
      _selectedPriority = null;
      _dateRange = null;
    });
  }

  void _applyFilters() {
    final filters = SearchFilters(
      entityTypes: _selectedTypes,
      status: _selectedStatus,
      priority: _selectedPriority,
      startDate: _dateRange?.start,
      endDate: _dateRange?.end,
    );

    widget.onApplyFilters(filters);
    Navigator.pop(context);
  }
}



