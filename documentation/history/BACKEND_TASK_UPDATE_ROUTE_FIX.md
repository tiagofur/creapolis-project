# 🔧 BACKEND API - TASK UPDATE ROUTE FIX

## 📋 Problema Identificado

La aplicación Flutter intentaba actualizar una tarea usando la ruta:

```
PUT http://localhost:3001/api/tasks/1
```

Pero el backend **NO tenía esta ruta implementada**, causando un error **404 Not Found**:

```javascript
{
  "error": "Not Found",
  "message": "Route PUT /api/tasks/1 not found"
}
```

### Error en Logs de Flutter

```
╔╣ Request ║ PUT
║  http://localhost:3001/api/tasks/1
╚══════════════════════════════════════════════════════════════════════════════════════════╝
╔ Body
╟ status: COMPLETED
╚══════════════════════════════════════════════════════════════════════════════════════════╝

╔╣ DioError ║ Status: 404 Not Found ║ Time: 88 ms
║  http://localhost:3001/api/tasks/1
╚══════════════════════════════════════════════════════════════════════════════════════════╝
╔ DioExceptionType.badResponse
║    {
║         "error": "Not Found",
║         "message": "Route PUT /api/tasks/1 not found"
║    }
╚══════════════════════════════════════════════════════════════════════════════════════════╝

⛔ TaskBloc: Error al actualizar tarea - Error al actualizar tarea: DioException [bad response]: Not Found
⛔ Error: Not Found
```

## 🔍 Análisis de la Causa Raíz

### Rutas Existentes en el Backend

**Archivo**: `backend/src/server.js`

```javascript
// API routes
app.use("/api/auth", authRoutes);
app.use("/api/workspaces", workspaceRoutes);
app.use("/api/projects", projectRoutes);
app.use("/api/projects/:projectId/tasks", taskRoutes); // ← Requiere projectId
app.use("/api/tasks", taskTimeLogRoutes); // ← Solo time logs
app.use("/api/timelogs", timelogRouter);
app.use("/api/integrations/google", googleCalendarRoutes);
```

### Rutas de Tareas Disponibles

#### Con `projectId` (task.routes.js)

```javascript
GET    /api/projects/:projectId/tasks         - Listar tareas
POST   /api/projects/:projectId/tasks         - Crear tarea
GET    /api/projects/:projectId/tasks/:taskId - Obtener tarea
PUT    /api/projects/:projectId/tasks/:taskId - Actualizar tarea ✅ (REQUIERE projectId)
DELETE /api/projects/:projectId/tasks/:taskId - Eliminar tarea
```

#### Sin `projectId` (timelog.routes.js - ANTES DEL FIX)

```javascript
POST /api/tasks/:taskId/start    - Iniciar tracking
POST /api/tasks/:taskId/stop     - Detener tracking
POST /api/tasks/:taskId/finish   - Finalizar tarea
GET  /api/tasks/:taskId/timelogs - Obtener time logs
GET  /api/tasks/:taskId          - Obtener tarea ✅
PUT  /api/tasks/:taskId          - ❌ NO EXISTÍA (404 Error)
```

### Discrepancia entre Frontend y Backend

**Flutter (task_remote_datasource.dart)** - Línea 171:

```dart
Future<TaskModel> updateTask({
  required int id,
  // ... otros parámetros
}) async {
  // ...
  final response = await _client.put('/tasks/$id', data: data);
  //                                   ^^^^^^^^^^
  //                                   NO incluye projectId
  // ...
}
```

**Backend esperaba**:

- Ruta completa: `PUT /api/projects/:projectId/tasks/:taskId`
- Pero Flutter llamaba: `PUT /api/tasks/:taskId`

### ¿Por Qué Flutter No Usa projectId?

El método `updateTask` en Flutter **NO recibe el projectId** como parámetro:

```dart
abstract class TaskRemoteDataSource {
  Future<TaskModel> updateTask({
    required int id,           // ← Solo taskId
    String? title,
    String? description,
    TaskStatus? status,
    // ... NO hay projectId
  });
}
```

Esto tiene sentido porque:

1. El `taskId` es único en toda la base de datos
2. Ya existe `GET /api/tasks/:taskId` que funciona sin projectId
3. El backend puede validar el acceso del usuario a través del taskId

## ✅ Solución Implementada

Agregué la ruta `PUT /api/tasks/:taskId` en el archivo `timelog.routes.js` para permitir actualizar tareas **sin necesidad del projectId**.

### Código Agregado

**Archivo**: `backend/src/routes/timelog.routes.js`

```javascript
/**
 * @route   PUT /api/tasks/:taskId
 * @desc    Update task (without needing projectId)
 * @access  Private
 */
router.put("/:taskId", taskIdValidation, validate, async (req, res, next) => {
  try {
    const { taskId } = req.params;
    const userId = req.user.userId;

    // Import prisma to query directly
    const { default: prisma } = await import("../config/database.js");

    // Verify task exists and user has access
    const existingTask = await prisma.task.findFirst({
      where: {
        id: parseInt(taskId),
        project: {
          members: {
            some: {
              userId,
            },
          },
        },
      },
    });

    if (!existingTask) {
      const { ErrorResponses } = await import("../utils/errors.js");
      throw ErrorResponses.notFound("Task not found or you don't have access");
    }

    // Prepare update data
    const updateData = {};

    if (req.body.title !== undefined) updateData.title = req.body.title;
    if (req.body.description !== undefined)
      updateData.description = req.body.description;
    if (req.body.status !== undefined) updateData.status = req.body.status;
    if (req.body.priority !== undefined)
      updateData.priority = req.body.priority;
    if (req.body.startDate !== undefined)
      updateData.startDate = req.body.startDate
        ? new Date(req.body.startDate)
        : null;
    if (req.body.endDate !== undefined)
      updateData.endDate = req.body.endDate ? new Date(req.body.endDate) : null;
    if (req.body.estimatedHours !== undefined)
      updateData.estimatedHours = req.body.estimatedHours;
    if (req.body.actualHours !== undefined)
      updateData.actualHours = req.body.actualHours;
    if (req.body.assigneeId !== undefined)
      updateData.assigneeId = req.body.assigneeId;

    // Update task
    const updatedTask = await prisma.task.update({
      where: { id: parseInt(taskId) },
      data: updateData,
      include: {
        assignee: {
          select: {
            id: true,
            name: true,
            email: true,
            role: true,
          },
        },
        predecessors: {
          include: {
            predecessor: {
              select: {
                id: true,
                title: true,
                status: true,
              },
            },
          },
        },
        successors: {
          include: {
            successor: {
              select: {
                id: true,
                title: true,
                status: true,
              },
            },
          },
        },
        _count: {
          select: {
            timeLogs: true,
          },
        },
      },
    });

    res.status(200).json({
      success: true,
      message: "Task updated successfully",
      data: updatedTask,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    next(error);
  }
});
```

### Características de la Solución

#### 1. ✅ Validación de Acceso

```javascript
const existingTask = await prisma.task.findFirst({
  where: {
    id: parseInt(taskId),
    project: {
      members: {
        some: {
          userId, // ← Verifica que el usuario es miembro del proyecto
        },
      },
    },
  },
});
```

El backend verifica que:

- La tarea existe
- El usuario tiene acceso al proyecto de la tarea
- Si no cumple, devuelve 404

#### 2. ✅ Actualización Parcial (PATCH-like)

```javascript
const updateData = {};

if (req.body.title !== undefined) updateData.title = req.body.title;
if (req.body.description !== undefined)
  updateData.description = req.body.description;
// ... solo actualiza campos enviados
```

Solo actualiza los campos que se envían en el request, no sobrescribe todo.

#### 3. ✅ Respuesta Completa

```javascript
include: {
  assignee: { ... },
  predecessors: { ... },
  successors: { ... },
  _count: { ... },
}
```

Devuelve la tarea actualizada con todas las relaciones necesarias.

## 📊 Flujo de Actualización Corregido

### Antes del Fix ❌

```
Flutter App
    ↓
PUT /api/tasks/1 {status: "COMPLETED"}
    ↓
Backend Router
    ↓
❌ 404 Not Found - Route PUT /api/tasks/1 not found
    ↓
DioException: Not Found
    ↓
⛔ TaskBloc: Error al actualizar tarea
```

### Después del Fix ✅

```
Flutter App
    ↓
PUT /api/tasks/1 {status: "COMPLETED"}
    ↓
Backend: /api/tasks (timelog.routes.js)
    ↓
router.put("/:taskId", ...)
    ↓
1. Verificar taskId = 1
2. Verificar userId tiene acceso al proyecto
3. Actualizar task.status = "COMPLETED"
4. Devolver tarea actualizada
    ↓
✅ 200 OK {success: true, data: {...}}
    ↓
Flutter: TaskBloc → TaskLoaded
```

## 🧪 Pruebas a Realizar

### Escenario 1: Cambiar estado de tarea ✅

**Request**:

```bash
curl -X PUT http://localhost:3001/api/tasks/1 \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"status": "IN_PROGRESS"}'
```

**Respuesta Esperada**:

```json
{
  "success": true,
  "message": "Task updated successfully",
  "data": {
    "id": 1,
    "title": "Crear Sistema",
    "status": "IN_PROGRESS"
    // ... resto de campos
  },
  "timestamp": "2025-10-10T21:30:00.000Z"
}
```

### Escenario 2: Actualización parcial ✅

**Request**:

```bash
curl -X PUT http://localhost:3001/api/tasks/1 \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"estimatedHours": 150}'
```

**Comportamiento**:

- Solo actualiza `estimatedHours`
- NO modifica otros campos (title, description, etc.)

### Escenario 3: Tarea sin acceso ❌

**Request**:

```bash
curl -X PUT http://localhost:3001/api/tasks/999 \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"status": "COMPLETED"}'
```

**Respuesta Esperada**:

```json
{
  "error": {
    "message": "Task not found or you don't have access"
  }
}
```

**Status Code**: 404

### Escenario 4: Desde Flutter App ✅

1. Abrir TaskDetailScreen
2. Hacer clic en pestaña "Time Tracking"
3. Hacer clic en "Iniciar"
4. Hacer clic en "Finalizar"
5. **Verificar**:
   - Estado de la tarea cambia a "COMPLETED"
   - NO aparece error 404
   - Se muestra confirmación exitosa

## 📝 Campos Actualizables

La ruta acepta los siguientes campos opcionales:

| Campo            | Tipo     | Descripción                                      |
| ---------------- | -------- | ------------------------------------------------ |
| `title`          | string   | Título de la tarea                               |
| `description`    | string   | Descripción detallada                            |
| `status`         | enum     | `PLANNED`, `IN_PROGRESS`, `COMPLETED`, `ON_HOLD` |
| `priority`       | enum     | `LOW`, `MEDIUM`, `HIGH`, `URGENT`                |
| `startDate`      | ISO 8601 | Fecha de inicio                                  |
| `endDate`        | ISO 8601 | Fecha de finalización                            |
| `estimatedHours` | number   | Horas estimadas                                  |
| `actualHours`    | number   | Horas trabajadas                                 |
| `assigneeId`     | number   | ID del usuario asignado                          |

## 🔒 Seguridad

### Validación de Acceso

```javascript
project: {
  members: {
    some: {
      userId,  // ← Solo usuarios miembros del proyecto
    },
  },
},
```

**Protecciones**:

1. ✅ Usuario debe estar autenticado (middleware `authenticate`)
2. ✅ Usuario debe ser miembro del proyecto de la tarea
3. ✅ TaskId debe existir
4. ✅ Validación de entrada con `taskIdValidation`

### Prevención de Escalada de Privilegios

Si un usuario intenta actualizar una tarea de un proyecto al que no pertenece:

```
Usuario A (no miembro) → PUT /api/tasks/123 (del Proyecto B)
    ↓
Backend verifica membresía
    ↓
❌ 404 Not Found (oculta existencia de la tarea)
```

No se revela si la tarea existe o no, solo se dice "not found or you don't have access".

## 💡 Alternativas Consideradas

### Opción 1: Modificar Flutter para usar projectId ❌

```dart
// RECHAZADA: Requiere cambios en toda la arquitectura
Future<TaskModel> updateTask({
  required int id,
  required int projectId,  // ← Agregar esto
  // ...
}) async {
  final response = await _client.put(
    '/projects/$projectId/tasks/$id',
    data: data,
  );
}
```

**Problemas**:

- Requiere cambiar múltiples capas (datasource, repository, usecase, bloc)
- El projectId no siempre está disponible en el contexto
- Ya existe `GET /api/tasks/:taskId` sin projectId

### Opción 2: Agregar ruta en backend (ELEGIDA) ✅

```javascript
// ✅ ELEGIDA: Cambio mínimo, consistente con GET /api/tasks/:taskId
router.put("/:taskId", ..., async (req, res, next) => {
  // Actualizar tarea sin necesitar projectId en la URL
});
```

**Ventajas**:

- ✅ Un solo cambio en el backend
- ✅ Consistente con `GET /api/tasks/:taskId`
- ✅ No rompe código existente
- ✅ Flutter no necesita cambios

## 📊 Rutas de Tareas Actualizadas

### Con `projectId`

```
GET    /api/projects/:projectId/tasks         - Listar tareas
POST   /api/projects/:projectId/tasks         - Crear tarea
GET    /api/projects/:projectId/tasks/:taskId - Obtener tarea
PUT    /api/projects/:projectId/tasks/:taskId - Actualizar tarea
DELETE /api/projects/:projectId/tasks/:taskId - Eliminar tarea
```

### Sin `projectId` (Nuevas/Actualizadas)

```
GET  /api/tasks/:taskId          - Obtener tarea ✅ (Ya existía)
PUT  /api/tasks/:taskId          - Actualizar tarea ✅ (AGREGADA)
POST /api/tasks/:taskId/start    - Iniciar tracking
POST /api/tasks/:taskId/stop     - Detener tracking
POST /api/tasks/:taskId/finish   - Finalizar tarea
GET  /api/tasks/:taskId/timelogs - Obtener time logs
```

## ✅ Estado Final

- ✅ Ruta `PUT /api/tasks/:taskId` implementada
- ✅ Validación de acceso por membresía de proyecto
- ✅ Actualización parcial de campos
- ✅ Respuesta con relaciones completas
- ✅ Sin errores de compilación
- ✅ Servidor backend reiniciado

## 🚀 Próximos Pasos

1. **Probar en Flutter**:

   - Abrir TaskDetailScreen
   - Cambiar estado de tarea
   - Verificar que no hay error 404

2. **Validar Time Tracking**:

   - Iniciar tracking
   - Detener tracking
   - Finalizar tarea
   - Verificar que el estado se actualiza correctamente

3. **Verificar Logs**:
   - Backend debe mostrar `PUT /api/tasks/1 200 OK`
   - Flutter debe mostrar respuesta exitosa sin DioException

---

**Fecha**: 2025-01-10  
**Archivo**: `backend/src/routes/timelog.routes.js`  
**Líneas agregadas**: 82-182 (100 líneas)  
**Autor**: GitHub Copilot  
**Versión**: 1.0
