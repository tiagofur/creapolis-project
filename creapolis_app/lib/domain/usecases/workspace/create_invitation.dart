import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../entities/workspace.dart';
import '../../entities/workspace_invitation.dart';
import '../../repositories/workspace_repository.dart';

/// Parámetros para crear invitación
class CreateInvitationParams {
  final int workspaceId;
  final String email;
  final WorkspaceRole role;

  CreateInvitationParams({
    required this.workspaceId,
    required this.email,
    required this.role,
  });
}

/// Caso de uso para crear una invitación
@injectable
class CreateInvitationUseCase {
  final WorkspaceRepository _repository;

  CreateInvitationUseCase(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, WorkspaceInvitation>> call(
    CreateInvitationParams params,
  ) async {
    return await _repository.createInvitation(
      workspaceId: params.workspaceId,
      email: params.email,
      role: params.role,
    );
  }
}



