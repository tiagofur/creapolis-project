Fase 1 – Implementaciones y Verificación

- Rutas y Acceso
  - Validación de acceso y permisos al restaurar rutas: `creapolis_app/lib/routes/app_router.dart:481-489`, `:503-511`.

- Gestión de Miembros
  - Casos de uso y BLoC para actualizar rol y remover miembro: `creapolis_app/lib/presentation/bloc/workspace_member/workspace_member_bloc.dart:92-121`, `:109-138`.
  - Badge "Tú" en lista de miembros: `creapolis_app/lib/presentation/screens/workspace/workspace_members_screen.dart:372-383`.

- Invitaciones
  - Envío de invitaciones desde la pantalla: `creapolis_app/lib/presentation/screens/workspace/workspace_invite_member_screen.dart:30-41`.
  - Listado y acciones de invitaciones pendientes: `creapolis_app/lib/presentation/screens/workspace/workspace_invitations_screen.dart`.

- Configuración de Workspace
  - Toggles operativos: `creapolis_app/lib/presentation/screens/workspace/workspace_detail_screen.dart:418-431`, `:426-435`.
  - Selector de zona horaria: `creapolis_app/lib/presentation/screens/workspace/workspace_detail_screen.dart` (función `_showTimezoneDialog`).

- Miembros de Proyecto
  - Identificación de usuario actual vía `AuthBloc`: `creapolis_app/lib/presentation/screens/projects/project_members_screen.dart:297-304`.

- Pruebas
  - Ejecutar tests: `flutter test -r expanded` en `creapolis_app`.
  - Resultados: suite pasa sin errores (exit code 0).
  - Mocks generados presentes en `test/**/**.mocks.dart`; algunas suites de `workspace_bloc_test.dart` están deshabilitadas por diseño.

- Consideraciones
  - Los endpoints remotos para invitaciones/miembros están implementados en `WorkspaceRemoteDataSource` y usados por BLoCs.
  - Cambios en Android (`applicationId` y firma) no afectan las pruebas.

Cómo Validar Rápido

- Abrir `More → Workspaces → Invitations` para ver y gestionar invitaciones.
- En un workspace, ir a "Gestionar Miembros" y verificar el badge "Tú" en tu usuario.
- En Detalle de Workspace, cambiar toggles y zona horaria; se persiste vía `UpdateWorkspace`.
