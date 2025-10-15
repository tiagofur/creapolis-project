import 'package:equatable/equatable.dart';

/// Modelo de Workspace
///
/// Representa un espacio de trabajo donde los usuarios pueden
/// colaborar en proyectos y tareas de manera organizada
class Workspace extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String? avatarUrl;
  final WorkspaceType type;
  final int ownerId;
  final WorkspaceOwner owner;
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
    required this.owner,
    required this.userRole,
    required this.memberCount,
    required this.projectCount,
    required this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      type: WorkspaceType.fromString(json['type'] as String),
      ownerId: json['ownerId'] as int,
      owner: WorkspaceOwner.fromJson(json['owner'] as Map<String, dynamic>),
      userRole: WorkspaceRole.fromString(json['userRole'] as String),
      memberCount: json['memberCount'] as int,
      projectCount: json['projectCount'] as int,
      settings: WorkspaceSettings.fromJson(
        json['settings'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'avatarUrl': avatarUrl,
      'type': type.value,
      'ownerId': ownerId,
      'owner': owner.toJson(),
      'userRole': userRole.value,
      'memberCount': memberCount,
      'projectCount': projectCount,
      'settings': settings.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

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

/// Owner del workspace
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

  factory WorkspaceOwner.fromJson(Map<String, dynamic> json) {
    return WorkspaceOwner(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'avatarUrl': avatarUrl};
  }

  @override
  List<Object?> get props => [id, name, email, avatarUrl];
}

/// Configuración del workspace
class WorkspaceSettings extends Equatable {
  final bool allowGuestInvites;
  final bool requireEmailVerification;
  final bool autoAssignNewMembers;
  final String? defaultProjectTemplate;
  final String timezone;
  final String language;

  const WorkspaceSettings({
    required this.allowGuestInvites,
    required this.requireEmailVerification,
    required this.autoAssignNewMembers,
    this.defaultProjectTemplate,
    required this.timezone,
    required this.language,
  });

  factory WorkspaceSettings.fromJson(Map<String, dynamic> json) {
    return WorkspaceSettings(
      allowGuestInvites: json['allowGuestInvites'] as bool? ?? true,
      requireEmailVerification:
          json['requireEmailVerification'] as bool? ?? true,
      autoAssignNewMembers: json['autoAssignNewMembers'] as bool? ?? false,
      defaultProjectTemplate: json['defaultProjectTemplate'] as String?,
      timezone: json['timezone'] as String? ?? 'UTC',
      language: json['language'] as String? ?? 'es',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allowGuestInvites': allowGuestInvites,
      'requireEmailVerification': requireEmailVerification,
      'autoAssignNewMembers': autoAssignNewMembers,
      'defaultProjectTemplate': defaultProjectTemplate,
      'timezone': timezone,
      'language': language,
    };
  }

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

/// Tipo de workspace
enum WorkspaceType {
  personal('PERSONAL'),
  team('TEAM'),
  enterprise('ENTERPRISE');

  final String value;
  const WorkspaceType(this.value);

  static WorkspaceType fromString(String value) {
    return WorkspaceType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => WorkspaceType.personal,
    );
  }
}

/// Rol del usuario en el workspace
enum WorkspaceRole {
  owner('OWNER'),
  admin('ADMIN'),
  member('MEMBER'),
  guest('GUEST');

  final String value;
  const WorkspaceRole(this.value);

  static WorkspaceRole fromString(String value) {
    return WorkspaceRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => WorkspaceRole.member,
    );
  }

  /// Verifica si el rol puede administrar el workspace
  bool get canManage =>
      this == WorkspaceRole.owner || this == WorkspaceRole.admin;

  /// Verifica si el rol puede invitar miembros
  bool get canInvite => this != WorkspaceRole.guest;

  /// Verifica si el rol puede crear proyectos
  bool get canCreateProjects => this != WorkspaceRole.guest;
}



