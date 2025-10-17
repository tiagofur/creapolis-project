# Fase 2 - Diagrama Visual del Sistema

## 🏗️ Arquitectura Completa

```
┌─────────────────────────────────────────────────────────────────┐
│                         USUARIO FINAL                            │
│                    (Interactúa con la UI)                        │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                            │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │         ProjectMembersScreen (Pantalla)                   │   │
│  │  - Header con estadísticas                                │   │
│  │  - Lista de miembros                                      │   │
│  │  - Dialog para agregar                                    │   │
│  │  - Pull-to-refresh                                        │   │
│  └────────────┬───────────────────────────────────────────────┘  │
│               │                                                   │
│               ▼                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │           Widgets Especializados                          │   │
│  │  ┌─────────────────────────────────────────────────┐     │   │
│  │  │  ProjectMemberRoleBadge                         │     │   │
│  │  │  - Muestra rol con color e ícono                │     │   │
│  │  └─────────────────────────────────────────────────┘     │   │
│  │  ┌─────────────────────────────────────────────────┐     │   │
│  │  │  ProjectMemberRoleSelector                      │     │   │
│  │  │  - Dropdown con descripciones                   │     │   │
│  │  └─────────────────────────────────────────────────┘     │   │
│  │  ┌─────────────────────────────────────────────────┐     │   │
│  │  │  ProjectMemberTile                              │     │   │
│  │  │  - Avatar, nombre, email, rol                   │     │   │
│  │  │  - Acciones: cambiar rol, eliminar              │     │   │
│  │  └─────────────────────────────────────────────────┘     │   │
│  └────────────┬───────────────────────────────────────────────┘  │
│               │                                                   │
│               ▼                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │           ProjectMemberBloc (Estado)                      │   │
│  │                                                            │   │
│  │  Estados:                     Eventos:                    │   │
│  │  - Initial                    - LoadProjectMembers        │   │
│  │  - Loading                    - AddProjectMember          │   │
│  │  - Loaded                     - UpdateProjectMemberRole   │   │
│  │  - Error                      - RemoveProjectMember       │   │
│  │  - OperationSuccess           - RefreshProjectMembers     │   │
│  │  - OperationInProgress                                    │   │
│  └────────────┬───────────────────────────────────────────────┘  │
└───────────────┼──────────────────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                                │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │      ProjectMemberRepository (Interface)                  │   │
│  │  - getProjectMembers(projectId)                           │   │
│  │  - addMember(projectId, userId, role)                     │   │
│  │  - updateMemberRole(projectId, userId, role)              │   │
│  │  - removeMember(projectId, userId)                        │   │
│  └────────────┬───────────────────────────────────────────────┘  │
│               │                                                   │
│               │                                                   │
│  ┌────────────▼───────────────────────────────────────────────┐ │
│  │        ProjectMember (Entity)                              │ │
│  │  - id, userId, projectId                                   │ │
│  │  - userName, userEmail                                     │ │
│  │  - role (ProjectMemberRole enum)                           │ │
│  │  - joinedAt                                                │ │
│  │                                                             │ │
│  │  Helpers de permisos:                                      │ │
│  │  - isOwner, canManage, canEdit, isReadOnly                │ │
│  └─────────────────────────────────────────────────────────────┘│
└───────────────┼──────────────────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────────────────────┐
│                       DATA LAYER                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │   ProjectMemberRepositoryImpl (Implementación)            │   │
│  │  - Convierte Exceptions → Failures                        │   │
│  │  - Maneja: ServerException, NetworkException, AuthError   │   │
│  └────────────┬───────────────────────────────────────────────┘  │
│               │                                                   │
│               ▼                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │     ProjectMemberRemoteDataSource                         │   │
│  │  - Comunicación con API REST                              │   │
│  │  - Serialización JSON                                     │   │
│  │  - Logging de operaciones                                 │   │
│  └────────────┬───────────────────────────────────────────────┘  │
│               │                                                   │
│               │                                                   │
│  ┌────────────▼───────────────────────────────────────────────┐ │
│  │        ProjectMemberModel (DTO)                            │ │
│  │  - fromJson()                                              │ │
│  │  - toJson()                                                │ │
│  │  - fromEntity()                                            │ │
│  └─────────────────────────────────────────────────────────────┘│
└───────────────┼──────────────────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      NETWORK LAYER                               │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                    ApiClient                              │   │
│  │  - HTTP Client (Dio)                                      │   │
│  │  - Interceptors (Auth, Logging)                           │   │
│  └────────────┬───────────────────────────────────────────────┘  │
└───────────────┼──────────────────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      BACKEND API                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │         REST Endpoints (Express + Node.js)                │   │
│  │                                                            │   │
│  │  POST   /api/projects/:id/members                         │   │
│  │  PUT    /api/projects/:id/members/:userId/role  ⭐ NEW    │   │
│  │  DELETE /api/projects/:id/members/:userId                 │   │
│  │  GET    /api/projects/:id  (includes members)             │   │
│  └────────────┬───────────────────────────────────────────────┘  │
│               │                                                   │
│               ▼                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │             Controllers                                    │   │
│  │  - project.controller.js                                  │   │
│  │    ├─ addMember (updated)                                 │   │
│  │    └─ updateMemberRole (NEW)                              │   │
│  └────────────┬───────────────────────────────────────────────┘  │
│               │                                                   │
│               ▼                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              Validators                                    │   │
│  │  - addMemberValidation (updated)                          │   │
│  │  - updateMemberRoleValidation (NEW)                       │   │
│  └────────────┬───────────────────────────────────────────────┘  │
│               │                                                   │
│               ▼                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              Services                                      │   │
│  │  - project.service.js                                     │   │
│  │    ├─ createProject (assigns OWNER)                       │   │
│  │    ├─ addMember (with role)                               │   │
│  │    └─ updateMemberRole (NEW)                              │   │
│  └────────────┬───────────────────────────────────────────────┘  │
└───────────────┼──────────────────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DATABASE (PostgreSQL)                       │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              ProjectMember Table                          │   │
│  │  ┌────────────────────────────────────────────────┐       │   │
│  │  │  id          INTEGER PRIMARY KEY               │       │   │
│  │  │  projectId   INTEGER FOREIGN KEY               │       │   │
│  │  │  userId      INTEGER FOREIGN KEY               │       │   │
│  │  │  role        ProjectMemberRole (ENUM) ⭐ NEW    │       │   │
│  │  │              - OWNER                            │       │   │
│  │  │              - ADMIN                            │       │   │
│  │  │              - MEMBER                           │       │   │
│  │  │              - VIEWER                           │       │   │
│  │  │  joinedAt    TIMESTAMP                          │       │   │
│  │  │  createdAt   TIMESTAMP                          │       │   │
│  │  │  updatedAt   TIMESTAMP                          │       │   │
│  │  └────────────────────────────────────────────────┘       │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Flujo de Operaciones

### 1. Agregar Miembro con Rol

```
Usuario → Tap "Agregar Miembro" en ProjectMembersScreen
  ↓
Dialog muestra: TextField (userId) + Dropdown (role)
  ↓
Usuario selecciona: userId=123, role=ADMIN
  ↓
Bloc.add(AddProjectMember(projectId, userId, role))
  ↓
Bloc emite: ProjectMemberOperationInProgress
  ↓
Repository → DataSource → ApiClient
  ↓
POST /api/projects/1/members { userId: 123, role: "ADMIN" }
  ↓
Backend: Validator → Controller → Service → Prisma → DB
  ↓
DB: INSERT INTO ProjectMember (projectId, userId, role)
  ↓
Backend responde: { success: true, data: { ...member } }
  ↓
DataSource → Model.fromJson() → Entity
  ↓
Repository → Right(ProjectMember)
  ↓
Bloc recarga lista completa de miembros
  ↓
Bloc emite: ProjectMemberOperationSuccess(message, members)
  ↓
UI muestra: SnackBar + Lista actualizada
```

### 2. Actualizar Rol de Miembro

```
Usuario → Selecciona nuevo rol en Dropdown de ProjectMemberTile
  ↓
onRoleChanged(newRole) → Bloc.add(UpdateProjectMemberRole)
  ↓
Bloc emite: ProjectMemberOperationInProgress
  ↓
Repository → DataSource → ApiClient
  ↓
PUT /api/projects/1/members/123/role { role: "VIEWER" }
  ↓
Backend: Validator → Controller → Service → Prisma → DB
  ↓
DB: UPDATE ProjectMember SET role='VIEWER' WHERE id=...
  ↓
Backend responde: { success: true, data: { ...member } }
  ↓
Bloc recarga lista completa
  ↓
Bloc emite: ProjectMemberOperationSuccess
  ↓
UI muestra: SnackBar + Badge actualizado con nuevo color
```

### 3. Eliminar Miembro

```
Usuario → Tap botón "Eliminar" en ProjectMemberTile
  ↓
Dialog de confirmación: "¿Está seguro?"
  ↓
Usuario confirma → Bloc.add(RemoveProjectMember)
  ↓
Bloc emite: ProjectMemberOperationInProgress
  ↓
Repository → DataSource → ApiClient
  ↓
DELETE /api/projects/1/members/123
  ↓
Backend: Controller → Service → Prisma → DB
  ↓
DB: DELETE FROM ProjectMember WHERE id=...
  ↓
Backend responde: { success: true }
  ↓
Bloc recarga lista (miembro ya no aparece)
  ↓
Bloc emite: ProjectMemberOperationSuccess
  ↓
UI muestra: SnackBar + Lista sin el miembro eliminado
```

---

## 🎨 Componentes Visuales

### ProjectMemberRoleBadge

```
┌─────────────────────────┐
│  ⭐ OWNER               │  Color: Naranja (#FF9800)
└─────────────────────────┘

┌─────────────────────────┐
│  👑 ADMIN               │  Color: Púrpura (#9C27B0)
└─────────────────────────┘

┌─────────────────────────┐
│  👤 MEMBER              │  Color: Azul (#2196F3)
└─────────────────────────┘

┌─────────────────────────┐
│  👁️ VIEWER              │  Color: Gris (#757575)
└─────────────────────────┘
```

### ProjectMemberTile

```
┌──────────────────────────────────────────────────────────┐
│  ┌──┐  Juan Pérez                      [Dropdown ▼]  ✖   │
│  │JP│  juan@example.com                                   │
│  └──┘                                                      │
└──────────────────────────────────────────────────────────┘
 Avatar  Nombre/Email                  Selector    Eliminar
```

### ProjectMembersScreen - Header

```
┌──────────────────────────────────────────────────────────┐
│  👥 4 Miembros                                            │
│                                                            │
│  • Propietarios: 1  • Admins: 1                          │
│  • Miembros: 1      • Visualizadores: 1                  │
└──────────────────────────────────────────────────────────┘
```

---

## 🔒 Matriz de Permisos (Visual)

```
┌────────────┬─────────┬─────────┬─────────┬─────────┐
│  ACCIÓN    │  OWNER  │  ADMIN  │ MEMBER  │ VIEWER  │
├────────────┼─────────┼─────────┼─────────┼─────────┤
│ Ver        │    ✅   │   ✅    │   ✅    │   ✅    │
│ Editar     │    ✅   │   ✅    │   ✅    │   ❌    │
│ Crear      │    ✅   │   ✅    │   ✅    │   ❌    │
│ Eliminar   │    ✅   │   ✅    │   ❌    │   ❌    │
│ Gestionar  │    ✅   │   ✅*   │   ❌    │   ❌    │
│ Transferir │    ✅   │   ❌    │   ❌    │   ❌    │
└────────────┴─────────┴─────────┴─────────┴─────────┘

* ADMIN solo puede gestionar MEMBER y VIEWER
```

---

## 📱 Estados de la UI

### Loading
```
┌──────────────────────────┐
│                          │
│      🔄 Cargando...      │
│                          │
└──────────────────────────┘
```

### Error
```
┌──────────────────────────┐
│         ⚠️                │
│  Error al cargar          │
│  miembros                 │
│                           │
│  [Reintentar]             │
└──────────────────────────┘
```

### Vacío
```
┌──────────────────────────┐
│         👥                │
│  No hay miembros          │
│  en este proyecto         │
│                           │
│  [Agregar primer miembro] │
└──────────────────────────┘
```

### Operación en Progreso
```
┌──────────────────────────┐
│  [Overlay con fondo gris] │
│                           │
│      ┌──────────┐         │
│      │    🔄    │         │
│      │Procesando│         │
│      └──────────┘         │
└──────────────────────────┘
```

---

Este diagrama muestra visualmente cómo todos los componentes de la Fase 2 trabajan juntos para proporcionar una experiencia completa de gestión de miembros con roles.
