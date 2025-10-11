# 🚀 Guía Rápida - Ejecutar Flutter con Puerto Fijo

## Opción 1: Usar el Script PowerShell (Más Fácil) ⭐

```powershell
# Ejecutar en Chrome (puerto 8080)
.\run-flutter.ps1

# Ejecutar en Edge
.\run-flutter.ps1 -Device edge

# Ejecutar en otro puerto
.\run-flutter.ps1 -Port 3001

# Modo Release
.\run-flutter.ps1 -Release

# Modo Profile
.\run-flutter.ps1 -Profile
```

El script automáticamente:

- ✅ Verifica que Flutter esté instalado
- ✅ Verifica que el backend Docker esté corriendo
- ✅ Cambia al directorio de la app
- ✅ Inicia Flutter en el puerto especificado
- ✅ Muestra información útil en pantalla

---

## Opción 2: Desde VS Code (Recomendado para Debug)

1. Presiona `F5`
2. Selecciona: **"Flutter Web (Chrome - Puerto 8080)"**
3. ¡Listo! Se abrirá en `http://localhost:8080`

---

## Opción 3: Desde Terminal Manual

```powershell
cd creapolis_app
flutter run -d chrome --web-port=8080
```

---

## 🔧 Configuración Aplicada

### Backend CORS

```env
# .env
CORS_ORIGIN=http://localhost:5173,http://localhost:8080
```

### Flutter Launch Config

```json
// creapolis_app/.vscode/launch.json
{
  "name": "Flutter Web (Chrome - Puerto 8080)",
  "args": ["--web-port=8080"]
}
```

---

## ✅ Verificar que Todo Funciona

1. **Backend corriendo:**

   ```powershell
   docker-compose ps
   ```

   Ambos servicios deben estar "Up (healthy)"

2. **Flutter en puerto correcto:**
   Abrir el navegador y verificar URL: `http://localhost:8080`

3. **CORS funcionando:**
   - Abrir DevTools (F12)
   - Intentar login o register
   - No debe haber errores de CORS

---

## 📚 Documentación Completa

- `FLUTTER_FIXED_PORT.md` - Guía completa de configuración
- `CORS_FIX.md` - Solución de problemas de CORS
- `FLUTTER_FIX_NAVIGATION.md` - Corrección de rutas
- `TEST_RESULTS.md` - Resultados de pruebas del backend

---

## 🆘 Problemas Comunes

### Puerto 8080 ocupado

```powershell
# Ver qué proceso usa el puerto
netstat -ano | findstr :8080

# Usar otro puerto
.\run-flutter.ps1 -Port 3001
```

### Backend no corre

```powershell
docker-compose up -d
```

### Error de CORS

```powershell
# Verificar configuración
docker-compose exec backend printenv | findstr CORS

# Debe mostrar: CORS_ORIGIN=http://localhost:5173,http://localhost:8080
```

---

## 🎯 URLs del Sistema

| Servicio     | URL                              |
| ------------ | -------------------------------- |
| Flutter Web  | http://localhost:8080            |
| Backend API  | http://localhost:3000            |
| Health Check | http://localhost:3000/api/health |
| PostgreSQL   | localhost:5433                   |
| PgAdmin      | http://localhost:5050            |

---

**¡Listo para desarrollar! 🎉**
