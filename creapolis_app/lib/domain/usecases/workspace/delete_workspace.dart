import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/workspace_repository.dart';

/// Caso de uso para eliminar un workspace
@injectable
class DeleteWorkspaceUseCase {
  final WorkspaceRepository _repository;

  const DeleteWorkspaceUseCase(this._repository);

  Future<Either<Failure, void>> call(int workspaceId) {
    return _repository.deleteWorkspace(workspaceId);
  }
}
