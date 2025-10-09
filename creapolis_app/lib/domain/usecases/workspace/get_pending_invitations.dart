import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../entities/workspace_invitation.dart';
import '../../repositories/workspace_repository.dart';

/// Caso de uso para obtener invitaciones pendientes del usuario
@injectable
class GetPendingInvitationsUseCase {
  final WorkspaceRepository _repository;

  GetPendingInvitationsUseCase(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, List<WorkspaceInvitation>>> call() async {
    return await _repository.getPendingInvitations();
  }
}
