import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

/// Use case para actualizar un proyecto existente
@injectable
class UpdateProjectUseCase {
  final ProjectRepository repository;

  UpdateProjectUseCase(this.repository);

  /// Ejecutar el caso de uso
  ///
  /// Retorna `Right(Project)` con el proyecto actualizado.
  /// Retorna `Left(Failure)` si hay error.
  Future<Either<Failure, Project>> call(UpdateProjectParams params) async {
    // Validaciones de negocio si se proporcionan valores
    if (params.name != null && params.name!.trim().isEmpty) {
      return const Left(ValidationFailure('El nombre no puede estar vacío'));
    }

    if (params.name != null && params.name!.length < 3) {
      return const Left(
        ValidationFailure('El nombre debe tener al menos 3 caracteres'),
      );
    }

    if (params.description != null && params.description!.trim().isEmpty) {
      return const Left(
        ValidationFailure('La descripción no puede estar vacía'),
      );
    }

    if (params.startDate != null &&
        params.endDate != null &&
        params.endDate!.isBefore(params.startDate!)) {
      return const Left(
        ValidationFailure(
          'La fecha de fin debe ser posterior a la fecha de inicio',
        ),
      );
    }

    return await repository.updateProject(
      id: params.id,
      name: params.name,
      description: params.description,
      startDate: params.startDate,
      endDate: params.endDate,
      status: params.status,
      managerId: params.managerId,
    );
  }
}

/// Parámetros para actualizar un proyecto
class UpdateProjectParams extends Equatable {
  final int id;
  final String? name;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final ProjectStatus? status;
  final int? managerId;

  const UpdateProjectParams({
    required this.id,
    this.name,
    this.description,
    this.startDate,
    this.endDate,
    this.status,
    this.managerId,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    startDate,
    endDate,
    status,
    managerId,
  ];
}
