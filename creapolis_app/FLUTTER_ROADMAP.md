# 📱 Creapolis Flutter App - Roadmap de Desarrollo

> Plan completo para implementar la app móvil de Creapolis con Flutter

## 🎯 Visión General

**Objetivo**: Desarrollar aplicación móvil multiplataforma (iOS, Android, Web, Desktop) que consuma el backend Creapolis ya implementado.

**Estado Actual**:

- ✅ Backend 100% completo (31 endpoints REST)
- ✅ Proyecto Flutter creado con Clean Architecture
- ✅ Dependencias core instaladas
- 🚧 Frontend 0% - Listo para empezar desarrollo

## 🏗️ Arquitectura

### Clean Architecture

```
lib/
├── core/               # Configuración base
│   ├── constants/     # API URLs, strings
│   ├── theme/         # Tema Material Design
│   ├── network/       # Cliente Dio
│   ├── errors/        # Failures & Exceptions
│   └── utils/         # Validadores, helpers
│
├── data/              # Capa de datos
│   ├── models/        # DTOs (toJson/fromJson)
│   ├── datasources/   # Remote (API) & Local (Cache)
│   └── repositories/  # Implementaciones
│
├── domain/            # Lógica de negocio
│   ├── entities/      # Entidades puras
│   ├── repositories/  # Interfaces
│   └── usecases/      # Casos de uso
│
└── presentation/      # UI Layer
    ├── blocs/         # State management (BLoC)
    ├── screens/       # Pantallas por feature
    └── shared/        # Widgets reutilizables
```

## 📦 Dependencias Principales

### Ya Instaladas ✅

```yaml
dependencies:
  # State Management
  flutter_bloc: ^8.1.6 # BLoC pattern
  equatable: ^2.0.5 # Value equality

  # Networking
  dio: ^5.7.0 # HTTP client
  pretty_dio_logger: ^1.4.0 # Network logging

  # Storage
  shared_preferences: ^2.3.2 # Simple storage
  flutter_secure_storage: ^9.2.2 # Secure JWT storage

  # Dependency Injection
  get_it: ^8.0.2 # Service locator
  injectable: ^2.5.0 # DI code generation

  # Routing
  go_router: ^14.6.2 # Declarative routing

  # UI
  flutter_svg: ^2.0.10+1 # SVG support
  cached_network_image: ^3.4.1 # Image caching
  shimmer: ^3.0.0 # Loading shimmer
  loading_animation_widget: ^1.2.1

  # Forms
  flutter_form_builder: ^10.0.0
  form_builder_validators: ^11.0.0

  # Utils
  intl: ^0.20.0 # i18n & formatting
  timeago: ^3.7.0 # Relative dates
  logger: ^2.4.0 # Logging
  dartz: ^0.10.1 # Either<L,R>
```

### Por Añadir 📌

```yaml
dependencies:
  # Gantt Chart
  gantt_chart: ^1.0.0 # O implementar custom
  flutter_gantt_chart: ^0.0.3 # Alternativa

  # Charts
  fl_chart: ^0.69.0 # Para workload view

  # OAuth
  url_launcher: ^6.3.1 # Abrir URLs
  webview_flutter: ^4.10.0 # WebView para OAuth

  # Notifications
  flutter_local_notifications: ^18.0.1

  # Calendar
  table_calendar: ^3.1.2 # Calendar widgets
```

## 🎨 Tema y Design System

### Colores Principales

```dart
// Ya configurado en core/theme/app_theme.dart
ColorScheme.light(
  primary: Color(0xFF2196F3),      // Blue
  secondary: Color(0xFF03DAC6),     // Teal
  error: Color(0xFFB00020),         // Red
  surface: Color(0xFFFFFFFF),       // White
  background: Color(0xFFF5F5F5),    // Light gray
)

// Estados de tareas
Colors.blue[200]      // PLANNED
Colors.orange[300]    // IN_PROGRESS
Colors.green[400]     // COMPLETED
```

### Componentes Reutilizables

Ya creados en `presentation/shared/widgets/`:

- ✅ `primary_button.dart`
- ✅ `secondary_button.dart`
- ✅ `custom_card.dart`
- ✅ `loading_widget.dart`
- ✅ `error_widget.dart`
- ✅ `empty_widget.dart`

## 📱 Features a Desarrollar

### 1. Autenticación (Tarea 4.2) 🔐

**Estimación**: 8 horas

**Screens**:

- `LoginScreen` - Email, password, botón login
- `RegisterScreen` - Formulario completo con validaciones
- `SplashScreen` - Verificar JWT y redirigir

**BLoC**:

```dart
AuthBloc:
  - AuthInitial
  - AuthLoading
  - AuthAuthenticated(User user)
  - AuthUnauthenticated
  - AuthError(String message)
```

**Endpoints usados**:

- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/auth/profile`

**Storage**:

- JWT en `flutter_secure_storage`
- User data en `shared_preferences`

---

### 2. Proyectos (Tarea 4.3) 📊

**Estimación**: 8 horas

**Screens**:

- `ProjectsListScreen` - GridView de ProjectCards
- `ProjectDetailScreen` - Info completa + miembros + acciones
- `CreateProjectBottomSheet` - Formulario

**Widgets**:

- `ProjectCard` - Card con nombre, descripción, progreso
- `MemberAvatar` - Avatar circular de miembro
- `ProjectActions` - Edit, delete, add member

**BLoC**:

```dart
ProjectsBloc:
  - ProjectsInitial
  - ProjectsLoading
  - ProjectsLoaded(List<Project> projects)
  - ProjectsError(String message)
  - ProjectActionInProgress
  - ProjectActionSuccess
```

**Endpoints usados**:

- `GET /api/projects`
- `POST /api/projects`
- `GET /api/projects/:id`
- `PUT /api/projects/:id`
- `DELETE /api/projects/:id`
- `POST /api/projects/:id/members`
- `DELETE /api/projects/:id/members/:userId`

---

### 3. Tareas (Tarea 4.4) ✅

**Estimación**: 8 horas

**Screens**:

- `TasksListScreen` - ListView de TaskCards
- `TaskDetailScreen` - Detalle completo
- `CreateTaskBottomSheet` - Form con dependencias

**Widgets**:

- `TaskCard` - Card con estado coloreado
- `StatusChip` - Chip para PLANNED/IN_PROGRESS/COMPLETED
- `DependencySelector` - Multi-select de tareas predecesoras
- `TaskProgressBar` - Linear indicator de progreso

**BLoC**:

```dart
TasksBloc:
  - TasksInitial
  - TasksLoading
  - TasksLoaded(List<Task> tasks)
  - TaskFiltered(List<Task> filtered)
  - TasksError(String message)
```

**Endpoints usados**:

- `GET /api/projects/:projectId/tasks`
- `POST /api/projects/:projectId/tasks`
- `GET /api/projects/:projectId/tasks/:taskId`
- `PUT /api/projects/:projectId/tasks/:taskId`
- `DELETE /api/projects/:projectId/tasks/:taskId`

---

### 4. Gantt Chart (Tarea 4.5) 📈 ⭐ CRÍTICO

**Estimación**: 16 horas

**Opciones de Implementación**:

#### Opción A: Package Existente (Recomendado)

```yaml
dependencies:
  gantt_chart: ^1.0.0
  # o
  flutter_gantt_chart: ^0.0.3
```

**Pros**: Más rápido, menos bugs
**Contras**: Menos control, customización limitada

#### Opción B: Custom Paint (Avanzado)

```dart
class GanttChartPainter extends CustomPainter {
  // Dibujar timeline, barras, dependencias con Canvas
}
```

**Pros**: Control total, altamente customizable
**Contras**: Más tiempo, complejidad de gestures

**Features**:

- Timeline horizontal con scroll
- Barras de tareas (fecha inicio → fin)
- Líneas de dependencias (flechas)
- Color por estado
- Tap → mostrar detalle
- Long press → editar
- Pinch zoom
- Botón "Calcular cronograma" → API
- Botón "Replanificar desde aquí" → API

**Widgets**:

- `GanttChartWidget` - Contenedor principal
- `GanttTimeline` - Eje de fechas
- `GanttTaskBar` - Barra de tarea
- `GanttDependencyLine` - Línea de dependencia
- `GanttZoomControls` - Botones zoom +/-

**BLoC**:

```dart
SchedulerBloc:
  - SchedulerInitial
  - SchedulerCalculating
  - SchedulerCalculated(Schedule schedule)
  - SchedulerRescheduling
  - SchedulerRescheduled(Schedule updated)
  - SchedulerError(String message)
```

**Endpoints usados**:

- `POST /api/projects/:id/schedule` - Calcular inicial
- `POST /api/projects/:id/schedule/reschedule` - Replanificar
- `GET /api/projects/:id/schedule/validate` - Validar deps
- `GET /api/projects/:id/schedule/resources` - Análisis

---

### 5. Time Tracking (Tarea 4.6) ⏱️

**Estimación**: 10 horas

**Screens**:

- `TimeTrackerScreen` - Vista principal con timer
- `TimeLogsListScreen` - Historial de timelogs
- `TaskTimeDetailBottomSheet` - Detalle + tracker

**Widgets**:

- `TimeTrackerFAB` - FloatingActionButton animado
- `TimerDisplay` - Display HH:MM:SS actualizado cada segundo
- `TimeLogCard` - Card de sesión de trabajo
- `ProgressCircularChart` - Circular con horas/estimadas

**BLoC**:

```dart
TimeTrackingBloc:
  - TimeTrackingIdle
  - TimeTrackingRunning(TimeLog active, Duration elapsed)
  - TimeTrackingStopped(TimeLog completed)
  - TimeTrackingError(String message)

Events:
  - StartTimerEvent(int taskId)
  - StopTimerEvent
  - FinishTaskEvent
  - TickEvent (cada segundo)
```

**Timer Logic**:

```dart
Timer.periodic(Duration(seconds: 1), (timer) {
  add(TickEvent());
});
```

**Endpoints usados**:

- `POST /api/tasks/:id/timelogs/start`
- `POST /api/tasks/:id/timelogs/stop`
- `POST /api/tasks/:id/finish`
- `GET /api/tasks/:id/timelogs`
- `GET /api/timelogs`

---

### 6. Workload View (Tarea 4.7) 📅

**Estimación**: 12 horas

**Screens**:

- `WorkloadScreen` - Vista principal
- `WorkloadCalendarView` - Vista tipo calendario
- `WorkloadChartView` - Gráficos con fl_chart

**Widgets**:

- `MemberWorkloadCard` - ExpansionTile por miembro
- `WorkloadGrid` - Table con horas por día
- `WorkloadColorLegend` - Leyenda de colores
- `OverloadBadge` - Badge "Overloaded"
- `DateRangePicker` - Selector de rango

**Color Coding**:

```dart
Color getWorkloadColor(double hours) {
  if (hours < 6) return Colors.green[300]!;
  if (hours <= 8) return Colors.yellow[300]!;
  return Colors.red[300]!;
}
```

**BLoC**:

```dart
WorkloadBloc:
  - WorkloadInitial
  - WorkloadLoading
  - WorkloadLoaded(ResourceAllocation allocation)
  - WorkloadDateRangeChanged
  - WorkloadError
```

**Endpoints usados**:

- `GET /api/projects/:id/schedule/resources`

---

### 7. Google Calendar (Tarea 4.8) 🔗

**Estimación**: 8 horas

**Screens**:

- `SettingsScreen` - Con sección "Integraciones"
- `CalendarEventsScreen` - Lista de eventos (opcional)

**Widgets**:

- `IntegrationCard` - Card de integración (Google, etc.)
- `ConnectionBadge` - Badge Connected/Disconnected
- `CalendarEventCard` - Card de evento de calendario

**OAuth Flow**:

```dart
// 1. Get auth URL from backend
final authUrl = await calendarDataSource.getAuthUrl();

// 2. Open WebView
await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => WebViewScreen(url: authUrl),
  ),
);

// 3. Intercept callback URL with code
// 4. Send code to backend
await calendarDataSource.saveTokens(code);
```

**BLoC**:

```dart
CalendarBloc:
  - CalendarDisconnected
  - CalendarConnecting
  - CalendarConnected(List<CalendarEvent> events)
  - CalendarError
```

**Endpoints usados**:

- `GET /api/integrations/google/connect`
- `GET /api/integrations/google/callback`
- `POST /api/integrations/google/tokens`
- `DELETE /api/integrations/google/disconnect`
- `GET /api/integrations/google/status`
- `GET /api/integrations/google/events`
- `GET /api/integrations/google/availability`

---

## 🔧 Setup Inicial (Tarea 4.1)

### 1. Configurar Cliente Dio

```dart
// lib/core/network/dio_client.dart
class DioClient {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  DioClient(this.dio, this.secureStorage) {
    dio
      ..options.baseUrl = ApiConstants.baseUrl
      ..options.connectTimeout = Duration(seconds: 30)
      ..options.receiveTimeout = Duration(seconds: 30)
      ..interceptors.addAll([
        AuthInterceptor(secureStorage),
        PrettyDioLogger(),
        ErrorInterceptor(),
      ]);
  }
}
```

### 2. Configurar Inyección de Dependencias

```dart
// lib/injection.dart
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() => getIt.init();

// Registrar manualmente
getIt.registerLazySingleton(() => Dio());
getIt.registerLazySingleton(() => FlutterSecureStorage());
getIt.registerLazySingleton(() => DioClient(getIt(), getIt()));
```

### 3. Configurar Rutas con GoRouter

```dart
// lib/routes/app_router.dart
final goRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) async {
    // Check JWT and redirect accordingly
    final hasToken = await authService.hasValidToken();
    final isAuthRoute = state.location.startsWith('/auth');

    if (!hasToken && !isAuthRoute) {
      return '/auth/login';
    }
    if (hasToken && isAuthRoute) {
      return '/projects';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: '/auth/login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/auth/register',
      builder: (context, state) => RegisterScreen(),
    ),
    GoRoute(
      path: '/projects',
      builder: (context, state) => ProjectsListScreen(),
    ),
    GoRoute(
      path: '/projects/:id',
      builder: (context, state) => ProjectDetailScreen(
        projectId: int.parse(state.params['id']!),
      ),
    ),
    // ... más rutas
  ],
);
```

### 4. Variables de Entorno

```dart
// lib/core/constants/api_constants.dart
class ApiConstants {
  // TODO: Cambiar a IP de tu backend
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android emulator
  // static const String baseUrl = 'http://localhost:3000/api'; // iOS simulator
  // static const String baseUrl = 'https://api.creapolis.com/api'; // Production

  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/auth/profile';
  static const String projects = '/projects';
  // ... más endpoints
}
```

---

## 🧪 Testing

### Estrategia de Testing

```
tests/
├── unit/              # Unit tests
│   ├── domain/       # Use cases
│   └── data/         # Repositories, models
├── widget/            # Widget tests
│   └── presentation/ # Widgets, screens
└── integration/       # Integration tests
    └── flows/        # User flows completos
```

### Ejemplo: Unit Test

```dart
// test/unit/domain/usecases/login_usecase_test.dart
void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
    useCase = LoginUseCase(mockRepo);
  });

  test('should return User when login is successful', () async {
    // Arrange
    when(mockRepo.login(any, any))
        .thenAnswer((_) async => Right(tUser));

    // Act
    final result = await useCase(LoginParams(
      email: 'test@example.com',
      password: 'password',
    ));

    // Assert
    expect(result, Right(tUser));
    verify(mockRepo.login('test@example.com', 'password'));
  });
}
```

---

## 📊 Progreso Tracker

### Fase 4: Flutter App

| Tarea     | Descripción           | Horas   | Estado           |
| --------- | --------------------- | ------- | ---------------- |
| 4.1       | Setup & Configuración | 4h      | 🔄 Parcial (70%) |
| 4.2       | Autenticación         | 8h      | ⏳ Pendiente     |
| 4.3       | Proyectos             | 8h      | ⏳ Pendiente     |
| 4.4       | Tareas                | 8h      | ⏳ Pendiente     |
| 4.5       | Gantt Chart ⭐        | 16h     | ⏳ Pendiente     |
| 4.6       | Time Tracking         | 10h     | ⏳ Pendiente     |
| 4.7       | Workload View         | 12h     | ⏳ Pendiente     |
| 4.8       | Google Calendar       | 8h      | ⏳ Pendiente     |
| **Total** |                       | **74h** | **0% completo**  |

---

## 🚀 Comandos Útiles

### Desarrollo

```bash
# Run app en modo debug
flutter run

# Run con hot reload
flutter run --hot

# Build para Android
flutter build apk --release

# Build para iOS
flutter build ios --release

# Build para Web
flutter build web

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format .

# Generate code (injectable)
flutter pub run build_runner build --delete-conflicting-outputs
```

### Dispositivos

```bash
# Ver dispositivos conectados
flutter devices

# Run en dispositivo específico
flutter run -d chrome
flutter run -d android
flutter run -d iphone
```

---

## 📚 Recursos

### Documentación

- [Flutter Docs](https://docs.flutter.dev/)
- [flutter_bloc](https://bloclibrary.dev/)
- [Dio](https://pub.dev/packages/dio)
- [GoRouter](https://pub.dev/packages/go_router)

### Packages Útiles

- [pub.dev](https://pub.dev/) - Buscar packages
- [Flutter Gems](https://fluttergems.dev/) - Curated packages

### Tutoriales

- [Clean Architecture Flutter](https://resocoder.com/flutter-clean-architecture/)
- [BLoC Pattern](https://bloclibrary.dev/#/gettingstarted)
- [Custom Painter](https://api.flutter.dev/flutter/rendering/CustomPainter-class.html)

---

## 🎯 Próximos Pasos Inmediatos

1. **Completar Setup (Tarea 4.1)**

   - [ ] Configurar DioClient con interceptores
   - [ ] Setup GetIt/Injectable
   - [ ] Configurar GoRouter completo
   - [ ] Probar conexión con backend

2. **Implementar Auth (Tarea 4.2)**

   - [ ] Crear entidades y modelos
   - [ ] Implementar use cases
   - [ ] Crear AuthBloc
   - [ ] Diseñar LoginScreen
   - [ ] Diseñar RegisterScreen
   - [ ] Probar flujo completo

3. **Iteración Rápida**
   - Implementar una feature completa antes de pasar a la siguiente
   - Testing continuo
   - Refactoring cuando sea necesario

---

**¿Listo para empezar?** 🚀 Comencemos con la Tarea 4.1!
