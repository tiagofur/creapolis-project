# Documentación - Creapolis Project

> **Última actualización**: Enero 11, 2025

## 📚 Estructura de Documentación

Esta carpeta contiene toda la documentación técnica del proyecto Creapolis organizada por categorías.

---

## 🚀 NUEVO: Plan de Mejoras UX/UI (2025-01-11)

### 📋 Documentación Completa - 23,000+ palabras

> **Objetivo**: Plan completo y ejecutable para mejorar la experiencia de usuario con funcionalidades básicas de alto impacto.

#### Documentos (Leer en este orden):

1. **[UX_EXECUTIVE_SUMMARY.md](./UX_EXECUTIVE_SUMMARY.md)** ⭐ **EMPEZAR AQUÍ**

   - Resumen ejecutivo de 10 minutos
   - Visión general de mejoras
   - Métricas de éxito y ROI
   - Comparación con Notion/Trello/Asana
   - Timeline: 5 días de desarrollo

2. **[UX_IMPROVEMENT_PLAN.md](./UX_IMPROVEMENT_PLAN.md)**

   - Análisis completo del estado actual (30 min)
   - Filosofía: "Lo básico perfecto primero"
   - 7 mejoras priorizadas por impacto/esfuerzo
   - Estructura definitiva de URLs
   - Clean Code y gestión de deuda técnica

3. **[UX_IMPROVEMENT_ROADMAP.md](./UX_IMPROVEMENT_ROADMAP.md)**

   - Roadmap de implementación día por día (25 min)
   - Checklist de 60+ tareas con subtareas
   - Estimaciones de tiempo precisas
   - Tests a realizar por feature
   - Workflow de desarrollo y commits

4. **[UX_TECHNICAL_SPECS.md](./UX_TECHNICAL_SPECS.md)**

   - Especificaciones técnicas completas (20 min)
   - Código base de DashboardScreen
   - Implementación de Bottom Navigation
   - Extension methods de navegación
   - 24 archivos nuevos especificados

5. **[UX_VISUAL_GUIDE.md](./UX_VISUAL_GUIDE.md)**
   - Guía visual rápida (15 min)
   - Wireframes ASCII de todas las pantallas
   - Flujos de navegación visuales
   - Mapa completo de URLs
   - Testing checklist visual

#### Mejoras Principales:

- ✅ **Dashboard/Home Screen** - Punto de entrada principal
- ✅ **Bottom Navigation** - 4 tabs para acceso rápido
- ✅ **All Tasks Screen** - Vista global de tareas
- ✅ **FAB Global** - Creación rápida con 1 tap
- ✅ **Profile Screen** - Perfil completo del usuario
- ✅ **Onboarding Flow** - Guía para nuevos usuarios
- ✅ **Empty States** - Estados amigables y accionables

#### Características del Plan:

- 🎯 Bajo riesgo, alto impacto
- 📱 Mobile-first UX
- 🔗 URLs perfectas (compartibles, bookmarkables)
- 🧹 Clean Code y best practices
- ⚡ 5 días de implementación
- 📊 ROI muy alto

---

## 📂 Carpetas

### 🔧 [setup/](./setup/)

Guías de configuración y puesta en marcha del entorno de desarrollo.

- **[ENVIRONMENT_SETUP.md](./setup/ENVIRONMENT_SETUP.md)** - Configuración completa del entorno (puertos, CORS, Docker, PostgreSQL)
- **[QUICKSTART_DOCKER.md](./setup/QUICKSTART_DOCKER.md)** - Guía rápida de inicio con Docker

### 🛠️ [fixes/](./fixes/)

Documentación de soluciones a problemas comunes y errores recurrentes.

- **[COMMON_FIXES.md](./fixes/COMMON_FIXES.md)** - Soluciones consolidadas de errores comunes (API, Frontend, DB, Parsing)

### 🎨 [workflow/](./workflow/)

Documentación sobre workflows visuales y personalización del sistema.

- **[README.md](./workflow/README.md)** - Índice de documentación de workflows
- **[WORKFLOW_VISUAL_DESIGN_GUIDE.md](./workflow/WORKFLOW_VISUAL_DESIGN_GUIDE.md)** - Guía de diseño visual
- **[WORKFLOW_VISUAL_QUICK_REFERENCE.md](./workflow/WORKFLOW_VISUAL_QUICK_REFERENCE.md)** - Referencia rápida
- **[WORKFLOW_VISUAL_PERSONALIZATION.md](./workflow/WORKFLOW_VISUAL_PERSONALIZATION.md)** - Guía de personalización
- **[WORKFLOW_VISUAL_TESTING_GUIDE.md](./workflow/WORKFLOW_VISUAL_TESTING_GUIDE.md)** - Guía de testing

### 🔌 [mcps/](./mcps/)

Documentación sobre Model Context Protocol (MCP) servers integrados.

- **[README.md](./mcps/README.md)** - Información sobre MCPs utilizados en el proyecto

### 📜 [history/](./history/)

Archivo histórico de fixes y documentación legacy. **No necesitas revisar esto para trabajar en el proyecto.**

Incluye documentación histórica de problemas ya resueltos y consolidados en los archivos principales.

---

## 🚀 Inicio Rápido

### Para Desarrolladores Nuevos

1. **Configurar el entorno**: Lee [setup/ENVIRONMENT_SETUP.md](./setup/ENVIRONMENT_SETUP.md) o [setup/QUICKSTART_DOCKER.md](./setup/QUICKSTART_DOCKER.md)
2. **Si encuentras errores**: Consulta [fixes/COMMON_FIXES.md](./fixes/COMMON_FIXES.md)
3. **Workflows visuales**: Revisa [workflow/](./workflow/) para personalización
4. **Arquitectura del proyecto**: Ve al README principal del proyecto

### Para Troubleshooting

1. **Error de CORS o puertos**: [setup/ENVIRONMENT_SETUP.md](./setup/ENVIRONMENT_SETUP.md#configuración-de-cors)
2. **Error en API o Backend**: [fixes/COMMON_FIXES.md](./fixes/COMMON_FIXES.md#errores-de-api-y-backend)
3. **Error en Flutter**: [fixes/COMMON_FIXES.md](./fixes/COMMON_FIXES.md#errores-de-frontend-flutter)
4. **Error de Base de Datos**: [fixes/COMMON_FIXES.md](./fixes/COMMON_FIXES.md#errores-de-base-de-datos)

---

## 📋 Stack Tecnológico

### Backend

- Node.js 18+ con Express
- Prisma ORM
- PostgreSQL
- JWT Authentication
- Docker

### Frontend

- Flutter 3.9+ (Web, Mobile, Desktop)
- Clean Architecture
- BLoC Pattern (State Management)
- Dio (HTTP Client)
- GoRouter (Navigation)

### DevOps

- Docker & Docker Compose
- PowerShell Scripts
- Git

---

## 🎯 Comandos Rápidos

```powershell
# Iniciar todo (automatizado)
.\start-dev.ps1

# Backend
cd backend
npm start

# Frontend
.\run-flutter.ps1

# PostgreSQL
docker-compose up -d postgres

# Ver estado
docker ps
curl http://localhost:3000/api/health
```

---

## 📞 Ayuda y Recursos

### Documentación Oficial

- [Flutter Docs](https://docs.flutter.dev/)
- [Node.js Docs](https://nodejs.org/docs/)
- [Prisma Docs](https://www.prisma.io/docs/)
- [Docker Docs](https://docs.docker.com/)

### Repositorio

- **GitHub**: [tiagofur/creapolis-project](https://github.com/tiagofur/creapolis-project)
- **Branch principal**: `main`

---

## 📝 Contribuir

Para contribuir al proyecto:

1. Lee [CONTRIBUTING.md](../CONTRIBUTING.md) en la raíz del proyecto
2. Revisa [setup/ENVIRONMENT_SETUP.md](./setup/ENVIRONMENT_SETUP.md) para configurar tu entorno
3. Sigue las convenciones de código del proyecto
4. Escribe tests para nuevas funcionalidades
5. Actualiza la documentación relevante

---

## 📊 Estado del Proyecto

| Componente       | Estado          | Documentación              |
| ---------------- | --------------- | -------------------------- |
| Backend API      | ✅ Funcional    | setup/ENVIRONMENT_SETUP.md |
| Frontend Flutter | ✅ Funcional    | setup/ENVIRONMENT_SETUP.md |
| PostgreSQL       | ✅ Funcional    | setup/ENVIRONMENT_SETUP.md |
| Docker Setup     | ✅ Configurado  | setup/ENVIRONMENT_SETUP.md |
| CORS Config      | ✅ Resuelto     | fixes/COMMON_FIXES.md      |
| Time Tracking    | ✅ Implementado | fixes/COMMON_FIXES.md      |
| Gantt Chart      | ✅ Implementado | history/                   |
| Google Calendar  | ✅ Integrado    | history/                   |

---

## 🗂️ Índice de Problemas Resueltos

Todos los problemas históricos han sido consolidados. Si encuentras algo similar:

1. **Errores de CORS** → [setup/ENVIRONMENT_SETUP.md](./setup/ENVIRONMENT_SETUP.md#configuración-de-cors)
2. **Errores 404** → [fixes/COMMON_FIXES.md](./fixes/COMMON_FIXES.md#1-error-404-en-apiauthme)
3. **Errores de Parsing** → [fixes/COMMON_FIXES.md](./fixes/COMMON_FIXES.md#1-error-en-parsing-de-task-model)
4. **Errores de DB** → [fixes/COMMON_FIXES.md](./fixes/COMMON_FIXES.md#errores-de-base-de-datos)
5. **Puertos ocupados** → [setup/ENVIRONMENT_SETUP.md](./setup/ENVIRONMENT_SETUP.md#error-port-8080-already-in-use)

---

## 🔐 Credenciales de Desarrollo

### PostgreSQL

```
Host: localhost
Port: 5432
Database: creapolis_db
User: creapolis
Password: creapolis_password_2024
```

### Usuario de Prueba

```
Email: tiagofur@gmail.com
Password: Davidi81
```

---

## 📅 Última Actualización

**Fecha**: Octubre 11, 2025  
**Versión**: 2.0  
**Reorganización**: Documentación consolidada y optimizada  
**Mantenedor**: Equipo Creapolis

---

## ⚠️ Nota Importante

La carpeta `history/` contiene documentación legacy de problemas ya resueltos. **No es necesario revisarla** para trabajar en el proyecto. Toda la información relevante ha sido consolidada en:

- **setup/ENVIRONMENT_SETUP.md** - Configuración
- **fixes/COMMON_FIXES.md** - Soluciones

Solo consulta `history/` si necesitas contexto histórico de cómo se resolvió un problema específico.
