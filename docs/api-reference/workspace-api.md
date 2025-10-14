# Workspace System API Documentation

## 📋 Descripción General

El sistema de Workspaces permite a los usuarios crear espacios de trabajo aislados donde pueden colaborar con equipos, gestionar proyectos y tareas de manera organizada.

## 🔐 Autenticación

Todos los endpoints requieren autenticación mediante JWT token en el header:
```
Authorization: Bearer <token>
```

---

## 📚 Endpoints

### 1. Obtener Workspaces del Usuario

**GET** `/api/workspaces`

Obtiene todos los workspaces donde el usuario es miembro.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Mi Workspace Personal",
      "description": "Workspace personal",
      "avatarUrl": null,
      "type": "PERSONAL",
      "ownerId": 1,
      "owner": {
        "id": 1,
        "name": "Usuario Test",
        "email": "test@example.com",
        "avatarUrl": null
      },
      "userRole": "OWNER",
      "memberCount": 1,
      "projectCount": 5,
      "settings": {
        "allowGuestInvites": true,
        "requireEmailVerification": true,
        "autoAssignNewMembers": false,
        "defaultProjectTemplate": null,
        "timezone": "UTC",
        "language": "es"
      },
      "createdAt": "2025-10-08T10:00:00.000Z",
      "updatedAt": "2025-10-08T10:00:00.000Z"
    }
  ]
}
```

---

### 2. Obtener Workspace Específico

**GET** `/api/workspaces/:id`

Obtiene detalles de un workspace específico.

**Parámetros:**
- `id` (path): ID del workspace

**Response:** Igual que el objeto individual del endpoint anterior.

---

### 3. Crear Workspace

**POST** `/api/workspaces`

Crea un nuevo workspace.

**Request Body:**
```json
{
  "name": "Mi Empresa S.A.",
  "description": "Workspace para proyectos de la empresa",
  "avatarUrl": "https://example.com/avatar.png",
  "type": "TEAM",
  "settings": {
    "allowGuestInvites": true,
    "requireEmailVerification": true,
    "autoAssignNewMembers": false,
    "timezone": "America/Mexico_City",
    "language": "es"
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "Workspace creado exitosamente",
  "data": {
    "id": 2,
    "name": "Mi Empresa S.A.",
    "description": "Workspace para proyectos de la empresa",
    "avatarUrl": "https://example.com/avatar.png",
    "type": "TEAM",
    "ownerId": 1,
    "owner": {
      "id": 1,
      "name": "Usuario Test",
      "email": "test@example.com",
      "avatarUrl": null
    },
    "userRole": "OWNER",
    "memberCount": 1,
    "projectCount": 0,
    "settings": {
      "allowGuestInvites": true,
      "requireEmailVerification": true,
      "autoAssignNewMembers": false,
      "defaultProjectTemplate": null,
      "timezone": "America/Mexico_City",
      "language": "es"
    },
    "createdAt": "2025-10-08T11:00:00.000Z",
    "updatedAt": "2025-10-08T11:00:00.000Z"
  }
}
```

---

### 4. Actualizar Workspace

**PUT** `/api/workspaces/:id`

Actualiza un workspace existente. Solo OWNER y ADMIN pueden actualizar.

**Parámetros:**
- `id` (path): ID del workspace

**Request Body:** (todos los campos son opcionales)
```json
{
  "name": "Nuevo nombre",
  "description": "Nueva descripción",
  "avatarUrl": "https://example.com/new-avatar.png",
  "type": "ENTERPRISE",
  "settings": {
    "timezone": "Europe/Madrid"
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "Workspace actualizado exitosamente",
  "data": { /* ... datos del workspace actualizado ... */ }
}
```

---

### 5. Eliminar Workspace

**DELETE** `/api/workspaces/:id`

Elimina un workspace. Solo el OWNER puede eliminar.

**Parámetros:**
- `id` (path): ID del workspace

**Response:**
```json
{
  "success": true,
  "message": "Workspace eliminado exitosamente"
}
```

---

### 6. Obtener Miembros del Workspace

**GET** `/api/workspaces/:id/members`

Obtiene todos los miembros activos de un workspace.

**Parámetros:**
- `id` (path): ID del workspace

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "workspaceId": 1,
      "userId": 1,
      "userName": "Usuario Test",
      "userEmail": "test@example.com",
      "userAvatarUrl": null,
      "role": "OWNER",
      "joinedAt": "2025-10-08T10:00:00.000Z",
      "lastActiveAt": "2025-10-08T12:00:00.000Z",
      "isActive": true
    },
    {
      "id": 2,
      "workspaceId": 1,
      "userId": 2,
      "userName": "Miembro Test",
      "userEmail": "member@example.com",
      "userAvatarUrl": null,
      "role": "MEMBER",
      "joinedAt": "2025-10-08T11:00:00.000Z",
      "lastActiveAt": "2025-10-08T11:30:00.000Z",
      "isActive": true
    }
  ]
}
```

---

### 7. Actualizar Rol de Miembro

**PUT** `/api/workspaces/:id/members/:userId`

Actualiza el rol de un miembro. Solo OWNER y ADMIN pueden cambiar roles.

**Parámetros:**
- `id` (path): ID del workspace
- `userId` (path): ID del usuario

**Request Body:**
```json
{
  "role": "ADMIN"
}
```

**Roles disponibles:**
- `OWNER`: Control total del workspace
- `ADMIN`: Puede gestionar miembros y proyectos
- `MEMBER`: Puede trabajar en proyectos asignados
- `GUEST`: Solo lectura

**Response:**
```json
{
  "success": true,
  "message": "Rol actualizado exitosamente",
  "data": {
    "id": 2,
    "workspaceId": 1,
    "userId": 2,
    "userName": "Miembro Test",
    "userEmail": "member@example.com",
    "userAvatarUrl": null,
    "role": "ADMIN",
    "joinedAt": "2025-10-08T11:00:00.000Z",
    "lastActiveAt": "2025-10-08T11:30:00.000Z",
    "isActive": true
  }
}
```

---

### 8. Remover Miembro

**DELETE** `/api/workspaces/:id/members/:userId`

Remueve un miembro del workspace. Solo OWNER y ADMIN pueden remover miembros.

**Parámetros:**
- `id` (path): ID del workspace
- `userId` (path): ID del usuario

**Response:**
```json
{
  "success": true,
  "message": "Miembro removido exitosamente"
}
```

---

### 9. Crear Invitación

**POST** `/api/workspaces/:id/invitations`

Crea una invitación para añadir un nuevo miembro al workspace.

**Parámetros:**
- `id` (path): ID del workspace

**Request Body:**
```json
{
  "email": "nuevo@example.com",
  "role": "MEMBER"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Invitación creada exitosamente",
  "data": {
    "id": 1,
    "workspaceId": 1,
    "workspaceName": "Mi Workspace Personal",
    "inviterName": "Usuario Test",
    "inviteeEmail": "nuevo@example.com",
    "role": "MEMBER",
    "token": "a1b2c3d4e5f6...",
    "status": "PENDING",
    "createdAt": "2025-10-08T12:00:00.000Z",
    "expiresAt": "2025-10-15T12:00:00.000Z"
  }
}
```

---

### 10. Obtener Invitaciones Pendientes

**GET** `/api/workspaces/invitations/pending`

Obtiene todas las invitaciones pendientes del usuario autenticado.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "workspaceId": 2,
      "workspaceName": "Empresa XYZ",
      "workspaceDescription": "Workspace corporativo",
      "workspaceAvatarUrl": null,
      "workspaceType": "ENTERPRISE",
      "inviterName": "Admin Usuario",
      "inviterEmail": "admin@xyz.com",
      "inviterAvatarUrl": null,
      "inviteeEmail": "test@example.com",
      "role": "MEMBER",
      "token": "a1b2c3d4e5f6...",
      "status": "PENDING",
      "createdAt": "2025-10-08T12:00:00.000Z",
      "expiresAt": "2025-10-15T12:00:00.000Z"
    }
  ]
}
```

---

### 11. Aceptar Invitación

**POST** `/api/workspaces/invitations/accept`

Acepta una invitación para unirse a un workspace.

**Request Body:**
```json
{
  "token": "a1b2c3d4e5f6..."
}
```

**Response:**
```json
{
  "success": true,
  "message": "Invitación aceptada exitosamente",
  "data": {
    "workspaceId": 2,
    "workspaceName": "Empresa XYZ"
  }
}
```

---

### 12. Rechazar Invitación

**POST** `/api/workspaces/invitations/decline`

Rechaza una invitación a un workspace.

**Request Body:**
```json
{
  "token": "a1b2c3d4e5f6..."
}
```

**Response:**
```json
{
  "success": true,
  "message": "Invitación rechazada"
}
```

---

## 🎯 Códigos de Estado

| Código | Descripción |
|--------|-------------|
| 200 | Operación exitosa |
| 201 | Recurso creado exitosamente |
| 400 | Error en la solicitud (validación) |
| 401 | No autenticado |
| 403 | Sin permisos para esta acción |
| 404 | Recurso no encontrado |
| 500 | Error interno del servidor |

---

## 🔒 Permisos por Rol

| Acción | OWNER | ADMIN | MEMBER | GUEST |
|--------|-------|-------|--------|-------|
| Ver workspace | ✅ | ✅ | ✅ | ✅ |
| Actualizar workspace | ✅ | ✅ | ❌ | ❌ |
| Eliminar workspace | ✅ | ❌ | ❌ | ❌ |
| Invitar miembros | ✅ | ✅ | ✅ | ❌ |
| Cambiar roles | ✅ | ✅ | ❌ | ❌ |
| Remover miembros | ✅ | ✅ | ❌ | ❌ |
| Crear proyectos | ✅ | ✅ | ✅ | ❌ |
| Crear tareas | ✅ | ✅ | ✅ | ❌ |

---

## 📝 Notas Importantes

1. **Migración automática**: Cuando se ejecuta la migración, se crea automáticamente un workspace personal para cada usuario existente.

2. **Proyectos existentes**: Todos los proyectos existentes se migran automáticamente al workspace personal del usuario.

3. **Expiración de invitaciones**: Las invitaciones expiran después de 7 días.

4. **Tokens únicos**: Cada invitación tiene un token único que se debe usar para aceptar o rechazar.

5. **Aislamiento de datos**: Cada workspace tiene sus propios proyectos, tareas y miembros completamente aislados.

6. **Workspace personal**: Por defecto, cada usuario tiene un workspace personal de tipo `PERSONAL`.

---

## 🧪 Ejemplos de Uso

### Ejemplo 1: Crear y configurar un workspace

```bash
# 1. Crear workspace
curl -X POST http://localhost:3000/api/workspaces \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Mi Equipo",
    "description": "Workspace para el equipo de desarrollo",
    "type": "TEAM"
  }'

# 2. Invitar miembro
curl -X POST http://localhost:3000/api/workspaces/1/invitations \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "developer@example.com",
    "role": "MEMBER"
  }'
```

### Ejemplo 2: Aceptar invitación

```bash
# 1. Ver invitaciones pendientes
curl -X GET http://localhost:3000/api/workspaces/invitations/pending \
  -H "Authorization: Bearer <token>"

# 2. Aceptar invitación
curl -X POST http://localhost:3000/api/workspaces/invitations/accept \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "a1b2c3d4e5f6..."
  }'
```

---

## 🚀 Próximos Pasos

1. Ejecutar migración: `.\migrate-workspace.ps1`
2. Probar endpoints con Postman o curl
3. Implementar frontend Flutter
4. Configurar notificaciones por email para invitaciones
