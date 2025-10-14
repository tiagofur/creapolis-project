# Fix: Error al Crear Proyecto - Campos Opcionales

## Problema
Al crear un proyecto, la aplicación Flutter lanzaba el error:
```
TypeError: null: type 'Null' is not a subtype of type 'String'
```

## Análisis del Problema

### Backend
El modelo `Project` en Prisma (base de datos) tiene esta estructura:
```prisma
model Project {
  id          Int      @id @default(autoincrement())
  name        String
  description String?
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  // ...
}
```

**Campos que el backend NO tiene**: `startDate`, `endDate`, `status`, `managerId`

### Frontend (Flutter)
El modelo `ProjectModel` esperaba estos campos como obligatorios:
```dart
factory ProjectModel.fromJson(Map<String, dynamic> json) {
  return ProjectModel(
    startDate: DateTime.parse(json['startDate'] as String), // ❌ Error: null
    endDate: DateTime.parse(json['endDate'] as String),     // ❌ Error: null
    status: _statusFromString(json['status'] as String),    // ❌ Error: null
    // ...
  );
}
```

Cuando el backend devolvía un proyecto sin estos campos, intentaba parsear `null` como `String`, causando el error.

## Solución Implementada

### 1. Modelo Flexible (ProjectModel)
**Archivo**: `creapolis_app/lib/data/models/project_model.dart`

Modificado `fromJson` para manejar campos opcionales con valores por defecto:

```dart
factory ProjectModel.fromJson(Map<String, dynamic> json) {
  // El backend puede no incluir startDate, endDate y status
  // Si no están presentes, usar valores por defecto
  final now = DateTime.now();
  final defaultEndDate = now.add(const Duration(days: 30));
  
  return ProjectModel(
    id: json['id'] as int,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    startDate: json['startDate'] != null 
        ? DateTime.parse(json['startDate'] as String)
        : now,  // ✅ Fecha actual si no existe
    endDate: json['endDate'] != null
        ? DateTime.parse(json['endDate'] as String)
        : defaultEndDate,  // ✅ +30 días si no existe
    status: json['status'] != null
        ? _statusFromString(json['status'] as String)
        : ProjectStatus.planned,  // ✅ PLANNED por defecto
    managerId: json['managerId'] as int?,
    managerName: json['managerName'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}
```

**Valores por defecto**:
- `startDate`: Fecha actual
- `endDate`: Fecha actual + 30 días
- `status`: `PLANNED`
- `description`: String vacío si es null

### 2. DataSource Actualizado
**Archivo**: `creapolis_app/lib/data/datasources/project_remote_datasource.dart`

Comentados los campos que el backend no soporta:

```dart
@override
Future<ProjectModel> createProject({
  required String name,
  required String description,
  required DateTime startDate,
  required DateTime endDate,
  required ProjectStatus status,
  int? managerId,
}) async {
  try {
    // El backend actualmente solo maneja name y description
    final response = await _dioClient.post(
      '/projects',
      data: {
        'name': name,
        'description': description,
        // TODO: Cuando el backend soporte estos campos, descomentarlos:
        // 'startDate': startDate.toIso8601String(),
        // 'endDate': endDate.toIso8601String(),
        // 'status': _statusToString(status),
        // if (managerId != null) 'managerId': managerId,
      },
    );
    // ...
  }
}
```

Igual para `updateProject`.

## Resultado

### Antes del Fix
```
⛔ ProjectBloc: Error al crear proyecto - TypeError: null: type 'Null' is not a subtype of type 'String'
```

### Después del Fix
```
✅ Proyecto creado exitosamente
- Los campos opcionales usan valores por defecto
- La app no crashea
- El proyecto se crea correctamente en el backend
```

## Limitaciones Actuales

### Frontend
- Los campos `startDate`, `endDate`, `status` y `managerId` que el usuario ingresa se **ignoran**
- Se usan valores por defecto en su lugar
- La interfaz puede mostrar estos campos, pero no se guardan en el backend

### Backend
El modelo actual de `Project` es minimalista:
- ✅ Soporta: `name`, `description`
- ❌ No soporta: `startDate`, `endDate`, `status`, `managerId`

## Próximos Pasos (Mejora Futura)

### Opción 1: Actualizar Backend (Recomendado)
Agregar campos faltantes al schema de Prisma:

**Archivo**: `backend/prisma/schema.prisma`
```prisma
model Project {
  id          Int            @id @default(autoincrement())
  name        String
  description String?
  startDate   DateTime?      // ➕ Agregar
  endDate     DateTime?      // ➕ Agregar
  status      ProjectStatus? @default(PLANNED) // ➕ Agregar
  managerId   Int?           // ➕ Agregar
  createdAt   DateTime       @default(now())
  updatedAt   DateTime       @updatedAt
  
  // Relaciones
  manager     User?          @relation("ManagedProjects", fields: [managerId], references: [id])
  members     ProjectMember[]
  tasks       Task[]
}

enum ProjectStatus {  // ➕ Agregar enum
  PLANNED
  ACTIVE
  PAUSED
  COMPLETED
  CANCELLED
}
```

Luego ejecutar migración:
```bash
cd backend
npx prisma migrate dev --name add_project_fields
```

Actualizar servicios y controladores para manejar los nuevos campos.

### Opción 2: Simplificar Frontend
Remover campos no soportados de la UI hasta que el backend los soporte.

## Testing

### Verificar que funciona:
1. Crear un proyecto desde la app
2. El proyecto debe crearse sin errores
3. Verificar en la lista que aparece el proyecto
4. Los campos `startDate` y `endDate` mostrarán valores por defecto

### Comando de prueba:
```powershell
# Desde la raíz del proyecto
.\run-flutter.ps1

# Probar crear proyecto en http://localhost:8080
```

## Archivos Modificados
1. `creapolis_app/lib/data/models/project_model.dart`
   - Factory `fromJson` con manejo de campos opcionales
   
2. `creapolis_app/lib/data/datasources/project_remote_datasource.dart`
   - Métodos `createProject` y `updateProject` actualizados
   - Solo envían campos soportados por el backend

## Referencias
- [FIX_LOGIN_RESPONSE_STRUCTURE.md](./FIX_LOGIN_RESPONSE_STRUCTURE.md) - Fix anterior
- [PUERTO_8080_SETUP.md](./PUERTO_8080_SETUP.md) - Configuración de puerto

---

**Fecha**: Octubre 6, 2025  
**Estado**: ✅ Fix temporal implementado (funcional)  
**Mejora Futura**: Agregar campos al backend para soporte completo
