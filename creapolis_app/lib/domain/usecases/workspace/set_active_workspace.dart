import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/workspace_repository.dart';

/// Caso de uso para establecer workspace activo
@injectable
class SetActiveWorkspaceUseCase {
  final WorkspaceRepository _repository;

  SetActiveWorkspaceUseCase(this._repository);

  /// Establecer workspace activo
  Future<Either<Failure, void>> call(int workspaceId) async {
    return await _repository.saveActiveWorkspace(workspaceId);
  }
}



