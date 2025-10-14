# 🎨 Sistema de Roles y Permisos - Guía Visual

## 📊 Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────────────────┐
│                         FRONTEND (Flutter)                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────┐  ┌──────────────────┐  ┌───────────────┐ │
│  │ ProjectRoles     │  │ CreateRole       │  │ RoleDetail    │ │
│  │ Screen           │  │ Screen           │  │ Screen        │ │
│  │                  │  │                  │  │               │ │
│  │ • Lista roles    │  │ • Nombre         │  │ • Info rol    │ │
│  │ • Stats          │  │ • Descripción    │  │ • Permisos    │ │
│  │ • Acciones       │  │ • Permisos       │  │ • Auditoría   │ │
│  └────────┬─────────┘  └────────┬─────────┘  └───────┬───────┘ │
│           │                     │                     │          │
│           └─────────────────────┼─────────────────────┘          │
│                                 │                                │
│                          ┌──────▼──────┐                         │
│                          │  RoleBloc   │                         │
│                          ├─────────────┤                         │
│                          │ • Events    │                         │
│                          │ • States    │                         │
│                          └──────┬──────┘                         │
│                                 │                                │
│                     ┌───────────▼───────────┐                    │
│                     │  RoleRepository       │                    │
│                     ├───────────────────────┤                    │
│                     │ • getProjectRoles     │                    │
│                     │ • createProjectRole   │                    │
│                     │ • updatePermissions   │                    │
│                     │ • checkPermission     │                    │
│                     └───────────┬───────────┘                    │
│                                 │                                │
└─────────────────────────────────┼────────────────────────────────┘
                                  │
                                  │ HTTP/REST
                                  │
┌─────────────────────────────────▼────────────────────────────────┐
│                        BACKEND (Node.js)                          │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│                     ┌────────────────────┐                        │
│                     │  Role Controller   │                        │
│                     ├────────────────────┤                        │
│                     │ GET    /roles      │                        │
│                     │ POST   /roles      │                        │
│                     │ PUT    /roles/:id  │                        │
│                     │ DELETE /roles/:id  │                        │
│                     └──────────┬─────────┘                        │
│                                │                                  │
│                  ┌─────────────┴─────────────┐                   │
│                  │                           │                   │
│         ┌────────▼────────┐       ┌─────────▼──────────┐         │
│         │ Permission      │       │  Audit Logger      │         │
│         │ Middleware      │       │                    │         │
│         │                 │       │ • Track changes    │         │
│         │ • Check perms   │       │ • Log events       │         │
│         └────────┬────────┘       └─────────┬──────────┘         │
│                  │                          │                    │
│                  └──────────┬───────────────┘                    │
│                             │                                    │
│                    ┌────────▼────────┐                           │
│                    │  Prisma ORM     │                           │
│                    └────────┬────────┘                           │
│                             │                                    │
└─────────────────────────────┼──────────────────────────────────┘
                              │
┌─────────────────────────────▼────────────────────────────────────┐
│                      DATABASE (PostgreSQL)                        │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │ ProjectRole  │  │ Permission   │  │ RoleAuditLog │           │
│  ├──────────────┤  ├──────────────┤  ├──────────────┤           │
│  │ id           │  │ id           │  │ id           │           │
│  │ projectId    │  │ roleId       │  │ roleId       │           │
│  │ name         │  │ resource     │  │ userId       │           │
│  │ description  │  │ action       │  │ action       │           │
│  │ isDefault    │  │ granted      │  │ details      │           │
│  └──────┬───────┘  └──────┬───────┘  │ createdAt    │           │
│         │                 │          └──────────────┘           │
│         │                 │                                      │
│         │     ┌───────────▼──────────┐                           │
│         └─────►  ProjectRoleMember   │                           │
│               ├──────────────────────┤                           │
│               │ userId               │                           │
│               │ roleId               │                           │
│               │ assignedAt           │                           │
│               └──────────────────────┘                           │
└───────────────────────────────────────────────────────────────────┘
```

---

## 🎯 Matriz de Permisos Visual

```
┌───────────────┬────────┬──────┬────────┬──────────┬─────────┬───────────┐
│   Recurso     │ Crear  │ Ver  │ Editar │ Eliminar │ Asignar │ Gestionar │
├───────────────┼────────┼──────┼────────┼──────────┼─────────┼───────────┤
│ 📋 Tareas     │   ✅   │  ✅  │   ✅   │    ✅    │   ✅    │    ✅     │
├───────────────┼────────┼──────┼────────┼──────────┼─────────┼───────────┤
│ 📊 Proyectos  │   ❌   │  ✅  │   ✅   │    ❌    │   ❌    │    ❌     │
├───────────────┼────────┼──────┼────────┼──────────┼─────────┼───────────┤
│ 👥 Miembros   │   ❌   │  ✅  │   ❌   │    ❌    │   ✅    │    ❌     │
├───────────────┼────────┼──────┼────────┼──────────┼─────────┼───────────┤
│ ⚙️  Config    │   ❌   │  ✅  │   ❌   │    ❌    │   ❌    │    ❌     │
├───────────────┼────────┼──────┼────────┼──────────┼─────────┼───────────┤
│ 📈 Reportes   │   ❌   │  ✅  │   ❌   │    ❌    │   ❌    │    ❌     │
├───────────────┼────────┼──────┼────────┼──────────┼─────────┼───────────┤
│ 💬 Comentarios│   ✅   │  ✅  │   ✅   │    ❌    │   ❌    │    ❌     │
├───────────────┼────────┼──────┼────────┼──────────┼─────────┼───────────┤
│ ⏱️  Tracking  │   ✅   │  ✅  │   ✅   │    ❌    │   ❌    │    ❌     │
├───────────────┼────────┼──────┼────────┼──────────┼─────────┼───────────┤
│ 🔐 Roles      │   ❌   │  ✅  │   ❌   │    ❌    │   ❌    │    ❌     │
└───────────────┴────────┴──────┴────────┴──────────┴─────────┴───────────┘

Ejemplo: Rol "Desarrollador"
```

---

## 📱 Flujo de Usuario - Crear Rol

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                  │
│  1️⃣  Usuario abre lista de roles                                │
│      ProjectRolesScreen                                          │
│      ┌──────────────────────────────────────┐                   │
│      │  Roles - Mi Proyecto                 │                   │
│      │  ┌────────────────────────────────┐  │                   │
│      │  │ 👤 Desarrollador               │  │                   │
│      │  │    5 permisos, 3 miembros      │  │                   │
│      │  └────────────────────────────────┘  │                   │
│      │  ┌────────────────────────────────┐  │                   │
│      │  │ 🎨 Diseñador                   │  │                   │
│      │  │    3 permisos, 2 miembros      │  │                   │
│      │  └────────────────────────────────┘  │                   │
│      │                                       │                   │
│      │  [➕ Crear Rol]                       │                   │
│      └──────────────────────────────────────┘                   │
│                       │                                          │
│                       ▼                                          │
│  2️⃣  Click en "Crear Rol"                                       │
│      CreateRoleScreen                                            │
│      ┌──────────────────────────────────────┐                   │
│      │  Crear Rol                            │                   │
│      │  ┌────────────────────────────────┐  │                   │
│      │  │ Información Básica             │  │                   │
│      │  │  Nombre: [QA Tester]           │  │                   │
│      │  │  Descripción: [Pruebas...]     │  │                   │
│      │  │  ☐ Rol por defecto             │  │                   │
│      │  └────────────────────────────────┘  │                   │
│      │  ┌────────────────────────────────┐  │                   │
│      │  │ Permisos                       │  │                   │
│      │  │  ▼ Tareas (2/6)                │  │                   │
│      │  │    ☐ Crear  ☑ Ver              │  │                   │
│      │  │    ☐ Editar ☐ Eliminar         │  │                   │
│      │  │  ▼ Comentarios (2/6)           │  │                   │
│      │  │    ☑ Crear  ☑ Ver              │  │                   │
│      │  └────────────────────────────────┘  │                   │
│      │                                       │                   │
│      │  [Cancelar]  [Crear Rol]             │                   │
│      └──────────────────────────────────────┘                   │
│                       │                                          │
│                       ▼                                          │
│  3️⃣  Rol creado y guardado                                      │
│      ✅ "Rol creado exitosamente"                                │
│      Lista actualizada con nuevo rol                             │
│                       │                                          │
│                       ▼                                          │
│  4️⃣  Click en rol para ver detalles                             │
│      RoleDetailScreen                                            │
│      ┌──────────────────────────────────────┐                   │
│      │  QA Tester                            │                   │
│      │  ┌────────────────────────────────┐  │                   │
│      │  │ 👤 QA Tester                   │  │                   │
│      │  │    Pruebas y validación        │  │                   │
│      │  │    4 permisos | 0 miembros     │  │                   │
│      │  └────────────────────────────────┘  │                   │
│      │  ┌────────────────────────────────┐  │                   │
│      │  │ Permisos Asignados             │  │                   │
│      │  │  ▼ Tareas                      │  │                   │
│      │  │    ✅ Ver                       │  │                   │
│      │  │  ▼ Comentarios                 │  │                   │
│      │  │    ✅ Crear  ✅ Ver             │  │                   │
│      │  └────────────────────────────────┘  │                   │
│      │  ┌────────────────────────────────┐  │                   │
│      │  │ Historial de Auditoría         │  │                   │
│      │  │  🟢 Rol creado                 │  │                   │
│      │  │     Por Juan - 14/10 19:00     │  │                   │
│      │  └────────────────────────────────┘  │                   │
│      └──────────────────────────────────────┘                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Flujo de Verificación de Permisos

```
┌────────────────────────────────────────────────────────────┐
│  Usuario intenta realizar acción                           │
│  (ej: eliminar tarea)                                      │
└────────────────┬───────────────────────────────────────────┘
                 │
                 ▼
    ┌────────────────────────┐
    │  Frontend verifica     │
    │  checkPermission()     │
    └────────┬───────────────┘
             │
             ▼
    ┌────────────────────────┐
    │  API Request           │
    │  GET /check-permission │
    │  ?resource=tasks       │
    │  &action=delete        │
    └────────┬───────────────┘
             │
             ▼
    ┌────────────────────────┐
    │  Backend verifica      │
    │  1. Rol de workspace   │
    │     ├─ OWNER? → ✅     │
    │     └─ ADMIN? → ✅     │
    │  2. Rol de proyecto    │
    │     └─ Permission?     │
    └────────┬───────────────┘
             │
             ├─────────┬─────────┐
             │         │         │
             ▼         ▼         ▼
        ┌────────┐ ┌──────┐ ┌──────┐
        │   ✅    │ │  ✅   │ │  ❌   │
        │  TRUE  │ │ TRUE │ │ FALSE│
        └───┬────┘ └───┬──┘ └───┬──┘
            │          │        │
            ▼          ▼        ▼
     ┌──────────┐ ┌────────┐ ┌────────────┐
     │ Permitir │ │Permitir│ │  Denegar   │
     │ acción   │ │acción  │ │  acción    │
     └──────────┘ └────────┘ └────────────┘
```

---

## 🎨 Componentes de UI

### ProjectRolesScreen
```
┌─────────────────────────────────────┐
│  Roles - Mi Proyecto         🔄      │
├─────────────────────────────────────┤
│                                      │
│  ┌──────────────────────────────┐   │
│  │ 👤  Desarrollador            │   │
│  │                              │   │
│  │ Puede crear y editar tareas  │   │
│  │                              │   │
│  │ 🔒 7 permisos  👥 5 miembros  │   │
│  │                          ⋮   │   │
│  └──────────────────────────────┘   │
│                                      │
│  ┌──────────────────────────────┐   │
│  │ 🎨  Diseñador  [Por defecto] │   │
│  │                              │   │
│  │ Diseño y revisión visual     │   │
│  │                              │   │
│  │ 🔒 4 permisos  👥 3 miembros  │   │
│  │                          ⋮   │   │
│  └──────────────────────────────┘   │
│                                      │
│                                      │
│                [➕ Crear Rol]         │
└─────────────────────────────────────┘
```

### PermissionsMatrix Widget
```
┌─────────────────────────────────────────────────────────┐
│  Recurso      │ Crear │ Ver │ Editar │ Eliminar │ ... │
├───────────────┼───────┼─────┼────────┼──────────┼─────┤
│ 📋 Tareas     │  ✅   │ ✅  │   ✅   │    ✅    │ ... │
│ 📊 Proyectos  │  ❌   │ ✅  │   ✅   │    ❌    │ ... │
│ 👥 Miembros   │  ❌   │ ✅  │   ❌   │    ❌    │ ... │
│ 💬 Comentarios│  ✅   │ ✅  │   ✅   │    ❌    │ ... │
└─────────────────────────────────────────────────────────┘
```

---

## 📊 Tipos de Eventos de Auditoría

```
🟢 ROLE_CREATED         Rol creado
🔵 ROLE_UPDATED         Rol actualizado  
🔴 ROLE_DELETED         Rol eliminado
🟢 PERMISSION_GRANTED   Permisos otorgados
🔴 PERMISSION_REVOKED   Permisos revocados
🟠 MEMBER_ASSIGNED      Miembro asignado
🔴 MEMBER_REMOVED       Miembro removido
```

---

## 🔐 Jerarquía de Permisos

```
┌────────────────────────────────────────┐
│    Workspace OWNER / ADMIN             │
│    ✅ Acceso completo automático        │
└───────────────┬────────────────────────┘
                │
                ▼
┌────────────────────────────────────────┐
│    Project Roles                       │
│    Permisos específicos del proyecto   │
└────────────────────────────────────────┘
```

**Regla**: Los OWNER y ADMIN del workspace tienen todos los permisos, independientemente de los roles de proyecto.

---

## 📦 Estructura de Datos

### ProjectRole
```json
{
  "id": 1,
  "projectId": 5,
  "name": "Desarrollador",
  "description": "Puede crear y editar tareas",
  "isDefault": false,
  "permissions": [...],
  "memberCount": 3,
  "createdAt": "2025-10-14T19:00:00Z",
  "updatedAt": "2025-10-14T19:00:00Z"
}
```

### ProjectPermission
```json
{
  "id": 1,
  "roleId": 1,
  "resource": "tasks",
  "action": "create",
  "granted": true,
  "createdAt": "2025-10-14T19:00:00Z",
  "updatedAt": "2025-10-14T19:00:00Z"
}
```

### RoleAuditLog
```json
{
  "id": 1,
  "roleId": 1,
  "userId": 5,
  "action": "ROLE_CREATED",
  "details": "Rol \"Desarrollador\" creado",
  "createdAt": "2025-10-14T19:00:00Z",
  "user": {
    "name": "Juan Pérez",
    "email": "juan@example.com"
  }
}
```

---

## 🎯 Casos de Uso Visualizados

### Caso 1: Desarrollador Junior
```
👤 Desarrollador Junior
├─ ✅ Ver tareas
├─ ✅ Crear comentarios
├─ ✅ Ver reportes
└─ ❌ No puede eliminar tareas
```

### Caso 2: Project Manager
```
👤 Project Manager
├─ ✅ Gestionar tareas (CRUD completo)
├─ ✅ Asignar tareas
├─ ✅ Ver y editar proyectos
├─ ✅ Gestionar comentarios
└─ ❌ No puede gestionar roles
```

### Caso 3: Cliente/Observador
```
👤 Cliente
├─ ✅ Ver tareas
├─ ✅ Ver proyectos
├─ ✅ Ver reportes
└─ ❌ Sin permisos de edición
```

---

**Para más información, consulta**:
- 📖 [Documentación Completa](./ROLES_AND_PERMISSIONS_SYSTEM.md)
- 🚀 [Guía Rápida](./ROLES_PERMISSIONS_QUICK_START.md)
