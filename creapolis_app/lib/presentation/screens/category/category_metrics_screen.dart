import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../domain/entities/task_category.dart';
import '../../bloc/category/category_bloc.dart';

/// Pantalla para mostrar métricas de precisión del modelo de IA
class CategoryMetricsScreen extends StatefulWidget {
  const CategoryMetricsScreen({super.key});

  @override
  State<CategoryMetricsScreen> createState() => _CategoryMetricsScreenState();
}

class _CategoryMetricsScreenState extends State<CategoryMetricsScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar métricas al iniciar
    context.read<CategoryBloc>().add(const GetCategoryMetricsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Métricas de Categorización IA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<CategoryBloc>().add(const GetCategoryMetricsEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryMetricsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is CategoryMetricsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar métricas',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<CategoryBloc>().add(const GetCategoryMetricsEvent());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is CategoryMetricsLoaded) {
            return _buildMetricsContent(context, state.metrics);
          }

          return const Center(
            child: Text('Carga las métricas para comenzar'),
          );
        },
      ),
    );
  }

  Widget _buildMetricsContent(BuildContext context, CategoryMetrics metrics) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<CategoryBloc>().add(const GetCategoryMetricsEvent());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de resumen
            _buildSummaryCard(context, metrics),
            const SizedBox(height: 24),

            // Gráfico de precisión general
            _buildAccuracyChart(context, metrics),
            const SizedBox(height: 24),

            // Distribución por categoría
            _buildCategoryDistribution(context, metrics),
            const SizedBox(height: 24),

            // Precisión por categoría
            _buildCategoryAccuracy(context, metrics),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, CategoryMetrics metrics) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen General',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    context,
                    'Total Sugerencias',
                    metrics.totalSuggestions.toString(),
                    Icons.auto_awesome,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    context,
                    'Correctas',
                    metrics.correctSuggestions.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    context,
                    'Incorrectas',
                    metrics.incorrectSuggestions.toString(),
                    Icons.cancel,
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    context,
                    'Precisión',
                    '${(metrics.accuracy * 100).toStringAsFixed(1)}%',
                    Icons.analytics,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Última actualización: ${_formatDateTime(metrics.lastUpdated)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAccuracyChart(BuildContext context, CategoryMetrics metrics) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Precisión General',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: metrics.correctSuggestions.toDouble(),
                      title: 'Correctas\n${metrics.correctSuggestions}',
                      color: Colors.green,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: metrics.incorrectSuggestions.toDouble(),
                      title: 'Incorrectas\n${metrics.incorrectSuggestions}',
                      color: Colors.red,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDistribution(BuildContext context, CategoryMetrics metrics) {
    final sortedEntries = metrics.categoryDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribución por Categoría',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...sortedEntries.map((entry) {
              final percentage = metrics.totalSuggestions > 0
                  ? (entry.value / metrics.totalSuggestions * 100)
                  : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              entry.key.icon,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(entry.key.displayName),
                          ],
                        ),
                        Text(
                          '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[300],
                      minHeight: 8,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryAccuracy(BuildContext context, CategoryMetrics metrics) {
    final sortedEntries = metrics.categoryAccuracy.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Precisión por Categoría',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...sortedEntries.map((entry) {
              final accuracy = entry.value * 100;
              final color = accuracy >= 80
                  ? Colors.green
                  : accuracy >= 60
                      ? Colors.orange
                      : Colors.red;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              entry.key.icon,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(entry.key.displayName),
                          ],
                        ),
                        Text(
                          '${accuracy.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: entry.value,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 8,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}



