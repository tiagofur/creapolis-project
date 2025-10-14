# 🗺️ PLAN MAESTRO DE DESARROLLO - CREAPOLIS

> **Plan estructurado y priorizado de todas las funcionalidades pendientes**

**Fecha**: 12 de octubre de 2025  
**Estado Actual**: Fase 3 completada (Offline Support)  
**Próximo**: Fase 4 (Funcionalidades Básicas CRUD)

---

## 📊 Resumen Ejecutivo

| Fase  | Nombre               | Duración     | Prioridad      | Dependencias | Estado        |
| ----- | -------------------- | ------------ | -------------- | ------------ | ------------- |
| **1** | UI/Theme Foundation  | -            | ✅             | Ninguna      | ✅ COMPLETADA |
| **2** | Networking (parcial) | -            | ✅             | Ninguna      | ✅ COMPLETADA |
| **3** | Offline Support      | -            | ✅             | Fase 1, 2    | ✅ COMPLETADA |
| **4** | **CRUD Básico**      | **2-3 días** | 🔴 **CRÍTICA** | Fase 3       | ⏳ PENDIENTE  |
| **5** | Vistas Detalladas    | 2 días       | 🟠 ALTA        | Fase 4       | ⏳ PENDIENTE  |
| **6** | Features Intermedias | 3-4 días     | 🟡 MEDIA       | Fase 5       | ⏳ PENDIENTE  |
| **7** | Features Avanzadas   | 5+ días      | 🟢 BAJA        | Fase 6       | ⏳ PENDIENTE  |

**Total para MVP usable**: 4-5 días de desarrollo intensivo

---

## ❌ ESTADO ACTUAL: ¿Qué falta?

### 🚫 App NO Usable Sin Esto (Fase 4)

| Funcionalidad         | Estado Repo | Estado UI  | Estado BLoC | Bloqueante |
| --------------------- | ----------- | ---------- | ----------- | ---------- |
| **Dashboard/Home**    | -           | ❌         | ❌          | 🔴 SÍ      |
| **Listar Proyectos**  | ✅          | ❌         | ❌          | 🔴 SÍ      |
| **Crear Proyecto**    | ✅          | ❌         | ❌          | 🔴 SÍ      |
| **Editar Proyecto**   | ✅          | ❌         | ❌          | 🔴 SÍ      |
| **Eliminar Proyecto** | ✅          | ❌         | ❌          | 🔴 SÍ      |
| **Listar Tareas**     | ✅          | ⚠️ Parcial | ⚠️ Parcial  | 🔴 SÍ      |
| **Crear Tarea**       | ✅          | ❌         | ❌          | 🔴 SÍ      |
| **Editar Tarea**      | ✅          | ⚠️ Parcial | ⚠️ Parcial  | 🔴 SÍ      |
| **Eliminar Tarea**    | ✅          | ❌         | ❌          | 🔴 SÍ      |

### ⚠️ Mejoran UX Pero App Funciona (Fase 5-6)

| Funcionalidad           | Prioridad | Bloqueante |
| ----------------------- | --------- | ---------- |
| **ProjectDetailScreen** | 🟠 Alta   | No         |
| **TaskDetailScreen**    | 🟠 Alta   | No         |
| **KanbanBoard**         | 🟠 Alta   | No         |
| **ProfileScreen**       | 🟡 Media  | No         |
| **Time Tracking**       | 🟡 Media  | No         |
| **Editar Workspace**    | 🟡 Media  | No         |
| **Ver Members**         | 🟡 Media  | No         |
| **Búsqueda/Filtros**    | 🟡 Media  | No         |

### 🎁 Nice-to-Have (Fase 7)

| Funcionalidad           | Prioridad | Complejidad |
| ----------------------- | --------- | ----------- |
| **Scheduler/Gantt**     | 🟢 Baja   | 🔥🔥🔥 Alta |
| **Google Calendar**     | 🟢 Baja   | 🔥🔥 Media  |
| **Analytics/Reports**   | 🟢 Baja   | 🔥🔥 Media  |
| **Notificaciones Push** | 🟢 Baja   | 🔥 Baja     |
| **Exportar Datos**      | 🟢 Baja   | 🔥 Baja     |

---

## 🎯 FASE 4: CRUD Básico (CRÍTICA - 2-3 días)

> **Objetivo**: App funcional mínima - Usuarios pueden crear workspaces, proyectos y tareas

### 📋 Checklist de Tareas

#### 4.1: Dashboard/Home Screen (6h)

**Objetivo**: Primera pantalla después de login con resumen y accesos rápidos

- [ ] **4.1.1** Crear estructura de archivos

  ```
  lib/presentation/screens/dashboard/
  ├── dashboard_screen.dart
  ├── blocs/
  │   ├── dashboard_bloc.dart
  │   ├── dashboard_event.dart
  │   └── dashboard_state.dart
  └── widgets/
      ├── workspace_summary_card.dart
      ├── quick_actions_grid.dart
      ├── recent_items_list.dart
      └── stats_overview_card.dart
  ```

- [ ] **4.1.2** Implementar DashboardBloc

  - Event: LoadDashboardData
  - Event: RefreshDashboard
  - State: DashboardLoading, DashboardLoaded, DashboardError
  - Obtener: workspaces, proyectos activos, tareas pendientes

- [ ] **4.1.3** Crear DashboardScreen

  - AppBar con saludo personalizado + avatar
  - WorkspaceSummaryCard (nombre, rol, proyectos activos)
  - QuickActionsGrid (4 botones: Nuevo Proyecto, Nueva Tarea, Ver Proyectos, Ver Tareas)
  - StatsOverviewCard (X proyectos, Y tareas, Z completadas)
  - RecentItemsList (últimos 5 proyectos/tareas modificados)

- [ ] **4.1.4** Empty states

  - Sin workspace: "Crea tu primer workspace"
  - Sin proyectos: "Comienza creando un proyecto"
  - Sin tareas: "¡Agrega tu primera tarea!"

- [ ] **4.1.5** Actualizar router

  - Hacer `/dashboard` la ruta inicial después de login
  - Cambiar redirect de `/workspaces` a `/dashboard`

- [ ] **4.1.6** Integrar con BottomNav
  - Dashboard como primera tab
  - Icono: Icons.home

**Dependencias**: WorkspaceContext, ProjectRepository, TaskRepository

---

#### 4.2: ProjectBloc + ProjectsScreen (8h)

**Objetivo**: Gestión completa de proyectos (CRUD)

##### 4.2.1: ProjectBloc (3h)

- [ ] **4.2.1.1** Crear estructura

  ```
  lib/presentation/blocs/project/
  ├── project_bloc.dart
  ├── project_event.dart
  └── project_state.dart
  ```

- [ ] **4.2.1.2** Implementar Events

  - LoadProjects(workspaceId)
  - LoadProjectById(id)
  - CreateProject({name, description, workspaceId, startDate, endDate, status})
  - UpdateProject({id, name?, description?, status?, dates?})
  - DeleteProject(id)
  - RefreshProjects

- [ ] **4.2.1.3** Implementar States

  - ProjectInitial
  - ProjectLoading
  - ProjectsLoaded(List<Project>, selectedProject?)
  - ProjectOperationSuccess(message)
  - ProjectOperationInProgress
  - ProjectError(message, projects?)

- [ ] **4.2.1.4** Implementar lógica BLoC
  - Llamar ProjectRepository para cada operación
  - Manejar errores con Either<Failure, T>
  - Actualizar cache después de operaciones exitosas
  - Emitir estados apropiados

##### 4.2.2: ProjectsScreen (3h)

- [ ] **4.2.2.1** Crear estructura

  ```
  lib/presentation/screens/projects/
  ├── projects_screen.dart
  ├── widgets/
  │   ├── project_card.dart
  │   ├── project_list_item.dart
  │   ├── project_status_filter.dart
  │   └── project_search_bar.dart
  ```

- [ ] **4.2.2.2** Implementar ProjectsScreen

  - AppBar con título "Proyectos" + botón filtro + search
  - BlocConsumer<ProjectBloc, ProjectState>
  - ListView con ProjectCard para cada proyecto
  - FloatingActionButton "Crear Proyecto"
  - Pull-to-refresh
  - Empty state: "No hay proyectos"

- [ ] **4.2.2.3** Implementar ProjectCard
  - Nombre del proyecto
  - Descripción (truncada)
  - Status badge (ACTIVE, ON_HOLD, COMPLETED, CANCELLED)
  - Fechas (inicio - fin)
  - Progreso visual (% tareas completadas)
  - Botones: Ver, Editar, Eliminar
  - onTap: Navegar a ProjectDetailScreen

##### 4.2.3: CreateProjectDialog (2h)

- [ ] **4.2.3.1** Crear `create_project_bottom_sheet.dart`

  - Form con campos:
    - Nombre (required)
    - Descripción (optional)
    - Fecha inicio (DatePicker)
    - Fecha fin (DatePicker)
    - Status (Dropdown)
  - Validaciones:
    - Nombre no vacío
    - Fecha fin >= fecha inicio
  - Botones: Cancelar, Crear

- [ ] **4.2.3.2** Implementar lógica
  - Al crear: dispatch CreateProject event
  - Mostrar loading durante creación
  - Al éxito: cerrar dialog + snackbar "Proyecto creado"
  - Al error: mostrar error en dialog

##### 4.2.4: EditProjectDialog (similar a create)

##### 4.2.5: DeleteProjectDialog (confirmación)

**Dependencias**: ProjectRepository, WorkspaceContext

---

#### 4.3: TaskBloc + TasksScreen (8h)

**Objetivo**: Gestión completa de tareas (CRUD)

##### 4.3.1: TaskBloc (3h)

- [ ] **4.3.1.1** Crear estructura

  ```
  lib/presentation/blocs/task/
  ├── task_bloc.dart
  ├── task_event.dart
  └── task_state.dart
  ```

- [ ] **4.3.1.2** Implementar Events

  - LoadTasks(projectId)
  - LoadAllTasks(workspaceId)
  - LoadTaskById(id)
  - CreateTask({title, description, projectId, status, priority, assignedUserId?, dates?, hours?})
  - UpdateTask({id, ...campos opcionales})
  - DeleteTask(id)
  - UpdateTaskStatus(id, status)
  - RefreshTasks

- [ ] **4.3.1.3** Implementar States

  - TaskInitial
  - TaskLoading
  - TasksLoaded(List<Task>, selectedTask?, filter?)
  - TaskOperationSuccess(message)
  - TaskOperationInProgress
  - TaskError(message, tasks?)

- [ ] **4.3.1.4** Implementar lógica BLoC
  - Similar a ProjectBloc
  - Filtrado local por status/priority
  - Ordenamiento (por fecha, prioridad, status)

##### 4.3.2: TasksScreen (3h)

- [ ] **4.3.2.1** Crear estructura

  ```
  lib/presentation/screens/tasks/
  ├── tasks_screen.dart
  ├── all_tasks_screen.dart (ya existe, actualizar)
  ├── widgets/
  │   ├── task_card.dart
  │   ├── task_list_item.dart
  │   ├── task_status_filter.dart
  │   ├── task_priority_badge.dart
  │   └── task_search_bar.dart
  ```

- [ ] **4.3.2.2** Implementar TasksScreen

  - AppBar con filtros (Status, Priority, Project)
  - BlocConsumer<TaskBloc, TaskState>
  - ListView con TaskCard
  - FloatingActionButton "Crear Tarea"
  - Pull-to-refresh
  - Empty state

- [ ] **4.3.2.3** Implementar TaskCard
  - Título
  - Proyecto padre (nombre + color)
  - Status badge (dropdown interactivo)
  - Priority badge
  - Fecha límite (si existe)
  - Avatar assignee (si existe)
  - Progreso (si está en progreso)
  - Botones: Ver, Editar, Eliminar

##### 4.3.3: CreateTaskDialog (2h)

- [ ] Campos:
  - Título (required)
  - Descripción
  - Proyecto (Dropdown) (required)
  - Status (Dropdown)
  - Priority (Dropdown)
  - Assignee (Dropdown de users del workspace)
  - Fecha inicio/fin
  - Estimación de horas

##### 4.3.4: EditTaskDialog (similar)

##### 4.3.5: DeleteTaskDialog (confirmación)

**Dependencias**: TaskRepository, ProjectBloc, WorkspaceContext

---

#### 4.4: Integración y Testing (2h)

- [ ] **4.4.1** Actualizar navegación

  - Dashboard → ProjectsScreen
  - Dashboard → TasksScreen
  - ProjectCard → ProjectDetailScreen (placeholder si no existe)
  - TaskCard → TaskDetailScreen (placeholder si no existe)

- [ ] **4.4.2** Actualizar BottomNav

  - Tab 0: Dashboard
  - Tab 1: Proyectos
  - Tab 2: Tareas
  - Tab 3: Workspaces
  - Tab 4: Perfil (placeholder)

- [ ] **4.4.3** Testing manual

  - Crear workspace → crear proyecto → crear tarea
  - Editar proyecto
  - Editar tarea
  - Eliminar tarea
  - Eliminar proyecto
  - Verificar offline works
  - Verificar sincronización

- [ ] **4.4.4** Fixes de bugs encontrados

---

### 📊 Métricas Fase 4

| Métrica                   | Valor Estimado                 |
| ------------------------- | ------------------------------ |
| **Archivos nuevos**       | ~25                            |
| **Líneas de código**      | ~3,500                         |
| **Screens**               | 3 (Dashboard, Projects, Tasks) |
| **BLoCs**                 | 3 (Dashboard, Project, Task)   |
| **Dialogs**               | 6 (Create/Edit/Delete × 2)     |
| **Widgets reutilizables** | ~15                            |
| **Duración**              | 24-30 horas                    |

---

## 🎯 FASE 5: Vistas Detalladas (ALTA - 2 días)

> **Objetivo**: Mejorar UX con vistas dedicadas para ver/editar entidades

### 5.1: ProjectDetailScreen (6h)

- [ ] Mostrar todos los detalles del proyecto
- [ ] Lista de tareas del proyecto
- [ ] Gráfico de progreso
- [ ] Timeline de eventos
- [ ] Botones: Editar, Eliminar, Compartir
- [ ] Tabs: Tareas, Información, Actividad

### 5.2: TaskDetailScreen (6h)

- [ ] Mostrar todos los detalles de la tarea
- [ ] Edición in-place de campos
- [ ] Comentarios (si existe en backend)
- [ ] Historial de cambios
- [ ] Archivos adjuntos (futuro)
- [ ] Botones: Editar, Eliminar, Duplicar

### 5.3: KanbanBoard (6h)

- [ ] Columnas por status (PLANNED, IN_PROGRESS, COMPLETED, BLOCKED, CANCELLED)
- [ ] Drag & Drop entre columnas
- [ ] Actualizar status automáticamente
- [ ] Filtros por proyecto/assignee/priority
- [ ] Vista compacta de TaskCard

### 5.4: ProfileScreen (4h)

- [ ] Avatar del usuario
- [ ] Datos personales (nombre, email)
- [ ] Estadísticas (X tareas completadas, Y horas logueadas)
- [ ] Configuración (theme, notificaciones)
- [ ] Botón logout

**Duración**: 22 horas (~3 días)

---

## 🎯 FASE 6: Features Intermedias (MEDIA - 3-4 días)

### 6.1: Time Tracking Básico (6h)

- [ ] Botón "Start Timer" en TaskDetailScreen
- [ ] Widget cronómetro flotante
- [ ] Botón "Stop" y "Finish"
- [ ] Guardar tiempo en backend
- [ ] Ver historial de time logs
- [ ] Comparar estimado vs real

### 6.2: Editar/Eliminar Workspace (4h)

- [ ] Dialog para editar workspace
- [ ] Confirmación para eliminar
- [ ] Actualizar WorkspaceBloc
- [ ] Actualizar UI

### 6.3: Gestión de Members (8h)

- [ ] MembersScreen
- [ ] Lista de miembros con roles
- [ ] Invitar miembro (email)
- [ ] Cambiar rol
- [ ] Eliminar miembro
- [ ] Ver invitaciones pendientes

### 6.4: Búsqueda y Filtros Avanzados (6h)

- [ ] Barra de búsqueda global
- [ ] Filtros combinados (status + priority + project + assignee)
- [ ] Guardado de filtros favoritos
- [ ] Búsqueda por texto en título/descripción

### 6.5: Notificaciones Locales (4h)

- [ ] flutter_local_notifications
- [ ] Notificar cuando tarea asignada
- [ ] Notificar cuando tarea vence hoy
- [ ] Notificar cuando sync completa (offline)

**Duración**: 28 horas (~3.5 días)

---

## 🎯 FASE 7: Features Avanzadas (BAJA - 5+ días)

### 7.1: Scheduler/Gantt (16h)

- [ ] Integrar backend de scheduling
- [ ] Vista Gantt interactiva
- [ ] Calcular cronograma inicial
- [ ] Re-planificar desde tarea
- [ ] Dependencias visuales
- [ ] Detección de conflictos

### 7.2: Google Calendar Integration (12h)

- [ ] OAuth flow
- [ ] Leer eventos del calendario
- [ ] Detectar disponibilidad
- [ ] Sincronización bidireccional
- [ ] Configuración de sincronización

### 7.3: Analytics y Reports (10h)

- [ ] Dashboard de métricas
- [ ] Gráficos de progreso
- [ ] Análisis de workload
- [ ] Reports exportables (PDF/CSV)
- [ ] Filtros por rango de fechas

### 7.4: Otros (8h)

- [ ] Drag & Drop avanzado
- [ ] Shortcuts de teclado
- [ ] Modo dark (si no existe)
- [ ] Internacionalización (i18n)
- [ ] Exportar/Importar datos

**Duración**: 46+ horas (~6 días)

---

## 📈 Gráfico de Dependencias

```
FASE 1 (UI/Theme) ✅
  ↓
FASE 2 (Networking) ✅
  ↓
FASE 3 (Offline) ✅
  ↓
FASE 4 (CRUD Básico) ← BLOQUEANTE PARA APP USABLE
  ├── Dashboard (4.1)
  ├── ProjectBloc + ProjectsScreen (4.2) ← Base para 5.1, 6.4
  ├── TaskBloc + TasksScreen (4.3) ← Base para 5.2, 5.3, 6.1
  └── Integración (4.4)
  ↓
FASE 5 (Vistas Detalladas) ← MEJORA UX
  ├── ProjectDetailScreen (5.1)
  ├── TaskDetailScreen (5.2) ← Base para 6.1
  ├── KanbanBoard (5.3)
  └── ProfileScreen (5.4)
  ↓
FASE 6 (Features Intermedias)
  ├── Time Tracking (6.1) ← Requiere 5.2
  ├── Workspace Edit/Delete (6.2)
  ├── Members Management (6.3)
  ├── Search & Filters (6.4)
  └── Local Notifications (6.5)
  ↓
FASE 7 (Features Avanzadas)
  ├── Scheduler/Gantt (7.1) ← Requiere backend scheduler
  ├── Google Calendar (7.2)
  ├── Analytics (7.3)
  └── Otros (7.4)
```

---

## 🚀 Plan de Ejecución Recomendado

### Semana 1 (5 días)

**Día 1-2**: FASE 4.1 + 4.2 (Dashboard + Projects)

- Día 1 AM: Dashboard (4.1)
- Día 1 PM: ProjectBloc (4.2.1)
- Día 2 AM: ProjectsScreen (4.2.2)
- Día 2 PM: Dialogs (4.2.3-5)

**Día 3-4**: FASE 4.3 (Tasks)

- Día 3 AM: TaskBloc (4.3.1)
- Día 3 PM: TasksScreen (4.3.2)
- Día 4 AM: Dialogs (4.3.3-5)
- Día 4 PM: Integración (4.4)

**Día 5**: Testing + Fase 5.1-5.2 (Detail Screens)

- AM: Testing exhaustivo de Fase 4
- PM: ProjectDetailScreen (5.1)

### Semana 2 (5 días)

**Día 6-7**: FASE 5.3-5.4 (Kanban + Profile)

- Día 6: KanbanBoard (5.3)
- Día 7: ProfileScreen (5.4)

**Día 8-10**: FASE 6 (Features Intermedias)

- Día 8: Time Tracking (6.1) + Workspace Edit (6.2)
- Día 9: Members Management (6.3)
- Día 10: Search & Filters (6.4) + Notifications (6.5)

### Semana 3+ (Opcional - Features Avanzadas)

**Día 11-13**: FASE 7.1 (Scheduler/Gantt)
**Día 14-15**: FASE 7.2 (Google Calendar)
**Día 16-17**: FASE 7.3 (Analytics)
**Día 18**: FASE 7.4 (Polish final)

---

## ✅ Checklist de Verificación por Fase

### FASE 4 - Ready for Production? ☑️

- [ ] Usuario puede crear workspace
- [ ] Usuario puede crear proyecto
- [ ] Usuario puede crear tarea
- [ ] Usuario puede listar proyectos
- [ ] Usuario puede listar tareas
- [ ] Usuario puede editar proyecto
- [ ] Usuario puede editar tarea
- [ ] Usuario puede eliminar proyecto
- [ ] Usuario puede eliminar tarea
- [ ] Dashboard muestra resumen
- [ ] Navegación funciona correctamente
- [ ] Offline mode funciona
- [ ] Sincronización funciona
- [ ] 0 errores críticos

**Si todos ✅ → APP USABLE PARA TESTING BETA**

### FASE 5 - Production Ready? ☑️

- [ ] Vista detallada de proyecto
- [ ] Vista detallada de tarea
- [ ] Kanban board funcional
- [ ] Drag & drop funciona
- [ ] Perfil de usuario completo
- [ ] UX pulida
- [ ] Animaciones suaves

**Si todos ✅ → APP LISTA PARA PRODUCCIÓN**

### FASE 6 - Feature Complete? ☑️

- [ ] Time tracking funciona
- [ ] Editar/eliminar workspace
- [ ] Gestión de miembros
- [ ] Búsqueda avanzada
- [ ] Notificaciones

**Si todos ✅ → APP FEATURE-COMPLETE**

### FASE 7 - Enterprise Ready? ☑️

- [ ] Scheduler/Gantt
- [ ] Google Calendar
- [ ] Analytics
- [ ] Reports exportables

**Si todos ✅ → APP ENTERPRISE-READY**

---

## 📝 Notas Importantes

### Aceleradores de Desarrollo

1. **Copiar patrones**: WorkspaceBloc puede servir como template para ProjectBloc y TaskBloc
2. **Reutilizar widgets**: Crear widgets base (BaseCard, BaseListItem, BaseDialog)
3. **Generadores**: Usar build_runner para reducir boilerplate
4. **Snippets**: Crear snippets de VSCode para BLoC pattern

### Decisiones de Arquitectura

1. **BLoC por entidad**: ProjectBloc, TaskBloc, WorkspaceBloc (ya existe)
2. **Repository ya existe**: No necesitamos crear, solo usar
3. **Offline-first**: Siempre intentar remote → fallback cache (ya implementado)
4. **UI reactiva**: StreamBuilder/BlocConsumer para todo

### Testing Strategy

- **Fase 4**: Testing manual exhaustivo (crítico)
- **Fase 5**: Testing de UX y usabilidad
- **Fase 6**: Testing de features específicas
- **Fase 7**: Testing de integración end-to-end

---

## 🎯 MVP Definition

**MVP = Fase 4 completada**

Un usuario puede:

1. ✅ Registrarse / Login
2. ✅ Crear workspace
3. ✅ Crear proyectos
4. ✅ Crear tareas
5. ✅ Ver dashboard con resumen
6. ✅ Listar proyectos y tareas
7. ✅ Editar proyectos y tareas
8. ✅ Eliminar proyectos y tareas
9. ✅ Funcionar offline
10. ✅ Sincronizar al volver online

**Esto es suficiente para:**

- Testing beta con usuarios reales
- Validar el producto
- Obtener feedback
- Iterar rápidamente

---

## 🔄 Proceso de Desarrollo (por tarea)

### Template de Implementación

Para cada feature nueva:

1. **Planificar** (5 min)

   - Definir archivos a crear
   - Definir dependencias
   - Definir acceptance criteria

2. **Crear estructura** (10 min)

   - Crear carpetas y archivos vacíos
   - Imports básicos

3. **Implementar lógica** (60-80% del tiempo)

   - BLoC/Repository/Service
   - Manejo de errores
   - Estados

4. **Implementar UI** (20-40% del tiempo)

   - Screen
   - Widgets
   - Styling

5. **Integrar** (10 min)

   - Router
   - Navigation
   - DI

6. **Testing** (15 min)

   - Happy path
   - Error cases
   - Edge cases

7. **Refactoring** (10 min)
   - Cleanup
   - Extract widgets
   - Documentation

---

## 📊 Tracking de Progreso

Actualizar este archivo después de completar cada sub-tarea:

### FASE 4 Progress: 6/30 (20%)

**Status**: 🟡 EN PROGRESO
**Última actualización**: 12 de octubre de 2025

- [x] ✅ 4.1.1 Dashboard estructura
- [x] ✅ 4.1.2 DashboardBloc
- [x] ✅ 4.1.3 DashboardScreen
- [x] ✅ 4.1.4 Empty states
- [x] ✅ 4.1.5 Router update
- [x] ✅ 4.1.6 BottomNav integration
- [ ] 4.2.1.1 ProjectBloc estructura
- [ ] 4.2.1.2 Project Events
- [ ] 4.2.1.3 Project States
- [ ] 4.2.1.4 Project lógica
- [ ] 4.2.2.1 ProjectsScreen estructura
- [ ] 4.2.2.2 ProjectsScreen implementación
- [ ] 4.2.2.3 ProjectCard
- [ ] 4.2.3.1 CreateProjectDialog
- [ ] 4.2.3.2 CreateProject lógica
- [ ] 4.2.4 EditProjectDialog
- [ ] 4.2.5 DeleteProjectDialog
- [ ] 4.3.1.1 TaskBloc estructura
- [ ] 4.3.1.2 Task Events
- [ ] 4.3.1.3 Task States
- [ ] 4.3.1.4 Task lógica
- [ ] 4.3.2.1 TasksScreen estructura
- [ ] 4.3.2.2 TasksScreen implementación
- [ ] 4.3.2.3 TaskCard
- [ ] 4.3.3 CreateTaskDialog
- [ ] 4.3.4 EditTaskDialog
- [ ] 4.3.5 DeleteTaskDialog
- [ ] 4.4.1 Navegación update
- [ ] 4.4.2 BottomNav update
- [ ] 4.4.3 Testing manual
- [ ] 4.4.4 Bug fixes

---

**🚀 ¡Empecemos con la Fase 4! La app estará usable en 2-3 días de desarrollo intensivo.**

**Siguiente paso**: Ejecutar tarea 4.1.1 (Dashboard estructura)
