import '../../domain/entities/project.dart';

/// Modelo de datos para Project
///
/// Extiende la entidad Project y agrega funcionalidades de serialización.
class ProjectModel extends Project {
  const ProjectModel({
    required super.id,
    required super.name,
    required super.description,
    required super.startDate,
    required super.endDate,
    required super.status,
    super.managerId,
    super.managerName,
    required super.workspaceId,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Crear ProjectModel desde JSON
  ///
  /// Usado para deserializar respuestas de la API.
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();

    final id = _readInt(json['id']);
    final name = _readString(json['name']);

    if (id == null || name == null) {
      throw const FormatException('ProjectModel requiere id y name válidos');
    }

    final managerInfo = _extractManager(json);
    final startDate = _parseDate(json['startDate']) ?? now;
    final endDate =
        _parseDate(json['endDate']) ??
        (startDate.isAfter(now) ? startDate : now).add(
          const Duration(days: 30),
        );
    final createdAt = _parseDate(json['createdAt']) ?? now;
    final updatedAt = _parseDate(json['updatedAt']) ?? createdAt;
    final workspace = json['workspace'];
    final workspaceId =
        _readInt(json['workspaceId']) ??
        (workspace is Map<String, dynamic>
            ? _readInt(workspace['id'])
            : null) ??
        1;

    return ProjectModel(
      id: id,
      name: name,
      description: _readString(json['description']) ?? '',
      startDate: startDate,
      endDate: endDate,
      status: _parseStatus(json['status']),
      managerId: _readInt(json['managerId']) ?? managerInfo?.$1,
      managerName: _readString(json['managerName']) ?? managerInfo?.$2,
      workspaceId: workspaceId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convertir ProjectModel a JSON
  ///
  /// Usado para serializar datos para enviar a la API.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': _statusToString(status),
      if (managerId != null) 'managerId': managerId,
      if (managerName != null) 'managerName': managerName,
      'workspaceId': workspaceId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Crear ProjectModel desde una entidad Project
  factory ProjectModel.fromEntity(Project project) {
    return ProjectModel(
      id: project.id,
      name: project.name,
      description: project.description,
      startDate: project.startDate,
      endDate: project.endDate,
      status: project.status,
      managerId: project.managerId,
      managerName: project.managerName,
      workspaceId: project.workspaceId,
      createdAt: project.createdAt,
      updatedAt: project.updatedAt,
    );
  }

  /// Convertir string a ProjectStatus
  static ProjectStatus _statusFromString(String status) {
    switch (status.toUpperCase()) {
      case 'PLANNED':
        return ProjectStatus.planned;
      case 'ACTIVE':
        return ProjectStatus.active;
      case 'PAUSED':
        return ProjectStatus.paused;
      case 'COMPLETED':
        return ProjectStatus.completed;
      case 'CANCELLED':
        return ProjectStatus.cancelled;
      default:
        return ProjectStatus.planned;
    }
  }

  /// Convertir ProjectStatus a string
  static String _statusToString(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planned:
        return 'PLANNED';
      case ProjectStatus.active:
        return 'ACTIVE';
      case ProjectStatus.paused:
        return 'PAUSED';
      case ProjectStatus.completed:
        return 'COMPLETED';
      case ProjectStatus.cancelled:
        return 'CANCELLED';
    }
  }

  /// Copiar con nuevos valores
  @override
  ProjectModel copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    ProjectStatus? status,
    int? managerId,
    String? managerName,
    int? workspaceId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      managerId: managerId ?? this.managerId,
      managerName: managerName ?? this.managerName,
      workspaceId: workspaceId ?? this.workspaceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static (int?, String?)? _extractManager(Map<String, dynamic> json) {
    final manager = json['manager'] ?? json['owner'];

    if (manager is Map<String, dynamic>) {
      return (_readInt(manager['id']), _readString(manager['name']));
    }

    final members = json['members'];
    if (members is List) {
      for (final member in members) {
        if (member is Map<String, dynamic>) {
          final role = _readString(member['role'] ?? member['memberRole']);
          final isManager =
              (member['isManager'] as bool?) ??
              (role != null && role.toUpperCase().contains('MANAGER'));

          if (isManager) {
            final user = member['user'] as Map<String, dynamic>?;
            return (
              _readInt(member['userId']) ?? _readInt(user?['id']),
              _readString(member['name']) ?? _readString(user?['name']),
            );
          }
        }
      }

      if (members.isNotEmpty) {
        final first = members.first;
        if (first is Map<String, dynamic>) {
          final user = first['user'] as Map<String, dynamic>?;
          return (
            _readInt(first['userId']) ?? _readInt(user?['id']),
            _readString(first['name']) ?? _readString(user?['name']),
          );
        }
      }
    }

    return null;
  }

  static ProjectStatus _parseStatus(dynamic value) {
    if (value is ProjectStatus) {
      return value;
    }

    if (value is String && value.isNotEmpty) {
      return _statusFromString(value);
    }

    if (value is Map<String, dynamic>) {
      for (final key in ['value', 'code', 'status', 'name', 'label']) {
        final nested = value[key];
        if (nested is String && nested.isNotEmpty) {
          return _statusFromString(nested);
        }
      }
    }

    return ProjectStatus.planned;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true).toLocal();
    }

    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(
        (value * 1000).round(),
        isUtc: true,
      ).toLocal();
    }

    if (value is Map<String, dynamic>) {
      for (final key in ['iso', 'isoString', 'value', 'date', 'timestamp']) {
        final nested = value[key];
        final parsed = _parseDate(nested);
        if (parsed != null) {
          return parsed;
        }
      }

      final seconds = value['seconds'];
      final nanoseconds = value['nanoseconds'];

      if (seconds is num) {
        final baseMs = seconds * 1000;
        final extraMs = nanoseconds is num ? nanoseconds / 1e6 : 0;
        return DateTime.fromMillisecondsSinceEpoch(
          (baseMs + extraMs).round(),
          isUtc: true,
        ).toLocal();
      }
    }

    return null;
  }

  static int? _readInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value);
    }

    if (value is Map<String, dynamic>) {
      for (final key in ['id', 'value', 'count']) {
        final nested = value[key];
        final parsed = _readInt(nested);
        if (parsed != null) {
          return parsed;
        }
      }
    }

    return null;
  }

  static String? _readString(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is String) {
      return value;
    }

    if (value is num || value is bool) {
      return value.toString();
    }

    if (value is Map<String, dynamic>) {
      for (final key in [
        'value',
        'name',
        'label',
        'text',
        'title',
        'description',
      ]) {
        final nested = value[key];
        final parsed = _readString(nested);
        if (parsed != null && parsed.isNotEmpty) {
          return parsed;
        }
      }
    }

    return null;
  }
}
