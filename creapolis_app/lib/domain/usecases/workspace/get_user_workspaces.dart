import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../entities/workspace.dart';
import '../../repositories/workspace_repository.dart';

/// Caso de uso para obtener todos los workspaces del usuario
@injectable
class GetUserWorkspacesUseCase {
  final WorkspaceRepository _repository;

  GetUserWorkspacesUseCase(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, List<Workspace>>> call() async {
    return await _repository.getUserWorkspaces();
  }
}
