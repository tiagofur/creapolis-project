import 'package:dartz/dartz.dart' hide Task;
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Use case para actualizar una tarea
@injectable
class UpdateTaskUseCase {
  final TaskRepository _repository;

  UpdateTaskUseCase(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, Task>> call(UpdateTaskParams params) async {
    // Validaciones de negocio solo para campos que se actualizan
    if (params.title != null) {
      if (params.title!.trim().isEmpty) {
        return const Left(ValidationFailure('El título no puede estar vacío'));
      }
      if (params.title!.length < 3) {
        return const Left(
          ValidationFailure('El título debe tener al menos 3 caracteres'),
        );
      }
    }

    if (params.description != null && params.description!.trim().isEmpty) {
      return const Left(
        ValidationFailure('La descripción no puede estar vacía'),
      );
    }

    if (params.startDate != null && params.endDate != null) {
      if (params.endDate!.isBefore(params.startDate!)) {
        return const Left(
          ValidationFailure(
            'La fecha de fin debe ser posterior a la fecha de inicio',
          ),
        );
      }
    }

    if (params.estimatedHours != null && params.estimatedHours! <= 0) {
      return const Left(
        ValidationFailure('Las horas estimadas deben ser mayores a 0'),
      );
    }

    if (params.actualHours != null && params.actualHours! < 0) {
      return const Left(
        ValidationFailure('Las horas actuales no pueden ser negativas'),
      );
    }

    return await _repository.updateTask(
      id: params.id,
      title: params.title,
      description: params.description,
      status: params.status,
      priority: params.priority,
      startDate: params.startDate,
      endDate: params.endDate,
      estimatedHours: params.estimatedHours,
      actualHours: params.actualHours,
      assignedUserId: params.assignedUserId,
      dependencyIds: params.dependencyIds,
    );
  }
}

/// Parámetros para actualizar una tarea
class UpdateTaskParams extends Equatable {
  final int id;
  final String? title;
  final String? description;
  final TaskStatus? status;
  final TaskPriority? priority;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? estimatedHours;
  final double? actualHours;
  final int? assignedUserId;
  final List<int>? dependencyIds;

  const UpdateTaskParams({
    required this.id,
    this.title,
    this.description,
    this.status,
    this.priority,
    this.startDate,
    this.endDate,
    this.estimatedHours,
    this.actualHours,
    this.assignedUserId,
    this.dependencyIds,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    status,
    priority,
    startDate,
    endDate,
    estimatedHours,
    actualHours,
    assignedUserId,
    dependencyIds,
  ];
}
