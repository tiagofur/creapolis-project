# Estado del Entorno de Desarrollo - Creapolis

## Fecha: 2025-10-08 12:20

## ✅ Servicios Levantados

### 1. PostgreSQL (Docker)

- **Container**: `creapolis-postgres`
- **Puerto**: 5432
- **Estado**: ✅ Running
- **Credenciales**:
  - Usuario: `creapolis`
  - Password: `creapolis_password_2024`
  - Base de datos: `creapolis_db`

**Comando para verificar**:

```powershell
docker ps | Select-String "postgres"
```

**Comando para ver logs**:

```powershell
docker logs creapolis-postgres --tail 50
```

### 2. Backend (Node.js/Express)

- **Puerto**: 3000
- **Estado**: ✅ Running (localmente, NO en Docker)
- **URL**: http://localhost:3000
- **Health Check**: http://localhost:3000/api/health

**Features habilitadas**:

- ✅ Autenticación JWT
- ✅ CORS configurado para puerto 8080
- ✅ Nueva ruta: `GET /api/tasks/:id` (sin necesidad de projectId)
- ✅ Rutas de timelogs
- ⚠️ Google Calendar no configurado (opcional)

**Archivo de configuración**: `backend/.env`

**Comando para verificar**:

```powershell
curl http://localhost:3000/api/health
```

### 3. Flutter Web

- **Puerto**: 8080
- **Estado**: 🔄 Compilando...
- **URL**: http://localhost:8080 (se abrirá automáticamente en Chrome)

**Features actualizadas**:

- ✅ TaskModel acepta camelCase y snake_case
- ✅ Campos opcionales con valores por defecto
- ✅ getTaskById implementado correctamente
- ✅ TimeLogRemoteDataSource corregido

## 📝 Cambios Aplicados en Esta Sesión

### Backend

1. **Nueva ruta agregada** (`backend/src/routes/timelog.routes.js`):

   ```javascript
   GET /api/tasks/:taskId
   ```

   - Permite obtener una tarea sin necesitar projectId
   - Verifica acceso del usuario al proyecto
   - Retorna datos con formato estándar

2. **Credenciales actualizadas** (`backend/.env`):
   ```
   DATABASE_URL="postgresql://creapolis:creapolis_password_2024@localhost:5432/creapolis_db?schema=public"
   ```

### Flutter

1. **TaskModel.fromJson()** mejorado:

   - Acepta tanto camelCase como snake_case
   - Campo `priority` opcional (default: MEDIUM)
   - Campos `startDate` y `endDate` opcionales
   - Maneja diferentes formatos de dependencias

2. **TaskRemoteDataSource.getTaskById()** actualizado:

   - Usa la nueva ruta `/api/tasks/:id`
   - Extrae correctamente el campo `data` de la respuesta

3. **TimeLogRemoteDataSource.getTimeLogsByTask()** corregido:
   - Extrae el campo `data` de la respuesta anidada
   - Maneja respuestas vacías correctamente

## 🔧 Cómo Iniciar Todo (Manual)

### Opción 1: Usar el script automatizado

```powershell
.\start-dev.ps1
```

### Opción 2: Manual (paso a paso)

```powershell
# 1. Levantar PostgreSQL
docker-compose up -d postgres

# 2. Esperar a que PostgreSQL esté listo (unos 5 segundos)
Start-Sleep -Seconds 5

# 3. Iniciar Backend
cd backend
npm start  # Dejar corriendo en esta terminal

# 4. En otra terminal, iniciar Flutter
cd creapolis_app
flutter run -d chrome --web-port=8080
```

## 🛑 Cómo Detener Todo

```powershell
# 1. En la terminal de Flutter: Presionar Ctrl+C

# 2. En la terminal del Backend: Presionar Ctrl+C

# 3. Detener PostgreSQL (opcional, puede dejarse corriendo):
docker-compose down
```

## 🔍 Comandos Útiles de Verificación

### Verificar puertos en uso

```powershell
# Verificar puerto 3000 (Backend)
Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue

# Verificar puerto 8080 (Flutter)
Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue

# Verificar puerto 5432 (PostgreSQL)
Get-NetTCPConnection -LocalPort 5432 -ErrorAction SilentlyContinue
```

### Ver logs en tiempo real

```powershell
# Backend: Ver en la terminal donde se ejecutó npm start

# PostgreSQL:
docker logs -f creapolis-postgres

# Flutter: Ver en la terminal donde se ejecutó flutter run
```

### Probar conectividad

```powershell
# Backend Health Check
Invoke-WebRequest http://localhost:3000/api/health

# Test de login (necesitas credenciales válidas)
$body = @{
    email = "user@example.com"
    password = "password"
} | ConvertTo-Json

Invoke-WebRequest -Uri http://localhost:3000/api/auth/login `
  -Method POST `
  -ContentType "application/json" `
  -Body $body
```

## 📚 Documentación de Fixes

- [FIX_TASK_MODEL_PARSING.md](./FIX_TASK_MODEL_PARSING.md) - Fix de parseo del TaskModel
- [FIX_TASK_DETAIL_404.md](./FIX_TASK_DETAIL_404.md) - Nueva ruta para obtener tarea por ID
- [CORS_CONFIG.md](./CORS_CONFIG.md) - Configuración de CORS para puerto 8080

## ⚠️ Notas Importantes

1. **Backend corriendo localmente**: El backend NO está corriendo en Docker, está corriendo localmente con `npm start`. Esto permite aplicar cambios rápidamente sin reconstruir la imagen.

2. **Hot Reload en Flutter**: Después de hacer cambios en el código Flutter:

   - Presiona `r` para hot reload
   - Presiona `R` para hot restart (reinicio completo)

3. **Reiniciar Backend**: Si haces cambios en el código del backend, necesitas:

   ```powershell
   # Detener el proceso actual (Ctrl+C en la terminal)
   # Luego reiniciar:
   cd backend
   npm start
   ```

4. **PostgreSQL persiste datos**: Los datos de la base de datos se mantienen entre reinicios gracias al volumen Docker `creapolis-postgres-data`.

## 🐛 Troubleshooting

### Error: Puerto 3000 en uso

```powershell
# Encontrar y terminar el proceso
$proc = Get-NetTCPConnection -LocalPort 3000 | Select-Object -First 1
Stop-Process -Id $proc.OwningProcess -Force
```

### Error: Puerto 8080 en uso

```powershell
# Encontrar y terminar el proceso
$proc = Get-NetTCPConnection -LocalPort 8080 | Select-Object -First 1
Stop-Process -Id $proc.OwningProcess -Force
```

### Error: No se puede conectar a PostgreSQL

```powershell
# Verificar que el contenedor está corriendo
docker ps | Select-String "postgres"

# Si no está corriendo, iniciarlo:
docker-compose up -d postgres

# Ver logs para más detalles:
docker logs creapolis-postgres --tail 50
```

### Backend no se conecta a la DB

Verificar que el archivo `backend/.env` tenga las credenciales correctas:

```
DATABASE_URL="postgresql://creapolis:creapolis_password_2024@localhost:5432/creapolis_db?schema=public"
```

## 🚀 Próximos Pasos Recomendados

1. ✅ Probar creación de tareas
2. ✅ Probar navegación a detalle de tarea
3. ✅ Probar time tracking
4. 📝 Agregar tests unitarios para los nuevos cambios
5. 📝 Considerar mover la lógica de getTaskById a TaskService en el backend
6. 📝 Actualizar documentación de API con la nueva ruta

## 📊 Estado de Features

| Feature          | Backend | Flutter | Estado               |
| ---------------- | ------- | ------- | -------------------- |
| Login            | ✅      | ✅      | Funcionando          |
| Proyectos        | ✅      | ✅      | Funcionando          |
| Tareas (CRUD)    | ✅      | ✅      | Funcionando          |
| Detalle de tarea | ✅      | ✅      | **Recién arreglado** |
| Time tracking    | ✅      | ✅      | Funcionando          |
| Dependencias     | ✅      | ✅      | Funcionando          |
| Google Calendar  | ⚠️      | ❌      | No configurado       |
