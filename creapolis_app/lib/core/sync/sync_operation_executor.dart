import 'dart:convert';
import 'package:injectable/injectable.dart';
import '../../data/models/hive/hive_operation_queue.dart';
import '../../data/datasources/workspace_remote_datasource.dart';
import '../../data/datasources/project_remote_datasource.dart';
import '../../data/datasources/task_remote_datasource.dart';
import '../../features/workspace/data/models/workspace_model.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/task.dart';
import '../utils/app_logger.dart';

/// Ejecutor de operaciones encoladas
///
/// Toma operaciones de la cola y las ejecuta contra los data sources remotos.
/// Soporta 9 tipos de operaciones:
/// - Workspace: create, update, delete
/// - Project: create, update, delete
/// - Task: create, update, delete
@lazySingleton
class SyncOperationExecutor {
  final WorkspaceRemoteDataSource _workspaceRemoteDataSource;
  final ProjectRemoteDataSource _projectRemoteDataSource;
  final TaskRemoteDataSource _taskRemoteDataSource;

  SyncOperationExecutor(
    this._workspaceRemoteDataSource,
    this._projectRemoteDataSource,
    this._taskRemoteDataSource,
  );

  /// Ejecutar una operación encolada
  ///
  /// Retorna `true` si la operación se ejecutó exitosamente.
  /// Retorna `false` si hubo error.
  /// Lanza excepción si el tipo de operación no es soportado.
  Future<bool> executeOperation(HiveOperationQueue operation) async {
    try {
      AppLogger.info(
        'SyncOperationExecutor: Ejecutando operación ${operation.type}',
      );

      final data = _decodeOperationData(operation.data);

      switch (operation.type) {
        // ========== WORKSPACE OPERATIONS ==========
        case 'create_workspace':
          return await _executeCreateWorkspace(data);
        case 'update_workspace':
          return await _executeUpdateWorkspace(data);
        case 'delete_workspace':
          return await _executeDeleteWorkspace(data);

        // ========== PROJECT OPERATIONS ==========
        case 'create_project':
          return await _executeCreateProject(data);
        case 'update_project':
          return await _executeUpdateProject(data);
        case 'delete_project':
          return await _executeDeleteProject(data);

        // ========== TASK OPERATIONS ==========
        case 'create_task':
          return await _executeCreateTask(data);
        case 'update_task':
          return await _executeUpdateTask(data);
        case 'delete_task':
          return await _executeDeleteTask(data);

        default:
          throw UnimplementedError('Operación no soportada: ${operation.type}');
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'SyncOperationExecutor: Error ejecutando ${operation.type}',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Decodificar datos de operación
  Map<String, dynamic> _decodeOperationData(String data) {
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      AppLogger.error('Error decodificando datos de operación', e);
      return {};
    }
  }

  // ========== WORKSPACE OPERATIONS ==========

  Future<bool> _executeCreateWorkspace(Map<String, dynamic> data) async {
    try {
      final workspace = await _workspaceRemoteDataSource.createWorkspace(
        name: data['name'] as String,
        description: data['description'] as String?,
        avatarUrl: data['avatarUrl'] as String?,
        type: _parseWorkspaceType(data['type'] as String?),
        settings: _parseWorkspaceSettings(data['settings']),
      );
      AppLogger.info('Workspace creado exitosamente: ${workspace.id}');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Error en _executeCreateWorkspace', e, stackTrace);
      return false;
    }
  }

  Future<bool> _executeUpdateWorkspace(Map<String, dynamic> data) async {
    try {
      final workspaceId = data['id'] as int?;
      if (workspaceId == null) {
        AppLogger.error('ID de workspace no encontrado en data');
        return false;
      }

      final workspace = await _workspaceRemoteDataSource.updateWorkspace(
        workspaceId: workspaceId,
        name: data['name'] as String?,
        description: data['description'] as String?,
        avatarUrl: data['avatarUrl'] as String?,
        type: _parseWorkspaceType(data['type'] as String?),
        settings: _parseWorkspaceSettings(data['settings']),
      );
      AppLogger.info('Workspace actualizado exitosamente: ${workspace.id}');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Error en _executeUpdateWorkspace', e, stackTrace);
      return false;
    }
  }

  Future<bool> _executeDeleteWorkspace(Map<String, dynamic> data) async {
    try {
      final workspaceId = data['id'] as int?;
      if (workspaceId == null) {
        AppLogger.error('ID de workspace no encontrado en data');
        return false;
      }

      await _workspaceRemoteDataSource.deleteWorkspace(workspaceId);
      AppLogger.info('Workspace eliminado exitosamente: $workspaceId');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Error en _executeDeleteWorkspace', e, stackTrace);
      return false;
    }
  }

  // ========== PROJECT OPERATIONS ==========

  Future<bool> _executeCreateProject(Map<String, dynamic> data) async {
    try {
      final project = await _projectRemoteDataSource.createProject(
        name: data['name'] as String,
        description: data['description'] as String,
        startDate: DateTime.parse(data['startDate'] as String),
        endDate: DateTime.parse(data['endDate'] as String),
        status: _parseProjectStatus(data['status'] as String),
        managerId: data['managerId'] as int?,
        workspaceId: data['workspaceId'] as int,
      );
      AppLogger.info('Project creado exitosamente: ${project.id}');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Error en _executeCreateProject', e, stackTrace);
      return false;
    }
  }

  Future<bool> _executeUpdateProject(Map<String, dynamic> data) async {
    try {
      final projectId = data['id'] as int?;
      if (projectId == null) {
        AppLogger.error('ID de project no encontrado en data');
        return false;
      }

      final project = await _projectRemoteDataSource.updateProject(
        id: projectId,
        name: data['name'] as String?,
        description: data['description'] as String?,
        startDate: data['startDate'] != null
            ? DateTime.parse(data['startDate'] as String)
            : null,
        endDate: data['endDate'] != null
            ? DateTime.parse(data['endDate'] as String)
            : null,
        status: data['status'] != null
            ? _parseProjectStatus(data['status'] as String)
            : null,
        managerId: data['managerId'] as int?,
      );
      AppLogger.info('Project actualizado exitosamente: ${project.id}');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Error en _executeUpdateProject', e, stackTrace);
      return false;
    }
  }

  Future<bool> _executeDeleteProject(Map<String, dynamic> data) async {
    try {
      final projectId = data['id'] as int?;
      if (projectId == null) {
        AppLogger.error('ID de project no encontrado en data');
        return false;
      }

      await _projectRemoteDataSource.deleteProject(projectId);
      AppLogger.info('Project eliminado exitosamente: $projectId');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Error en _executeDeleteProject', e, stackTrace);
      return false;
    }
  }

  // ========== TASK OPERATIONS ==========

  Future<bool> _executeCreateTask(Map<String, dynamic> data) async {
    try {
      final task = await _taskRemoteDataSource.createTask(
        title: data['title'] as String,
        description: data['description'] as String,
        status: _parseTaskStatus(data['status'] as String),
        priority: _parseTaskPriority(data['priority'] as String),
        startDate: DateTime.parse(data['startDate'] as String),
        endDate: DateTime.parse(data['endDate'] as String),
        estimatedHours: (data['estimatedHours'] as num).toDouble(),
        projectId: data['projectId'] as int,
        assignedUserId: data['assignedUserId'] as int?,
        dependencyIds: (data['dependencyIds'] as List?)?.cast<int>(),
      );
      AppLogger.info('Task creada exitosamente: ${task.id}');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Error en _executeCreateTask', e, stackTrace);
      return false;
    }
  }

  Future<bool> _executeUpdateTask(Map<String, dynamic> data) async {
    try {
      final taskId = data['id'] as int?;
      final projectId = data['projectId'] as int?;

      if (taskId == null || projectId == null) {
        AppLogger.error('ID de task o projectId no encontrado en data');
        return false;
      }

      final task = await _taskRemoteDataSource.updateTask(
        projectId: projectId,
        taskId: taskId,
        title: data['title'] as String?,
        description: data['description'] as String?,
        status: data['status'] != null
            ? _parseTaskStatus(data['status'] as String)
            : null,
        priority: data['priority'] != null
            ? _parseTaskPriority(data['priority'] as String)
            : null,
        startDate: data['startDate'] != null
            ? DateTime.parse(data['startDate'] as String)
            : null,
        endDate: data['endDate'] != null
            ? DateTime.parse(data['endDate'] as String)
            : null,
        estimatedHours: data['estimatedHours'] != null
            ? (data['estimatedHours'] as num).toDouble()
            : null,
        assignedUserId: data['assignedUserId'] as int?,
        dependencyIds: (data['dependencyIds'] as List?)?.cast<int>(),
      );
      AppLogger.info('Task actualizada exitosamente: ${task.id}');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Error en _executeUpdateTask', e, stackTrace);
      return false;
    }
  }

  Future<bool> _executeDeleteTask(Map<String, dynamic> data) async {
    try {
      final taskId = data['id'] as int?;
      final projectId = data['projectId'] as int?;

      if (taskId == null || projectId == null) {
        AppLogger.error('ID de task o projectId no encontrado en data');
        return false;
      }

      await _taskRemoteDataSource.deleteTask(projectId, taskId);
      AppLogger.info('Task eliminada exitosamente: $taskId');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Error en _executeDeleteTask', e, stackTrace);
      return false;
    }
  }

  // ========== HELPER METHODS ==========

  WorkspaceType _parseWorkspaceType(String? type) {
    if (type == null) return WorkspaceType.enterprise;

    switch (type.toLowerCase()) {
      case 'personal':
        return WorkspaceType.personal;
      case 'business':
        return WorkspaceType.enterprise;
      case 'educational':
        return WorkspaceType.team;
      default:
        return WorkspaceType.enterprise;
    }
  }

  WorkspaceSettings? _parseWorkspaceSettings(dynamic settings) {
    try {
      if (settings == null) return null;
      if (settings is Map<String, dynamic>) {
        return WorkspaceSettings.fromJson(settings);
      }
      if (settings is String && settings.isNotEmpty) {
        final decoded = jsonDecode(settings);
        if (decoded is Map<String, dynamic>) {
          return WorkspaceSettings.fromJson(decoded);
        }
      }
      return null;
    } catch (e) {
      AppLogger.error('SyncOperationExecutor: Error parseando settings', e);
      return null;
    }
  }

  ProjectStatus _parseProjectStatus(String status) {
    switch (status.toLowerCase()) {
      case 'planning':
        return ProjectStatus.planned;
      case 'active':
        return ProjectStatus.active;
      case 'on_hold':
        return ProjectStatus.paused;
      case 'completed':
        return ProjectStatus.completed;
      case 'cancelled':
        return ProjectStatus.cancelled;
      default:
        return ProjectStatus.planned;
    }
  }

  TaskStatus _parseTaskStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return TaskStatus.planned;
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'completed':
        return TaskStatus.completed;
      case 'blocked':
        return TaskStatus.blocked;
      default:
        return TaskStatus.planned;
    }
  }

  TaskPriority _parseTaskPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return TaskPriority.low;
      case 'medium':
        return TaskPriority.medium;
      case 'high':
        return TaskPriority.high;
      case 'critical':
        return TaskPriority.critical;
      default:
        return TaskPriority.medium;
    }
  }
}
