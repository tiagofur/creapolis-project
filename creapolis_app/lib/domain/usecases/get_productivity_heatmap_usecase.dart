import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/productivity_heatmap.dart';
import '../repositories/time_log_repository.dart';

class GetProductivityHeatmapParams {
  final DateTime? startDate;
  final DateTime? endDate;
  final int? projectId;
  final bool teamView;
  final int? workspaceId;

  GetProductivityHeatmapParams({
    this.startDate,
    this.endDate,
    this.projectId,
    this.teamView = false,
    this.workspaceId,
  });
}

@lazySingleton
class GetProductivityHeatmapUseCase {
  final TimeLogRepository _repository;

  GetProductivityHeatmapUseCase(this._repository);

  Future<Either<Failure, ProductivityHeatmap>> call(
    GetProductivityHeatmapParams params,
  ) async {
    return await _repository.getProductivityHeatmap(
      startDate: params.startDate,
      endDate: params.endDate,
      projectId: params.projectId,
      teamView: params.teamView,
      workspaceId: params.workspaceId,
    );
  }
}
