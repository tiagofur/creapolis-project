import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/gamification.dart';
import '../../repositories/gamification_repository.dart';

@injectable
class GetGamificationStatsUseCase {
  final GamificationRepository repository;

  GetGamificationStatsUseCase(this.repository);

  Future<Either<Failure, GamificationStats>> call() async {
    return await repository.getMyStats();
  }
}
