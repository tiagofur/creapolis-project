# Fix: Error al Parsear Tareas del Backend

## Problema

Al crear o cargar tareas desde el backend, la aplicación Flutter mostraba el siguiente error:

```
TypeError: null: type 'Null' is not a subtype of type 'int'
```

## Causa

El backend estaba enviando las respuestas con:

1. **Campos en camelCase** (ej: `projectId`, `startDate`, `endDate`) pero el modelo de Flutter esperaba **snake_case** (`project_id`, `start_date`, `end_date`)

2. **Campo `priority` faltante**: El backend no estaba enviando el campo `priority` en las respuestas, pero el modelo lo esperaba como obligatorio

3. **Campos `startDate` y `endDate` null**: El backend enviaba estos campos como `null` pero el modelo los esperaba como valores no nulos

## Ejemplo de Respuesta del Backend

```json
{
  "success": true,
  "message": "Task created successfully",
  "data": {
    "id": 1,
    "title": "terminar app",
    "description": "terminar la app de las tareas.",
    "status": "PLANNED",
    "estimatedHours": 8, // ❌ camelCase
    "actualHours": 0, // ❌ camelCase
    "startDate": null, // ❌ null
    "endDate": null, // ❌ null
    "projectId": 2, // ❌ camelCase
    "assigneeId": null,
    "createdAt": "2025-10-08T16:59:38.710Z", // ❌ camelCase
    "updatedAt": "2025-10-08T16:59:38.710Z", // ❌ camelCase
    "assignee": null,
    "predecessors": []
    // ❌ priority no está presente
  }
}
```

## Solución

Se actualizó el método `TaskModel.fromJson()` en `lib/data/models/task_model.dart` para:

### 1. Manejar ambos formatos de nombres (camelCase y snake_case)

```dart
factory TaskModel.fromJson(Map<String, dynamic> json) {
  // El backend puede enviar tanto camelCase como snake_case
  final projectId = json['projectId'] ?? json['project_id'];
  final estimatedHours = json['estimatedHours'] ?? json['estimated_hours'];
  final actualHours = json['actualHours'] ?? json['actual_hours'];
  final startDateStr = json['startDate'] ?? json['start_date'];
  final endDateStr = json['endDate'] ?? json['end_date'];
  final createdAtStr = json['createdAt'] ?? json['created_at'];
  final updatedAtStr = json['updatedAt'] ?? json['updated_at'];

  // ...
}
```

### 2. Hacer el campo `priority` opcional con valor por defecto

```dart
priority: json['priority'] != null
    ? priorityFromString(json['priority'] as String)
    : TaskPriority.medium, // Default si no viene
```

### 3. Manejar `startDate` y `endDate` opcionales

```dart
startDate: startDateStr != null
    ? DateTime.parse(startDateStr as String)
    : DateTime.now(), // Default a fecha actual si no viene

endDate: endDateStr != null
    ? DateTime.parse(endDateStr as String)
    : DateTime.now().add(const Duration(days: 7)), // Default a 7 días después
```

### 4. Manejar diferentes formatos de dependencias

```dart
dependencyIds: json['dependency_ids'] != null
    ? List<int>.from(json['dependency_ids'] as List)
    : (json['predecessors'] != null && json['predecessors'] is List
        ? (json['predecessors'] as List)
            .map((p) => p['id'] as int)
            .toList()
        : const []),
```

## Archivo Modificado

- `creapolis_app/lib/data/models/task_model.dart`

## Resultado

✅ Las tareas ahora se pueden crear y cargar correctamente sin errores de tipo

✅ El modelo es compatible con:

- Respuestas en camelCase (como las envía el backend actual)
- Respuestas en snake_case (por compatibilidad futura)
- Campos opcionales con valores por defecto sensatos

## Prueba

Después de aplicar el fix:

1. Crear una nueva tarea → ✅ Funciona
2. Cargar lista de tareas → ✅ Funciona
3. Ver detalle de tarea → ✅ Funciona

## Notas

- Se usó `flutter clean` para limpiar el cache de compilación antes de probar
- Se requirió un full restart de Flutter para aplicar los cambios (no solo hot reload)

## Mejoras Futuras Recomendadas

### Opción 1: Estandarizar el Backend

Sería ideal que el backend siempre envíe el campo `priority` incluso si tiene un valor por defecto.

**Backend**: `backend/src/controllers/task.controller.js`

```javascript
// Asegurar que priority siempre se envíe
const taskResponse = {
  ...task,
  priority: task.priority || "MEDIUM", // Default
};
```

### Opción 2: Usar Serialización Automática

Considerar usar paquetes como `json_serializable` o `freezed` para generar automáticamente el código de serialización y evitar este tipo de errores en el futuro.

```yaml
# pubspec.yaml
dependencies:
  json_annotation: ^4.8.1

dev_dependencies:
  build_runner: ^2.4.6
  json_serializable: ^6.7.1
```

## Relacionado

- [FIX_BACKEND_RESPONSE_STRUCTURE.md](./FIX_BACKEND_RESPONSE_STRUCTURE.md)
- [FIX_LOGIN_RESPONSE_STRUCTURE.md](./FIX_LOGIN_RESPONSE_STRUCTURE.md)
