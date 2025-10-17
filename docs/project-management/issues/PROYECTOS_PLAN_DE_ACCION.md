# 🎯 PLAN DE ACCIÓN - PROYECTOS

**Objetivo:** Llevar la funcionalidad de Proyectos al 100% de integración con Workspaces y estabilidad operacional.

**Fecha de inicio:** 16 de Octubre, 2025  
**Duración estimada:** 3-4 semanas  
**Prioridad:** ALTA

---

## 📊 RESUMEN EJECUTIVO

Este plan detalla las acciones necesarias para completar la funcionalidad de Proyectos, siguiendo el modelo exitoso de Workspaces. Se enfoca en:

1. 🔴 **Alineación Backend-Frontend** (Crítico)
2. 🔴 **Implementación de ProjectMembers** (Crítico)
3. 🟡 **Unificación de BLoCs** (Importante)
4. 🟢 **Funcionalidades avanzadas** (Mejora)

---

## 📋 FASE 1: ALINEACIÓN BACKEND-FRONTEND (CRÍTICA)

**Duración:** 3-5 días  
**Prioridad:** 🔴 CRÍTICA  
**Bloqueador:** Sí - Afecta toda la funcionalidad

### 1.1 Schema de Base de Datos

**Archivo:** `backend/prisma/schema.prisma`

**Cambios necesarios:**

```prisma
model Project {
  id          Int             @id @default(autoincrement())
  name        String
  description String?
  workspaceId Int

  // ✅ NUEVOS CAMPOS
  status      ProjectStatus   @default(PLANNED)
  startDate   DateTime
  endDate     DateTime
  managerId   Int?
  progress    Float           @default(0.0)

  createdAt   DateTime        @default(now())
  updatedAt   DateTime        @updatedAt

  workspace   Workspace       @relation(fields: [workspaceId], references: [id], onDelete: Cascade)
  manager     User?           @relation("ProjectManager", fields: [managerId], references: [id], onDelete: SetNull)
  members     ProjectMember[]
  tasks       Task[]
  comments    Comment[]
  roles       ProjectRole[]

  @@index([workspaceId])
  @@index([managerId])
  @@index([status])
  @@index([name])
}

// ✅ NUEVO ENUM
enum ProjectStatus {
  PLANNED
  ACTIVE
  PAUSED
  COMPLETED
  CANCELLED
}
```

**También actualizar en User:**

```prisma
model User {
  // ... campos existentes ...

  managedProjects Project[]       @relation("ProjectManager")

  // ... resto de relaciones ...
}
```

**Pasos:**

1. ✅ Modificar `schema.prisma`
2. ✅ Crear migración: `npx prisma migrate dev --name add_project_fields`
3. ✅ Generar cliente: `npx prisma generate`
4. ✅ Verificar migración en desarrollo
5. ✅ Documentar cambios

**Testing:**

```bash
# Verificar que la migración no rompa datos existentes
npm run test:db
```

---

### 1.2 Backend - Service Layer

**Archivo:** `backend/src/services/project.service.js`

**Cambios en `createProject`:**

```javascript
async createProject(
  userId,
  { name, description, workspaceId, memberIds = [],
    status = 'PLANNED', startDate, endDate, managerId }
) {
  // Validaciones
  if (!startDate || !endDate) {
    throw ErrorResponses.badRequest('Start and end dates are required');
  }

  if (new Date(endDate) < new Date(startDate)) {
    throw ErrorResponses.badRequest('End date must be after start date');
  }

  // Verificar workspace...

  const project = await prisma.project.create({
    data: {
      name,
      description,
      workspaceId,
      status,
      startDate: new Date(startDate),
      endDate: new Date(endDate),
      managerId: managerId || userId, // El creador es manager por defecto
      progress: 0.0,
      members: {
        create: uniqueMemberIds.map((memberId) => ({
          userId: memberId,
        })),
      },
    },
    include: {
      manager: {
        select: {
          id: true,
          name: true,
          email: true,
        },
      },
      members: {
        include: {
          user: {
            select: {
              id: true,
              name: true,
              email: true,
              role: true,
            },
          },
        },
      },
    },
  });

  return project;
}
```

**Cambios en `updateProject`:**

```javascript
async updateProject(
  projectId,
  userId,
  { name, description, status, startDate, endDate, managerId, progress }
) {
  // Check access...

  const updateData = {};
  if (name !== undefined) updateData.name = name;
  if (description !== undefined) updateData.description = description;
  if (status !== undefined) updateData.status = status;
  if (startDate !== undefined) updateData.startDate = new Date(startDate);
  if (endDate !== undefined) updateData.endDate = new Date(endDate);
  if (managerId !== undefined) updateData.managerId = managerId;
  if (progress !== undefined) updateData.progress = progress;

  const project = await prisma.project.update({
    where: { id: projectId },
    data: updateData,
    include: {
      manager: {
        select: {
          id: true,
          name: true,
          email: true,
        },
      },
      members: {
        include: {
          user: {
            select: {
              id: true,
              name: true,
              email: true,
              role: true,
            },
          },
        },
      },
    },
  });

  return project;
}
```

**Cambios en `getProjectById` y `getUserProjects`:**

```javascript
// Agregar include para manager
include: {
  manager: {
    select: {
      id: true,
      name: true,
      email: true,
    },
  },
  // ... resto de includes
}
```

---

### 1.3 Backend - Controller

**Archivo:** `backend/src/controllers/project.controller.js`

**Actualizar `create`:**

```javascript
create = asyncHandler(async (req, res) => {
  const {
    name,
    description,
    workspaceId,
    memberIds,
    status, // ✅ NUEVO
    startDate, // ✅ NUEVO
    endDate, // ✅ NUEVO
    managerId, // ✅ NUEVO
  } = req.body;

  const project = await projectService.createProject(req.user.id, {
    name,
    description,
    workspaceId,
    memberIds,
    status,
    startDate,
    endDate,
    managerId,
  });

  return successResponse(res, project, "Project created successfully", 201);
});
```

**Actualizar `update`:**

```javascript
update = asyncHandler(async (req, res) => {
  const projectId = parseInt(req.params.id);
  const {
    name,
    description,
    status, // ✅ NUEVO
    startDate, // ✅ NUEVO
    endDate, // ✅ NUEVO
    managerId, // ✅ NUEVO
    progress, // ✅ NUEVO
  } = req.body;

  const project = await projectService.updateProject(projectId, req.user.id, {
    name,
    description,
    status,
    startDate,
    endDate,
    managerId,
    progress,
  });

  return successResponse(res, project, "Project updated successfully");
});
```

---

### 1.4 Backend - Validators

**Archivo:** `backend/src/validators/project.validator.js`

**Actualizar validaciones:**

```javascript
import { body, param, query } from "express-validator";

export const createProjectValidation = [
  body("name")
    .trim()
    .notEmpty()
    .withMessage("Name is required")
    .isLength({ min: 3, max: 100 })
    .withMessage("Name must be between 3 and 100 characters"),

  body("description")
    .optional()
    .trim()
    .isLength({ max: 500 })
    .withMessage("Description must not exceed 500 characters"),

  body("workspaceId")
    .notEmpty()
    .withMessage("Workspace ID is required")
    .isInt({ min: 1 })
    .withMessage("Workspace ID must be a valid integer"),

  // ✅ NUEVAS VALIDACIONES
  body("status")
    .optional()
    .isIn(["PLANNED", "ACTIVE", "PAUSED", "COMPLETED", "CANCELLED"])
    .withMessage("Invalid status"),

  body("startDate")
    .notEmpty()
    .withMessage("Start date is required")
    .isISO8601()
    .withMessage("Start date must be a valid date"),

  body("endDate")
    .notEmpty()
    .withMessage("End date is required")
    .isISO8601()
    .withMessage("End date must be a valid date")
    .custom((endDate, { req }) => {
      if (new Date(endDate) <= new Date(req.body.startDate)) {
        throw new Error("End date must be after start date");
      }
      return true;
    }),

  body("managerId")
    .optional()
    .isInt({ min: 1 })
    .withMessage("Manager ID must be a valid integer"),

  body("memberIds")
    .optional()
    .isArray()
    .withMessage("Member IDs must be an array"),

  body("memberIds.*")
    .isInt({ min: 1 })
    .withMessage("Each member ID must be a valid integer"),
];

export const updateProjectValidation = [
  param("id")
    .isInt({ min: 1 })
    .withMessage("Project ID must be a valid integer"),

  body("name")
    .optional()
    .trim()
    .isLength({ min: 3, max: 100 })
    .withMessage("Name must be between 3 and 100 characters"),

  body("description")
    .optional()
    .trim()
    .isLength({ max: 500 })
    .withMessage("Description must not exceed 500 characters"),

  // ✅ NUEVAS VALIDACIONES
  body("status")
    .optional()
    .isIn(["PLANNED", "ACTIVE", "PAUSED", "COMPLETED", "CANCELLED"])
    .withMessage("Invalid status"),

  body("startDate")
    .optional()
    .isISO8601()
    .withMessage("Start date must be a valid date"),

  body("endDate")
    .optional()
    .isISO8601()
    .withMessage("End date must be a valid date"),

  body("managerId")
    .optional()
    .isInt({ min: 1 })
    .withMessage("Manager ID must be a valid integer"),

  body("progress")
    .optional()
    .isFloat({ min: 0, max: 1 })
    .withMessage("Progress must be between 0 and 1"),
];
```

---

### 1.5 Backend - Tests

**Archivo:** `backend/tests/project.test.js`

**Agregar tests para nuevos campos:**

```javascript
describe("Project API - New Fields", () => {
  it("should create project with status and dates", async () => {
    const res = await request(app)
      .post("/api/projects")
      .set("Authorization", `Bearer ${authToken}`)
      .send({
        name: "New Project",
        description: "Test project",
        workspaceId: testWorkspaceId,
        status: "ACTIVE",
        startDate: "2025-01-01",
        endDate: "2025-12-31",
        managerId: testUserId,
      });

    expect(res.status).toBe(201);
    expect(res.body.data.status).toBe("ACTIVE");
    expect(res.body.data.startDate).toBeDefined();
    expect(res.body.data.endDate).toBeDefined();
    expect(res.body.data.managerId).toBe(testUserId);
  });

  it("should reject project with end date before start date", async () => {
    const res = await request(app)
      .post("/api/projects")
      .set("Authorization", `Bearer ${authToken}`)
      .send({
        name: "Invalid Project",
        workspaceId: testWorkspaceId,
        startDate: "2025-12-31",
        endDate: "2025-01-01",
      });

    expect(res.status).toBe(400);
  });

  it("should update project status", async () => {
    const res = await request(app)
      .put(`/api/projects/${testProjectId}`)
      .set("Authorization", `Bearer ${authToken}`)
      .send({
        status: "COMPLETED",
      });

    expect(res.status).toBe(200);
    expect(res.body.data.status).toBe("COMPLETED");
  });
});
```

---

### 1.6 Frontend - Actualizar Models

**Archivo:** `creapolis_app/lib/data/models/project_model.dart`

**Verificar que mapee correctamente los nuevos campos:**

```dart
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

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: ProjectStatus.fromString(json['status'] as String? ?? 'planned'),
      managerId: json['managerId'] as int?,
      managerName: json['manager']?['name'] as String?,
      workspaceId: json['workspaceId'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status.name.toUpperCase(),
      'managerId': managerId,
      'workspaceId': workspaceId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
```

---

### 1.7 Frontend - Actualizar Remote DataSource

**Archivo:** `creapolis_app/lib/data/datasources/project_remote_datasource.dart`

**Actualizar método `createProject`:**

```dart
@override
Future<ProjectModel> createProject({
  required String name,
  required String description,
  required DateTime startDate,
  required DateTime endDate,
  required ProjectStatus status,
  int? managerId,
  required int workspaceId,
}) async {
  AppLogger.info('ProjectRemoteDataSource: Creando proyecto $name');

  try {
    final requestData = {
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status.name.toUpperCase(),
      'workspaceId': workspaceId,
      if (managerId != null) 'managerId': managerId,
    };

    final response = await _apiClient.post<Map<String, dynamic>>(
      '/projects',
      data: requestData,
    );

    final responseBody = response.data;
    if (responseBody == null || responseBody['data'] == null) {
      throw ServerException('Respuesta inválida del servidor');
    }

    final project = ProjectModel.fromJson(
      responseBody['data'] as Map<String, dynamic>,
    );

    AppLogger.info(
      'ProjectRemoteDataSource: Proyecto ${project.name} creado exitosamente',
    );

    return project;
  } catch (e) {
    AppLogger.error('ProjectRemoteDataSource: Error al crear proyecto - $e');
    rethrow;
  }
}
```

**Actualizar método `updateProject`:**

```dart
@override
Future<ProjectModel> updateProject({
  required int id,
  String? name,
  String? description,
  DateTime? startDate,
  DateTime? endDate,
  ProjectStatus? status,
  int? managerId,
}) async {
  AppLogger.info('ProjectRemoteDataSource: Actualizando proyecto $id');

  try {
    final requestData = <String, dynamic>{};
    if (name != null) requestData['name'] = name;
    if (description != null) requestData['description'] = description;
    if (startDate != null) requestData['startDate'] = startDate.toIso8601String();
    if (endDate != null) requestData['endDate'] = endDate.toIso8601String();
    if (status != null) requestData['status'] = status.name.toUpperCase();
    if (managerId != null) requestData['managerId'] = managerId;

    final response = await _apiClient.put<Map<String, dynamic>>(
      '/projects/$id',
      data: requestData,
    );

    final responseBody = response.data;
    if (responseBody == null || responseBody['data'] == null) {
      throw ServerException('Respuesta inválida del servidor');
    }

    final project = ProjectModel.fromJson(
      responseBody['data'] as Map<String, dynamic>,
    );

    AppLogger.info(
      'ProjectRemoteDataSource: Proyecto ${project.name} actualizado',
    );

    return project;
  } catch (e) {
    AppLogger.error('ProjectRemoteDataSource: Error al actualizar - $e');
    rethrow;
  }
}
```

---

### 1.8 Checklist Fase 1

- [ ] **1.1** Actualizar schema.prisma
- [ ] **1.2** Crear y ejecutar migración
- [ ] **1.3** Actualizar ProjectService
- [ ] **1.4** Actualizar ProjectController
- [ ] **1.5** Actualizar validators
- [ ] **1.6** Crear tests backend
- [ ] **1.7** Ejecutar tests backend
- [ ] **1.8** Actualizar ProjectModel en Flutter
- [ ] **1.9** Actualizar RemoteDataSource
- [ ] **1.10** Probar integración end-to-end
- [ ] **1.11** Actualizar documentación API
- [ ] **1.12** Code review
- [ ] **1.13** Merge a main

**Criterios de aceptación:**

- ✅ Migración ejecutada sin errores
- ✅ Tests backend pasando (100%)
- ✅ Frontend recibe todos los campos
- ✅ Fechas se validan correctamente
- ✅ Status se actualiza y persiste
- ✅ Manager se asigna y muestra

---

## 👥 FASE 2: PROJECT MEMBERS (CRÍTICA)

**Duración:** 4-6 días  
**Prioridad:** 🔴 CRÍTICA  
**Bloqueador:** Sí - Impide colaboración

### 2.1 Frontend - Domain Layer

**Crear Entity:**

**Archivo:** `creapolis_app/lib/domain/entities/project_member.dart`

```dart
import 'package:equatable/equatable.dart';

/// Rol del miembro en el proyecto
enum ProjectMemberRole {
  owner,      // Propietario/Manager
  admin,      // Administrador
  member,     // Miembro regular
  viewer;     // Solo lectura

  String get label {
    switch (this) {
      case ProjectMemberRole.owner:
        return 'Propietario';
      case ProjectMemberRole.admin:
        return 'Administrador';
      case ProjectMemberRole.member:
        return 'Miembro';
      case ProjectMemberRole.viewer:
        return 'Espectador';
    }
  }
}

/// Entidad de dominio para ProjectMember
class ProjectMember extends Equatable {
  final int id;
  final int userId;
  final int projectId;
  final String userName;
  final String userEmail;
  final String? userAvatarUrl;
  final ProjectMemberRole role;
  final DateTime joinedAt;
  final bool isActive;

  const ProjectMember({
    required this.id,
    required this.userId,
    required this.projectId,
    required this.userName,
    required this.userEmail,
    this.userAvatarUrl,
    required this.role,
    required this.joinedAt,
    this.isActive = true,
  });

  /// Verifica si el miembro es el owner del proyecto
  bool get isOwner => role == ProjectMemberRole.owner;

  /// Verifica si el miembro tiene permisos de administración
  bool get canManage => role == ProjectMemberRole.owner || role == ProjectMemberRole.admin;

  /// Verifica si el miembro puede solo ver
  bool get isReadOnly => role == ProjectMemberRole.viewer;

  @override
  List<Object?> get props => [
    id,
    userId,
    projectId,
    userName,
    userEmail,
    userAvatarUrl,
    role,
    joinedAt,
    isActive,
  ];
}
```

---

**Crear Repository:**

**Archivo:** `creapolis_app/lib/domain/repositories/project_member_repository.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/project_member.dart';

/// Repositorio de miembros de proyecto
abstract class ProjectMemberRepository {
  /// Obtener miembros de un proyecto
  Future<Either<Failure, List<ProjectMember>>> getProjectMembers(int projectId);

  /// Agregar miembro a un proyecto
  Future<Either<Failure, ProjectMember>> addMember({
    required int projectId,
    required int userId,
    ProjectMemberRole? role,
  });

  /// Actualizar rol de un miembro
  Future<Either<Failure, ProjectMember>> updateMemberRole({
    required int projectId,
    required int userId,
    required ProjectMemberRole role,
  });

  /// Remover miembro de un proyecto
  Future<Either<Failure, void>> removeMember({
    required int projectId,
    required int userId,
  });
}
```

---

### 2.2 Frontend - Data Layer

**Crear Model:**

**Archivo:** `creapolis_app/lib/data/models/project_member_model.dart`

```dart
import '../../domain/entities/project_member.dart';

class ProjectMemberModel extends ProjectMember {
  const ProjectMemberModel({
    required super.id,
    required super.userId,
    required super.projectId,
    required super.userName,
    required super.userEmail,
    super.userAvatarUrl,
    required super.role,
    required super.joinedAt,
    super.isActive,
  });

  factory ProjectMemberModel.fromJson(Map<String, dynamic> json) {
    return ProjectMemberModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      projectId: json['projectId'] as int,
      userName: json['user']['name'] as String,
      userEmail: json['user']['email'] as String,
      userAvatarUrl: json['user']['avatarUrl'] as String?,
      role: _roleFromString(json['role'] as String?),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  static ProjectMemberRole _roleFromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'owner':
        return ProjectMemberRole.owner;
      case 'admin':
        return ProjectMemberRole.admin;
      case 'viewer':
        return ProjectMemberRole.viewer;
      default:
        return ProjectMemberRole.member;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'projectId': projectId,
      'role': role.name,
      'joinedAt': joinedAt.toIso8601String(),
      'isActive': isActive,
    };
  }
}
```

---

**Crear Remote DataSource:**

**Archivo:** `creapolis_app/lib/data/datasources/project_member_remote_datasource.dart`

```dart
import 'package:injectable/injectable.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/project_member.dart';
import '../models/project_member_model.dart';

abstract class ProjectMemberRemoteDataSource {
  Future<List<ProjectMemberModel>> getProjectMembers(int projectId);
  Future<ProjectMemberModel> addMember(int projectId, int userId);
  Future<void> removeMember(int projectId, int userId);
}

@LazySingleton(as: ProjectMemberRemoteDataSource)
class ProjectMemberRemoteDataSourceImpl implements ProjectMemberRemoteDataSource {
  final ApiClient _apiClient;

  ProjectMemberRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ProjectMemberModel>> getProjectMembers(int projectId) async {
    AppLogger.info('ProjectMemberRemoteDS: Obteniendo miembros del proyecto $projectId');

    try {
      // Los miembros vienen incluidos al obtener el proyecto
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/projects/$projectId',
      );

      final responseBody = response.data;
      if (responseBody == null || responseBody['data'] == null) {
        throw ServerException('Respuesta inválida del servidor');
      }

      final project = responseBody['data'] as Map<String, dynamic>;
      final membersData = project['members'] as List<dynamic>?;

      if (membersData == null || membersData.isEmpty) {
        AppLogger.info('ProjectMemberRemoteDS: No hay miembros en el proyecto');
        return [];
      }

      final members = membersData
          .map((json) => ProjectMemberModel.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.info('ProjectMemberRemoteDS: ${members.length} miembros obtenidos');

      return members;
    } catch (e) {
      AppLogger.error('ProjectMemberRemoteDS: Error al obtener miembros - $e');
      rethrow;
    }
  }

  @override
  Future<ProjectMemberModel> addMember(int projectId, int userId) async {
    AppLogger.info('ProjectMemberRemoteDS: Agregando miembro $userId al proyecto $projectId');

    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/projects/$projectId/members',
        data: {'userId': userId},
      );

      final responseBody = response.data;
      if (responseBody == null || responseBody['data'] == null) {
        throw ServerException('Respuesta inválida del servidor');
      }

      final member = ProjectMemberModel.fromJson(
        responseBody['data'] as Map<String, dynamic>,
      );

      AppLogger.info('ProjectMemberRemoteDS: Miembro agregado exitosamente');

      return member;
    } catch (e) {
      AppLogger.error('ProjectMemberRemoteDS: Error al agregar miembro - $e');
      rethrow;
    }
  }

  @override
  Future<void> removeMember(int projectId, int userId) async {
    AppLogger.info('ProjectMemberRemoteDS: Removiendo miembro $userId del proyecto $projectId');

    try {
      await _apiClient.delete(
        '/projects/$projectId/members/$userId',
      );

      AppLogger.info('ProjectMemberRemoteDS: Miembro removido exitosamente');
    } catch (e) {
      AppLogger.error('ProjectMemberRemoteDS: Error al remover miembro - $e');
      rethrow;
    }
  }
}
```

---

**Crear Repository Implementation:**

**Archivo:** `creapolis_app/lib/data/repositories/project_member_repository_impl.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/project_member.dart';
import '../../domain/repositories/project_member_repository.dart';
import '../datasources/project_member_remote_datasource.dart';

@LazySingleton(as: ProjectMemberRepository)
class ProjectMemberRepositoryImpl implements ProjectMemberRepository {
  final ProjectMemberRemoteDataSource _remoteDataSource;

  ProjectMemberRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<ProjectMember>>> getProjectMembers(
    int projectId,
  ) async {
    try {
      final members = await _remoteDataSource.getProjectMembers(projectId);
      return Right(members);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error desconocido: $e'));
    }
  }

  @override
  Future<Either<Failure, ProjectMember>> addMember({
    required int projectId,
    required int userId,
    ProjectMemberRole? role,
  }) async {
    try {
      final member = await _remoteDataSource.addMember(projectId, userId);
      return Right(member);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error desconocido: $e'));
    }
  }

  @override
  Future<Either<Failure, ProjectMember>> updateMemberRole({
    required int projectId,
    required int userId,
    required ProjectMemberRole role,
  }) async {
    // TODO: Implementar cuando el backend lo soporte
    return const Left(ServerFailure('No implementado aún'));
  }

  @override
  Future<Either<Failure, void>> removeMember({
    required int projectId,
    required int userId,
  }) async {
    try {
      await _remoteDataSource.removeMember(projectId, userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error desconocido: $e'));
    }
  }
}
```

---

### 2.3 Frontend - Presentation Layer

**Crear BLoC:**

**Archivo:** `creapolis_app/lib/presentation/bloc/project_member/project_member_event.dart`

```dart
import 'package:equatable/equatable.dart';

abstract class ProjectMemberEvent extends Equatable {
  const ProjectMemberEvent();

  @override
  List<Object?> get props => [];
}

class LoadProjectMembers extends ProjectMemberEvent {
  final int projectId;

  const LoadProjectMembers(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class AddProjectMember extends ProjectMemberEvent {
  final int projectId;
  final int userId;

  const AddProjectMember(this.projectId, this.userId);

  @override
  List<Object?> get props => [projectId, userId];
}

class RemoveProjectMember extends ProjectMemberEvent {
  final int projectId;
  final int userId;

  const RemoveProjectMember(this.projectId, this.userId);

  @override
  List<Object?> get props => [projectId, userId];
}
```

**Archivo:** `creapolis_app/lib/presentation/bloc/project_member/project_member_state.dart`

```dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/project_member.dart';

abstract class ProjectMemberState extends Equatable {
  const ProjectMemberState();

  @override
  List<Object?> get props => [];
}

class ProjectMemberInitial extends ProjectMemberState {
  const ProjectMemberInitial();
}

class ProjectMemberLoading extends ProjectMemberState {
  const ProjectMemberLoading();
}

class ProjectMembersLoaded extends ProjectMemberState {
  final List<ProjectMember> members;
  final int projectId;

  const ProjectMembersLoaded(this.members, this.projectId);

  @override
  List<Object?> get props => [members, projectId];
}

class ProjectMemberOperationSuccess extends ProjectMemberState {
  final String message;
  final List<ProjectMember>? members;

  const ProjectMemberOperationSuccess(this.message, {this.members});

  @override
  List<Object?> get props => [message, members];
}

class ProjectMemberError extends ProjectMemberState {
  final String message;

  const ProjectMemberError(this.message);

  @override
  List<Object?> get props => [message];
}
```

**Archivo:** `creapolis_app/lib/presentation/bloc/project_member/project_member_bloc.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../core/utils/app_logger.dart';
import '../../../domain/repositories/project_member_repository.dart';
import 'project_member_event.dart';
import 'project_member_state.dart';

@injectable
class ProjectMemberBloc extends Bloc<ProjectMemberEvent, ProjectMemberState> {
  final ProjectMemberRepository _repository;

  ProjectMemberBloc(this._repository) : super(const ProjectMemberInitial()) {
    on<LoadProjectMembers>(_onLoadProjectMembers);
    on<AddProjectMember>(_onAddProjectMember);
    on<RemoveProjectMember>(_onRemoveProjectMember);
  }

  Future<void> _onLoadProjectMembers(
    LoadProjectMembers event,
    Emitter<ProjectMemberState> emit,
  ) async {
    AppLogger.info('ProjectMemberBloc: Cargando miembros del proyecto ${event.projectId}');
    emit(const ProjectMemberLoading());

    final result = await _repository.getProjectMembers(event.projectId);

    result.fold(
      (failure) {
        AppLogger.error('ProjectMemberBloc: Error - ${failure.message}');
        emit(ProjectMemberError(failure.message));
      },
      (members) {
        AppLogger.info('ProjectMemberBloc: ${members.length} miembros cargados');
        emit(ProjectMembersLoaded(members, event.projectId));
      },
    );
  }

  Future<void> _onAddProjectMember(
    AddProjectMember event,
    Emitter<ProjectMemberState> emit,
  ) async {
    AppLogger.info('ProjectMemberBloc: Agregando miembro ${event.userId}');

    // Mantener lista actual mientras se agrega
    final currentState = state;
    final currentMembers = currentState is ProjectMembersLoaded
        ? currentState.members
        : <ProjectMember>[];

    final result = await _repository.addMember(
      projectId: event.projectId,
      userId: event.userId,
    );

    result.fold(
      (failure) {
        AppLogger.error('ProjectMemberBloc: Error - ${failure.message}');
        emit(ProjectMemberError(failure.message));

        // Restaurar estado anterior
        if (currentMembers.isNotEmpty) {
          emit(ProjectMembersLoaded(currentMembers, event.projectId));
        }
      },
      (newMember) {
        AppLogger.info('ProjectMemberBloc: Miembro agregado exitosamente');

        final updatedMembers = [...currentMembers, newMember];

        emit(const ProjectMemberOperationSuccess('Miembro agregado exitosamente'));
        emit(ProjectMembersLoaded(updatedMembers, event.projectId));
      },
    );
  }

  Future<void> _onRemoveProjectMember(
    RemoveProjectMember event,
    Emitter<ProjectMemberState> emit,
  ) async {
    AppLogger.info('ProjectMemberBloc: Removiendo miembro ${event.userId}');

    final currentState = state;
    final currentMembers = currentState is ProjectMembersLoaded
        ? currentState.members
        : <ProjectMember>[];

    final result = await _repository.removeMember(
      projectId: event.projectId,
      userId: event.userId,
    );

    result.fold(
      (failure) {
        AppLogger.error('ProjectMemberBloc: Error - ${failure.message}');
        emit(ProjectMemberError(failure.message));

        if (currentMembers.isNotEmpty) {
          emit(ProjectMembersLoaded(currentMembers, event.projectId));
        }
      },
      (_) {
        AppLogger.info('ProjectMemberBloc: Miembro removido exitosamente');

        final updatedMembers = currentMembers
            .where((m) => m.userId != event.userId)
            .toList();

        emit(const ProjectMemberOperationSuccess('Miembro removido exitosamente'));
        emit(ProjectMembersLoaded(updatedMembers, event.projectId));
      },
    );
  }
}
```

---

**Crear UI Screen:**

**Archivo:** `creapolis_app/lib/presentation/screens/projects/project_members_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/project_member.dart';
import '../../bloc/project_member/project_member_bloc.dart';
import '../../bloc/project_member/project_member_event.dart';
import '../../bloc/project_member/project_member_state.dart';
import '../../widgets/common/common_widgets.dart';

class ProjectMembersScreen extends StatelessWidget {
  final int projectId;
  final String projectName;

  const ProjectMembersScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CreopolisAppBar(
        title: 'Miembros de $projectName',
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddMemberDialog(context),
            tooltip: 'Agregar miembro',
          ),
        ],
      ),
      body: BlocConsumer<ProjectMemberBloc, ProjectMemberState>(
        listener: (context, state) {
          if (state is ProjectMemberOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ProjectMemberError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProjectMemberLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProjectMembersLoaded) {
            if (state.members.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.members.length,
              itemBuilder: (context, index) {
                final member = state.members[index];
                return _MemberCard(
                  member: member,
                  onRemove: () => _confirmRemoveMember(context, member),
                );
              },
            );
          }

          if (state is ProjectMemberError) {
            return _buildErrorState(context, state.message);
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay miembros en este proyecto',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega miembros para colaborar',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<ProjectMemberBloc>().add(
                LoadProjectMembers(projectId),
              );
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddMemberDialog(BuildContext context) async {
    // TODO: Implementar dialog para buscar y agregar usuarios
    AppLogger.info('Mostrar dialog para agregar miembro');
  }

  Future<void> _confirmRemoveMember(
    BuildContext context,
    ProjectMember member,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remover Miembro'),
        content: Text(
          '¿Estás seguro de que deseas remover a ${member.userName} del proyecto?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<ProjectMemberBloc>().add(
        RemoveProjectMember(projectId, member.userId),
      );
    }
  }
}

class _MemberCard extends StatelessWidget {
  final ProjectMember member;
  final VoidCallback onRemove;

  const _MemberCard({
    required this.member,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: member.userAvatarUrl != null
              ? NetworkImage(member.userAvatarUrl!)
              : null,
          child: member.userAvatarUrl == null
              ? Text(member.userName[0].toUpperCase())
              : null,
        ),
        title: Text(member.userName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(member.userEmail),
            const SizedBox(height: 4),
            Chip(
              label: Text(
                member.role.label,
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: _getRoleColor(member.role).withValues(alpha: 0.2),
              labelStyle: TextStyle(color: _getRoleColor(member.role)),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        trailing: !member.isOwner
            ? IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                color: theme.colorScheme.error,
                onPressed: onRemove,
              )
            : const Icon(Icons.star, color: Colors.amber),
        isThreeLine: true,
      ),
    );
  }

  Color _getRoleColor(ProjectMemberRole role) {
    switch (role) {
      case ProjectMemberRole.owner:
        return Colors.purple;
      case ProjectMemberRole.admin:
        return Colors.blue;
      case ProjectMemberRole.member:
        return Colors.green;
      case ProjectMemberRole.viewer:
        return Colors.grey;
    }
  }
}
```

---

### 2.4 Frontend - Integración

**Actualizar Router:**

**Archivo:** `creapolis_app/lib/routes/app_router.dart`

```dart
// Agregar ruta dentro de project detail
GoRoute(
  path: 'members',
  name: RouteNames.projectMembers,
  builder: (context, state) {
    final projectId = int.parse(state.pathParameters['pId'] ?? '0');
    // TODO: Obtener project name del estado

    return BlocProvider(
      create: (context) => getIt<ProjectMemberBloc>()
        ..add(LoadProjectMembers(projectId)),
      child: ProjectMembersScreen(
        projectId: projectId,
        projectName: 'Proyecto', // TODO: Pasar nombre real
      ),
    );
  },
),
```

**Actualizar ProjectDetailScreen:**

```dart
// Agregar botón para ver miembros en AppBar
actions: [
  IconButton(
    icon: const Icon(Icons.people),
    onPressed: () {
      context.go(
        '/workspaces/$workspaceId/projects/${project.id}/members',
      );
    },
    tooltip: 'Ver miembros',
  ),
  // ... otros botones
]
```

---

### 2.5 Checklist Fase 2

- [ ] **2.1** Crear entity ProjectMember
- [ ] **2.2** Crear repository interface
- [ ] **2.3** Crear model ProjectMemberModel
- [ ] **2.4** Crear RemoteDataSource
- [ ] **2.5** Crear RepositoryImpl
- [ ] **2.6** Crear ProjectMemberBloc
- [ ] **2.7** Crear ProjectMembersScreen
- [ ] **2.8** Agregar ruta al router
- [ ] **2.9** Integrar con ProjectDetailScreen
- [ ] **2.10** Agregar widget de diálogo para buscar usuarios
- [ ] **2.11** Registrar en DI (injection.dart)
- [ ] **2.12** Ejecutar build_runner
- [ ] **2.13** Probar flujo completo
- [ ] **2.14** Code review
- [ ] **2.15** Merge a main

**Criterios de aceptación:**

- ✅ Se pueden ver miembros del proyecto
- ✅ Se pueden agregar miembros
- ✅ Se pueden remover miembros
- ✅ Se muestra el rol de cada miembro
- ✅ UI responsive y accesible

---

## 🔀 FASE 3: UNIFICACIÓN DE BLoCs

**Duración:** 2-3 días  
**Prioridad:** 🟡 IMPORTANTE  
**Bloqueador:** No - Pero genera deuda técnica

### 3.1 Estrategia

**Opción recomendada:** Usar el BLoC nuevo (`features/projects/presentation/blocs/`) como base, mejorándolo con UseCases.

**Pasos:**

1. ✅ **Auditar ambos BLoCs** - Identificar funcionalidades únicas
2. ✅ **Integrar UseCases** en el BLoC nuevo
3. ✅ **Migrar ProjectDetailScreen** al BLoC nuevo
4. ✅ **Eliminar BLoC viejo**
5. ✅ **Actualizar imports** en todo el proyecto
6. ✅ **Regenerar DI** con build_runner

### 3.2 Modificaciones al BLoC Nuevo

**Archivo:** `creapolis_app/lib/features/projects/presentation/blocs/project_bloc.dart`

```dart
@injectable
class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  // ✅ Agregar UseCases
  final GetProjectsUseCase _getProjectsUseCase;
  final GetProjectByIdUseCase _getProjectByIdUseCase;
  final CreateProjectUseCase _createProjectUseCase;
  final UpdateProjectUseCase _updateProjectUseCase;
  final DeleteProjectUseCase _deleteProjectUseCase;

  ProjectBloc(
    this._getProjectsUseCase,
    this._getProjectByIdUseCase,
    this._createProjectUseCase,
    this._updateProjectUseCase,
    this._deleteProjectUseCase,
  ) : super(const ProjectInitial()) {
    on<LoadProjects>(_onLoadProjects);
    on<LoadProjectById>(_onLoadProjectById);
    on<CreateProject>(_onCreateProject);
    on<UpdateProject>(_onUpdateProject);
    on<DeleteProject>(_onDeleteProject);
    on<RefreshProjects>(_onRefreshProjects);
    on<FilterProjectsByStatus>(_onFilterProjectsByStatus);
    on<SearchProjects>(_onSearchProjects);
  }

  // Mantener implementaciones actuales pero usando UseCases
  // ...
}
```

### 3.3 Migración de Screens

**ProjectDetailScreen:**

```dart
// Cambiar import
// De:
import '../../bloc/project/project_bloc.dart';
// A:
import '../../../features/projects/presentation/blocs/project_bloc.dart';

// Actualizar eventos
// De: LoadProjectByIdEvent(id)
// A: LoadProjectById(id)
```

### 3.4 Limpieza

**Eliminar archivos legacy:**

```
lib/presentation/bloc/project/
├── project_bloc.dart         ❌ ELIMINAR
├── project_event.dart        ❌ ELIMINAR
└── project_state.dart        ❌ ELIMINAR
```

### 3.5 Checklist Fase 3

- [ ] **3.1** Documentar diferencias entre BLoCs
- [ ] **3.2** Integrar UseCases en BLoC nuevo
- [ ] **3.3** Actualizar ProjectDetailScreen
- [ ] **3.4** Actualizar todos los imports
- [ ] **3.5** Eliminar BLoC viejo
- [ ] **3.6** Ejecutar build_runner
- [ ] **3.7** Probar todas las screens
- [ ] **3.8** Verificar que no haya imports rotos
- [ ] **3.9** Code review
- [ ] **3.10** Merge a main

---

## 🚀 FASE 4: FUNCIONALIDADES AVANZADAS

**Duración:** 5-7 días  
**Prioridad:** 🟢 MEJORA  
**Bloqueador:** No

### 4.1 Status Management UI

- [ ] Dropdown para cambiar status
- [ ] Colores y badges por status
- [ ] Validaciones de transiciones
- [ ] Confirmación para completar/cancelar

### 4.2 Date Pickers y Timeline

- [ ] Date pickers nativos
- [ ] Validación de fechas
- [ ] Timeline visual mejorado
- [ ] Indicadores de retrasados

### 4.3 Manager Assignment

- [ ] Selector de manager
- [ ] Transfer ownership
- [ ] Permisos basados en manager

### 4.4 Progress Calculation

- [ ] Progreso real basado en tareas
- [ ] Barra de progreso dinámica
- [ ] Métricas de completitud
- [ ] Predicciones de finalización

### 4.5 Project Settings Screen

- [ ] Configuración general
- [ ] Permisos y privacidad
- [ ] Notificaciones
- [ ] Integraciones

---

## 🎨 FASE 5: INTEGRACIÓN PROFUNDA CON WORKSPACES

**Duración:** 3-4 días  
**Prioridad:** 🟡 IMPORTANTE  
**Bloqueador:** No

### 5.1 ProjectContext Provider

Similar a WorkspaceContext:

```dart
class ProjectContext extends ChangeNotifier {
  Project? _activeProject;

  Project? get activeProject => _activeProject;

  Future<void> setActiveProject(int projectId) async {
    // Load and set project
    notifyListeners();
  }
}
```

### 5.2 Dashboard por Proyecto

- [ ] Resumen de tareas
- [ ] Gráficas de progreso
- [ ] Actividad reciente
- [ ] Miembros activos

### 5.3 Validaciones de Acceso

- [ ] Verificar permisos en workspace
- [ ] Restringir acciones por rol
- [ ] Mostrar/ocultar opciones según permisos

---

## 📊 MÉTRICAS DE ÉXITO

### KPIs por Fase

| Fase   | Métrica                  | Objetivo    |
| ------ | ------------------------ | ----------- |
| Fase 1 | Campos completos en API  | 100%        |
| Fase 1 | Tests backend pasando    | 100%        |
| Fase 2 | UI de members funcional  | 100%        |
| Fase 2 | Operaciones CRUD members | 100%        |
| Fase 3 | BLoC unificado           | 1 solo BLoC |
| Fase 3 | Imports actualizados     | 0 legacy    |
| Fase 4 | Funcionalidades básicas  | 90%         |
| Fase 5 | Integración workspace    | 80%         |

### Criterios de Completitud General

- ✅ **Backend:** Todos los campos implementados
- ✅ **Frontend:** CRUD completo funcionando
- ✅ **Members:** Gestión completa de miembros
- ✅ **UI/UX:** Consistente con Workspaces
- ✅ **Testing:** Cobertura >70%
- ✅ **Documentación:** README actualizado

---

## 🗓️ CRONOGRAMA

```
Semana 1:
├── Lunes-Martes:    Fase 1 (Backend alignment)
├── Miércoles:       Fase 1 (Tests y validación)
├── Jueves-Viernes:  Fase 2 (ProjectMembers backend)
└── Sábado:          Fase 2 (ProjectMembers frontend)

Semana 2:
├── Lunes:           Fase 2 (UI y testing)
├── Martes:          Fase 3 (Unificación BLoCs)
├── Miércoles:       Fase 3 (Testing)
├── Jueves-Viernes:  Fase 4 (Funcionalidades)
└── Sábado:          Fase 4 (Refinamiento)

Semana 3:
├── Lunes-Martes:    Fase 5 (Integración Workspaces)
├── Miércoles:       Testing integral
├── Jueves:          Correcciones
└── Viernes:         Deploy y documentación

Buffer:
└── Semana 4: Contingencia y refinamiento
```

---

## ⚠️ RIESGOS Y MITIGACIONES

| Riesgo               | Probabilidad | Impacto | Mitigación                            |
| -------------------- | ------------ | ------- | ------------------------------------- |
| Migración DB falla   | Baja         | Alto    | Backup antes de migrar, rollback plan |
| Conflictos BLoC      | Media        | Medio   | Tests extensivos, feature flags       |
| API breaking changes | Baja         | Alto    | Versioning, backward compatibility    |
| Performance issues   | Media        | Medio   | Profiling, lazy loading               |
| UI inconsistencies   | Alta         | Bajo    | Design system, code review            |

---

## 📝 CONCLUSIÓN

Este plan de acción proporciona una ruta clara para completar la funcionalidad de Proyectos al 100%. Las **Fases 1 y 2 son críticas** y deben completarse primero para desbloquear el resto de la funcionalidad.

**Próximos pasos inmediatos:**

1. ✅ Aprobar este plan
2. ✅ Crear branch `feature/projects-completion`
3. ✅ Iniciar Fase 1: Backend alignment
4. ✅ Daily stand-ups para seguimiento

**Tiempo total estimado:** 3-4 semanas  
**Esfuerzo:** 1 desarrollador full-time  
**Valor entregado:** Funcionalidad completa y estable de Proyectos

---

**Generado por:** GitHub Copilot  
**Fecha:** 16 de Octubre, 2025  
**Versión:** 1.0
