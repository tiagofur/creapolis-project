# Fix: Error de Conexión - PostgreSQL en Puerto Incorrecto

## Fecha: 2025-10-08 12:25

## 🔴 Problema

Flutter mostraba un error de conexión al intentar hacer login:

```
DioError ║ DioExceptionType.connectionError
The connection errored: The XMLHttpRequest onError callback was called.
```

```
⛔ AuthBloc: Error en login - Sin conexión a internet. Verifica tu red y vuelve a intentar.
```

## 🔍 Diagnóstico

### 1. Backend no estaba corriendo

El backend se había detenido debido a un error de conexión con PostgreSQL.

### 2. Puerto de PostgreSQL incorrecto

El contenedor de PostgreSQL estaba mapeado al puerto **5433** en el host, pero el backend intentaba conectarse al puerto **5432**.

**Verificación del contenedor**:

```powershell
docker ps | Select-String "postgres"
```

**Resultado**:

```
creapolis-postgres   0.0.0.0:5433->5432/tcp
```

El mapeo era `5433:5432`, lo que significa:

- Puerto del host: **5433**
- Puerto del contenedor: 5432

**Configuración incorrecta en `backend/.env`**:

```properties
DATABASE_URL="postgresql://creapolis:creapolis_password_2024@localhost:5432/creapolis_db?schema=public"
                                                                    ^^^^
                                                                 Incorrecto!
```

## ✅ Solución

### Paso 1: Actualizar el puerto en backend/.env

**Archivo**: `backend/.env`

```properties
# ANTES (Incorrecto)
DATABASE_URL="postgresql://creapolis:creapolis_password_2024@localhost:5432/creapolis_db?schema=public"

# DESPUÉS (Correcto)
DATABASE_URL="postgresql://creapolis:creapolis_password_2024@localhost:5433/creapolis_db?schema=public"
```

### Paso 2: Reiniciar el backend

```powershell
cd backend
npm start
```

**Resultado esperado**:

```
✅ Database connected successfully
🚀 Server running on port 3000
```

### Paso 3: Reiniciar Flutter

```powershell
cd creapolis_app
flutter run -d chrome --web-port=8080
```

## 🎯 Resultado

- ✅ Backend conectado correctamente a PostgreSQL
- ✅ Flutter puede conectarse al backend
- ✅ Login funciona correctamente

## 📝 Notas Técnicas

### ¿Por qué PostgreSQL está en el puerto 5433?

Esto ocurre cuando ya hay otro servicio (posiblemente otra instancia de PostgreSQL) usando el puerto 5432 en el host. Docker automáticamente asigna el siguiente puerto disponible.

### Verificar puertos en uso

```powershell
# Verificar qué está usando el puerto 5432
Get-NetTCPConnection -LocalPort 5432 -ErrorAction SilentlyContinue

# Verificar qué está usando el puerto 5433
Get-NetTCPConnection -LocalPort 5433 -ErrorAction SilentlyContinue
```

### Opciones para resolver permanentemente

#### Opción 1: Detener el servicio que usa el puerto 5432

Si hay otro PostgreSQL corriendo:

```powershell
# Buscar el servicio de PostgreSQL
Get-Service | Where-Object {$_.Name -like "*postgres*"}

# Detener el servicio (si no lo necesitas)
Stop-Service postgresql-x64-15  # O el nombre que corresponda
```

#### Opción 2: Actualizar docker-compose.yml para usar puerto específico

**Archivo**: `docker-compose.yml`

```yaml
services:
  postgres:
    # ...
    ports:
      - "5433:5432" # Usar explícitamente 5433
```

Y mantener el `.env` del backend con `localhost:5433`.

#### Opción 3: Usar el puerto estándar (Recomendado)

Si no necesitas el otro PostgreSQL:

1. Detener y remover el contenedor actual:

```powershell
docker-compose down
```

2. Detener el servicio PostgreSQL local:

```powershell
Stop-Service postgresql-x64-15  # Ajustar nombre según tu instalación
```

3. Actualizar `docker-compose.yml` para forzar el puerto 5432:

```yaml
ports:
  - "5432:5432"
```

4. Actualizar `backend/.env`:

```properties
DATABASE_URL="postgresql://creapolis:creapolis_password_2024@localhost:5432/creapolis_db?schema=public"
```

5. Levantar los servicios:

```powershell
docker-compose up -d postgres
cd backend
npm start
```

## 🔧 Script Mejorado

Para evitar este problema en el futuro, el script `start-dev.ps1` podría detectar automáticamente en qué puerto está PostgreSQL:

```powershell
# Detectar el puerto de PostgreSQL
$postgresContainer = docker ps --filter "name=creapolis-postgres" --format "{{.Ports}}"
if ($postgresContainer -match '0\.0\.0\.0:(\d+)->5432') {
    $postgresPort = $matches[1]
    Write-Host "PostgreSQL detectado en puerto: $postgresPort"

    # Actualizar .env si es necesario
    $envContent = Get-Content "backend\.env" -Raw
    if ($envContent -notmatch "localhost:$postgresPort") {
        Write-Host "Actualizando puerto en backend\.env..."
        $envContent = $envContent -replace "localhost:\d+", "localhost:$postgresPort"
        Set-Content "backend\.env" -Value $envContent
    }
}
```

## 🐛 Troubleshooting

### Error persiste después del fix

1. **Verificar que el backend está corriendo**:

```powershell
Get-NetTCPConnection -LocalPort 3000
```

2. **Probar la conexión directamente**:

```powershell
curl http://localhost:3000/api/health
```

3. **Ver logs del backend**:
   Verificar en la terminal donde se ejecutó `npm start`

4. **Ver logs de PostgreSQL**:

```powershell
docker logs creapolis-postgres --tail 50
```

### Backend se conecta pero Flutter no

1. **Verificar CORS**: El backend debe tener configurado `http://localhost:8080` en CORS
2. **Limpiar caché de Flutter**:

```powershell
cd creapolis_app
flutter clean
flutter pub get
flutter run -d chrome --web-port=8080
```

## 📚 Archivos Afectados

```
backend/.env                              # Puerto de PostgreSQL actualizado
```

## 🔗 Relacionado

- [ESTADO_ENTORNO.md](./ESTADO_ENTORNO.md) - Estado del entorno
- [QUICKSTART_DOCKER.md](../QUICKSTART_DOCKER.md) - Guía de inicio con Docker
- [docker-compose.yml](../docker-compose.yml) - Configuración de servicios
