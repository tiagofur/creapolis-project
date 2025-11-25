# 📚 Creapolis Documentation

> **Documentación oficial del sistema de gestión de proyectos Creapolis**

---

## 🎯 Estado del Proyecto

**[📊 MASTER_STATUS.md](./MASTER_STATUS.md)** - Estado completo y actualizado del proyecto

| Métrica          | Estado |
| ---------------- | ------ |
| Backend          | 85% ✅ |
| Flutter App      | 75% ✅ |
| Enterprise Ready | 40% ⚠️ |

---

## 🚀 Quick Start

### Opción 1: Docker (Recomendado)

```bash
docker-compose up -d
```

### Opción 2: Manual

```bash
# Backend
cd backend
npm install
npx prisma migrate dev
npm run dev

# Flutter App
cd creapolis_app
flutter pub get
flutter run
```

**Guía completa**: [QUICK_START.md](./QUICK_START.md)

---

## 📖 Documentación por Área

### 🏗️ [Architecture](./architecture/)

- [Backend Status](./architecture/backend-status.md)
- [Database Design](./architecture/database-design.md)

### 🔌 [API Reference](./api-reference/)

- [REST API](./api-reference/rest-api.md)
- [GraphQL API](./api-reference/graphql-api.md)
- [Workspace API](./api-reference/workspace-api.md)

### 🖥️ [Backend](./backend/)

- [Installation](./backend/INSTALLATION.md)
- [API Documentation](./backend/API_DOCUMENTATION.md)
- [GraphQL Documentation](./backend/GRAPHQL_API_DOCUMENTATION.md)
- [NLP Features](./backend/NLP_FEATURE_DOCUMENTATION.md)
- [Integrations](./backend/INTEGRATIONS_DOCUMENTATION.md)

### 📱 [Flutter App](./creapolis_app/)

- [Architecture](./creapolis_app/ARCHITECTURE.md)
- [Design System](./creapolis_app/DESIGN_SYSTEM.md)
- [Offline Implementation](./creapolis_app/OFFLINE_FIRST_IMPLEMENTATION.md)
- [Getting Started](./creapolis_app/GETTING_STARTED.md)

### 🚢 [Deployment](./deployment/)

- Docker deployment
- Cloud configuration
- Environment setup

---

## 📋 Roadmap

### ✅ Completado

- Autenticación completa (JWT, OAuth, 2FA)
- Gestión de Workspaces, Proyectos, Tareas
- Time Tracking con analytics
- Gantt Chart, Calendar, Workload views
- Notificaciones push + real-time
- Chat integrado
- Integraciones (Google Calendar, Slack, Trello)
- AI/NLP para tareas
- Reportes con export (CSV, Excel, PDF)
- Offline-first con sync
- GoRouter con deep linking

### 🔜 Próximo

1. **Custom Fields** - Campos personalizados en tareas/proyectos
2. **Automations** - Workflows automatizados
3. **Webhooks** - Integración con sistemas externos
4. **SAML SSO** - Enterprise single sign-on

**Roadmap completo**: [ROADMAP_WORLD_CLASS.md](./ROADMAP_WORLD_CLASS.md)

---

## 🗂️ Estructura de Documentación

```
docs/
├── MASTER_STATUS.md          # 📊 Estado actual del proyecto
├── QUICK_START.md            # 🚀 Inicio rápido
├── ROADMAP_WORLD_CLASS.md    # 🗺️ Roadmap estratégico
│
├── api-reference/            # 🔌 Documentación de APIs
├── architecture/             # 🏗️ Arquitectura del sistema
├── backend/                  # 🖥️ Documentación backend
├── creapolis_app/            # 📱 Documentación Flutter
├── deployment/               # 🚢 Guías de deployment
│
├── archive/                  # 📦 Documentación histórica
│   └── flutter-phases/       # Fases de desarrollo completadas
│
└── TODO/                     # 📝 Tareas pendientes
```

---

## 🛠️ Tech Stack

| Capa          | Tecnología                           |
| ------------- | ------------------------------------ |
| **Backend**   | Node.js, Express, Prisma, PostgreSQL |
| **Frontend**  | Flutter (iOS, Android, Web, Desktop) |
| **Real-time** | Socket.IO, WebSockets                |
| **AI/ML**     | OpenAI GPT-4, NLP                    |
| **Cache**     | Redis                                |
| **Queue**     | BullMQ                               |
| **Storage**   | AWS S3                               |
| **Auth**      | JWT, OAuth 2.0, TOTP 2FA             |

---

## 🤝 Contribuir

1. Lee [MASTER_STATUS.md](./MASTER_STATUS.md) para entender el estado actual
2. Revisa los gaps en la sección "Pendientes"
3. Crea un issue o PR con tu contribución

---

## 📞 Soporte

- **GitHub Issues**: [Reportar problema](https://github.com/tiagofur/creapolis-project/issues)
- **Documentación**: Este repositorio

---

<div align="center">

**Última actualización**: 25 de Noviembre, 2025

Made with ❤️ by Creapolis Team

</div>
