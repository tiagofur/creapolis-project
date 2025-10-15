import 'package:flutter/material.dart';

/// Widget que muestra una cuadrícula de acciones rápidas en el Dashboard.
///
/// Permite al usuario acceder rápidamente a las funcionalidades más comunes:
/// - Nueva tarea
/// - Nuevo proyecto
/// - Buscar
/// - Notificaciones
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones Rápidas',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _QuickActionButton(
                  icon: Icons.add_task,
                  label: 'Nueva Tarea',
                  color: Colors.blue,
                  onTap: () {
                    // TODO: Implementar navegación a creación de tarea
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Crear nueva tarea - Por implementar'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                _QuickActionButton(
                  icon: Icons.create_new_folder,
                  label: 'Nuevo Proyecto',
                  color: Colors.green,
                  onTap: () {
                    // TODO: Implementar navegación a creación de proyecto
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Crear nuevo proyecto - Por implementar'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                _QuickActionButton(
                  icon: Icons.search,
                  label: 'Buscar',
                  color: Colors.orange,
                  onTap: () {
                    // TODO: Implementar búsqueda global
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Búsqueda - Por implementar'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                _QuickActionButton(
                  icon: Icons.notifications,
                  label: 'Notificaciones',
                  color: Colors.purple,
                  onTap: () {
                    // TODO: Implementar panel de notificaciones
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notificaciones - Por implementar'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón individual de acción rápida
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



