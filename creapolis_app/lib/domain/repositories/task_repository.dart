import 'package:dartz/dartz.dart' hide Task;

import '../../core/errors/failures.dart';
import '../entities/task.dart';

/// Repositorio de tareas
abstract class TaskRepository {
  /// Obtener todas las tareas de un proyecto
  Future<Either<Failure, List<Task>>> getTasksByProject(int projectId);

  /// Obtener una tarea por ID
  Future<Either<Failure, Task>> getTaskById(int projectId, int taskId);

  /// Crear una nueva tarea
  Future<Either<Failure, Task>> createTask({
    required String title,
    required String description,
    required TaskStatus status,
    required TaskPriority priority,
    required DateTime startDate,
    required DateTime endDate,
    required double estimatedHours,
    required int projectId,
    int? assignedUserId,
    List<int>? dependencyIds,
  });

  /// Actualizar una tarea existente
  Future<Either<Failure, Task>> updateTask({
    required int projectId,
    required int taskId,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? startDate,
    DateTime? endDate,
    double? estimatedHours,
    double? actualHours,
    int? assignedUserId,
    List<int>? dependencyIds,
  });

  /// Eliminar una tarea
  Future<Either<Failure, void>> deleteTask(int projectId, int taskId);

  /// Obtener dependencias de una tarea
  Future<Either<Failure, List<TaskDependency>>> getTaskDependencies(
    int projectId,
    int taskId,
  );

  /// Crear dependencia entre tareas
  Future<Either<Failure, TaskDependency>> createDependency({
    required int projectId,
    required int taskId,
    required int predecessorId,
    required String type,
  });

  /// Eliminar dependencia
  Future<Either<Failure, void>> deleteDependency({
    required int projectId,
    required int taskId,
    required int predecessorId,
  });

  /// Calcular cronograma inicial del proyecto
  Future<Either<Failure, List<Task>>> calculateSchedule(int projectId);

  /// Replanificar proyecto desde una tarea específica
  Future<Either<Failure, List<Task>>> rescheduleProject(
    int projectId,
    int triggerTaskId,
  );
}
