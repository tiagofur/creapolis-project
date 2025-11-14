import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../entities/workspace_member.dart';
import '../../repositories/workspace_repository.dart';
import '../../../features/workspace/data/models/workspace_model.dart';

class UpdateMemberRoleParams {
  final int workspaceId;
  final int userId;
  final WorkspaceRole newRole;

  UpdateMemberRoleParams({
    required this.workspaceId,
    required this.userId,
    required this.newRole,
  });
}

@injectable
class UpdateMemberRoleUseCase {
  final WorkspaceRepository _repository;

  UpdateMemberRoleUseCase(this._repository);

  Future<Either<Failure, WorkspaceMember>> call(
    UpdateMemberRoleParams params,
  ) async {
    return _repository.updateMemberRole(
      workspaceId: params.workspaceId,
      userId: params.userId,
      role: params.newRole,
    );
  }
}

