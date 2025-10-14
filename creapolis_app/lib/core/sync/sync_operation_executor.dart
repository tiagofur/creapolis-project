import 'dart:convert';
import 'package:injectable/injectable.dart';
import '../../data/models/hive/hive_operation_queue.dart';
import '../../domain/repositories/workspace_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/entities/workspace.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/task.dart';
import '../utils/app_logger.dart';

/// Ejecutor de operaciones encoladas
///
/// Toma operaciones de la cola y las ejecuta contra los repositorios
/// apropiados. Soporta 9 tipos de operaciones:
/// - Workspace: create, update, delete
/// - Project: create, update, delete
/// - Task: create, update, delete
@lazySingleton
class SyncOperationExecutor {
  final WorkspaceRepository _workspaceRepository;
  final ProjectRepository _projectRepository;
  final TaskRepository _taskRepository;

  SyncOperationExecutor(
    this._workspaceRepository,
    this._projectRepository,
    this._taskRepository,
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
          throw UnimplementedError(
            'Operación no soportada: ${operation.type}',
          );
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
      final result = await _workspaceRepository.createWorkspace(
        name: data['name'] as String,
        description: data['description'] as String?,
        avatarUrl: data['avatarUrl'] as String?,
        type: _parseWorkspaceType(data['type'] as String?),
        settings: null, // TODO: Parse settings if needed
      );

      return result.fold(
        (failure) {
          AppLogger.error('Falló create_workspace', failure);
          return false;
        },
        (workspace) {
          AppLogger.info('Workspace creado exitosamente: ${workspace.id}');
          return true;
        },
      );
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

      final result = await _workspaceRepository.updateWorkspace(
        workspaceId: workspaceId,
        name: data['name'] as String?,
        description: data['description'] as String?,
        avatarUrl: data['avatarUrl'] as String?,
        type: _parseWorkspaceType(data['type'] as String?),
        settings: null, // TODO: Parse settings if needed
      );

      return result.fold(
        (failure) {
          AppLogger.error('Falló update_workspace', failure);
          return false;
        },
        (workspace) {
          AppLogger.info('Workspace actualizado exitosamente: ${workspace.id}');
          return true;
        },
      );
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

      final result = await _workspaceRepository.deleteWorkspace(workspaceId);

      return result.fold(
        (failure) {
          AppLogger.error('Falló delete_workspace', failure);
          return false;
        },
        (_) {
          AppLogger.info('Workspace eliminado exitosamente: $workspaceId');
          return true;
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error en _executeDeleteWorkspace', e, stackTrace);
      return false;
    }
  }

  // ========== PROJECT OPERATIONS ==========

  Future<bool> _executeCreateProject(Map<String, dynamic> data) async {
    try {
      final result = await _projectRepository.createProject(
        name: data['name'] as String,
        description: data['description'] as String,
        startDate: DateTime.parse(data['startDate'] as String),
        endDate: DateTime.parse(data['endDate'] as String),
        status: _parseProjectStatus(data['status'] as String),
        managerId: data['managerId'] as int?,
        workspaceId: data['workspaceId'] as int,
      );

      return result.fold(
        (failure) {
          AppLogger.error('Falló create_project', failure);
          return false;
        },
        (project) {
          AppLogger.info('Project creado exitosamente: ${project.id}');
          return true;
        },
      );
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

      final result = await _projectRepository.updateProject(
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

      return result.fold(
        (failure) {
          AppLogger.error('Falló update_project', failure);
          return false;
        },
        (project) {
          AppLogger.info('Project actualizado exitosamente: ${project.id}');
          return true;
        },
      );
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

      final result = await _projectRepository.deleteProject(projectId);

      return result.fold(
        (failure) {
          AppLogger.error('Falló delete_project', failure);
          return false;
        },
        (_) {
          AppLogger.info('Project eliminado exitosamente: $projectId');
          return true;
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error en _executeDeleteProject', e, stackTrace);
      return false;
    }
  }

  // ========== TASK OPERATIONS ==========

  Future<bool> _executeCreateTask(Map<String, dynamic> data) async {
    try {
      final result = await _taskRepository.createTask(
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

      return result.fold(
        (failure) {
          AppLogger.error('Falló create_task', failure);
          return false;
        },
        (task) {
          AppLogger.info('Task creada exitosamente: ${task.id}');
          return true;
        },
      );
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

      final result = await _taskRepository.updateTask(
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

      return result.fold(
        (failure) {
          AppLogger.error('Falló update_task', failure);
          return false;
        },
        (task) {
          AppLogger.info('Task actualizada exitosamente: ${task.id}');
          return true;
        },
      );
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

      final result = await _taskRepository.deleteTask(projectId, taskId);

      return result.fold(
        (failure) {
          AppLogger.error('Falló delete_task', failure);
          return false;
        },
        (_) {
          AppLogger.info('Task eliminada exitosamente: $taskId');
          return true;
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error en _executeDeleteTask', e, stackTrace);
      return false;
    }
  }

  // ========== HELPER METHODS ==========

  WorkspaceType _parseWorkspaceType(String? type) {
    if (type == null) return WorkspaceType.business;
    
    switch (type.toLowerCase()) {
      case 'personal':
        return WorkspaceType.personal;
      case 'business':
        return WorkspaceType.business;
      case 'educational':
        return WorkspaceType.educational;
      default:
        return WorkspaceType.business;
    }
  }

  ProjectStatus _parseProjectStatus(String status) {
    switch (status.toLowerCase()) {
      case 'planning':
        return ProjectStatus.planning;
      case 'active':
        return ProjectStatus.active;
      case 'on_hold':
        return ProjectStatus.onHold;
      case 'completed':
        return ProjectStatus.completed;
      case 'cancelled':
        return ProjectStatus.cancelled;
      default:
        return ProjectStatus.planning;
    }
  }

  TaskStatus _parseTaskStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return TaskStatus.pending;
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'completed':
        return TaskStatus.completed;
      case 'blocked':
        return TaskStatus.blocked;
      default:
        return TaskStatus.pending;
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
