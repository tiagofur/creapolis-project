import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

/// Use case para crear un nuevo proyecto
@injectable
class CreateProjectUseCase {
  final ProjectRepository repository;

  CreateProjectUseCase(this.repository);

  /// Ejecutar el caso de uso
  ///
  /// Retorna `Right(Project)` con el proyecto creado.
  /// Retorna `Left(Failure)` si hay error de validación o servidor.
  Future<Either<Failure, Project>> call(CreateProjectParams params) async {
    // Validaciones de negocio
    if (params.name.trim().isEmpty) {
      return const Left(
        ValidationFailure('El nombre del proyecto es requerido'),
      );
    }

    if (params.name.length < 3) {
      return const Left(
        ValidationFailure('El nombre debe tener al menos 3 caracteres'),
      );
    }

    if (params.description.trim().isEmpty) {
      return const Left(
        ValidationFailure('La descripción del proyecto es requerida'),
      );
    }

    if (params.endDate.isBefore(params.startDate)) {
      return const Left(
        ValidationFailure(
          'La fecha de fin debe ser posterior a la fecha de inicio',
        ),
      );
    }

    return await repository.createProject(
      name: params.name,
      description: params.description,
      startDate: params.startDate,
      endDate: params.endDate,
      status: params.status,
      managerId: params.managerId,
    );
  }
}

/// Parámetros para crear un proyecto
class CreateProjectParams extends Equatable {
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final ProjectStatus status;
  final int? managerId;

  const CreateProjectParams({
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.managerId,
  });

  @override
  List<Object?> get props => [
    name,
    description,
    startDate,
    endDate,
    status,
    managerId,
  ];
}
