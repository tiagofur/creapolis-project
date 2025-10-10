# 🧪 Resultados de Pruebas - Backend Docker

**Fecha:** 6 de Octubre, 2025  
**Estado:** ✅ Todos los servicios funcionando correctamente

---

## 📊 Estado de Servicios

| Servicio    | Puerto | Estado      | Health Check                     |
| ----------- | ------ | ----------- | -------------------------------- |
| PostgreSQL  | 5433   | ✅ Healthy  | N/A                              |
| Backend API | 3001   | ✅ Healthy  | http://localhost:3001/api/health |
| PgAdmin     | 5050   | ⏸️ Opcional | http://localhost:5050            |

---

## ✅ Pruebas Realizadas

### 1. Health Check

```json
{
  "status": "ok",
  "timestamp": "2025-10-06T15:02:56.557Z",
  "environment": "production"
}
```

**Resultado:** ✅ PASS (200 OK)

---

### 2. Registro de Usuario

**Endpoint:** `POST /api/auth/register`

**Request:**

```json
{
  "email": "usuario1@creapolis.com",
  "password": "Password123!",
  "name": "Usuario Uno"
}
```

**Logs del Backend:**

```
POST /api/auth/register 201 148.956 ms - 389
```

**Resultado:** ✅ PASS (201 Created)

---

### 3. Login de Usuario

**Endpoint:** `POST /api/auth/login`

**Request:**

```json
{
  "email": "usuario1@creapolis.com",
  "password": "Password123!"
}
```

**Response (parcial):**

```json
{
  "data": {
    "user": {
      "id": 2,
      "name": "Usuario Uno",
      "email": "usuario1@creapolis.com",
      "role": "TEAM_MEMBER"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Logs del Backend:**

```
POST /api/auth/login 200 87.118 ms - 377
```

**Resultado:** ✅ PASS (200 OK)

---

### 4. Crear Proyecto

**Endpoint:** `POST /api/projects`

**Request:**

```json
{
  "name": "Proyecto Demo",
  "description": "Proyecto de prueba para Docker"
}
```

**Headers:**

```
Authorization: Bearer <token>
```

**Logs del Backend:**

```
POST /api/projects 201 21.187 ms - 435
```

**Resultado:** ✅ PASS (201 Created)

---

### 5. Listar Proyectos

**Endpoint:** `GET /api/projects`

**Headers:**

```
Authorization: Bearer <token>
```

**Logs del Backend:**

```
GET /api/projects 200 25.652 ms - 534
```

**Resultado:** ✅ PASS (200 OK)

---

## 🗄️ Estado de la Base de Datos

### Tablas Creadas

```sql
 Schema |        Name        | Type  |   Owner
--------+--------------------+-------+-----------
 public | Dependency         | table | creapolis
 public | Project            | table | creapolis
 public | ProjectMember      | table | creapolis
 public | Task               | table | creapolis
 public | TimeLog            | table | creapolis
 public | User               | table | creapolis
 public | _prisma_migrations | table | creapolis
```

### Datos de Prueba

**Usuarios:**

```sql
 id |    name     |         email          |    role
----+-------------+------------------------+-------------
  1 | Test User   | test@creapolis.com     | TEAM_MEMBER
  2 | Usuario Uno | usuario1@creapolis.com | TEAM_MEMBER
```

**Proyectos:**

```sql
 id |     name      |          description           |        createdAt
----+---------------+--------------------------------+-------------------------
  1 | Proyecto Demo | Proyecto de prueba para Docker | 2025-10-06 15:10:41.005
```

---

## 📈 Métricas de Rendimiento

| Operación        | Tiempo Promedio | Estado       |
| ---------------- | --------------- | ------------ |
| Health Check     | ~0.3 ms         | ⚡ Excelente |
| Login            | ~85 ms          | ✅ Bueno     |
| Registro         | ~150 ms         | ✅ Bueno     |
| Crear Proyecto   | ~21 ms          | ⚡ Excelente |
| Listar Proyectos | ~25 ms          | ⚡ Excelente |

---

## 🔧 Migraciones de Prisma

**Migración Aplicada:** `20251006150706_init`

**Resultado:** ✅ Base de datos sincronizada con el esquema

```
Your database is now in sync with your schema.
✔ Generated Prisma Client (v5.22.0)
```

---

## 🚀 Comandos Útiles para Desarrollo

### Ver logs en tiempo real

```powershell
docker-compose logs -f backend
```

### Verificar estado de servicios

```powershell
docker-compose ps
```

### Acceder a la base de datos

```powershell
docker-compose exec postgres psql -U creapolis -d creapolis_db
```

### Ejecutar migraciones

```powershell
docker-compose exec backend npx prisma migrate dev
```

### Iniciar PgAdmin

```powershell
docker-compose --profile tools up -d
```

Acceder a: http://localhost:5050

- Email: admin@creapolis.com
- Password: admin

### Detener servicios

```powershell
docker-compose down
```

### Ver todos los comandos disponibles

```powershell
.\docker.ps1 help
```

---

## 🔗 Integración con Flutter

Para conectar la app Flutter al backend Docker:

1. Actualizar la configuración de API en Flutter:

   ```dart
   // lib/core/constants/api_constants.dart
   static const String baseUrl = 'http://localhost:3001';
   ```

2. Asegurarse de que el backend esté corriendo:

   ```powershell
   docker-compose ps
   ```

3. La app Flutter podrá hacer peticiones a:
   - `http://localhost:3001/api/auth/register`
   - `http://localhost:3000/api/auth/login`
   - `http://localhost:3000/api/projects`
   - etc.

---

## ✅ Conclusión

Todos los servicios de Docker están funcionando correctamente:

- ✅ PostgreSQL 16 operativo en puerto 5433
- ✅ Backend Node.js operativo en puerto 3000
- ✅ Base de datos con todas las tablas creadas
- ✅ Endpoints de autenticación funcionando
- ✅ Endpoints de proyectos funcionando
- ✅ Migraciones de Prisma aplicadas
- ✅ Health checks pasando

**Sistema listo para desarrollo y pruebas!** 🎉
