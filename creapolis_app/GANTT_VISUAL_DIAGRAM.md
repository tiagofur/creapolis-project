# 📊 Diagrama Visual: Gantt Chart Dinámico

## 🎯 Arquitectura de Componentes

```
┌─────────────────────────────────────────────────────────────────┐
│                    GanttChartScreen                              │
│  ┌────────────────────────────────────────────────────────┐     │
│  │ AppBar                                                  │     │
│  │  [← Back] Gantt Chart    [👥][📥][🔄][🧮]            │     │
│  └────────────────────────────────────────────────────────┘     │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ TaskBloc (BlocConsumer)                                 │    │
│  │  • LoadTasksByProjectEvent                              │    │
│  │  • UpdateTaskEvent (drag & drop)                        │    │
│  │  • CalculateScheduleEvent                               │    │
│  │  • RescheduleProjectEvent                               │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                   │
│  ┌──────────────────┐        ┌───────────────────────────┐     │
│  │ RepaintBoundary  │        │  GanttResourcePanel       │     │
│  │   (for export)   │        │                           │     │
│  │                  │        │  ┌─────────────────────┐  │     │
│  │ ┌──────────────┐ │   OR   │  │ 👤 Juan Pérez       │  │     │
│  │ │ GanttChart   │ │        │  │ 5 tareas · 40h      │  │     │
│  │ │   Widget     │ │        │  │ ████████░░░░        │  │     │
│  │ └──────────────┘ │        │  └─────────────────────┘  │     │
│  └──────────────────┘        │  ┌─────────────────────┐  │     │
│                               │  │ 👤 María García     │  │     │
│                               │  │ 3 tareas · 24h      │  │     │
│                               │  │ ██████████░░░░      │  │     │
│                               │  └─────────────────────┘  │     │
│                               └───────────────────────────┘     │
└─────────────────────────────────────────────────────────────────┘
```

## 🏗️ Estructura de GanttChartWidget

```
GanttChartWidget
├── Column
│   ├── Controls (Zoom & Legend)
│   │   ├── IconButton (zoom out)
│   │   ├── IconButton (zoom in)
│   │   ├── Text (zoom level)
│   │   └── Legend (status colors)
│   │
│   ├── Header Row
│   │   ├── Label Column (fixed, 200px)
│   │   │   └── "Tareas"
│   │   └── Timeline Header (scrollable)
│   │       └── GanttTimelineHeader
│   │           ├── Month Row
│   │           └── Day Row
│   │
│   └── Chart Row (Expanded)
│       ├── Task Labels (fixed, 200px)
│       │   └── ListView
│       │       └── TaskLabel (name + assignee)
│       │
│       └── Chart Canvas (scrollable)
│           └── GestureDetector
│               ├── onScaleUpdate (zoom)
│               ├── onTapUp (select)
│               ├── onLongPressStart (options)
│               ├── onPanStart (drag start) ★ NEW
│               ├── onPanUpdate (dragging)  ★ NEW
│               └── onPanEnd (drag end)     ★ NEW
│                   └── CustomPaint
│                       └── GanttChartPainter
│                           ├── _drawDependencies()
│                           └── _drawTaskBars()
```

## 🎨 GanttChartPainter - Renderizado

```
Canvas Rendering Order:
┌─────────────────────────────────────────────┐
│ 1. Background (implicit)                    │
│                                             │
│ 2. Dependency Lines                         │
│    ┌──────────┐                             │
│    │ Task A   │────────┐                    │
│    └──────────┘        │                    │
│                        ↓                    │
│                   ┌──────────┐              │
│                   │ Task B   │              │
│                   └──────────┘              │
│                                             │
│ 3. Task Bars (for each task)                │
│    ├── Shadow (if selected/dragging) ★ NEW │
│    ├── Main bar (with color by status)     │
│    ├── Progress overlay                     │
│    ├── Title text                           │
│    ├── Priority indicator                   │
│    └── Border (if selected)                 │
└─────────────────────────────────────────────┘
```

## 🖱️ Flujo de Drag & Drop

```
User Action          State Changes               Visual Feedback
─────────────────────────────────────────────────────────────────
1. Touch bar        _draggingTaskId = task.id   Normal appearance
   │                _dragStartPosition = pos
   │                _dragOriginalStartDate = date
   │
2. Move finger      setState() triggered        • Opacity: 70%
   │                                            • Shadow: Stronger
   │                                            • Cursor: Grabbing
   │
3. Release finger   _handleDragEnd()            Show confirmation dialog
   │                                            ┌─────────────────┐
   │                                            │ Actualizar?     │
   │                                            │ [Cancel][OK]    │
   │                                            └─────────────────┘
   │
4. Confirm          UpdateTaskEvent             Loading...
   │                ↓
   │                TaskBloc
   │                ↓
   │                TaskRepository.updateTask()
   │                ↓
   │                Backend API
   │                ↓
5. Success          LoadTasksByProjectEvent     Reload complete view
                    ↓
                    TasksLoaded state
                    ↓
                    Rebuild widget
```

## 👥 Panel de Recursos - Estructura

```
GanttResourcePanel
├── _calculateWorkloadByAssignee()
│   └── Map<String, List<Task>>
│       ├── "Juan Pérez" → [Task1, Task2, Task3]
│       ├── "María García" → [Task4, Task5]
│       └── "Pedro López" → [Task6]
│
└── ListView.builder
    └── For each assignee:
        └── _buildAssigneeCard()
            ├── ExpansionTile
            │   ├── leading: CircleAvatar (initials)
            │   ├── title: Name
            │   ├── subtitle:
            │   │   ├── "X tareas · Yh"
            │   │   └── _buildWorkloadBar()
            │   │       ├── Completed (green)
            │   │       ├── InProgress (blue)
            │   │       └── Planned (grey)
            │   │
            │   └── children: (expandable)
            │       └── For each task:
            │           └── _buildTaskItem()
            │               ├── Status dot
            │               ├── Title
            │               ├── Date range
            │               └── Hours
```

## 📤 Exportación - Flujo

```
User clicks Export button
│
├─ Bottom Sheet appears
│  ├─ [🖼️ Export as Image]
│  ├─ [📄 Export as PDF]
│  └─ [📤 Share]
│
└─ User selects option
   │
   ├─ Export as Image:
   │  ├── Show loading dialog
   │  ├── GanttExportService.saveAsImage()
   │  │   ├── Get RenderRepaintBoundary from _ganttKey
   │  │   ├── boundary.toImage(pixelRatio: 3.0)
   │  │   ├── Convert to PNG bytes
   │  │   ├── Save to app documents directory
   │  │   └── Return file path
   │  ├── Hide loading
   │  └── Show success snackbar with path
   │
   ├─ Export as PDF:
   │  ├── Show loading dialog
   │  ├── GanttExportService.exportAsPDF()
   │  │   └── (Currently calls exportAsImage)
   │  ├── Hide loading
   │  └── Show success message
   │
   └─ Share:
      ├── Show loading dialog
      ├── GanttExportService.exportAsImage()
      │   ├── Capture as PNG
      │   ├── Save to temp directory
      │   └── Share.shareXFiles([XFile(path)])
      └── Native share sheet opens
```

## 🔄 Integración con Backend

```
Flutter App                 Backend API
─────────────────────────────────────────────────────────

GanttChartScreen
├── Load Tasks
│   └── GET /api/projects/:id/tasks
│       └── Returns: List<Task> with dependencies
│
├── Update Task Dates (Drag & Drop)
│   └── PUT /api/tasks/:id
│       Body: { startDate, endDate }
│       └── Returns: Updated Task
│
├── Calculate Schedule
│   └── POST /api/projects/:id/schedule
│       Body: { options }
│       └── Returns: { tasks: [...], message }
│           └── Uses topological sort algorithm
│           └── Considers dependencies
│           └── Applies working hours (9-5, Mon-Fri)
│
└── Reschedule from Task
    └── POST /api/projects/:id/schedule/reschedule
        Body: { triggerTaskId, options }
        └── Returns: { tasks: [...], message }
            └── Recalculates dependent tasks only
```

## 📊 Estado del BLoC - Ciclo de Vida

```
TaskBloc State Machine
─────────────────────────────────────────

[TaskInitial]
     ↓ LoadTasksByProjectEvent
[TaskLoading]
     ↓ Success
[TasksLoaded] ←─────────────────┐
     ↓                           │
     ├─ UpdateTaskEvent          │
     │  (drag & drop dates)      │
     ↓                           │
[TaskUpdating]                   │
     ↓ Success                   │
[TaskUpdated] ──────────────────┤
     ↓ Auto-reload               │
[TaskLoading] ──────────────────┘
     
     
Special States:
─────────────────────

[TaskScheduleCalculating]
     ↓
[TaskScheduleCalculated]
     with tasks property
     
[TaskRescheduling]
     ↓
[TaskRescheduled]
     with tasks property
     
[TaskError]
     with message property
```

## 🎯 Interacciones de Usuario

```
┌────────────────────────────────────────────────────────┐
│                 Gantt Chart View                       │
│                                                        │
│  User Action              Result                      │
│  ─────────────────────────────────────────────────    │
│                                                        │
│  1. Tap on task bar  →  • Select task                 │
│                         • Highlight with border       │
│                         • Show details dialog         │
│                                                        │
│  2. Long press       →  • Bottom sheet with:          │
│                           - Edit Task                 │
│                           - Reschedule                │
│                           - View Details              │
│                                                        │
│  3. Pinch out       →   • Zoom in                     │
│                         • Increase dayWidth           │
│                         • More detail per day         │
│                                                        │
│  4. Pinch in        →   • Zoom out                    │
│                         • Decrease dayWidth           │
│                         • See more days               │
│                                                        │
│  5. Drag task bar   →   • Visual feedback             │
│     horizontally        • Confirmation dialog         │
│                         • Update dates                │
│                                                        │
│  6. Click 👥        →   • Switch to Resources view    │
│                         • Show workload by person     │
│                                                        │
│  7. Click 📥        →   • Export options menu          │
│                         • Image/PDF/Share             │
│                                                        │
│  8. Click 🧮        →   • Calculate schedule           │
│                         • Auto-optimize dates         │
└────────────────────────────────────────────────────────┘
```

## 🎨 Código de Colores y Visualización

```
Task Bar Appearance:
─────────────────────────────────────────────

Normal State:
┌─────────────────────┐
│ [████████████] 60%  │ ← Progress bar overlay
│ Task Title      🔴  │ ← Priority indicator (high/critical)
└─────────────────────┘
     ↑                 ↑
  Color by status   Rounded corners

Selected State:
┌─────────────────────┐
│▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│ ← Black border (2px)
│█[████████████] 60% █│
│█Task Title      🔴 █│
│▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│
└─────────────────────┘
  ↑
Shadow effect

Dragging State:
┌─────────────────────┐
░░░░░░░░░░░░░░░░░░░░░░░ ← Stronger shadow
░[████████████] 60%  ░ ← 70% opacity
░Task Title      🔴  ░
░░░░░░░░░░░░░░░░░░░░░░░
└─────────────────────┘


Dependency Lines:
─────────────────────────────────────────

Task A ────────┐
               │
               ↓ Arrow
        Task B (successor)

Style:
• Color: Grey (#9E9E9E)
• Width: 2px
• Pattern: Solid line with arrow
• Path: Horizontal → Vertical → Horizontal
```

## 📏 Dimensiones y Métricas

```
Layout Metrics:
─────────────────────────────────────────

Fixed:
• Task Label Width:    200px
• Task Height:         40px
• Task Spacing:        10px
• Timeline Height:     50px
• Controls Height:     ~56px

Variable:
• Day Width:           20-100px (zoom level)
  - Min (20px):        Very zoomed out
  - Default (40px):    Normal view
  - Max (100px):       Very zoomed in

• Chart Width:         totalDays × dayWidth
• Chart Height:        tasks.length × (taskHeight + taskSpacing)

Scrollable Areas:
• Horizontal:          Chart + Timeline
• Vertical:            Task Labels + Chart

Fixed Areas:
• Task Labels Column:  Left side
• Controls Bar:        Top
```

## 🔄 Performance y Optimización

```
Optimizations Applied:
─────────────────────────────────────────

1. RepaintBoundary
   └── Isolates Gantt chart for efficient repaints
   └── Enables high-quality export capture

2. CustomPainter
   └── shouldRepaint() checks:
       • tasks changed?
       • dayWidth changed?
       • selectedTaskId changed?
       • draggingTaskId changed?
   └── Only repaints when necessary

3. Scroll Controllers
   └── Synchronized scrolling between:
       • Header timeline
       • Main chart
   └── Prevents multiple repaints

4. State Management
   └── BLoC pattern:
       • Predictable state changes
       • Efficient rebuilds
       • Easy testing

5. Lazy Building
   └── ListView.builder for:
       • Task labels
       • Resource panel items
   └── Only builds visible items
```

---

## 📊 Resumen Visual de Funcionalidades

```
┌─────────────────────────────────────────────────────────────┐
│                   GANTT CHART FEATURES                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ✅ Vista de Timeline          ✅ Drag & Drop de Fechas    │
│  ✅ Dependencias Visuales      ✅ Panel de Recursos        │
│  ✅ Zoom Dinámico              ✅ Exportar Imagen          │
│  ✅ Selección de Tareas        ✅ Compartir Gantt          │
│  ✅ Cálculo Automático         ✅ Replanificación          │
│                                                             │
│  Estado: 🟢 COMPLETADO                                     │
│  Tests: 🟡 PENDIENTES                                      │
│  Docs:  🟢 COMPLETOS                                       │
└─────────────────────────────────────────────────────────────┘
```

---

**Leyenda:**
- ★ NEW: Funcionalidad nueva implementada
- ✅: Completado
- 🟢: Estado óptimo
- 🟡: Pendiente
- →: Flujo de datos
- ↓: Transición de estado

**Fecha**: Octubre 2025  
**Versión**: 1.0
