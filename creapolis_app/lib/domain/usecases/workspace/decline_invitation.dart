import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/workspace_repository.dart';

/// Parámetros para rechazar una invitación a workspace
class DeclineInvitationParams {
  final String token;

  const DeclineInvitationParams({required this.token});
}

/// Caso de uso para rechazar una invitación a workspace
@injectable
class DeclineInvitationUseCase {
  final WorkspaceRepository _repository;

  DeclineInvitationUseCase(this._repository);

  Future<Either<Failure, void>> call(DeclineInvitationParams params) async {
    return _repository.declineInvitation(params.token);
  }
}
