import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/workspace_repository.dart';

/// Caso de uso para obtener workspace activo
@injectable
class GetActiveWorkspaceUseCase {
  final WorkspaceRepository _repository;

  GetActiveWorkspaceUseCase(this._repository);

  /// Obtener ID del workspace activo
  Future<Either<Failure, int?>> call() async {
    return await _repository.getActiveWorkspaceId();
  }
}



