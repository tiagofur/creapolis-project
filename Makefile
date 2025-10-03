# 🐳 Makefile para Creapolis Docker
# Simplifica comandos comunes de Docker Compose

.PHONY: help build up down restart logs clean dev prod ps db-backup db-restore

# Variables
COMPOSE_FILE = docker-compose.yml
COMPOSE_DEV_FILE = docker-compose.dev.yml
PROJECT_NAME = creapolis

# Color output
BLUE = \033[0;34m
GREEN = \033[0;32m
YELLOW = \033[0;33m
RED = \033[0;31m
NC = \033[0m # No Color

##@ General

help: ## Mostrar esta ayuda
	@echo "$(BLUE)Creapolis Docker Commands$(NC)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make $(GREEN)<target>$(NC)\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(YELLOW)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development

dev: ## Iniciar en modo desarrollo (hot-reload)
	@echo "$(BLUE)Starting development environment...$(NC)"
	docker-compose -f $(COMPOSE_DEV_FILE) up -d
	@echo "$(GREEN)✓ Development environment started$(NC)"
	@echo "Backend: http://localhost:3001"
	@echo "PgAdmin: http://localhost:5051"

dev-logs: ## Ver logs de desarrollo
	docker-compose -f $(COMPOSE_DEV_FILE) logs -f

dev-down: ## Detener entorno de desarrollo
	@echo "$(YELLOW)Stopping development environment...$(NC)"
	docker-compose -f $(COMPOSE_DEV_FILE) down
	@echo "$(GREEN)✓ Development environment stopped$(NC)"

dev-rebuild: ## Reconstruir imagen de desarrollo
	@echo "$(BLUE)Rebuilding development image...$(NC)"
	docker-compose -f $(COMPOSE_DEV_FILE) build --no-cache backend
	docker-compose -f $(COMPOSE_DEV_FILE) up -d
	@echo "$(GREEN)✓ Development rebuilt$(NC)"

##@ Production

prod: up ## Iniciar en modo producción (alias de 'up')

up: ## Iniciar servicios en producción
	@echo "$(BLUE)Starting production environment...$(NC)"
	docker-compose up -d
	@echo "$(GREEN)✓ Production environment started$(NC)"
	@echo "Backend: http://localhost:3000"
	@echo "PgAdmin: http://localhost:5050 (use --profile tools)"

build: ## Construir imágenes de producción
	@echo "$(BLUE)Building production images...$(NC)"
	docker-compose build
	@echo "$(GREEN)✓ Images built$(NC)"

rebuild: ## Reconstruir imágenes sin caché
	@echo "$(BLUE)Rebuilding images without cache...$(NC)"
	docker-compose build --no-cache
	docker-compose up -d
	@echo "$(GREEN)✓ Images rebuilt$(NC)"

down: ## Detener servicios de producción
	@echo "$(YELLOW)Stopping production services...$(NC)"
	docker-compose down
	@echo "$(GREEN)✓ Services stopped$(NC)"

restart: ## Reiniciar servicios de producción
	@echo "$(BLUE)Restarting services...$(NC)"
	docker-compose restart
	@echo "$(GREEN)✓ Services restarted$(NC)"

##@ Monitoring

logs: ## Ver logs de producción (todos los servicios)
	docker-compose logs -f

logs-backend: ## Ver solo logs del backend
	docker-compose logs -f backend

logs-postgres: ## Ver solo logs de PostgreSQL
	docker-compose logs -f postgres

ps: ## Ver estado de los contenedores
	@echo "$(BLUE)Container status:$(NC)"
	@docker-compose ps

stats: ## Ver estadísticas de recursos
	docker stats

##@ Database

db-shell: ## Conectar a PostgreSQL shell
	docker-compose exec postgres psql -U creapolis -d creapolis_db

db-backup: ## Crear backup de la base de datos
	@echo "$(BLUE)Creating database backup...$(NC)"
	@mkdir -p backups
	docker-compose exec postgres pg_dump -U creapolis creapolis_db > backups/backup-$(shell date +%Y%m%d-%H%M%S).sql
	@echo "$(GREEN)✓ Backup created in backups/$(NC)"

db-restore: ## Restaurar backup (uso: make db-restore FILE=backup.sql)
	@if [ -z "$(FILE)" ]; then echo "$(RED)Error: FILE parameter required. Usage: make db-restore FILE=backup.sql$(NC)"; exit 1; fi
	@echo "$(YELLOW)Restoring database from $(FILE)...$(NC)"
	cat $(FILE) | docker-compose exec -T postgres psql -U creapolis -d creapolis_db
	@echo "$(GREEN)✓ Database restored$(NC)"

migrate: ## Ejecutar migraciones de Prisma
	@echo "$(BLUE)Running migrations...$(NC)"
	docker-compose exec backend npx prisma migrate deploy
	@echo "$(GREEN)✓ Migrations completed$(NC)"

migrate-status: ## Ver estado de migraciones
	docker-compose exec backend npx prisma migrate status

prisma-studio: ## Abrir Prisma Studio
	@echo "$(BLUE)Opening Prisma Studio...$(NC)"
	docker-compose exec backend npx prisma studio
	@echo "Visit: http://localhost:5555"

prisma-generate: ## Regenerar Prisma Client
	docker-compose exec backend npx prisma generate

##@ Maintenance

clean: ## Limpiar contenedores y volúmenes (⚠️  BORRA DATOS)
	@echo "$(RED)WARNING: This will delete all data!$(NC)"
	@echo "Press Ctrl+C to cancel, or wait 5 seconds..."
	@sleep 5
	docker-compose down -v
	@echo "$(GREEN)✓ Cleaned$(NC)"

prune: ## Limpiar sistema Docker completo
	@echo "$(YELLOW)Cleaning Docker system...$(NC)"
	docker system prune -a --volumes
	@echo "$(GREEN)✓ Docker system cleaned$(NC)"

reset: clean up ## Reset completo (down + clean + up)
	@echo "$(GREEN)✓ System reset complete$(NC)"

##@ Testing

test: ## Ejecutar tests en el backend
	docker-compose exec backend npm test

test-coverage: ## Ejecutar tests con coverage
	docker-compose exec backend npm run test:coverage

##@ Utils

shell: ## Acceder a shell del backend
	docker-compose exec backend sh

install: ## Instalar nueva dependencia (uso: make install PKG=package-name)
	@if [ -z "$(PKG)" ]; then echo "$(RED)Error: PKG parameter required. Usage: make install PKG=package-name$(NC)"; exit 1; fi
	docker-compose exec backend npm install $(PKG)
	@echo "$(GREEN)✓ Package $(PKG) installed$(NC)"

pgadmin: ## Iniciar con PgAdmin
	docker-compose --profile tools up -d
	@echo "$(GREEN)✓ PgAdmin available at http://localhost:5050$(NC)"

health: ## Verificar health del backend
	@curl -s http://localhost:3000/api/health | jq . || echo "$(RED)Backend not responding$(NC)"

env-template: ## Copiar .env.docker a .env
	@if [ -f .env ]; then echo "$(YELLOW)Warning: .env already exists$(NC)"; else cp .env.docker .env && echo "$(GREEN)✓ .env created from template$(NC)"; fi
