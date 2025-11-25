import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../../features/workspace/data/models/workspace_model.dart';
import '../../repositories/workspace_repository.dart';

/// Parámetros para aceptar invitación
class AcceptInvitationParams extends Equatable {
  final String token;

  const AcceptInvitationParams({required this.token});

  @override
  List<Object?> get props => [token];
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
