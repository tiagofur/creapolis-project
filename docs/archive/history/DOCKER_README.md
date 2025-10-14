# 🐳 Guía de Docker - Creapolis Backend

Documentación completa para ejecutar el backend de Creapolis con Docker y Docker Compose.

## 📋 Tabla de Contenidos

- [Prerequisitos](#prerequisitos)
- [Configuración Rápida](#configuración-rápida)
- [Modo Producción](#modo-producción)
- [Modo Desarrollo](#modo-desarrollo)
- [Comandos Útiles](#comandos-útiles)
- [Troubleshooting](#troubleshooting)
- [Arquitectura](#arquitectura)

---

## 📦 Prerequisitos

- **Docker**: v24.0+ ([Descargar](https://www.docker.com/products/docker-desktop))
- **Docker Compose**: v2.20+ (incluido con Docker Desktop)
- **Git**: Para clonar el repositorio

Verificar instalación:

```bash
docker --version
docker-compose --version
```

---

## 🚀 Configuración Rápida

### 1. Clonar y Configurar

```bash
# Clonar repositorio
git clone https://github.com/tiagofur/creapolis-project.git
cd creapolis-project

# Copiar archivo de configuración
cp .env.docker .env

# Editar variables de entorno (opcional)
notepad .env  # Windows
nano .env     # Linux/Mac
```

### 2. Iniciar Servicios

```bash
# Construir y levantar servicios
docker-compose up -d

# Ver logs
docker-compose logs -f backend

# Verificar estado
docker-compose ps
```

### 3. Verificar Funcionamiento

```bash
# Healthcheck del backend
curl http://localhost:3000/api/health

# Debería retornar: {"status":"ok","timestamp":"..."}
```

### 4. Crear Usuario de Prueba

```bash
# POST a /api/auth/register
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@creapolis.com",
    "password": "Admin123!",
    "name": "Admin User",
    "role": "ADMIN"
  }'
```

---

## 🏭 Modo Producción

### Archivo: `docker-compose.yml`

```bash
# Iniciar servicios
docker-compose up -d

# Ver logs
docker-compose logs -f

# Detener servicios
docker-compose down

# Detener y eliminar volúmenes (⚠️ BORRA DATOS)
docker-compose down -v
```

### Servicios Incluidos

1. **PostgreSQL** (puerto 5432)

   - Base de datos principal
   - Persistencia con volúmenes Docker
   - Healthcheck integrado

2. **Backend API** (puerto 3000)

   - Node.js + Express + Prisma
   - Ejecuta migraciones automáticamente
   - Healthcheck en `/api/health`

3. **PgAdmin** (puerto 5050) - Opcional
   ```bash
   # Iniciar con PgAdmin
   docker-compose --profile tools up -d
   ```
   - URL: http://localhost:5050
   - Email: admin@creapolis.com
   - Password: admin

### Variables de Entorno Importantes

```env
# .env
POSTGRES_PASSWORD=cambiar-en-produccion
JWT_SECRET=generar-con-openssl-rand-base64-32
NODE_ENV=production
```

---

## 🛠️ Modo Desarrollo

### Archivo: `docker-compose.dev.yml`

Características:

- ✅ Hot-reload automático (nodemon)
- ✅ Código fuente montado como volumen
- ✅ Puerto diferente (3001) para no conflictuar
- ✅ Base de datos separada

```bash
# Iniciar en modo desarrollo
docker-compose -f docker-compose.dev.yml up -d

# Ver logs con seguimiento
docker-compose -f docker-compose.dev.yml logs -f backend

# Detener
docker-compose -f docker-compose.dev.yml down
```

### Cambios en Código

Los cambios en `backend/src/` se reflejan automáticamente:

```bash
# Editar archivo
notepad backend/src/server.js

# Ver logs para confirmar recarga
docker-compose -f docker-compose.dev.yml logs -f backend
# Output: [nodemon] restarting due to changes...
```

---

## 🔧 Comandos Útiles

### Gestión de Contenedores

```bash
# Ver todos los contenedores
docker ps -a

# Ver logs de un servicio específico
docker-compose logs backend
docker-compose logs postgres

# Logs en tiempo real
docker-compose logs -f

# Reiniciar un servicio
docker-compose restart backend

# Acceder a shell del backend
docker-compose exec backend sh

# Acceder a PostgreSQL
docker-compose exec postgres psql -U creapolis -d creapolis_db
```

### Gestión de Base de Datos

```bash
# Ejecutar migraciones manualmente
docker-compose exec backend npx prisma migrate deploy

# Ver estado de migraciones
docker-compose exec backend npx prisma migrate status

# Abrir Prisma Studio
docker-compose exec backend npx prisma studio
# Acceder en: http://localhost:5555

# Generar Prisma Client
docker-compose exec backend npx prisma generate

# Seed de datos (si existe)
docker-compose exec backend npx prisma db seed
```

### Backup y Restore

```bash
# Backup de base de datos
docker-compose exec postgres pg_dump -U creapolis creapolis_db > backup.sql

# Restore de base de datos
cat backup.sql | docker-compose exec -T postgres psql -U creapolis -d creapolis_db

# Backup con timestamp
docker-compose exec postgres pg_dump -U creapolis creapolis_db > "backup-$(date +%Y%m%d-%H%M%S).sql"
```

### Limpieza

```bash
# Detener y eliminar contenedores
docker-compose down

# Eliminar volúmenes (⚠️ BORRA DATOS)
docker-compose down -v

# Eliminar imágenes huérfanas
docker image prune

# Limpieza completa del sistema Docker
docker system prune -a --volumes
```

### Reconstruir Imágenes

```bash
# Reconstruir backend después de cambios en Dockerfile
docker-compose build backend

# Reconstruir sin caché
docker-compose build --no-cache backend

# Reconstruir y reiniciar
docker-compose up -d --build backend
```

---

## 🐛 Troubleshooting

### Puerto ya en uso

```bash
# Error: bind: address already in use
# Solución 1: Cambiar puerto en .env
BACKEND_PORT=3001

# Solución 2: Detener servicio que usa el puerto
# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Linux/Mac
lsof -ti:3000 | xargs kill -9
```

### Base de datos no se conecta

```bash
# Verificar healthcheck
docker-compose ps

# Ver logs de PostgreSQL
docker-compose logs postgres

# Reiniciar PostgreSQL
docker-compose restart postgres

# Verificar conexión manual
docker-compose exec postgres psql -U creapolis -d creapolis_db
```

### Migraciones fallan

```bash
# Ver error específico
docker-compose logs backend

# Reintentar migraciones
docker-compose exec backend npx prisma migrate deploy

# Reset completo (⚠️ BORRA DATOS)
docker-compose down -v
docker-compose up -d
```

### Backend no inicia

```bash
# Ver logs detallados
docker-compose logs -f backend

# Verificar variables de entorno
docker-compose exec backend env | grep DATABASE_URL

# Reconstruir imagen
docker-compose down
docker-compose build --no-cache backend
docker-compose up -d
```

### Prisma Client desactualizado

```bash
# Regenerar Prisma Client
docker-compose exec backend npx prisma generate

# Reiniciar backend
docker-compose restart backend
```

---

## 🏗️ Arquitectura

### Estructura de Archivos

```
creapolis-project/
├── docker-compose.yml          # Configuración producción
├── docker-compose.dev.yml      # Configuración desarrollo
├── .env.docker                 # Template de variables
├── .env                        # Variables actuales (no commitear)
├── DOCKER_README.md           # Esta documentación
└── backend/
    ├── Dockerfile              # Imagen producción
    ├── Dockerfile.dev          # Imagen desarrollo
    ├── .dockerignore          # Archivos ignorados
    ├── package.json
    ├── prisma/
    │   └── schema.prisma
    └── src/
        └── server.js
```

### Network

Todos los servicios comparten la red `creapolis-network`:

```
┌─────────────────────────────────────────┐
│       creapolis-network (bridge)        │
│                                         │
│  ┌──────────┐  ┌──────────┐  ┌───────┐│
│  │PostgreSQL│◄─┤ Backend  │◄─┤PgAdmin││
│  │  :5432   │  │  :3000   │  │ :5050 ││
│  └──────────┘  └──────────┘  └───────┘│
│       ▲             ▲            ▲     │
└───────┼─────────────┼────────────┼─────┘
        │             │            │
   localhost:5432  localhost:3000  localhost:5050
```

### Volúmenes Persistentes

```bash
# Listar volúmenes
docker volume ls | grep creapolis

# Volúmenes creados:
creapolis-postgres-data    # Datos de PostgreSQL
creapolis-pgadmin-data     # Configuración de PgAdmin
creapolis-backend-logs     # Logs del backend

# Inspeccionar volumen
docker volume inspect creapolis-postgres-data
```

---

## 🔐 Seguridad

### Producción Checklist

- [ ] Cambiar `POSTGRES_PASSWORD` en `.env`
- [ ] Generar `JWT_SECRET` seguro: `openssl rand -base64 32`
- [ ] Cambiar `PGADMIN_PASSWORD`
- [ ] Configurar `CORS_ORIGIN` específico
- [ ] No exponer puertos innecesarios
- [ ] Usar volúmenes encriptados para datos sensibles
- [ ] Habilitar HTTPS con reverse proxy (nginx/traefik)
- [ ] Implementar rate limiting
- [ ] Backups automatizados de base de datos

### Generar Secretos Seguros

```bash
# JWT Secret
openssl rand -base64 32

# PostgreSQL Password
openssl rand -base64 24

# O usar Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```

---

## 📚 Recursos Adicionales

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Prisma Docker Guide](https://www.prisma.io/docs/guides/deployment/deployment-guides/deploying-to-docker)
- [PostgreSQL Docker Hub](https://hub.docker.com/_/postgres)

---

## 🆘 Soporte

Si encuentras problemas:

1. Revisa esta documentación
2. Verifica logs: `docker-compose logs -f`
3. Consulta issues en GitHub
4. Contacta al equipo de desarrollo

---

**Última actualización**: 3 de octubre de 2025  
**Versión Docker**: 24.0+  
**Versión Docker Compose**: 2.20+
