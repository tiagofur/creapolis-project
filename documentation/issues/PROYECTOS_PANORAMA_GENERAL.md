# 📊 PANORAMA GENERAL DE PROYECTOS - Reporte Completo

**Fecha:** 16 de Octubre, 2025  
**Estado General:** ⚠️ Funcional pero incompleto - Integración parcial con Workspaces

---

## 🎯 RESUMEN EJECUTIVO

La funcionalidad de **Proyectos** está **70% implementada** con arquitectura limpia, pero presenta **desconexión significativa con la realidad del backend** y falta integración profunda con Workspaces. Mientras que Workspaces está bien integrado y estable, Proyectos tiene varios aspectos críticos pendientes.

### Estado por Componente

| Componente                 | Estado             | Cobertura | Crítico           |
| -------------------------- | ------------------ | --------- | ----------------- |
| **Frontend - Entidades**   | ✅ Completo        | 100%      | -                 |
| **Frontend - BLoC**        | ⚠️ Dual            | 80%       | Dos BLoCs activos |
| **Frontend - UI**          | ⚠️ Parcial         | 65%       | Falta integración |
| **Frontend - Repository**  | ✅ Sólido          | 90%       | -                 |
| **Frontend - DataSources** | ✅ Funcional       | 85%       | -                 |
| **Backend - API**          | ⚠️ Básico          | 60%       | Falta campos      |
| **Backend - DB Schema**    | ✅ Correcto        | 95%       | -                 |
| **Integración Workspaces** | ⚠️ Parcial         | 40%       | **CRÍTICO**       |
| **Project Members**        | ❌ No implementado | 0%        | **CRÍTICO**       |
| **Navegación**             | ✅ Funcional       | 90%       | -                 |

---

## 📁 1. ANÁLISIS DE ARQUITECTURA FRONTEND

### 1.1 Estructura de Archivos ✅

```
lib/
├── domain/
│   ├── entities/
│   │   └── project.dart                 ✅ Completo con relaciones
│   ├── repositories/
│   │   └── project_repository.dart      ✅ Contratos claros
│   └── usecases/
│       ├── get_projects_usecase.dart    ✅
│       ├── get_project_by_id_usecase.dart ✅
│       ├── create_project_usecase.dart  ✅
│       ├── update_project_usecase.dart  ✅
│       └── delete_project_usecase.dart  ✅
│
├── data/
│   ├── models/
│   │   └── project_model.dart           ✅ Con fromJson/toJson
│   ├── repositories/
│   │   └── project_repository_impl.dart ✅ Cache + Remote
│   └── datasources/
│       ├── project_remote_datasource.dart     ✅ ApiClient
│       └── local/
│           └── project_cache_datasource.dart  ✅ Hive completo
│
└── presentation/
    ├── bloc/project/                    ⚠️ BLoC VIEJO (legacy)
    │   ├── project_bloc.dart            ⚠️ Usar UseCases
    │   ├── project_event.dart           ⚠️
    │   └── project_state.dart           ⚠️
    │
    ├── features/projects/
    │   └── presentation/
    │       ├── blocs/                   ✅ BLoC NUEVO (actual)
    │       │   ├── project_bloc.dart    ✅ Mejor estructura
    │       │   ├── project_event.dart   ✅ Estados avanzados
    │       │   └── project_state.dart   ✅ Con filtros
    │       ├── screens/
    │       │   └── projects_screen.dart ✅ Completa con filtros
    │       └── widgets/
    │           ├── project_card.dart    ✅
    │           ├── create_project_dialog.dart ⚠️ Pendiente verificar
    │           └── edit_project_dialog.dart   ⚠️ Pendiente verificar
    │
    └── screens/projects/
        ├── project_detail_screen.dart   ✅ Progressive Disclosure
        ├── projects_list_screen.dart    ⚠️ No usado
        └── all_projects_screen.dart     ⚠️ Stub con TODO

```

**Observaciones:**

- ✅ **Arquitectura limpia** bien implementada
- ⚠️ **Duplicación de BLoCs**: Hay dos `ProjectBloc` activos
- ⚠️ **Screens dispersas**: Algunas screens no están en uso

---

## 🔄 2. ANÁLISIS DE BLOCS

### 2.1 BLoC Viejo (`presentation/bloc/project/`)

**Ubicación:** `lib/presentation/bloc/project/project_bloc.dart`

**Características:**

- ✅ Usa UseCases correctamente
- ✅ Manejo de errores con Either
- ✅ Injectable con GetIt
- ⚠️ Estados simples (ProjectsLoaded, ProjectLoaded)
- ⚠️ No tiene filtrado ni búsqueda

**Estados:**

```dart
- ProjectInitial
- ProjectLoading
- ProjectsLoaded(projects)
- ProjectLoaded(project)
- ProjectCreated(project)
- ProjectUpdated(project)
- ProjectDeleted(projectId)
- ProjectError(message)
```

**Eventos:**

```dart
- LoadProjectsEvent(workspaceId)
- LoadProjectByIdEvent(id)
- CreateProjectEvent(...)
- UpdateProjectEvent(...)
- DeleteProjectEvent(id)
```

### 2.2 BLoC Nuevo (`features/projects/presentation/blocs/`)

**Ubicación:** `lib/features/projects/presentation/blocs/project_bloc.dart`

**Características:**

- ✅ Acceso directo al Repository (sin UseCases)
- ✅ Estados más avanzados con filtros
- ✅ Soporte para búsqueda y filtrado
- ✅ Manejo de estados de operación en progreso
- ⚠️ No usa UseCases (diferente patrón)

**Estados:**

```dart
- ProjectInitial
- ProjectLoading
- ProjectsLoaded(projects, filteredProjects, selectedProject, currentFilter, searchQuery)
- ProjectOperationInProgress(message, currentProjects)
- ProjectOperationSuccess(message, project)
- ProjectError(message, currentProjects)
```

**Eventos:**

```dart
- LoadProjects(workspaceId)
- LoadProjectById(projectId)
- CreateProject(...)
- UpdateProject(...)
- DeleteProject(projectId)
- RefreshProjects(workspaceId)
- FilterProjectsByStatus(status)
- SearchProjects(query)
```

### 2.3 Cuál Usar ⚠️

**Actualmente en uso:**

- `ProjectsScreen` → Usa el **BLoC NUEVO** ✅
- `ProjectDetailScreen` → Usa el **BLoC VIEJO** ⚠️
- Router → Registra el **BLoC NUEVO** ✅

**Recomendación:** Unificar usando el BLoC nuevo con UseCases integrados.

---

## 🎨 3. ANÁLISIS DE PANTALLAS

### 3.1 ProjectsScreen ✅

**Ubicación:** `features/projects/presentation/screens/projects_screen.dart`

**Estado:** ✅ Completa y funcional

**Características:**

- ✅ Lista de proyectos con filtros
- ✅ Búsqueda en tiempo real
- ✅ Pull-to-refresh
- ✅ Filtrado por status
- ✅ Diálogos de creación/edición/eliminación
- ✅ Navegación a tareas del proyecto
- ✅ Integración con WorkspaceContext
- ✅ Estados vacíos y de error bien manejados

**Navegación:**

```dart
context.go('/workspaces/$workspaceId/projects/$projectId/tasks');
```

### 3.2 ProjectDetailScreen ✅

**Ubicación:** `presentation/screens/projects/project_detail_screen.dart`

**Estado:** ✅ Completa con Progressive Disclosure

**Características:**

- ✅ Tabs: Overview, Tareas, Timeline
- ✅ Secciones colapsables con preferencias
- ✅ Barra de progreso visual
- ✅ Estadísticas del proyecto
- ✅ Navegación a Gantt, Workload, Resource Map
- ✅ Edición y eliminación inline
- ⚠️ **Lista de tareas embebida** (TasksListScreen)

**Problema:** Usa el BLoC viejo

### 3.3 ProjectsListScreen ⚠️

**Ubicación:** `presentation/screens/projects/projects_list_screen.dart`

**Estado:** ⚠️ Parece legacy, no usado en router

**Observación:** Duplica funcionalidad de ProjectsScreen

### 3.4 AllProjectsScreen ⚠️

**Ubicación:** `presentation/screens/projects/all_projects_screen.dart`

**Estado:** ❌ Stub sin implementar

```dart
/// TODO: Conectar con ProjectsBloc para obtener datos reales
class AllProjectsScreen extends StatelessWidget {
  // Datos mock...
}
```

---

## 🗄️ 4. ANÁLISIS BACKEND

### 4.1 Schema de Base de Datos ✅

**Ubicación:** `backend/prisma/schema.prisma`

```prisma
model Project {
  id          Int             @id @default(autoincrement())
  name        String
  description String?
  workspaceId Int             // ✅ Relación con Workspace
  createdAt   DateTime
  updatedAt   DateTime
  workspace   Workspace       @relation(...)
  members     ProjectMember[] // ✅ Relación muchos a muchos
  tasks       Task[]
  comments    Comment[]
  roles       ProjectRole[]

  @@index([workspaceId])
}

model ProjectMember {
  id        Int      @id
  userId    Int
  projectId Int
  joinedAt  DateTime
  project   Project  @relation(...)
  user      User     @relation(...)

  @@unique([userId, projectId])
}
```

**Observaciones:**

- ✅ Relación correcta con Workspace
- ✅ Soporte para ProjectMembers
- ✅ Índices apropiados
- ⚠️ **Faltan campos** que el frontend espera: `status`, `startDate`, `endDate`, `managerId`, `managerName`

### 4.2 API REST (Node.js) ⚠️

**Ubicación:** `backend/src/controllers/project.controller.js`

**Endpoints:**

```javascript
GET    /api/projects                    // Lista con paginación
POST   /api/projects                    // Crear
GET    /api/projects/:id                // Por ID
PUT    /api/projects/:id                // Actualizar
DELETE /api/projects/:id                // Eliminar
POST   /api/projects/:id/members        // Agregar miembro
DELETE /api/projects/:id/members/:userId // Quitar miembro
```

**Campos soportados en Backend:**

```javascript
// Crear/Actualizar
{
  name,
    description,
    workspaceId, // ✅ Requiere workspace
    memberIds; // ✅ Array de usuarios
}
```

**❌ CAMPOS FALTANTES EN BACKEND:**

- `status` (planned, active, paused, completed, cancelled)
- `startDate`
- `endDate`
- `managerId`
- `progress`
- Campos de auditoría más detallados

### 4.3 Service Layer ⚠️

**Ubicación:** `backend/src/services/project.service.js`

**Lógica actual:**

- ✅ Validación de acceso por workspace
- ✅ Verificación de miembros
- ✅ Include de relaciones (members, tasks)
- ✅ Control de permisos básico
- ⚠️ No devuelve `status`, `startDate`, `endDate`
- ⚠️ No calcula `progress`
- ⚠️ No identifica `managerId` claramente

---

## 🔗 5. INTEGRACIÓN CON WORKSPACES

### 5.1 Estado Actual ⚠️

**Lo que funciona:**

- ✅ Proyectos filtrados por `workspaceId`
- ✅ Navegación: `/workspaces/:wId/projects`
- ✅ WorkspaceContext detecta cambio de workspace
- ✅ Recarga automática al cambiar workspace

**Lo que falta:**

- ❌ **Verificar permisos del usuario en el workspace**
- ❌ **UI para seleccionar workspace al crear proyecto**
- ❌ **Validación de que el usuario tiene acceso al workspace**
- ❌ **Dashboard de proyectos por workspace**
- ❌ **Estadísticas agregadas por workspace**

### 5.2 Flujo de Creación de Proyecto ⚠️

**Actual:**

```dart
CreateProject(
  workspaceId: workspaceId,  // Se pasa desde la pantalla
  name: ...,
  description: ...,
  // ...
)
```

**Problema:**

- El `workspaceId` se toma del contexto de la ruta
- No hay validación visual de a qué workspace pertenece
- No hay opción de cambiar de workspace durante la creación

---

## 👥 6. PROJECT MEMBERS - CRÍTICO ❌

### 6.1 Backend ✅

```javascript
// Endpoints disponibles
POST   /api/projects/:id/members        // Agregar
DELETE /api/projects/:id/members/:userId // Quitar

// Service implementado
addMember(projectId, userId, memberId)
removeMember(projectId, userId, memberId)
```

### 6.2 Frontend ❌

**NO IMPLEMENTADO:**

- ❌ UI para ver miembros del proyecto
- ❌ UI para agregar miembros
- ❌ UI para quitar miembros
- ❌ Entity `ProjectMember` en Domain
- ❌ Repository para ProjectMembers
- ❌ BLoC/Estado para ProjectMembers
- ❌ Widgets para gestionar miembros

**Impacto:**

- No se pueden compartir proyectos con el equipo
- No se puede asignar tareas a otros usuarios
- No se refleja el tipo de relación (personal, sharedByMe, sharedWithMe)

---

## 🧩 7. ANÁLISIS DE DEPENDENCIAS

### 7.1 Dependency Injection ✅

**Ubicación:** `lib/injection.config.dart`

```dart
// ✅ ProjectRepository
gh.lazySingleton<ProjectRepository>(() => ProjectRepositoryImpl(
  gh<ProjectRemoteDataSource>(),
  gh<ProjectCacheDataSource>(),
  gh<ConnectivityService>(),
));

// ✅ UseCases
gh.factory<CreateProjectUseCase>(() => CreateProjectUseCase(gh<ProjectRepository>()));
gh.factory<DeleteProjectUseCase>(() => DeleteProjectUseCase(gh<ProjectRepository>()));
gh.factory<GetProjectsUseCase>(() => GetProjectsUseCase(gh<ProjectRepository>()));
gh.factory<GetProjectByIdUseCase>(() => GetProjectByIdUseCase(gh<ProjectRepository>()));
gh.factory<UpdateProjectUseCase>(() => UpdateProjectUseCase(gh<ProjectRepository>()));

// ⚠️ AMBOS BLoCs registrados
gh.factory<ProjectBloc>(() => ProjectBloc(projectRepository: gh<ProjectRepository>())); // Nuevo
gh.factory<ProjectBloc>(() => ProjectBloc(
  gh<GetProjectsUseCase>(),
  gh<GetProjectByIdUseCase>(),
  gh<CreateProjectUseCase>(),
  gh<UpdateProjectUseCase>(),
  gh<DeleteProjectUseCase>(),
)); // Viejo
```

**Problema:** Ambos BLoCs están registrados bajo el mismo tipo.

### 7.2 Cache y Sincronización ✅

**Implementación sólida:**

- ✅ Hive para almacenamiento local
- ✅ Cache por workspace (`hasValidCache(workspaceId)`)
- ✅ Timestamps de cache
- ✅ Operaciones pendientes de sync
- ✅ Filtrado eficiente por workspace

---

## 📋 8. TODOs ENCONTRADOS

### Frontend

```dart
// all_projects_screen.dart:15
/// TODO: Conectar con ProjectsBloc para obtener datos reales

// my_projects_widget.dart:49
// TODO: Navegar a /projects

// projects_screen.dart:249
// TODO: Navegar a project detail
```

### Backend

```dart
// project_remote_datasource.dart:179
// TODO: El backend actual no soporta estos campos, agregar cuando esté disponible
// - startDate
// - endDate
// - status
// - managerId
```

---

## 🔍 9. COMPARACIÓN CON WORKSPACES

| Aspecto              | Workspaces           | Projects            |
| -------------------- | -------------------- | ------------------- |
| **Domain Layer**     | ✅ Completo          | ✅ Completo         |
| **Repository**       | ✅ Cache + Remote    | ✅ Cache + Remote   |
| **BLoC**             | ✅ Único y robusto   | ⚠️ Duplicado        |
| **UI Screens**       | ✅ CRUD completo     | ⚠️ Parcial          |
| **Members**          | ✅ Implementado      | ❌ Faltante         |
| **Invitations**      | ✅ Implementado      | ❌ N/A              |
| **Backend API**      | ✅ Completo          | ⚠️ Campos faltantes |
| **Integración**      | ✅ Estable           | ⚠️ Parcial          |
| **Settings**         | ✅ Pantalla completa | ❌ No existe        |
| **Context Provider** | ✅ WorkspaceContext  | ❌ No existe        |

**Conclusión:** Workspaces está más maduro y completo.

---

## 📊 10. MÉTRICAS DE CÓDIGO

### Cobertura de Funcionalidades

| Funcionalidad            | Estado  | Prioridad     |
| ------------------------ | ------- | ------------- |
| **Listar proyectos**     | ✅ 100% | -             |
| **Crear proyecto**       | ✅ 90%  | Faltan campos |
| **Editar proyecto**      | ✅ 90%  | Faltan campos |
| **Eliminar proyecto**    | ✅ 100% | -             |
| **Filtrar proyectos**    | ✅ 100% | -             |
| **Buscar proyectos**     | ✅ 100% | -             |
| **Ver detalle**          | ✅ 95%  | Mejorar tabs  |
| **Gestionar miembros**   | ❌ 0%   | **ALTA**      |
| **Asignar manager**      | ❌ 0%   | **ALTA**      |
| **Establecer fechas**    | ❌ 0%   | **ALTA**      |
| **Cambiar status**       | ❌ 0%   | **ALTA**      |
| **Calcular progreso**    | ⚠️ 30%  | **MEDIA**     |
| **Settings de proyecto** | ❌ 0%   | **BAJA**      |

---

## 🚨 11. PROBLEMAS CRÍTICOS

### 11.1 Desalineación Frontend-Backend ⚠️

**Problema:** El frontend espera campos que el backend no devuelve.

**Frontend espera:**

```dart
class Project {
  final ProjectStatus status;        // ❌ No en backend
  final DateTime startDate;          // ❌ No en backend
  final DateTime endDate;            // ❌ No en backend
  final int? managerId;              // ❌ No en backend
  final String? managerName;         // ❌ No en backend
  // ...
}
```

**Backend devuelve:**

```json
{
  "id": 1,
  "name": "Proyecto Demo",
  "description": "...",
  "workspaceId": 1,
  "createdAt": "...",
  "updatedAt": "...",
  "members": [...],
  "tasks": [...]
}
```

**Impacto:**

- Los campos `status`, `startDate`, `endDate` son `null` siempre
- No se puede calcular `progress` correctamente
- No se puede identificar al manager del proyecto
- Las funciones de relación (personal, sharedByMe, sharedWithMe) no funcionan

### 11.2 Duplicación de BLoCs ⚠️

**Problema:** Dos `ProjectBloc` activos con diferentes implementaciones.

**Impacto:**

- Confusión en el código
- Mantenimiento duplicado
- Posibles bugs por usar el BLoC incorrecto

### 11.3 ProjectMembers No Implementado ❌

**Problema:** Aunque el backend lo soporta, el frontend no tiene UI.

**Impacto:**

- No se pueden compartir proyectos
- No se pueden asignar roles
- La colaboración está limitada

---

## ✅ 12. ASPECTOS POSITIVOS

### Lo que está bien implementado:

1. ✅ **Arquitectura limpia** consistente
2. ✅ **Cache local** robusto con Hive
3. ✅ **Manejo de errores** con Either
4. ✅ **Navegación** bien estructurada
5. ✅ **UI responsive** y moderna
6. ✅ **Progressive Disclosure** en detalle
7. ✅ **Filtros y búsqueda** funcionales
8. ✅ **Integración básica** con Workspaces
9. ✅ **DI con Injectable** correcta
10. ✅ **Logging** apropiado

---

## 🎯 13. NIVEL DE COMPLETITUD

```
Frontend:  ████████████░░░░░░░░  65%
Backend:   ████████░░░░░░░░░░░░  45%
Integration: ████░░░░░░░░░░░░░░░░  25%
Overall:   ██████░░░░░░░░░░░░░░  35%
```

**Desglose:**

| Área               | % Completitud | Bloqueadores     |
| ------------------ | ------------- | ---------------- |
| Domain Layer       | 95%           | Ninguno          |
| Data Layer         | 85%           | Campos backend   |
| Presentation Layer | 70%           | Members UI       |
| Backend API        | 60%           | Campos faltantes |
| Backend DB         | 95%           | Migraciones      |
| Testing            | 10%           | Todos            |
| Documentación      | 40%           | Ejemplos         |

---

## 📈 14. ROADMAP RECOMENDADO

### Fase 1: Alineación Backend (CRÍTICA)

- Agregar campos faltantes al schema
- Migración de base de datos
- Actualizar API para incluir nuevos campos
- Tests de API

### Fase 2: Unificación de BLoCs

- Consolidar en un solo ProjectBloc
- Migrar pantallas al BLoC correcto
- Eliminar código legacy

### Fase 3: Project Members (CRÍTICA)

- Implementar UI de gestión de miembros
- Repository y DataSources
- BLoC para members
- Integración con permisos

### Fase 4: Funcionalidades Faltantes

- Status de proyectos
- Fechas y timeline
- Cálculo de progreso real
- Manager assignment

### Fase 5: Integración Profunda

- ProjectContext similar a WorkspaceContext
- Dashboard por proyecto
- Estadísticas avanzadas
- Settings de proyecto

### Fase 6: Refinamiento

- Testing completo
- Documentación
- Optimizaciones de rendimiento
- Accesibilidad

---

## 📝 CONCLUSIÓN

Proyectos tiene una **base sólida** con buena arquitectura, pero requiere trabajo significativo para alcanzar el nivel de madurez de Workspaces. Los **bloqueadores principales** son:

1. 🔴 **Desalineación Frontend-Backend** en campos críticos
2. 🔴 **ProjectMembers no implementado** en el frontend
3. 🟡 **Duplicación de BLoCs** que causa confusión
4. 🟡 **Falta integración profunda** con Workspaces

**Tiempo estimado para completar:** 3-4 semanas de desarrollo enfocado.

**Recomendación:** Priorizar Fase 1 (Backend) y Fase 3 (Members) antes de agregar nuevas funcionalidades.

---

**Generado por:** GitHub Copilot  
**Fecha:** 16 de Octubre, 2025
