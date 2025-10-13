import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/services/customization_metrics_service.dart';
import '../../domain/entities/customization_event.dart';
import '../../domain/entities/customization_metrics.dart';

/// Pantalla de dashboard de métricas de personalización
///
/// Permite a los administradores ver estadísticas sobre el uso de
/// las opciones de personalización de UI.
class CustomizationMetricsScreen extends StatefulWidget {
  const CustomizationMetricsScreen({super.key});

  @override
  State<CustomizationMetricsScreen> createState() =>
      _CustomizationMetricsScreenState();
}

class _CustomizationMetricsScreenState
    extends State<CustomizationMetricsScreen> {
  final _metricsService = CustomizationMetricsService.instance;
  CustomizationMetrics? _metrics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500)); // Simular carga

    final metrics = _metricsService.generateMetrics();

    setState(() {
      _metrics = metrics;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Métricas de Personalización'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMetrics,
            tooltip: 'Actualizar métricas',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _showClearDialog,
            tooltip: 'Limpiar datos',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _metrics == null || _metrics!.totalEvents == 0
              ? _buildEmptyState()
              : _buildMetricsContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay datos de métricas',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Los eventos de personalización se registrarán automáticamente',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsContent() {
    if (_metrics == null) return const SizedBox();

    return RefreshIndicator(
      onRefresh: _loadMetrics,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildOverviewCard(),
          const SizedBox(height: 16),
          _buildThemeUsageCard(),
          const SizedBox(height: 16),
          _buildLayoutUsageCard(),
          const SizedBox(height: 16),
          _buildWidgetUsageCard(),
          const SizedBox(height: 16),
          _buildEventTypeCard(),
          const SizedBox(height: 16),
          _buildRecentEventsCard(),
        ],
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dashboard,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Resumen General',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              'Total de Eventos',
              _metrics!.totalEvents.toString(),
              Icons.event,
            ),
            const Divider(height: 24),
            _buildStatRow(
              'Usuarios',
              _metrics!.totalUsers.toString(),
              Icons.person,
            ),
            const Divider(height: 24),
            _buildStatRow(
              'Última Actualización',
              _formatDate(_metrics!.lastUpdated),
              Icons.update,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeUsageCard() {
    if (_metrics!.themeUsage.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Temas Más Usados',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._metrics!.themeUsage.take(5).map(
                  (stat) => _buildUsageBar(
                    stat.item,
                    stat.count,
                    stat.percentage,
                    _getThemeColor(stat.item),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayoutUsageCard() {
    if (_metrics!.layoutUsage.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.view_quilt,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Layouts Más Usados',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._metrics!.layoutUsage.take(5).map(
                  (stat) => _buildUsageBar(
                    stat.item,
                    stat.count,
                    stat.percentage,
                    Theme.of(context).colorScheme.secondary,
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetUsageCard() {
    if (_metrics!.widgetUsage.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.widgets,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Widgets Más Usados',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._metrics!.widgetUsage.take(10).map(
                  (stat) => _buildUsageBar(
                    _formatWidgetName(stat.item),
                    stat.count,
                    stat.percentage,
                    Theme.of(context).colorScheme.tertiary,
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventTypeCard() {
    if (_metrics!.eventTypeCount.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tipos de Eventos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._metrics!.eventTypeCount.entries.map(
              (entry) {
                final eventType = CustomizationEventType.values.firstWhere(
                  (e) => e.name == entry.key,
                  orElse: () => CustomizationEventType.themeChanged,
                );
                final total = _metrics!.eventTypeCount.values
                    .reduce((a, b) => a + b);
                final percentage = (entry.value / total) * 100;

                return _buildUsageBar(
                  eventType.displayName,
                  entry.value,
                  percentage,
                  _getEventTypeColor(eventType),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentEventsCard() {
    final recentEvents = _metricsService.getAllEvents().reversed.take(10);

    if (recentEvents.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Eventos Recientes',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recentEvents.map(_buildEventTile),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildUsageBar(
    String label,
    int count,
    double percentage,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$count (${percentage.toStringAsFixed(1)}%)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTile(CustomizationEvent event) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: CircleAvatar(
        backgroundColor: _getEventTypeColor(event.type).withValues(alpha: 0.2),
        child: Icon(
          _getEventTypeIcon(event.type),
          size: 20,
          color: _getEventTypeColor(event.type),
        ),
      ),
      title: Text(event.type.displayName),
      subtitle: Text(
        _formatEventDetails(event),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        _formatTime(event.timestamp),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  Color _getThemeColor(String theme) {
    switch (theme.toLowerCase()) {
      case 'light':
        return Colors.orange;
      case 'dark':
        return Colors.indigo;
      case 'system':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getEventTypeColor(CustomizationEventType type) {
    switch (type) {
      case CustomizationEventType.themeChanged:
        return Colors.blue;
      case CustomizationEventType.layoutChanged:
        return Colors.purple;
      case CustomizationEventType.widgetAdded:
        return Colors.green;
      case CustomizationEventType.widgetRemoved:
        return Colors.red;
      case CustomizationEventType.widgetReordered:
        return Colors.orange;
      case CustomizationEventType.dashboardReset:
        return Colors.grey;
      case CustomizationEventType.preferencesExported:
        return Colors.teal;
      case CustomizationEventType.preferencesImported:
        return Colors.cyan;
    }
  }

  IconData _getEventTypeIcon(CustomizationEventType type) {
    switch (type) {
      case CustomizationEventType.themeChanged:
        return Icons.palette;
      case CustomizationEventType.layoutChanged:
        return Icons.view_quilt;
      case CustomizationEventType.widgetAdded:
        return Icons.add_box;
      case CustomizationEventType.widgetRemoved:
        return Icons.delete;
      case CustomizationEventType.widgetReordered:
        return Icons.swap_vert;
      case CustomizationEventType.dashboardReset:
        return Icons.restore;
      case CustomizationEventType.preferencesExported:
        return Icons.upload;
      case CustomizationEventType.preferencesImported:
        return Icons.download;
    }
  }

  String _formatWidgetName(String name) {
    // Convert camelCase to Title Case
    final result = name.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    );
    return result.trim();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Ahora';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d';
    } else {
      return DateFormat('dd/MM').format(date);
    }
  }

  String _formatEventDetails(CustomizationEvent event) {
    if (event.newValue != null && event.previousValue != null) {
      return '${event.previousValue} → ${event.newValue}';
    } else if (event.newValue != null) {
      return event.newValue!;
    } else if (event.previousValue != null) {
      return event.previousValue!;
    }
    return 'Sin detalles';
  }

  Future<void> _showClearDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar Métricas'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar todos los datos de métricas? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _metricsService.clearAllEvents();
      await _loadMetrics();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Métricas eliminadas correctamente'),
          ),
        );
      }
    }
  }
}
