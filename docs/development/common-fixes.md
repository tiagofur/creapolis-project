# Soluciones Comunes - Creapolis

> **Última actualización**: Octubre 11, 2025

## 📋 Índice

- [Errores de API y Backend](#errores-de-api-y-backend)
- [Errores de Frontend Flutter](#errores-de-frontend-flutter)
- [Errores de Base de Datos](#errores-de-base-de-datos)
- [Errores de Parsing y Tipos](#errores-de-parsing-y-tipos)

---

## 🔧 Errores de API y Backend

### 1. Error 404 en /api/auth/me

**Síntoma**: `404 Not Found` al intentar obtener perfil de usuario

**Causa**: Token JWT inválido o expirado

**Solución**:

```javascript
// Verificar que el token se envía correctamente
headers: {
  'Authorization': `Bearer ${token}`
}

// Verificar expiración del token
const decoded = jwt.verify(token, process.env.JWT_SECRET);
```

**Archivos relacionados**:

- `backend/src/middleware/auth.middleware.js`
- `backend/src/routes/auth.routes.js`

---

### 2. Error en Estructura de Respuesta de Login

**Problema**: El backend devolvía `{success, message, data: {user, token}}` pero Flutter esperaba `{user, token}` directamente.

**Solución aplicada**:

```dart
// lib/data/datasources/auth_remote_datasource.dart
Future<UserModel> login(String email, String password) async {
  final response = await _client.post(
    '/auth/login',
    data: {'email': email, 'password': password},
  );

  // Extraer el campo 'data' de la respuesta
  final data = response.data['data']; // ⬅️ FIX

  if (data == null) {
    throw ServerException('Invalid response structure');
  }

  return UserModel.fromJson(data);
}
```

**Archivos modificados**:

- `lib/data/datasources/auth_remote_datasource.dart`
- `lib/data/datasources/project_remote_datasource.dart`

---

### 3. Error 404 en Task Detail

**Problema**: Necesitar `projectId` para obtener una tarea por ID era innecesario.

**Solución**: Nueva ruta agregada en el backend.

```javascript
// backend/src/routes/timelog.routes.js
router.get("/api/tasks/:taskId", authenticateJWT, async (req, res) => {
  const { taskId } = req.params;
  const userId = req.user.id;

  const task = await prisma.task.findUnique({
    where: { id: parseInt(taskId) },
    include: {
      project: { include: { members: true } },
      assignee: true,
    },
  });

  // Verificar acceso del usuario
  const hasAccess = task.project.members.some((m) => m.id === userId);
  if (!hasAccess) {
    return res.status(403).json({ error: "Access denied" });
  }

  res.json({ success: true, data: task });
});
```

**Frontend actualizado**:

```dart
// lib/data/datasources/task_remote_datasource.dart
Future<TaskModel> getTaskById(int taskId) async {
  // Nueva ruta: /api/tasks/:id (sin projectId)
  final response = await _client.get('/tasks/$taskId');
  final data = response.data['data'];
  return TaskModel.fromJson(data);
}
```

---

### 4. Error en Mensajes de Error del Backend

**Problema**: Mensajes de error genéricos y poco informativos.

**Solución**: Estandarización de respuestas de error.

```javascript
// backend/src/middleware/errorHandler.js
const errorHandler = (err, req, res, next) => {
  console.error(err.stack);

  const statusCode = err.statusCode || 500;
  const message = err.message || "Internal Server Error";

  res.status(statusCode).json({
    success: false,
    error: {
      message,
      ...(process.env.NODE_ENV === "development" && { stack: err.stack }),
    },
  });
};

module.exports = errorHandler;
```

**Uso en rutas**:

```javascript
// Ejemplo: validación de entrada
if (!email || !password) {
  return res.status(400).json({
    success: false,
    error: { message: "Email and password are required" },
  });
}
```

---

## 📱 Errores de Frontend Flutter

### 1. Error en Parsing de Task Model

**Problema**: TaskModel esperaba campos obligatorios que el backend no siempre enviaba (camelCase vs snake_case).

**Solución**: Modelo flexible que acepta ambos formatos.

```dart
// lib/data/models/task_model.dart
class TaskModel extends Task {
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',

      // Acepta camelCase o snake_case
      status: TaskStatus.values.firstWhere(
        (e) => e.toString() == 'TaskStatus.${json['status'] ?? json['task_status'] ?? 'PLANNED'}',
        orElse: () => TaskStatus.PLANNED,
      ),

      // Campos opcionales con defaults
      priority: json['priority'] != null
        ? TaskPriority.values.firstWhere(
            (e) => e.toString() == 'TaskPriority.${json['priority']}',
            orElse: () => TaskPriority.MEDIUM,
          )
        : TaskPriority.MEDIUM,

      // Fechas opcionales
      startDate: json['startDate'] != null || json['start_date'] != null
        ? DateTime.parse(json['startDate'] ?? json['start_date'])
        : null,

      endDate: json['endDate'] != null || json['end_date'] != null
        ? DateTime.parse(json['endDate'] ?? json['end_date'])
        : null,

      // Horas con defaults
      estimatedHours: (json['estimatedHours'] ?? json['estimated_hours'] ?? 0).toDouble(),
      actualHours: (json['actualHours'] ?? json['actual_hours'] ?? 0).toDouble(),

      // Relaciones opcionales
      assignee: json['assignee'] != null
        ? UserModel.fromJson(json['assignee'])
        : null,

      // Dependencias flexibles
      dependencies: json['dependencies'] != null
        ? (json['dependencies'] is List
            ? (json['dependencies'] as List).map((d) => DependencyModel.fromJson(d)).toList()
            : <DependencyModel>[])
        : <DependencyModel>[],
    );
  }
}
```

---

### 2. Error Null Type en Project Model

**Problema**: Backend no enviaba `startDate`, `endDate`, `status` pero Flutter los esperaba como obligatorios.

**Solución**: Campos opcionales con valores por defecto.

```dart
// lib/data/models/project_model.dart
class ProjectModel extends Project {
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',

      // Campos opcionales con defaults
      startDate: json['startDate'] != null
        ? DateTime.parse(json['startDate'])
        : DateTime.now(), // Default: hoy

      endDate: json['endDate'] != null
        ? DateTime.parse(json['endDate'])
        : DateTime.now().add(const Duration(days: 30)), // Default: +30 días

      status: json['status'] != null
        ? ProjectStatus.values.firstWhere(
            (e) => e.toString() == 'ProjectStatus.${json['status']}',
            orElse: () => ProjectStatus.PLANNED,
          )
        : ProjectStatus.PLANNED, // Default: PLANNED

      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),

      members: json['members'] != null
        ? (json['members'] as List).map((m) => UserModel.fromJson(m)).toList()
        : <UserModel>[],
    );
  }
}
```

**Datasource actualizado**:

```dart
// lib/data/datasources/project_remote_datasource.dart
Future<ProjectModel> createProject(String name, String description) async {
  // No enviar campos que el backend no soporta
  final response = await _client.post(
    '/projects',
    data: {
      'name': name,
      'description': description,
      // ❌ NO enviar: startDate, endDate, status, managerId
    },
  );

  final data = response.data['data'];
  return ProjectModel.fromJson(data);
}
```

---

### 3. Error en Task List Loading

**Problema**: Loading infinito al cargar lista de tareas.

**Causa**: No se manejaba correctamente el estado vacío.

**Solución**:

```dart
// lib/presentation/blocs/task_bloc.dart
if (state is TasksLoaded) {
  emit(TasksLoading()); // Mostrar loading
}

try {
  final tasks = await _getTasksByProjectUseCase(projectId);

  if (tasks.isEmpty) {
    emit(const TasksLoaded([])); // Estado vacío explícito
  } else {
    emit(TasksLoaded(tasks));
  }
} catch (e) {
  emit(TaskError(e.toString()));
}
```

**Widget con estados claros**:

```dart
BlocBuilder<TaskBloc, TaskState>(
  builder: (context, state) {
    if (state is TasksLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is TasksLoaded) {
      if (state.tasks.isEmpty) {
        return const EmptyStateWidget(message: 'No tasks yet');
      }
      return ListView.builder(...);
    }

    if (state is TaskError) {
      return ErrorWidget(message: state.message);
    }

    return const SizedBox.shrink();
  },
)
```

---

## 🗄️ Errores de Base de Datos

### 1. Error de Puerto PostgreSQL

**Problema**: Puerto 5432 ya en uso o PostgreSQL no accesible.

**Verificación**:

```powershell
# Ver procesos usando puerto 5432
Get-NetTCPConnection -LocalPort 5432

# Ver contenedores Docker
docker ps | Select-String "postgres"
```

**Solución**:

```powershell
# Opción 1: Reiniciar contenedor
docker-compose restart postgres

# Opción 2: Recrear contenedor
docker-compose down
docker-compose up -d postgres

# Opción 3: Cambiar puerto en .env
# backend/.env
DATABASE_URL="postgresql://creapolis:password@localhost:5433/creapolis_db"
# Y en docker-compose.yml:
# ports:
#   - "5433:5432"
```

---

### 2. Error de Credenciales de DB

**Síntoma**: `password authentication failed`

**Solución**:

```powershell
# Verificar credenciales en .env
cd backend
cat .env | Select-String "DATABASE_URL"

# Debe ser:
DATABASE_URL="postgresql://creapolis:creapolis_password_2024@localhost:5432/creapolis_db?schema=public"
```

**Recrear contenedor con credenciales correctas**:

```powershell
docker-compose down -v  # ⚠️ BORRA DATOS
docker-compose up -d postgres
```

---

### 3. Migraciones Prisma Fallidas

**Problema**: Errores al ejecutar `prisma migrate dev`

**Diagnóstico**:

```powershell
cd backend

# Ver estado de migraciones
npm run prisma:migrate status

# Ver logs de PostgreSQL
docker logs creapolis-postgres --tail 50
```

**Solución**:

```powershell
# Opción 1: Reset completo (⚠️ BORRA DATOS)
npm run prisma:migrate reset

# Opción 2: Deploy manual
npm run prisma:migrate deploy

# Opción 3: Resolver conflictos
npm run prisma:migrate resolve --applied "nombre_migracion"
```

---

## 🔄 Errores de Parsing y Tipos

### 1. TimeLog Parsing Error

**Problema**: Respuesta anidada de backend no manejada correctamente.

**Solución**:

```dart
// lib/data/datasources/timelog_remote_datasource.dart
Future<List<TimeLogModel>> getTimeLogsByTask(int taskId) async {
  final response = await _client.get('/tasks/$taskId/timelogs');

  // Backend retorna: { success: true, data: [...] }
  final data = response.data['data'] as List? ?? [];

  if (data.isEmpty) {
    return [];
  }

  return data.map((json) => TimeLogModel.fromJson(json)).toList();
}
```

---

### 2. Dependency Type Enum Error

**Problema**: Enum `DependencyType` no reconocía valores del backend.

**Solución**:

```dart
// lib/domain/entities/dependency.dart
enum DependencyType {
  FINISH_TO_START,
  START_TO_START,
  FINISH_TO_FINISH,
  START_TO_FINISH;

  static DependencyType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'FINISH_TO_START':
      case 'FS':
        return DependencyType.FINISH_TO_START;
      case 'START_TO_START':
      case 'SS':
        return DependencyType.START_TO_START;
      case 'FINISH_TO_FINISH':
      case 'FF':
        return DependencyType.FINISH_TO_FINISH;
      case 'START_TO_FINISH':
      case 'SF':
        return DependencyType.START_TO_FINISH;
      default:
        return DependencyType.FINISH_TO_START; // Default
    }
  }
}
```

---

## 📚 Referencias

- [Backend Response Structure Fix](../history/FIX_BACKEND_RESPONSE_STRUCTURE.md)
- [Task Model Parsing Fix](../history/FIX_TASK_MODEL_PARSING.md)
- [Environment Setup](../setup/ENVIRONMENT_SETUP.md)

---

**Última actualización**: Octubre 11, 2025  
**Mantenedor**: Equipo Creapolis
