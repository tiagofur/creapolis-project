# 🚀 Creapolis - Sistema de Gestión de Proyectos Inteligente

> Sistema de gestión de proyectos colaborativo con planificación adaptativa y sincronización con Google Calendar

> **📚 Documentation Reorganized!** All documentation has been moved to the [`docs/`](./docs/) folder with a comprehensive, world-class structure. See [Documentation Migration Guide](./DOCUMENTATION_MIGRATION_GUIDE.md) for details.

## 🎯 Estado del Proyecto - Noviembre 2025

### ✅ Prioridad 1 & 2 - 100% Completado
- ✅ **P1**: Auth, Proyectos, Tareas, GraphQL, Real-time, Notificaciones, Búsqueda, Analytics
- ✅ **P2**: Kanban Mejorado, Offline Mode, Time Tracking Avanzado, Mobile UX Optimizado

### 📋 Próximas Prioridades
- **P3**: Docs/Wiki, Billing/Subscriptions, VS Code Extension, Email-to-Task
- **P4**: Gamification, Templates Avanzados, Workflows, Reportes Ejecutivos

**Última Actualización**: 25 de Noviembre 2025  
**Ver Estado Completo**: [MASTER_STATUS.md](docs/MASTER_STATUS.md) | [Última Sesión](docs/SESSION_25_NOV_2025.md)

---

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Node.js](https://img.shields.io/badge/node-%3E%3D20.0-brightgreen.svg)](https://nodejs.org)
[![Flutter](https://img.shields.io/badge/flutter-3.27%2B-blue.svg)](https://flutter.dev)
[![Docker](https://img.shields.io/badge/docker-ready-blue.svg)](https://www.docker.com)
[![PostgreSQL](https://img.shields.io/badge/postgres-16-blue.svg)](https://www.postgresql.org)

### CI/CD Status

[![Backend CI](https://github.com/tiagofur/creapolis-project/workflows/Backend%20CI/badge.svg)](https://github.com/tiagofur/creapolis-project/actions/workflows/backend-ci.yml)
[![Flutter CI](https://github.com/tiagofur/creapolis-project/workflows/Flutter%20CI/badge.svg)](https://github.com/tiagofur/creapolis-project/actions/workflows/flutter-ci.yml)
[![Android Build](https://github.com/tiagofur/creapolis-project/workflows/Android%20Build/badge.svg)](https://github.com/tiagofur/creapolis-project/actions/workflows/android-build.yml)
[![iOS Build](https://github.com/tiagofur/creapolis-project/workflows/iOS%20Build/badge.svg)](https://github.com/tiagofur/creapolis-project/actions/workflows/ios-build.yml)

## 📋 Tabla de Contenidos

- [Características](#-características-principales)
- [Quick Start](#-quick-start-con-docker)
- [Documentación](#-documentación)
- [Arquitectura](#-arquitectura)
- [Contribuir](#-contribuir)

---

## ✨ Características Principales

### 🎯 Gestión Inteligente de Proyectos

- **Planificación Automática**: Motor de scheduling con algoritmos topológicos
- **Replanificación Adaptativa**: Ajuste automático ante cambios
- **Dependencias Avanzadas**: Soporte para FINISH_TO_START y START_TO_START
- **Tareas Ancladas**: Fija fechas inamovibles

### 📅 Integración con Google Calendar

- **OAuth 2.0**: Conexión segura con calendarios
- **Sincronización Bidireccional**: Lee disponibilidad real del equipo
- **Detección de Conflictos**: Alerta automática de sobrecargas

### ⏱️ Time Tracking Completo

- **Cronómetro Integrado**: Play/Stop/Finish en cada tarea
- **Análisis de Desviaciones**: Tiempo estimado vs real
- **Métricas por Usuario**: Carga de trabajo y productividad

### 📊 Visualización Avanzada

- **Diagrama de Gantt Interactivo**: Custom paint con Canvas
- **Vista de Workload**: Análisis de carga con color coding
- **Dashboard de Métricas**: KPIs del proyecto en tiempo real

### 🔐 Gestión de Usuarios

- **Roles Granulares**: Admin, Project Manager, Team Member
- **Autenticación JWT**: Segura y escalable
- **Permisos por Proyecto**: Control de acceso fino

### 🔔 Sistema de Notificaciones Push

- **Firebase Cloud Messaging**: Notificaciones en tiempo real (Web, iOS, Android)
- **Preferencias Personalizables**: Control granular por tipo de notificación
- **Notificaciones Individuales y Grupales**: Soporte para topics y usuarios específicos
- **Logs y Métricas**: Seguimiento completo de entregas y fallos
- **Integración Automática**: Push enviado automáticamente al crear notificaciones

---

## 🏗️ Arquitectura

### Backend

- **Node.js + Express**: API RESTful
- **Prisma ORM**: Type-safe database access
- **PostgreSQL**: Base de datos relacional
- **JWT**: Autenticación stateless

### Frontend

- **Flutter 3.9+**: Multiplataforma (iOS/Android/Web/Desktop)
- **Clean Architecture**: Separación domain/data/presentation
- **BLoC Pattern**: State management reactivo
- **Dio**: HTTP client con interceptores

### Infraestructura

- **Docker Compose**: Orquestación de servicios
- **Multi-stage Build**: Imágenes optimizadas
- **Health Checks**: Monitoreo automático
- **PgAdmin**: Administración de BD (opcional)

---

## 🐳 Quick Start con Docker

### Prerequisitos

- Docker 24.0+
- Docker Compose 2.20+

### Instalación en 3 Pasos

```bash
# 1. Copiar configuración
cp .env.docker .env

# 2. Iniciar servicios
docker-compose up -d

# 3. Verificar
curl http://localhost:3001/api/health
```

### Servicios Disponibles

- **Backend API**: http://localhost:3001
- **PostgreSQL**: localhost:5432
- **PgAdmin**: http://localhost:5050 (con `--profile tools`)

### Comandos Útiles

#### Windows (PowerShell)

```powershell
.\docker.ps1 up        # Iniciar producción
.\docker.ps1 dev       # Iniciar desarrollo (hot-reload)
.\docker.ps1 logs      # Ver logs
.\docker.ps1 status    # Estado de servicios
.\docker.ps1 help      # Ver todos los comandos
```

#### Linux/Mac (Make)

```bash
make up              # Iniciar producción
make dev             # Iniciar desarrollo
make logs            # Ver logs
make ps              # Estado de servicios
make help            # Ver todos los comandos
```

### Modo Desarrollo (Hot-Reload)

```bash
# Iniciar con hot-reload automático
docker-compose -f docker-compose.dev.yml up -d

# Acceso:
# - Backend: http://localhost:3001
# - PgAdmin: http://localhost:5051
```

Ver documentación completa en [DOCKER_README.md](./DOCKER_README.md)

---

## 🛠️ Configuración Inicial de Base de Datos

### ⚠️ Primera Vez en una Computadora Nueva

Si es la primera vez que instalas Creapolis o ves el error:

```
The table `public.User` does not exist in the current database
```

**Solución Rápida - Ejecuta el script automático:**

```powershell
# Windows PowerShell
.\setup-database.ps1
```

**Solución Manual:**

```bash
# 1. Iniciar PostgreSQL
docker-compose -f docker-compose.dev.yml up postgres -d

# 2. Ir al directorio backend
cd backend

# 3. Aplicar migraciones
npx prisma migrate dev --name init

# 4. Iniciar backend
npm run dev
```

📖 **Guía completa**: [backend/DATABASE_SETUP_GUIDE.md](./backend/DATABASE_SETUP_GUIDE.md)

---

## 📦 Instalación Manual

### Backend

```bash
cd backend

# Instalar dependencias
npm install

# Configurar .env
cp .env.example .env
# Editar DATABASE_URL, JWT_SECRET, etc.

# Ejecutar migraciones
npx prisma migrate deploy
npx prisma generate

# Iniciar servidor
npm run dev  # Desarrollo
npm start    # Producción
```

### Frontend Flutter

```bash
cd creapolis_app

# Instalar dependencias
flutter pub get

# Generar código
dart run build_runner build --delete-conflicting-outputs

# Ejecutar app
flutter run -d chrome  # Web
flutter run -d windows # Desktop
flutter run            # Móvil (con emulador)
```

---

## 📚 Documentación

### 📖 [Complete Documentation](./docs/)

**New to Creapolis?** Start here:
- **[Getting Started Guide](./docs/getting-started/)** - Setup and first steps
- **[Quick Start with Docker](./docs/getting-started/quickstart-docker.md)** - Fastest way to run
- **[User Guides](./docs/user-guides/)** - Step-by-step guides for users

**For Developers:**
- **[Architecture Overview](./docs/architecture/)** - System design and patterns
- **[API Reference](./docs/api-reference/)** - Complete API documentation
- **[Development Guide](./docs/development/)** - Contributing and development
- **[Deployment Guide](./docs/deployment/)** - Production deployment

**Features:**
- **[Features Documentation](./docs/features/)** - All features documented
  - [Advanced Search](./docs/features/advanced-search/)
  - [AI Categorization](./docs/features/ai-categorization/)
  - [NLP Task Creation](./docs/features/nlp-task-creation/)
  - [Push Notifications](./docs/features/notifications/)
  - [And more...](./docs/features/)

**Project Management:**
- **[Master Development Plan](./docs/project-management/MASTER_DEVELOPMENT_PLAN.md)** - Roadmap
- **[Changelog](./docs/project-management/CHANGELOG.md)** - Version history
- **[Phase Documentation](./docs/project-management/phases/)** - Implementation phases

> **💡 Tip**: All documentation has been reorganized into the [`docs/`](./docs/) folder for better navigation and discoverability.

---

## 🔌 API

### Endpoints Principales

#### Autenticación

```bash
POST /api/auth/register  # Registro
POST /api/auth/login     # Login
```

#### Proyectos

```bash
GET    /api/projects           # Listar proyectos
POST   /api/projects           # Crear proyecto
GET    /api/projects/:id       # Obtener proyecto
PUT    /api/projects/:id       # Actualizar
DELETE /api/projects/:id       # Eliminar
```

#### Tareas

```bash
GET    /api/projects/:projectId/tasks      # Listar tareas
POST   /api/projects/:projectId/tasks      # Crear tarea
GET    /api/tasks/:taskId                  # Obtener tarea
PUT    /api/tasks/:taskId                  # Actualizar
DELETE /api/tasks/:taskId                  # Eliminar
```

#### Scheduler

```bash
POST /api/projects/:id/schedule/calculate    # Calcular cronograma inicial
POST /api/projects/:id/schedule/reschedule   # Replanificar desde tarea
GET  /api/projects/:id/schedule/resources    # Análisis de carga
```

#### Google Calendar

```bash
GET  /api/integrations/google/auth-url       # Obtener URL OAuth
POST /api/integrations/google/callback       # Completar OAuth
GET  /api/integrations/google/status         # Estado de conexión
GET  /api/integrations/google/events         # Eventos del calendario
```

#### Push Notifications

```bash
POST   /api/push/register           # Registrar dispositivo
DELETE /api/push/unregister         # Desregistrar dispositivo
GET    /api/push/preferences        # Obtener preferencias
PUT    /api/push/preferences        # Actualizar preferencias
POST   /api/push/subscribe          # Suscribirse a topic
POST   /api/push/unsubscribe        # Desuscribirse de topic
GET    /api/push/logs               # Logs de notificaciones
GET    /api/push/metrics            # Métricas de notificaciones
```

**📖 Complete API Documentation**: See [API Reference](./docs/api-reference/)

---

## 🤝 Contribuir

We welcome contributions! Here's how to get started:

1. Fork el proyecto
2. Crea tu rama (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

**📖 Contribution Guidelines**: See [Contributing Guide](./docs/development/contributing.md)

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver [LICENSE](./LICENSE) para más información.

---

## 👥 Equipo

**Creapolis Team**

- GitHub: [@tiagofur](https://github.com/tiagofur)
- Proyecto: [creapolis-project](https://github.com/tiagofur/creapolis-project)

---

**Última actualización**: 3 de octubre de 2025  
**Versión**: 1.0.0  
**Estado**: ✅ Producción Ready
