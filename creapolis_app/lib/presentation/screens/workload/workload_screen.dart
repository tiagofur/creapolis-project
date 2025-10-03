import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_logger.dart';
import '../../../injection.dart';
import '../../bloc/workload/workload_bloc.dart';
import '../../bloc/workload/workload_event.dart';
import '../../bloc/workload/workload_state.dart';
import '../../widgets/workload/date_range_selector.dart';
import '../../widgets/workload/resource_allocation_grid.dart';
import '../../widgets/workload/workload_stats_card.dart';

/// Pantalla de carga de trabajo
class WorkloadScreen extends StatefulWidget {
  final int projectId;

  const WorkloadScreen({super.key, required this.projectId});

  @override
  State<WorkloadScreen> createState() => _WorkloadScreenState();
}

class _WorkloadScreenState extends State<WorkloadScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<WorkloadBloc>()
            ..add(LoadResourceAllocationEvent(widget.projectId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Carga de Trabajo'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<WorkloadBloc>().add(
                  RefreshWorkloadEvent(widget.projectId),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<WorkloadBloc, WorkloadState>(
          listener: (context, state) {
            if (state is WorkloadError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is WorkloadLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ResourceAllocationLoaded) {
              return _buildContent(context, state);
            }

            if (state is WorkloadError) {
              return _buildErrorState(context, state.message);
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  /// Construir contenido principal
  Widget _buildContent(BuildContext context, ResourceAllocationLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<WorkloadBloc>().add(
          RefreshWorkloadEvent(widget.projectId),
        );
        await Future.delayed(const Duration(seconds: 1));
      },
      child: CustomScrollView(
        slivers: [
          // Selector de rango de fechas
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DateRangeSelector(
                startDate: state.startDate ?? state.dateRange?.start,
                endDate: state.endDate ?? state.dateRange?.end,
                onDateRangeChanged: (start, end) {
                  context.read<WorkloadBloc>().add(
                    ChangeDateRangeEvent(widget.projectId, start, end),
                  );
                },
              ),
            ),
          ),

          // Tarjeta de estadísticas (si está disponible)
          if (state.stats != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: WorkloadStatsCard(stats: state.stats!),
              ),
            ),

          // Espacio
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Grid de resource allocation
          if (state.allocations.isEmpty)
            SliverFillRemaining(child: _buildEmptyState(context))
          else
            SliverToBoxAdapter(
              child: ResourceAllocationGrid(
                allocations: state.allocations,
                dates: state.allDates,
              ),
            ),

          // Espacio final
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  /// Estado vacío
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay asignaciones',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No se encontraron asignaciones de recursos\npara el período seleccionado',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Estado de error
  Widget _buildErrorState(BuildContext context, String message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Error al cargar workload',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              AppLogger.info('WorkloadScreen: Reintentando carga');
              context.read<WorkloadBloc>().add(
                LoadResourceAllocationEvent(widget.projectId),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
