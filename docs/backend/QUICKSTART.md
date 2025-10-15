# Creapolis Backend - Guía de Uso Rápido

Esta guía te ayudará a probar rápidamente todas las funcionalidades del backend de Creapolis.

## 🚀 Inicio Rápido

### 1. Instalar y Configurar

```powershell
# Navegar al directorio backend
cd backend

# Instalar dependencias
npm install

# Configurar .env
cp .env.example .env
# Editar .env con tu configuración de base de datos

# Ejecutar migraciones
npm run prisma:migrate
npm run prisma:generate

# Iniciar servidor
npm run dev
```

El servidor estará corriendo en `http://localhost:3000`

---

## 📝 Flujo de Trabajo Completo

### Paso 1: Registrar un Usuario

```powershell
curl -X POST http://localhost:3000/api/auth/register `
  -H "Content-Type: application/json" `
  -d '{
    "email": "admin@creapolis.com",
    "password": "Admin123",
    "name": "Administrator",
    "role": "ADMIN"
  }'
```

**Guarda el token que recibes en la respuesta!**

### Paso 2: Iniciar Sesión

```powershell
curl -X POST http://localhost:3000/api/auth/login `
  -H "Content-Type: application/json" `
  -d '{
    "email": "admin@creapolis.com",
    "password": "Admin123"
  }'
```

### Paso 3: Crear un Proyecto

```powershell
$token = "tu-token-jwt-aqui"

curl -X POST http://localhost:3000/api/projects `
  -H "Authorization: Bearer $token" `
  -H "Content-Type: application/json" `
  -d '{
    "name": "Proyecto Creapolis MVP",
    "description": "Desarrollo del MVP de la plataforma"
  }'
```

**Guarda el ID del proyecto de la respuesta!**

### Paso 4: Crear Tareas

```powershell
# Tarea 1: Diseño de UI
curl -X POST http://localhost:3000/api/projects/1/tasks `
  -H "Authorization: Bearer $token" `
  -H "Content-Type: application/json" `
  -d '{
    "title": "Diseño de interfaz de usuario",
    "description": "Crear mockups y diseño visual",
    "estimatedHours": 8
  }'

# Tarea 2: Desarrollo Frontend (depende de Tarea 1)
curl -X POST http://localhost:3000/api/projects/1/tasks `
  -H "Authorization: Bearer $token" `
  -H "Content-Type: application/json" `
  -d '{
    "title": "Implementar componentes React",
    "description": "Desarrollar componentes de UI",
    "estimatedHours": 16,
    "predecessorIds": [1]
  }'

# Tarea 3: Testing
curl -X POST http://localhost:3000/api/projects/1/tasks `
  -H "Authorization: Bearer $token" `
  -H "Content-Type: application/json" `
  -d '{
    "title": "Pruebas E2E",
    "description": "Ejecutar pruebas end-to-end",
    "estimatedHours": 6,
    "predecessorIds": [2]
  }'
```

### Paso 5: Listar Tareas del Proyecto

```powershell
curl http://localhost:3000/api/projects/1/tasks `
  -H "Authorization: Bearer $token"
```

### Paso 6: Iniciar Time Tracking

```powershell
# Iniciar trabajo en tarea 1
curl -X POST http://localhost:3000/api/tasks/1/start `
  -H "Authorization: Bearer $token"
```

### Paso 7: Ver Timelog Activo

```powershell
curl http://localhost:3000/api/timelogs/active `
  -H "Authorization: Bearer $token"
```

### Paso 8: Detener Time Tracking

```powershell
# Después de trabajar un rato...
curl -X POST http://localhost:3000/api/tasks/1/stop `
  -H "Authorization: Bearer $token"
```

### Paso 9: Ver Historial de Timelogs

```powershell
curl http://localhost:3000/api/tasks/1/timelogs `
  -H "Authorization: Bearer $token"
```

### Paso 10: Finalizar Tarea

```powershell
curl -X POST http://localhost:3000/api/tasks/1/finish `
  -H "Authorization: Bearer $token"
```

### Paso 11: Ver Estadísticas Personales

```powershell
curl http://localhost:3000/api/timelogs/stats `
  -H "Authorization: Bearer $token"
```

---

## 🧪 Ejecutar Tests

```powershell
# Ejecutar todos los tests
npm test

# Ejecutar tests en modo watch
npm test -- --watch

# Ver coverage
npm test -- --coverage

# Ejecutar test específico
npm test -- auth.test.js
```

---

## 📊 Endpoints Disponibles

### Autenticación

- `POST /api/auth/register` - Registrar usuario
- `POST /api/auth/login` - Iniciar sesión
- `GET /api/auth/me` - Perfil del usuario

### Proyectos

- `GET /api/projects` - Listar proyectos
- `POST /api/projects` - Crear proyecto
- `GET /api/projects/:id` - Ver proyecto
- `PUT /api/projects/:id` - Actualizar proyecto
- `DELETE /api/projects/:id` - Eliminar proyecto
- `POST /api/projects/:id/members` - Agregar miembro
- `DELETE /api/projects/:id/members/:userId` - Remover miembro

### Tareas

- `GET /api/projects/:projectId/tasks` - Listar tareas
- `POST /api/projects/:projectId/tasks` - Crear tarea
- `GET /api/projects/:projectId/tasks/:taskId` - Ver tarea
- `PUT /api/projects/:projectId/tasks/:taskId` - Actualizar tarea
- `DELETE /api/projects/:projectId/tasks/:taskId` - Eliminar tarea
- `POST /api/projects/:projectId/tasks/:taskId/dependencies` - Agregar dependencia
- `DELETE /api/projects/:projectId/tasks/:taskId/dependencies/:predId` - Remover dependencia

### Time Tracking

- `POST /api/tasks/:taskId/start` - Iniciar tracking
- `POST /api/tasks/:taskId/stop` - Detener tracking
- `POST /api/tasks/:taskId/finish` - Finalizar tarea
- `GET /api/tasks/:taskId/timelogs` - Ver timelogs de tarea
- `GET /api/timelogs/active` - Ver timelog activo
- `GET /api/timelogs/stats` - Estadísticas de tiempo

---

## 🔧 Herramientas Útiles

### Prisma Studio

Ver y editar datos de la base de datos:

```powershell
npm run prisma:studio
```

### Logs del Servidor

El servidor muestra logs detallados en desarrollo:

```
🚀 Server running on port 3000
📝 Environment: development
🔗 Health check: http://localhost:3000/health
✅ Database connected successfully
```

### Health Check

Verificar que el servidor está funcionando:

```powershell
curl http://localhost:3000/health
```

---

## 💡 Ejemplos de Escenarios Comunes

### Crear un Equipo de Proyecto

```powershell
# 1. Registrar usuarios adicionales
curl -X POST http://localhost:3000/api/auth/register `
  -H "Content-Type: application/json" `
  -d '{
    "email": "developer@creapolis.com",
    "password": "Dev123",
    "name": "Developer User"
  }'

# 2. Agregar al proyecto (necesitas el userId de la respuesta anterior)
curl -X POST http://localhost:3000/api/projects/1/members `
  -H "Authorization: Bearer $token" `
  -H "Content-Type: application/json" `
  -d '{
    "userId": 2
  }'
```

### Asignar Tarea a Miembro

```powershell
curl -X PUT http://localhost:3000/api/projects/1/tasks/1 `
  -H "Authorization: Bearer $token" `
  -H "Content-Type: application/json" `
  -d '{
    "assigneeId": 2
  }'
```

### Buscar Proyectos

```powershell
curl "http://localhost:3000/api/projects?search=MVP&page=1&limit=10" `
  -H "Authorization: Bearer $token"
```

### Filtrar Tareas por Estado

```powershell
curl "http://localhost:3000/api/projects/1/tasks?status=IN_PROGRESS" `
  -H "Authorization: Bearer $token"
```

### Ver Estadísticas de un Período

```powershell
curl "http://localhost:3000/api/timelogs/stats?startDate=2025-10-01&endDate=2025-10-03" `
  -H "Authorization: Bearer $token"
```

---

## 🐛 Solución de Problemas

### Error: "Can't reach database server"

```powershell
# Verificar que PostgreSQL está corriendo
# En Windows con Docker:
docker ps

# Reiniciar contenedor si es necesario:
docker restart creapolis-postgres
```

### Error: "JWT_SECRET is not defined"

```powershell
# Verificar que existe el archivo .env
cat .env

# Si no existe, copiar el ejemplo:
cp .env.example .env
```

### Error: "Port 3000 is already in use"

```powershell
# Cambiar el puerto en .env
echo "PORT=3001" >> .env
```

### Resetear Base de Datos

```powershell
# Cuidado: esto eliminará todos los datos
npx prisma migrate reset
npm run prisma:generate
```

---

## 📚 Recursos Adicionales

- [Documentación Completa de la API](./API_DOCS.md)
- [Guía de Instalación](./INSTALLATION.md)
- [Estado del Proyecto](./STATUS.md)
- [Plan de Tareas](../documentation/tasks.md)

## 🎉 ¡Listo!

Ahora tienes un backend completamente funcional con:

- ✅ Autenticación y autorización
- ✅ Gestión de proyectos y equipos
- ✅ Sistema de tareas con dependencias
- ✅ Time tracking completo
- ✅ APIs RESTful bien documentadas
- ✅ Tests automatizados
- ✅ Validaciones robustas

**Próximo paso**: Continuar con Fase 3 (Motor de Planificación) o Fase 4 (Frontend React)
