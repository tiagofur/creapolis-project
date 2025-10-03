# 🎨 Creapolis App - Guía Visual de Estructura

## 📊 Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Screens    │  │    BLoCs     │  │   Widgets    │          │
│  │  (UI Views)  │←→│ (State Mgmt) │  │ (Components) │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────────┐
│                         DOMAIN LAYER                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Entities   │  │   Use Cases  │  │ Repositories │          │
│  │  (Business)  │←→│   (Logic)    │→ │ (Interfaces) │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────────┐
│                          DATA LAYER                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │    Models    │  │ Repositories │  │ Data Sources │          │
│  │    (DTOs)    │←→│ (Implement.) │→ │ (API/Cache)  │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────────┐
│                      EXTERNAL SERVICES                          │
│              API REST  │  Google Calendar  │  Storage           │
└─────────────────────────────────────────────────────────────────┘
```

## 🗂️ Estructura de Carpetas Detallada

### 📁 core/ - Núcleo de la Aplicación

```
core/
├── constants/
│   ├── api_constants.dart      # 🌐 URLs, endpoints, timeouts
│   ├── storage_keys.dart       # 🔑 Claves de almacenamiento
│   └── app_strings.dart        # 📝 Textos de la app (i18n ready)
│
├── theme/
│   ├── app_theme.dart          # 🎨 Tema claro/oscuro completo
│   └── app_dimensions.dart     # 📏 Espaciado, fuentes, bordes
│
├── utils/
│   ├── validators.dart         # ✅ Validaciones de formularios
│   └── date_utils.dart         # 📅 Utilidades de fecha/hora
│
├── errors/
│   ├── failures.dart           # ❌ Clases de fallo (domain)
│   └── exceptions.dart         # 💥 Excepciones (data layer)
│
└── network/
    └── (próximo: dio_client.dart)  # 🌐 Cliente HTTP
```

### 📁 domain/ - Lógica de Negocio

```
domain/
├── entities/                   # 🎯 Entidades puras (sin dependencias)
│   ├── user.dart              # 👤 Usuario (con roles)
│   ├── project.dart           # 📊 Proyecto
│   ├── task.dart              # ✓ Tarea (con estados)
│   ├── dependency.dart        # 🔗 Dependencia entre tareas
│   ├── time_log.dart          # ⏱️ Registro de tiempo
│   └── auth_response.dart     # 🔐 Respuesta de auth
│
├── repositories/               # 📝 Interfaces de repositorios
│   └── (próximo: interfaces)
│
└── usecases/                   # 🎮 Casos de uso
    ├── auth/
    │   └── (próximo: login, register, logout)
    ├── projects/
    │   └── (próximo: CRUD operations)
    └── tasks/
        └── (próximo: CRUD + time tracking)
```

### 📁 data/ - Manejo de Datos

```
data/
├── models/                     # 📦 DTOs (toJson/fromJson)
│   └── (próximo: user_model.dart, etc.)
│
├── repositories/               # 🔧 Implementaciones
│   └── (próximo: implementar interfaces)
│
└── datasources/
    ├── remote/                # 🌐 API REST
    │   └── (próximo: auth_api.dart, etc.)
    └── local/                 # 💾 Cache/Storage
        └── (próximo: auth_local.dart, etc.)
```

### 📁 presentation/ - Interfaz de Usuario

```
presentation/
├── shared/
│   └── widgets/               # 🧩 Componentes reutilizables
│       ├── primary_button.dart       # 🔵 Botón principal
│       ├── secondary_button.dart     # ⚪ Botón secundario
│       ├── custom_card.dart          # 📄 Card
│       ├── loading_widget.dart       # ⏳ Loading
│       ├── error_widget.dart         # ❌ Error
│       └── empty_widget.dart         # 📭 Vacío
│
├── screens/                   # 📱 Pantallas organizadas por feature
│   ├── auth/
│   │   ├── login/
│   │   │   ├── login_screen.dart
│   │   │   └── widgets/      # Widgets específicos de login
│   │   │       └── login_form.dart
│   │   └── register/
│   │       ├── register_screen.dart
│   │       └── widgets/      # Widgets específicos de registro
│   │           └── register_form.dart
│   │
│   ├── projects/
│   │   ├── list/
│   │   │   ├── projects_screen.dart
│   │   │   └── widgets/
│   │   │       ├── project_card.dart
│   │   │       └── create_project_dialog.dart
│   │   └── detail/
│   │       ├── project_detail_screen.dart
│   │       └── widgets/
│   │           ├── project_info.dart
│   │           ├── members_list.dart
│   │           └── tasks_gantt.dart
│   │
│   └── tasks/
│       ├── tasks_screen.dart
│       └── widgets/
│           ├── task_card.dart
│           ├── task_detail.dart
│           └── time_tracker.dart
│
└── blocs/                     # 🧠 State Management
    ├── auth/
    │   ├── auth_bloc.dart
    │   ├── auth_event.dart
    │   └── auth_state.dart
    ├── projects/
    │   ├── projects_bloc.dart
    │   ├── projects_event.dart
    │   └── projects_state.dart
    └── tasks/
        ├── tasks_bloc.dart
        ├── tasks_event.dart
        └── tasks_state.dart
```

## 🎯 Flujo de Datos

### Ejemplo: Login de Usuario

```
┌─────────────────┐
│  LoginScreen    │ (User taps login button)
└────────┬────────┘
         │ 1. Add LoginEvent
         ↓
┌─────────────────┐
│   AuthBloc      │ (Receives event)
└────────┬────────┘
         │ 2. Call use case
         ↓
┌─────────────────┐
│ LoginUseCase    │ (Business logic)
└────────┬────────┘
         │ 3. Call repository
         ↓
┌─────────────────┐
│AuthRepository   │ (Interface)
└────────┬────────┘
         │ 4. Implementation
         ↓
┌─────────────────┐
│AuthRepositoryImp│
└────────┬────────┘
         │ 5. Get data
         ↓
┌─────────────────┐
│AuthRemoteSource │ (Dio HTTP call)
└────────┬────────┘
         │ 6. Parse response
         ↓
┌─────────────────┐
│  UserModel      │ (DTO)
└────────┬────────┘
         │ 7. Map to entity
         ↓
┌─────────────────┐
│  User Entity    │
└────────┬────────┘
         │ 8. Return Either<Failure, User>
         ↓
┌─────────────────┐
│   AuthBloc      │ (Emit new state)
└────────┬────────┘
         │ 9. State change
         ↓
┌─────────────────┐
│  LoginScreen    │ (UI updates)
└─────────────────┘
```

## 🎨 Widgets Organizados por Tipo

### 🔵 Botones

```dart
PrimaryButton(          // Acción principal
  text: 'Iniciar Sesión',
  onPressed: () {},
  isLoading: true,      // Muestra loading
  icon: Icons.login,    // Icono opcional
  isFullWidth: true,    // Ancho completo
)

SecondaryButton(        // Acción secundaria
  text: 'Cancelar',
  onPressed: () {},
)
```

### 📄 Contenedores

```dart
CustomCard(             // Card personalizado
  onTap: () {},         // Tapeable opcional
  child: Text('Content'),
)
```

### 📊 Estados

```dart
LoadingWidget()         // Cuando carga
ErrorWidget(            // Cuando hay error
  message: 'Error!',
  onRetry: () {},       // Botón de reintentar
)
EmptyWidget()           // Cuando no hay datos
```

## 📦 Dependencias por Categoría

### 🧠 State Management

- `flutter_bloc` - BLoC pattern

### 🌐 Networking

- `dio` - Cliente HTTP
- `pretty_dio_logger` - Logs bonitos

### 💾 Storage

- `shared_preferences` - Storage simple
- `flutter_secure_storage` - Storage seguro

### 🧩 Dependency Injection

- `get_it` - Service locator
- `injectable` - Code generation

### 🗺️ Navigation

- `go_router` - Routing declarativo

### 🛠️ Utils

- `equatable` - Value equality
- `dartz` - Either<L,R>
- `logger` - Logging
- `intl` - Internacionalización

## 🎯 Convenciones de Nomenclatura

```dart
// Archivos
login_screen.dart       // snake_case

// Clases
class LoginScreen       // PascalCase

// Variables y funciones
void onPressed()        // camelCase
String userName         // camelCase

// Constantes
static const String apiUrl    // camelCase con static const

// Privados
class _LoginState       // Prefijo _
void _handleLogin()     // Prefijo _

// Widgets específicos
widgets/
  login_form.dart       // Específico de login
shared/widgets/
  primary_button.dart   // Compartido
```

## ✅ Checklist de Calidad

Antes de hacer commit, verifica:

```
□ Código formateado (flutter format .)
□ Sin errores de análisis (flutter analyze)
□ Tests pasan (flutter test)
□ Nombres descriptivos
□ Funciones < 50 líneas
□ Widgets pequeños y reutilizables
□ Documentación de funciones complejas
□ Manejo de errores adecuado
```

---

**Creapolis** - Código limpio, organizado y escalable 🚀
