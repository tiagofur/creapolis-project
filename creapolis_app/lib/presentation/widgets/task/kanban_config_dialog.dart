import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/kanban_preferences_service.dart';
import '../../../domain/entities/kanban_config.dart';
import '../../../domain/entities/task.dart';

/// Diálogo mejorado para configurar el tablero Kanban
class KanbanConfigDialog extends StatefulWidget {
  final int projectId;
  final KanbanBoardConfig currentConfig;
  final VoidCallback onConfigChanged;

  const KanbanConfigDialog({
    super.key,
    required this.projectId,
    required this.currentConfig,
    required this.onConfigChanged,
  });

  @override
  State<KanbanConfigDialog> createState() => _KanbanConfigDialogState();
}

class _KanbanConfigDialogState extends State<KanbanConfigDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Map<TaskStatus, int?> _wipLimits;
  late List<KanbanSwimlane> _swimlanes;
  late bool _swimlanesEnabled;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCurrentConfig();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadCurrentConfig() {
    _wipLimits = {};
    for (final status in TaskStatus.values) {
      final config = widget.currentConfig.getColumnConfig(status);
      _wipLimits[status] = config?.wipLimit;
    }
    _swimlanes = List.from(widget.currentConfig.swimlanes);
    _swimlanesEnabled = widget.currentConfig.swimlanesEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.settings,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Configurar Kanban',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
            ),

            // Tabs
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'WIP Limits', icon: Icon(Icons.category_outlined)),
                Tab(text: 'Swimlanes', icon: Icon(Icons.view_stream_outlined)),
              ],
            ),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildWipLimitsTab(),
                  _buildSwimlanesTab(),
                ],
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _isSaving ? null : _saveConfig,
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Guardar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWipLimitsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Los WIP limits ayudan a evitar sobrecarga y cuellos de botella.',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...TaskStatus.values.map(_buildWipLimitRow),
      ],
    );
  }

  Widget _buildWipLimitRow(TaskStatus status) {
    final color = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Text(
                status.displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            SizedBox(
              width: 120,
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Límite',
                  hintText: 'Sin límite',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: Icon(Icons.workspaces_outlined, size: 18),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(
                  text: _wipLimits[status]?.toString() ?? '',
                ),
                onChanged: (value) {
                  setState(() {
                    _wipLimits[status] =
                        value.isEmpty ? null : int.tryParse(value);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwimlanesTab() {
    return Column(
      children: [
        // Toggle swimlanes
        SwitchListTile(
          title: const Text(
            'Habilitar Swimlanes',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: const Text(
            'Agrupa tareas por prioridad, asignado, etc.',
          ),
          value: _swimlanesEnabled,
          onChanged: (value) {
            setState(() {
              _swimlanesEnabled = value;
            });
          },
        ),
        const Divider(height: 1),

        // Swimlanes list
        Expanded(
          child: _swimlanesEnabled
              ? _buildSwimlanesList()
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.view_stream_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Swimlanes deshabilitados',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSwimlanesList() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Swimlanes configurados',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: _addSwimlane,
              icon: const Icon(Icons.add),
              label: const Text('Agregar'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_swimlanes.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No hay swimlanes configurados.\nAgrega uno con el botón +',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          )
        else
          ..._swimlanes.asMap().entries.map((entry) {
            final index = entry.key;
            final swimlane = entry.value;
            return _buildSwimlaneCard(swimlane, index);
          }),
      ],
    );
  }

  Widget _buildSwimlaneCard(KanbanSwimlane swimlane, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Drag handle
            Icon(Icons.drag_indicator, color: Colors.grey[600]),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    swimlane.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getCriteriaDescription(swimlane.criteria),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Visible toggle
            Switch(
              value: swimlane.isVisible,
              onChanged: (value) {
                setState(() {
                  _swimlanes[index] = swimlane.copyWith(isVisible: value);
                });
              },
            ),

            // Actions
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _editSwimlane(index),
              tooltip: 'Editar',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _deleteSwimlane(index),
              tooltip: 'Eliminar',
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  void _addSwimlane() {
    showDialog(
      context: context,
      builder: (context) => _SwimlaneEditor(
        onSave: (swimlane) {
          setState(() {
            _swimlanes.add(swimlane);
          });
        },
      ),
    );
  }

  void _editSwimlane(int index) {
    showDialog(
      context: context,
      builder: (context) => _SwimlaneEditor(
        initialSwimlane: _swimlanes[index],
        onSave: (swimlane) {
          setState(() {
            _swimlanes[index] = swimlane;
          });
        },
      ),
    );
  }

  void _deleteSwimlane(int index) {
    setState(() {
      _swimlanes.removeAt(index);
    });
  }

  Future<void> _saveConfig() async {
    setState(() => _isSaving = true);

    try {
      final service = KanbanPreferencesService.instance;

      // Guardar WIP limits
      for (final entry in _wipLimits.entries) {
        await service.setWipLimit(widget.projectId, entry.key, entry.value);
      }

      // Guardar swimlanes
      await service.setSwimlanesEnabled(widget.projectId, _swimlanesEnabled);
      await service.setSwimlanes(widget.projectId, _swimlanes);

      widget.onConfigChanged();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Configuración guardada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.planned:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.blocked:
        return Colors.red;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.cancelled:
        return Colors.grey.shade400;
    }
  }

  String _getCriteriaDescription(SwimlaneCriteria criteria) {
    switch (criteria.type) {
      case SwimlaneCriteriaType.all:
        return 'Todas las tareas';
      case SwimlaneCriteriaType.priority:
        return 'Prioridad: ${criteria.value}';
      case SwimlaneCriteriaType.assignee:
        return 'Asignado a: ${criteria.value}';
      case SwimlaneCriteriaType.unassigned:
        return 'Tareas sin asignar';
    }
  }
}

/// Editor de swimlanes
class _SwimlaneEditor extends StatefulWidget {
  final KanbanSwimlane? initialSwimlane;
  final Function(KanbanSwimlane) onSave;

  const _SwimlaneEditor({
    this.initialSwimlane,
    required this.onSave,
  });

  @override
  State<_SwimlaneEditor> createState() => _SwimlaneEditorState();
}

class _SwimlaneEditorState extends State<_SwimlaneEditor> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late SwimlaneCriteriaType _criteriaType;
  dynamic _criteriaValue;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialSwimlane?.name ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialSwimlane?.description ?? '',
    );
    _criteriaType =
        widget.initialSwimlane?.criteria.type ?? SwimlaneCriteriaType.all;
    _criteriaValue = widget.initialSwimlane?.criteria.value;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialSwimlane == null ? 'Nuevo Swimlane' : 'Editar Swimlane',
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<SwimlaneCriteriaType>(
              value: _criteriaType,
              decoration: const InputDecoration(
                labelText: 'Criterio de agrupación',
                border: OutlineInputBorder(),
              ),
              items: SwimlaneCriteriaType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getCriteriaTypeName(type)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _criteriaType = value!;
                  _criteriaValue = null;
                });
              },
            ),
            if (_criteriaType == SwimlaneCriteriaType.priority) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskPriority>(
                value: _criteriaValue as TaskPriority?,
                decoration: const InputDecoration(
                  labelText: 'Prioridad',
                  border: OutlineInputBorder(),
                ),
                items: TaskPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _criteriaValue = value);
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saveSwimlane,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  void _saveSwimlane() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre es requerido')),
      );
      return;
    }

    final swimlane = KanbanSwimlane(
      id: widget.initialSwimlane?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      criteria: SwimlaneCriteria(
        type: _criteriaType,
        value: _criteriaValue,
      ),
      order: widget.initialSwimlane?.order ?? 0,
      isVisible: widget.initialSwimlane?.isVisible ?? true,
    );

    widget.onSave(swimlane);
    Navigator.pop(context);
  }

  String _getCriteriaTypeName(SwimlaneCriteriaType type) {
    switch (type) {
      case SwimlaneCriteriaType.all:
        return 'Todas las tareas';
      case SwimlaneCriteriaType.priority:
        return 'Por prioridad';
      case SwimlaneCriteriaType.assignee:
        return 'Por asignado';
      case SwimlaneCriteriaType.unassigned:
        return 'Sin asignar';
    }
  }
}
