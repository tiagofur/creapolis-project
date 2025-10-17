# 📝 Plan de Eliminación de TODOs

Este documento centraliza el plan para eliminar los TODOs del proyecto Creapolis. Se priorizan los más fáciles y útiles, y se documentan dependencias y fases de implementación.

---

## Fase 1: TODOs fáciles y útiles

### Frontend

- Conectar AllProjectsScreen con ProjectsBloc para datos reales
- Navegar a /projects desde MyProjectsWidget
- Navegar a project detail desde ProjectsScreen
- Implementar búsqueda y filtros cuando se integre con backend
- Obtener proyectos del BLoC

### Backend

- Agregar soporte para nuevos campos en Project (startDate, endDate, status, managerId)

### Testing

- Actualizar workspace_flow_test.dart con nuevos args
- Actualizar workspace_bloc_test.dart con nuevos args

---

## Fase 2: TODOs dependientes o avanzados

- Progress Bar en Onboarding
- Haptic Feedback en Onboarding y botones importantes
- Gestos adicionales en Onboarding
- Dark Mode para ilustraciones
- Accessibility: VoiceOver/TalkBack, semantic labels, keyboard navigation, high contrast mode
- Tracking de páginas vistas y completion rate en Onboarding
- Feature Interest analytics
- Notificaciones push
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

> Última actualización: 2025-10-17
