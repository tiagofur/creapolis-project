# 📝 Plan de Eliminación de TODOs

Este documento centraliza el plan para eliminar los TODOs del proyecto Creapolis. Se priorizan los más fáciles y útiles, y se documentan dependencias y fases de implementación.

---

## Fase 1: TODOs fáciles y útiles

### Frontend

- ~~Conectar AllProjectsScreen con ProjectsBloc para datos reales~~ ✅
  - AllProjectsScreen ahora consume directamente el estado de `ProjectBloc` sin caché local adicional (22/10/2025)
- Navegar a /projects desde MyProjectsWidget
- Navegar a project detail desde ProjectsScreen
- ~~Implementar búsqueda y filtros cuando se integre con backend~~ ✅
- ~~Obtener proyectos del BLoC~~ ✅

### Backend

- ~~Agregar soporte para nuevos campos en Project (startDate, endDate, status, managerId)~~ ✅
  - Backend (GraphQL/REST), Flutter UI/BLoC y pruebas unitarias actualizados para los cuatro campos

### Testing

- ~~Actualizar workspace_flow_test.dart con nuevos args~~ ✅
- ~~Actualizar workspace_bloc_test.dart con nuevos args~~ ✅

---

## Fase 2: TODOs dependientes o avanzados

- ~~Progress Bar en Onboarding~~ ✅
  - Barra de progreso animada con contador de página implementada (25/11/2025)
- ~~Haptic Feedback en Onboarding y botones importantes~~ ✅
  - HapticService centralizado + ConfirmationDialogs helper + integrado en login, onboarding, crear proyecto/tarea (25/11/2025)
- ~~User Picker para Custom Fields~~ ✅
  - UserPickerDialog con búsqueda, selección simple/múltiple, avatares apilados (25/11/2025)
- ~~Project Picker Dialog~~ ✅
  - ProjectPickerDialog para copiar custom fields entre proyectos, con búsqueda y cards visuales (25/11/2025)
- ~~Dark Mode para ilustraciones~~ ✅
  - AdaptiveIllustration widget con soporte theme-aware, paletas para light/dark, partículas decorativas y PredefinedIllustrations extension. Integrado en onboarding_screen, empty_workspace_screen, y state_widgets (25/11/2025)
- ~~Gestos adicionales en Onboarding~~ ✅
  - Swipe con haptic feedback, dots interactivos (tap para ir a página), botón Atrás animado, hint de swipe con animación en primera página (25/11/2025)
- ~~Accessibility~~ ✅
  - Semantic labels en onboarding (páginas, botones, indicadores, progress bar). MergeSemantics para features, ExcludeSemantics para ilustraciones decorativas. Semantics con header:true para títulos. AdaptiveIllustration con semanticLabel opcional (25/11/2025)
- ~~Tracking de páginas vistas y completion rate en Onboarding~~ ✅
  - AnalyticsService centralizado con soporte para Firebase/Mixpanel futuro. Tracking de: onboarding started, page viewed, completed/skipped con tiempo total y páginas vistas. Historial local de eventos con exportación (25/11/2025)
- ~~Feature Interest analytics~~ ✅
  - TrackableFeature widget con animación, haptic feedback y tracking de duración. AnalyticsService extendido con métodos para tracking de interés en features y engagement por página. 7 features trackeables en onboarding (25/11/2025)
- ~~Notificaciones push~~ ✅
  - Firebase Core + Messaging inicializados, FirebaseMessagingService completo, NotificationSettingsScreen conectada a backend, preferencias por tipo de notificación (25/11/2025)
- Offline mode con caché
- Sincronización en tiempo real
- Analytics tracking
- A/B testing framework
- Lazy loading de imágenes
- Pagination en listas largas
- Caché de red
- Background sync
- Optimización de bundle size
- Unit tests (70%+ coverage)
- Widget tests para componentes clave
- Integration tests E2E
- Golden tests para UI
- Actualizar tests existentes con nuevas features

---

## Fase 3: TODOs de documentación y herramientas

- Checklist de code review: marcar TODOs con fecha y responsable
- Implementar Widgetbook y documentar componentes
- Documentar proceso de integración y testing

---

## Proceso de actualización

- Revisar y actualizar este plan periódicamente
- Marcar TODOs completados y moverlos a la sección de "Resueltos"
- Documentar dependencias nuevas que surjan

---

> Última actualización: 2025-11-25
