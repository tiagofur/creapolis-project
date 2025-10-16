# 🚀 QUICK START - Creapolis

**Guía rápida para levantar el entorno de desarrollo completo**

---

## ⚡ OPCIÓN 1: Todo Automatizado (RECOMENDADO)

### Primer Uso (Setup inicial)

```powershell
# 1. Desde la raíz del proyecto:
.\setup-database.ps1
```

Este script:

- ✅ Levanta PostgreSQL en Docker
- ✅ Espera a que esté listo
- ✅ Aplica migraciones de Prisma
- ✅ Genera cliente de Prisma
- ✅ Verifica dependencias

### Días Siguientes (Inicio rápido)

```powershell
# Opción A: Todo junto (BD + Backend + Flutter Web)
.\start-dev.ps1

# Opción B: Solo levantar servicios individuales
# Ver más abajo "OPCIÓN 2"
```

---

## 📋 OPCIÓN 2: Manual (Control Individual)

### 1️⃣ Levantar PostgreSQL

```powershell
# Opción A: Con docker-compose (producción)
docker-compose up -d postgres

# Opción B: Con docker-compose.dev.yml (desarrollo)
docker-compose -f docker-compose.dev.yml up -d postgres

# Verificar que esté corriendo:
docker ps | Select-String postgres
```

**Credenciales (según .env):**

- Host: `localhost`
- Puerto: `5432` (producción) o `5434` (dev)
- Usuario: `creapolis`
- Password: `creapolis_password_2024`
- Database: `creapolis_db`

### 2️⃣ Backend

```powershell
cd backend

# Primera vez: instalar dependencias
npm install

# Aplicar migraciones (si es necesario)
npx prisma migrate deploy

# Iniciar backend
npm run dev
# O para producción:
# npm start
```

**Backend corriendo en:** `http://localhost:3001`

### 3️⃣ Flutter App

```powershell
cd creapolis_app

# Primera vez: obtener dependencias
flutter pub get

# Iniciar en Chrome (puerto 8080 - configurado en CORS)
flutter run -d chrome --web-port=8080

# O usar el script:
.\run-dev.ps1
```

**Flutter corriendo en:** `http://localhost:8080`

---

## 🐛 SOLUCIÓN A ERRORES COMUNES

### ❌ Error: "Database connection failed: Authentication failed"

**Causa:** PostgreSQL no está corriendo o credenciales incorrectas

**Solución:**

```powershell
# 1. Verificar si PostgreSQL está corriendo
docker ps

# 2. Si NO aparece, levantarlo:
docker-compose up -d postgres

# 3. Esperar 10-15 segundos para que inicie completamente

# 4. Verificar logs si hay problemas:
docker logs creapolis-postgres

# 5. Reintentar backend:
cd backend
npm run dev
```

---

### ❌ Error: "Port 5432 already in use"

**Causa:** Ya hay un PostgreSQL corriendo en ese puerto

**Solución A (Usar el que ya está):**

```powershell
# Verificar si el PostgreSQL existente tiene la base de datos creapolis_db
# Puedes conectarte con pgAdmin o usar psql
# Si tiene la BD, solo necesitas:
cd backend
npx prisma migrate deploy
npm run dev
```

**Solución B (Cambiar puerto):**

```powershell
# Editar docker-compose.yml, cambiar:
ports:
  - "5433:5432"  # O cualquier otro puerto libre

# Editar backend/.env, cambiar:
DATABASE_URL="postgresql://creapolis:creapolis_password_2024@localhost:5433/creapolis_db?schema=public"

# Reiniciar:
docker-compose down
docker-compose up -d postgres
```

---

### ❌ Error: "Cannot find module 'prisma'"

**Causa:** Dependencias no instaladas o cliente Prisma no generado

**Solución:**

```powershell
cd backend
npm install
npx prisma generate
```

---

### ❌ Error: "Port 3001 already in use"

**Causa:** Backend ya está corriendo o hay otro proceso en ese puerto

**Solución:**

```powershell
# Encontrar proceso:
Get-NetTCPConnection -LocalPort 3001 | Select-Object OwningProcess
Get-Process -Id <PID>

# Detener proceso:
Stop-Process -Id <PID> -Force
```

---

### ❌ Error: "Port 8080 already in use"

**Causa:** Flutter ya está corriendo o hay otro proceso

**Solución:**

```powershell
# El script start-dev.ps1 te preguntará si quieres detenerlo

# O manualmente:
Get-NetTCPConnection -LocalPort 8080 | Select-Object OwningProcess
Stop-Process -Id <PID> -Force
```

---

## 📊 VERIFICACIÓN DEL ENTORNO

### Verificar que todo está corriendo:

```powershell
# PostgreSQL
docker ps | Select-String postgres
# Debe mostrar: creapolis-postgres ... Up ... 0.0.0.0:5432->5432/tcp

# Backend
curl http://localhost:3001/api/health
# Debe retornar: {"status":"ok","timestamp":"..."}

# Flutter
# Abrir navegador: http://localhost:8080
```

---

## 🔧 COMANDOS ÚTILES

### Docker

```powershell
# Ver contenedores corriendo
docker ps

# Ver todos los contenedores (incluso detenidos)
docker ps -a

# Ver logs de PostgreSQL
docker logs creapolis-postgres -f

# Detener PostgreSQL
docker-compose down

# Eliminar volúmenes (CUIDADO: borra datos)
docker-compose down -v

# Reiniciar PostgreSQL
docker-compose restart postgres
```

### Prisma

```powershell
cd backend

# Ver estado de migraciones
npx prisma migrate status

# Aplicar migraciones pendientes
npx prisma migrate deploy

# Crear nueva migración (desarrollo)
npx prisma migrate dev --name nombre_de_migracion

# Regenerar cliente
npx prisma generate

# Abrir Prisma Studio (GUI para ver datos)
npx prisma studio
```

### Backend

```powershell
cd backend

# Desarrollo (con hot reload)
npm run dev

# Producción
npm start

# Ver logs en tiempo real
npm run dev | Tee-Object -FilePath logs/backend.log
```

### Flutter

```powershell
cd creapolis_app

# Limpiar build
flutter clean

# Obtener dependencias
flutter pub get

# Generar código (injectable, etc)
flutter pub run build_runner build --delete-conflicting-outputs

# Ver dispositivos disponibles
flutter devices

# Correr en Chrome
flutter run -d chrome --web-port=8080

# Build de producción
flutter build web
```

---

## 🎯 RESUMEN WORKFLOW DIARIO

### Primera vez del día:

```powershell
# Terminal 1: Base de datos
docker-compose up -d postgres

# Terminal 2: Backend
cd backend
npm run dev

# Terminal 3: Flutter
cd creapolis_app
flutter run -d chrome --web-port=8080
```

### O simplemente:

```powershell
.\start-dev.ps1
```

---

## 📱 PUERTOS USADOS

| Servicio      | Puerto | URL                       |
| ------------- | ------ | ------------------------- |
| PostgreSQL    | 5432   | localhost:5432            |
| Backend API   | 3001   | http://localhost:3001/api |
| Flutter Web   | 8080   | http://localhost:8080     |
| PgAdmin (opt) | 5050   | http://localhost:5050     |
| Prisma Studio | 5555   | http://localhost:5555     |

---

## 🆘 AYUDA ADICIONAL

### Documentación relacionada:

- `README.md` - Información general del proyecto
- `backend/README.md` - Documentación del backend
- `creapolis_app/README.md` - Documentación de Flutter
- `DOCUMENTATION_MIGRATION_GUIDE.md` - Guía de migraciones

### Scripts disponibles:

- `start-dev.ps1` - Inicia todo el entorno automáticamente
- `setup-database.ps1` - Setup inicial de base de datos
- `run-flutter.ps1` - Inicia solo Flutter
- `docker.ps1` - Comandos Docker útiles

---

## 🎉 TODO LISTO

Una vez que todo esté corriendo:

1. ✅ PostgreSQL: `docker ps` muestra `creapolis-postgres`
2. ✅ Backend: `http://localhost:3001/api/health` retorna OK
3. ✅ Flutter: `http://localhost:8080` muestra la app

**¡A desarrollar!** 🚀
