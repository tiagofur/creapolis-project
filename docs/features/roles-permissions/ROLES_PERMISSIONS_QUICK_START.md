# Sistema de Roles y Permisos - Guía Rápida 🚀

## Inicio Rápido en 5 Minutos

### 1. Crear un Rol (Backend)

```bash
curl -X POST http://localhost:3001/api/roles/projects/1/roles \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Desarrollador",
    "description": "Puede crear y editar tareas",
    "isDefault": false,
    "permissions": [
      {"resource": "tasks", "action": "create", "granted": true},
      {"resource": "tasks", "action": "read", "granted": true},
      {"resource": "tasks", "action": "update", "granted": true}
    ]
  }'
```

### 2. Listar Roles de un Proyecto

```bash
curl -X GET http://localhost:3001/api/roles/projects/1/roles \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 3. Verificar Permiso

```bash
curl -X GET "http://localhost:3001/api/roles/projects/1/check-permission?resource=tasks&action=create" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 4. Asignar Rol a Usuario

```bash
curl -X POST http://localhost:3001/api/roles/roles/1/assign \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "targetUserId": 5
  }'
```

---

## UI Flutter - Navegación Rápida

### Abrir Gestión de Roles

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => ProjectRolesScreen(
      projectId: project.id,
      projectName: project.name,
    ),
  ),
);
```

### Crear Rol desde Código

```dart
context.read<RoleBloc>().add(
  CreateProjectRole(
    projectId: 1,
    name: 'QA Tester',
    description: 'Puede ver y comentar tareas',
    permissions: [
      {'resource': 'tasks', 'action': 'read', 'granted': true},
      {'resource': 'comments', 'action': 'create', 'granted': true},
      {'resource': 'comments', 'action': 'read', 'granted': true},
    ],
  ),
);
```

### Verificar Permiso en UI

```dart
final hasPermission = await roleRepository.checkPermission(
  projectId: projectId,
  resource: 'tasks',
  action: 'delete',
);

hasPermission.fold(
  (failure) => print('Error: ${failure.message}'),
  (allowed) {
    if (allowed) {
      // Mostrar botón de eliminar
    } else {
      // Ocultar botón de eliminar
    }
  },
);
```

---

## Recursos y Acciones Disponibles

### 📦 Recursos

- `tasks` - Tareas
- `projects` - Proyectos
- `members` - Miembros
- `settings` - Configuración
- `reports` - Reportes
- `comments` - Comentarios
- `timeTracking` - Time Tracking
- `roles` - Roles

### ⚡ Acciones

- `create` - Crear
- `read` - Ver
- `update` - Editar
- `delete` - Eliminar
- `assign` - Asignar
- `manage` - Gestionar

---

## Ejemplos de Roles Comunes

### 🎯 Desarrollador

```json
{
  "name": "Desarrollador",
  "permissions": [
    {"resource": "tasks", "action": "create"},
    {"resource": "tasks", "action": "read"},
    {"resource": "tasks", "action": "update"},
    {"resource": "comments", "action": "create"},
    {"resource": "comments", "action": "read"},
    {"resource": "timeTracking", "action": "create"},
    {"resource": "timeTracking", "action": "read"}
  ]
}
```

### 🎨 Diseñador

```json
{
  "name": "Diseñador",
  "permissions": [
    {"resource": "tasks", "action": "read"},
    {"resource": "tasks", "action": "update"},
    {"resource": "comments", "action": "create"},
    {"resource": "comments", "action": "read"},
    {"resource": "reports", "action": "read"}
  ]
}
```

### 👀 Observador

```json
{
  "name": "Observador",
  "permissions": [
    {"resource": "tasks", "action": "read"},
    {"resource": "projects", "action": "read"},
    {"resource": "reports", "action": "read"},
    {"resource": "comments", "action": "read"}
  ]
}
```

### 🔧 Project Manager

```json
{
  "name": "Project Manager",
  "permissions": [
    {"resource": "tasks", "action": "create"},
    {"resource": "tasks", "action": "read"},
    {"resource": "tasks", "action": "update"},
    {"resource": "tasks", "action": "delete"},
    {"resource": "tasks", "action": "assign"},
    {"resource": "projects", "action": "update"},
    {"resource": "members", "action": "read"},
    {"resource": "members", "action": "assign"},
    {"resource": "reports", "action": "read"},
    {"resource": "comments", "action": "manage"}
  ]
}
```

---

## Proteger Endpoints con Middleware

```javascript
import { requirePermission } from '../middleware/permission.js';

// Proteger endpoint para crear tareas
router.post('/projects/:projectId/tasks', 
  authenticate, 
  requirePermission('tasks', 'create'),
  createTask
);

// Proteger endpoint para eliminar tareas
router.delete('/projects/:projectId/tasks/:taskId',
  authenticate,
  requirePermission('tasks', 'delete'),
  deleteTask
);
```

---

## Ver Logs de Auditoría

```bash
curl -X GET http://localhost:3001/api/roles/roles/1/audit-logs \
  -H "Authorization: Bearer YOUR_TOKEN"
```

Respuesta:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "action": "ROLE_CREATED",
      "details": "Rol \"Desarrollador\" creado",
      "createdAt": "2025-10-14T19:00:00Z",
      "user": {
        "name": "Juan Pérez",
        "email": "juan@example.com"
      }
    },
    {
      "id": 2,
      "action": "PERMISSION_GRANTED",
      "details": "Permisos actualizados para rol \"Desarrollador\"",
      "createdAt": "2025-10-14T19:05:00Z",
      "user": {
        "name": "Juan Pérez",
        "email": "juan@example.com"
      }
    }
  ]
}
```

---

## Troubleshooting Común

### ❌ "No tienes permisos para crear roles"

**Solución**: Verifica que tu usuario tenga rol OWNER o ADMIN en el workspace.

### ❌ "Rol no encontrado"

**Solución**: Verifica que el roleId sea correcto y que el rol pertenezca al proyecto.

### ❌ "El usuario ya tiene este rol asignado"

**Solución**: El usuario ya tiene el rol. Si necesitas cambiar permisos, actualiza el rol en lugar de reasignarlo.

---

## Mejores Prácticas

1. **Principio de Menor Privilegio** - Otorga solo los permisos necesarios
2. **Roles Descriptivos** - Usa nombres claros como "Desarrollador Senior" en lugar de "Rol1"
3. **Documentar Roles** - Usa el campo `description` para explicar el propósito del rol
4. **Revisar Periódicamente** - Revisa logs de auditoría para detectar uso inusual
5. **Rol por Defecto** - Define un rol por defecto para nuevos miembros

---

## Recursos Adicionales

- 📖 [Documentación Completa](./ROLES_AND_PERMISSIONS_SYSTEM.md)
- 🔗 [API Reference](./backend/src/controllers/role.controller.js)
- 🎨 [UI Screens](./creapolis_app/lib/presentation/screens/roles/)
- 🧪 [Tests](./backend/tests/) (próximamente)

---

**¿Necesitas ayuda?** Consulta la documentación completa o revisa los ejemplos de código en el repositorio.
