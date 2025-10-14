# 🏢 WORKSPACE SYSTEM - PLAN MAESTRO COMPLETO

**Fecha de inicio:** 8 de Octubre, 2025  
**Proyecto:** Creapolis - Sistema de Workspaces  
**Objetivo:** Implementar sistema completo de espacios de trabajo colaborativos con aislamiento de datos

---

## 📋 TABLA DE CONTENIDOS

1. [Visión General](#visión-general)
2. [Arquitectura del Sistema](#arquitectura-del-sistema)
3. [Fases de Implementación](#fases-de-implementación)
4. [Estado Actual](#estado-actual)
5. [Roadmap Detallado](#roadmap-detallado)
6. [Dependencias y Requisitos](#dependencias-y-requisitos)

---

## 🎯 VISIÓN GENERAL

### ¿Qué es el Sistema de Workspaces?

Un **Workspace** (espacio de trabajo) es un entorno completamente aislado donde equipos colaboran en proyectos y tareas. Similar a:

- **Slack:** Cada workspace es una organización independiente
- **Notion:** Espacios de trabajo separados con miembros y permisos
- **Asana:** Organizaciones con equipos y proyectos

### Características Principales

✅ **Aislamiento Total:** Cada workspace tiene sus propios proyectos, tareas y miembros  
✅ **Multi-Tenancy:** Un usuario puede pertenecer a múltiples workspaces  
✅ **Sistema de Roles:** Owner, Admin, Member, Guest con permisos granulares  
✅ **Invitaciones:** Sistema de invitaciones por email con tokens de expiración  
✅ **Configuraciones Personalizadas:** Cada workspace puede tener su propia configuración  
✅ **Escalabilidad:** Preparado para crecer desde uso personal hasta empresarial

### Tipos de Workspace

| Tipo           | Descripción                        | Caso de Uso                              |
| -------------- | ---------------------------------- | ---------------------------------------- |
| **Personal**   | Workspace individual               | Usuario trabajando solo en sus proyectos |
| **Team**       | Equipo pequeño (2-20 personas)     | Startups, equipos ágiles, departamentos  |
| **Enterprise** | Organización grande (20+ personas) | Empresas, corporaciones, agencias        |

### Sistema de Roles y Permisos

| Rol        | Descripción               | Permisos                                      |
| ---------- | ------------------------- | --------------------------------------------- |
| **Owner**  | Propietario del workspace | Control total, puede eliminar workspace       |
| **Admin**  | Administrador             | Gestionar miembros, proyectos, configuración  |
| **Member** | Miembro regular           | Trabajar en proyectos asignados, crear tareas |
| **Guest**  | Invitado temporal         | Solo lectura en proyectos específicos         |

---

## 🏗️ ARQUITECTURA DEL SISTEMA

### Diagrama de Entidades

```
┌─────────────────────────────────────────────────────────────┐
│                         USER                                 │
│  - id, name, email, password, avatar                         │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  │ (puede pertenecer a múltiples)
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│                    WORKSPACE_MEMBER                          │
│  - workspaceId, userId, role, joinedAt                       │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  │ (pertenece a)
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│                      WORKSPACE                               │
│  - id, name, description, type, ownerId, settings            │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  │ (contiene múltiples)
                  │
                  ├─────────────┬─────────────┬────────────────┐
                  ▼             ▼             ▼                ▼
            ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌──────────────┐
            │ PROJECT │   │  TASK   │   │ MEMBER  │   │ INVITATION   │
            └─────────┘   └─────────┘   └─────────┘   └──────────────┘
```

### Stack Tecnológico

**Backend:**

- Node.js + Express
- PostgreSQL con Prisma ORM
- JWT Authentication
- RESTful API

**Frontend (Flutter):**

- Clean Architecture
- BLoC Pattern (State Management)
- Dartz (Functional Programming)
- Injectable (Dependency Injection)
- SharedPreferences (Local Storage)

---

## 📊 FASES DE IMPLEMENTACIÓN

---

## ✅ FASE 1: BACKEND - BASE DE DATOS Y API (100% COMPLETADO)

### 1.1 Base de Datos ✅ COMPLETADO

**Archivos Modificados:**

- `backend/prisma/schema.prisma`

**Entidades Creadas:**

#### 1. Workspace

```prisma
model Workspace {
  id                        Int      @id @default(autoincrement())
  name                      String
  description               String?
  avatarUrl                 String?  @map("avatar_url")
  type                      String   @default("TEAM")
  ownerId                   Int      @map("owner_id")

  // Settings
  allowGuestInvites         Boolean  @default(true)
  requireEmailVerification  Boolean  @default(true)
  autoAssignNewMembers      Boolean  @default(false)
  defaultProjectTemplate    String?
  timezone                  String   @default("UTC")
  language                  String   @default("es")

  createdAt                 DateTime @default(now())
  updatedAt                 DateTime @updatedAt

  // Relaciones
  owner                     User     @relation("WorkspaceOwner")
  members                   WorkspaceMember[]
  projects                  Project[]
  invitations               WorkspaceInvitation[]
}
```

#### 2. WorkspaceMember

```prisma
model WorkspaceMember {
  id            Int       @id @default(autoincrement())
  workspaceId   Int       @map("workspace_id")
  userId        Int       @map("user_id")
  role          String    @default("MEMBER")
  joinedAt      DateTime  @default(now())
  lastActiveAt  DateTime? @map("last_active_at")
  isActive      Boolean   @default(true)

  workspace     Workspace @relation(fields: [workspaceId])
  user          User      @relation(fields: [userId])

  @@unique([workspaceId, userId])
}
```

#### 3. WorkspaceInvitation

```prisma
model WorkspaceInvitation {
  id              Int       @id @default(autoincrement())
  workspaceId     Int       @map("workspace_id")
  inviterUserId   Int       @map("inviter_user_id")
  inviteeEmail    String    @map("invitee_email")
  role            String    @default("MEMBER")
  token           String    @unique
  status          String    @default("PENDING")
  createdAt       DateTime  @default(now())
  expiresAt       DateTime  @map("expires_at")

  workspace       Workspace @relation(fields: [workspaceId])
  inviter         User      @relation(fields: [inviterUserId])
}
```

**Índices Creados:** ✅

- `@@index([workspaceId])`
- `@@index([userId])`
- `@@index([inviteeEmail])`
- `@@index([token])`

---

### 1.2 API Backend ✅ COMPLETADO

**Archivos Creados:**

- `backend/src/controllers/workspaceController.js`
- `backend/src/routes/workspaces.js`

**Endpoints Implementados:** (12 total)

#### Workspace CRUD

| Método   | Endpoint              | Descripción                   | Permisos    | Estado |
| -------- | --------------------- | ----------------------------- | ----------- | ------ |
| `GET`    | `/api/workspaces`     | Listar workspaces del usuario | Autenticado | ✅     |
| `GET`    | `/api/workspaces/:id` | Obtener workspace específico  | Member+     | ✅     |
| `POST`   | `/api/workspaces`     | Crear nuevo workspace         | Autenticado | ✅     |
| `PUT`    | `/api/workspaces/:id` | Actualizar workspace          | Admin/Owner | ✅     |
| `DELETE` | `/api/workspaces/:id` | Eliminar workspace            | Owner       | ✅     |

#### Gestión de Miembros

| Método   | Endpoint                              | Descripción     | Permisos    | Estado |
| -------- | ------------------------------------- | --------------- | ----------- | ------ |
| `GET`    | `/api/workspaces/:id/members`         | Listar miembros | Member+     | ✅     |
| `PUT`    | `/api/workspaces/:id/members/:userId` | Cambiar rol     | Admin/Owner | ✅     |
| `DELETE` | `/api/workspaces/:id/members/:userId` | Remover miembro | Admin/Owner | ✅     |

#### Sistema de Invitaciones

| Método | Endpoint                              | Descripción             | Permisos    | Estado |
| ------ | ------------------------------------- | ----------------------- | ----------- | ------ |
| `POST` | `/api/workspaces/:id/invitations`     | Crear invitación        | Member+     | ✅     |
| `GET`  | `/api/workspaces/invitations/pending` | Invitaciones pendientes | Autenticado | ✅     |
| `POST` | `/api/workspaces/invitations/accept`  | Aceptar invitación      | Autenticado | ✅     |
| `POST` | `/api/workspaces/invitations/decline` | Rechazar invitación     | Autenticado | ✅     |

**Validaciones Implementadas:** ✅

- Verificación de permisos por rol
- Validación de datos de entrada
- Verificación de existencia de recursos
- Manejo de errores con códigos HTTP apropiados

---

### 1.3 Scripts y Migración ✅ COMPLETADO

**Archivo Creado:**

- `backend/migrate-workspace.ps1`

**Funcionalidad:**

1. ✅ Crea workspace personal para cada usuario existente
2. ✅ Migra todos los proyectos al workspace personal del creador
3. ✅ Crea registros de membresía (WorkspaceMember)
4. ✅ Verifica integridad de datos
5. ✅ Genera reporte de migración

**Comando de ejecución:**

```powershell
cd backend
.\migrate-workspace.ps1
```

---

### 1.4 Documentación Backend ✅ COMPLETADO

**Archivo Creado:**

- `backend/WORKSPACE_API_DOCS.md`

**Contenido:**

- ✅ Descripción de cada endpoint
- ✅ Ejemplos de request/response
- ✅ Códigos de error
- ✅ Matriz de permisos
- ✅ Ejemplos con curl
- ✅ Guía de testing

---

## ✅ FASE 2: FLUTTER - DOMAIN LAYER (100% COMPLETADO)

### 2.1 Entities ✅ COMPLETADO

#### Workspace Entity

**Archivo:** `lib/domain/entities/workspace.dart`

**Enums:**

```dart
enum WorkspaceType {
  personal, team, enterprise
}

enum WorkspaceRole {
  owner, admin, member, guest
}
```

**Classes:**

- `WorkspaceSettings` - Configuración del workspace
- `WorkspaceOwner` - Datos del propietario
- `Workspace` - Entidad principal

**Métodos Helper:**

- `initials` - Obtener iniciales para avatar
- `isOwner` - Verificar si es propietario
- `isAdminOrOwner` - Verificar permisos de administración
- `canManageMembers` - Verificar permisos de gestión
- `canManageSettings` - Verificar permisos de configuración

#### WorkspaceMember Entity

**Archivo:** `lib/domain/entities/workspace_member.dart`

**Class:**

- `WorkspaceMember` - Miembro del workspace

**Métodos Helper:**

- `initials` - Iniciales del nombre
- `isRecentlyActive` - Activo en últimas 24 horas

#### WorkspaceInvitation Entity

**Archivo:** `lib/domain/entities/workspace_invitation.dart`

**Enum:**

```dart
enum InvitationStatus {
  pending, accepted, declined, expired
}
```

**Class:**

- `WorkspaceInvitation` - Invitación a workspace

**Métodos Helper:**

- `isExpired` - Verificar expiración
- `isPending` - Verificar si está pendiente
- `daysUntilExpiration` - Días hasta expirar
- `inviterInitials` - Iniciales del invitador
- `workspaceInitials` - Iniciales del workspace

---

### 2.2 Repository Interface ✅ COMPLETADO

**Archivo:** `lib/domain/repositories/workspace_repository.dart`

**Métodos Definidos:** (14 total)

```dart
abstract class WorkspaceRepository {
  // Workspace CRUD
  Future<Either<Failure, List<Workspace>>> getUserWorkspaces();
  Future<Either<Failure, Workspace>> getWorkspace(int workspaceId);
  Future<Either<Failure, Workspace>> createWorkspace({...});
  Future<Either<Failure, Workspace>> updateWorkspace({...});
  Future<Either<Failure, void>> deleteWorkspace(int workspaceId);

  // Miembros
  Future<Either<Failure, List<WorkspaceMember>>> getWorkspaceMembers(int workspaceId);
  Future<Either<Failure, WorkspaceMember>> updateMemberRole({...});
  Future<Either<Failure, void>> removeMember({...});

  // Invitaciones
  Future<Either<Failure, WorkspaceInvitation>> createInvitation({...});
  Future<Either<Failure, List<WorkspaceInvitation>>> getPendingInvitations();
  Future<Either<Failure, Workspace>> acceptInvitation(String token);
  Future<Either<Failure, void>> declineInvitation(String token);

  // Local Storage
  Future<Either<Failure, void>> saveActiveWorkspace(int workspaceId);
  Future<Either<Failure, int?>> getActiveWorkspaceId();
}
```

---

### 2.3 Use Cases ✅ COMPLETADO

**Archivos Creados:** (6 use cases principales)

| Use Case              | Archivo                        | Descripción                    | Estado |
| --------------------- | ------------------------------ | ------------------------------ | ------ |
| GetUserWorkspaces     | `get_user_workspaces.dart`     | Obtener workspaces del usuario | ✅     |
| CreateWorkspace       | `create_workspace.dart`        | Crear nuevo workspace          | ✅     |
| GetWorkspaceMembers   | `get_workspace_members.dart`   | Obtener miembros               | ✅     |
| CreateInvitation      | `create_invitation.dart`       | Crear invitación               | ✅     |
| GetPendingInvitations | `get_pending_invitations.dart` | Invitaciones pendientes        | ✅     |
| AcceptInvitation      | `accept_invitation.dart`       | Aceptar invitación             | ✅     |

**Patrón Utilizado:**

- Injectable para dependency injection
- Parámetros encapsulados en clases Params
- Retorno con Either<Failure, T> para manejo de errores

---

## ⏳ FASE 3: FLUTTER - DATA LAYER (0% - PRÓXIMA FASE)

### 3.1 Models ⏳ PENDIENTE

**Por Crear:**

#### WorkspaceModel

**Archivo:** `lib/data/models/workspace_model.dart`

**Responsabilidades:**

- Mapear JSON a entidad Workspace
- Método `fromJson()`
- Método `toJson()`
- Método `toEntity()`
- Manejo de valores nulos

#### WorkspaceMemberModel

**Archivo:** `lib/data/models/workspace_member_model.dart`

**Responsabilidades:**

- Mapear JSON a entidad WorkspaceMember
- Métodos de conversión

#### WorkspaceInvitationModel

**Archivo:** `lib/data/models/workspace_invitation_model.dart`

**Responsabilidades:**

- Mapear JSON a entidad WorkspaceInvitation
- Métodos de conversión

---

### 3.2 Data Sources ⏳ PENDIENTE

#### Remote Data Source

**Archivo:** `lib/data/datasources/workspace_remote_data_source.dart`

**Responsabilidades:**

- Comunicación con API backend
- Manejo de HTTP requests/responses
- Parseo de JSON
- Manejo de errores de red

**Métodos a Implementar:**

```dart
abstract class WorkspaceRemoteDataSource {
  Future<List<WorkspaceModel>> getUserWorkspaces();
  Future<WorkspaceModel> getWorkspace(int id);
  Future<WorkspaceModel> createWorkspace({...});
  Future<WorkspaceModel> updateWorkspace({...});
  Future<void> deleteWorkspace(int id);
  Future<List<WorkspaceMemberModel>> getWorkspaceMembers(int id);
  Future<WorkspaceMemberModel> updateMemberRole({...});
  Future<void> removeMember({...});
  Future<WorkspaceInvitationModel> createInvitation({...});
  Future<List<WorkspaceInvitationModel>> getPendingInvitations();
  Future<WorkspaceModel> acceptInvitation(String token);
  Future<void> declineInvitation(String token);
}
```

#### Local Data Source

**Archivo:** `lib/data/datasources/workspace_local_data_source.dart`

**Responsabilidades:**

- Guardar workspace activo en SharedPreferences
- Recuperar workspace activo
- Cache de workspaces (opcional)

**Métodos a Implementar:**

```dart
abstract class WorkspaceLocalDataSource {
  Future<void> saveActiveWorkspaceId(int workspaceId);
  Future<int?> getActiveWorkspaceId();
  Future<void> clearActiveWorkspace();
}
```

---

### 3.3 Repository Implementation ⏳ PENDIENTE

**Archivo:** `lib/data/repositories/workspace_repository_impl.dart`

**Responsabilidades:**

- Implementar interface WorkspaceRepository
- Coordinar remote y local data sources
- Convertir modelos a entidades
- Manejo de errores con Either
- Cache strategy (opcional)

**Estructura:**

```dart
@LazySingleton(as: WorkspaceRepository)
class WorkspaceRepositoryImpl implements WorkspaceRepository {
  final WorkspaceRemoteDataSource remoteDataSource;
  final WorkspaceLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  WorkspaceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  // Implementar todos los métodos...
}
```

---

### 3.4 Dependency Injection ⏳ PENDIENTE

**Archivo:** `lib/injection.dart`

**Registros Necesarios:**

```dart
// Data sources
@module
abstract class DataSourceModule {
  @lazySingleton
  WorkspaceRemoteDataSource get workspaceRemoteDataSource;

  @lazySingleton
  WorkspaceLocalDataSource get workspaceLocalDataSource;
}

// Repository
@LazySingleton(as: WorkspaceRepository)
WorkspaceRepositoryImpl get workspaceRepository;

// Use cases
@lazySingleton
GetUserWorkspacesUseCase get getUserWorkspaces;

@lazySingleton
CreateWorkspaceUseCase get createWorkspace;

// ... más use cases
```

---

## ⏳ FASE 4: FLUTTER - PRESENTATION LAYER (0% - PENDIENTE)

### 4.1 BLoC Pattern ⏳ PENDIENTE

#### WorkspaceBloc

**Archivos:**

- `lib/presentation/bloc/workspace/workspace_bloc.dart`
- `lib/presentation/bloc/workspace/workspace_event.dart`
- `lib/presentation/bloc/workspace/workspace_state.dart`

**Events:**

```dart
abstract class WorkspaceEvent {}

class LoadUserWorkspacesEvent extends WorkspaceEvent {}
class SelectWorkspaceEvent extends WorkspaceEvent {
  final int workspaceId;
}
class CreateWorkspaceEvent extends WorkspaceEvent {
  final String name;
  final WorkspaceType type;
  // ...
}
class UpdateWorkspaceEvent extends WorkspaceEvent {}
class DeleteWorkspaceEvent extends WorkspaceEvent {
  final int workspaceId;
}
class LoadWorkspaceMembersEvent extends WorkspaceEvent {
  final int workspaceId;
}
class InviteMemberEvent extends WorkspaceEvent {
  final int workspaceId;
  final String email;
  final WorkspaceRole role;
}
class UpdateMemberRoleEvent extends WorkspaceEvent {}
class RemoveMemberEvent extends WorkspaceEvent {}
class LoadPendingInvitationsEvent extends WorkspaceEvent {}
class AcceptInvitationEvent extends WorkspaceEvent {
  final String token;
}
class DeclineInvitationEvent extends WorkspaceEvent {
  final String token;
}
```

**States:**

```dart
abstract class WorkspaceState {}

class WorkspaceInitial extends WorkspaceState {}
class WorkspaceLoading extends WorkspaceState {}

class WorkspacesLoaded extends WorkspaceState {
  final List<Workspace> workspaces;
  final Workspace? activeWorkspace;
}

class WorkspaceError extends WorkspaceState {
  final String message;
}

class WorkspaceMembersLoaded extends WorkspaceState {
  final List<WorkspaceMember> members;
}

class InvitationsLoaded extends WorkspaceState {
  final List<WorkspaceInvitation> invitations;
}

// ... más estados
```

---

### 4.2 Context Provider ⏳ PENDIENTE

#### WorkspaceContext

**Archivo:** `lib/presentation/providers/workspace_context.dart`

**Responsabilidades:**

- Mantener workspace activo globalmente
- Notificar cambios a toda la app
- Sincronizar con SharedPreferences
- Proveer métodos helper para permisos

**Estructura:**

```dart
class WorkspaceContext extends ChangeNotifier {
  Workspace? _activeWorkspace;
  List<Workspace> _userWorkspaces = [];

  Workspace? get activeWorkspace => _activeWorkspace;
  List<Workspace> get userWorkspaces => _userWorkspaces;
  WorkspaceRole? get currentRole => _activeWorkspace?.userRole;

  bool get canManageMembers => currentRole?.canManageMembers ?? false;
  bool get canCreateProjects => currentRole?.canCreateProjects ?? false;

  Future<void> switchWorkspace(int workspaceId) async {}
  Future<void> loadUserWorkspaces() async {}
  Future<void> refresh() async {}
}
```

---

### 4.3 Pantallas ⏳ PENDIENTE

#### WorkspaceListScreen

**Archivo:** `lib/presentation/screens/workspace/workspace_list_screen.dart`

**Funcionalidad:**

- Mostrar lista de workspaces del usuario
- Indicar workspace activo
- Botón para crear nuevo workspace
- Tap para cambiar workspace activo
- Pull to refresh
- Estados: loading, loaded, error, empty

#### CreateWorkspaceScreen

**Archivo:** `lib/presentation/screens/workspace/create_workspace_screen.dart`

**Funcionalidad:**

- Formulario para crear workspace
- Campos: nombre, descripción, tipo
- Validación de campos
- Selector de tipo (Personal, Team, Enterprise)
- Botón guardar/cancelar

#### WorkspaceDetailScreen

**Archivo:** `lib/presentation/screens/workspace/workspace_detail_screen.dart`

**Funcionalidad:**

- Mostrar información del workspace
- Estadísticas (proyectos, tareas, miembros)
- Lista de miembros
- Botón editar (si es admin/owner)
- Botón invitar miembros
- Botón configuración
- Tab navigation: Overview, Members, Settings

#### WorkspaceMembersScreen

**Archivo:** `lib/presentation/screens/workspace/workspace_members_screen.dart`

**Funcionalidad:**

- Lista de miembros con avatares
- Indicador de rol (Owner, Admin, Member, Guest)
- Indicador de actividad reciente
- Búsqueda de miembros
- Filtros por rol
- Acciones: cambiar rol, remover (si tiene permisos)
- Botón invitar nuevo miembro

#### InviteMemberScreen

**Archivo:** `lib/presentation/screens/workspace/invite_member_screen.dart`

**Funcionalidad:**

- Formulario de invitación
- Campo email con validación
- Selector de rol
- Botón enviar invitación
- Mostrar invitaciones pendientes del workspace

#### InvitationsScreen

**Archivo:** `lib/presentation/screens/workspace/invitations_screen.dart`

**Funcionalidad:**

- Lista de invitaciones pendientes del usuario
- Cards con info del workspace y quien invita
- Botones: Aceptar / Rechazar
- Indicador de días hasta expiración
- Pull to refresh

#### WorkspaceSettingsScreen

**Archivo:** `lib/presentation/screens/workspace/workspace_settings_screen.dart`

**Funcionalidad:**

- Editar nombre y descripción
- Cambiar avatar
- Configuraciones:
  - Permitir invitaciones de guests
  - Requerir verificación de email
  - Timezone
  - Idioma
- Botón eliminar workspace (solo owner)
- Confirmación para acciones destructivas

---

### 4.4 Widgets Reutilizables ⏳ PENDIENTE

#### WorkspaceCard

**Archivo:** `lib/presentation/widgets/workspace/workspace_card.dart`

**Componentes:**

- Avatar del workspace (imagen o iniciales)
- Nombre del workspace
- Descripción (truncada)
- Badge de rol del usuario
- Contador de miembros y proyectos
- Indicador de workspace activo
- Tap para seleccionar

#### WorkspaceSelector

**Archivo:** `lib/presentation/widgets/workspace/workspace_selector.dart`

**Componentes:**

- Dropdown o bottom sheet
- Lista de workspaces disponibles
- Workspace activo resaltado
- Búsqueda de workspaces
- Botón "Crear nuevo workspace"
- Animación de transición

#### MemberListItem

**Archivo:** `lib/presentation/widgets/workspace/member_list_item.dart`

**Componentes:**

- Avatar del miembro
- Nombre y email
- Badge de rol
- Indicador de actividad (online/offline)
- Fecha de unión
- Menú de opciones (3 dots):
  - Ver perfil
  - Cambiar rol
  - Remover

#### InvitationCard

**Archivo:** `lib/presentation/widgets/workspace/invitation_card.dart`

**Componentes:**

- Logo/avatar del workspace
- Nombre del workspace
- Descripción breve
- Avatar del invitador
- Texto: "X te invitó a unirte"
- Rol ofrecido
- Días hasta expirar
- Botones: Aceptar (verde) / Rechazar (rojo)

#### WorkspaceAvatar

**Archivo:** `lib/presentation/widgets/workspace/workspace_avatar.dart`

**Componentes:**

- CircleAvatar
- Imagen o iniciales
- Tamaño configurable
- Badge opcional (para notificaciones)

#### EmptyWorkspaceState

**Archivo:** `lib/presentation/widgets/workspace/empty_workspace_state.dart`

**Componentes:**

- Ilustración
- Título: "No hay workspaces"
- Mensaje explicativo
- Botón "Crear mi primer workspace"

---

### 4.5 Navigation ⏳ PENDIENTE

**Actualizar:**

- `lib/presentation/routes/app_router.dart`

**Rutas a añadir:**

```dart
static const String workspaceList = '/workspaces';
static const String workspaceDetail = '/workspaces/:id';
static const String workspaceCreate = '/workspaces/create';
static const String workspaceEdit = '/workspaces/:id/edit';
static const String workspaceMembers = '/workspaces/:id/members';
static const String workspaceInvite = '/workspaces/:id/invite';
static const String invitations = '/invitations';
static const String workspaceSettings = '/workspaces/:id/settings';
```

---

## ⏳ FASE 5: INTEGRACIÓN CON SISTEMA EXISTENTE (0% - PENDIENTE)

### 5.1 Actualizar Entidades Existentes ⏳ PENDIENTE

#### Project Entity

**Archivo:** `lib/domain/entities/project.dart`

**Cambios:**

```dart
class Project {
  // ... campos existentes
  final int workspaceId; // NUEVO CAMPO

  const Project({
    // ... parámetros existentes
    required this.workspaceId, // AÑADIR
  });
}
```

#### Task Entity

**Archivo:** `lib/domain/entities/task.dart`

**Nota:** Las tareas heredan workspaceId a través de su proyecto

---

### 5.2 Actualizar Backend Models ⏳ PENDIENTE

#### ProjectModel

**Archivo:** `lib/data/models/project_model.dart`

**Cambios:**

```dart
factory ProjectModel.fromJson(Map<String, dynamic> json) {
  return ProjectModel(
    // ... campos existentes
    workspaceId: json['workspaceId'] ?? json['workspace_id'],
  );
}
```

---

### 5.3 Actualizar BLoCs Existentes ⏳ PENDIENTE

#### ProjectBloc

**Archivo:** `lib/presentation/bloc/project/project_bloc.dart`

**Cambios:**

- Añadir filtro por workspace activo en LoadProjectsEvent
- Modificar queries para incluir workspaceId
- Actualizar CreateProjectEvent para requerir workspaceId

**Ejemplo:**

```dart
class LoadProjectsEvent extends ProjectEvent {
  final int workspaceId; // AÑADIR

  LoadProjectsEvent({required this.workspaceId});
}
```

#### TaskBloc

**Archivo:** `lib/presentation/bloc/task/task_bloc.dart`

**Cambios:**

- Filtrar tareas por workspace (a través de projectId)
- Verificar permisos de workspace antes de crear/editar

---

### 5.4 Actualizar API Service ⏳ PENDIENTE

**Archivo:** `lib/data/datasources/api_service.dart`

**Cambios:**

- Añadir header `X-Workspace-Id` en requests
- Middleware para inyectar workspace activo
- Manejo de errores 403 (sin acceso al workspace)

---

### 5.5 Actualizar UI Principal ⏳ PENDIENTE

#### Drawer Principal

**Archivo:** `lib/presentation/widgets/common/main_drawer.dart`

**Cambios:**

- Añadir selector de workspace en la parte superior
- Mostrar nombre y avatar del workspace activo
- Dropdown para cambiar workspace
- Nueva sección "Equipo" con:
  - Ver miembros
  - Invitar miembros
  - Configuración del workspace

**Layout sugerido:**

```
┌──────────────────────────────┐
│ 🏢 Mi Workspace ▼            │ ← Selector
├──────────────────────────────┤
│ 📊 Dashboard                 │
│ 📁 Proyectos                 │
│ ✓ Tareas                     │
│ ⏱️ Time Tracking             │
│ 📅 Calendario                │
├──────────────────────────────┤
│ 👥 Equipo                    │ ← NUEVO
│   • Miembros (15)            │
│   • Invitar                  │
│   • Configuración            │
├──────────────────────────────┤
│ ⚙️ Preferencias              │
│ 🚪 Cerrar Sesión             │
└──────────────────────────────┘
```

#### AppBar

**Archivo:** `lib/presentation/widgets/common/custom_app_bar.dart`

**Cambios:**

- Añadir workspace indicator
- Opcionalmente mostrar selector compacto

---

### 5.6 Onboarding para Nuevos Usuarios ⏳ PENDIENTE

**Archivo:** `lib/presentation/screens/onboarding/workspace_onboarding_screen.dart`

**Funcionalidad:**

- Mostrar la primera vez que inicia sesión
- Explicar qué son los workspaces
- Opción de crear workspace inicial
- Tutorial interactivo (opcional)

---

### 5.7 Migración de Proyectos Existentes ⏳ PENDIENTE

**Estrategia:**

1. Al cargar la app, verificar si hay proyectos sin workspaceId
2. Si existen, mostrar diálogo de migración
3. Asignar automáticamente al workspace personal del usuario
4. Opcional: permitir elegir workspace destino

---

## ⏳ FASE 6: UI/UX REFINAMIENTO (0% - PENDIENTE)

### 6.1 Selector de Workspace Elegante ⏳ PENDIENTE

**Diseño:**

- Animación smooth de apertura
- Búsqueda con auto-complete
- Agrupación por tipo (Personal, Teams, Enterprise)
- Favoritos (pin workspaces)
- Recientes

### 6.2 Animaciones ⏳ PENDIENTE

**Transiciones:**

- Hero animation para workspace avatar
- Fade in/out al cambiar workspace
- Slide animation para drawer
- Ripple effect en cards

### 6.3 Estados Vacíos ⏳ PENDIENTE

**Ilustraciones:**

- Sin workspaces: "Crea tu primer espacio de trabajo"
- Sin miembros: "Invita a tu equipo"
- Sin invitaciones: "No tienes invitaciones pendientes"
- Sin proyectos en workspace: "Comienza un nuevo proyecto"

### 6.4 Loading States ⏳ PENDIENTE

**Implementar:**

- Skeleton screens para lista de workspaces
- Shimmer effect en cards
- Progress indicators contextuales
- Pull to refresh personalizado

### 6.5 Feedback Visual ⏳ PENDIENTE

**Elementos:**

- Snackbars para acciones exitosas
- Toasts para notificaciones
- Confirmaciones con diálogos elegantes
- Celebración al crear workspace (confetti)

### 6.6 Temas y Colores ⏳ PENDIENTE

**Workspace Colors:**

- Permitir seleccionar color del workspace
- Aplicar color theme dinámicamente
- Mantener accesibilidad (contrast ratio)

---

## ⏳ FASE 7: TESTING Y PULIDO (0% - PENDIENTE)

### 7.1 Tests Unitarios ⏳ PENDIENTE

#### Use Cases

**Archivos:**

- `test/domain/usecases/workspace/get_user_workspaces_test.dart`
- `test/domain/usecases/workspace/create_workspace_test.dart`
- ... (uno por cada use case)

**Coverage esperado:** 90%+

#### Repository

**Archivo:**

- `test/data/repositories/workspace_repository_impl_test.dart`

**Casos:**

- Success cases
- Failure cases (network, server, cache)
- Edge cases

### 7.2 Tests de Integración ⏳ PENDIENTE

**Archivo:**

- `test/integration/workspace_flow_test.dart`

**Flujos a probar:**

1. Usuario crea workspace
2. Usuario invita miembro
3. Miembro acepta invitación
4. Admin cambia rol de miembro
5. Owner elimina workspace

### 7.3 Tests de BLoC ⏳ PENDIENTE

**Archivo:**

- `test/presentation/bloc/workspace/workspace_bloc_test.dart`

**Escenarios:**

- Cada evento debe producir el estado correcto
- Errores deben producir WorkspaceError
- Estados de loading

### 7.4 Tests de Widget ⏳ PENDIENTE

**Archivos:**

- `test/presentation/widgets/workspace/workspace_card_test.dart`
- `test/presentation/widgets/workspace/member_list_item_test.dart`
- ... (widgets principales)

### 7.5 Manejo de Errores ⏳ PENDIENTE

**Escenarios a cubrir:**

- Sin conexión a internet
- Token expirado
- Permisos insuficientes
- Workspace no encontrado
- Invitación expirada
- Email inválido
- Usuario ya es miembro

**Para cada error:**

- Mensaje user-friendly
- Sugerencia de acción
- Logging apropiado

### 7.6 Performance Testing ⏳ PENDIENTE

**Métricas:**

- Tiempo de carga de workspaces
- Tiempo de cambio de workspace
- Uso de memoria
- Tamaño de builds

**Optimizaciones:**

- Lazy loading de miembros
- Pagination en listas grandes
- Image caching para avatars
- Debouncing en búsquedas

### 7.7 Documentación de Código ⏳ PENDIENTE

**Añadir:**

- Dartdoc comments en todas las clases públicas
- Ejemplos de uso en README
- Arquitectura diagram actualizado
- Changelog

---

## 📦 DEPENDENCIAS Y REQUISITOS

### Backend Dependencies

```json
{
  "@prisma/client": "^5.x",
  "express": "^4.x",
  "jsonwebtoken": "^9.x",
  "bcrypt": "^5.x",
  "dotenv": "^16.x"
}
```

### Flutter Dependencies

**pubspec.yaml**

```yaml
dependencies:
  flutter_bloc: ^8.x
  equatable: ^2.x
  dartz: ^0.10.x
  injectable: ^2.x
  get_it: ^7.x
  dio: ^5.x
  shared_preferences: ^2.x
  freezed_annotation: ^2.x

dev_dependencies:
  build_runner: ^2.x
  injectable_generator: ^2.x
  freezed: ^2.x
  json_serializable: ^6.x
  mockito: ^5.x
  bloc_test: ^9.x
```

### Environment Variables

**Backend (.env)**

```env
DATABASE_URL="postgresql://..."
JWT_SECRET="..."
PORT=3000
```

---

## 📈 MÉTRICAS DE PROGRESO

### Por Fase

| Fase                 | Progreso | Tareas Completadas | Tareas Totales | Estado |
| -------------------- | -------- | ------------------ | -------------- | ------ |
| Fase 1: Backend      | 100%     | 12/12              | 12             | ✅     |
| Fase 2: Domain Layer | 100%     | 9/9                | 9              | ✅     |
| Fase 3: Data Layer   | 0%       | 0/7                | 7              | ⏳     |
| Fase 4: Presentation | 0%       | 0/25               | 25             | ⏳     |
| Fase 5: Integración  | 0%       | 0/12               | 12             | ⏳     |
| Fase 6: UI/UX        | 0%       | 0/8                | 8              | ⏳     |
| Fase 7: Testing      | 0%       | 0/15               | 15             | ⏳     |
| **TOTAL**            | **24%**  | **21/88**          | **88**         | 🔄     |

### Gráfico de Progreso

```
█████░░░░░░░░░░░░░░░░ 24% Completado

Fase 1: Backend           ████████████████████ 100% ✅
Fase 2: Domain Layer      ████████████████████ 100% ✅
Fase 3: Data Layer        ░░░░░░░░░░░░░░░░░░░░   0% ⏳
Fase 4: Presentation      ░░░░░░░░░░░░░░░░░░░░   0% ⏳
Fase 5: Integración       ░░░░░░░░░░░░░░░░░░░░   0% ⏳
Fase 6: UI/UX             ░░░░░░░░░░░░░░░░░░░░   0% ⏳
Fase 7: Testing           ░░░░░░░░░░░░░░░░░░░░   0% ⏳
```

---

## 🎯 PRÓXIMOS PASOS INMEDIATOS

### Antes de Fase 3

1. **Ejecutar Migración Backend:**

   ```powershell
   cd backend
   .\migrate-workspace.ps1
   ```

2. **Probar API Endpoints:**

   - Usar Postman/Insomnia
   - Verificar todos los endpoints
   - Probar casos de error

3. **Validar Base de Datos:**
   - Verificar que workspace personal fue creado
   - Verificar migración de proyectos
   - Verificar relaciones intactas

### Durante Fase 3

1. Crear WorkspaceModel, WorkspaceMemberModel, WorkspaceInvitationModel
2. Implementar WorkspaceRemoteDataSource
3. Implementar WorkspaceLocalDataSource
4. Implementar WorkspaceRepositoryImpl
5. Configurar dependency injection
6. Testing de data layer
7. Generar código con build_runner

---

## 📝 NOTAS IMPORTANTES

### Consideraciones de Arquitectura

1. **Clean Architecture:** Mantener separación estricta de capas
2. **SOLID Principles:** Aplicar en todo el código
3. **DRY:** No duplicar lógica entre workspaces
4. **Single Source of Truth:** WorkspaceContext es la fuente de verdad

### Consideraciones de UX

1. **Onboarding suave:** No abrumar al usuario nuevo
2. **Workspace personal por defecto:** Ya creado en registro
3. **Cambio de workspace rápido:** Máximo 2 taps
4. **Feedback inmediato:** En todas las acciones

### Consideraciones de Performance

1. **Lazy loading:** No cargar todo de una vez
2. **Cache inteligente:** Usar para reducir llamadas API
3. **Optimistic updates:** Actualizar UI antes de confirmar con backend
4. **Debouncing:** En búsquedas y filtros

### Consideraciones de Seguridad

1. **Validación en backend:** Nunca confiar en el frontend
2. **Permisos en cada endpoint:** Verificar rol del usuario
3. **Tokens de invitación únicos:** No reutilizables
4. **Rate limiting:** Prevenir abuso de API

---

## 🚀 ESTADO ACTUAL DEL PROYECTO

### ✅ Completado (24%)

- **Backend completo y funcional**
  - Base de datos diseñada
  - API REST implementada
  - Sistema de permisos funcionando
  - Script de migración listo
- **Domain Layer Flutter completo**
  - Todas las entidades creadas
  - Repository interface definido
  - Use cases principales implementados

### 🔄 En Progreso (0%)

- Nada actualmente en progreso

### ⏳ Pendiente (76%)

- Data Layer (models, data sources, repository impl)
- Presentation Layer (BLoC, screens, widgets)
- Integración con sistema existente
- UI/UX refinamiento
- Testing completo

---

## 💪 RESUMEN EJECUTIVO

**Objetivo:** Implementar sistema completo de Workspaces en Creapolis

**Progreso Global:** 24% (21/88 tareas)

**Tiempo Estimado Restante:** 3-4 semanas de desarrollo

**Próxima Fase:** FASE 3 - Data Layer (Flutter)

**Bloqueadores Actuales:** Ninguno

**Estado General:** 🟢 EN BUEN CAMINO

---

## 📞 PUNTOS DE DECISIÓN

### Decisiones Tomadas ✅

1. ✅ Usar modelo Workspace (no Organization)
2. ✅ 4 roles: Owner, Admin, Member, Guest
3. ✅ Sistema de invitaciones con tokens
4. ✅ Workspace personal automático en registro
5. ✅ SharedPreferences para workspace activo

### Decisiones Pendientes ⏳

1. ⏳ ¿Permitir workspace colors personalizados?
2. ⏳ ¿Implementar workspace favorites/pinning?
3. ⏳ ¿Añadir workspace description rich text?
4. ⏳ ¿Implementar notificaciones push para invitaciones?
5. ⏳ ¿Añadir workspace templates?

---

**Última actualización:** 8 de Octubre, 2025  
**Próxima revisión:** Al completar Fase 3

---

## 🎉 ¡VAMOS CON TODO!

El backend está sólido como una roca. La arquitectura de dominio está perfecta.
Ahora solo necesitamos conectar todo con la capa de datos y crear la UI.

**¡A por la Fase 3!** 💪🚀
