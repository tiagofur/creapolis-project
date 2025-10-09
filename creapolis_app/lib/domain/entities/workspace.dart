import 'package:equatable/equatable.dart';

/// Tipos de workspace
enum WorkspaceType {
  personal('PERSONAL', 'Personal'),
  team('TEAM', 'Equipo'),
  enterprise('ENTERPRISE', 'Empresa');

  const WorkspaceType(this.value, this.displayName);

  final String value;
  final String displayName;

  static WorkspaceType fromString(String value) {
    return WorkspaceType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => WorkspaceType.team,
    );
  }
}

/// Roles en workspace
enum WorkspaceRole {
  owner('OWNER', 'Propietario'),
  admin('ADMIN', 'Administrador'),
  member('MEMBER', 'Miembro'),
  guest('GUEST', 'Invitado');

  const WorkspaceRole(this.value, this.displayName);

  final String value;
  final String displayName;

  static WorkspaceRole fromString(String value) {
    return WorkspaceRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => WorkspaceRole.member,
    );
  }

  // Permisos
  bool get canManageMembers => this == owner || this == admin;
  bool get canCreateProjects => this != guest;
  bool get canDeleteWorkspace => this == owner;
  bool get canManageSettings => this == owner || this == admin;
  bool get canInviteMembers => this != guest;
  bool get canRemoveMembers => this == owner || this == admin;
  bool get canChangeRoles => this == owner || this == admin;
}

/// Configuración de workspace
class WorkspaceSettings extends Equatable {
  final bool allowGuestInvites;
  final bool requireEmailVerification;
  final bool autoAssignNewMembers;
  final String? defaultProjectTemplate;
  final String timezone;
  final String language;

  const WorkspaceSettings({
    this.allowGuestInvites = true,
    this.requireEmailVerification = true,
    this.autoAssignNewMembers = false,
    this.defaultProjectTemplate,
    this.timezone = 'UTC',
    this.language = 'es',
  });

  WorkspaceSettings copyWith({
    bool? allowGuestInvites,
    bool? requireEmailVerification,
    bool? autoAssignNewMembers,
    String? defaultProjectTemplate,
    String? timezone,
    String? language,
  }) {
    return WorkspaceSettings(
      allowGuestInvites: allowGuestInvites ?? this.allowGuestInvites,
      requireEmailVerification:
          requireEmailVerification ?? this.requireEmailVerification,
      autoAssignNewMembers: autoAssignNewMembers ?? this.autoAssignNewMembers,
      defaultProjectTemplate:
          defaultProjectTemplate ?? this.defaultProjectTemplate,
      timezone: timezone ?? this.timezone,
      language: language ?? this.language,
    );
  }

  @override
  List<Object?> get props => [
    allowGuestInvites,
    requireEmailVerification,
    autoAssignNewMembers,
    defaultProjectTemplate,
    timezone,
    language,
  ];
}

/// Usuario propietario del workspace (simplificado)
class WorkspaceOwner extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? avatarUrl;

  const WorkspaceOwner({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, name, email, avatarUrl];
}

/// Entidad Workspace
class Workspace extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String? avatarUrl;
  final WorkspaceType type;
  final int ownerId;
  final WorkspaceOwner? owner;
  final WorkspaceRole userRole;
  final int memberCount;
  final int projectCount;
  final WorkspaceSettings settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Workspace({
    required this.id,
    required this.name,
    this.description,
    this.avatarUrl,
    required this.type,
    required this.ownerId,
    this.owner,
    required this.userRole,
    this.memberCount = 0,
    this.projectCount = 0,
    required this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Obtener iniciales para avatar
  String get initials {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  /// Verificar si el usuario es owner
  bool get isOwner => userRole == WorkspaceRole.owner;

  /// Verificar si el usuario es admin o owner
  bool get isAdminOrOwner =>
      userRole == WorkspaceRole.owner || userRole == WorkspaceRole.admin;

  /// Verificar si el usuario puede gestionar miembros
  bool get canManageMembers => userRole.canManageMembers;

  /// Verificar si el usuario puede gestionar configuración
  bool get canManageSettings => userRole.canManageSettings;

  Workspace copyWith({
    int? id,
    String? name,
    String? description,
    String? avatarUrl,
    WorkspaceType? type,
    int? ownerId,
    WorkspaceOwner? owner,
    WorkspaceRole? userRole,
    int? memberCount,
    int? projectCount,
    WorkspaceSettings? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Workspace(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      type: type ?? this.type,
      ownerId: ownerId ?? this.ownerId,
      owner: owner ?? this.owner,
      userRole: userRole ?? this.userRole,
      memberCount: memberCount ?? this.memberCount,
      projectCount: projectCount ?? this.projectCount,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    avatarUrl,
    type,
    ownerId,
    owner,
    userRole,
    memberCount,
    projectCount,
    settings,
    createdAt,
    updatedAt,
  ];
}
