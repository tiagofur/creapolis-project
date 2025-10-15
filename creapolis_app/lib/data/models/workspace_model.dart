import '../../domain/entities/workspace.dart';

/// Model para Workspace que maneja serialización JSON
class WorkspaceModel {
  final int id;
  final String name;
  final String? description;
  final String? avatarUrl;
  final String type;
  final int ownerId;
  final WorkspaceOwnerModel? owner;
  final String userRole;
  final int memberCount;
  final int projectCount;
  final WorkspaceSettingsModel settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkspaceModel({
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

  /// Crear desde JSON
  factory WorkspaceModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      type: json['type'] as String,
      ownerId: json['ownerId'] as int,
      owner: json['owner'] != null
          ? WorkspaceOwnerModel.fromJson(json['owner'] as Map<String, dynamic>)
          : null,
      userRole: json['userRole'] as String,
      memberCount: json['memberCount'] as int? ?? 0,
      projectCount: json['projectCount'] as int? ?? 0,
      settings: json['settings'] != null
          ? WorkspaceSettingsModel.fromJson(
              json['settings'] as Map<String, dynamic>,
            )
          : const WorkspaceSettingsModel(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'avatarUrl': avatarUrl,
      'type': type,
      'ownerId': ownerId,
      'owner': owner?.toJson(),
      'userRole': userRole,
      'memberCount': memberCount,
      'projectCount': projectCount,
      'settings': settings.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convertir a entidad de dominio
  Workspace toEntity() {
    return Workspace(
      id: id,
      name: name,
      description: description,
      avatarUrl: avatarUrl,
      type: WorkspaceType.fromString(type),
      ownerId: ownerId,
      owner: owner?.toEntity(),
      userRole: WorkspaceRole.fromString(userRole),
      memberCount: memberCount,
      projectCount: projectCount,
      settings: settings.toEntity(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Crear desde entidad de dominio
  factory WorkspaceModel.fromEntity(Workspace workspace) {
    return WorkspaceModel(
      id: workspace.id,
      name: workspace.name,
      description: workspace.description,
      avatarUrl: workspace.avatarUrl,
      type: workspace.type.value,
      ownerId: workspace.ownerId,
      owner: workspace.owner != null
          ? WorkspaceOwnerModel.fromEntity(workspace.owner!)
          : null,
      userRole: workspace.userRole.value,
      memberCount: workspace.memberCount,
      projectCount: workspace.projectCount,
      settings: WorkspaceSettingsModel.fromEntity(workspace.settings),
      createdAt: workspace.createdAt,
      updatedAt: workspace.updatedAt,
    );
  }
}

/// Model para WorkspaceOwner
class WorkspaceOwnerModel {
  final int id;
  final String name;
  final String email;
  final String? avatarUrl;

  const WorkspaceOwnerModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  factory WorkspaceOwnerModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceOwnerModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'avatarUrl': avatarUrl};
  }

  WorkspaceOwner toEntity() {
    return WorkspaceOwner(
      id: id,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
    );
  }

  factory WorkspaceOwnerModel.fromEntity(WorkspaceOwner owner) {
    return WorkspaceOwnerModel(
      id: owner.id,
      name: owner.name,
      email: owner.email,
      avatarUrl: owner.avatarUrl,
    );
  }
}

/// Model para WorkspaceSettings
class WorkspaceSettingsModel {
  final bool allowGuestInvites;
  final bool requireEmailVerification;
  final bool autoAssignNewMembers;
  final String? defaultProjectTemplate;
  final String timezone;
  final String language;

  const WorkspaceSettingsModel({
    this.allowGuestInvites = true,
    this.requireEmailVerification = true,
    this.autoAssignNewMembers = false,
    this.defaultProjectTemplate,
    this.timezone = 'UTC',
    this.language = 'es',
  });

  factory WorkspaceSettingsModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceSettingsModel(
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

  WorkspaceSettings toEntity() {
    return WorkspaceSettings(
      allowGuestInvites: allowGuestInvites,
      requireEmailVerification: requireEmailVerification,
      autoAssignNewMembers: autoAssignNewMembers,
      defaultProjectTemplate: defaultProjectTemplate,
      timezone: timezone,
      language: language,
    );
  }

  factory WorkspaceSettingsModel.fromEntity(WorkspaceSettings settings) {
    return WorkspaceSettingsModel(
      allowGuestInvites: settings.allowGuestInvites,
      requireEmailVerification: settings.requireEmailVerification,
      autoAssignNewMembers: settings.autoAssignNewMembers,
      defaultProjectTemplate: settings.defaultProjectTemplate,
      timezone: settings.timezone,
      language: settings.language,
    );
  }
}



