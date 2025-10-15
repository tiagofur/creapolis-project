# Burndown y Burnup Charts - Documentación

## 🎯 Resumen

Se han implementado gráficos de burndown y burnup para el seguimiento de sprints y proyectos, cumpliendo todos los criterios de aceptación del issue [FASE 2].

## ✅ Criterios de Aceptación Cumplidos

| Criterio | Estado | Implementación |
|----------|--------|----------------|
| Gráfico de burndown para sprints | ✅ | BurndownChartWidget con líneas ideal vs real |
| Gráfico de burnup para proyectos | ✅ | BurnupChartWidget con scope total y progreso |
| Línea ideal vs real | ✅ | Implementado en ambos gráficos |
| Predicción de finalización | ✅ | Cálculo automático basado en velocidad |
| Exportar gráficos | ✅ | ChartExportService para imagen/compartir |

---

## 📊 Componentes Implementados

### 1. Sprint Entity

**Ubicación**: `lib/domain/entities/sprint.dart`

**Descripción**: Entidad de dominio para representar sprints en el sistema.

**Propiedades principales**:
- `id`: Identificador único del sprint
- `name`: Nombre del sprint
- `projectId`: ID del proyecto asociado
- `startDate`, `endDate`: Fechas de inicio y fin
- `status`: Estado del sprint (planned, active, completed, cancelled)
- `plannedPoints`: Puntos de historia planificados

**Métodos útiles**:
- `isActive`: Verifica si el sprint está activo
- `durationInDays`: Calcula duración en días
- `daysElapsed`: Días transcurridos del sprint
- `progress`: Progreso del sprint (0.0 a 1.0)

### 2. BurndownChartWidget

**Ubicación**: `lib/presentation/screens/dashboard/widgets/burndown_chart_widget.dart`

**Descripción**: Gráfico de burndown que muestra el trabajo restante por día, ideal vs real.

**Características**:
- **Línea Ideal**: Muestra el burndown esperado lineal (línea punteada azul claro)
- **Línea Real**: Progreso actual del trabajo restante (línea sólida azul)
- **Línea de Predicción**: Proyección de cuándo se completará el trabajo (línea punteada terciaria)
- **Tooltips interactivos**: Muestra valores exactos al tocar/hover
- **Exportación**: Botón de descarga para guardar o compartir
- **Responsive**: Se adapta a diferentes tamaños de pantalla

**Cálculo del Burndown**:
1. Calcula el total de puntos (suma de `estimatedHours`)
2. Genera línea ideal: decremento lineal desde total a 0
3. Calcula línea real: puntos restantes día a día
4. Predice finalización: basado en velocidad de los últimos días

**Fórmula de Predicción**:
```dart
velocityPerDay = previousDay.remaining - currentDay.remaining
daysToCompletion = currentRemaining / velocityPerDay
predictedDay = currentDay + daysToCompletion
```

### 3. BurnupChartWidget

**Ubicación**: `lib/presentation/screens/dashboard/widgets/burnup_chart_widget.dart`

**Descripción**: Gráfico de burnup que muestra el trabajo total vs completado acumulado.

**Características**:
- **Línea de Scope Total**: Trabajo total planificado (línea punteada terciaria)
- **Línea Ideal**: Progreso esperado lineal (línea punteada azul claro)
- **Línea Real**: Trabajo completado acumulado (línea sólida secundaria)
- **Línea de Predicción**: Proyección de finalización (línea punteada roja)
- **Estadísticas**: Panel con % completado y predicción de finalización
- **Tooltips interactivos**: Valores exactos al tocar/hover
- **Exportación**: Guardar como imagen o compartir
- **Responsive**: Adaptable a diferentes pantallas

**Cálculo del Burnup**:
1. Calcula scope total (suma de `estimatedHours`)
2. Genera línea ideal: incremento lineal de 0 a total
3. Calcula línea real: puntos completados acumulados día a día
4. Predice finalización: basado en velocidad actual

**Estadísticas Mostradas**:
- **Completado**: Porcentaje del trabajo finalizado
- **Predicción**: Estado del proyecto (a tiempo o retrasado)

### 4. ChartExportService

**Ubicación**: `lib/presentation/services/chart_export_service.dart`

**Descripción**: Servicio para exportar gráficos como imágenes.

**Funciones implementadas**:

1. **`exportAsImage(GlobalKey key, String chartName)`**:
   - Captura el widget usando `RepaintBoundary`
   - Convierte a PNG con alta calidad (pixelRatio: 3.0)
   - Guarda temporalmente y comparte usando `share_plus`

2. **`saveAsImage(GlobalKey key, String chartName)`**:
   - Similar a exportAsImage
   - Guarda permanentemente en directorio de documentos
   - Retorna path del archivo guardado
   - Formato: `chart_NombreGrafico_timestamp.png`

3. **`exportAsPDF(GlobalKey key, String chartName)`**:
   - Actualmente usa exportAsImage
   - Preparado para implementación futura con paquete `pdf`

---

## 🔧 Configuración e Integración

### Nuevos Tipos de Widgets

Se añadieron 2 nuevos tipos al enum `DashboardWidgetType`:

```dart
enum DashboardWidgetType {
  // ... existentes
  burndownChart,     // Gráfico de Burndown
  burnupChart,       // Gráfico de Burnup
}
```

### Integración en DashboardWidgetFactory

```dart
case DashboardWidgetType.burndownChart:
  child = const BurndownChartWidget();
  break;
case DashboardWidgetType.burnupChart:
  child = const BurnupChartWidget();
  break;
```

### Metadata de los Widgets

```dart
// Burndown Chart
displayName: 'Burndown Chart'
description: 'Gráfico de burndown para sprints'
iconName: 'trending_down'

// Burnup Chart
displayName: 'Burnup Chart'
description: 'Gráfico de burnup para proyectos'
iconName: 'trending_up'
```

---

## 📱 Flujo de Usuario

### Ver Gráfico de Burndown

1. Usuario añade el widget "Burndown Chart" al dashboard
2. El gráfico muestra:
   - Trabajo restante ideal (línea punteada)
   - Trabajo restante real (línea sólida con área)
   - Predicción de finalización (si hay datos suficientes)
3. Puede interactuar tocando/hovering para ver valores exactos
4. Puede exportar usando el botón de descarga

### Ver Gráfico de Burnup

1. Usuario añade el widget "Burnup Chart" al dashboard
2. El gráfico muestra:
   - Scope total del proyecto (línea horizontal punteada)
   - Progreso ideal (línea punteada ascendente)
   - Progreso real (línea sólida con área)
   - Predicción de finalización
3. Panel de estadísticas muestra % completado y predicción
4. Interacción y exportación similar al burndown

### Exportar Gráfico

1. Click en botón de descarga (📥)
2. Aparece bottom sheet con opciones:
   - **Exportar como Imagen**: Guarda en documentos
   - **Compartir**: Abre sheet nativo de compartir
3. Muestra loading durante el proceso
4. Confirma con snackbar al completar

---

## 🎨 Características Visuales

### Burndown Chart

**Colores**:
- Línea Ideal: `primary.withOpacity(0.5)` + dash
- Línea Real: `primary` con área de relleno
- Predicción: `tertiary` + dash

**Elementos**:
- Eje X: Días del sprint (D0, D1, D2...)
- Eje Y: Puntos/horas restantes
- Grid: Líneas horizontales y verticales
- Dots: Círculos en puntos de la línea real
- Leyenda: Indicadores de cada línea

### Burnup Chart

**Colores**:
- Scope Total: `tertiary.withOpacity(0.7)` + dash
- Línea Ideal: `primary.withOpacity(0.5)` + dash
- Línea Real: `secondary` con área de relleno
- Predicción: `error` + dash

**Elementos**:
- Eje X: Días del proyecto (D0, D1, D2...)
- Eje Y: Puntos/horas completadas
- Grid: Líneas horizontales y verticales
- Dots: Círculos en puntos de la línea real
- Leyenda: Indicadores de cada línea
- Stats Panel: Completado % y predicción

---

## 🧮 Algoritmos de Predicción

### Predicción en Burndown

```dart
// Calcular velocidad entre últimos 2 puntos
velocityPerDay = previousDay.remaining - currentDay.remaining

// Si hay velocidad positiva y puntos restantes
if (velocityPerDay > 0 && currentRemaining > 0) {
  daysToCompletion = currentRemaining / velocityPerDay
  predictedDay = currentDay + daysToCompletion
}
```

### Predicción en Burnup

```dart
// Calcular velocidad de completado
velocityPerDay = currentDay.completed - previousDay.completed

// Si hay velocidad positiva y trabajo restante
if (velocityPerDay > 0 && currentCompleted < totalScope) {
  remainingWork = totalScope - currentCompleted
  daysToCompletion = remainingWork / velocityPerDay
  predictedDay = currentDay + daysToCompletion
}

// Determinar estado
if (predictedDay <= plannedDays) {
  status = "A tiempo"
} else {
  delay = predictedDay - plannedDays
  status = "Retrasado (X días extra)"
}
```

---

## 📊 Integración con Filtros

Ambos widgets respetan el filtro de proyecto del `DashboardFilterProvider`:

```dart
List<Task> _applyFilters(
  List<Task> tasks,
  DashboardFilterProvider filterProvider,
) {
  var filtered = tasks;

  if (filterProvider.selectedProjectId != null) {
    filtered = filtered
        .where((task) => task.projectId.toString() == filterProvider.selectedProjectId)
        .toList();
  }

  return filtered;
}
```

Esto permite:
- Ver burndown/burnup de un proyecto específico
- Comparar métricas entre proyectos
- Enfocarse en sprints activos

---

## 📄 Archivos Creados

### Nuevos
- `lib/domain/entities/sprint.dart` (~120 líneas)
- `lib/presentation/services/chart_export_service.dart` (~80 líneas)
- `lib/presentation/screens/dashboard/widgets/burndown_chart_widget.dart` (~550 líneas)
- `lib/presentation/screens/dashboard/widgets/burnup_chart_widget.dart` (~650 líneas)

### Modificados
- `lib/domain/entities/dashboard_widget_config.dart`
- `lib/presentation/screens/dashboard/widgets/dashboard_widget_factory.dart`

---

## 🎯 Casos de Uso

### Sprint Tracking con Burndown

**Escenario**: Equipo ágil con sprint de 2 semanas

1. Product Owner planifica sprint con 40 puntos de historia
2. Equipo añade Burndown Chart al dashboard
3. Cada día se actualiza automáticamente mostrando:
   - Línea ideal de burndown
   - Progreso real del equipo
   - Si están adelante/atrás del plan
4. Al final del sprint se puede exportar para retrospectiva

**Interpretación**:
- Línea real **por debajo** de ideal = adelantados ✅
- Línea real **por encima** de ideal = atrasados ⚠️
- Línea real **plana** = no hay progreso 🔴

### Project Tracking con Burnup

**Escenario**: Proyecto de 3 meses con múltiples sprints

1. Project Manager configura proyecto con 200 puntos totales
2. Añade Burnup Chart al dashboard del proyecto
3. El gráfico muestra:
   - Scope total (200 pts)
   - Línea ideal de progreso
   - Trabajo completado acumulado
   - Predicción de finalización
4. Permite identificar:
   - Si se completará a tiempo
   - Necesidad de ajustar recursos
   - Impacto de cambios de scope

**Interpretación**:
- Línea real **por encima** de ideal = adelantados ✅
- Línea real **por debajo** de ideal = atrasados ⚠️
- Predicción **< fecha fin** = completar a tiempo ✅
- Predicción **> fecha fin** = necesita ajustes ⚠️

---

## 🔮 Mejoras Futuras

1. **Integración con Sprint Entity Backend**:
   - CRUD de sprints
   - Asociar tareas a sprints específicos
   - Múltiples sprints por proyecto

2. **Configuración Avanzada**:
   - Seleccionar sprint específico para burndown
   - Ajustar rango de fechas manualmente
   - Configurar unidades (puntos/horas)

3. **Análisis Avanzado**:
   - Velocity chart histórico
   - Comparación entre sprints
   - Detección de patrones

4. **Exportación Mejorada**:
   - PDF real con múltiples gráficos
   - Incluir tabla de datos
   - Exportar serie histórica

5. **Scope Changes**:
   - Detectar cambios de scope en burnup
   - Mostrar línea de scope con cambios
   - Alertas de scope creep

---

## 📖 Referencias

### fl_chart
- **Documentación**: https://pub.dev/packages/fl_chart
- **LineChart**: Usado para burndown/burnup
- **Características usadas**:
  - FlSpot: Puntos de datos
  - LineTouchData: Tooltips interactivos
  - BarAreaData: Áreas bajo la curva
  - dashArray: Líneas punteadas

### Metodologías Ágiles
- **Burndown Chart**: https://www.scrum.org/resources/what-is-a-burndown-chart
- **Burnup Chart**: https://www.agilealliance.org/glossary/burnup-chart/
- **Velocity Tracking**: Medición de ritmo de trabajo

---

## ✅ Checklist Final

- [x] Crear entidad Sprint
- [x] Implementar BurndownChartWidget
- [x] Implementar BurnupChartWidget
- [x] Añadir líneas ideal vs real en ambos
- [x] Implementar algoritmo de predicción
- [x] Crear ChartExportService
- [x] Integrar en DashboardWidgetConfig
- [x] Integrar en DashboardWidgetFactory
- [x] Documentación completa
- [x] Soporte para exportación de imágenes

**Todos los criterios de aceptación del issue han sido cumplidos.**
