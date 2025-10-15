# 🔧 Guía de Configuración de Base de Datos para Nuevas Instalaciones

## 📋 Problema Común

Cuando se instala Creapolis en una computadora nueva, es común encontrar el error:

```
The table `public.User` does not exist in the current database.
```

Este error ocurre porque las tablas de la base de datos no existen aún.

## ✅ Solución Paso a Paso

### 1. 🗄️ Iniciar PostgreSQL

```bash
# Usando Docker Compose
docker-compose -f docker-compose.dev.yml up postgres -d
```

### 2. 🔧 Configurar Variables de Entorno

Asegúrate de que el archivo `backend/.env` tenga la configuración correcta:

```bash
# Database Configuration
DATABASE_URL="postgresql://creapolis:creapolis_dev_2024@localhost:5434/creapolis_dev?schema=public"

# Server Configuration
PORT=3001
NODE_ENV=development
```

### 3. 📦 Instalar Dependencias

```bash
cd backend
npm install
```

### 4. 🏗️ Crear las Tablas de Base de Datos

```bash
# Crear migración inicial (solo la primera vez)
npx prisma migrate dev --name init

# O aplicar migraciones existentes
npx prisma migrate deploy

# Generar cliente de Prisma
npx prisma generate
```

### 5. 🚀 Iniciar el Backend

```bash
npm run dev
```

## 📝 Script de Setup Automático

Para facilitar el proceso, puedes usar este script en PowerShell:

```powershell
# setup-database.ps1
Write-Host "🔧 Configurando base de datos de Creapolis..." -ForegroundColor Green

# 1. Iniciar PostgreSQL
Write-Host "📦 Iniciando PostgreSQL..." -ForegroundColor Yellow
docker-compose -f docker-compose.dev.yml up postgres -d

# 2. Esperar a que PostgreSQL esté listo
Write-Host "⏳ Esperando a que PostgreSQL esté listo..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# 3. Navegar al directorio backend
Set-Location backend

# 4. Aplicar migraciones
Write-Host "🏗️ Aplicando migraciones de base de datos..." -ForegroundColor Yellow
npx prisma migrate deploy

# 5. Generar cliente Prisma
Write-Host "🔄 Generando cliente de Prisma..." -ForegroundColor Yellow
try {
    npx prisma generate
} catch {
    Write-Host "⚠️ Error generando cliente, pero las migraciones están aplicadas" -ForegroundColor Orange
}

# 6. Iniciar backend
Write-Host "🚀 Iniciando backend..." -ForegroundColor Green
npm run dev
```

## 🐛 Problemas Comunes y Soluciones

### Error: "EPERM: operation not permitted"

Este es un error común en Windows al generar el cliente de Prisma:

- **Solución**: Cierra VS Code y cualquier proceso de Node.js, luego vuelve a intentar
- **Alternativa**: Reinicia el backend, funciona aunque salga este error

### Error: "Can't reach database server"

- **Verificar**: Que PostgreSQL esté corriendo en el puerto correcto
- **Comando**: `docker ps | findstr postgres`
- **Puerto esperado**: 5434

### Error: "No migration found"

- **Solución**: Ejecuta `npx prisma migrate dev --name init`
- **Significa**: Es la primera instalación, necesitas crear las tablas

## 📊 Verificación Final

Para verificar que todo funciona:

```bash
# 1. Verificar PostgreSQL
docker ps | findstr postgres

# 2. Verificar tablas
npx prisma migrate status

# 3. Verificar backend
curl http://localhost:3001/api/health
```

## 🔄 Reset Completo (si es necesario)

Si necesitas empezar desde cero:

```bash
# 1. Parar servicios
docker-compose -f docker-compose.dev.yml down

# 2. Eliminar volúmenes (CUIDADO: borra todos los datos)
docker volume rm creapolis-postgres-dev-data

# 3. Seguir la guía desde el paso 1
```

## 📁 Estructura de Archivos Importantes

```
backend/
├── prisma/
│   ├── schema.prisma          # Esquema de base de datos
│   ├── migrations/            # Archivos de migración
│   │   └── [timestamp]_init/
│   │       └── migration.sql
│   └── migration_lock.toml    # Lock de migraciones
├── .env                       # Variables de entorno
└── package.json               # Dependencias
```

## 🎯 Checklist para Nueva Instalación

- [ ] PostgreSQL corriendo en puerto 5434
- [ ] Variables de entorno configuradas en `.env`
- [ ] Dependencias instaladas (`npm install`)
- [ ] Migraciones aplicadas (`npx prisma migrate deploy`)
- [ ] Cliente generado (`npx prisma generate`)
- [ ] Backend iniciado (`npm run dev`)
- [ ] Frontend funcionando en puerto 8080

---

**📅 Creado**: Octubre 10, 2025  
**🔄 Última actualización**: Octubre 10, 2025  
**📝 Versión**: 1.0
