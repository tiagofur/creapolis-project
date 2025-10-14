# 🚀 Quick Start - Creapolis Docker

## Setup Rápido (Windows PowerShell)

```powershell
# 1. Copiar archivo de configuración
Copy-Item .env.docker .env

# 2. Editar variables (opcional)
notepad .env

# 3. Iniciar servicios
docker-compose up -d

# 4. Ver logs
docker-compose logs -f

# 5. Verificar estado
docker-compose ps

# 6. Health check
curl http://localhost:3000/api/health
```

## Setup Rápido (Linux/Mac)

```bash
# 1. Copiar archivo de configuración
cp .env.docker .env

# 2. Editar variables (opcional)
nano .env

# 3. Iniciar servicios
docker-compose up -d

# 4. Ver logs
docker-compose logs -f

# 5. Verificar estado
docker-compose ps

# 6. Health check
curl http://localhost:3000/api/health
```

## Comandos Útiles

### Producción

```bash
docker-compose up -d              # Iniciar
docker-compose down               # Detener
docker-compose logs -f backend    # Ver logs
docker-compose restart backend    # Reiniciar
```

### Desarrollo

```bash
docker-compose -f docker-compose.dev.yml up -d    # Iniciar dev
docker-compose -f docker-compose.dev.yml logs -f  # Ver logs dev
```

### Base de Datos

```bash
# Conectar a PostgreSQL
docker-compose exec postgres psql -U creapolis -d creapolis_db

# Backup
docker-compose exec postgres pg_dump -U creapolis creapolis_db > backup.sql

# Restore
cat backup.sql | docker-compose exec -T postgres psql -U creapolis -d creapolis_db

# Migraciones
docker-compose exec backend npx prisma migrate deploy
```

## Acceso a Servicios

- **Backend API**: http://localhost:3000
- **Health Check**: http://localhost:3000/api/health
- **PostgreSQL**: localhost:5432
- **PgAdmin**: http://localhost:5050 (requiere `--profile tools`)
  - Email: admin@creapolis.com
  - Password: admin

## Desarrollo

```bash
# Modo desarrollo (hot-reload)
docker-compose -f docker-compose.dev.yml up -d

# Acceso:
# - Backend: http://localhost:3001
# - PgAdmin: http://localhost:5051
```

## Troubleshooting

### Puerto en uso

```bash
# Ver qué usa el puerto
netstat -ano | findstr :3000  # Windows
lsof -i :3000                 # Linux/Mac

# Cambiar puerto en .env
BACKEND_PORT=3001
```

### Reiniciar desde cero

```bash
docker-compose down -v        # ⚠️ BORRA DATOS
docker-compose up -d
```

### Ver errores

```bash
docker-compose logs backend
docker-compose logs postgres
```

## Documentación Completa

Ver [DOCKER_README.md](./DOCKER_README.md) para documentación detallada.

---

**Última actualización**: 3 de octubre de 2025
