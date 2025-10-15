import 'package:equatable/equatable.dart';

/// Entidad ProjectRole - Rol a nivel de proyecto
class ProjectRole extends Equatable {
  final int id;
  final int projectId;
  final String name;
  final String? description;
  final bool isDefault;
  final List<ProjectPermission> permissions;
  final int memberCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProjectRole({
    required this.id,
    required this.projectId,
    required this.name,
    this.description,
    this.isDefault = false,
    this.permissions = const [],
    this.memberCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectRole.fromJson(Map<String, dynamic> json) {
    return ProjectRole(
      id: json['id'] as int,
      projectId: json['projectId'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((e) => ProjectPermission.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      memberCount: json['_count']?['members'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'name': name,
      if (description != null) 'description': description,
      'isDefault': isDefault,
      'permissions': permissions.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ProjectRole copyWith({
    int? id,
    int? projectId,
    String? name,
    String? description,
    bool? isDefault,
    List<ProjectPermission>? permissions,
    int? memberCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectRole(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      description: description ?? this.description,
      isDefault: isDefault ?? this.isDefault,
      permissions: permissions ?? this.permissions,
      memberCount: memberCount ?? this.memberCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        name,
        description,
        isDefault,
        permissions,
        memberCount,
        createdAt,
        updatedAt,
      ];
}

/// Entidad ProjectPermission - Permiso granular
class ProjectPermission extends Equatable {
  final int id;
  final int roleId;
  final String resource;
  final String action;
  final bool granted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProjectPermission({
    required this.id,
    required this.roleId,
    required this.resource,
    required this.action,
    this.granted = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectPermission.fromJson(Map<String, dynamic> json) {
    return ProjectPermission(
      id: json['id'] as int,
      roleId: json['roleId'] as int,
      resource: json['resource'] as String,
      action: json['action'] as String,
      granted: json['granted'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roleId': roleId,
      'resource': resource,
      'action': action,
      'granted': granted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Para crear un nuevo permiso (sin id)
  Map<String, dynamic> toCreateJson() {
    return {
      'resource': resource,
      'action': action,
      'granted': granted,
    };
  }

  ProjectPermission copyWith({
    int? id,
    int? roleId,
    String? resource,
    String? action,
    bool? granted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectPermission(
      id: id ?? this.id,
      roleId: roleId ?? this.roleId,
      resource: resource ?? this.resource,
      action: action ?? this.action,
      granted: granted ?? this.granted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        roleId,
        resource,
        action,
        granted,
        createdAt,
        updatedAt,
      ];
}

/// Recursos disponibles para permisos
class PermissionResource {
  static const String tasks = 'tasks';
  static const String projects = 'projects';
  static const String members = 'members';
  static const String settings = 'settings';
  static const String reports = 'reports';
  static const String comments = 'comments';
  static const String timeTracking = 'timeTracking';
  static const String roles = 'roles';

  static const List<String> all = [
    tasks,
    projects,
    members,
    settings,
    reports,
    comments,
    timeTracking,
    roles,
  ];

  static String getDisplayName(String resource) {
    switch (resource) {
      case tasks:
        return 'Tareas';
      case projects:
        return 'Proyectos';
      case members:
        return 'Miembros';
      case settings:
        return 'Configuración';
      case reports:
        return 'Reportes';
      case comments:
        return 'Comentarios';
      case timeTracking:
        return 'Time Tracking';
      case roles:
        return 'Roles';
      default:
        return resource;
    }
  }
}

/// Acciones disponibles para permisos
class PermissionAction {
  static const String create = 'create';
  static const String read = 'read';
  static const String update = 'update';
  static const String delete = 'delete';
  static const String assign = 'assign';
  static const String manage = 'manage';

  static const List<String> all = [
    create,
    read,
    update,
    delete,
    assign,
    manage,
  ];

  static String getDisplayName(String action) {
    switch (action) {
      case create:
        return 'Crear';
      case read:
        return 'Ver';
      case update:
        return 'Editar';
      case delete:
        return 'Eliminar';
      case assign:
        return 'Asignar';
      case manage:
        return 'Gestionar';
      default:
        return action;
    }
  }
}

/// Entidad RoleAuditLog - Log de auditoría
class RoleAuditLog extends Equatable {
  final int id;
  final int roleId;
  final int userId;
  final String action;
  final String? details;
  final DateTime createdAt;
  final String? userName;
  final String? userEmail;

  const RoleAuditLog({
    required this.id,
    required this.roleId,
    required this.userId,
    required this.action,
    this.details,
    required this.createdAt,
    this.userName,
    this.userEmail,
  });

  factory RoleAuditLog.fromJson(Map<String, dynamic> json) {
    return RoleAuditLog(
      id: json['id'] as int,
      roleId: json['roleId'] as int,
      userId: json['userId'] as int,
      action: json['action'] as String,
      details: json['details'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userName: json['user']?['name'] as String?,
      userEmail: json['user']?['email'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        roleId,
        userId,
        action,
        details,
        createdAt,
        userName,
        userEmail,
      ];
}

/// Enum para acciones de auditoría
enum AuditAction {
  roleCreated,
  roleUpdated,
  roleDeleted,
  permissionGranted,
  permissionRevoked,
  memberAssigned,
  memberRemoved;

  String get displayName {
    switch (this) {
      case AuditAction.roleCreated:
        return 'Rol creado';
      case AuditAction.roleUpdated:
        return 'Rol actualizado';
      case AuditAction.roleDeleted:
        return 'Rol eliminado';
      case AuditAction.permissionGranted:
        return 'Permisos otorgados';
      case AuditAction.permissionRevoked:
        return 'Permisos revocados';
      case AuditAction.memberAssigned:
        return 'Miembro asignado';
      case AuditAction.memberRemoved:
        return 'Miembro removido';
    }
  }

  static AuditAction fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ROLE_CREATED':
        return AuditAction.roleCreated;
      case 'ROLE_UPDATED':
        return AuditAction.roleUpdated;
      case 'ROLE_DELETED':
        return AuditAction.roleDeleted;
      case 'PERMISSION_GRANTED':
        return AuditAction.permissionGranted;
      case 'PERMISSION_REVOKED':
        return AuditAction.permissionRevoked;
      case 'MEMBER_ASSIGNED':
        return AuditAction.memberAssigned;
      case 'MEMBER_REMOVED':
        return AuditAction.memberRemoved;
      default:
        return AuditAction.roleUpdated;
    }
  }
}



