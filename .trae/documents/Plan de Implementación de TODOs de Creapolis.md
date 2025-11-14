## Resumen
- Objetivo: Convertir los TODOs críticos en entregables, ordenados por prioridad y dependencias.
- Alcance: App Flutter (`creapolis_app`) y backend (`backend`).
- Resultado: Fases accionables con criterios de aceptación y referencias exactas.

## Fase 0: Preparación de Release
- Android Application ID y firma:
  - `creapolis_app/android/app/build.gradle.kts:23` → Definir `applicationId` único.
  - `creapolis_app/android/app/build.gradle.kts:35` → Configurar `signingConfig` para `release` con variables seguras.
- Windows build hygiene:
  - `creapolis_app/windows/flutter/CMakeLists.txt:9` → Mover lógica efímera a archivos en `ephemeral`.
- Criterios: Compila `debug` y `release`; CI pasa para Android y Windows.

## Fase 1: Acceso de Workspace y Casos de Uso
- Validaciones de acceso en navegación:
  - `creapolis_app/lib/routes/app_router.dart:484` y `:508` → Verificar permisos y acceso del usuario al workspace antes de restaurar/abrir.
- Casos de uso faltantes en tests:
  - `creapolis_app/test/presentation/bloc/workspace_bloc_test.dart:9,21` y `test/integration/workspace_flow_test.dart:9,19` → Mock de `SetActiveWorkspaceUseCase` y `GetActiveWorkspaceUseCase`.
- Gestión de miembros:
  - `creapolis_app/lib/presentation/bloc/workspace_member/workspace_member_bloc.dart:100,117` → Soportar `UpdateMemberRoleUseCase` y `RemoveMemberUseCase`.
- Invitaciones (dependiente de backend):
  - `creapolis_app/lib/presentation/screens/workspace/workspace_invite_member_screen.dart:6,33` → Implementar al existir endpoint y usecase.
- Criterios: Navegación bloquea accesos no permitidos; tests BLoC corren con mocks; eventos de miembros funcionan.

## Fase 2: Búsqueda y Filtros
- Tareas:
  - `creapolis_app/lib/presentation/screens/tasks/all_tasks_screen.dart:1298` → Implementar búsqueda.
  - `creapolis_app/lib/presentation/screens/tasks/all_tasks_screen.dart:1457` → Implementar filtros.
- Proyectos:
  - `creapolis_app/lib/presentation/screens/projects/projects_list_screen.dart:191` → Añadir búsqueda.
- Repositorio de tareas:
  - `creapolis_app/lib/features/tasks/presentation/blocs/task_bloc.dart:68` → Implementar `getAllTasks` en repository.
- Resultados de búsqueda:
  - `creapolis_app/lib/features/search/presentation/widgets/search_result_card.dart:340` → Navegar según tipo de resultado.
- Criterios: Búsqueda/filtros operativos y probados; navegación desde resultados coherente.

## Fase 3: Dashboard con Datos Reales y Navegación
- Heatmaps y progreso:
  - `creapolis_app/lib/presentation/screens/dashboard/widgets/weekly_productivity_heatmap_widget.dart:68` y `hourly_productivity_heatmap_widget.dart:68` → Recarga según modo de vista.
  - `creapolis_app/lib/presentation/screens/dashboard/widgets/weekly_progress_widget.dart:47` → Navegar a estadísticas.
- Info de workspace y actividad:
  - `creapolis_app/lib/presentation/screens/dashboard/widgets/workspace_quick_info.dart:58` → Obtener rol del usuario.
  - `creapolis_app/lib/presentation/screens/dashboard/widgets/recent_activity_list.dart:18,38,91` → Datos reales y navegación a vista completa.
- Mis tareas y proyectos:
  - `creapolis_app/lib/presentation/screens/dashboard/widgets/my_tasks_widget.dart:21,139` → Cargar tareas reales y navegar a detalle.
  - `creapolis_app/lib/presentation/screens/dashboard/widgets/my_projects_widget.dart:166,267` → Calcular progreso real.
  - `creapolis_app/lib/presentation/screens/dashboard/widgets/daily_summary_card.dart:246,256` → Navegar a todas las tareas y detalle.
- Criterios: Widgets muestran datos desde BLoC/estado; navegación funcional.

## Fase 4: Notificaciones y Mensajería
- Preferencias de notificación:
  - `creapolis_app/lib/presentation/screens/settings/notification_preferences_screen.dart:35,43` → Cargar/actualizar preferencias vía repository.
- Firebase Messaging:
  - `creapolis_app/lib/core/services/firebase_messaging_service.dart:147` → UI para notificación en foreground.
  - `creapolis_app/lib/core/services/firebase_messaging_service.dart:166,172,177` → Implementar navegación según payload.
  - `creapolis_app/lib/core/services/firebase_messaging_service.dart:226` → Manejar badges en iOS con plugin.
- Criterios: Notificaciones foreground/redirect funcionan; preferencias persistidas.

## Fase 5: Autenticación e Identidad
- Integraciones con AuthBloc (o servicio de auth):
  - `creapolis_app/lib/presentation/screens/workspace/workspace_members_screen.dart:380` → Badge "Tú" en miembro actual.
  - `creapolis_app/lib/presentation/screens/projects/project_members_screen.dart:298` → Usar `userId` del usuario actual.
  - `creapolis_app/lib/presentation/screens/more/more_screen.dart:66,83,117,132,200,207` → Navegar a pantallas de ajustes/ayuda y rellenar nombre/email reales.
- Criterios: UI refleja identidad; navegación a preferencias/tema/ayuda operativa.

## Fase 6: Creación de Tareas desde Dashboard
- `creapolis_app/lib/features/dashboard/presentation/screens/dashboard_screen.dart:155,195` y `lib/presentation/screens/main_shell/main_shell.dart:121` → Integrar `CreateTaskSheet` o pantalla dedicada cuando esté disponible.
- Criterios: Flujo de creación de tarea accesible y probado.

## Fase 7: Backend y Deuda Técnica
- Dependencias circulares:
  - `backend/src/services/task.service.js:462` → Detección y ruptura de ciclos.
- Criterios: Análisis estático sin ciclos; arquitectura estable.

## Fase 8: Internacionalización
- `creapolis_app/lib/core/constants/app_strings.dart:2` → Preparar `i18n` (arb/json) y sustituir strings.
- Criterios: App soporta al menos `es` y `en`; toggle desde settings.

## Dependencias y Riesgos
- Backend: Endpoint de invitaciones y casos de uso de miembros.
- Seguridad: Gestión de keystore/secretos para firma Android.
- UX: Definición de `CreateTaskSheet` y flujos asociados.

## Próximos Pasos
- Confirmar el plan y el orden de fases.
- Si estás de acuerdo, empezamos por Fase 0 y Fase 1 en paralelo (independientes).