## Objetivo
- Eliminar y resolver los TODO/FIXME existentes para dejar únicamente funciones nuevas por implementar.

## Inventario de TODO/FIXME
- Backend (IA):
  - `backend/src/services/ai/categorizationService.js:8` y `:203` — Integración con TensorFlow.js / aprendizaje real.
- Flutter (Windows build):
  - `creapolis_app/windows/flutter/CMakeLists.txt:9` — Nota técnica de Flutter (no funcionalidad propia).
- Tests (Workspace):
  - `creapolis_app/test/presentation/bloc/workspace_bloc_test.dart:16,28` — Añadir mocks de `SetActiveWorkspaceUseCase` y `GetActiveWorkspaceUseCase` y reactivar pruebas.
  - `creapolis_app/test/integration/workspace_flow_test.dart:16,26` — Igual que arriba, para integración.
- Dashboard (Crear tarea):
  - `creapolis_app/lib/features/dashboard/presentation/screens/dashboard_screen.dart:155,195` — Conectar `CreateTaskBottomSheet` en “Nueva Tarea”.
- Dashboard (Actividad reciente):
  - `creapolis_app/lib/presentation/screens/dashboard/widgets/recent_activity_list.dart:109` — Reemplazar mock por datos reales.
- i18n:
  - `creapolis_app/lib/core/constants/app_strings.dart:2` — Migrar a `AppLocalizations` (ya presente en `pubspec.yaml` y `lib/l10n/*`).
- Invitación de miembros:
  - `creapolis_app/lib/presentation/screens/workspace/workspace_invite_member_screen.dart:10` — Backend ya implementado; limpiar TODO y robustecer UX.

## Prioridades y acciones
### 1) Dashboard: Crear Tarea
- Reemplazar SnackBars por `CreateTaskBottomSheet` en:
  - `dashboard_screen.dart:155` y `:195`.
- Reutilizar el flujo probado de selección de proyecto y sheet de `MainShell` (`lib/presentation/screens/main_shell/main_shell.dart:115–155, 184–232`).
- Validar workspace activo con `WorkspaceBloc` y cargar proyectos si faltan.

### 2) Actividad Reciente sin mocks
- Asegurar carga de tareas del workspace activo:
  - Despachar `LoadWorkspaceTasksEvent` al cambiar `WorkspaceContext` en Dashboard (`dashboard_screen.dart:47–58`).
- En `RecentActivityList`, usar estado de `TaskBloc` y mostrar “sin actividad” cuando `WorkspaceTasksLoaded.tasks` esté vacío; eliminar `_getMockActivities()` de `:109–134`.

### 3) Migración a i18n
- Reemplazar usos de `AppStrings` por `AppLocalizations` en:
  - `lib/main.dart` (fallback ya aplicado en `:153–156`).
  - `presentation/shared/widgets/error_widget.dart`, `empty_widget.dart` y `core/utils/validators.dart`.
- Añadir claves faltantes a `lib/l10n/app_localizations_en.dart` y `app_localizations_es.dart` si son necesarias.
- Mantener fallback seguro con texto por defecto cuando `AppLocalizations.of(context)` sea null.

### 4) Invitaciones de miembros
- Backend disponible en `WorkspaceRemoteDataSource.createInvitation` (`:396–445`).
- El flujo actual en `WorkspaceBloc` `InviteMember` (`lib/features/workspace/presentation/bloc/workspace_bloc.dart:447–499`) es funcional; eliminar el TODO y mejorar feedback de error/success en `WorkspaceInviteMemberScreen`.

### 5) Tests de Workspace
- Reactivar tests:
  - Añadir a `@GenerateMocks` y configurar `WorkspaceBloc` con todas dependencias mock.
  - Generar mocks: `dart run build_runner build`.
  - Descomentar bloques y asegurar expectativas con `bloc_test`.

### 6) Backend IA (postergado corto plazo)
- Definir interfaz `MLCategorizer` y adaptador (p. ej. TensorFlow.js o API externa).
- Mantener el motor por reglas actual y preparar puntos de inyección en `categorizationService`.

## Verificación
- Ejecutar la app y probar:
  - “Nueva Tarea” desde Dashboard y FAB del `MainShell` muestra `CreateTaskBottomSheet` y crea tareas correctamente.
  - Actividad reciente refleja tareas reales y estados de tiempo.
- Ejecutar tests:
  - Unit tests de `WorkspaceBloc` y pruebas de integración del flujo de workspaces.
- Revisar que no se rompan cadenas; validación visual con locales `es` y `en`.

## Entregables
- Dashboard conectado a `CreateTaskBottomSheet` sin SnackBars temporales.
- Lista de Actividad Reciente sin mocks.
- Migración progresiva de `AppStrings` a `AppLocalizations`.
- Pantalla de invitación estable con feedback correcto.
- Suite de tests de Workspace reactivada y pasando.

¿Confirmo y comienzo con estas acciones en el orden propuesto?