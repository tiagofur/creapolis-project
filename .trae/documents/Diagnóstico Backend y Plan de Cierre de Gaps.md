## Estado Actual
- Plataforma: `Express` + `Apollo GraphQL` + `Prisma` sobre PostgreSQL. Arranca con CORS, Helmet, rate‑limiting y health checks (`backend/src/server.js`:49–127, 96–101, 112–127).
- Base de datos: conexión Prisma con logs y lifecycle (`backend/src/config/database.js`:7–13, 15–30). Esquema amplio con usuarios, workspaces, proyectos, tareas, dependencias, notificaciones, blog, foro y soporte (`backend/prisma/schema.prisma`:10–58, 60–173, 391–404, 589–676, 696–904, 905–1044).
- Autenticación: JWT en REST y GraphQL, middleware de protección (`backend/src/middleware/auth.middleware.js`:9–52). Endpoints: register/login/me (`backend/src/controllers/auth.controller.js`:13–46) y resolvers GraphQL including `updateProfile` (`backend/src/graphql/resolvers/auth.resolvers.js`:93–156, 193–210).
- Funciones de tareas/proyectos/time tracking: rutas y servicios robustos con validaciones y dependencias (REST) y equivalentes en GraphQL (e.g., `backend/tests/task.test.js`, `backend/tests/project.test.js`, `backend/src/graphql/resolvers/project.resolvers.js`).
- Búsqueda global: servicio con relevancia y quick search protegido por auth (`backend/src/services/search.service.js`:84–207, 283–350; `backend/src/routes/search.routes.js`:7–10).
- Notificaciones push: Firebase Admin con llaves por env, registro de tokens y métricas (`backend/src/services/firebase.service.js`:27–47; `backend/src/services/push-notification.service.js`:151–222, 393–444; rutas protegidas `backend/src/routes/push-notification.routes.js`:7–9).
- IA/NLP: categorización y parser de instrucciones basado en reglas, sin proveedores externos (`backend/src/services/ai/categorizationService.js`; `backend/src/services/ai/nlpService.js`).
- GraphQL: servidor y contexto con introspección controlada por `NODE_ENV` (`backend/src/graphql/index.js`:12–36; `backend/src/graphql/context.js`:8–23).
- Tests: suites para REST/GraphQL/NLP con base de datos Postgres en CI (`backend/tests/*.js`, `.github/workflows/backend-ci.yml`).
- Entorno: `.env.example` específico del backend con todas las vars usadas por código (`backend/.env.example`).

## Gaps y Errores Detectados
- Rutas de IA sin autenticación; escriben en BD: proteger con `authenticate` (`backend/src/routes/aiRoutes.js`:17–33).
- Inconsistencias en Soporte: se usa `role: 'SUPPORT'` que no existe en `Role`, y `avatar` en vez de `avatarUrl` (`backend/src/controllers/support.controller.js`:520–529). Debe alinearse con el esquema.
- Perfil de usuario (REST): no hay endpoint para actualizar nombre/`avatarUrl`; GraphQL sí. Falta `PUT /api/auth/me` con validaciones.
- Imagen de perfil: no hay flujo de subida/almacenamiento (S3/local) ni sanitización; faltan llaves y servicio de almacenamiento.
- Seguridad adicional:
  - Rate limiting aplica a `/api` pero no a `/graphql` (`backend/src/server.js`:96–101); conviene limitar `/graphql`.
  - Reset de contraseña/verify email ausentes; faltan flows de email.
- Cobertura de tests: sin tests para soporte, blog, foro, búsqueda y notificaciones; ampliar.
- Entorno duplicado: `.env.example` raíz contiene Mongo/Supabase/AI no usados por backend; puede confundir. Backend usa `backend/.env.example` correctamente.

## Sugerencias de Funcionalidad Faltante
- Gestión de perfil completa: campos opcionales (bio, teléfono, idioma, zona horaria, redes), `PUT /api/auth/me`, y subida segura de avatar (S3/local).
- Adaptador de IA opcional: interfaz `mlAdapter` ya existe; crear provider con OpenAI/Groq/Anthropic usando `OPENAI_API_KEY` etc., con fallback a reglas si no hay llaves.
- Roles/Permisos: definir rol de soporte en enum o usar roles existentes; revisar permisos por recurso en Soporte y Admin.
- Email service: endpoints `POST /api/auth/forgot-password`, `POST /api/auth/reset-password`, `POST /api/auth/verify-email` usando proveedor (SendGrid) con plantillas.
- Observabilidad: logger estructurado (p.ej. `pino`) y métricas para endpoints críticos.
- Endpoints de media: servicio para subir imágenes (perfil/blog) con validaciones de tamaño/tipo.

## Validación y Tests Propuestos
- Añadir suites Jest para: soporte (CRUD y permisos), blog/foro (creación/like/comentarios), búsqueda (relevancia/paginación), push (registro tokens y métricas con Firebase simulado).
- Tests de GraphQL adicionales: rate limiting, autorización en resolvers de IA si se exponen.

## Plan de Implementación
1) Proteger rutas de IA con auth y añadir validaciones de entrada.
2) Corregir Soporte: usar `avatarUrl` y rol válido; opcionalmente ampliar enum de `Role`.
3) Crear `PUT /api/auth/me` con validator y servicio; exponer actualización de `avatarUrl`.
4) Añadir servicio de almacenamiento (S3/local) y endpoint de subida de avatar; agregar vars a `.env.example` backend.
5) Integrar `mlAdapter` con proveedor externo (OpenAI/Groq) controlado por env; fallback si no hay llaves.
6) Aplicar rate limiting a `/graphql`; parametrizar ventanas/límites via env.
7) Implementar flows de email (forgot/reset/verify) y plantillas; añadir tests.
8) Ampliar cobertura de tests para soporte/blog/foro/búsqueda/push.
9) Documentar `.env` efectivo del backend y limpiar referencias no usadas en el root para evitar confusión.

## Llaves de Entorno (backend) requeridas
- Base: `DATABASE_URL`, `PORT`, `NODE_ENV`, `JWT_SECRET`, `JWT_EXPIRES_IN`, `CORS_ORIGIN`, `RATE_LIMIT_WINDOW_MS`, `RATE_LIMIT_MAX_REQUESTS`.
- Integraciones: `GOOGLE_CLIENT_ID/SECRET/REDIRECT_URI`, `SLACK_CLIENT_ID/SECRET/REDIRECT_URI`, `TRELLO_API_KEY/SECRET/REDIRECT_URI`, `API_BASE_URL`.
- Push: `FIREBASE_PROJECT_ID`, `FIREBASE_PRIVATE_KEY`, `FIREBASE_CLIENT_EMAIL`.
- IA opcional: `OPENAI_API_KEY`/`ANTHROPIC_API_KEY`/`GROQ_API_KEY` (a definir si se integra).

¿Confirmas que procedamos con este plan? Incluye parches en controladores/rutas, creación de servicios de avatar/IA, rate limiting en GraphQL y ampliación de tests.