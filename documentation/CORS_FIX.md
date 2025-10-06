# 🔧 Solución: Error de CORS con Flutter Web

**Fecha:** 6 de Octubre, 2025  
**Problema:** CORS bloqueando peticiones de Flutter Web al backend

---

## 🐛 Error Original

```
Access to XMLHttpRequest at 'http://localhost:3000/api/auth/register'
from origin 'http://localhost:56757' has been blocked by CORS policy:
Response to preflight request doesn't pass access control check:
The 'Access-Control-Allow-Origin' header has a value 'http://localhost:5173'
that is not equal to the supplied origin.
```

### 🔍 Análisis del Error

1. **Flutter Web** corre en un puerto aleatorio (en este caso: `56757`)
2. **Backend** estaba configurado para aceptar solo: `http://localhost:5173` (puerto de Vite)
3. **CORS Policy** rechazó la petición porque el origen no coincidía

---

## ✅ Solución Implementada

### 1. Actualizar Variable de Entorno (`.env`)

**Antes:**

```env
CORS_ORIGIN=http://localhost:5173
```

**Después:**

```env
# Múltiples orígenes separados por coma (Vite frontend, Flutter web)
CORS_ORIGIN=http://localhost:5173,http://localhost:56757
```

### 2. Actualizar Configuración de CORS (`backend/src/server.js`)

**Antes:**

```javascript
// CORS configuration
app.use(
  cors({
    origin: process.env.CORS_ORIGIN || "http://localhost:5173",
    credentials: true,
  })
);
```

**Después:**

```javascript
// CORS configuration
const corsOrigins = process.env.CORS_ORIGIN
  ? process.env.CORS_ORIGIN.split(",").map((origin) => origin.trim())
  : ["http://localhost:5173"];

app.use(
  cors({
    origin: corsOrigins,
    credentials: true,
  })
);
```

### 3. Reconstruir y Reiniciar Backend

```powershell
docker-compose up -d --build backend
```

---

## 🔍 Cómo Funciona Ahora

### Configuración Multi-Origen

El backend ahora:

1. Lee la variable `CORS_ORIGIN` del archivo `.env`
2. Si contiene comas, divide los orígenes en un array
3. Acepta peticiones desde cualquiera de los orígenes listados

### Orígenes Permitidos

✅ `http://localhost:5173` - Frontend Vite (React/Vue/etc.)  
✅ `http://localhost:56757` - Flutter Web (puerto actual)  
✅ Cualquier otro origen que agregues separado por coma

---

## 📝 Notas Importantes

### ⚠️ Puerto Dinámico de Flutter Web

El puerto de Flutter Web puede cambiar cada vez que ejecutas la app. Si ves un error de CORS con un puerto diferente:

**Opción 1: Agregar el nuevo puerto al .env**

```env
CORS_ORIGIN=http://localhost:5173,http://localhost:56757,http://localhost:NUEVO_PUERTO
```

**Opción 2: Usar un puerto fijo en Flutter**

```powershell
flutter run -d chrome --web-port=8080
```

Luego agregar al .env:

```env
CORS_ORIGIN=http://localhost:5173,http://localhost:8080
```

**Opción 3: Permitir todos los orígenes locales (SOLO DESARROLLO)**

```javascript
// En server.js
app.use(
  cors({
    origin: (origin, callback) => {
      // Permitir cualquier localhost
      if (!origin || origin.startsWith("http://localhost:")) {
        callback(null, true);
      } else {
        callback(new Error("Not allowed by CORS"));
      }
    },
    credentials: true,
  })
);
```

---

## 🚀 Cómo Ejecutar Flutter con Puerto Fijo

### Opción Recomendada: Puerto Fijo

```powershell
# Navegar a la carpeta de Flutter
cd creapolis_app

# Ejecutar con puerto específico
flutter run -d chrome --web-port=8080
```

Luego actualizar `.env`:

```env
CORS_ORIGIN=http://localhost:5173,http://localhost:8080
```

Y reconstruir backend:

```powershell
docker-compose up -d --build backend
```

---

## 🧪 Verificar que CORS Funciona

### 1. Desde el navegador (DevTools Console)

```javascript
fetch("http://localhost:3000/api/health", {
  method: "GET",
  headers: {
    "Content-Type": "application/json",
  },
})
  .then((res) => res.json())
  .then((data) => console.log("✅ CORS OK:", data))
  .catch((err) => console.error("❌ CORS Error:", err));
```

### 2. Ver headers de respuesta

En las DevTools del navegador:

1. Abrir Network tab
2. Hacer una petición al backend
3. Ver la respuesta
4. Verificar el header: `Access-Control-Allow-Origin`

Debería mostrar tu origen actual.

---

## 🔧 Troubleshooting

### Problema: Aún veo error de CORS después de los cambios

**Solución 1: Verificar que el backend tomó los cambios**

```powershell
# Ver variables de entorno en el contenedor
docker-compose exec backend printenv | grep CORS
```

Debería mostrar:

```
CORS_ORIGIN=http://localhost:5173,http://localhost:56757
```

**Solución 2: Verificar logs del backend**

```powershell
docker-compose logs backend | Select-String -Pattern "CORS|cors"
```

**Solución 3: Limpiar cache del navegador**

- Chrome: `Ctrl+Shift+Delete` → Borrar caché
- O abrir en modo incógnito

**Solución 4: Reconstruir forzando sin cache**

```powershell
docker-compose build --no-cache backend
docker-compose up -d backend
```

### Problema: El puerto de Flutter cambia cada vez

**Solución: Usar puerto fijo**

```powershell
flutter run -d chrome --web-port=8080
```

O agregar en `creapolis_app/launch.json` (VS Code):

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter Web",
      "request": "launch",
      "type": "dart",
      "args": ["-d", "chrome", "--web-port=8080"]
    }
  ]
}
```

---

## 📋 Checklist de Verificación

Después de aplicar los cambios, verificar:

- [ ] `.env` tiene los orígenes correctos separados por coma
- [ ] `backend/src/server.js` tiene el código de split(',')
- [ ] Backend se reconstruyó: `docker-compose up -d --build backend`
- [ ] Backend está corriendo: `docker-compose ps`
- [ ] Health endpoint funciona: `curl http://localhost:3000/api/health`
- [ ] Flutter Web puede hacer peticiones sin error de CORS
- [ ] DevTools Network muestra status 200 en las peticiones

---

## 🌐 Configuración para Producción

### ⚠️ IMPORTANTE: No usar \* en producción

**MAL (inseguro):**

```javascript
app.use(cors({ origin: "*" }));
```

**BIEN (seguro):**

```javascript
const allowedOrigins = [
  "https://tuapp.com",
  "https://www.tuapp.com",
  "https://app.tuapp.com",
];

app.use(
  cors({
    origin: (origin, callback) => {
      if (!origin || allowedOrigins.includes(origin)) {
        callback(null, true);
      } else {
        callback(new Error("Not allowed by CORS"));
      }
    },
    credentials: true,
  })
);
```

### Variables de Entorno por Entorno

**Development (.env.development):**

```env
CORS_ORIGIN=http://localhost:5173,http://localhost:8080
```

**Production (.env.production):**

```env
CORS_ORIGIN=https://tuapp.com,https://www.tuapp.com
```

---

## 📚 Recursos Adicionales

- [MDN: CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
- [Express CORS Middleware](https://expressjs.com/en/resources/middleware/cors.html)
- [Flutter Web Port Configuration](https://docs.flutter.dev/platform-integration/web/building)

---

## ✅ Resumen

**Problema:** CORS bloqueaba peticiones de Flutter Web  
**Causa:** Backend solo aceptaba `http://localhost:5173`  
**Solución:** Configurar múltiples orígenes en CORS  
**Resultado:** ✅ Flutter Web puede comunicarse con el backend

**Archivos modificados:**

1. `.env` - Agregado puerto de Flutter a CORS_ORIGIN
2. `backend/src/server.js` - Soporte para múltiples orígenes
3. Backend reconstruido y reiniciado

**Estado:** ✅ Completado y verificado
