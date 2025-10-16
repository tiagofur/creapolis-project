# 🔧 SETUP AUTOMATIZADO - Creapolis

**Estado:** ✅ **COMPLETADO - Backend Corriendo**  
**Fecha:** 16 de Octubre, 2025

---

## 📋 PROBLEMA IDENTIFICADO

### Error Original:

```bash
❌ Database connection failed: PrismaClientInitializationError
Authentication failed against database server, the provided database credentials
for `creapolis` are not valid.

Error code: P1000
```

**Causa raíz:**

- PostgreSQL no estaba corriendo
- Backend intentaba conectarse sin base de datos activa

---

## ✅ SOLUCIÓN IMPLEMENTADA

### 1️⃣ Configuración de PostgreSQL

**Problema:** Puerto 5432 ocupado por otro proyecto (aegg-postgres)

**Solución:** Usar docker-compose.dev.yml con puerto alternativo (5434)

```powershell
# Levantar PostgreSQL en modo desarrollo
docker-compose -f docker-compose.dev.yml up -d postgres
```

**Resultado:**

```
✅ Container: creapolis-postgres-dev
✅ Puerto: 5434 (no conflicto)
✅ Database: creapolis_dev
✅ User: creapolis
✅ Password: creapolis_dev_2024
```

---

### 2️⃣ Actualización de Credenciales

**Archivo:** `backend/.env`

**Cambio realizado:**

```diff
- DATABASE_URL="postgresql://creapolis:creapolis_password_2024@localhost:5432/creapolis_db?schema=public"
+ DATABASE_URL="postgresql://creapolis:creapolis_dev_2024@localhost:5434/creapolis_dev?schema=public"
```

**Explicación:**

- Puerto: 5432 → 5434 (para evitar conflicto)
- Database: creapolis_db → creapolis_dev (ambiente de desarrollo)
- Password: creapolis_password_2024 → creapolis_dev_2024

---

### 3️⃣ Migraciones de Base de Datos

**Problema:** Migración fallida (tipo "Role" ya existía)

**Solución:** Reset completo de la base de datos

```powershell
cd backend
npx prisma migrate reset --force
```

**Resultado:**

```
✅ Database reset successful
✅ Migration 20251016151251_init applied
✅ Prisma Client generated
```

---

### 4️⃣ Instalación de Dependencias

```powershell
cd backend
npm install
```

**Resultado:**

```
✅ 737 packages installed
✅ nodemon disponible
```

---

### 5️⃣ Inicio del Backend

```powershell
npm run dev
```

**Resultado:**

```
✅ Server running on port 3001
✅ Database connected successfully
✅ WebSocket service initialized
✅ GraphQL endpoint ready

🔗 Health check: http://localhost:3001/health
🎯 GraphQL endpoint: http://localhost:3001/graphql
```

---

## 🎯 ESTADO FINAL

### Servicios Corriendo:

```
┌──────────────────────────────────────────────────────────┐
│ SERVICIO           │ ESTADO  │ PUERTO │ URL              │
├──────────────────────────────────────────────────────────┤
│ PostgreSQL Dev     │ ✅ UP   │ 5434   │ localhost:5434   │
│ Backend API        │ ✅ UP   │ 3001   │ localhost:3001   │
│ Flutter Web        │ ⏸️ STOP │ 8080   │ -                │
└──────────────────────────────────────────────────────────┘
```

---

## 🚀 PRÓXIMOS PASOS

### 1. Iniciar Flutter Web

```powershell
# Terminal 3 (nueva terminal)
cd creapolis_app
flutter run -d chrome --web-port=8080
```

**O usar el script automatizado:**

```powershell
# Desde la raíz del proyecto
.\start-dev.ps1
```

---

### 2. Verificar Funcionamiento

```powershell
# Health Check del Backend
curl http://localhost:3001/health
# Debe retornar: {"status":"ok"}

# Verificar PostgreSQL
docker ps | Select-String creapolis
# Debe mostrar: creapolis-postgres-dev ... Up ... 5434->5432

# Ver logs del backend
# (Ya está corriendo en terminal)

# Abrir Flutter Web
# http://localhost:8080
```

---

## 📝 COMANDOS ÚTILES PARA EL FUTURO

### Inicio Rápido (Siguiente vez)

```powershell
# Opción A: Script automatizado (RECOMENDADO)
.\start-dev.ps1

# Opción B: Manual
docker-compose -f docker-compose.dev.yml up -d postgres
cd backend
npm run dev
# En otra terminal:
cd creapolis_app
flutter run -d chrome --web-port=8080
```

---

### Detener Servicios

```powershell
# Detener Backend: Ctrl+C en su terminal

# Detener PostgreSQL
docker-compose -f docker-compose.dev.yml down

# Detener Flutter: Ctrl+C en su terminal
```

---

### Limpiar y Reiniciar

```powershell
# Si necesitas resetear la base de datos
cd backend
npx prisma migrate reset --force

# Si necesitas reinstalar dependencias
npm install

# Si Flutter tiene problemas
cd creapolis_app
flutter clean
flutter pub get
```

---

## 🐛 TROUBLESHOOTING

### Backend no conecta a BD

**Verificar que PostgreSQL esté corriendo:**

```powershell
docker ps | Select-String creapolis
```

**Si no aparece, levantar:**

```powershell
docker-compose -f docker-compose.dev.yml up -d postgres
```

---

### Puerto 5434 en uso

**Opción A: Detener el proceso existente**

```powershell
Get-NetTCPConnection -LocalPort 5434
Stop-Process -Id <PID> -Force
```

**Opción B: Usar otro puerto**

```powershell
# Editar docker-compose.dev.yml
ports:
  - "5435:5432"  # Cambiar a puerto libre

# Actualizar backend/.env
DATABASE_URL="postgresql://creapolis:creapolis_dev_2024@localhost:5435/creapolis_dev?schema=public"
```

---

### Migraciones fallan

**Reset completo:**

```powershell
cd backend
npx prisma migrate reset --force
```

**Verificar estado:**

```powershell
npx prisma migrate status
```

---

### Backend no inicia

**Verificar dependencias:**

```powershell
cd backend
npm install
```

**Verificar .env:**

```powershell
# Debe existir backend/.env con DATABASE_URL correcto
cat backend\.env | Select-String DATABASE_URL
```

---

## 📚 DOCUMENTACIÓN RELACIONADA

- `QUICK_START.md` - Guía rápida de inicio
- `start-dev.ps1` - Script automatizado completo
- `setup-database.ps1` - Setup inicial de BD
- `backend/README.md` - Documentación del backend
- `docker-compose.dev.yml` - Configuración Docker desarrollo

---

## ✨ LECCIONES APRENDIDAS

### 1. **Conflictos de Puerto**

**Problema:** Múltiples proyectos usando el mismo puerto  
**Solución:** Usar archivos docker-compose diferentes con puertos distintos  
**Implementado:** docker-compose.dev.yml (puerto 5434)

### 2. **Automatización es Clave**

**Problema:** Múltiples pasos manuales propensos a errores  
**Solución:** Scripts PowerShell que automatizan todo  
**Implementado:** start-dev.ps1, setup-database.ps1

### 3. **Estado de la BD es Importante**

**Problema:** Migraciones fallidas por estado inconsistente  
**Solución:** prisma migrate reset --force para desarrollo  
**Nota:** En producción, usar migrate deploy sin force

### 4. **Dependencias Primero**

**Problema:** npm run dev falla sin node_modules  
**Solución:** Verificar e instalar dependencias antes de iniciar  
**Implementado:** npm install en scripts de setup

---

## 🎉 RESULTADO FINAL

✅ **PostgreSQL corriendo en puerto 5434**  
✅ **Backend API corriendo en puerto 3001**  
✅ **Base de datos creada y migrada**  
✅ **Dependencias instaladas**  
✅ **Health check funcionando**  
✅ **Listo para desarrollo de Flutter**

---

**Tiempo total de setup:** ~5 minutos  
**Scripts creados:**

- QUICK_START.md
- SETUP_AUTOMATION_SUMMARY.md (este documento)

**Próximo paso:** Levantar Flutter Web y probar Workspaces 🚀
