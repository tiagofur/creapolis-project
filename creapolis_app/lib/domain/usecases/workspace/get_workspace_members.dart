import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../entities/workspace_member.dart';
import '../../repositories/workspace_repository.dart';

/// Parámetros para obtener miembros
class GetWorkspaceMembersParams extends Equatable {
  final int workspaceId;

  const GetWorkspaceMembersParams({required this.workspaceId});

  @override
  List<Object?> get props => [workspaceId];
}

/// Caso de uso para obtener miembros de un workspace
@injectable
class GetWorkspaceMembersUseCase {
  final WorkspaceRepository _repository;

  GetWorkspaceMembersUseCase(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, List<WorkspaceMember>>> call(
    GetWorkspaceMembersParams params,
  ) async {
    return await _repository.getWorkspaceMembers(params.workspaceId);
  }
}
