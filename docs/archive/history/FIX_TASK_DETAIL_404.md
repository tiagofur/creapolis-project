# Fix: Error 404 al obtener tarea individual y parseo de timelogs

## Fecha: 2025-10-08

## Problemas

### 1. Error 404: Route GET /api/tasks/:id not found

Al intentar ver el detalle de una tarea, la aplicación intentaba hacer:

```
GET /api/tasks/2
```

Pero el backend no tenía esta ruta implementada. Solo existía:

```
GET /api/projects/:projectId/tasks/:taskId
```

### 2. Error de parseo en timelogs

```
TypeError: Instance of '_JsonMap': type '_JsonMap' is not a subtype of type 'List<dynamic>'
```

El endpoint `/api/tasks/:taskId/timelogs` retornaba:

```json
{
  "success": true,
  "message": "Time logs retrieved successfully",
  "data": []
}
```

Pero el código Flutter esperaba directamente un array sin el wrapper de `data`.

## Soluciones Aplicadas

### 1. Nueva ruta en el backend para obtener tarea por ID

**Archivo modificado**: `backend/src/routes/timelog.routes.js`

Se agregó una nueva ruta que permite obtener una tarea por ID sin necesidad de especificar el `projectId`:

```javascript
/**
 * @route   GET /api/tasks/:taskId
 * @desc    Get task by ID (without needing projectId)
 * @access  Private
 */
router.get("/:taskId", taskIdValidation, validate, async (req, res, next) => {
  try {
    const { taskId } = req.params;
    const userId = req.user.userId;

    // Import prisma to query directly
    const { default: prisma } = await import("../config/database.js");

    // Find task with project membership verification
    const task = await prisma.task.findFirst({
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

    if (!task) {
      const { ErrorResponses } = await import("../utils/errors.js");
      throw ErrorResponses.notFound("Task not found or you don't have access");
    }

    res.status(200).json({
      success: true,
      message: "Task retrieved successfully",
      data: task,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    next(error);
  }
});
```

**Características**:

- ✅ No requiere `projectId` en la URL
- ✅ Verifica que el usuario tenga acceso al proyecto de la tarea
- ✅ Retorna la tarea con todas las relaciones necesarias
- ✅ Sigue el formato estándar de respuesta con `{success, message, data, timestamp}`

### 2. Fix en TimeLogRemoteDataSource

**Archivo modificado**: `creapolis_app/lib/data/datasources/time_log_remote_datasource.dart`

Se actualizó el método `getTimeLogsByTask` para extraer correctamente el campo `data`:

```dart
@override
Future<List<TimeLogModel>> getTimeLogsByTask(int taskId) async {
  try {
    final response = await _client.get('/tasks/$taskId/timelogs');

    // Extraer el campo 'data' de la respuesta anidada
    final responseData = response.data as Map<String, dynamic>;
    final dataRaw = responseData['data'];

    // Si data es null o no es una lista, retornar lista vacía
    if (dataRaw == null || dataRaw is! List) {
      return [];
    }

    final data = dataRaw as List;
    return data
        .map((json) => TimeLogModel.fromJson(json as Map<String, dynamic>))
        .toList();
  } on AuthException {
    rethrow;
  } on NotFoundException {
    rethrow;
  } catch (e) {
    throw ServerException('Error al obtener time logs: ${e.toString()}');
  }
}
```

### 3. TaskRemoteDataSource actualizado

**Archivo modificado**: `creapolis_app/lib/data/datasources/task_remote_datasource.dart`

Se restauró el método `getTaskById` para usar la nueva ruta del backend:

```dart
@override
Future<TaskModel> getTaskById(int id) async {
  try {
    // Usar la ruta /api/tasks/:id que no requiere projectId
    final response = await _client.get('/tasks/$id');

    // Extraer el campo 'data' de la respuesta anidada
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;

    return TaskModel.fromJson(data);
  } on AuthException {
    rethrow;
  } on NotFoundException {
    rethrow;
  } catch (e) {
    throw ServerException('Error al obtener tarea: ${e.toString()}');
  }
}
```

## Resultado

✅ **Backend**: Nueva ruta `/api/tasks/:id` disponible
✅ **Flutter**: `getTaskById` funciona correctamente
✅ **Flutter**: `getTimeLogsByTask` parsea correctamente la respuesta
✅ **Seguridad**: Se verifica que el usuario tenga acceso al proyecto de la tarea

## Pruebas

Después de aplicar los cambios:

1. Detalle de tarea → ✅ Funciona
2. Lista de time logs → ✅ Funciona
3. Verificación de acceso → ✅ Funciona

## Notas Técnicas

### Backend iniciado localmente

Para aplicar los cambios al backend fue necesario:

```powershell
# 1. Detener contenedor Docker del backend
docker stop creapolis-backend

# 2. Iniciar backend localmente
cd backend
npm start
```

El backend ahora corre localmente en el puerto 3000 con los nuevos cambios aplicados.

### Flutter hot reload

Para Flutter, basta con hacer hot reload (`r`) o hot restart (`R`) para que tome los cambios del datasource.

## Mejoras Futuras

### Opción 1: Centralizar la lógica de getTaskById

Actualmente la lógica está en el archivo de rutas. Sería mejor moverla al `TaskService`:

```javascript
// backend/src/services/task.service.js
async getTaskByIdWithoutProject(taskId, userId) {
  const task = await prisma.task.findFirst({
    where: {
      id: taskId,
      project: {
        members: {
          some: { userId },
        },
      },
    },
    include: { /* ... */ },
  });

  if (!task) {
    throw ErrorResponses.notFound("Task not found or you don't have access");
  }

  return task;
}
```

### Opción 2: Unificar rutas de tareas

Considerar si tiene sentido tener rutas de tareas en dos lugares diferentes:

- `/api/projects/:projectId/tasks/*`
- `/api/tasks/*`

Podría ser confuso para futuros desarrolladores.

## Archivos Modificados

```
backend/src/routes/timelog.routes.js
creapolis_app/lib/data/datasources/task_remote_datasource.dart
creapolis_app/lib/data/datasources/time_log_remote_datasource.dart
```

## Relacionado

- [FIX_TASK_MODEL_PARSING.md](./FIX_TASK_MODEL_PARSING.md)
- [FIX_BACKEND_RESPONSE_STRUCTURE.md](./FIX_BACKEND_RESPONSE_STRUCTURE.md)
