# Configuración de CORS para Desarrollo

## Problema Actual

El backend Node.js tiene configuración de CORS que solo permite orígenes específicos. Flutter Web usa puertos aleatorios por defecto, causando errores de CORS.

## Solución Implementada ✅

### Opción Elegida: Puerto Fijo (8080)

Se decidió usar **puerto fijo 8080** para Flutter Web porque:

- ✅ Más seguro desde el inicio
- ✅ Evita problemas al pasar a producción
- ✅ Configuración consistente entre desarrollo y producción
- ✅ Fácil de documentar y compartir con el equipo

### Configuración del Backend

**Archivo**: `backend/.env`

```bash
# CORS Configuration
# Multiple origins separated by comma
CORS_ORIGIN=http://localhost:5173,http://localhost:8080
```

- `http://localhost:5173` → React/Vite (si se usa)
- `http://localhost:8080` → Flutter Web

**Nota**: Si no existe `backend/.env`, copiar desde `backend/.env.example`

### Scripts de Desarrollo

#### Flutter Web (Recomendado)

```powershell
# Desde la raíz del proyecto
.\creapolis_app\run-dev.ps1

# O directamente desde creapolis_app
cd creapolis_app
.\run-dev.ps1
```

El script `run-dev.ps1`:

- ✓ Verifica si el puerto 8080 está en uso
- ✓ Ofrece terminar el proceso que lo está usando
- ✓ Inicia Flutter en el puerto correcto
- ✓ Muestra mensajes informativos

#### Backend

```powershell
cd backend
npm start
```

## Opción Alternativa (No Recomendada)

### Configuración CORS Permisiva para Desarrollo

Si prefieres **permitir cualquier origen** durante desarrollo (NO recomendado):

**Archivo**: `backend/src/server.js`

```javascript
// Solo para desarrollo - NO usar en producción
const corsOptions =
  process.env.NODE_ENV === "production"
    ? {
        origin: corsOrigins,
        credentials: true,
      }
    : {
        origin: true, // Permite cualquier origen en desarrollo
        credentials: true,
      };

app.use(cors(corsOptions));
```

### ⚠️ Advertencias

- Debe cambiarse antes de producción
- Menos seguro
- Puede ocultar problemas de configuración

## Verificación

### 1. Verificar Backend

```bash
# Ver configuración de CORS en logs del backend al iniciar
npm start
```

### 2. Verificar Flutter Web

Abrir DevTools del navegador → Console:

- ✓ No debe haber errores de CORS
- ✓ Requests a `http://localhost:3000/api/...` deben funcionar

### 3. Test de Login

1. Abrir `http://localhost:8080`
2. Intentar login
3. Verificar en Network tab que no hay errores CORS

## Troubleshooting

### Error: "Access-Control-Allow-Origin"

**Causa**: Puerto incorrecto o backend no configurado

**Solución**:

```powershell
# 1. Verificar que Flutter use puerto 8080
# Ver en la consola: "Running on http://localhost:8080"

# 2. Verificar .env del backend
cd backend
cat .env  # o notepad .env
# Debe contener: CORS_ORIGIN=http://localhost:5173,http://localhost:8080

# 3. Reiniciar backend
npm start
```

### Puerto 8080 en Uso

**Solución 1**: Usar el script que lo maneja automáticamente

```powershell
.\creapolis_app\run-dev.ps1
```

**Solución 2**: Manual

```powershell
# Encontrar proceso
Get-NetTCPConnection -LocalPort 8080 | Select-Object OwningProcess

# Terminar proceso
Stop-Process -Id <PID> -Force

# Iniciar Flutter
flutter run -d chrome --web-port=8080
```

## Producción

Para producción, asegúrate de:

1. **Backend .env**:

   ```bash
   CORS_ORIGIN=https://tu-dominio.com
   NODE_ENV=production
   ```

2. **Flutter Web**:
   - Compilar con `flutter build web`
   - Servir desde un servidor web (nginx, Apache, etc.)
   - Configurar CORS en el servidor web si es necesario

## Referencias

- [Flutter Web deployment](https://docs.flutter.dev/deployment/web)
- [Express CORS middleware](https://expressjs.com/en/resources/middleware/cors.html)
- [MDN - CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
