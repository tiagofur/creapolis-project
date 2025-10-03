import 'package:dartz/dartz.dart' hide Task;
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Use case para crear una tarea
@injectable
class CreateTaskUseCase {
  final TaskRepository _repository;

  CreateTaskUseCase(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, Task>> call(CreateTaskParams params) async {
    // Validaciones de negocio
    if (params.title.trim().isEmpty) {
      return const Left(ValidationFailure('El título no puede estar vacío'));
    }

    if (params.title.length < 3) {
      return const Left(
        ValidationFailure('El título debe tener al menos 3 caracteres'),
      );
    }

    if (params.description.trim().isEmpty) {
      return const Left(
        ValidationFailure('La descripción no puede estar vacía'),
      );
    }

    if (params.endDate.isBefore(params.startDate)) {
      return const Left(
        ValidationFailure(
          'La fecha de fin debe ser posterior a la fecha de inicio',
        ),
      );
    }

    if (params.estimatedHours <= 0) {
      return const Left(
        ValidationFailure('Las horas estimadas deben ser mayores a 0'),
      );
    }

    return await _repository.createTask(
      title: params.title,
      description: params.description,
      status: params.status,
      priority: params.priority,
      startDate: params.startDate,
      endDate: params.endDate,
      estimatedHours: params.estimatedHours,
      projectId: params.projectId,
      assignedUserId: params.assignedUserId,
      dependencyIds: params.dependencyIds,
    );
  }
}

/// Parámetros para crear una tarea
class CreateTaskParams extends Equatable {
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime startDate;
  final DateTime endDate;
  final double estimatedHours;
  final int projectId;
  final int? assignedUserId;
  final List<int>? dependencyIds;

  const CreateTaskParams({
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.startDate,
    required this.endDate,
    required this.estimatedHours,
    required this.projectId,
    this.assignedUserId,
    this.dependencyIds,
  });

  @override
  List<Object?> get props => [
    title,
    description,
    status,
    priority,
    startDate,
    endDate,
    estimatedHours,
    projectId,
    assignedUserId,
    dependencyIds,
  ];
}
