# Configuración del Puerto del Backend - Puerto 3001

## 📋 Resumen

El backend de Creapolis está configurado para ejecutarse **siempre en el puerto 3001** en todos los entornos (desarrollo, testing y producción).

## 🔧 Archivos de Configuración

### 1. Variables de Entorno

#### `backend/.env`

```bash
PORT=3001
GOOGLE_REDIRECT_URI=http://localhost:3001/api/integrations/google/callback
```

#### `backend/.env.example`

```bash
PORT=3001
GOOGLE_REDIRECT_URI=http://localhost:3001/api/integrations/google/callback
```

#### `.env.docker`

```bash
BACKEND_PORT=3001
GOOGLE_REDIRECT_URI=http://localhost:3001/api/integrations/google/callback
```

### 2. Código del Servidor

#### `backend/src/server.js`

```javascript
const PORT = process.env.PORT || 3001; // Puerto por defecto cambiado a 3001
```

### 3. Configuración Docker

#### `backend/Dockerfile`

```dockerfile
EXPOSE 3001
```

#### `backend/Dockerfile.dev`

```dockerfile
EXPOSE 3001
```

#### `docker-compose.yml`

```yaml
backend:
  ports:
    - "${BACKEND_PORT:-3001}:3001"
  environment:
    GOOGLE_REDIRECT_URI: ${GOOGLE_REDIRECT_URI:-http://localhost:3001/api/integrations/google/callback}
  healthcheck:
    test:
      [
        "CMD",
        "node",
        "-e",
        "require('http').get('http://localhost:3001/api/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})",
      ]
```

#### `docker-compose.dev.yml`

```yaml
backend:
  environment:
    PORT: 3001
  ports:
    - "${BACKEND_PORT:-3001}:3001"
```

### 4. Frontend Flutter

#### `creapolis_app/lib/core/constants/api_constants.dart`

```dart
static const String baseUrl = 'http://localhost:3001/api';
```

## 🌐 URLs de Acceso

- **API Base URL**: `http://localhost:3001/api`
- **Health Check**: `http://localhost:3001/api/health`
- **Documentación**: `http://localhost:3001/api/docs` (si está configurado)

## 📱 Configuración por Plataforma

### Desarrollo Local

- **URL**: `http://localhost:3001/api`

### Android Emulator

- **URL**: `http://10.0.2.2:3001/api`

### iOS Simulator

- **URL**: `http://localhost:3001/api`

### Dispositivo Físico

- **URL**: `http://[IP_DE_TU_MAQUINA]:3001/api`
- Ejemplo: `http://192.168.1.100:3001/api`

## 🚀 Comandos de Inicio

### Desarrollo Local

```bash
cd backend
npm run dev
# El servidor se iniciará en http://localhost:3001
```

### Docker (Desarrollo)

```bash
docker-compose -f docker-compose.dev.yml up
# Backend disponible en http://localhost:3001
```

### Docker (Producción)

```bash
docker-compose up
# Backend disponible en http://localhost:3001
```

## ✅ Verificación

Para verificar que el backend está corriendo en el puerto correcto:

```bash
curl http://localhost:3001/api/health
```

Respuesta esperada:

```json
{
  "status": "ok",
  "timestamp": "2024-01-XX-XXXX",
  "environment": "development"
}
```

## 📝 Notas Importantes

1. **Consistencia**: El puerto 3001 debe mantenerse en todos los entornos para evitar conflictos
2. **CORS**: La configuración CORS permite requests desde los puertos típicos de frontend (5173, 8080)
3. **OAuth**: Las URLs de callback de Google OAuth están configuradas para el puerto 3001
4. **Docker**: Los contenedores exponen el puerto 3001 tanto interna como externamente
5. **Documentación**: Toda la documentación de API ha sido actualizada para reflejar el puerto 3001

## 🔄 Migración desde Puerto 3000

Si tienes configuraciones locales que apuntaban al puerto 3000:

1. Actualiza tu archivo `.env` local
2. Reinicia el servidor backend
3. Verifica que el frontend esté configurado para usar el puerto 3001
4. Actualiza cualquier tool de testing (Postman, curl scripts, etc.)

## 🐛 Troubleshooting

### Error: "EADDRINUSE"

Si ves este error, significa que el puerto 3001 ya está en uso:

```bash
# Encuentra el proceso usando el puerto
netstat -ano | findstr :3001
# Termina el proceso si es necesario
taskkill /PID [PID_NUMBER] /F
```

### Error de CORS

Si tienes errores de CORS desde el frontend:

1. Verifica que `CORS_ORIGIN` incluya la URL de tu frontend
2. Asegúrate de que el frontend esté haciendo requests a `localhost:3001`

---

**Fecha de actualización**: $(Get-Date -Format "yyyy-MM-dd")
**Versión**: 1.0.0
