# 🔄 Task API Integration - Session Summary

**Fecha:** 2025-10-12  
**Sesión:** Backend ↔ Frontend Integration  
**Estado:** ⏳ EN PROGRESO (80% completado)

---

## ✅ Completado

### 1. Documentación API Mapping

- ✅ Creado `documentation/TASK_API_MAPPING.md`
- ✅ Documentadas discrepancias entre Backend y Frontend
- ✅ Identificado problema del campo `priority` (Frontend tiene, Backend no)
- ✅ Plan de implementación por fases

### 2. Actualización de Task Remote Data Source

- ✅ Actualizada interface `TaskRemoteDataSource`
- ✅ Agregado parámetro `projectId` a métodos:
  - `getTaskById(projectId, taskId)`
  - `updateTask({required projectId, required taskId, ...})`
  - `deleteTask(projectId, taskId)`
  - `getTaskDependencies(projectId, taskId)`
- ✅ Actualizado `createDependency` y `deleteDependency` con projectId
- ✅ Implementación de `TaskRemoteDataSourceImpl` con rutas correctas:
  - `GET /projects/:projectId/tasks/:taskId`
  - `PUT /projects/:projectId/tasks/:taskId`
  - `DELETE /projects/:projectId/tasks/:taskId`
  - `POST /projects/:projectId/tasks/:taskId/dependencies`
  - `DELETE /projects/:projectId/tasks/:taskId/dependencies/:predecessorId`

### 3. Actualización de Task Repository

- ✅ Actualizada interface `TaskRepository` con nuevas firmas
- ✅ Actualizada implementación `TaskRepositoryImpl`
- ✅ Todos los métodos ahora pasan projectId correctamente

### 4. Actualización de Task State

- ✅ Agregado campo `projectId` a `TasksLoaded`
- ✅ Actualizado `copyWith()` para manejar projectId
- ✅ Actualizado `props` para incluir projectId en comparaciones

---

## ⏳ Pendiente

### 5. Actualización de Task Bloc (ACTUAL)

- ⏳ Actualizar todos los emisores de `TasksLoaded` para incluir projectId
- ⏳ Actualizar llamadas a repository:
  - `getTaskById(currentState.projectId, event.taskId)`
  - `updateTask(projectId: currentState.projectId, taskId: event.id, ...)`
  - `deleteTask(currentState.projectId, event.taskId)`
- ⏳ Extraer projectId del state actual en métodos de operaciones

**Archivos a modificar:**

- `lib/features/tasks/presentation/blocs/task_bloc.dart` (~450 líneas)

**Errores actuales:** 12 compile errors

**Patrón de fix:**

```dart
// ANTES:
emit(TasksLoaded(tasks: tasks, filteredTasks: tasks));
final result = await taskRepository.getTaskById(event.taskId);
await taskRepository.deleteTask(event.taskId);
await taskRepository.updateTask(id: event.id, ...);

// DESPUÉS:
emit(TasksLoaded(projectId: event.projectId, tasks: tasks, filteredTasks: tasks));
final result = await taskRepository.getTaskById(currentState.projectId, event.taskId);
await taskRepository.deleteTask(currentState.projectId, event.taskId);
await taskRepository.updateTask(projectId: currentState.projectId, taskId: event.id, ...);
```

---

## 📊 Estadísticas de Cambios

| Archivo                       | Líneas Modificadas | Estado           |
| ----------------------------- | ------------------ | ---------------- |
| `task_remote_datasource.dart` | ~150 líneas        | ✅ COMPLETADO    |
| `task_repository.dart`        | ~30 líneas         | ✅ COMPLETADO    |
| `task_repository_impl.dart`   | ~100 líneas        | ✅ COMPLETADO    |
| `task_state.dart`             | ~20 líneas         | ✅ COMPLETADO    |
| `task_bloc.dart`              | ~50 líneas         | ⏳ PENDIENTE     |
| **TOTAL**                     | **~350 líneas**    | **80% completo** |

---

## 🐛 Issues Identificados

### Issue 1: Campo Priority no existe en Backend

**Descripción:** Frontend tiene enum `TaskPriority` pero Backend (Prisma) no tiene este campo.

**Impacto:**

- ❌ No se puede persistir priority al crear/actualizar tareas
- ❌ Filtros por prioridad solo funcionan en frontend
- ⚠️ Priority se pierde al sincronizar con servidor

**Solución propuesta:**

```prisma
// prisma/schema.prisma
enum TaskPriority {
  LOW
  MEDIUM
  HIGH
  CRITICAL
}

model Task {
  // ... campos existentes
  priority TaskPriority @default(MEDIUM)
}
```

**Migración requerida:**

```bash
cd backend
npx prisma migrate dev --name add_task_priority
```

**Estado:** 📝 Documentado en `issues/ISSUE_TASK_PRIORITY.md` (TODO)

---

### Issue 2: Endpoints de Scheduler no existen

**Descripción:** Frontend tiene métodos para cálculo de cronograma pero Backend no tiene implementación CPM.

**Métodos afectados:**

- `calculateSchedule(projectId)` → `POST /projects/:id/schedule/calculate`
- `rescheduleProject(projectId, taskId)` → `POST /projects/:id/schedule/reschedule`

**Estado:** Feature futura - Fase 5 o posterior

---

## 🔄 Próximos Pasos

### Inmediato (5-10 minutos)

1. ⏳ Actualizar TaskBloc con projectId en todos los métodos
2. ⏳ Compilar y verificar 0 errores
3. ✅ Commit de cambios: "feat(tasks): Integrate backend API endpoints"
4. ✅ Push a GitHub

### Testing (15-20 minutos)

1. ⏳ Fix DI issue (documentado en `issues/ISSUE_DI_DATASOURCES.md`)
2. ⏳ Ejecutar aplicación
3. ⏳ Probar CRUD completo de tareas:
   - Crear tarea
   - Listar tareas
   - Editar tarea
   - Eliminar tarea
   - Cambiar status desde card

### Backend (30-45 minutos)

1. ❌ Agregar campo `priority` a Prisma schema
2. ❌ Migración de base de datos
3. ❌ Actualizar validators en backend
4. ❌ Testing de endpoints con priority

---

## 📝 Notas Técnicas

### Cambio de Arquitectura: projectId en State

**Antes:**

- TaskBloc no guardaba projectId
- Métodos individuales no tenían contexto del proyecto
- Imposible hacer operaciones CRUD sin pasar projectId en cada event

**Después:**

- `TasksLoaded` incluye `projectId`
- Métodos de operación extraen projectId del state actual
- Arquitectura más robusta y consistente

**Beneficios:**

- ✅ Todas las operaciones tienen contexto del proyecto
- ✅ Events más simples (no necesitan projectId excepto LoadTasks)
- ✅ State más rico y autodescriptivo
- ✅ Facilita debugging (siempre sabemos en qué proyecto estamos)

### Endpoints Backend ✅ Verificados

Todos los endpoints Task CRUD están implementados en:

- ✅ `backend/src/controllers/task.controller.js`
- ✅ `backend/src/services/task.service.js`
- ✅ `backend/src/routes/task.routes.js`
- ✅ Registrado en `backend/src/server.js`

**Rutas activas:**

```
GET    /api/projects/:projectId/tasks
POST   /api/projects/:projectId/tasks
GET    /api/projects/:projectId/tasks/:taskId
PUT    /api/projects/:projectId/tasks/:taskId
DELETE /api/projects/:projectId/tasks/:taskId
POST   /api/projects/:projectId/tasks/:taskId/dependencies
DELETE /api/projects/:projectId/tasks/:taskId/dependencies/:predecessorId
```

**Autenticación:** Todos requieren JWT token en header `Authorization: Bearer <token>`

---

## 🎯 Objetivo Final

Tener funcionalidad completa de Tasks CRUD conectada con backend real:

1. ✅ Frontend puede crear tareas → Backend las persiste en PostgreSQL
2. ✅ Frontend lista tareas → Backend las sirve desde DB
3. ✅ Frontend edita tareas → Backend actualiza en DB
4. ✅ Frontend elimina tareas → Backend las borra de DB
5. ✅ Filtros y búsqueda funcionan en frontend (datos del backend)
6. ✅ Cache offline funciona con datos reales del backend

---

**Última actualización:** 2025-10-12 20:30  
**Próxima sesión:** Completar TaskBloc + Testing CRUD  
**Estimado:** 20-30 minutos más
