import 'package:flutter/material.dart';

import '../../../domain/repositories/workload_repository.dart';

/// Card con estadísticas de workload
class WorkloadStatsCard extends StatelessWidget {
  final WorkloadStats stats;

  const WorkloadStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Estadísticas del Equipo',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Grid de estadísticas
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Total Miembros',
                    value: '${stats.totalMembers}',
                    icon: Icons.people,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatItem(
                    label: 'Sobrecargados',
                    value: '${stats.overloadedMembers}',
                    icon: Icons.warning,
                    color: stats.overloadedMembers > 0
                        ? colorScheme.error
                        : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Promedio h/miembro',
                    value: stats.averageHoursPerMember.toStringAsFixed(1),
                    icon: Icons.schedule,
                    color: colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatItem(
                    label: '% Sobrecarga',
                    value: '${stats.overloadPercentage.toStringAsFixed(1)}%',
                    icon: Icons.trending_up,
                    color: _getColorForPercentage(
                      stats.overloadPercentage,
                      colorScheme,
                    ),
                  ),
                ),
              ],
            ),

            // Indicador de balance
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            Row(
              children: [
                Icon(
                  stats.isBalanced ? Icons.check_circle : Icons.warning,
                  color: stats.isBalanced ? Colors.green : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    stats.isBalanced
                        ? 'Carga de trabajo balanceada'
                        : 'Atención: Equipo con sobrecarga',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: stats.isBalanced ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),

            // Distribución por nivel de carga
            if (stats.distributionByLoadLevel.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Text('Distribución de Carga', style: theme.textTheme.labelMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _DistributionChip(
                    label: 'Baja (<6h)',
                    count: stats.distributionByLoadLevel['low'] ?? 0,
                    color: Colors.green,
                  ),
                  _DistributionChip(
                    label: 'Media (6-8h)',
                    count: stats.distributionByLoadLevel['medium'] ?? 0,
                    color: Colors.orange,
                  ),
                  _DistributionChip(
                    label: 'Alta (>8h)',
                    count: stats.distributionByLoadLevel['high'] ?? 0,
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Obtiene el color según el porcentaje de sobrecarga
  Color _getColorForPercentage(double percentage, ColorScheme colorScheme) {
    if (percentage > 30) return colorScheme.error;
    if (percentage > 15) return Colors.orange;
    return Colors.green;
  }
}

/// Item de estadística
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip de distribución
class _DistributionChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _DistributionChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color,
        child: Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
      labelStyle: theme.textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
