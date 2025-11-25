import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/workspace_repository.dart';

class RemoveMemberParams extends Equatable {
  final int workspaceId;
  final int userId;

  const RemoveMemberParams({required this.workspaceId, required this.userId});

  @override
  List<Object?> get props => [workspaceId, userId];
}

@injectable
class RemoveMemberUseCase {
  final WorkspaceRepository _repository;

  RemoveMemberUseCase(this._repository);

  Future<Either<Failure, void>> call(RemoveMemberParams params) async {
    return _repository.removeMember(
      workspaceId: params.workspaceId,
      userId: params.userId,
    );
  }
}
