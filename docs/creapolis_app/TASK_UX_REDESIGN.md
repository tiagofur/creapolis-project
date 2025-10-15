# TASK_UX_REDESIGN.md

## Rediseño UX de Pantallas de Tareas (Creapolis)

**Fecha:** 10/10/2025
**Autor:** GitHub Copilot
**Opción elegida:** OPCIÓN 1: "Status Badge Clickeable + Progressive Disclosure"

---

## 1. Análisis Actual

### Problemas Identificados

- Sobrecarga visual en TaskCard (10+ elementos siempre visibles)
- Cambio de estado requiere abrir modal de edición
- No hay acciones rápidas (quick actions)
- Descripción y detalles siempre expandidos

---

## 2. Inspiración UX

- **Linear:** Quick actions en hover, status dropdown inline
- **Asana:** Checkbox para completar, status menu inline
- **ClickUp:** Status button contextual, quick assignee change
- **Todoist:** Checkbox simple, priority flags clickeables

---

## 3. Propuesta de Rediseño

### 3.1 TaskCard (Progresive Disclosure)

#### Vista Compacta

- Status badge **clickeable** (menu contextual para cambiar estado)
- Título
- Barra de progreso
- Hover: muestra descripción, horas, asignado, acciones secundarias

#### Vista Cómoda

- Todo visible pero mejor organizado
- Secciones colapsables para detalles

#### Quick Actions

- Status badge: click → menu contextual
- Checkbox para completar rápido (opcional)
- Priority badge clickeable (opcional)

---

### 3.2 TasksListScreen

- Toggle densidad (compacta/cómoda)
- Filtros rápidos por estado/prioridad
- Quick actions toolbar

---

### 3.3 TaskDetailScreen

- Tabs: Overview | Time Tracking | Dependencies | History
- Secciones colapsables
- Quick status/priority change en header

---

## 4. Wireframes

### 4.1 TaskCard (Compacta)

```
┌─────────────────────────────────┐
│ [🔵 En Progreso ▼]             │ ← Click aquí
│ Título de la tarea             │
│ ────────────────               │
│ Barra de progreso              │
│ (Hover)                        │
│ ────────────────               │
│ Descripción (expandida)        │
│ Horas, asignado, acciones      │
└─────────────────────────────────┘
```

### 4.2 Status Badge Menu

```
┌─────────────────────────┐
│ ⚪ Planificada          │
│ ● En Progreso           │ ✓
│ ⚪ Bloqueada            │
│ ⚪ Completada           │
│ ⚪ Cancelada            │
└─────────────────────────┘
```

---

## 5. Especificaciones Técnicas

### 5.1 TaskCard

- Status badge: Widget clickeable, abre menu contextual
- Cambio de estado: Dispatch directo al Bloc, sin modal
- Animación: 200-300ms para hover y menú
- Progressive Disclosure: Solo muestra detalles en hover o tap
- Densidad: Integrar con ViewPreferencesService

### 5.2 TasksListScreen

- Toggle densidad en AppBar
- Filtros rápidos (chips/buttons)
- Quick actions toolbar (opcional)

### 5.3 TaskDetailScreen

- Tabs con TabController
- Secciones colapsables (CollapsibleSection)
- Status/priority quick change en header

---

## 6. Ventajas

- Reduce carga cognitiva
- Permite cambio de estado en 1 click
- UX consistente con pantallas de proyectos
- Personalización por usuario

---

## 7. Roadmap de Implementación

1. Crear StatusBadgeWidget clickeable
2. Integrar menú contextual para cambio de estado
3. Refactorizar TaskCard con Progressive Disclosure
4. Añadir toggle de densidad y filtros rápidos
5. Rediseñar TaskDetailScreen con tabs y quick actions
6. Documentar y testear

---

## 8. Referencias

- [PROJECT_UX_REDESIGN.md](PROJECT_UX_REDESIGN.md)
- Linear, Asana, ClickUp, Todoist UX patterns

---

## 9. Notas

- No realizar cambios en código hasta aprobación final
- Documentar feedback y ajustes antes de implementar

---

**Fin del documento**
