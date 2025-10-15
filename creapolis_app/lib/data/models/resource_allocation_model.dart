import '../../domain/entities/resource_allocation.dart';
import '../../domain/repositories/workload_repository.dart';

/// Modelo de datos para ResourceAllocation
class ResourceAllocationModel extends ResourceAllocation {
  const ResourceAllocationModel({
    required super.userId,
    required super.userName,
    required super.dailyHours,
    required super.totalHours,
    required super.isOverloaded,
    required super.taskAllocations,
  });

  /// Crea desde JSON
  factory ResourceAllocationModel.fromJson(Map<String, dynamic> json) {
    // Parsear dailyHours: {"2025-10-01": 8.5, "2025-10-02": 6.0}
    final Map<DateTime, double> dailyHours = {};
    if (json['dailyHours'] != null) {
      (json['dailyHours'] as Map<String, dynamic>).forEach((key, value) {
        dailyHours[DateTime.parse(key)] = (value as num).toDouble();
      });
    }

    // Parsear taskAllocations
    final List<TaskAllocation> taskAllocations = [];
    if (json['tasks'] != null) {
      taskAllocations.addAll(
        (json['tasks'] as List)
            .map((task) => TaskAllocationModel.fromJson(task))
            .toList(),
      );
    }

    return ResourceAllocationModel(
      userId: json['userId'] as int,
      userName: json['userName'] as String,
      dailyHours: dailyHours,
      totalHours: (json['totalHours'] as num).toDouble(),
      isOverloaded: json['isOverloaded'] as bool? ?? false,
      taskAllocations: taskAllocations,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    final Map<String, double> dailyHoursJson = {};
    dailyHours.forEach((date, hours) {
      dailyHoursJson[date.toIso8601String().split('T')[0]] = hours;
    });

    return {
      'userId': userId,
      'userName': userName,
      'dailyHours': dailyHoursJson,
      'totalHours': totalHours,
      'isOverloaded': isOverloaded,
      'tasks': taskAllocations
          .map((task) => (task as TaskAllocationModel).toJson())
          .toList(),
    };
  }
}

/// Modelo de datos para TaskAllocation
class TaskAllocationModel extends TaskAllocation {
  const TaskAllocationModel({
    required super.taskId,
    required super.taskTitle,
    required super.startDate,
    required super.endDate,
    required super.estimatedHours,
    required super.status,
  });

  /// Crea desde JSON
  factory TaskAllocationModel.fromJson(Map<String, dynamic> json) {
    return TaskAllocationModel(
      taskId: json['taskId'] as int,
      taskTitle: json['taskTitle'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      estimatedHours: (json['estimatedHours'] as num).toDouble(),
      status: json['status'] as String,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'taskTitle': taskTitle,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'estimatedHours': estimatedHours,
      'status': status,
    };
  }
}

/// Modelo de datos para WorkloadStats
class WorkloadStatsModel {
  final int totalMembers;
  final int overloadedMembers;
  final double averageHoursPerMember;
  final double maxHoursAssigned;
  final double minHoursAssigned;
  final Map<String, int> distributionByLoadLevel;

  const WorkloadStatsModel({
    required this.totalMembers,
    required this.overloadedMembers,
    required this.averageHoursPerMember,
    required this.maxHoursAssigned,
    required this.minHoursAssigned,
    required this.distributionByLoadLevel,
  });

  /// Convierte a entidad de dominio
  WorkloadStats toEntity() {
    return WorkloadStats(
      totalMembers: totalMembers,
      overloadedMembers: overloadedMembers,
      averageHoursPerMember: averageHoursPerMember,
      maxHoursAssigned: maxHoursAssigned,
      minHoursAssigned: minHoursAssigned,
      distributionByLoadLevel: distributionByLoadLevel,
    );
  }

  /// Crea desde JSON
  factory WorkloadStatsModel.fromJson(Map<String, dynamic> json) {
    final Map<String, int> distribution = {};
    if (json['distributionByLoadLevel'] != null) {
      (json['distributionByLoadLevel'] as Map<String, dynamic>).forEach((
        key,
        value,
      ) {
        distribution[key] = value as int;
      });
    }

    return WorkloadStatsModel(
      totalMembers: json['totalMembers'] as int,
      overloadedMembers: json['overloadedMembers'] as int,
      averageHoursPerMember: (json['averageHoursPerMember'] as num).toDouble(),
      maxHoursAssigned: (json['maxHoursAssigned'] as num).toDouble(),
      minHoursAssigned: (json['minHoursAssigned'] as num).toDouble(),
      distributionByLoadLevel: distribution,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'totalMembers': totalMembers,
      'overloadedMembers': overloadedMembers,
      'averageHoursPerMember': averageHoursPerMember,
      'maxHoursAssigned': maxHoursAssigned,
      'minHoursAssigned': minHoursAssigned,
      'distributionByLoadLevel': distributionByLoadLevel,
    };
  }
}



