import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/portfolio_stats.dart';
import '../repositories/project_repository.dart';

@lazySingleton
class GetPortfolioStatsUseCase {
  final ProjectRepository _repository;

  GetPortfolioStatsUseCase(this._repository);

  Future<Either<Failure, PortfolioStats>> call(int workspaceId) async {
    return await _repository.getPortfolioStats(workspaceId);
  }
}
