# Configuración del Entorno - Creapolis

> **Última actualización**: Octubre 11, 2025

## 📋 Índice

- [Inicio Rápido](#inicio-rápido)
- [Requisitos Previos](#requisitos-previos)
- [Configuración de Puertos](#configuración-de-puertos)
- [Configuración de CORS](#configuración-de-cors)
- [Base de Datos PostgreSQL](#base-de-datos-postgresql)
- [Comandos Útiles](#comandos-útiles)
- [Troubleshooting](#troubleshooting)

---

## 🚀 Inicio Rápido

### Opción 1: Script Automatizado

```powershell
.\start-dev.ps1
```

### Opción 2: Manual

```powershell
# 1. Levantar PostgreSQL
docker-compose up -d postgres

# 2. Iniciar Backend (en una terminal)
cd backend
npm start

# 3. Iniciar Flutter Web (en otra terminal, puerto 8080)
.\run-flutter.ps1
```

---

## 📦 Requisitos Previos

- Node.js 18+ y npm
- Docker Desktop
- Flutter 3.9+
- PostgreSQL (vía Docker)
- PowerShell

---

## 🔌 Configuración de Puertos

### Puertos Utilizados

| Servicio   | Puerto | Descripción        |
| ---------- | ------ | ------------------ |
| Backend    | 3000   | API REST (Node.js) |
| Frontend   | 8080   | Flutter Web (FIJO) |
| PostgreSQL | 5432   | Base de datos      |

### ✅ Puerto Fijo para Flutter (8080)

**Problema resuelto**: Flutter usaba puertos aleatorios, causando errores CORS.

**Solución**: Configurado Flutter para usar siempre puerto 8080.

**Scripts configurados**:

- `run-flutter.ps1` - Puerto 8080 fijo
- `creapolis_app/run-dev.ps1` - Puerto 8080 con auto-kill

**Código del script**:

```powershell
# run-flutter.ps1
$port = 8080

# Liberar puerto si está ocupado
$process = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
if ($process) {
    Stop-Process -Id $process.OwningProcess -Force
}

# Iniciar Flutter
cd creapolis_app
flutter run -d chrome --web-port=$port
```

---

## 🌐 Configuración de CORS

### Backend (.env)

```bash
# backend/.env
PORT=3000
NODE_ENV=development
CORS_ORIGIN=http://localhost:5173,http://localhost:8080  # ✅ Puerto 8080 incluido
DATABASE_URL="postgresql://creapolis:creapolis_password_2024@localhost:5432/creapolis_db?schema=public"
JWT_SECRET=your-secret-key-here
```

### Verificación de CORS

```powershell
# Verificar configuración
cd backend
cat .env | Select-String "CORS_ORIGIN"

# Debe incluir: http://localhost:8080
```

### Reiniciar Backend si hay cambios

```powershell
docker-compose restart backend
# O si corre localmente:
# Ctrl+C en la terminal del backend, luego npm start
```

---

## 🗄️ Base de Datos PostgreSQL

### Credenciales

```env
Host: localhost
Port: 5432
Database: creapolis_db
User: creapolis
Password: creapolis_password_2024
```

### Comandos Docker

```powershell
# Iniciar PostgreSQL
docker-compose up -d postgres

# Ver estado
docker ps | Select-String "postgres"

# Ver logs
docker logs creapolis-postgres --tail 50

# Detener
docker-compose down

# Eliminar volumen (⚠️ BORRA DATOS)
docker-compose down -v
```

### Migraciones Prisma

```powershell
cd backend

# Generar cliente Prisma
npm run prisma:generate

# Ejecutar migraciones
npm run prisma:migrate

# Ver base de datos en navegador
npm run prisma:studio
```

---

## 🛠️ Comandos Útiles

### Verificar Puertos

```powershell
# Backend (3000)
Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue

# Flutter (8080)
Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue

# PostgreSQL (5432)
Get-NetTCPConnection -LocalPort 5432 -ErrorAction SilentlyContinue
```

### Liberar Puertos

```powershell
# Liberar puerto específico (ejemplo: 8080)
Get-NetTCPConnection -LocalPort 8080 |
  ForEach-Object { Stop-Process -Id $_.OwningProcess -Force }
```

### Health Checks

```powershell
# Backend
Invoke-WebRequest http://localhost:3000/api/health

# PostgreSQL
docker exec creapolis-postgres pg_isready
```

---

## 🐛 Troubleshooting

### Error: "CORS policy"

**Síntoma**: `Access to XMLHttpRequest blocked by CORS policy`

**Solución**:

```powershell
# 1. Verificar backend .env
cd backend
cat .env | Select-String "CORS_ORIGIN"
# Debe incluir: http://localhost:8080

# 2. Reiniciar backend
docker-compose restart backend
# O Ctrl+C y npm start
```

---

### Error: "Connection refused" (puerto 3000)

**Síntoma**: `Failed to fetch` o `ECONNREFUSED`

**Solución**:

```powershell
# Iniciar backend
docker-compose up -d backend

# O sin Docker
cd backend
npm start
```

---

### Error: "Port 8080 already in use"

**Síntoma**: `Port 8080 is already in use`

**Solución**:

```powershell
# Opción 1: Usar script que maneja esto
.\creapolis_app\run-dev.ps1

# Opción 2: Liberar puerto manualmente
Get-NetTCPConnection -LocalPort 8080 |
  ForEach-Object { Stop-Process -Id $_.OwningProcess -Force }
```

---

### Error: "Database connection failed"

**Síntoma**: `Can't reach database server`

**Solución**:

```powershell
# 1. Iniciar PostgreSQL
docker-compose up -d postgres

# 2. Esperar 5-10 segundos
Start-Sleep -Seconds 5

# 3. Verificar
docker ps | Select-String "postgres"

# 4. Iniciar backend
cd backend
npm start
```

---

### Error: "Module not found" en Backend

**Síntoma**: `Cannot find module` o `MODULE_NOT_FOUND`

**Solución**:

```powershell
cd backend
npm install
npm run prisma:generate
npm start
```

---

### Error: Flutter no compila

**Síntoma**: Errores de compilación en Flutter

**Solución**:

```powershell
cd creapolis_app
flutter clean
flutter pub get
flutter run -d chrome --web-port=8080
```

---

## 📊 Estado de Servicios

### Verificación Completa

```powershell
# PostgreSQL
docker ps --filter "name=postgres" --format "table {{.Names}}\t{{.Status}}"

# Backend
curl http://localhost:3000/api/health

# Flutter (abrir en navegador)
# http://localhost:8080
```

### Logs en Tiempo Real

```powershell
# PostgreSQL
docker logs -f creapolis-postgres

# Backend
# (ver en la terminal donde corre npm start)

# Flutter
# (ver en la terminal donde corre flutter run)
```

---

## 🔐 Credenciales de Prueba

### Usuario de Prueba

```json
{
  "email": "tiagofur@gmail.com",
  "password": "Davidi81"
}
```

### Test de Login

```powershell
$body = @{
    email = "tiagofur@gmail.com"
    password = "Davidi81"
} | ConvertTo-Json

Invoke-WebRequest -Uri http://localhost:3000/api/auth/login `
  -Method POST `
  -ContentType "application/json" `
  -Body $body
```

---

## 📚 Referencias

- [CORS_CONFIG.md](../history/CORS_CONFIG.md) - Histórico de configuración CORS
- [ESTADO_ENTORNO.md](../history/ESTADO_ENTORNO.md) - Estado histórico del entorno
- [Docker Documentation](https://docs.docker.com/)
- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)
- [Prisma Documentation](https://www.prisma.io/docs/)

---

**Última actualización**: Octubre 11, 2025  
**Mantenedor**: Equipo Creapolis
