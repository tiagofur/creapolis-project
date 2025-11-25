import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/error/error_message_mapper.dart';
import '../../../domain/entities/portfolio_stats.dart';
import '../../../domain/entities/project.dart';
import '../../../features/projects/presentation/blocs/project_bloc.dart';
import '../../../features/projects/presentation/blocs/project_event.dart';
import '../../../features/projects/presentation/blocs/project_state.dart';
import '../../providers/workspace_context.dart';
import '../../widgets/common/main_drawer.dart';
import '../../widgets/error/friendly_error_widget.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final workspaceId = context.read<WorkspaceContext>().activeWorkspace?.id;
      if (workspaceId != null) {
        context.read<ProjectBloc>().add(LoadPortfolioStats(workspaceId));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Portafolio de Proyectos')),
      drawer: const MainDrawer(),
      body: BlocBuilder<ProjectBloc, ProjectState>(
        builder: (context, state) {
          if (state is ProjectLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PortfolioStatsLoaded) {
            return _buildContent(context, state.stats);
          } else if (state is ProjectError) {
            return FriendlyErrorWidget(
              errorMessage: FriendlyErrorMessage(
                title: 'Error al cargar portafolio',
                message: state.message,
                icon: Icons.error_outline,
                color: Colors.red,
                suggestion: 'Verifica tu conexión e intenta nuevamente.',
                severity: ErrorSeverity.error,
                canRetry: true,
              ),
              onRetry: () {
                final workspaceId = context
                    .read<WorkspaceContext>()
                    .activeWorkspace
                    ?.id;
                if (workspaceId != null) {
                  context.read<ProjectBloc>().add(
                    LoadPortfolioStats(workspaceId),
                  );
                }
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, PortfolioStats stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(context, stats),
          const SizedBox(height: 24),
          _buildStatusChart(context, stats),
          const SizedBox(height: 24),
          _buildUpcomingDeadlines(context, stats),
          const SizedBox(height: 24),
          _buildTimeline(context, stats),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, PortfolioStats stats) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Total',
            value: stats.totalProjects.toString(),
            icon: Icons.folder,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _SummaryCard(
            title: 'Progreso',
            value: '${(stats.avgProgress * 100).toStringAsFixed(1)}%',
            icon: Icons.trending_up,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChart(BuildContext context, PortfolioStats stats) {
    final theme = Theme.of(context);
    final data = stats.statusDistribution;

    if (data.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estado de Proyectos', style: theme.textTheme.titleMedium),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: data.entries.map((e) {
                    return PieChartSectionData(
                      value: e.value.toDouble(),
                      title: '${e.value}',
                      color: _getColorForStatus(e.key),
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: data.entries.map((e) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getColorForStatus(e.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${e.key.label} (${e.value})'),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingDeadlines(BuildContext context, PortfolioStats stats) {
    final theme = Theme.of(context);
    final deadlines = stats.upcomingDeadlines;

    if (deadlines.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Próximos Vencimientos', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: deadlines.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final project = deadlines[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(project.name),
                  subtitle: Text(
                    'Vence: ${DateFormat.yMMMd().format(project.endDate)}',
                  ),
                  trailing: _StatusBadge(status: project.status),
                  onTap: () {
                    context.push(
                      '/more/workspaces/${project.workspaceId}/projects/${project.id}',
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, PortfolioStats stats) {
    final theme = Theme.of(context);
    final projects = stats.allProjects;

    if (projects.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Línea de Tiempo', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
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
                              project.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${(project.progress * 100).toInt()}%',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: project.progress,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        color: _getColorForStatus(project.status),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat.MMMd().format(project.startDate)} - ${DateFormat.MMMd().format(project.endDate)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForStatus(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planned:
        return Colors.grey;
      case ProjectStatus.active:
        return Colors.blue;
      case ProjectStatus.paused:
        return Colors.orange;
      case ProjectStatus.completed:
        return Colors.green;
      case ProjectStatus.cancelled:
        return Colors.red;
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(title, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ProjectStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case ProjectStatus.planned:
        color = Colors.grey;
        break;
      case ProjectStatus.active:
        color = Colors.blue;
        break;
      case ProjectStatus.paused:
        color = Colors.orange;
        break;
      case ProjectStatus.completed:
        color = Colors.green;
        break;
      case ProjectStatus.cancelled:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
