# 📡 Task API Mapping - Frontend ↔ Backend

**Fecha:** 2025-10-12  
**Versión Backend:** 1.0.0  
**Versión Frontend:** 1.0.0

---

## 🎯 Objetivo

Documentar el mapeo entre los endpoints del backend (Express/Prisma) y los métodos del frontend (Flutter/Dart) para la funcionalidad de Tareas.

---

## ✅ Endpoints Implementados (CRUD Básico)

| #   | Método Frontend                | Backend Route                                   | Status       |
| --- | ------------------------------ | ----------------------------------------------- | ------------ |
| 1   | `getTasksByProject(projectId)` | `GET /api/projects/:projectId/tasks`            | ✅ MAPPED    |
| 2   | `getTaskById(id)`              | `GET /api/projects/:projectId/tasks/:taskId`    | ⚠️ NEEDS FIX |
| 3   | `createTask(...)`              | `POST /api/projects/:projectId/tasks`           | ✅ MAPPED    |
| 4   | `updateTask(...)`              | `PUT /api/projects/:projectId/tasks/:taskId`    | ⚠️ NEEDS FIX |
| 5   | `deleteTask(id)`               | `DELETE /api/projects/:projectId/tasks/:taskId` | ⚠️ NEEDS FIX |

---

## ⚠️ Problemas Identificados

### Problema 1: projectId faltante en métodos update/delete/getById

**Frontend actual:**

```dart
Future<TaskModel> getTaskById(int id) async {
  // ❌ Usa /tasks/:id (no existe en backend)
  final response = await _apiClient.get('/tasks/$id');
}

Future<TaskModel> updateTask({required int id, ...}) async {
  // ❌ Usa /tasks/:id (no existe en backend)
  final response = await _apiClient.put('/tasks/$id', data: data);
}

Future<void> deleteTask(int id) async {
  // ❌ Usa /tasks/:id (no existe en backend)
  await _apiClient.delete('/tasks/$id');
}
```

**Backend esperado:**

- `GET /api/projects/:projectId/tasks/:taskId`
- `PUT /api/projects/:projectId/tasks/:taskId`
- `DELETE /api/projects/:projectId/tasks/:taskId`

**Solución:**

El TaskRepository necesita pasar `projectId` a estos métodos. Hay 2 opciones:

**Opción A: Cambiar firma de métodos (RECOMENDADA)**

```dart
// En TaskRepository
Future<Either<Failure, Task>> getTaskById(int projectId, int taskId);
Future<Either<Failure, Task>> updateTask({required int projectId, required int id, ...});
Future<Either<Failure, void>> deleteTask(int projectId, int taskId);
```

**Opción B: Obtener projectId del Task cacheado (ACTUAL - TEMPORAL)**

```dart
// En TaskRemoteDataSource
Future<TaskModel> getTaskById(int id) async {
  // 1. Buscar tarea en caché para obtener projectId
  final cachedTask = await _cacheDataSource.getCachedTaskById(id);
  final projectId = cachedTask?.projectId ?? 0;

  // 2. Usar endpoint correcto
  final response = await _apiClient.get('/projects/$projectId/tasks/$id');
}
```

**Decisión:** Usar **Opción B temporalmente** para no romper la interfaz del repositorio. En futuras refactorizaciones se puede migrar a Opción A.

---

## ❌ Endpoints NO Implementados en Backend

| #   | Método Frontend                        | Endpoint Esperado                               | Alternativa Backend                                                                           |
| --- | -------------------------------------- | ----------------------------------------------- | --------------------------------------------------------------------------------------------- |
| 6   | `getTaskDependencies(taskId)`          | `GET /tasks/:taskId/dependencies`               | ✅ Incluido en `GET /projects/:projectId/tasks/:taskId` (campo `predecessors` y `successors`) |
| 7   | `createDependency(...)`                | `POST /tasks/dependencies`                      | ✅ `POST /projects/:projectId/tasks/:taskId/dependencies`                                     |
| 8   | `deleteDependency(dependencyId)`       | `DELETE /tasks/dependencies/:id`                | ✅ `DELETE /projects/:projectId/tasks/:taskId/dependencies/:predecessorId`                    |
| 9   | `calculateSchedule(projectId)`         | `POST /projects/:projectId/schedule/calculate`  | ❌ NO EXISTE (Feature futura - Scheduler CPM)                                                 |
| 10  | `rescheduleProject(projectId, taskId)` | `POST /projects/:projectId/schedule/reschedule` | ❌ NO EXISTE (Feature futura - Scheduler CPM)                                                 |

### Endpoints de Dependencias

**Frontend actual:**

```dart
// ❌ Endpoints incorrectos
GET /tasks/:taskId/dependencies
POST /tasks/dependencies
DELETE /tasks/dependencies/:dependencyId
```

**Backend real:**

```javascript
// ✅ Endpoints correctos
POST   /api/projects/:projectId/tasks/:taskId/dependencies
DELETE /api/projects/:projectId/tasks/:taskId/dependencies/:predecessorId
```

**Nota:** El backend NO tiene GET específico de dependencias porque las incluye automáticamente en GET task by ID:

```json
{
  "data": {
    "id": 1,
    "title": "Tarea ejemplo",
    "predecessors": [
      {
        "id": 123,
        "predecessorId": 5,
        "predecessor": {
          "id": 5,
          "title": "Tarea predecesora",
          "status": "COMPLETED"
        }
      }
    ],
    "successors": [...]
  }
}
```

**Solución:** Actualizar `getTaskDependencies()` para extraer del task detail en lugar de endpoint separado.

---

## 🔧 Implementación de Fixes

### Fix 1: Actualizar TaskRemoteDataSource para rutas correctas

**Archivo:** `lib/data/datasources/task_remote_datasource.dart`

**Cambios necesarios:**

1. **getTaskById:** Agregar parámetro `projectId` o obtenerlo del caché
2. **updateTask:** Agregar parámetro `projectId` o obtenerlo del caché
3. **deleteTask:** Agregar parámetro `projectId` o obtenerlo del caché
4. **getTaskDependencies:** Cambiar para obtener de task detail
5. **createDependency:** Actualizar ruta a `/projects/:projectId/tasks/:taskId/dependencies`
6. **deleteDependency:** Actualizar ruta a `/projects/:projectId/tasks/:taskId/dependencies/:predecessorId`

### Fix 2: Actualizar TaskRepository (Opcional - Futuro)

Agregar `projectId` a las firmas de métodos para evitar dependencia del caché.

---

## 📋 Mapeo de Campos Backend ↔ Frontend

### Campos que coinciden ✅

| Backend (Prisma) | Frontend (Dart)  | Tipo                                   |
| ---------------- | ---------------- | -------------------------------------- |
| `id`             | `id`             | int                                    |
| `title`          | `title`          | String                                 |
| `description`    | `description`    | String?                                |
| `status`         | `status`         | enum (PLANNED, IN_PROGRESS, COMPLETED) |
| `estimatedHours` | `estimatedHours` | double                                 |
| `actualHours`    | `actualHours`    | double                                 |
| `startDate`      | `startDate`      | DateTime?                              |
| `endDate`        | `endDate`        | DateTime?                              |
| `projectId`      | `projectId`      | int                                    |
| `assigneeId`     | `assignedUserId` | int?                                   |
| `createdAt`      | `createdAt`      | DateTime                               |
| `updatedAt`      | `updatedAt`      | DateTime                               |

### Campos diferentes ⚠️

| Backend (Prisma) | Frontend (Dart)  | Acción                                     |
| ---------------- | ---------------- | ------------------------------------------ |
| `assigneeId`     | `assignedUserId` | ✅ TaskModel mapea correctamente           |
| (no existe)      | `priority`       | ⚠️ Backend no tiene prioridad, Frontend sí |

### Campo Priority - Discrepancia

**Frontend Task:**

```dart
enum TaskPriority { low, medium, high, critical }
final TaskPriority priority;
```

**Backend Task (Prisma):**

```prisma
model Task {
  // NO tiene campo priority
}
```

**Soluciones:**

1. **Agregar priority al backend** (RECOMENDADO)

```prisma
enum TaskPriority {
  LOW
  MEDIUM
  HIGH
  CRITICAL
}

model Task {
  // ...
  priority TaskPriority @default(MEDIUM)
}
```

2. **Eliminar priority del frontend** (NO recomendado - ya está en uso)

3. **Mantener priority solo en frontend temporalmente** (ACTUAL)
   - Frontend usa priority para filtros y UI
   - No se envía al backend en CREATE/UPDATE
   - Se pierde al sincronizar con servidor

**Decisión:** Documentar como TODO pendiente. Agregar priority al backend en próxima migración de Prisma.

---

## 🚀 Plan de Implementación

### Fase 1: Fixes Críticos (HOY) ✅

1. ✅ Documentar mapeo actual
2. ⏳ Actualizar rutas en TaskRemoteDataSource
3. ⏳ Actualizar método getTaskDependencies
4. ⏳ Actualizar métodos de dependencias
5. ⏳ Testing manual de CRUD

### Fase 2: Migración Backend (FUTURO)

1. ❌ Agregar campo `priority` a Prisma schema
2. ❌ Migración de base de datos
3. ❌ Actualizar validators en backend
4. ❌ Actualizar controllers para manejar priority

### Fase 3: Features Avanzadas (FUTURO)

1. ❌ Implementar Scheduler CPM en backend
2. ❌ Endpoint `POST /projects/:id/schedule/calculate`
3. ❌ Endpoint `POST /projects/:id/schedule/reschedule`
4. ❌ Actualizar frontend para usar estos endpoints

---

## 📝 Notas Adicionales

### Autenticación

Todos los endpoints requieren token JWT en header:

```
Authorization: Bearer <token>
```

### Formato de respuesta

Backend usa formato estándar:

```json
{
  "success": true,
  "message": "Tasks retrieved successfully",
  "data": [...] // o {} para objetos
}
```

TaskRemoteDataSource extrae correctamente con `response.data?['data']`.

### Manejo de errores

Backend retorna errores HTTP:

- `400` - Validación fallida
- `401` - No autenticado
- `403` - Sin permisos
- `404` - Recurso no encontrado
- `500` - Error del servidor

ApiClient convierte automáticamente a excepciones de Dart.

---

**Última actualización:** 2025-10-12  
**Próxima revisión:** Después de implementar Fase 1  
**Responsable:** Flutter Developer + Backend Developer
