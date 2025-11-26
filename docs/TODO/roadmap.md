# 🗺️ Roadmap de Eliminación de TODOs

Este documento complementa el plan-todo.md y muestra el avance y orden recomendado para abordar los TODOs, agrupados por prioridad y dependencias.

---

## Roadmap Fase 1: TODOs fáciles y útiles

1. ~~Conectar AllProjectsScreen con ProjectsBloc para datos reales~~ ✅
   - AllProjectsScreen reutiliza `ProjectsLoaded` del bloc y mantiene filtros/búsquedas sincronizados (22/10/2025)
2. ~~Navegar a /projects desde MyProjectsWidget~~ ✅
3. ~~Navegar a project detail desde ProjectsScreen~~ ✅
4. ~~Implementar búsqueda y filtros cuando se integre con backend~~ ✅
5. ~~Obtener proyectos del BLoC~~ ✅
6. ~~Agregar soporte para nuevos campos en Project (startDate, endDate, status, managerId)~~ ✅
   - Backend (REST/GraphQL), Flutter UI/BLoC y pruebas unitarias adaptadas a startDate/endDate/status/managerId
7. ~~Actualizar workspace_flow_test.dart con nuevos args~~ ✅
8. ~~Actualizar workspace_bloc_test.dart con nuevos args~~ ✅

---

## Roadmap Fase 2: TODOs dependientes o avanzados

1. ~~Progress Bar en Onboarding~~ ✅
   - Barra de progreso animada con contador de página y TweenAnimationBuilder (25/11/2025)
2. ~~Haptic Feedback en Onboarding y botones importantes~~ ✅
   - HapticService con múltiples niveles de intensidad + ConfirmationDialogs helper (25/11/2025)
3. ~~User Picker para Custom Fields~~ ✅
   - UserPickerDialog reutilizable con búsqueda, selección simple/múltiple, avatares apilados (25/11/2025)
4. ~~Project Picker Dialog~~ ✅
   - ProjectPickerDialog para copiar custom fields entre proyectos con búsqueda y preview (25/11/2025)
5. ~~Dark Mode para ilustraciones~~ ✅
   - AdaptiveIllustration widget con IllustrationType enum, paletas theme-aware, decorative particles/icons, PredefinedIllustrations extension con 12 presets (welcome, workspace, projects, collaboration, empty, success, error, warning, noProjects, noTasks, noResults). Integrado en onboarding_screen, empty_workspace_screen y state_widgets (25/11/2025)
6. ~~Gestos adicionales en Onboarding~~ ✅
   - Swipe horizontal con haptic feedback al cambiar página, dots interactivos con tap para navegación directa, botón Atrás con animación de aparición, hint de swipe animado en primera página que desaparece después de 5s o primer swipe (25/11/2025)
7. ~~Accessibility~~ ✅
   - Semantic labels completos en onboarding_screen: páginas con label descriptivo, botones con button:true y labels, dots con selected/hint, progress bar con porcentaje, títulos con header:true. MergeSemantics en features, ExcludeSemantics en ilustraciones decorativas. AdaptiveIllustration con semanticLabel opcional y ExcludeSemantics automático si no tiene label (25/11/2025)
8. ~~Tracking de páginas vistas y completion rate en Onboarding~~ ✅
   - AnalyticsService (`lib/core/services/analytics_service.dart`) con: AnalyticsEvent enum (30+ eventos), AnalyticsEventRecord para historial local, métodos trackOnboardingStarted/PageViewed/Completed/Skipped, cálculo de completion rate y tiempo total, exportación JSON de eventos. Integrado en onboarding_screen con \_startTime, \_pagesViewed set, tracking automático de pageChanged y completion (25/11/2025)
9. ~~Feature Interest analytics~~ ✅
   - TrackableFeature widget (`lib/presentation/widgets/common/trackable_feature.dart`) con animación de presión, haptic feedback y tracking de duración. AnalyticsService extendido con trackFeatureInterest(), trackOnboardingPageEngagement(), getFeatureInterestSummary() y getOnboardingEngagementByPage(). Integrado en onboarding con 7 features trackeables en páginas 1-3 (workspaces, projects, collaboration) (25/11/2025)
10. ~~Notificaciones push~~ ✅
    - Infraestructura completa: Firebase Core + Firebase Messaging inicializados en main.dart, FirebaseMessagingService con permisos/token/handlers, PushNotificationRemoteDataSource para API, NotificationSettingsScreen mejorada con conexión real al backend, preferencias por tipo de notificación (menciones, tareas, proyectos, sistema), estado de dispositivo registrado. Backend: firebase.service.js, push-notification.service.js, rutas REST completas (25/11/2025)
11. Offline mode con caché
12. Sincronización en tiempo real
13. Analytics tracking
14. A/B testing framework
15. Lazy loading de imágenes
16. Pagination en listas largas
17. Caché de red
18. Background sync
19. Optimización de bundle size
20. Unit tests (70%+ coverage)
21. Widget tests para componentes clave
22. Integration tests E2E
23. Golden tests para UI
24. Actualizar tests existentes con nuevas features

---

## Roadmap Fase 3: Documentación y herramientas

1. Checklist de code review: marcar TODOs con fecha y responsable
2. Implementar Widgetbook y documentar componentes
3. Documentar proceso de integración y testing

---

> Última actualización: 2025-11-25
