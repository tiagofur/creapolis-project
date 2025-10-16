import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../../features/workspace/data/models/workspace_model.dart';
import '../../repositories/workspace_repository.dart';

/// Parámetros para crear workspace
class CreateWorkspaceParams {
  final String name;
  final String? description;
  final String? avatarUrl;
  final WorkspaceType type;
  final WorkspaceSettings? settings;

  CreateWorkspaceParams({
    required this.name,
    this.description,
    this.avatarUrl,
    required this.type,
    this.settings,
  });
}

/// Caso de uso para crear un nuevo workspace
@injectable
class CreateWorkspaceUseCase {
  final WorkspaceRepository _repository;

  CreateWorkspaceUseCase(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, Workspace>> call(CreateWorkspaceParams params) async {
    return await _repository.createWorkspace(
      name: params.name,
      description: params.description,
      avatarUrl: params.avatarUrl,
      type: params.type,
      settings: params.settings,
    );
  }
}
