# 🚀 FASE 2: Backend Integration - Workspaces, Projects & Tasks

**Estado**: 📋 **PLANIFICACIÓN**  
**Fecha de inicio**: 11 de octubre de 2025  
**Duración estimada**: 25-30 horas  
**Prioridad**: 🔥 **CRÍTICA** (funcionalidad core)

---

## 🎯 Objetivo General

Implementar la **funcionalidad completa del flujo principal** de Creapolis:

- **Workspaces** → Crear, listar, seleccionar, gestionar miembros
- **Proyectos** → Crear, listar, asociar a workspace, gestionar
- **Tareas** → Crear, listar, asociar a proyecto, cambiar estados, asignar

**Resultado esperado**: Usuario puede crear workspace → crear proyecto → crear tareas → gestionar todo el ciclo de vida.

---

## 📊 Estado Actual vs Objetivo

### 🔴 Estado Actual

- ✅ **UI/UX completa** y pulida (Fase 1)
- ❌ **Datos mockeados** (demo data hardcoded)
- ❌ **No hay integración con backend**
- ❌ **BLoCs incompletos** o desactualizados
- ❌ **Speed Dial crea dialogs vacíos**
- ❌ **Dashboard muestra stats fake**
- ❌ **No hay gestión de workspace activo**

### 🟢 Objetivo Post-Fase 2

- ✅ **Backend completamente integrado**
- ✅ **Networking layer robusto** (Dio + interceptors)
- ✅ **WorkspaceBloc funcional** (CRUD completo)
- ✅ **ProjectBloc nuevo** (CRUD completo)
- ✅ **TaskBloc mejorado** (CRUD completo)
- ✅ **Dashboard con datos reales**
- ✅ **Speed Dial crea entidades reales**
- ✅ **Gestión de workspace activo** (selección + persistencia)
- ✅ **Flujo completo operativo**: Workspace → Project → Task

---

## 📋 Tareas Detalladas

### **Tarea 2.1: Networking Layer Setup** (3-4h)

**Objetivo**: Crear infraestructura robusta de networking con manejo de errores, interceptors y retry logic.

#### Subtareas

1. **Setup de Dio** (1h)

   - Instalar dependency: `dio: ^5.4.0`
   - Crear `ApiClient` con base URL configurable
   - Configurar timeouts (connect: 30s, receive: 30s)
   - Implementar headers por default (Content-Type, Accept)

2. **JWT Interceptor** (1h)

   - Crear `AuthInterceptor` extends `Interceptor`
   - Inyectar token desde `AuthBloc.state.token`
   - Auto-agregar `Authorization: Bearer <token>` en requests
   - Manejar refresh de token (si expira)

3. **Error Interceptor** (1h)

   - Crear `ErrorInterceptor` extends `Interceptor`
   - Mapear errores HTTP a excepciones custom:
     - 400 → `BadRequestException`
     - 401 → `UnauthorizedException` (auto-logout)
     - 403 → `ForbiddenException`
     - 404 → `NotFoundException`
     - 500 → `ServerException`
     - Network → `NetworkException`
   - Log de errores con `AppLogger`

4. **Retry Logic** (30min)

   - Implementar retry en errores de red (max 3 intentos)
   - Exponential backoff (1s, 2s, 4s)
   - Solo para métodos idempotentes (GET)

5. **API Response Wrapper** (30min)
   - Crear `ApiResponse<T>` model:
     ```dart
     class ApiResponse<T> {
       final bool success;
       final String? message;
       final T? data;
       final Map<String, dynamic>? errors;
     }
     ```
   - Parser genérico para todas las responses

**Entregables**:

- `lib/core/network/api_client.dart`
- `lib/core/network/interceptors/auth_interceptor.dart`
- `lib/core/network/interceptors/error_interceptor.dart`
- `lib/core/network/exceptions/api_exceptions.dart`
- `lib/core/network/models/api_response.dart`

**Testing**:

- ✅ Request con token funciona
- ✅ Request sin token recibe 401
- ✅ Error 500 se mapea a `ServerException`
- ✅ Retry funciona en network errors

---

### **Tarea 2.2: Workspace Management** (6-7h)

**Objetivo**: Implementar CRUD completo de Workspaces con gestión de workspace activo.

#### Subtareas

1. **Workspace Data Layer** (2h)

   - Crear `WorkspaceRemoteDataSource`:

     - `getWorkspaces()` → `GET /api/workspaces`
     - `getWorkspaceById(id)` → `GET /api/workspaces/:id`
     - `createWorkspace(data)` → `POST /api/workspaces`
     - `updateWorkspace(id, data)` → `PUT /api/workspaces/:id`
     - `deleteWorkspace(id)` → `DELETE /api/workspaces/:id`
     - `inviteMember(id, email, role)` → `POST /api/workspaces/:id/members`
     - `removeMember(id, userId)` → `DELETE /api/workspaces/:id/members/:userId`

   - Crear `WorkspaceRepositoryImpl`:
     - Implementar métodos del repository
     - Mapear DTOs a Entities
     - Manejo de errores con Either<Failure, T>

2. **Workspace Use Cases** (1h)

   - `GetUserWorkspacesUseCase`
   - `GetWorkspaceByIdUseCase`
   - `CreateWorkspaceUseCase`
   - `UpdateWorkspaceUseCase`
   - `DeleteWorkspaceUseCase`
   - `InviteMemberUseCase`
   - `RemoveMemberUseCase`

3. **WorkspaceBloc Refactor** (2h)

   - **Events**:

     - `LoadWorkspacesEvent`
     - `SelectWorkspaceEvent(workspaceId)`
     - `CreateWorkspaceEvent(data)`
     - `UpdateWorkspaceEvent(id, data)`
     - `DeleteWorkspaceEvent(id)`
     - `InviteMemberEvent(workspaceId, email, role)`
     - `RemoveMemberEvent(workspaceId, userId)`

   - **States**:

     - `WorkspaceInitial`
     - `WorkspaceLoading`
     - `WorkspaceLoaded(workspaces, activeWorkspace)`
     - `WorkspaceError(message)`
     - `WorkspaceOperationSuccess(message)`

   - Implementar lógica de negocio
   - Persistir workspace activo en SharedPreferences

4. **Active Workspace Management** (1h)

   - Crear `ActiveWorkspaceProvider` (StateNotifier o similar)
   - Guardar/cargar workspace activo de SharedPreferences
   - Key: `StorageKeys.activeWorkspaceId`
   - Emitir cambios a toda la app

5. **UI Integration** (2h)

   - **Workspace Screen** (existing):

     - Conectar con `WorkspaceBloc`
     - Mostrar workspaces reales
     - Permitir selección de workspace activo
     - Botón "Crear Workspace" funcional

   - **Workspace Selector** (nuevo widget):

     - Dropdown en Dashboard/All Tasks para cambiar workspace
     - Muestra workspace activo
     - Lista de workspaces disponibles

   - **Create Workspace Dialog** (mejorar existente):

     - Form con validación:
       - Nombre (required, 3-50 chars)
       - Descripción (optional, max 200 chars)
       - Tipo (PERSONAL, TEAM, ENTERPRISE)
     - Botón "Crear" dispara `CreateWorkspaceEvent`
     - Loading state + error handling

   - **Profile Screen**:
     - Conectar workspaces list con datos reales
     - Role badges desde API
     - Member count real

**Entregables**:

- `lib/data/datasources/workspace_remote_datasource.dart`
- `lib/data/repositories/workspace_repository_impl.dart`
- `lib/domain/usecases/workspace/` (7 use cases)
- `lib/presentation/bloc/workspace/workspace_bloc.dart` (refactored)
- `lib/presentation/widgets/workspace_selector.dart` (nuevo)
- `lib/presentation/dialogs/create_workspace_dialog.dart` (mejorado)

**Testing**:

- ✅ Usuario puede crear workspace
- ✅ Workspaces se listan correctamente
- ✅ Workspace activo se persiste
- ✅ Cambiar workspace activo funciona
- ✅ Profile muestra workspaces reales

---

### **Tarea 2.3: Project Management** (6-7h)

**Objetivo**: Implementar CRUD completo de Proyectos asociados a Workspaces.

#### Subtareas

1. **Project Data Layer** (2h)

   - Crear `ProjectRemoteDataSource`:

     - `getProjects(workspaceId)` → `GET /api/workspaces/:id/projects`
     - `getProjectById(id)` → `GET /api/projects/:id`
     - `createProject(workspaceId, data)` → `POST /api/workspaces/:id/projects`
     - `updateProject(id, data)` → `PUT /api/projects/:id`
     - `deleteProject(id)` → `DELETE /api/projects/:id`
     - `addMember(projectId, userId, role)` → `POST /api/projects/:id/members`

   - Crear `ProjectRepositoryImpl`:
     - Implementar repository interface
     - Mapear DTOs a Entities
     - Filtrado por workspace activo

2. **Project Use Cases** (1h)

   - `GetWorkspaceProjectsUseCase(workspaceId)`
   - `GetProjectByIdUseCase(id)`
   - `CreateProjectUseCase(workspaceId, data)`
   - `UpdateProjectUseCase(id, data)`
   - `DeleteProjectUseCase(id)`
   - `AddProjectMemberUseCase(projectId, userId, role)`

3. **ProjectBloc Creation** (2h)

   - **Events**:

     - `LoadProjectsEvent(workspaceId)`
     - `CreateProjectEvent(workspaceId, data)`
     - `UpdateProjectEvent(id, data)`
     - `DeleteProjectEvent(id)`
     - `SelectProjectEvent(projectId)` (para filtrar tareas)

   - **States**:

     - `ProjectInitial`
     - `ProjectLoading`
     - `ProjectLoaded(projects, selectedProject)`
     - `ProjectError(message)`
     - `ProjectOperationSuccess(message)`

   - Auto-reload cuando workspace activo cambia

4. **UI Integration** (2-3h)

   - **All Projects Screen**:

     - Conectar con `ProjectBloc`
     - Listar proyectos del workspace activo
     - Botón "Crear Proyecto" funcional
     - ProjectCard con datos reales
     - Empty state cuando workspace no tiene proyectos
     - Pull to refresh

   - **Create Project Dialog** (nuevo):

     - Form con validación:
       - Nombre (required, 3-100 chars)
       - Descripción (optional, max 500 chars)
       - Fecha inicio (optional)
       - Fecha fin (optional)
       - Color/Avatar (optional)
     - Botón "Crear" dispara `CreateProjectEvent`
     - Loading + error handling

   - **Project Details Screen** (mejorar existente):

     - Mostrar info real del proyecto
     - Lista de miembros
     - Stats (tareas totales, completadas, etc.)
     - Botón editar/eliminar (si tiene permisos)

   - **Dashboard**:
     - Selector de proyecto (dropdown)
     - Filtrar recent tasks por proyecto

**Entregables**:

- `lib/data/datasources/project_remote_datasource.dart`
- `lib/data/repositories/project_repository_impl.dart`
- `lib/domain/usecases/project/` (6 use cases)
- `lib/presentation/bloc/project/project_bloc.dart` (nuevo)
- `lib/presentation/dialogs/create_project_dialog.dart` (nuevo)
- `lib/presentation/screens/projects/project_details_screen.dart` (mejorado)

**Testing**:

- ✅ Usuario puede crear proyecto en workspace
- ✅ Proyectos se listan por workspace
- ✅ Cambiar workspace actualiza proyectos
- ✅ Project details muestra info real
- ✅ Speed Dial crea proyecto real

---

### **Tarea 2.4: Task Management** (6-7h)

**Objetivo**: Implementar CRUD completo de Tareas asociadas a Proyectos.

#### Subtareas

1. **Task Data Layer** (2h)

   - Crear `TaskRemoteDataSource`:

     - `getTasks(projectId?, status?)` → `GET /api/tasks?projectId=...&status=...`
     - `getTaskById(id)` → `GET /api/tasks/:id`
     - `createTask(projectId, data)` → `POST /api/tasks`
     - `updateTask(id, data)` → `PUT /api/tasks/:id`
     - `deleteTask(id)` → `DELETE /api/tasks/:id`
     - `updateTaskStatus(id, status)` → `PATCH /api/tasks/:id/status`
     - `assignTask(id, userId)` → `PATCH /api/tasks/:id/assign`

   - Crear `TaskRepositoryImpl`:
     - Implementar repository
     - Filtros server-side
     - Optimistic updates

2. **Task Use Cases** (1h)

   - `GetTasksUseCase(projectId?, status?)`
   - `GetTaskByIdUseCase(id)`
   - `CreateTaskUseCase(projectId, data)`
   - `UpdateTaskUseCase(id, data)`
   - `DeleteTaskUseCase(id)`
   - `UpdateTaskStatusUseCase(id, status)`
   - `AssignTaskUseCase(id, userId)`

3. **TaskBloc Refactor** (2h)

   - **Events**:

     - `LoadTasksEvent(projectId?, status?)`
     - `CreateTaskEvent(projectId, data)`
     - `UpdateTaskEvent(id, data)`
     - `DeleteTaskEvent(id)`
     - `UpdateTaskStatusEvent(id, status)`
     - `AssignTaskEvent(id, userId)`
     - `SearchTasksEvent(query)`
     - `FilterTasksEvent(filters)`

   - **States**:

     - `TaskInitial`
     - `TaskLoading`
     - `TaskLoaded(tasks, filters, selectedTask)`
     - `TaskError(message)`
     - `TaskOperationSuccess(message)`

   - Implementar filtrado local + server-side
   - Manejo de búsqueda en tiempo real

4. **UI Integration** (2-3h)

   - **All Tasks Screen**:

     - Conectar con `TaskBloc`
     - Filtrar por workspace activo + proyecto
     - Tabs funcionan con API:
       - "Todas" → sin filtro de status
       - "Pendientes" → status=PENDING
       - "En Progreso" → status=IN_PROGRESS
       - "Completadas" → status=COMPLETED
     - Búsqueda real (server-side)
     - Pull to refresh

   - **Create Task Dialog** (mejorar existente):

     - Form con validación:
       - Título (required, 3-200 chars)
       - Descripción (optional, max 1000 chars)
       - Proyecto (required, dropdown)
       - Prioridad (LOW, MEDIUM, HIGH)
       - Fecha límite (optional)
       - Asignado a (optional, dropdown de miembros)
     - Botón "Crear" dispara `CreateTaskEvent`
     - Loading + error handling

   - **Task Details Dialog** (mejorar):

     - Mostrar info completa
     - Botones de acción:
       - Editar
       - Cambiar estado (dropdown)
       - Asignar a usuario
       - Eliminar (confirmación)
     - Comments section (placeholder para Fase 3)

   - **Dashboard**:
     - Recent tasks desde API
     - Stats cards con números reales:
       - GET /api/tasks?status=PENDING → count
       - GET /api/tasks?status=IN_PROGRESS → count
       - GET /api/tasks?status=COMPLETED → count

**Entregables**:

- `lib/data/datasources/task_remote_datasource.dart`
- `lib/data/repositories/task_repository_impl.dart`
- `lib/domain/usecases/task/` (7 use cases)
- `lib/presentation/bloc/task/task_bloc.dart` (refactored)
- `lib/presentation/dialogs/create_task_dialog.dart` (mejorado)
- `lib/presentation/dialogs/task_details_dialog.dart` (mejorado)

**Testing**:

- ✅ Usuario puede crear tarea en proyecto
- ✅ Tareas se filtran por workspace/proyecto
- ✅ Tabs de All Tasks funcionan con API
- ✅ Búsqueda funciona en tiempo real
- ✅ Cambiar estado de tarea funciona
- ✅ Dashboard muestra stats reales

---

### **Tarea 2.5: Dashboard Integration** (3-4h)

**Objetivo**: Conectar Dashboard con APIs reales y mostrar datos dinámicos.

#### Subtareas

1. **Dashboard Data Aggregation** (2h)

   - Crear `DashboardRepository`:

     - `getDashboardStats(workspaceId)`:
       - Tareas pendientes (count)
       - Tareas en progreso (count)
       - Tareas completadas (count)
       - Proyectos activos (count)
     - `getRecentTasks(workspaceId, limit=5)`
     - Caché de 5 minutos para stats

   - Crear `DashboardBloc`:
     - **Events**:
       - `LoadDashboardEvent(workspaceId)`
       - `RefreshDashboardEvent`
     - **States**:
       - `DashboardLoading`
       - `DashboardLoaded(stats, recentTasks)`
       - `DashboardError(message)`

2. **UI Updates** (1-2h)

   - **Dashboard Screen**:

     - Conectar con `DashboardBloc`
     - Stats cards con números reales
     - Recent tasks desde API
     - Shimmer loading mientras carga
     - Pull to refresh actualiza datos
     - Auto-reload cuando workspace cambia

   - **Quick Actions**:
     - "Nueva Tarea" → Abre dialog funcional
     - "Nuevo Proyecto" → Abre dialog funcional
     - "Invitar" → Abre dialog de invite (placeholder)
     - "Configuración" → Navega a settings

**Entregables**:

- `lib/data/repositories/dashboard_repository.dart`
- `lib/presentation/bloc/dashboard/dashboard_bloc.dart`
- `lib/presentation/screens/dashboard/dashboard_screen.dart` (updated)

**Testing**:

- ✅ Dashboard carga stats reales
- ✅ Recent tasks son del workspace activo
- ✅ Cambiar workspace actualiza dashboard
- ✅ Pull to refresh funciona

---

### **Tarea 2.6: Speed Dial Real Actions** (2-3h)

**Objetivo**: Hacer que todas las opciones del Speed Dial creen entidades reales.

#### Subtareas

1. **Speed Dial Actions** (2h)

   - **Nueva Tarea**:

     - Verificar que hay workspace activo
     - Si no hay proyectos, mostrar mensaje: "Crea un proyecto primero"
     - Abrir `CreateTaskDialog` con dropdown de proyectos
     - Dispatch `CreateTaskEvent` al BLoC
     - Feedback visual (snackbar success/error)

   - **Nuevo Proyecto**:

     - Verificar que hay workspace activo
     - Si no hay, mostrar mensaje: "Selecciona un workspace primero"
     - Abrir `CreateProjectDialog`
     - Dispatch `CreateProjectEvent` al BLoC
     - Feedback visual

   - **Nuevo Workspace**:
     - Abrir `CreateWorkspaceDialog`
     - Dispatch `CreateWorkspaceEvent` al BLoC
     - Al crear exitosamente, auto-seleccionar como activo
     - Feedback visual

2. **Error Handling** (1h)
   - Validación de precondiciones
   - Mensajes de error claros
   - Retry option en errores de red
   - Loading states durante creación

**Entregables**:

- `lib/presentation/widgets/speed_dial_fab_widget.dart` (updated)
- `lib/presentation/dialogs/create_task_dialog.dart` (fully functional)
- `lib/presentation/dialogs/create_project_dialog.dart` (fully functional)
- `lib/presentation/dialogs/create_workspace_dialog.dart` (fully functional)

**Testing**:

- ✅ Speed Dial crea tarea real
- ✅ Speed Dial crea proyecto real
- ✅ Speed Dial crea workspace real
- ✅ Validaciones funcionan correctamente
- ✅ Feedback visual apropiado

---

### **Tarea 2.7: Integration Testing & Polish** (3-4h)

**Objetivo**: Testing exhaustivo del flujo completo y pulido final.

#### Subtareas

1. **Flujo Completo E2E** (2h)

   - **Test Manual 1**: Nuevo Usuario

     ```
     1. Login
     2. No tiene workspaces → Ver empty state
     3. Crear workspace "Mi Empresa"
     4. Workspace se selecciona automáticamente
     5. Dashboard muestra stats en 0
     6. Crear proyecto "Proyecto Alpha"
     7. Dashboard actualiza con 1 proyecto
     8. Crear tarea "Tarea 1" en Proyecto Alpha
     9. Dashboard actualiza: 1 tarea pendiente
     10. All Tasks muestra la tarea
     11. Cambiar estado a "En Progreso"
     12. Dashboard actualiza: 1 en progreso, 0 pendientes
     13. Profile muestra 1 workspace con role OWNER
     ```

   - **Test Manual 2**: Usuario con Múltiples Workspaces
     ```
     1. Login con usuario que tiene 2 workspaces
     2. Dashboard muestra datos del workspace activo
     3. Cambiar workspace desde selector
     4. Dashboard actualiza automáticamente
     5. All Tasks muestra tareas del nuevo workspace
     6. All Projects muestra proyectos del nuevo workspace
     7. Crear proyecto en workspace 2
     8. Proyecto aparece solo en workspace 2
     9. Cambiar a workspace 1
     10. Proyecto no aparece (correcto)
     ```

2. **Error Scenarios** (1h)

   - Sin conexión a internet → Mensaje apropiado
   - Backend caído → Retry logic + mensaje
   - Token expirado → Auto-logout
   - Permisos insuficientes → Mensaje claro
   - Datos inválidos → Validación client-side

3. **Performance** (1h)

   - Caché de workspaces (5 min)
   - Caché de proyectos (3 min)
   - Optimistic updates en tareas
   - Lazy loading en listas largas
   - Debounce en búsqueda (300ms)

4. **Polish** (1h)
   - Loading states consistentes
   - Error messages traducidos
   - Empty states con CTAs claros
   - Success feedback (snackbars)
   - Animaciones suaves
   - Pull to refresh en todas las listas

**Entregables**:

- `TAREA_2.7_COMPLETADA.md` (documentación de testing)
- Screenshots de flujos funcionales
- Lista de bugs encontrados y resueltos

**Testing**:

- ✅ Flujo E2E completo funciona
- ✅ Múltiples workspaces funcionan
- ✅ Error handling robusto
- ✅ Performance optimizado
- ✅ UX pulida

---

## 📊 Resumen de Entregables

### Archivos Nuevos (~15)

1. `lib/core/network/api_client.dart`
2. `lib/core/network/interceptors/auth_interceptor.dart`
3. `lib/core/network/interceptors/error_interceptor.dart`
4. `lib/core/network/exceptions/api_exceptions.dart`
5. `lib/core/network/models/api_response.dart`
6. `lib/data/datasources/workspace_remote_datasource.dart`
7. `lib/data/datasources/project_remote_datasource.dart`
8. `lib/data/datasources/task_remote_datasource.dart`
9. `lib/domain/usecases/workspace/` (7 archivos)
10. `lib/domain/usecases/project/` (6 archivos)
11. `lib/domain/usecases/task/` (7 archivos)
12. `lib/presentation/bloc/project/project_bloc.dart`
13. `lib/presentation/bloc/dashboard/dashboard_bloc.dart`
14. `lib/presentation/widgets/workspace_selector.dart`
15. `lib/presentation/dialogs/create_project_dialog.dart`

### Archivos Modificados (~10)

1. `pubspec.yaml` (añadir `dio: ^5.4.0`)
2. `lib/presentation/bloc/workspace/workspace_bloc.dart` (refactor)
3. `lib/presentation/bloc/task/task_bloc.dart` (refactor)
4. `lib/presentation/screens/dashboard/dashboard_screen.dart`
5. `lib/presentation/screens/tasks/all_tasks_screen.dart`
6. `lib/presentation/screens/projects/all_projects_screen.dart`
7. `lib/presentation/screens/profile/profile_screen.dart`
8. `lib/presentation/widgets/speed_dial_fab_widget.dart`
9. `lib/presentation/dialogs/create_task_dialog.dart`
10. `lib/presentation/dialogs/create_workspace_dialog.dart`

### Documentación (~3)

1. `TAREA_2.1_COMPLETADA.md`
2. `TAREA_2.2_COMPLETADA.md`
3. ...
4. `TAREA_2.7_COMPLETADA.md`
5. `FASE_2_COMPLETADA.md`

**Total estimado**: ~2,500-3,000 líneas de código nuevo + ~5,000 líneas de documentación

---

## ⏱️ Estimación de Tiempo

| Tarea                     | Tiempo     | Complejidad |
| ------------------------- | ---------- | ----------- |
| 2.1 Networking Layer      | 3-4h       | Media       |
| 2.2 Workspace Management  | 6-7h       | Alta        |
| 2.3 Project Management    | 6-7h       | Alta        |
| 2.4 Task Management       | 6-7h       | Alta        |
| 2.5 Dashboard Integration | 3-4h       | Media       |
| 2.6 Speed Dial Actions    | 2-3h       | Baja        |
| 2.7 Testing & Polish      | 3-4h       | Media       |
| **TOTAL**                 | **29-36h** | **Alta**    |

**Recomendación**: Dividir en 5-7 días de trabajo (4-6h por día)

---

## 🎯 Criterios de Éxito

### Must Have (Crítico)

- ✅ Usuario puede crear workspace
- ✅ Usuario puede crear proyecto en workspace
- ✅ Usuario puede crear tarea en proyecto
- ✅ Dashboard muestra stats reales del workspace activo
- ✅ All Tasks muestra tareas del workspace/proyecto
- ✅ Cambiar workspace actualiza toda la UI
- ✅ Speed Dial crea entidades reales

### Should Have (Importante)

- ✅ Búsqueda en tareas funciona
- ✅ Filtros en All Tasks funcionan
- ✅ Profile muestra workspaces reales
- ✅ Manejo robusto de errores
- ✅ Loading states consistentes
- ✅ Pull to refresh en listas

### Nice to Have (Opcional)

- ⏳ Caché offline (Fase 3)
- ⏳ Notificaciones push (Fase 3)
- ⏳ Real-time updates (Fase 3)
- ⏳ Comentarios en tareas (Fase 3)

---

## 🚨 Riesgos & Mitigación

| Riesgo                        | Probabilidad | Impacto | Mitigación                     |
| ----------------------------- | ------------ | ------- | ------------------------------ |
| Backend APIs no funcionan     | Media        | Alto    | Testing temprano con Postman   |
| Token expira durante uso      | Alta         | Medio   | Refresh token logic            |
| Workspace activo se pierde    | Media        | Alto    | Persistir en SharedPreferences |
| Performance con muchas tareas | Baja         | Medio   | Paginación server-side         |
| Errores de red frecuentes     | Alta         | Medio   | Retry logic + caché            |

---

## 📝 Notas de Implementación

### Orden Recomendado

1. **Empezar por 2.1** (Networking) - Es la base de todo
2. **Seguir con 2.2** (Workspaces) - Define el contexto
3. **Luego 2.3** (Projects) - Depende de workspaces
4. **Después 2.4** (Tasks) - Depende de projects
5. **Integrar 2.5** (Dashboard) - Usa todo lo anterior
6. **Finalizar 2.6** (Speed Dial) - Rápido una vez que hay CRUDs
7. **Completar 2.7** (Testing) - Validar todo

### Dependencias Clave

```
Networking (2.1)
    ↓
Workspaces (2.2) ← Requerido por todo
    ↓
Projects (2.3) ← Requerido por Tasks
    ↓
Tasks (2.4) ← Requerido por Dashboard
    ↓
Dashboard (2.5) + Speed Dial (2.6)
    ↓
Testing (2.7)
```

### Testing Durante Desarrollo

- Usar Postman para validar APIs antes de integrar
- Console logs frecuentes durante desarrollo
- Hot reload para iteraciones rápidas
- Testing incremental (no esperar al final)

---

## ✅ Checklist de Pre-requisitos

Antes de empezar Fase 2, verificar:

- [x] **Backend corriendo** en `localhost:3001` ✅
- [x] **Fase 1 completada** (UI/UX pulida) ✅
- [ ] **API Docs revisados** (WORKSPACE_API_DOCS.md, API_DOCS.md)
- [ ] **Postman collection** para testing manual
- [ ] **Usuario de prueba** creado en backend
- [ ] **Workspace de prueba** creado (opcional)

---

## 🎉 Resultado Esperado

Al finalizar Fase 2:

```
Usuario Abre App
    ↓
Login
    ↓
Dashboard muestra:
    - Stats reales del workspace activo
    - Recent tasks reales
    - Quick actions funcionales
    ↓
Crea Workspace "Mi Empresa"
    ↓
Crea Proyecto "Proyecto Alpha"
    ↓
Crea Tarea "Implementar Login"
    ↓
Dashboard actualiza automáticamente:
    - 1 proyecto activo
    - 1 tarea pendiente
    ↓
All Tasks muestra la tarea
    ↓
Cambia estado a "En Progreso"
    ↓
Dashboard actualiza:
    - 0 tareas pendientes
    - 1 tarea en progreso
    ↓
¡FLUJO COMPLETO FUNCIONAL! 🎊
```

---

## 📞 Punto de Decisión

**¿Este plan está alineado con tu visión?**

Revisa especialmente:

1. **Orden de tareas** - ¿Te parece lógico?
2. **Estimaciones de tiempo** - ¿Son realistas?
3. **Alcance de cada tarea** - ¿Falta o sobra algo?
4. **Criterios de éxito** - ¿Qué más debería incluirse?

**Opciones**:

- ✅ **Aprobar y comenzar** con Tarea 2.1 (Networking Layer)
- 🔄 **Ajustar plan** - Dime qué cambiar
- ❓ **Preguntas** - Resuelvo cualquier duda

---

**¡Espero tu visto bueno para arrancar con Tarea 2.1! 🚀**
