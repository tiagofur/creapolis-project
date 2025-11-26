import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/productivity_heatmap.dart';
import '../../../domain/usecases/get_productivity_heatmap_usecase.dart';
import '../../../injection.dart';
import '../dashboard/widgets/hourly_productivity_heatmap_widget.dart';
import '../dashboard/widgets/weekly_productivity_heatmap_widget.dart';

/// Pantalla de reportes de time tracking
/// Muestra estadísticas, heatmaps y timeline de trabajo
class TimeReportsScreen extends StatefulWidget {
  final int? projectId;
  final int? workspaceId;

  const TimeReportsScreen({
    super.key,
    this.projectId,
    this.workspaceId,
  });

  @override
  State<TimeReportsScreen> createState() => _TimeReportsScreenState();
}

class _TimeReportsScreenState extends State<TimeReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _startDate;
  late DateTime _endDate;
  bool _isTeamView = false;
  ProductivityHeatmap? _heatmapData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Default: últimos 7 días
    _endDate = DateTime.now();
    _startDate = _endDate.subtract(const Duration(days: 7));
    
    _loadHeatmapData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHeatmapData() async {
    setState(() => _isLoading = true);

    final useCase = getIt<GetProductivityHeatmapUseCase>();
    final result = await useCase(
      GetProductivityHeatmapParams(
        startDate: _startDate,
        endDate: _endDate,
        projectId: widget.projectId,
        teamView: _isTeamView,
        workspaceId: widget.workspaceId,
      ),
    );

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error cargando datos: ${failure.message}')),
          );
        }
      },
      (data) {
        if (mounted) {
          setState(() => _heatmapData = data);
        }
      },
    );

    setState(() => _isLoading = false);
  }

  void _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadHeatmapData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes de Tiempo'),
        actions: [
          // Date range selector
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _showDateRangePicker,
            tooltip: 'Seleccionar rango de fechas',
          ),
          // Export button
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportReport,
            tooltip: 'Exportar reporte',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: 'Resumen'),
            Tab(icon: Icon(Icons.grid_on), text: 'Heatmaps'),
            Tab(icon: Icon(Icons.timeline), text: 'Timeline'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Date range indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  '${DateFormat('dd MMM yyyy').format(_startDate)} - ${DateFormat('dd MMM yyyy').format(_endDate)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _showDateRangePicker,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Cambiar'),
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildHeatmapsTab(),
                _buildTimelineTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_heatmapData == null) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    final data = _heatmapData!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Quick stats grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Total Horas',
              '${data.totalHours.toStringAsFixed(1)}h',
              Icons.access_time,
              Colors.blue,
            ),
            _buildStatCard(
              'Promedio/Día',
              '${data.avgHoursPerDay.toStringAsFixed(1)}h',
              Icons.trending_up,
              Colors.green,
            ),
            _buildStatCard(
              'Hora Pico',
              '${data.peakHour}:00',
              Icons.schedule,
              Colors.orange,
            ),
            _buildStatCard(
              'Registros',
              '${data.totalLogs}',
              Icons.checklist,
              Colors.purple,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Peak day card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Día Más Productivo',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _getDayName(data.peakDay),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${data.weeklyData[data.peakDay].toStringAsFixed(1)} horas trabajadas',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Top productive slots
        if (data.topProductiveSlots.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Franjas Más Productivas',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...data.topProductiveSlots.map((slot) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_getDayName(slot.day)}, ${slot.hour}:00 - ${slot.hour + 1}:00',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Text(
                                    '${slot.hours.toStringAsFixed(1)} horas',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Insights
        if (data.insights.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Insights',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...data.insights.map((insight) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Icon(
                              _getInsightIcon(insight.icon),
                              color: _getInsightColor(insight.type),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                insight.message,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHeatmapsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Team view toggle
        Card(
          child: SwitchListTile(
            title: const Text('Vista de Equipo'),
            subtitle: Text(_isTeamView
                ? 'Mostrando datos del equipo completo'
                : 'Mostrando solo tus datos'),
            value: _isTeamView,
            onChanged: (value) {
              setState(() => _isTeamView = value);
              _loadHeatmapData();
            },
            secondary: Icon(
              _isTeamView ? Icons.groups : Icons.person,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Hourly heatmap
        HourlyProductivityHeatmapWidget(
          isTeamView: _isTeamView,
          data: _heatmapData,
          onTeamViewChanged: (value) {
            setState(() => _isTeamView = value);
            _loadHeatmapData();
          },
        ),

        const SizedBox(height: 16),

        // Weekly heatmap
        WeeklyProductivityHeatmapWidget(
          isTeamView: _isTeamView,
          data: _heatmapData,
          onTeamViewChanged: (value) {
            setState(() => _isTeamView = value);
            _loadHeatmapData();
          },
        ),
      ],
    );
  }

  Widget _buildTimelineTab() {
    // TODO: Implementar timeline view con gráficos de línea
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Timeline View',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Próximamente: Gráfico de línea de tiempo',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                Icon(icon, size: 20, color: color),
              ],
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(int day) {
    const days = [
      'Domingo',
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado'
    ];
    return days[day % 7];
  }

  IconData _getInsightIcon(String icon) {
    switch (icon) {
      case 'morning':
        return Icons.wb_sunny;
      case 'afternoon':
        return Icons.wb_twilight;
      case 'calendar':
        return Icons.calendar_today;
      case 'trending_up':
        return Icons.trending_up;
      case 'trending_down':
        return Icons.trending_down;
      default:
        return Icons.lightbulb;
    }
  }

  Color _getInsightColor(String type) {
    final theme = Theme.of(context);
    switch (type) {
      case 'peak_morning':
      case 'peak_afternoon':
      case 'peak_weekday':
        return theme.colorScheme.primary;
      case 'high_productivity':
        return Colors.green;
      case 'low_productivity':
        return Colors.orange;
      default:
        return theme.colorScheme.onSurface;
    }
  }

  Future<void> _exportReport() async {
    // TODO: Implementar exportación a PDF/Excel
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de exportación próximamente'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
