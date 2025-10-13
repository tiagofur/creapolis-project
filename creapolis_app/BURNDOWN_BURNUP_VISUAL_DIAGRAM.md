# 📊 Diagrama Visual: Burndown y Burnup Charts

## 🎯 Arquitectura de Componentes

```
┌─────────────────────────────────────────────────────────────────┐
│                    DASHBOARD SCREEN                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │         DashboardFilterProvider (State)                 │  │
│  │  - selectedProjectId                                    │  │
│  │  - selectedUserId                                       │  │
│  │  - dateRange                                            │  │
│  └─────────────────────────────────────────────────────────┘  │
│                            │                                   │
│                            ▼                                   │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │    DashboardWidgetFactory.buildWidget()                 │  │
│  │                                                         │  │
│  │    switch (config.type) {                              │  │
│  │      case burndownChart:                               │  │
│  │        → BurndownChartWidget()                         │  │
│  │      case burnupChart:                                 │  │
│  │        → BurnupChartWidget()                           │  │
│  │    }                                                    │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📉 Burndown Chart - Flujo de Datos

```
┌────────────────────────────────────────────────────────────────────┐
│                    BurndownChartWidget                             │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  1. context.watch<DashboardFilterProvider>()                      │
│     │                                                              │
│     ▼                                                              │
│  2. BlocBuilder<TaskBloc, TaskState>                              │
│     │                                                              │
│     ├─ TaskLoading → Show CircularProgressIndicator              │
│     ├─ TaskError   → Show error message                          │
│     └─ TasksLoaded → Continue to step 3                          │
│                                                                    │
│  3. _applyFilters(tasks, filterProvider)                          │
│     │                                                              │
│     ├─ Filter by projectId                                        │
│     └─ Return filtered tasks                                      │
│                                                                    │
│  4. _calculateBurndownData(tasks)                                 │
│     │                                                              │
│     ├─ Calculate date range (startDate to endDate)                │
│     ├─ Calculate totalPoints (sum of estimatedHours)              │
│     ├─ Generate idealSpots (linear from total to 0)               │
│     ├─ Generate actualSpots (remaining points per day)            │
│     └─ Generate predictionSpots (if velocity > 0)                 │
│                                                                    │
│  5. RepaintBoundary + LineChart                                   │
│     │                                                              │
│     ├─ Line 1: Ideal (dashed, primary.withOpacity(0.5))          │
│     ├─ Line 2: Actual (solid, primary with area)                 │
│     └─ Line 3: Prediction (dashed, tertiary) [if exists]         │
│                                                                    │
│  6. Export Options                                                │
│     │                                                              │
│     ├─ IconButton(download) → _showExportOptions()                │
│     ├─ BottomSheet: [Export, Share]                              │
│     └─ ChartExportService.saveAsImage(_chartKey)                 │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

### Cálculo de Burndown (Pseudocódigo)

```
function _calculateBurndownData(tasks):
  # 1. Fechas del sprint
  dates = [task.startDate, task.endDate for task in tasks]
  startDate = min(dates)
  endDate = max(dates)
  days = (endDate - startDate).days + 1
  
  # 2. Total de puntos
  totalPoints = sum(task.estimatedHours for task in tasks)
  
  # 3. Línea ideal
  idealSpots = []
  for i in range(days):
    remainingIdeal = totalPoints * (1 - i / (days - 1))
    idealSpots.append(FlSpot(i, remainingIdeal))
  
  # 4. Línea real
  actualSpots = []
  for i in range(days):
    currentDate = startDate + i days
    if currentDate > now: break
    
    remainingPoints = 0
    for task in tasks:
      if task.status != completed OR task.endDate > currentDate:
        remainingPoints += task.estimatedHours
    
    actualSpots.append(FlSpot(i, remainingPoints))
  
  # 5. Predicción
  if len(actualSpots) >= 2:
    lastSpot = actualSpots[-1]
    prevSpot = actualSpots[-2]
    velocityPerDay = prevSpot.y - lastSpot.y
    
    if velocityPerDay > 0 AND lastSpot.y > 0:
      daysToCompletion = ceil(lastSpot.y / velocityPerDay)
      predictionDay = lastSpot.x + daysToCompletion
      
      predictionSpots = [
        lastSpot,
        FlSpot(predictionDay, 0)
      ]
  
  return {
    idealSpots, actualSpots, predictionSpots,
    days, maxPoints: totalPoints
  }
```

---

## 📈 Burnup Chart - Flujo de Datos

```
┌────────────────────────────────────────────────────────────────────┐
│                     BurnupChartWidget                              │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  1. context.watch<DashboardFilterProvider>()                      │
│     │                                                              │
│     ▼                                                              │
│  2. BlocBuilder<TaskBloc, TaskState>                              │
│     │                                                              │
│     └─ TasksLoaded → Continue                                     │
│                                                                    │
│  3. _applyFilters(tasks, filterProvider)                          │
│     │                                                              │
│     └─ Filter by projectId                                        │
│                                                                    │
│  4. _calculateBurnupData(tasks)                                   │
│     │                                                              │
│     ├─ Calculate date range                                       │
│     ├─ Calculate totalPoints (scope)                              │
│     ├─ Generate totalScopeSpots (horizontal line)                 │
│     ├─ Generate idealSpots (linear 0 to total)                    │
│     ├─ Generate actualSpots (cumulative completed)                │
│     └─ Generate predictionSpots + predictedCompletionDay          │
│                                                                    │
│  5. RepaintBoundary + LineChart                                   │
│     │                                                              │
│     ├─ Line 1: Total Scope (dashed, tertiary)                     │
│     ├─ Line 2: Ideal (dashed, primary.withOpacity(0.5))          │
│     ├─ Line 3: Actual (solid, secondary with area)                │
│     └─ Line 4: Prediction (dashed, error) [if exists]             │
│                                                                    │
│  6. Stats Panel                                                   │
│     │                                                              │
│     ├─ Completed: (completed / total) * 100 %                     │
│     └─ Prediction: "A tiempo" or "Retrasado X días"               │
│                                                                    │
│  7. Export Options                                                │
│     │                                                              │
│     └─ Same as Burndown                                           │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

### Cálculo de Burnup (Pseudocódigo)

```
function _calculateBurnupData(tasks):
  # 1. Fechas del proyecto
  dates = [task.startDate, task.endDate for task in tasks]
  startDate = min(dates)
  endDate = max(dates)
  days = (endDate - startDate).days + 1
  
  # 2. Total de puntos (scope)
  totalPoints = sum(task.estimatedHours for task in tasks)
  
  # 3. Línea de scope total (horizontal)
  totalScopeSpots = [
    FlSpot(0, totalPoints),
    FlSpot(days - 1, totalPoints)
  ]
  
  # 4. Línea ideal de progreso
  idealSpots = []
  for i in range(days):
    idealProgress = totalPoints * (i / (days - 1))
    idealSpots.append(FlSpot(i, idealProgress))
  
  # 5. Línea real (acumulado)
  actualSpots = []
  cumulativeCompleted = 0
  
  for i in range(days):
    currentDate = startDate + i days
    if currentDate > now: break
    
    completedOnDay = 0
    for task in tasks:
      if task.status == completed AND 
         task.endDate <= currentDate AND
         task.endDate > (currentDate - 1 day):
        completedOnDay += task.estimatedHours
    
    cumulativeCompleted += completedOnDay
    actualSpots.append(FlSpot(i, cumulativeCompleted))
  
  # 6. Predicción
  if len(actualSpots) >= 2:
    lastSpot = actualSpots[-1]
    prevSpot = actualSpots[-2]
    velocityPerDay = lastSpot.y - prevSpot.y
    
    if velocityPerDay > 0 AND lastSpot.y < totalPoints:
      remainingPoints = totalPoints - lastSpot.y
      daysToCompletion = ceil(remainingPoints / velocityPerDay)
      predictedDay = lastSpot.x + daysToCompletion
      
      predictionSpots = [
        lastSpot,
        FlSpot(predictedDay, totalPoints)
      ]
  
  return {
    totalScopeSpots, idealSpots, actualSpots,
    predictionSpots, days, maxPoints: totalPoints,
    completedPoints: lastSpot.y,
    predictedCompletionDay
  }
```

---

## 🎨 Visualización de Gráficos

### Burndown Chart - Ejemplo Visual

```
Puntos  │
Restantes│
        │
  100   ├─┐                     Ideal: ╌╌╌╌
        │  ╲                    Real:  ────
   80   │   ╲╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌   Pred:  ┄┄┄┄
        │    ●╲
   60   │      ●╲╌╌╌╌╌╌╌╌╌╌
        │        ●╲
   40   │          ●╲╌╌╌╌╌╌
        │            ●╲
   20   │              ●╲╌╌╌┄┄┄┄
        │                ●╲  ┄┄┄┄
    0   ├──────────────────●╲┄┄┄┄┄┄┄→
        0   D1  D2  D3  D4  D5  D6  D7  Días

Interpretación:
- Línea real por DEBAJO de ideal = Adelantados ✅
- Línea real por ENCIMA de ideal = Atrasados ⚠️
- Predicción muestra día estimado de finalización
```

### Burnup Chart - Ejemplo Visual

```
Puntos   │
Completados│
         │
  100    ├───────────────────────────  Scope Total
         │                     ┌●╌╌╌╌  Pred: Día 8
   80    │                 ┌●╌╌╌       (2 días retraso)
         │             ┌●╌╌╌
   60    │         ┌●╌╌╌               Ideal: ╌╌╌╌
         │     ┌●╌╌╌                   Real:  ────
   40    │ ┌●╌╌╌                       Scope: ────
         │╌●╌
   20    ├●╌╌
         │╌
    0    ●──────────────────────────→
         0   D1  D2  D3  D4  D5  D6    Días

Interpretación:
- Línea real por ENCIMA de ideal = Adelantados ✅
- Línea real por DEBAJO de ideal = Atrasados ⚠️
- Distancia entre real y scope = Trabajo pendiente
- Predicción muestra si completará a tiempo
```

---

## 📤 Exportación - Flujo

```
User clicks Export button (📥)
│
├─ _showExportOptions()
│  │
│  └─ ModalBottomSheet:
│     ├─ [🖼️ Export as Image]
│     └─ [📤 Share]
│
└─ User selects option
   │
   ├─ Export as Image:
   │  ├── _showLoadingDialog()
   │  ├── ChartExportService.saveAsImage(_chartKey, chartName)
   │  │   ├── Get RenderRepaintBoundary from _chartKey
   │  │   ├── boundary.toImage(pixelRatio: 3.0)
   │  │   ├── Convert to PNG bytes
   │  │   ├── Get app documents directory
   │  │   ├── Save to: chart_ChartName_timestamp.png
   │  │   └── Return file path
   │  ├── Navigator.pop() // Close loading
   │  └── Show success snackbar with path
   │
   └─ Share:
      ├── _showLoadingDialog()
      ├── ChartExportService.exportAsImage(_chartKey, chartName)
      │   ├── Capture as PNG
      │   ├── Save to temp directory
      │   └── Share.shareXFiles([XFile(path)])
      └── Native share sheet opens
```

---

## 🔄 Integración con Dashboard

```
┌──────────────────────────────────────────────────────────────┐
│                    DashboardScreen                           │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  User clicks "+" to add widget                              │
│  │                                                           │
│  ├─ AddWidgetBottomSheet appears                            │
│  │  │                                                        │
│  │  ├─ Shows list of available widgets:                     │
│  │  │  ├─ Burndown Chart   (trending_down icon)            │
│  │  │  ├─ Burnup Chart     (trending_up icon)              │
│  │  │  └─ ... other widgets                                │
│  │  │                                                        │
│  │  └─ User selects "Burndown Chart"                        │
│  │                                                           │
│  ├─ DashboardPreferences.addWidget(                          │
│  │     DashboardWidgetConfig.defaultForType(                │
│  │       DashboardWidgetType.burndownChart,                 │
│  │       position                                           │
│  │     )                                                     │
│  │   )                                                       │
│  │                                                           │
│  ├─ Dashboard rebuilds with new widget                      │
│  │                                                           │
│  └─ DashboardWidgetFactory.buildWidget()                    │
│     │                                                        │
│     ├─ case burndownChart:                                  │
│     │    return BurndownChartWidget()                       │
│     │                                                        │
│     └─ Widget rendered in dashboard grid                    │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## 🧮 Algoritmo de Predicción - Detallado

### Velocidad y Predicción

```
┌────────────────────────────────────────────────────────────┐
│            CÁLCULO DE VELOCIDAD                            │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  Entrada:                                                  │
│  - actualSpots: List<FlSpot> [día, puntos]                │
│                                                            │
│  Proceso:                                                  │
│  1. Obtener últimos 2 puntos:                             │
│     lastSpot     = actualSpots[-1]  // Ej: (5, 40 pts)   │
│     previousSpot = actualSpots[-2]  // Ej: (4, 50 pts)   │
│                                                            │
│  2. Calcular velocidad:                                   │
│     ┌─ Burndown ────────────────────────────────────┐    │
│     │ velocityPerDay = previousSpot.y - lastSpot.y  │    │
│     │                = 50 - 40 = 10 pts/día         │    │
│     └────────────────────────────────────────────────┘    │
│                                                            │
│     ┌─ Burnup ──────────────────────────────────────┐    │
│     │ velocityPerDay = lastSpot.y - previousSpot.y  │    │
│     │                = 40 - 30 = 10 pts/día         │    │
│     └────────────────────────────────────────────────┘    │
│                                                            │
│  3. Validar velocidad:                                    │
│     if velocityPerDay <= 0: no se puede predecir         │
│                                                            │
│  4. Calcular días restantes:                              │
│     ┌─ Burndown ────────────────────────────────────┐    │
│     │ remainingWork = lastSpot.y                    │    │
│     │               = 40 pts                        │    │
│     │ daysToComplete = ceil(40 / 10) = 4 días      │    │
│     └────────────────────────────────────────────────┘    │
│                                                            │
│     ┌─ Burnup ──────────────────────────────────────┐    │
│     │ remainingWork = totalPoints - lastSpot.y      │    │
│     │               = 100 - 40 = 60 pts             │    │
│     │ daysToComplete = ceil(60 / 10) = 6 días      │    │
│     └────────────────────────────────────────────────┘    │
│                                                            │
│  5. Día de finalización predicho:                         │
│     predictedDay = lastSpot.x + daysToComplete            │
│                  = 5 + 4 = Día 9                          │
│                                                            │
│  6. Estado del proyecto:                                  │
│     if predictedDay <= plannedEndDay:                     │
│       status = "A tiempo ✅"                              │
│     else:                                                 │
│       delay = predictedDay - plannedEndDay                │
│       status = "Retrasado {delay} días ⚠️"               │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### Ejemplo Numérico Completo

```
Sprint de 7 días con 100 puntos

Día │ Ideal │ Real │ Velocidad │ Predicción
────┼───────┼──────┼───────────┼─────────────
 0  │  100  │  100 │     -     │     -
 1  │   86  │   90 │  10 pts/d │  Día 10 ⚠️
 2  │   71  │   78 │  12 pts/d │  Día 8.5 ⚠️
 3  │   57  │   65 │  13 pts/d │  Día 8 ⚠️
 4  │   43  │   50 │  15 pts/d │  Día 7.3 ⚠️
 5  │   29  │   32 │  18 pts/d │  Día 6.8 ✅
 6  │   14  │   12 │  20 pts/d │  Día 6 ✅
 7  │    0  │    0 │  12 pts/d │  Completado ✅

Interpretación:
- Días 0-4: Atrasados (predicción > 7)
- Días 5-6: Recuperando (predicción ≈ 7)
- Día 7: Completado a tiempo
```

---

## 📊 Resumen de Componentes

```
┌─────────────────────────────────────────────────────────────┐
│              COMPONENTES IMPLEMENTADOS                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ✅ Sprint Entity                                          │
│     - Modelo de dominio para sprints                       │
│     - Props: id, name, dates, status, points               │
│     - Métodos: isActive, progress, daysElapsed             │
│                                                             │
│  ✅ BurndownChartWidget (~550 líneas)                      │
│     - Gráfico de trabajo restante                          │
│     - 3 líneas: Ideal, Real, Predicción                    │
│     - Tooltips interactivos                                │
│     - Exportación de imagen                                │
│                                                             │
│  ✅ BurnupChartWidget (~650 líneas)                        │
│     - Gráfico de trabajo completado                        │
│     - 4 líneas: Scope, Ideal, Real, Predicción             │
│     - Panel de estadísticas                                │
│     - Exportación de imagen                                │
│                                                             │
│  ✅ ChartExportService (~80 líneas)                        │
│     - exportAsImage: Compartir gráfico                     │
│     - saveAsImage: Guardar en documentos                   │
│     - exportAsPDF: Preparado para futuro                   │
│                                                             │
│  ✅ DashboardWidgetConfig                                  │
│     - +2 enum values: burndownChart, burnupChart           │
│     - Metadata: nombres, descripciones, iconos             │
│                                                             │
│  ✅ DashboardWidgetFactory                                 │
│     - Integración de nuevos widgets                        │
│     - Switch cases para burndown/burnup                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎓 Conceptos Clave

### Burndown Chart
- **Propósito**: Seguimiento de sprint (corto plazo)
- **Eje Y**: Trabajo **restante**
- **Tendencia ideal**: **Descendente** (de total a 0)
- **Adelantado**: Línea real **por debajo** de ideal
- **Usado en**: Scrum, sprints ágiles

### Burnup Chart
- **Propósito**: Seguimiento de proyecto (largo plazo)
- **Eje Y**: Trabajo **completado** (acumulado)
- **Tendencia ideal**: **Ascendente** (de 0 a total)
- **Adelantado**: Línea real **por encima** de ideal
- **Ventaja**: Muestra cambios de scope
- **Usado en**: Releases, proyectos completos

### Predicción
- **Basado en**: Velocidad de últimos días
- **Fórmula**: daysLeft = remainingWork / velocity
- **Fiabilidad**: Mejora con más datos históricos
- **Limitaciones**: Asume velocidad constante

---

## ✅ Estado de Implementación

```
┌───────────────────────────────────────────────────────────┐
│           FASE 2 - BURNDOWN/BURNUP CHARTS                 │
├───────────────────────────────────────────────────────────┤
│                                                           │
│  ✅ Gráfico de burndown para sprints                     │
│  ✅ Gráfico de burnup para proyectos                     │
│  ✅ Línea ideal vs real                                  │
│  ✅ Predicción de finalización                           │
│  ✅ Exportar gráficos (imagen/compartir)                 │
│                                                           │
│  Estado: 🟢 COMPLETADO                                   │
│  Tests: 🟡 PENDIENTES                                    │
│  Docs:  🟢 COMPLETOS                                     │
│                                                           │
└───────────────────────────────────────────────────────────┘
```
