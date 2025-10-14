# 🌐 Flutter Web - Configuración de Puerto Fijo

**Problema Resuelto:** Flutter Web ya no usará puertos aleatorios  
**Puerto Configurado:** `http://localhost:8080`

---

## 🎯 ¿Por qué Puerto Fijo?

Flutter Web por defecto usa puertos dinámicos (aleatorios) cada vez que ejecutas la app:

- Primera ejecución: `http://localhost:56757`
- Segunda ejecución: `http://localhost:63821`
- Tercera ejecución: `http://localhost:51234`

Esto causa **problemas con CORS** porque el backend necesita saber de antemano qué orígenes permitir.

**Solución:** Configurar Flutter para usar siempre el mismo puerto: **8080**

---

## ✅ Configuración Aplicada

### 1. Archivo de Configuración VS Code

Creado: `creapolis_app/.vscode/launch.json`

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter Web (Chrome - Puerto 8080)",
      "request": "launch",
      "type": "dart",
      "deviceId": "chrome",
      "args": ["--web-port=8080", "--web-hostname=localhost"]
    }
  ]
}
```

### 2. Backend CORS Actualizado

Archivo: `.env`

```env
CORS_ORIGIN=http://localhost:5173,http://localhost:8080
```

- `http://localhost:5173` - Para frontend Vite (React/Vue)
- `http://localhost:8080` - Para Flutter Web (puerto fijo)

### 3. Backend Reconstruido

```powershell
docker-compose up -d --build backend
```

---

## 🚀 Cómo Ejecutar Flutter Web

### Opción 1: Desde VS Code (RECOMENDADO)

1. **Abrir el panel de Debug:**

   - Presiona `F5` o
   - Click en el ícono de Debug (▶️) en la barra lateral
   - O presiona `Ctrl+Shift+D`

2. **Seleccionar configuración:**

   - En el dropdown superior, selecciona: **"Flutter Web (Chrome - Puerto 8080)"**

3. **Iniciar Debug:**

   - Presiona `F5` o click en el botón verde ▶️

4. **Resultado:**
   - Chrome se abrirá automáticamente
   - URL: `http://localhost:8080`
   - ✅ Siempre el mismo puerto!

### Opción 2: Desde Terminal

```powershell
cd creapolis_app
flutter run -d chrome --web-port=8080
```

### Opción 3: Seleccionar navegador desde Terminal

**Chrome:**

```powershell
flutter run -d chrome --web-port=8080
```

**Edge:**

```powershell
flutter run -d edge --web-port=8080
```

**Ver dispositivos disponibles:**

```powershell
flutter devices
```

---

## 🔍 Verificar que Funciona

### 1. Verificar el puerto en el navegador

Después de ejecutar, verifica en la barra de direcciones:

```
http://localhost:8080
```

Si ves un puerto diferente, algo no se aplicó correctamente.

### 2. Verificar CORS en DevTools

1. Abrir DevTools (F12)
2. Ir a la pestaña **Console**
3. Ejecutar:

```javascript
fetch("http://localhost:3000/api/health")
  .then((res) => res.json())
  .then((data) => console.log("✅ CORS OK:", data))
  .catch((err) => console.error("❌ CORS Error:", err));
```

Debería mostrar:

```json
✅ CORS OK: {
  status: "ok",
  timestamp: "2025-10-06T...",
  environment: "production"
}
```

### 3. Verificar en Network Tab

1. Ir a DevTools → **Network**
2. Hacer una petición (login o register)
3. Click en la petición
4. Ver **Headers** → **Response Headers**
5. Verificar:

```
Access-Control-Allow-Origin: http://localhost:8080
```

---

## 📱 Configuraciones Adicionales en launch.json

El archivo `launch.json` incluye múltiples configuraciones:

### 1. Flutter Web (Chrome - Puerto 8080) ⭐ PREDETERMINADO

```json
{
  "name": "Flutter Web (Chrome - Puerto 8080)",
  "deviceId": "chrome",
  "args": ["--web-port=8080"]
}
```

### 2. Flutter Web (Edge - Puerto 8080)

```json
{
  "name": "Flutter Web (Edge - Puerto 8080)",
  "deviceId": "edge",
  "args": ["--web-port=8080"]
}
```

### 3. Flutter Debug (Dispositivo/Emulador)

```json
{
  "name": "Flutter (Debug - Dispositivo Conectado)"
}
```

### 4. Flutter Profile Mode

```json
{
  "name": "Flutter (Profile)",
  "flutterMode": "profile"
}
```

### 5. Flutter Release Mode

```json
{
  "name": "Flutter (Release)",
  "flutterMode": "release"
}
```

---

## 🛠️ Cambiar el Puerto (Opcional)

Si prefieres usar un puerto diferente:

### 1. Editar launch.json

```json
"args": [
  "--web-port=3001",  // Cambiar aquí
  "--web-hostname=localhost"
]
```

### 2. Actualizar .env

```env
CORS_ORIGIN=http://localhost:5173,http://localhost:3001
```

### 3. Reconstruir backend

```powershell
docker-compose up -d --build backend
```

---

## 🔧 Troubleshooting

### Problema: Flutter sigue usando puerto aleatorio

**Causa:** No estás usando la configuración de launch.json

**Solución:**

1. En VS Code, presiona `F5`
2. Asegúrate de seleccionar **"Flutter Web (Chrome - Puerto 8080)"**
3. No ejecutes `flutter run` sin argumentos desde terminal

### Problema: Puerto 8080 ya está en uso

**Ver qué proceso usa el puerto:**

```powershell
netstat -ano | findstr :8080
```

**Opción 1: Cerrar el proceso**

```powershell
# Obtener el PID de la última columna del comando anterior
taskkill /PID XXXX /F
```

**Opción 2: Usar otro puerto**

- Cambiar en `launch.json` y `.env`
- Reconstruir backend

### Problema: Error "No devices found"

**Solución:** Asegúrate de tener Chrome instalado

```powershell
flutter doctor
flutter devices
```

Debería mostrar:

```
Chrome (web) • chrome • web-javascript • Google Chrome 120.0.6099.109
```

### Problema: Error de CORS persiste

**Verificar variable de entorno en el contenedor:**

```powershell
docker-compose exec backend printenv | findstr CORS
```

Debería mostrar:

```
CORS_ORIGIN=http://localhost:5173,http://localhost:8080
```

**Si no muestra el valor correcto:**

```powershell
# Detener servicios
docker-compose down

# Verificar .env local
cat .env | findstr CORS

# Iniciar de nuevo
docker-compose up -d
```

---

## 📋 Checklist Final

Antes de ejecutar la app, verificar:

- [ ] Archivo `creapolis_app/.vscode/launch.json` creado
- [ ] Archivo `.env` actualizado con puerto 8080
- [ ] Backend reconstruido: `docker-compose up -d --build backend`
- [ ] Backend corriendo: `docker-compose ps` (ambos Healthy)
- [ ] Chrome instalado: `flutter devices` muestra Chrome
- [ ] En VS Code, configuración "Flutter Web (Chrome - Puerto 8080)" seleccionada

---

## 🎉 Beneficios del Puerto Fijo

✅ **No más problemas de CORS** - El backend siempre sabe qué origen permitir  
✅ **URLs consistentes** - Siempre `http://localhost:8080`  
✅ **Fácil de compartir** - Puedes compartir la URL con otros developers  
✅ **Bookmarks funcionan** - Puedes guardar en favoritos  
✅ **Testing más fácil** - Scripts de testing pueden usar siempre la misma URL  
✅ **Debugging mejorado** - Network logs más claros al revisar problemas

---

## 📚 Comandos Rápidos

```powershell
# Ejecutar Flutter Web con puerto fijo
cd creapolis_app
flutter run -d chrome --web-port=8080

# Ver estado de Docker
docker-compose ps

# Ver logs del backend
docker-compose logs -f backend

# Verificar CORS en el contenedor
docker-compose exec backend printenv | findstr CORS

# Reconstruir backend si cambias CORS
docker-compose up -d --build backend

# Hot restart en Flutter (sin cerrar el navegador)
# Presiona 'R' en la terminal donde corre flutter

# Hot reload en Flutter (más rápido)
# Presiona 'r' en la terminal donde corre flutter
```

---

## 🌐 URLs del Sistema

| Servicio       | URL                              | Descripción                      |
| -------------- | -------------------------------- | -------------------------------- |
| Flutter Web    | http://localhost:8080            | Aplicación Flutter (Puerto Fijo) |
| Backend API    | http://localhost:3000            | API REST                         |
| Backend Health | http://localhost:3000/api/health | Health check                     |
| PostgreSQL     | localhost:5433                   | Base de datos                    |
| PgAdmin        | http://localhost:5050            | Admin de BD (opcional)           |

---

## ✅ Estado

**Configuración:** ✅ Completa  
**Backend:** ✅ Actualizado con puerto 8080  
**Launch Config:** ✅ Creada en `.vscode/launch.json`  
**CORS:** ✅ Configurado para localhost:8080  
**Listo para usar:** ✅ Sí

**Próximo paso:** Ejecutar Flutter con `F5` en VS Code y probar el registro de usuario.
