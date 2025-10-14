# Creapolis Backend

> Sistema de gestión de proyectos con planificación automática e integración con Google Calendar

## ✨ Características

### Gestión de Proyectos

- ✅ CRUD completo de proyectos y tareas
- ✅ Sistema de dependencias entre tareas (FINISH_TO_START, START_TO_START)
- ✅ Gestión de miembros y roles (ADMIN, PROJECT_MANAGER, TEAM_MEMBER)
- ✅ Autenticación JWT con bcrypt

### Time Tracking

- ✅ Seguimiento de tiempo con start/stop/finish
- ✅ Cálculo automático de horas trabajadas
- ✅ Historial de timelogs por tarea y usuario

### Motor de Planificación Inteligente ⭐

- ✅ **Algoritmo de ordenamiento topológico** para resolver dependencias
- ✅ **Detección de dependencias circulares**
- ✅ **Cálculo automático de cronogramas** respetando horario laboral (9-5 L-V)
- ✅ **Replanificación dinámica** cuando cambian fechas de tareas
- ✅ **Análisis de carga de trabajo** y detección de sobrecargas

### Integración Google Calendar ⭐

- ✅ **Autenticación OAuth 2.0** con Google
- ✅ **Consulta de eventos** del calendario del usuario
- ✅ **Identificación de disponibilidad** (bloques de tiempo libre)
- ✅ **Planificación considerando calendario** personal
- ✅ Renovación automática de tokens

## 🚀 Inicio Rápido

### Prerrequisitos

- Node.js 18+
- PostgreSQL 14+
- npm o yarn
- Cuenta de Google Cloud (para integración de Google Calendar)

### Instalación

1. Instalar dependencias:

```bash
npm install
```

2. Configurar variables de entorno:

```bash
cp .env.example .env
# Editar .env con tus configuraciones
```

**Variables de entorno requeridas**:

```bash
DATABASE_URL="postgresql://username:password@localhost:5432/creapolis_db"
JWT_SECRET=your-secret-key
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
GOOGLE_REDIRECT_URI=http://localhost:3001/api/integrations/google/callback
```

3. Configurar base de datos:

```bash
# Crear base de datos PostgreSQL
createdb creapolis_db

# Ejecutar migraciones
npm run prisma:migrate

# Generar Prisma Client
npm run prisma:generate
```

4. Iniciar servidor de desarrollo:

```bash
npm run dev
```

El servidor estará disponible en `http://localhost:3001`

### Verificar Instalación

```bash
curl http://localhost:3001/health
```

## 📁 Estructura del Proyecto

```
backend/
├── src/
│   ├── controllers/     # Controladores de rutas (HTTP layer)
│   │   ├── auth.controller.js
│   │   ├── project.controller.js
│   │   ├── task.controller.js
│   │   ├── timelog.controller.js
│   │   ├── scheduler.controller.js          # ⭐ Planificación
│   │   └── google-calendar.controller.js    # ⭐ Google Calendar
│   ├── services/        # Lógica de negocio
│   │   ├── auth.service.js
│   │   ├── project.service.js
│   │   ├── task.service.js
│   │   ├── timelog.service.js
│   │   ├── scheduler.service.js             # ⭐ Motor de planificación
│   │   └── google-calendar.service.js       # ⭐ Integración Google
│   ├── middleware/      # Middleware de Express
│   │   ├── auth.middleware.js
│   │   └── validation.middleware.js
│   ├── routes/          # Definición de rutas
│   │   ├── auth.routes.js
│   │   ├── project.routes.js
│   │   ├── task.routes.js
│   │   ├── timelog.routes.js
│   │   ├── scheduler.routes.js              # ⭐ Rutas de scheduler
│   │   └── google-calendar.routes.js        # ⭐ Rutas de Google
│   ├── utils/           # Utilidades y helpers
│   ├── validators/      # Validadores de entrada
│   ├── config/          # Configuraciones
│   └── server.js        # Punto de entrada
├── prisma/
│   └── schema.prisma    # Esquema de base de datos
├── tests/               # Tests
├── API_DOCUMENTATION.md # 📘 Documentación completa de API
├── PHASE3_SUMMARY.md    # 📋 Resumen Fase 3 (Scheduler + Google)
└── package.json
```

## 🛠️ Scripts Disponibles

- `npm run dev` - Inicia servidor en modo desarrollo con nodemon
- `npm start` - Inicia servidor en modo producción
- `npm run prisma:generate` - Genera Prisma Client
- `npm run prisma:migrate` - Ejecuta migraciones de base de datos
- `npm run prisma:studio` - Abre Prisma Studio (GUI)
- `npm test` - Ejecuta tests con Jest
- `npm run test:watch` - Ejecuta tests en modo watch

## 🔗 API Endpoints

### API Options

Creapolis provides two API options:

1. **REST API** (Legacy): Traditional REST endpoints at `/api/*`
2. **GraphQL API** (Modern, Recommended): Modern GraphQL endpoint at `/graphql`

### GraphQL Endpoint

```
POST http://localhost:3001/graphql
```

**Features:**
- 🎯 Type-safe queries with schema validation
- 📊 Get exactly the data you need (no over-fetching)
- 🔄 Real-time subscriptions via WebSockets
- 📖 Self-documenting with GraphQL Playground
- 🚀 Optimized queries with DataLoader

**Quick Start:**

```graphql
# Login
mutation {
  login(input: { email: "user@example.com", password: "pass123" }) {
    token
    user { name }
  }
}

# Get your tasks
query {
  myTasks(status: IN_PROGRESS) {
    edges {
      node {
        id
        title
        project { name }
      }
    }
  }
}
```

See [GRAPHQL_QUICKSTART.md](./GRAPHQL_QUICKSTART.md) for full guide.

### REST Endpoints

### Resumen (31 endpoints totales)

| Categoría           | Endpoints | Descripción                        |
| ------------------- | --------- | ---------------------------------- |
| **Authentication**  | 3         | Registro, login, perfil            |
| **Projects**        | 7         | CRUD de proyectos y miembros       |
| **Tasks**           | 5         | CRUD de tareas                     |
| **Time Tracking**   | 5         | Start/stop/finish, timelogs        |
| **Scheduler**       | 4         | Planificación y replanificación ⭐ |
| **Google Calendar** | 7         | OAuth, eventos, disponibilidad ⭐  |

### Endpoints Principales

#### Scheduler ⭐

```http
POST   /api/projects/:projectId/schedule              # Calcular cronograma
GET    /api/projects/:projectId/schedule/validate     # Validar dependencias
POST   /api/projects/:projectId/schedule/reschedule   # Replanificar proyecto
GET    /api/projects/:projectId/schedule/resources    # Analizar carga de trabajo
```

#### Google Calendar ⭐

```http
GET    /api/integrations/google/connect               # Iniciar OAuth
GET    /api/integrations/google/callback              # OAuth callback
GET    /api/integrations/google/status                # Estado de conexión
GET    /api/integrations/google/availability          # Obtener disponibilidad
GET    /api/integrations/google/events                # Obtener eventos
```

**Ver documentación completa**: [API_DOCUMENTATION.md](./API_DOCUMENTATION.md)

## 📚 Documentación

### Documentos Disponibles

- **[API_DOCUMENTATION.md](./API_DOCUMENTATION.md)**: Documentación completa de todos los 31 endpoints REST con ejemplos
- **[GRAPHQL_API_DOCUMENTATION.md](./GRAPHQL_API_DOCUMENTATION.md)**: Documentación completa de la API GraphQL moderna
- **[GRAPHQL_QUICKSTART.md](./GRAPHQL_QUICKSTART.md)**: Guía rápida para empezar con GraphQL en 5 minutos
- **[PHASE3_SUMMARY.md](./PHASE3_SUMMARY.md)**: Resumen detallado de Fase 3 (Motor de Planificación + Google Calendar)
- **[prisma/schema.prisma](./prisma/schema.prisma)**: Modelo de datos completo

### Características Destacadas

#### 🎯 Motor de Planificación

El scheduler utiliza **ordenamiento topológico (algoritmo de Kahn)** para:

- Ordenar tareas respetando dependencias
- Detectar dependencias circulares
- Calcular fechas de inicio/fin automáticamente
- Considerar horario laboral (9-5 L-V)

**Ejemplo de uso**:

```bash
# Calcular cronograma inicial de proyecto
curl -X POST http://localhost:3001/api/projects/1/schedule \
  -H "Authorization: Bearer <token>"

# Replanificar desde tarea específica
curl -X POST http://localhost:3001/api/projects/1/schedule/reschedule \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "triggerTaskId": 5,
    "newStartDate": "2024-01-15T09:00:00.000Z",
    "considerCalendar": true
  }'
```

#### 📅 Integración Google Calendar

El sistema puede:

- Consultar eventos del calendario del usuario
- Identificar bloques de tiempo libre
- Agendar tareas en slots disponibles
- Evitar conflictos con eventos existentes

**Flujo OAuth**:

1. Usuario solicita conexión: `GET /api/integrations/google/connect`
2. Sistema genera URL de autorización
3. Usuario autoriza en Google
4. Google redirecciona a callback con código
5. Sistema intercambia código por tokens y los guarda

## 🔐 Autenticación

El sistema usa JWT (JSON Web Tokens) para autenticación. Los tokens deben incluirse en el header:

```
Authorization: Bearer <token>
```

**Obtener token**:

```bash
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123"
  }'
```

## 🧪 Testing

```bash
# Ejecutar todos los tests
npm test

# Tests con cobertura
npm test -- --coverage

# Tests en modo watch
npm run test:watch
```

## 🛠️ Stack Tecnológico

- **Runtime**: Node.js 18+
- **Framework**: Express 4.18
- **ORM**: Prisma 5.7
- **Base de Datos**: PostgreSQL 14+
- **Autenticación**: JWT + bcrypt
- **Validación**: express-validator
- **Testing**: Jest + Supertest
- **Seguridad**: Helmet, CORS, Rate Limiting
- **APIs Externas**: Google Calendar API (googleapis)

## 📊 Estado del Proyecto

### ✅ Completado (Fases 1-3)

- [x] Fase 1: Backend - Modelos de Datos y Autenticación (100%)
- [x] Fase 2: Backend - Lógica de Negocio Central (100%)
- [x] Fase 3: Backend - Motor de Planificación (100%)
  - [x] Scheduler con algoritmo topológico
  - [x] Integración Google Calendar OAuth 2.0
  - [x] Replanificación inteligente
  - [x] Análisis de carga de trabajo

### 🚧 En Progreso

- [ ] Fase 4: Frontend - Vistas y Componentes (0%)
  - [ ] React + Vite + Tailwind
  - [ ] Diagrama de Gantt
  - [ ] Time tracking UI
  - [ ] Vista de carga de trabajo

## 🤝 Contribución

Ver [CONTRIBUTING.md](../CONTRIBUTING.md) para detalles.

## 📄 Licencia

Ver [LICENSE](../LICENSE) para detalles.
