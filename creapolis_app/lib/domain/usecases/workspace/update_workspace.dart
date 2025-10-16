import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../../features/workspace/data/models/workspace_model.dart';
import '../../repositories/workspace_repository.dart';

/// Parámetros para actualizar un workspace existente
class UpdateWorkspaceParams {
  final int workspaceId;
  final String? name;
  final String? description;
  final String? avatarUrl;
  final WorkspaceType? type;
  final WorkspaceSettings? settings;

  const UpdateWorkspaceParams({
    required this.workspaceId,
    this.name,
    this.description,
    this.avatarUrl,
    this.type,
    this.settings,
  });
}

/// Caso de uso para actualizar un workspace
@injectable
class UpdateWorkspaceUseCase {
  final WorkspaceRepository _repository;

  const UpdateWorkspaceUseCase(this._repository);

  Future<Either<Failure, Workspace>> call(UpdateWorkspaceParams params) async {
    return _repository.updateWorkspace(
      workspaceId: params.workspaceId,
      name: params.name,
      description: params.description,
      avatarUrl: params.avatarUrl,
      type: params.type,
      settings: params.settings,
    );
  }
}
