import 'package:flutter/material.dart';

/// Grid de acciones rápidas del dashboard
class QuickActionsGrid extends StatelessWidget {
  final VoidCallback onNewProject;
  final VoidCallback onNewTask;
  final VoidCallback onViewProjects;
  final VoidCallback onViewTasks;

  const QuickActionsGrid({
    super.key,
    required this.onNewProject,
    required this.onNewTask,
    required this.onViewProjects,
    required this.onViewTasks,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _QuickActionCard(
          icon: Icons.add_box,
          label: 'Nuevo Proyecto',
          color: Colors.blue,
          onTap: onNewProject,
        ),
        _QuickActionCard(
          icon: Icons.add_task,
          label: 'Nueva Tarea',
          color: Colors.green,
          onTap: onNewTask,
        ),
        _QuickActionCard(
          icon: Icons.folder_open,
          label: 'Ver Proyectos',
          color: Colors.purple,
          onTap: onViewProjects,
        ),
        _QuickActionCard(
          icon: Icons.list_alt,
          label: 'Ver Tareas',
          color: Colors.orange,
          onTap: onViewTasks,
        ),
      ],
    );
  }
}

/// Card individual de acción rápida
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
