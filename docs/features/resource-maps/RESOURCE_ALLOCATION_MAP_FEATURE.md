# 🗺️ Mapa de Asignación de Recursos - Implementación Completa

## 📋 Descripción General

Se ha implementado una herramienta visual completa para gestionar y visualizar la asignación de recursos en proyectos, con funcionalidad de **drag & drop** para reasignar tareas entre usuarios de manera intuitiva.

## ✅ Criterios de Aceptación Implementados

### 1. ✅ Vista de recursos por proyecto
- Grid view y list view seleccionables
- Información detallada de cada recurso (usuario)
- Estadísticas de carga de trabajo por usuario
- Calendario diario con codificación de colores

### 2. ✅ Indicador de carga de trabajo por usuario
- **Total de horas asignadas**: Suma total de horas estimadas
- **Promedio de horas por día**: Cálculo automático basado en tareas
- **Número de tareas asignadas**: Contador de tareas activas
- **Carga diaria visualizada**: Grid semanal con colores:
  - 🟢 Verde: < 6 horas (carga baja)
  - 🟠 Naranja: 6-8 horas (carga normal)
  - 🔴 Rojo: > 8 horas (sobrecarga)

### 3. ✅ Detección de sobre-asignación
- Badge "Sobrecargado" visible en usuarios con exceso de trabajo
- Detección automática basada en promedio de horas diarias
- Filtro específico para ver solo recursos sobrecargados
- Indicadores visuales claros (color rojo y icono de advertencia)

### 4. ✅ Vista de disponibilidad
- Filtro "Disponibles" para recursos con < 6h/día promedio
- Estado visual: "Disponible", "Carga Normal", "Sobrecargado"
- Ordenamiento por disponibilidad (de menor a mayor carga)
- Identificación rápida de recursos disponibles para nuevas tareas

### 5. ✅ Redistribución drag & drop
- **Long press** en cualquier tarea para iniciar el arrastre
- **Visual feedback** durante el drag (tarea resaltada)
- **Drop zones** en cada card de usuario con animación hover
- **Confirmación** antes de reasignar la tarea
- **Actualización automática** del backend y UI tras reasignación
- **Feedback visual** con SnackBar confirmando la acción

## 🏗️ Arquitectura de la Implementación

### Estructura de Archivos

```
creapolis_app/lib/
├── presentation/
│   ├── screens/
│   │   └── resource_map/
│   │       └── resource_allocation_map_screen.dart    # Pantalla principal
│   └── widgets/
│       └── resource_map/
│           ├── resource_map_view.dart                 # Vista con DragTarget
│           ├── resource_card.dart                     # Card de usuario
│           └── draggable_task_item.dart              # Tarea draggable
└── routes/
    ├── app_router.dart                                # Ruta: /resource-map
    └── route_builder.dart                             # Helper de navegación
```

### Componentes Principales

#### 1. ResourceAllocationMapScreen
**Responsabilidades:**
- Gestión de estado de vista (grid/list)
- Filtros (all/overloaded/available)
- Ordenamiento (name/workload/availability)
- Integración con WorkloadBloc
- UI de filtros y estadísticas

**Features:**
- AppBar con botones de vista, filtro y ordenamiento
- Selector de rango de fechas
- Tarjeta de estadísticas globales
- Indicador de filtros activos
- Estados vacíos personalizados según filtro

#### 2. ResourceMapView
**Responsabilidades:**
- Renderizado de vistas (grid o lista)
- Gestión de drag & drop (DragTarget)
- Manejo de reasignación de tareas
- Actualización del backend via UpdateTaskUseCase

**Funcionalidad Drag & Drop:**
```dart
DragTarget<TaskAllocation>(
  onWillAcceptWithDetails: (details) => 
    _draggedFromUserId != allocation.userId,
  onAcceptWithDetails: (details) => 
    _handleTaskDrop(context, details.data, allocation.userId),
  builder: (context, candidateData, rejectedData) {
    // Visual feedback cuando hover
  }
)
```

#### 3. ResourceCard
**Responsabilidades:**
- Visualización de información del usuario
- Lista de tareas asignadas
- Estados expandibles/colapsables
- Indicadores de carga (disponible/normal/sobrecargado)

**Indicadores Visuales:**
- Avatar con inicial del usuario
- Badge de estado (color codificado)
- Estadísticas: total horas, promedio/día, # tareas
- Lista expandible de tareas

#### 4. DraggableTaskItem
**Responsabilidades:**
- Widget LongPressDraggable para cada tarea
- Visual feedback durante drag
- Información detallada de la tarea

**Información Mostrada:**
- Título de la tarea
- Estado (planned/in_progress/completed/blocked)
- Horas estimadas
- Fechas de inicio y fin
- Duración en días
- Horas por día
- Hint de "mantén presionado para reasignar"

## 🎨 Características de UX/UI

### Filtros Disponibles
1. **Todos**: Muestra todos los recursos del proyecto
2. **Sobrecargados**: Solo usuarios con isOverloaded = true
3. **Disponibles**: Solo usuarios con < 6h/día promedio

### Opciones de Ordenamiento
1. **Por nombre**: Alfabético (A-Z)
2. **Por carga de trabajo**: De mayor a menor horas totales
3. **Por disponibilidad**: De menor a mayor promedio diario

### Modos de Vista
1. **Grid**: 2 columnas, cards compactas, ideal para visión general
2. **List**: 1 columna, cards expandidas, ideal para detalle

### Codificación de Colores

#### Estados de Usuario
- 🔴 **Sobrecargado**: errorContainer (rojo)
- 🟢 **Disponible**: green.shade100
- 🔵 **Carga Normal**: blue.shade100

#### Carga Diaria (Calendario)
- 🟢 **< 6h**: Colors.green.shade100
- 🟠 **6-8h**: Colors.orange.shade100
- 🔴 **> 8h**: Colors.red.shade100
- ⚪ **0h**: Colors.grey.shade200

#### Estados de Tarea
- ⚫ **Planned**: Grey
- 🔵 **In Progress**: Blue
- 🟢 **Completed**: Green
- 🔴 **Blocked**: Red
- ⚫ **Cancelled**: Grey.shade600

## 🔄 Flujo de Reasignación de Tareas

### Paso a Paso

1. **Inicio del Drag**
   ```dart
   LongPressDraggable<TaskAllocation>(
     data: task,
     onDragStarted: () => onDragStart?.call(task),
     // ...
   )
   ```
   - Usuario mantiene presionada una tarea
   - Se muestra feedback visual (tarea elevada)
   - La tarea original queda semi-transparente

2. **Navegación sobre Targets**
   ```dart
   DragTarget<TaskAllocation>(
     onWillAcceptWithDetails: (details) => 
       _draggedFromUserId != allocation.userId,
     // ...
   )
   ```
   - Cada card de usuario es un DragTarget
   - Se resalta con borde azul cuando hover
   - Solo acepta si es diferente al usuario origen

3. **Drop de la Tarea**
   - Se muestra diálogo de confirmación
   - Mensaje: "¿Deseas reasignar '{tarea}' a {usuario}?"
   - Botones: Cancelar / Reasignar

4. **Actualización Backend**
   ```dart
   final result = await _updateTaskUseCase(
     UpdateTaskParams(
       projectId: widget.projectId,
       id: task.taskId,
       assignedUserId: newAssigneeId,
     ),
   );
   ```
   - Llamada al UpdateTaskUseCase
   - Actualización del assignedUserId en BD
   - Manejo de errores con SnackBar

5. **Actualización UI**
   ```dart
   context.read<WorkloadBloc>().add(
     RefreshWorkloadEvent(widget.projectId),
   );
   ```
   - Refresh automático del WorkloadBloc
   - Recálculo de cargas de trabajo
   - Actualización visual de todos los recursos

## 🔗 Navegación

### Desde Project Detail Screen

```dart
ElevatedButton.icon(
  onPressed: () => context.goToResourceMap(workspaceId, project.id),
  icon: const Icon(Icons.grid_view, size: 18),
  label: const Text('Mapa de Recursos'),
)
```

### Ruta

```
/workspaces/:wId/projects/:pId/resource-map
```

### RouteBuilder

```dart
static String resourceMap(int workspaceId, int projectId) =>
    '/workspaces/$workspaceId/projects/$projectId/resource-map';
```

## 🧪 Casos de Uso Cubiertos

### UC1: Visualizar Recursos del Proyecto
- ✅ Ver todos los miembros con tareas asignadas
- ✅ Ver estadísticas de carga por miembro
- ✅ Identificar recursos sobrecargados
- ✅ Identificar recursos disponibles

### UC2: Reasignar Tarea por Drag & Drop
- ✅ Seleccionar tarea manteniendo presionada
- ✅ Arrastrar sobre usuario destino
- ✅ Confirmar reasignación
- ✅ Ver actualización en tiempo real

### UC3: Filtrar y Ordenar Recursos
- ✅ Filtrar por estado (todos/sobrecargados/disponibles)
- ✅ Ordenar por nombre, carga o disponibilidad
- ✅ Cambiar entre vista grid y lista
- ✅ Ver información de filtros activos

### UC4: Analizar Disponibilidad
- ✅ Ver carga diaria en calendario
- ✅ Identificar días sobrecargados
- ✅ Ver promedio de horas por día
- ✅ Detectar patrones de sobre-asignación

## 📊 Integración con Sistema Existente

### Dependencias

```dart
// BLoC
WorkloadBloc
  ├── LoadResourceAllocationEvent
  ├── RefreshWorkloadEvent
  └── ChangeDateRangeEvent

// UseCases
UpdateTaskUseCase
  └── UpdateTaskParams

// Entities
ResourceAllocation
  ├── userId, userName
  ├── dailyHours (Map<DateTime, double>)
  ├── totalHours, averageHoursPerDay
  ├── isOverloaded, overloadedDaysCount
  └── taskAllocations (List<TaskAllocation>)

TaskAllocation
  ├── taskId, taskTitle
  ├── startDate, endDate
  ├── estimatedHours, status
  ├── durationInDays
  └── hoursPerDay
```

### Widgets Reutilizados
- `DateRangeSelector`: Selector de rango de fechas
- `WorkloadStatsCard`: Tarjeta de estadísticas globales

## 🚀 Ventajas de la Implementación

### Para Project Managers
1. **Visión holística** de la carga de trabajo del equipo
2. **Identificación rápida** de sobrecarga o disponibilidad
3. **Reasignación intuitiva** mediante drag & drop
4. **Planificación visual** con calendario de carga diaria

### Para el Equipo
1. **Transparencia** en la distribución de trabajo
2. **Balance de carga** más equitativo
3. **Reducción de sobrecarga** mediante detección temprana
4. **Mejor visibilidad** de tareas asignadas

### Técnicas
1. **Clean Architecture** con separación de responsabilidades
2. **Reutilización** de componentes existentes
3. **Drag & drop nativo** de Flutter sin librerías externas
4. **Actualización reactiva** con BLoC pattern
5. **Confirmación de acciones** para prevenir errores

## 🎯 Próximas Mejoras Posibles

1. **Vista de Timeline Horizontal**: Gantt simplificado por usuario
2. **Alertas Automáticas**: Notificación cuando se detecta sobrecarga
3. **Sugerencias de Reasignación**: IA que sugiere redistribuciones óptimas
4. **Histórico de Reasignaciones**: Registro de cambios realizados
5. **Bulk Reassignment**: Reasignar múltiples tareas a la vez
6. **Filtro por Skills**: Asignar según habilidades del equipo
7. **Exportación**: PDF/Excel con mapa de recursos
8. **Vista de Capacidad**: Comparar carga vs. capacidad disponible

## 📝 Notas de Implementación

### Consideraciones Técnicas
- El drag & drop usa `LongPressDraggable` para evitar conflictos con scroll
- Los `DragTarget` tienen validación para evitar reasignar al mismo usuario
- Se mantiene estado local (`_draggedTask`, `_draggedFromUserId`) para tracking
- La confirmación previene reasignaciones accidentales
- El refresh del bloc garantiza consistencia con backend

### Performance
- ListView.builder con `shrinkWrap` y `physics: NeverScrollableScrollPhysics`
- GridView con `childAspectRatio` optimizado para 2 columnas
- Cards con estado expandible para reducir renderizado inicial
- Filtrado y ordenamiento en memoria (eficiente para proyectos pequeños/medianos)

### Accesibilidad
- Tooltips en todos los iconos
- Labels descriptivos en botones
- Feedback visual y textual en todas las acciones
- Contraste de colores según Material Design 3
- Hint text en items draggables

---

**Fecha de Implementación**: 14 de Octubre, 2025  
**Versión**: 1.0  
**Estado**: ✅ Completado y funcional
