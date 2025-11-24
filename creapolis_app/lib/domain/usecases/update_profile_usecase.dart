import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class UpdateProfileUseCase {
  final AuthRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<Either<Failure, User>> call(UpdateProfileParams params) async {
    return await _repository.updateProfile(
      name: params.name,
      avatarUrl: params.avatarUrl,
    );
  }
}

class UpdateProfileParams {
  final String? name;
  final String? avatarUrl;

  UpdateProfileParams({this.name, this.avatarUrl});
}
