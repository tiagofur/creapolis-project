import 'package:hive/hive.dart';
import '../../../features/workspace/data/models/workspace_model.dart';

part 'hive_workspace.g.dart';

/// Modelo Hive para almacenamiento local de Workspaces
/// Versión simplificada para caché offline
@HiveType(typeId: 0)
class HiveWorkspace extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  String? avatarUrl;

  @HiveField(4)
  String type; // 'PERSONAL', 'TEAM', 'ENTERPRISE'

  @HiveField(5)
  int ownerId;

  @HiveField(6)
  String userRole; // 'OWNER', 'ADMIN', 'MEMBER', 'GUEST'

  @HiveField(7)
  int memberCount;

  @HiveField(8)
  int projectCount;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  DateTime updatedAt;

  @HiveField(11)
  DateTime? lastSyncedAt;

  @HiveField(12)
  bool isPendingSync;

  HiveWorkspace({
    required this.id,
    required this.name,
    this.description,
    this.avatarUrl,
    required this.type,
    required this.ownerId,
    required this.userRole,
    this.memberCount = 0,
    this.projectCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
    this.isPendingSync = false,
  });

  /// Convertir desde Entity a Hive
  factory HiveWorkspace.fromEntity(Workspace entity) {
    return HiveWorkspace(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      avatarUrl: entity.avatarUrl,
      type: entity.type.value,
      ownerId: entity.ownerId,
      userRole: entity.userRole.value,
      memberCount: entity.memberCount,
      projectCount: entity.projectCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      lastSyncedAt: DateTime.now(),
      isPendingSync: false,
    );
  }

  /// Convertir desde Hive a Entity
  Workspace toEntity() {
    return Workspace(
      id: id,
      name: name,
      description: description,
      avatarUrl: avatarUrl,
      type: WorkspaceType.fromString(type),
      ownerId: ownerId,
      owner: WorkspaceOwner(
        id: ownerId,
        name: '', // No tenemos el nombre en caché
        email: '', // No tenemos el email en caché
        avatarUrl: null,
      ),
      userRole: WorkspaceRole.fromString(userRole),
      memberCount: memberCount,
      projectCount: projectCount,
      settings: WorkspaceSettings.defaults(), // Default settings para caché
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convertir a JSON (para operation queue)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'avatarUrl': avatarUrl,
      'type': type,
      'ownerId': ownerId,
      'userRole': userRole,
      'memberCount': memberCount,
      'projectCount': projectCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'isPendingSync': isPendingSync,
    };
  }

  /// Crear desde JSON (para operation queue)
  factory HiveWorkspace.fromJson(Map<String, dynamic> json) {
    return HiveWorkspace(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      type: json['type'] as String,
      ownerId: json['ownerId'] as int,
      userRole: json['userRole'] as String,
      memberCount: json['memberCount'] as int? ?? 0,
      projectCount: json['projectCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'] as String)
          : null,
      isPendingSync: json['isPendingSync'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'HiveWorkspace(id: $id, name: $name, isPendingSync: $isPendingSync)';
  }
}
