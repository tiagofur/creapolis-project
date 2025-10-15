import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../entities/workspace.dart';
import '../../repositories/workspace_repository.dart';

/// Parámetros para aceptar invitación
class AcceptInvitationParams {
  final String token;

  AcceptInvitationParams({required this.token});
}

/// Caso de uso para aceptar una invitación
@injectable
class AcceptInvitationUseCase {
  final WorkspaceRepository _repository;

  AcceptInvitationUseCase(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, Workspace>> call(AcceptInvitationParams params) async {
    return await _repository.acceptInvitation(params.token);
  }
}



