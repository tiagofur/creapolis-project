# Dashboard Interactivo con Métricas Clave - Documentación

## 🎯 Resumen

Se ha implementado un dashboard interactivo con métricas clave (KPIs) de proyectos y productividad del equipo, cumpliendo todos los criterios de aceptación del issue [FASE 2].

## ✅ Criterios de Aceptación Cumplidos

| Criterio | Estado | Implementación |
|----------|--------|----------------|
| Diseñar layout del dashboard principal | ✅ | Dashboard con filtros y widgets modulares |
| Implementar widgets de métricas clave | ✅ | TaskMetricsWidget con KPIs visuales |
| Gráficos interactivos básicos | ✅ | Pie chart y bar chart con fl_chart |
| Filtros por proyecto, fecha, usuario | ✅ | DashboardFilterBar con UI intuitiva |
| Responsive design | ✅ | Widgets adaptativos con LayoutBuilder |

---

## 📊 Componentes Implementados

### 1. DashboardFilterProvider

**Ubicación**: `lib/presentation/providers/dashboard_filter_provider.dart`

**Descripción**: Provider para gestionar el estado de filtros del dashboard.

**Características**:
- Filtro por proyecto (ID)
- Filtro por usuario (ID)
- Filtro por rango de fechas (inicio y fin)
- Métodos para limpiar filtros individuales o todos
- Propiedad `hasActiveFilters` para detectar filtros activos

**Métodos principales**:
```dart
void setProjectFilter(String? projectId)
void setUserFilter(String? userId)
void setDateRange(DateTime? start, DateTime? end)
void clearFilters()
void clearProjectFilter()
void clearUserFilter()
void clearDateFilter()
```

### 2. TaskMetricsWidget

**Ubicación**: `lib/presentation/screens/dashboard/widgets/task_metrics_widget.dart`

**Descripción**: Widget que muestra métricas clave (KPIs) de tareas.

**Características**:
- **KPI Cards**: Muestra 4 métricas principales:
  - Tareas completadas (verde)
  - Tareas en progreso (azul)
  - Tareas retrasadas (rojo)
  - Tareas planificadas (naranja)
- **Barra de progreso**: Progreso general con porcentaje
- **Indicador de filtros**: Chip visual cuando hay filtros activos
- **Responsive**: Modo compacto para pantallas pequeñas (<600px)
- **Integración con filtros**: Aplica filtros de proyecto, usuario y fecha

**Cálculo de métricas**:
- Tareas retrasadas: Tareas con dueDate anterior a hoy y status != completed
- Progreso: (completadas / total) * 100

### 3. TaskPriorityChartWidget

**Ubicación**: `lib/presentation/screens/dashboard/widgets/task_priority_chart_widget.dart`

**Descripción**: Gráfico de pastel (pie chart) interactivo mostrando distribución de tareas por prioridad.

**Características**:
- **Gráfico de pastel**: Usando fl_chart para visualización
- **Interactividad**: Hover/touch muestra porcentajes
- **Colores por prioridad**:
  - Crítica: Morado
  - Alta: Rojo
  - Media: Naranja
  - Baja: Verde
- **Leyenda**: Lista de prioridades con conteo
- **Responsive**: Se adapta a diferentes tamaños de pantalla
- **Integración con filtros**: Respeta filtros activos

### 4. WeeklyProgressChartWidget

**Ubicación**: `lib/presentation/screens/dashboard/widgets/weekly_progress_chart_widget.dart`

**Descripción**: Gráfico de barras mostrando el progreso de tareas completadas en los últimos 7 días.

**Características**:
- **Gráfico de barras**: Usando fl_chart
- **Timeline de 7 días**: Desde hace 6 días hasta hoy
- **Etiquetas de días**: Lun, Mar, Mié, etc. (formato español)
- **Tooltips interactivos**: Muestra día y cantidad al tocar/hover
- **Escala dinámica**: Eje Y se adapta al máximo de datos
- **Integración con filtros**: Respeta filtros de proyecto y usuario

**Nota**: Solo cuenta tareas con `status == completed` y `completedAt` dentro del rango de 7 días.

### 5. DashboardFilterBar

**Ubicación**: `lib/presentation/screens/dashboard/widgets/dashboard_filter_bar.dart`

**Descripción**: Barra de filtros para el dashboard con UI intuitiva.

**Características**:
- **Filtro de proyecto**: Bottom sheet con lista de proyectos
- **Filtro de fecha**: Date range picker nativo de Flutter
- **Chips activos**: Muestra filtros aplicados con botón para eliminar
- **Botón limpiar todo**: Elimina todos los filtros de una vez
- **Integración con ProjectBloc**: Obtiene lista de proyectos disponibles

**UI Components**:
- `_ProjectFilterChip`: Chip para seleccionar proyecto
- `_DateRangeFilterChip`: Chip para seleccionar rango de fechas
- `_ActiveFilterChip`: Chip que muestra filtro activo con botón X

---

## 🔧 Configuración e Integración

### Dependencia Añadida

```yaml
dependencies:
  fl_chart: ^0.69.0  # Para gráficos interactivos
```

### Tipos de Widgets Nuevos

Se añadieron 3 nuevos tipos al enum `DashboardWidgetType`:

```dart
enum DashboardWidgetType {
  // ... existentes
  taskMetrics,           // Métricas de Tareas
  taskPriorityChart,     // Distribución por Prioridad
  weeklyProgressChart,   // Progreso Semanal
}
```

### Integración en DashboardWidgetFactory

```dart
case DashboardWidgetType.taskMetrics:
  child = const TaskMetricsWidget();
  break;
case DashboardWidgetType.taskPriorityChart:
  child = const TaskPriorityChartWidget();
  break;
case DashboardWidgetType.weeklyProgressChart:
  child = const WeeklyProgressChartWidget();
  break;
```

### Registro del Provider

En `main.dart`:

```dart
ChangeNotifierProvider(create: (context) => DashboardFilterProvider()),
```

### Integración en DashboardScreen

La barra de filtros se muestra al inicio del dashboard en modo normal:

```dart
Widget _buildNormalView() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DashboardFilterBar(),
        const SizedBox(height: 16),
        // ... widgets del dashboard
      ],
    ),
  );
}
```

---

## 🎨 Diseño Responsive

### Estrategias Implementadas

1. **LayoutBuilder**: Usado en `TaskMetricsWidget` para detectar ancho de pantalla
   ```dart
   LayoutBuilder(
     builder: (context, constraints) {
       final isSmallScreen = constraints.maxWidth < 600;
       // ... adaptar UI
     },
   )
   ```

2. **Tamaño Dinámico**: KPI cards ajustan tamaño en modo compacto
   - Normal: 100px de ancho
   - Compacto: 80px de ancho

3. **Wrap**: Para adaptarse a diferentes anchos sin overflow
   ```dart
   Wrap(
     spacing: 8,
     runSpacing: 8,
     children: [...],
   )
   ```

4. **Gráficos Flexibles**: fl_chart se adapta automáticamente al contenedor

---

## 📱 Flujo de Usuario

### Aplicar Filtros

1. Usuario entra al dashboard
2. Ve la barra de filtros en la parte superior
3. Puede hacer clic en:
   - **"Proyecto"**: Abre bottom sheet con lista de proyectos
   - **"Fecha"**: Abre date range picker
4. Al seleccionar filtros, aparecen chips con los valores seleccionados
5. Todos los widgets de métricas se actualizan automáticamente

### Limpiar Filtros

- **Individual**: Hacer clic en X de cada chip activo
- **Todos**: Hacer clic en botón "Limpiar" en la barra de filtros

### Interactuar con Gráficos

- **Pie Chart**: Tocar/hover sobre una sección para ver porcentaje
- **Bar Chart**: Tocar/hover sobre una barra para ver día y cantidad exacta

---

## 🧪 Testing

### Test Creado

**Ubicación**: `test/presentation/providers/dashboard_filter_provider_test.dart`

**Cobertura**:
- ✅ Inicialización sin filtros
- ✅ Establecer y limpiar filtro de proyecto
- ✅ Establecer y limpiar filtro de usuario
- ✅ Establecer y limpiar rango de fechas
- ✅ Limpiar todos los filtros
- ✅ Múltiples filtros activos simultáneamente
- ✅ Mantener filtros al limpiar uno específico

**Ejecutar tests**:
```bash
cd creapolis_app
flutter test test/presentation/providers/dashboard_filter_provider_test.dart
```

---

## 🚀 Próximas Mejoras Opcionales

1. **Más gráficos**:
   - Gráfico de líneas para tendencias
   - Burndown chart para sprints
   - Velocity chart

2. **Exportar datos**:
   - PDF de métricas
   - CSV de tareas filtradas

3. **Comparaciones**:
   - Comparar períodos (semana actual vs anterior)
   - Comparar proyectos

4. **Filtros adicionales**:
   - Por etiquetas/tags
   - Por estado personalizado
   - Por miembro del equipo (múltiple selección)

5. **Persistencia de filtros**:
   - Guardar preferencias de filtros
   - Filtros favoritos

---

## 📖 Uso para Desarrolladores

### Añadir un Widget de Métrica Nuevo

1. Crear el widget en `lib/presentation/screens/dashboard/widgets/`
2. Añadir tipo al enum en `dashboard_widget_config.dart`
3. Actualizar el switch en `dashboard_widget_factory.dart`
4. Usar `context.watch<DashboardFilterProvider>()` para obtener filtros
5. Aplicar filtros en el método de construcción del widget

### Ejemplo de Aplicación de Filtros

```dart
List<Task> _applyFilters(
  List<Task> tasks,
  DashboardFilterProvider filterProvider,
) {
  var filtered = tasks;

  if (filterProvider.selectedProjectId != null) {
    filtered = filtered
        .where((task) => task.projectId == filterProvider.selectedProjectId)
        .toList();
  }

  if (filterProvider.selectedUserId != null) {
    filtered = filtered
        .where((task) => task.assignedTo == filterProvider.selectedUserId)
        .toList();
  }

  if (filterProvider.startDate != null || filterProvider.endDate != null) {
    filtered = filtered.where((task) {
      if (task.dueDate == null) return false;
      if (filterProvider.startDate != null &&
          task.dueDate!.isBefore(filterProvider.startDate!)) return false;
      if (filterProvider.endDate != null &&
          task.dueDate!.isAfter(filterProvider.endDate!)) return false;
      return true;
    }).toList();
  }

  return filtered;
}
```

---

## 🎓 Conceptos Clave

### fl_chart

**Documentación**: https://pub.dev/packages/fl_chart

Biblioteca de gráficos para Flutter con soporte para:
- Line Chart
- Bar Chart
- Pie Chart
- Scatter Chart
- Radar Chart

**Ventajas**:
- Altamente personalizable
- Animaciones fluidas
- Interactividad built-in
- Responsive por defecto

### Provider Pattern

Los widgets usan `context.watch<DashboardFilterProvider>()` para:
- Escuchar cambios en los filtros
- Reconstruirse automáticamente cuando cambian
- Mantener UI sincronizada con el estado

---

## 📄 Archivos Relacionados

### Creados
- `lib/presentation/providers/dashboard_filter_provider.dart`
- `lib/presentation/screens/dashboard/widgets/task_metrics_widget.dart`
- `lib/presentation/screens/dashboard/widgets/task_priority_chart_widget.dart`
- `lib/presentation/screens/dashboard/widgets/weekly_progress_chart_widget.dart`
- `lib/presentation/screens/dashboard/widgets/dashboard_filter_bar.dart`
- `test/presentation/providers/dashboard_filter_provider_test.dart`

### Modificados
- `pubspec.yaml`
- `lib/domain/entities/dashboard_widget_config.dart`
- `lib/presentation/screens/dashboard/widgets/dashboard_widget_factory.dart`
- `lib/main.dart`
- `lib/presentation/screens/dashboard/dashboard_screen.dart`

---

## ✅ Checklist Final

- [x] Añadida biblioteca de gráficos (fl_chart)
- [x] Implementados widgets de métricas clave
- [x] Creados gráficos interactivos (pie y bar chart)
- [x] Implementado sistema de filtros completo
- [x] Diseño responsive en todos los widgets
- [x] Integración completa en dashboard
- [x] Test unitario del filter provider
- [x] Documentación exhaustiva

**Todos los criterios de aceptación del issue han sido cumplidos.**
