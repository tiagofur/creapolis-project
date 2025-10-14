import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_logger.dart';
import '../../../injection.dart';
import '../../bloc/workload/workload_bloc.dart';
import '../../bloc/workload/workload_event.dart';
import '../../bloc/workload/workload_state.dart';
import '../../widgets/resource_map/resource_map_view.dart';
import '../../widgets/workload/date_range_selector.dart';
import '../../widgets/workload/workload_stats_card.dart';

/// Pantalla de mapa de asignación de recursos con drag & drop
class ResourceAllocationMapScreen extends StatefulWidget {
  final int projectId;

  const ResourceAllocationMapScreen({super.key, required this.projectId});

  @override
  State<ResourceAllocationMapScreen> createState() =>
      _ResourceAllocationMapScreenState();
}

class _ResourceAllocationMapScreenState
    extends State<ResourceAllocationMapScreen> {
  String _viewMode = 'grid'; // 'grid' o 'list'
  String _filterBy = 'all'; // 'all', 'overloaded', 'available'
  String _sortBy = 'name'; // 'name', 'workload', 'availability'

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<WorkloadBloc>()
            ..add(LoadResourceAllocationEvent(widget.projectId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mapa de Recursos'),
          actions: [
            // Vista switcher
            IconButton(
              icon: Icon(
                _viewMode == 'grid' ? Icons.view_list : Icons.grid_view,
              ),
              tooltip: _viewMode == 'grid'
                  ? 'Vista de lista'
                  : 'Vista de cuadrícula',
              onPressed: () {
                setState(() {
                  _viewMode = _viewMode == 'grid' ? 'list' : 'grid';
                });
              },
            ),
            // Filter menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filtrar',
              onSelected: (value) {
                setState(() {
                  _filterBy = value;
                });
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'all',
                  child: Row(
                    children: [
                      Icon(Icons.people),
                      SizedBox(width: 8),
                      Text('Todos'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'overloaded',
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Sobrecargados'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'available',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Disponibles'),
                    ],
                  ),
                ),
              ],
            ),
            // Sort menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort),
              tooltip: 'Ordenar',
              onSelected: (value) {
                setState(() {
                  _sortBy = value;
                });
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'name',
                  child: Row(
                    children: [
                      Icon(Icons.sort_by_alpha),
                      SizedBox(width: 8),
                      Text('Nombre'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'workload',
                  child: Row(
                    children: [
                      Icon(Icons.show_chart),
                      SizedBox(width: 8),
                      Text('Carga de trabajo'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'availability',
                  child: Row(
                    children: [
                      Icon(Icons.schedule),
                      SizedBox(width: 8),
                      Text('Disponibilidad'),
                    ],
                  ),
                ),
              ],
            ),
            // Refresh
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
    // Aplicar filtros
    var filteredAllocations = state.allocations;
    
    if (_filterBy == 'overloaded') {
      filteredAllocations = filteredAllocations
          .where((a) => a.isOverloaded)
          .toList();
    } else if (_filterBy == 'available') {
      filteredAllocations = filteredAllocations
          .where((a) => !a.isOverloaded && a.averageHoursPerDay < 6.0)
          .toList();
    }

    // Aplicar ordenamiento
    filteredAllocations = List.from(filteredAllocations);
    if (_sortBy == 'name') {
      filteredAllocations.sort((a, b) => a.userName.compareTo(b.userName));
    } else if (_sortBy == 'workload') {
      filteredAllocations.sort((a, b) => 
        b.totalHours.compareTo(a.totalHours)
      );
    } else if (_sortBy == 'availability') {
      filteredAllocations.sort((a, b) => 
        a.averageHoursPerDay.compareTo(b.averageHoursPerDay)
      );
    }

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

          // Información de filtros activos
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildFilterInfo(context, filteredAllocations.length, state.allocations.length),
            ),
          ),

          // Vista de recursos
          if (filteredAllocations.isEmpty)
            SliverFillRemaining(child: _buildEmptyState(context))
          else
            SliverToBoxAdapter(
              child: ResourceMapView(
                allocations: filteredAllocations,
                allAllocations: state.allocations,
                dates: state.allDates,
                projectId: widget.projectId,
                viewMode: _viewMode,
              ),
            ),

          // Espacio final
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  /// Información de filtros activos
  Widget _buildFilterInfo(BuildContext context, int filtered, int total) {
    if (filtered == total) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Mostrando $filtered de $total recursos',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _filterBy = 'all';
              });
            },
            child: Text(
              'Limpiar filtro',
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Estado vacío
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String message;
    IconData icon;
    
    if (_filterBy == 'overloaded') {
      message = 'No hay recursos sobrecargados';
      icon = Icons.check_circle;
    } else if (_filterBy == 'available') {
      message = 'No hay recursos disponibles';
      icon = Icons.people_outline;
    } else {
      message = 'No hay asignaciones de recursos';
      icon = Icons.people_outline;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajusta los filtros o el rango de fechas\npara ver más recursos',
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
            'Error al cargar recursos',
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
              AppLogger.info('ResourceMapScreen: Reintentando carga');
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
