import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import 'package:creapolis_app/domain/entities/project.dart';
import 'package:creapolis_app/domain/entities/task.dart';
import 'package:creapolis_app/domain/repositories/project_repository.dart';
import 'package:creapolis_app/domain/repositories/task_repository.dart';
import 'package:creapolis_app/domain/repositories/workspace_repository.dart';
import 'package:creapolis_app/domain/usecases/get_productivity_heatmap_usecase.dart';

/// BLoC para gestionar el dashboard principal
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final WorkspaceRepository workspaceRepository;
  final ProjectRepository projectRepository;
  final TaskRepository taskRepository;
  final GetProductivityHeatmapUseCase getProductivityHeatmapUseCase;
  final Logger logger = Logger();

  DashboardBloc({
    required this.workspaceRepository,
    required this.projectRepository,
    required this.taskRepository,
    required this.getProductivityHeatmapUseCase,
  }) : super(const DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
    on<LoadProductivityHeatmap>(_onLoadProductivityHeatmap);
  }

  /// Maneja el evento de carga inicial del dashboard
  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      emit(const DashboardLoading());

      // Cargar workspaces
      final workspacesResult = await workspaceRepository.getUserWorkspaces();

      await workspacesResult.fold(
        (failure) {
          logger.e('Error loading workspaces: ${failure.message}');
          emit(DashboardError(failure.message));
        },
        (workspaces) async {
          if (workspaces.isEmpty) {
            // Sin workspaces, mostrar estado vacío
            emit(
              DashboardLoaded(
                workspaces: const [],
                allProjects: const <Project>[],
                activeProjects: [],
                pendingTasks: [],
                recentTasks: [],
                stats: const DashboardStats(
                  totalWorkspaces: 0,
                  totalProjects: 0,
                  totalTasks: 0,
                  completedTasks: 0,
                  inProgressTasks: 0,
                  completionRate: 0.0,
                ),
              ),
            );
            return;
          }

          // Cargar proyectos de todos los workspaces
          final allProjects = <Project>[];
          final allTasks = <Task>[];

          for (final workspace in workspaces) {
            // Obtener proyectos del workspace
            final projectsResult = await projectRepository.getProjects(
              workspaceId: workspace.id,
            );

            await projectsResult.fold(
              (failure) {
                logger.w(
                  'Error loading projects for workspace ${workspace.id}: ${failure.message}',
                );
              },
              (projects) async {
                allProjects.addAll(projects);

                // Obtener tareas de cada proyecto
                for (final project in projects) {
                  final tasksResult = await taskRepository.getTasksByProject(
                    project.id,
                  );

                  tasksResult.fold(
                    (failure) {
                      logger.w(
                        'Error loading tasks for project ${project.id}: ${failure.message}',
                      );
                    },
                    (tasks) {
                      allTasks.addAll(tasks);
                    },
                  );
                }
              },
            );
          }

          // Filtrar proyectos activos (status ACTIVE o IN_PROGRESS)
          final activeProjects = allProjects.where((project) {
            return project.status != ProjectStatus.completed &&
                project.status != ProjectStatus.cancelled;
          }).toList();

          // Filtrar tareas pendientes (status != COMPLETED && != CANCELLED)
          final pendingTasks = allTasks.where((task) {
            return task.status != TaskStatus.completed &&
                task.status != TaskStatus.cancelled;
          }).toList();

          // Ordenar tareas por fecha de actualización (más recientes primero)
          final recentTasks = List<Task>.from(allTasks)
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          final top5RecentTasks = recentTasks.take(5).toList();

          // Calcular estadísticas
          final completedTasks = allTasks
              .where((t) => t.status == TaskStatus.completed)
              .length;
          final inProgressTasks = allTasks
              .where((t) => t.status == TaskStatus.inProgress)
              .length;
          final completionRate = allTasks.isEmpty
              ? 0.0
              : (completedTasks / allTasks.length) * 100;

          final stats = DashboardStats(
            totalWorkspaces: workspaces.length,
            totalProjects: allProjects.length,
            totalTasks: allTasks.length,
            completedTasks: completedTasks,
            inProgressTasks: inProgressTasks,
            completionRate: completionRate,
          );

          // Cargar heatmap de productividad (últimos 30 días)
          final now = DateTime.now();
          final startDate = now.subtract(const Duration(days: 30));

          final heatmapResult = await getProductivityHeatmapUseCase(
            GetProductivityHeatmapParams(startDate: startDate, endDate: now),
          );

          heatmapResult.fold(
            (failure) {
              logger.w(
                'Error loading productivity heatmap: ${failure.message}',
              );
              // Emitir estado sin heatmap
              emit(
                DashboardLoaded(
                  workspaces: workspaces,
                  allProjects: allProjects,
                  activeProjects: activeProjects,
                  pendingTasks: pendingTasks,
                  recentTasks: top5RecentTasks,
                  stats: stats,
                  productivityHeatmap: null,
                ),
              );
            },
            (heatmap) {
              emit(
                DashboardLoaded(
                  workspaces: workspaces,
                  allProjects: allProjects,
                  activeProjects: activeProjects,
                  pendingTasks: pendingTasks,
                  recentTasks: top5RecentTasks,
                  stats: stats,
                  productivityHeatmap: heatmap,
                ),
              );
            },
          );

          logger.i('Dashboard data loaded successfully');
        },
      );
    } catch (e, stackTrace) {
      logger.e(
        'Unexpected error loading dashboard',
        error: e,
        stackTrace: stackTrace,
      );
      emit(DashboardError('Error inesperado: ${e.toString()}'));
    }
  }

  /// Maneja el evento de refresco del dashboard
  Future<void> _onRefreshDashboardData(
    RefreshDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    // Reutilizar la lógica de carga
    await _onLoadDashboardData(const LoadDashboardData(), emit);
  }

  Future<void> _onLoadProductivityHeatmap(
    LoadProductivityHeatmap event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is! DashboardLoaded) return;
    final currentState = state as DashboardLoaded;

    // Mantener el estado actual pero indicando carga si fuera necesario
    // Por ahora solo actualizamos el heatmap

    final now = DateTime.now();
    final startDate = event.startDate ?? now.subtract(const Duration(days: 30));
    final endDate = event.endDate ?? now;

    final heatmapResult = await getProductivityHeatmapUseCase(
      GetProductivityHeatmapParams(
        startDate: startDate,
        endDate: endDate,
        teamView: event.teamView,
      ),
    );

    heatmapResult.fold(
      (failure) {
        logger.w('Error loading productivity heatmap: ${failure.message}');
        // No cambiamos el estado general a error, solo el heatmap a null o mantenemos el anterior
        // Podríamos añadir un campo error específico para el heatmap
      },
      (heatmap) {
        emit(
          DashboardLoaded(
            workspaces: currentState.workspaces,
            allProjects: currentState.allProjects,
            activeProjects: currentState.activeProjects,
            pendingTasks: currentState.pendingTasks,
            recentTasks: currentState.recentTasks,
            stats: currentState.stats,
            productivityHeatmap: heatmap,
          ),
        );
      },
    );
  }
}
