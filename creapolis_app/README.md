# Creapolis App - Flutter

Sistema de gestión de proyectos con planificación automática, sistema de workspaces multi-usuario e integración con Google Calendar.

## 🎯 Estado del Proyecto

**Progreso General:** 76% Completado (67/88 tareas) 🚀

### Fases Implementadas:
- ✅ **Fase 1:** Backend API (100%)
- ✅ **Fase 2:** Domain Layer (100%)
- ✅ **Fase 3:** Data Layer (100%)
- ✅ **Fase 4:** Presentation Layer (100%)
- ✅ **Fase 5:** Integration (100%)
- 🔄 **Fase 6:** Testing (25% - En progreso)
- ⏳ **Fase 7:** Polish & UX (0%)

## ✨ Características Principales

### 🏢 Sistema de Workspaces
- **Multi-usuario con roles**: Owner, Admin, Member, Guest
- **Gestión de equipos**: Invitaciones, permisos granulares
- **Control de acceso**: Permisos por rol en toda la aplicación
- **Configuración avanzada**: Settings por workspace

### 📊 Gestión de Proyectos
- Creación y seguimiento de proyectos
- Filtrado automático por workspace activo
- Asignación de tareas y responsables
- Integración con workspaces

### ✅ Sistema de Tareas
- Gestión completa de tareas
- Time tracking integrado
- Control de permisos por rol
- Estados y prioridades

### ⏱️ Time Tracking
- Seguimiento de tiempo por tarea
- Restricciones basadas en permisos
- Estadísticas y reportes

### � UI/UX
- Material Design 3
- Tema oscuro/claro
- Navegación global con MainDrawer
- WorkspaceSwitcher en todas las pantallas
- Animaciones fluidas

## �🏗️ Arquitectura del Proyecto

El proyecto sigue **Clean Architecture** con una estructura modular y escalable:

```
lib/
├── core/                          # Núcleo compartido de la aplicación
│   ├── constants/                 # Constantes (API, Storage, Strings)
│   ├── theme/                     # Tema y estilos
│   ├── router/                    # Configuración de navegación (GoRouter)
│   ├── utils/                     # Utilidades compartidas
│   ├── errors/                    # Manejo de errores (Failures)
│   └── network/                   # Configuración de red (Dio)
├── domain/                        # Capa de dominio (entidades y casos de uso)
│   ├── entities/                  # Entidades de negocio
│   │   ├── workspace.dart         # ✨ Workspace con roles y settings
│   │   ├── workspace_member.dart  # ✨ Miembros del workspace
│   │   ├── workspace_invitation.dart # ✨ Sistema de invitaciones
│   │   ├── project.dart
│   │   ├── task.dart
│   │   └── time_log.dart
│   ├── repositories/              # Interfaces de repositorios
│   │   ├── workspace_repository.dart # ✨
│   │   ├── project_repository.dart
│   │   └── task_repository.dart
│   └── usecases/                  # Casos de uso
│       └── workspace/             # ✨ 6 use cases de workspace
│           ├── get_user_workspaces.dart
│           ├── create_workspace.dart
│           ├── get_workspace_members.dart
│           ├── accept_invitation.dart
│           └── ...
├── data/                          # Capa de datos
│   ├── models/                    # Modelos de datos (DTOs)
│   │   ├── workspace_model.dart   # ✨
│   │   ├── workspace_member_model.dart # ✨
│   │   └── ...
│   ├── repositories/              # Implementación de repositorios
│   │   └── workspace_repository_impl.dart # ✨
│   └── datasources/               # Fuentes de datos (remote/local)
│       └── workspace_remote_data_source.dart # ✨
├── presentation/                  # Capa de presentación
│   ├── bloc/                      # State Management (BLoC)
│   │   ├── workspace/             # ✨ WorkspaceBloc
│   │   ├── workspace_member/      # ✨ WorkspaceMemberBloc
│   │   ├── workspace_invitation/  # ✨ WorkspaceInvitationBloc
│   │   └── ...
│   ├── providers/                 # Providers globales
│   │   └── workspace_context.dart # ✨ Estado global de workspace
│   ├── screens/                   # Pantallas organizadas por feature
│   │   ├── workspace/             # ✨ 7 pantallas de workspace
│   │   │   ├── workspace_list_screen.dart
│   │   │   ├── workspace_detail_screen.dart
│   │   │   ├── workspace_members_screen.dart
│   │   │   └── ...
│   │   ├── projects/
│   │   ├── tasks/                 # ✨ Integrado con workspaces
│   │   └── ...
│   └── widgets/                   # Widgets reutilizables
│       ├── workspace/             # ✨ Widgets de workspace
│       │   ├── workspace_card.dart
│       │   ├── member_card.dart
│       │   ├── workspace_switcher.dart
│       │   └── ...
│       ├── main_drawer.dart       # ✨ Navegación global
│       └── ...
└── injection.dart                 # ✨ Inyección de dependencias (GetIt + Injectable)
```

## 🧪 Testing

### Tests Implementados (13 tests ✅)

```bash
# Ejecutar todos los tests
flutter test

# Ejecutar tests específicos
flutter test test/domain/usecases/workspace/
```

**Cobertura Actual:**
- ✅ GetUserWorkspacesUseCase (4 tests)
- ✅ CreateWorkspaceUseCase (4 tests)
- ✅ GetWorkspaceMembersUseCase (5 tests)
- ⏳ Repository tests (pendiente)
- ⏳ BLoC tests (pendiente)
- ⏳ Widget tests (pendiente)

## 📋 Principios de Organización

### 1. **Clean Architecture**
- **Domain**: Lógica de negocio pura (entities + use cases)
- **Data**: Manejo de datos y APIs (models + repositories + datasources)
- **Presentation**: UI y gestión de estado (BLoC + screens + widgets)

### 2. **BLoC Pattern**
- Estado predecible con eventos y estados inmutables
- Separación clara entre lógica de negocio y UI
- Testeable con bloc_test

### 3. **Dependency Injection**
- GetIt + Injectable para DI automática
- Fácil de testear con mocks
- Desacoplamiento de dependencias

### 4. **Error Handling**
- Either<Failure, Success> pattern con Dartz
- Tipos de Failure: ServerFailure, NetworkFailure, ValidationFailure, NotFoundFailure
- Manejo robusto de errores en toda la app

## 🚀 Ejecutar la Aplicación

### Desarrollo

```bash
cd creapolis_app
flutter pub get
flutter run
```

### Build Runner (para mocks)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Testing

```bash
# Todos los tests
flutter test

# Tests con cobertura
flutter test --coverage

# Tests específicos
flutter test test/domain/usecases/workspace/get_user_workspaces_test.dart
```

## 📦 Dependencias Principales

```yaml
dependencies:
  # Core
  flutter:
    sdk: flutter
  
  # State Management
  flutter_bloc: ^8.1.6
  provider: ^6.1.2
  equatable: ^2.0.5
  
  # Dependency Injection
  get_it: ^8.0.2
  injectable: ^2.5.0
  
  # Networking
  dio: ^5.7.0
  
  # Storage
  shared_preferences: ^2.3.3
  flutter_secure_storage: ^9.2.2
  
  # Navigation
  go_router: ^14.6.2
  
  # Functional Programming
  dartz: ^0.10.1

dev_dependencies:
  # Testing
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  bloc_test: ^9.1.7    # ✨ Nuevo
  mocktail: ^1.0.4     # ✨ Nuevo
  
  # Code Generation
  build_runner: ^2.4.13
  injectable_generator: ^2.6.2
```

## 🎨 Sistema de Permisos

### Roles de Workspace

| Rol | Crear | Editar | Eliminar | Gestionar Miembros | Time Tracking |
|-----|-------|--------|----------|-------------------|---------------|
| **Owner** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Admin** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Member** | ✅ | ✅ | ❌ | ❌ | ✅ |
| **Guest** | ❌ | ❌ | ❌ | ❌ | ❌ |

### Verificación de Permisos

```dart
// En UI con Consumer
Consumer<WorkspaceContext>(
  builder: (context, workspaceContext, child) {
    if (!workspaceContext.canCreateProjects) {
      return DisabledButton();
    }
    return EnabledButton();
  },
)

// En lógica
final context = context.read<WorkspaceContext>();
if (context.canEditTasks) {
  // Proceder con edición
}
```

## 📱 Navegación

### MainDrawer Global

El drawer principal se adapta según el rol del usuario:

- **Header**: Workspace activo + rol badge
- **Navegación**: Dashboard, Projects, Tasks, Time Tracking, Calendar
- **Workspace**: Members, Invite, Settings (según permisos)
- **Settings**: Preferences, Help, About
- **Footer**: Logout con confirmación

### Rutas de Workspace

```dart
/workspaces                    # Lista de workspaces
/workspaces/create             # Crear workspace
/workspaces/:id                # Detalle de workspace
/workspaces/:id/members        # Gestión de miembros
/workspaces/:id/settings       # Configuración
/invitations                   # Invitaciones pendientes
```

## 📚 Documentación

- 📋 [WORKSPACE_MASTER_PLAN.md](../WORKSPACE_MASTER_PLAN.md) - Plan completo del sistema
- 📊 [WORKSPACE_PROGRESS.md](../WORKSPACE_PROGRESS.md) - Progreso detallado
- ✅ [FASE_5_COMPLETADA.md](FASE_5_COMPLETADA.md) - Integración completada
- 🧪 [FASE_6_PROGRESO.md](FASE_6_PROGRESO.md) - Estado de testing
- 📈 [RESUMEN_EJECUTIVO_WORKSPACE.md](../RESUMEN_EJECUTIVO_WORKSPACE.md) - Resumen ejecutivo
- 🏗️ [ARCHITECTURE.md](ARCHITECTURE.md) - Documentación de arquitectura

## 🤝 Contribución

Este proyecto sigue los estándares de Flutter y Clean Architecture. Para contribuir:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

### Estándares de Código

- ✅ Clean Architecture con separación de capas
- ✅ BLoC pattern para state management
- ✅ Tests unitarios para use cases y repositorios
- ✅ Widget tests para componentes críticos
- ✅ Comentarios descriptivos en código complejo
- ✅ Nombres descriptivos y semánticos

## 📱 Plataformas Soportadas

✅ Android | ✅ iOS | ✅ Web | ✅ Windows | ✅ macOS | ✅ Linux

## 📄 Licencia

[Especificar licencia aquí]

---

**Creapolis** - Sistema de gestión de proyectos con workspaces colaborativos 🚀  
*Última actualización: Octubre 8, 2025*
