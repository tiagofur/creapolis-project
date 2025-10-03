# Plan de Tareas del Proyecto Creapolis

> **Documento generado**: 3 de octubre de 2025  
> **Estado**: Planificación inicial  
> **Versión**: 1.0

## Índice

- [Fase 1: Backend - Modelos de Datos y Autenticación](#fase-1-backend---modelos-de-datos-y-autenticación)
- [Fase 2: Backend - Lógica de Negocio Central](#fase-2-backend---lógica-de-negocio-central)
- [Fase 3: Backend - Motor de Planificación](#fase-3-backend---motor-de-planificación)
- [Fase 4: Frontend - Vistas y Componentes](#fase-4-frontend---vistas-y-componentes)
- [Consideraciones y Mejoras Sugeridas](#consideraciones-y-mejoras-sugeridas)

---

## Fase 1: Backend - Modelos de Datos y Autenticación

**Objetivo**: Establecer la base del backend con la estructura de datos y sistema de autenticación.

### Tarea 1.1: Configuración del Proyecto Backend

**Prioridad**: Alta  
**Estimación**: 4 horas  
**Dependencias**: Ninguna

**Descripción**:

- Configurar un nuevo proyecto con Node.js y Express
- Instalar y configurar Prisma como ORM
- Configurar PostgreSQL como base de datos
- Crear archivo `schema.prisma` base
- Configurar estructura de carpetas del proyecto (controllers, services, routes, middleware)
- Configurar variables de entorno (.env)

**Criterios de aceptación**:

- [x] Proyecto Node.js iniciado con Express
- [x] Prisma instalado y configurado
- [x] Conexión a PostgreSQL verificada
- [x] Estructura de carpetas creada
- [x] Archivo .env.example documentado

---

### Tarea 1.2: Definición del Modelo User

**Prioridad**: Alta  
**Estimación**: 2 horas  
**Dependencias**: Tarea 1.1

**Descripción**:
Definir el modelo `User` en `schema.prisma` con los siguientes campos:

```prisma
model User {
  id                  Int       @id @default(autoincrement())
  email               String    @unique
  password            String
  name                String
  role                Role      @default(TEAM_MEMBER)
  googleAccessToken   String?
  googleRefreshToken  String?
  createdAt           DateTime  @default(now())
  updatedAt           DateTime  @updatedAt
}

enum Role {
  ADMIN
  PROJECT_MANAGER
  TEAM_MEMBER
}
```

**Criterios de aceptación**:

- [x] Modelo User definido con todos los campos requeridos
- [x] Enum Role configurado
- [ ] Migración de Prisma ejecutada exitosamente

---

### Tarea 1.3: Definición de Modelos Project y Task

**Prioridad**: Alta  
**Estimación**: 3 horas  
**Dependencias**: Tarea 1.2

**Descripción**:
Definir los modelos `Project` y `Task` con sus relaciones:

- **Project**: id, name, description, relación muchos-a-muchos con User
- **Task**: id, title, description, status (enum), estimatedHours, actualHours, relación con Project y User (assignee)
- Configurar índices apropiados para optimizar consultas

**Criterios de aceptación**:

- [x] Modelo Project definido con relaciones
- [x] Modelo Task definido con todos los campos
- [x] Enum TaskStatus configurado (PLANNED, IN_PROGRESS, COMPLETED)
- [x] Tabla intermedia para Project-User creada
- [ ] Migración ejecutada y verificada

---

### Tarea 1.4: Definición de Modelos Dependency y TimeLog

**Prioridad**: Alta  
**Estimación**: 2 horas  
**Dependencias**: Tarea 1.3

**Descripción**:
Definir los modelos `Dependency` y `TimeLog`:

- **Dependency**: Relación entre tareas predecesoras y sucesoras con tipo de dependencia
- **TimeLog**: Registro de bloques de trabajo con startTime, endTime y relación con Task

**Criterios de aceptación**:

- [x] Modelo Dependency definido con validaciones
- [x] Modelo TimeLog definido
- [x] Enum DependencyType configurado (FINISH_TO_START, START_TO_START)
- [x] Restricciones de integridad referencial establecidas
- [ ] Migración ejecutada

---

### Tarea 1.5: Implementación de API de Autenticación

**Prioridad**: Alta  
**Estimación**: 6 horas  
**Dependencias**: Tarea 1.2

**Descripción**:
Crear sistema completo de autenticación:

- `POST /api/auth/register`: Registro de nuevos usuarios
- `POST /api/auth/login`: Autenticación y generación de JWT
- Middleware de autenticación para proteger rutas
- Implementar bcrypt para hasheo de contraseñas
- Configurar JWT con tiempo de expiración apropiado

**Criterios de aceptación**:

- [x] Endpoint de registro funcional con validaciones
- [x] Endpoint de login retorna JWT válido
- [x] Contraseñas hasheadas con bcrypt
- [x] Middleware de autenticación creado
- [x] Manejo de errores implementado
- [x] Documentación de endpoints (Swagger/OpenAPI recomendado)

---

## Fase 2: Backend - Lógica de Negocio Central

**Objetivo**: Implementar las operaciones CRUD y lógica de negocio principal.

### Tarea 2.1: API CRUD para Proyectos

**Prioridad**: Alta  
**Estimación**: 6 horas  
**Dependencias**: Tarea 1.5

**Descripción**:
Implementar API RESTful completa para gestión de proyectos:

- `GET /api/projects`: Listar proyectos del usuario autenticado
- `POST /api/projects`: Crear nuevo proyecto
- `GET /api/projects/:id`: Obtener proyecto por ID
- `PUT /api/projects/:id`: Actualizar proyecto
- `DELETE /api/projects/:id`: Eliminar proyecto

**Criterios de aceptación**:

- [x] Todos los endpoints implementados con autenticación JWT
- [x] Validación de permisos (solo miembros del proyecto pueden acceder)
- [x] Validación de datos de entrada
- [x] Paginación en listado de proyectos
- [x] Manejo de errores robusto
- [x] Tests unitarios e integración

---

### Tarea 2.2: API CRUD para Tareas

**Prioridad**: Alta  
**Estimación**: 8 horas  
**Dependencias**: Tarea 2.1

**Descripción**:
Implementar API RESTful para gestión de tareas dentro de proyectos:

- `GET /api/projects/:projectId/tasks`: Listar tareas del proyecto
- `POST /api/projects/:projectId/tasks`: Crear nueva tarea
- `GET /api/projects/:projectId/tasks/:taskId`: Obtener tarea específica
- `PUT /api/projects/:projectId/tasks/:taskId`: Actualizar tarea
- `DELETE /api/projects/:projectId/tasks/:taskId`: Eliminar tarea

**Criterios de aceptación**:

- [x] Todos los endpoints CRUD implementados
- [x] Validación de pertenencia al proyecto
- [x] Manejo de dependencias al eliminar tareas
- [x] Filtros y ordenamiento en listado
- [x] Validación de estados de tarea
- [x] Tests de integración

---

### Tarea 2.3: API para Time Tracking

**Prioridad**: Media  
**Estimación**: 6 horas  
**Dependencias**: Tarea 2.2

**Descripción**:
Implementar sistema de seguimiento de tiempo:

- `POST /api/tasks/:taskId/start`: Iniciar tiempo de trabajo
- `POST /api/tasks/:taskId/stop`: Detener tiempo de trabajo
- `POST /api/tasks/:taskId/finish`: Finalizar tarea y calcular horas totales
- `GET /api/tasks/:taskId/timelogs`: Obtener historial de timelogs

**Criterios de aceptación**:

- [x] Endpoint start crea TimeLog y actualiza estado de tarea
- [x] Endpoint stop calcula duración del TimeLog
- [x] Endpoint finish suma todas las horas y marca tarea como completada
- [x] Validación: no permitir múltiples timelogs activos simultáneos
- [x] Cálculo automático de actualHours
- [x] Tests de lógica de negocio

---

## Fase 3: Backend - Motor de Planificación

**Objetivo**: Implementar el sistema de planificación automática y sincronización con Google Calendar.

### Tarea 3.1: Módulo SchedulerService - Cálculo Inicial

**Prioridad**: Alta  
**Estimación**: 12 horas  
**Dependencias**: Tarea 2.2

**Descripción**:
Crear módulo `SchedulerService` con función de planificación inicial:

- Implementar algoritmo de ordenamiento topológico para resolver dependencias
- Calcular fechas de inicio y fin para cada tarea
- Considerar horarios laborales (8 horas/día, L-V)
- Manejar casos especiales (dependencias circulares, conflictos)

**Criterios de aceptación**:

- [x] Función calculateInitialSchedule(projectId) implementada
- [x] Algoritmo topológico maneja dependencias correctamente
- [x] Cálculo de fechas respeta horarios laborales
- [x] Detección de dependencias circulares
- [x] Guardado de fechas calculadas en base de datos
- [x] Tests exhaustivos con diferentes escenarios
- [x] Documentación del algoritmo

---

### Tarea 3.2: Integración con Google Calendar - OAuth

**Prioridad**: Media  
**Estimación**: 8 horas  
**Dependencias**: Tarea 1.5

**Descripción**:
Implementar flujo de autenticación OAuth 2.0 con Google:

- `GET /api/integrations/google/connect`: Iniciar flujo OAuth
- `GET /api/integrations/google/callback`: Callback de autorización
- Almacenar tokens de acceso y refresh de forma segura
- Implementar renovación automática de tokens

**Criterios de aceptación**:

- [x] Flujo OAuth 2.0 completo implementado
- [x] Tokens almacenados de forma segura (encriptados)
- [x] Renovación automática de access tokens
- [x] Manejo de errores de autorización
- [x] Documentación para configurar Google Cloud Console
- [x] Tests de integración

---

### Tarea 3.3: Servicio de Sincronización con Google Calendar

**Prioridad**: Media  
**Estimación**: 10 horas  
**Dependencias**: Tarea 3.2

**Descripción**:
Implementar servicio para consultar disponibilidad en Google Calendar:

- Función para obtener eventos de calendario de un usuario en un rango de fechas
- Función para identificar bloques de tiempo disponible
- Caché de eventos para optimizar rendimiento
- Sincronización periódica de eventos

**Criterios de aceptación**:

- [x] Consulta de eventos de Google Calendar funcional
- [x] Identificación de tiempo disponible implementada
- [x] Sistema de caché implementado
- [x] Manejo de zonas horarias
- [x] Rate limiting y manejo de cuotas de API
- [x] Tests con mocks de Google API

---

### Tarea 3.4: Módulo SchedulerService - Replanificación

**Prioridad**: Alta  
**Estimación**: 14 horas  
**Dependencias**: Tarea 3.1, Tarea 3.3

**Descripción**:
Implementar función de replanificación inteligente:

- Función rescheduleProject(projectId, triggerTaskId)
- Recalcular cronograma desde tarea modificada hacia adelante
- Considerar disponibilidad de Google Calendar de los responsables
- Optimizar asignación de recursos
- Notificar cambios a usuarios afectados

**Criterios de aceptación**:

- [x] Función rescheduleProject implementada
- [x] Replanificación respeta disponibilidad de calendarios
- [x] Optimización de asignación de tareas
- [x] Sistema de notificaciones de cambios
- [x] Performance optimizado para proyectos grandes
- [x] Tests de diferentes escenarios de replanificación
- [x] Logs detallados de cambios realizados

---

## Fase 4: Frontend - App Flutter 📱

**Objetivo**: Desarrollar aplicación móvil multiplataforma (iOS, Android, Web, Desktop) con Flutter.

**Stack Tecnológico**:

- 🎯 Flutter 3.9+ con Dart
- 🏗️ Clean Architecture (data/domain/presentation)
- 🧠 BLoC pattern (flutter_bloc) para state management
- 🌐 Dio para HTTP requests
- 💉 GetIt + Injectable para dependency injection
- 🗺️ GoRouter para navegación declarativa
- 💾 flutter_secure_storage para JWT
- 📝 flutter_form_builder para formularios

### Tarea 4.1: Configuración y Setup de Flutter

**Prioridad**: Alta  
**Estimación**: 4 horas  
**Dependencias**: Ninguna

**Descripción**:
Configurar y completar setup del proyecto Flutter existente (`creapolis_app`):

- ✅ Proyecto Flutter ya creado con arquitectura Clean
- ✅ Dependencias core instaladas (flutter_bloc, dio, get_it, go_router)
- Configurar cliente HTTP Dio con interceptores
- Configurar inyección de dependencias con GetIt/Injectable
- Configurar rutas con GoRouter
- Completar tema Material Design (light/dark)
- Configurar variables de entorno

**Criterios de aceptación**:

- [x] Proyecto Flutter configurado con Clean Architecture
- [x] Dependencias core instaladas y configuradas
- [x] Cliente Dio con interceptores (auth, logging, errores)
- [x] Inyección de dependencias funcional (GetIt + Injectable)
- [x] Sistema de rutas con GoRouter y guards
- [x] Tema completo (colores, tipografía, componentes)
- [x] Variables de entorno para API endpoints
- [x] Error handling robusto (Failures y Exceptions)
- [x] SplashScreen con lógica de navegación

**Estado**: ✅ **COMPLETADA**

---

### Tarea 4.2: Módulo de Autenticación Flutter

**Prioridad**: Alta  
**Estimación**: 8 horas  
**Dependencias**: Tarea 4.1, Tarea 1.5

**Descripción**:
Implementar flujo completo de autenticación con arquitectura Clean:

- **Data Layer**: Modelos (UserModel), API datasource, Repository implementation
- **Domain Layer**: Entities (User), Use Cases (Login, Register, Logout), Repository interface
- **Presentation Layer**: AuthBloc (state management), Screens (Login/Register), Widgets
- Almacenamiento seguro de JWT con `flutter_secure_storage`
- Interceptor Dio para agregar JWT automáticamente
- Guards de navegación con GoRouter

**Criterios de aceptación**:

- [ ] Entidades y modelos de User implementados
- [ ] Use Cases: Login, Register, Logout con Either<Failure, User>
- [ ] AuthBloc con estados: Initial, Loading, Authenticated, Error
- [ ] LoginScreen con formulario validado
- [ ] RegisterScreen con formulario validado
- [ ] JWT almacenado en secure storage
- [ ] Interceptor Dio agrega token a peticiones
- [ ] Rutas protegidas con GoRouter guards
- [ ] Manejo de errores con snackbars/dialogs

---

### Tarea 4.3: Módulo de Proyectos Flutter

**Prioridad**: Alta  
**Estimación**: 8 horas  
**Dependencias**: Tarea 4.2

**Descripción**:
Implementar gestión completa de proyectos:

- **Data Layer**: ProjectModel con toJson/fromJson, ProjectRemoteDataSource, ProjectRepository
- **Domain Layer**: Project entity, Use Cases (GetProjects, CreateProject, UpdateProject, DeleteProject)
- **Presentation Layer**: ProjectsBloc, ProjectsListScreen, ProjectDetailScreen
- GridView/ListView de proyectos con ProjectCard widgets
- BottomSheet/Dialog para crear/editar proyectos
- Form validation con flutter_form_builder
- Pull-to-refresh y paginación

**Criterios de aceptación**:

- [ ] Project entity y ProjectModel completos
- [ ] Use Cases de CRUD implementados
- [ ] ProjectsBloc con estados (Loading, Loaded, Error)
- [ ] ProjectsListScreen con grid de cards
- [ ] ProjectCard widget reutilizable
- [ ] CreateProjectBottomSheet con validación
- [ ] ProjectDetailScreen con información completa
- [ ] Pull-to-refresh funcional
- [ ] Búsqueda y filtros básicos
- [ ] Estados vacío/error/loading

---

### Tarea 4.4: Módulo de Tareas Flutter

**Prioridad**: Media  
**Estimación**: 8 horas  
**Dependencias**: Tarea 4.3

**Descripción**:
Implementar gestión de tareas con dependencias:

- **Data Layer**: TaskModel, DependencyModel, datasources y repositories
- **Domain Layer**: Task y Dependency entities, Use Cases (GetTasks, CreateTask, UpdateTask, DeleteTask)
- **Presentation Layer**: TasksBloc, TasksListScreen, TaskDetailScreen
- ListView de tareas con TaskCard (estado visual con colores)
- Formulario de tarea con selector de dependencias
- Chips para estados (PLANNED, IN_PROGRESS, COMPLETED)
- Filtros por estado y asignado

**Criterios de aceptación**:

- [ ] Task y Dependency entities completos
- [ ] TaskModel con serialización JSON
- [ ] Use Cases de CRUD de tareas
- [ ] TasksBloc con gestión de estado
- [ ] TasksListScreen con lista filtrable
- [ ] TaskCard con indicadores de estado (colores)
- [ ] CreateTaskBottomSheet con validación
- [ ] Selector de dependencias entre tareas
- [ ] Filtros por estado y asignado
- [ ] Badges para horas estimadas/actuales

---

### Tarea 4.5: Diagrama de Gantt Flutter ⭐

**Prioridad**: Alta  
**Estimación**: 16 horas  
**Dependencias**: Tarea 4.4, Tarea 3.1

**Descripción**:
Implementar visualización tipo Gantt chart interactivo:

- **Opción 1**: Usar package `gantt_chart` o `flutter_gantt_chart`
- **Opción 2**: Custom paint con Canvas para mayor control
- Timeline horizontal con scroll
- Barras de tareas con fechas inicio/fin
- Líneas de dependencias entre tareas
- Gestures para drag & drop (replanificar)
- Zoom in/out con GestureDetector
- Integración con scheduler backend (calcular/replanificar)

**Criterios de aceptación**:

- [x] GanttChartWidget renderiza timeline
- [x] Barras de tareas coloreadas por estado
- [x] Líneas de dependencias (flechas) visibles
- [x] Scroll horizontal y vertical
- [x] Tap en tarea muestra detalle
- [x] Long press para editar fechas
- [x] Botón calcular cronograma llama API
- [x] Botón replanificar desde tarea específica
- [x] Loading states durante cálculos
- [x] Vista responsive (tablet optimizada)
- [x] Leyenda de colores/estados

**Estado**: ✅ **COMPLETADA**

**Implementación**:

- Custom paint con Canvas para control total
- GanttChartPainter: Renderiza barras y dependencias
- GanttTimelineHeader: Header con meses y días
- GanttChartWidget: Widget principal con zoom y scroll
- GanttChartScreen: Pantalla con integración BLoC
- Eventos: CalculateScheduleEvent, RescheduleProjectEvent
- Estados: TaskScheduleCalculating, TaskScheduleCalculated, TaskRescheduling, TaskRescheduled
- API endpoints: /projects/:id/schedule/calculate, /projects/:id/schedule/reschedule
- Ruta: /projects/:projectId/gantt

---

### Tarea 4.6: Time Tracking Flutter

**Prioridad**: Alta  
**Estimación**: 10 horas  
**Dependencias**: Tarea 4.5, Tarea 2.3

**Descripción**:
Implementar módulo completo de seguimiento de tiempo:

- **Data Layer**: TimeLogModel, TimeLogRemoteDataSource, TimeLogRepository
- **Domain Layer**: TimeLog entity, Use Cases (StartTimer, StopTimer, FinishTask, GetTimeLogs)
- **Presentation Layer**: TimeTrackingBloc, TimeTrackerWidget, TimeLogsList
- Floating Action Button con estado (Play/Stop/Finish)
- Cronómetro en tiempo real con Timer de Dart
- Lista de sesiones de trabajo (timelogs) con duración
- Progress indicator circular (horas trabajadas/estimadas)
- BottomSheet con detalle de tarea + time tracking

**Criterios de aceptación**:

- [x] TimeLog entity y modelo completos
- [x] Use Cases: StartTimer, StopTimer, FinishTask
- [x] TimeTrackingBloc con estados (Idle, Running, Stopped)
- [x] FloatingActionButton animado (Play ↔ Stop)
- [x] Cronómetro actualiza cada segundo
- [x] Lista de timelogs con formato de duración
- [x] CircularProgressIndicator mostrando progreso
- [x] BottomSheet con toda info de tarea (TaskDetailScreen)
- [x] Botón Finish marca tarea como completada
- [ ] Notificación local cuando timer corre en background (deferred)

---

### Tarea 4.7: Vista de Carga de Trabajo Flutter

**Prioridad**: Media  
**Estimación**: 12 horas  
**Dependencias**: Tarea 4.5

**Descripción**:
Implementar análisis visual de carga de trabajo:

- **Data Layer**: Usar endpoint GET /api/projects/:id/schedule/resources
- **Domain Layer**: ResourceAllocation entity, GetResourceAllocation use case
- **Presentation Layer**: WorkloadBloc, WorkloadScreen
- Vista de lista con ExpansionTile por miembro
- Tabla/Grid: columnas por día, filas por miembro
- Color coding: Verde (<6h), Amarillo (6-8h), Rojo (>8h)
- Selector de rango de fechas (week/month picker)
- Gráficos con fl_chart (barras o líneas de carga)
- Indicadores de sobrecargas con badges

**Criterios de aceptación**:

- [x] ResourceAllocation entity mapeado del backend
- [x] GetResourceAllocation use case implementado
- [x] WorkloadBloc obtiene datos del scheduler
- [x] WorkloadScreen con vista tipo calendario
- [x] ExpansionTile por cada miembro del equipo
- [x] Grid/Table mostrando horas por día
- [x] Color coding funcional (verde/amarillo/rojo)
- [x] DateRangePicker para filtrar período (con presets)
- [x] WorkloadStats card con estadísticas del equipo
- [x] Badge/Chip indicando "Overloaded"
- [x] Vista optimizada para tablet (responsive)

---

### Tarea 4.8: Integración Google Calendar Flutter

**Prioridad**: Baja  
**Estimación**: 8 horas  
**Dependencias**: Tarea 3.2

**Descripción**:
Implementar UI para integración con Google Calendar:

- **Packages**: `url_launcher` para abrir OAuth URL, `webview_flutter` para callback
- **Data Layer**: GoogleCalendarDataSource usando endpoints /api/integrations/google
- **Domain Layer**: CalendarEvent entity, Use Cases (ConnectCalendar, GetEvents, GetAvailability)
- **Presentation Layer**: CalendarBloc, SettingsScreen con sección de integraciones
- Botón "Conectar Google Calendar" en settings
- WebView para flujo OAuth (abrir authUrl del backend)
- Indicador de estado con badge (Connected/Disconnected)
- Lista de próximos eventos del calendario (opcional)
- Botón desconectar con confirmación

**Criterios de aceptación**:

- [x] CalendarEvent entity y modelo
- [x] Use Cases: ConnectCalendar, DisconnectCalendar, GetStatus
- [x] CalendarBloc con estados de conexión
- [x] SettingsScreen con sección "Integraciones"
- [x] Botón "Conectar" abre OAuth en WebView
- [x] Badge mostrando estado (Connected ✓ / Disconnected)
- [ ] Lista de próximos eventos (opcional - deferred)
- [x] Botón "Desconectar" con dialog de confirmación
- [x] Manejo de errores OAuth con snackbars
- [ ] Deep linking para callback OAuth (opcional - deferred)

**Estado**: ✅ **COMPLETADA**

**Implementación**:

- Domain: CalendarEvent entity (9 campos), CalendarConnection con CalendarConnectionStatus enum
- Domain: CalendarRepository interface con 6 métodos (connectCalendar, completeOAuthFlow, disconnectCalendar, getConnectionStatus, getEvents, getAvailability)
- Domain: TimeSlot class para disponibilidad
- Use Cases: ConnectCalendarUseCase, DisconnectCalendarUseCase, GetCalendarConnectionStatusUseCase, GetCalendarEventsUseCase, CompleteCalendarOAuthUseCase con validaciones
- Data: CalendarEventModel, CalendarConnectionModel, TimeSlotModel con JSON serialization
- Data: CalendarRemoteDataSource con 6 API endpoints
- Data: CalendarRepositoryImpl con error handling completo
- Presentation: CalendarBloc con 6 event handlers y 8 estados
- Presentation: SettingsScreen con UI completa de integración
- OAuth flow: Obtener authUrl → Abrir navegador → Usuario autoriza → Pegar código manualmente → Completar OAuth
- Ruta: /settings con icono en AppBar de ProjectsListScreen
- Package: url_launcher ^6.3.1 para abrir navegador

---

## Consideraciones y Mejoras Sugeridas

### 🔍 Oportunidades de Mejora Identificadas

#### 1. **Seguridad**

- [ ] Implementar rate limiting en endpoints críticos
- [ ] Añadir validación de entrada robusta (usar librería como Joi o Zod)
- [ ] Implementar CORS apropiadamente
- [ ] Añadir logging de auditoría para acciones críticas
- [ ] Considerar implementar refresh tokens para JWT

#### 2. **Testing**

- [ ] Establecer estrategia de testing (unitarios, integración, E2E)
- [ ] Configurar CI/CD con tests automatizados
- [ ] Añadir tests de performance para el scheduler
- [ ] Implementar tests de carga para APIs

#### 3. **Documentación**

- [ ] Documentar API con Swagger/OpenAPI
- [ ] Crear guía de instalación y deployment
- [ ] Documentar algoritmos complejos (scheduler)
- [ ] Crear documentación de usuario final

#### 4. **Performance**

- [ ] Implementar caché (Redis) para consultas frecuentes
- [ ] Optimizar queries de Prisma con includes selectivos
- [ ] Considerar paginación en todos los listados
- [ ] Implementar lazy loading en frontend

#### 5. **Escalabilidad**

- [ ] Considerar arquitectura de microservicios si el proyecto crece
- [ ] Implementar cola de mensajes (Bull/RabbitMQ) para tareas pesadas
- [ ] Considerar separar el scheduler en servicio independiente
- [ ] Implementar WebSockets para actualizaciones en tiempo real

#### 6. **Funcionalidades Adicionales**

- [ ] Sistema de notificaciones (email, push)
- [ ] Comentarios en tareas
- [ ] Adjuntos de archivos en tareas
- [ ] Historial de cambios (audit log)
- [ ] Roles y permisos más granulares
- [ ] Plantillas de proyectos
- [ ] Dashboard de métricas y KPIs
- [ ] Exportación de reportes (PDF, Excel)
- [ ] Integración con Slack/Teams
- [ ] Modo offline (PWA)

#### 7. **UX/UI**

- [ ] Diseño system con componentes reutilizables
- [ ] Modo oscuro
- [ ] Internacionalización (i18n)
- [ ] Onboarding para nuevos usuarios
- [ ] Tooltips y ayuda contextual
- [ ] Teclado shortcuts
- [ ] Animaciones y transiciones

#### 8. **DevOps**

- [ ] Configurar Docker y Docker Compose
- [ ] Configurar CI/CD (GitHub Actions, GitLab CI)
- [ ] Estrategia de deployment (Vercel, AWS, etc.)
- [ ] Monitoreo y logging (Sentry, LogRocket)
- [ ] Backups automatizados de base de datos

### 📊 Métricas Sugeridas del Proyecto

| Fase      | Tareas | Horas Estimadas | Prioridad Alta | Prioridad Media | Prioridad Baja | Tecnología                 |
| --------- | ------ | --------------- | -------------- | --------------- | -------------- | -------------------------- |
| Fase 1    | 5      | 17h             | 5              | 0               | 0              | Backend (Node.js/Prisma)   |
| Fase 2    | 3      | 20h             | 2              | 1               | 0              | Backend (Express/JWT)      |
| Fase 3    | 4      | 44h             | 2              | 2               | 0              | Backend (Scheduler/Google) |
| Fase 4    | 8      | 74h             | 5              | 2               | 1              | **Flutter (Mobile/Web)**   |
| **Total** | **20** | **155h**        | **14**         | **5**           | **1**          | Full Stack                 |

**Nota**: Fase 4 actualizada a Flutter (de 60h a 74h) debido a complejidad de Gantt chart con Canvas.

### 🎯 Ruta Crítica Recomendada

1. **Sprint 1 (2-3 semanas)**: Fase 1 completa (Backend setup + Auth)
2. **Sprint 2 (2-3 semanas)**: Fase 2 completa (Backend CRUD + Time tracking)
3. **Sprint 3 (3-4 semanas)**: Fase 3 completa (Scheduler + Google Calendar) ✅ **COMPLETADO**
4. **Sprint 4 (1 semana)**: Tarea 4.1-4.2 (Flutter setup + Autenticación)
5. **Sprint 5 (2 semanas)**: Tareas 4.3-4.4 (Proyectos + Tareas)
6. **Sprint 6 (2-3 semanas)**: Tarea 4.5 (Gantt Chart - componente crítico)
7. **Sprint 7 (1-2 semanas)**: Tareas 4.6-4.7 (Time Tracking + Workload)
8. **Sprint 8 (1 semana)**: Tarea 4.8 + refinamiento y testing

### 📝 Notas Adicionales

- **Cambio a Flutter**: Frontend cambiado de React a Flutter para soporte multiplataforma nativo
- **Proyecto existente**: Se aprovecha `creapolis_app` ya creado con Clean Architecture
- **Priorización flexible**: Las prioridades pueden ajustarse según las necesidades del negocio
- **Estimaciones**: Son aproximadas y pueden variar según la experiencia del equipo
- **MVP Flutter**: Las tareas de prioridad alta (4.1-4.3, 4.5-4.6) constituyen el MVP
- **Gantt crítico**: Tarea 4.5 (Gantt) es la más compleja, considerar usar package existente
- **Refinamiento**: Cada tarea debe refinarse en reunión de planning antes de iniciar

---

**Última actualización**: 3 de octubre de 2025  
**Responsable**: Equipo de Desarrollo Creapolis  
**Próxima revisión**: Tras completar Fase 1
