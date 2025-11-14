Fase 2 – Búsqueda, Filtros y Navegación

- Búsqueda en Proyectos
  - Diálogo y filtrado local por nombre/descripcion en `creapolis_app/lib/presentation/screens/projects/projects_list_screen.dart:188-194, 268-312`.

- Resultados de Búsqueda
  - Navegación contextual según tipo en `creapolis_app/lib/features/search/presentation/widgets/search_result_card.dart:339-348`.
  - Fallback de `LastRouteService` para `workspaceId` cuando falta en el resultado.

- Filtros de Tareas (BLoC)
  - Eventos: `SearchWorkspaceTasksEvent`, `FilterWorkspaceTasksByStatusEvent`, `FilterWorkspaceTasksByPriorityEvent`.
  - Estado: `WorkspaceTasksLoaded` con `searchQuery`, `currentStatusFilter`, `currentPriorityFilter` y `filteredTasks`.
  - UI enlazada en `AllTasksScreen` para despachar eventos y renderizar `filteredTasks`.

- Pruebas
  - Navegación de `SearchResultCard`: `test/presentation/widgets/search_result_card_navigation_test.dart`.
  - Filtrado en `WorkspaceTasksLoaded`: `test/presentation/bloc/workspace_tasks_loaded_filters_test.dart`.
  - Ejecución: `flutter test -r expanded` (pruebas focalizadas pasan; el full suite contiene fallos preexistentes).

Validación rápida

- En Proyectos, abrir la búsqueda y verificar que la lista se filtra.
- Desde global search, tocar resultados de tipo tarea/proyecto y verificar navegación y fallback.
- En Tareas, aplicar filtros de estado/prioridad y buscar; la lista se actualiza.
