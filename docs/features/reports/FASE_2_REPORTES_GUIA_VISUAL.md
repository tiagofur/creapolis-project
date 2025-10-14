# 📊 Sistema de Reportes - Guía Visual

## 🎯 Flujo de Usuario

```
Usuario
│
├─ Opción 1: Report Builder (Personalizado)
│  │
│  ├─ Seleccionar Proyecto/Workspace
│  ├─ Configurar Métricas
│  │  ├─ ☑️ Tareas
│  │  ├─ ☑️ Progreso
│  │  ├─ ☑️ Tiempo
│  │  ├─ ☑️ Equipo
│  │  └─ ☑️ Productividad
│  ├─ Filtrar por Fechas (Opcional)
│  ├─ Generar Reporte
│  └─ Vista Previa + Exportar
│
└─ Opción 2: Plantillas Predefinidas
   │
   ├─ Ver Galería de Plantillas
   │  ├─ 📊 Resumen de Proyecto
   │  ├─ 📋 Proyecto Detallado
   │  ├─ 👥 Desempeño del Equipo
   │  ├─ ⏱️ Seguimiento de Tiempo
   │  ├─ 📈 Resumen Ejecutivo
   │  └─ 🏢 Vista General Workspace
   ├─ Seleccionar Plantilla
   ├─ Generar Automáticamente
   └─ Vista Previa + Exportar
```

## 📱 Pantallas Flutter

### 1. Report Builder Screen

```
┌────────────────────────────────────────┐
│ ← Crear Reporte               [?]     │
├────────────────────────────────────────┤
│                                        │
│  ┌──────────────────────────────────┐ │
│  │ Reporte para                     │ │
│  │ 📁 Proyecto Marketing 2024       │ │
│  │    Proyecto                      │ │
│  └──────────────────────────────────┘ │
│                                        │
│  ┌──────────────────────────────────┐ │
│  │ Nombre del Reporte               │ │
│  │ [Reporte de Marketing 2024]      │ │
│  └──────────────────────────────────┘ │
│                                        │
│  ┌──────────────────────────────────┐ │
│  │ Rango de Fechas (Opcional)       │ │
│  │ [Desde: 01/01/24] [Hasta: 31/12]│ │
│  └──────────────────────────────────┘ │
│                                        │
│  ┌──────────────────────────────────┐ │
│  │ Métricas a Incluir               │ │
│  │ ☑️ Tareas                        │ │
│  │ ☑️ Progreso                      │ │
│  │ ☑️ Tiempo                        │ │
│  │ ☑️ Equipo                        │ │
│  └──────────────────────────────────┘ │
│                                        │
│  ┌──────────────────────────────────┐ │
│  │     📊 Generar Reporte           │ │
│  └──────────────────────────────────┘ │
│                                        │
└────────────────────────────────────────┘
```

### 2. Report Templates Screen

```
┌────────────────────────────────────────┐
│ ← Plantillas de Reportes        🔄    │
├────────────────────────────────────────┤
│ [Todos] [📊Proyecto] [👥Equipo]       │
│ [⏱️Tiempo] [📈Ejecutivo] [🏢Workspace]│
├────────────────────────────────────────┤
│                                        │
│ ┌──────────────────────────────────┐  │
│ │ 📊  Resumen de Proyecto        → │  │
│ │     Vista general del estado     │  │
│ │     [Tareas][Progreso][Tiempo]   │  │
│ └──────────────────────────────────┘  │
│                                        │
│ ┌──────────────────────────────────┐  │
│ │ 📋  Proyecto Detallado         → │  │
│ │     Análisis completo            │  │
│ │     [Tareas][Progreso][Tiempo]   │  │
│ │     [Equipo][Dependencias]       │  │
│ └──────────────────────────────────┘  │
│                                        │
│ ┌──────────────────────────────────┐  │
│ │ 👥  Desempeño del Equipo       → │  │
│ │     Productividad y carga        │  │
│ │     [Equipo][Productividad]      │  │
│ └──────────────────────────────────┘  │
│                                        │
└────────────────────────────────────────┘
```

### 3. Report Preview Screen

```
┌────────────────────────────────────────┐
│ ← Vista Previa del Reporte       📥   │
├────────────────────────────────────────┤
│                                        │
│ ┌──────────────────────────────────┐  │
│ │ Reporte de Marketing 2024        │  │
│ │ Generado: 14/10/2025 10:30       │  │
│ │ Período: 01/01/24 - 31/12/24     │  │
│ └──────────────────────────────────┘  │
│                                        │
│ ┌──────────────────────────────────┐  │
│ │ ✓ Tareas                         │  │
│ │ ─────────────────────────────    │  │
│ │ Total:            50             │  │
│ │ Planificadas:     10             │  │
│ │ En Progreso:      20             │  │
│ │ Completadas:      20             │  │
│ │ Completitud:      40%            │  │
│ └──────────────────────────────────┘  │
│                                        │
│ ┌──────────────────────────────────┐  │
│ │ 📈 Progreso                      │  │
│ │ ─────────────────────────────    │  │
│ │ Progreso General: 40%            │  │
│ │ Velocidad:        0.4            │  │
│ │ Tareas Atrasadas: 5              │  │
│ └──────────────────────────────────┘  │
│                                        │
│ [Más métricas...]                     │
│                                        │
└────────────────────────────────────────┘
```

### Export Bottom Sheet

```
┌────────────────────────────────────────┐
│             Exportar Reporte           │
├────────────────────────────────────────┤
│                                        │
│  📄 Exportar como PDF                 │
│  📊 Exportar como Excel               │
│  📝 Exportar como CSV                 │
│  ─────────────────────────────────    │
│  📤 Compartir                         │
│                                        │
└────────────────────────────────────────┘
```

## 🔄 Flujo de Datos

### Generación de Reporte

```
Flutter App                Backend                Database
    │                        │                      │
    │─── GET /templates ────>│                      │
    │<── Templates ──────────│                      │
    │                        │                      │
    │─ POST /custom ────────>│                      │
    │   {templateId, ...}    │                      │
    │                        │──── Query ──────────>│
    │                        │<─── Project Data ────│
    │                        │                      │
    │                        │ Calculate Metrics    │
    │                        │ ───────────          │
    │                        │           │          │
    │                        │<──────────┘          │
    │                        │                      │
    │<── Report JSON ────────│                      │
    │                        │                      │
    │ Display Preview        │                      │
    │                        │                      │
```

### Exportación de Reporte

```
Flutter App                Backend
    │                        │
    │─ GET /project/1 ──────>│
    │   ?format=pdf          │
    │                        │
    │                        │ Generate Report
    │                        │ ───────────
    │                        │           │
    │                        │<──────────┘
    │                        │
    │                        │ Export to PDF
    │                        │ (using pdfkit)
    │                        │ ───────────
    │                        │           │
    │                        │<──────────┘
    │                        │
    │<── PDF Buffer ─────────│
    │                        │
    │ Save to Device         │
    │ or Share               │
    │                        │
```

## 📊 Estructura de Datos

### Report JSON Structure

```json
{
  "project": {
    "id": 1,
    "name": "Marketing 2024",
    "description": "Proyecto de marketing",
    "workspace": "Creapolis",
    "createdAt": "2024-01-01T00:00:00Z"
  },
  "generatedAt": "2024-10-14T10:30:00Z",
  "dateRange": {
    "startDate": "2024-01-01T00:00:00Z",
    "endDate": "2024-12-31T23:59:59Z"
  },
  "metrics": {
    "tasks": {
      "total": 50,
      "byStatus": {
        "planned": 10,
        "inProgress": 20,
        "completed": 20
      },
      "completionRate": 40.0
    },
    "progress": {
      "totalTasks": 50,
      "completedTasks": 20,
      "overallProgress": 40,
      "velocity": 0.4,
      "overdueTasks": 5
    },
    "time": {
      "totalEstimatedHours": 500.0,
      "totalActualHours": 450.0,
      "variance": 50.0,
      "variancePercentage": -10.0,
      "efficiency": 111
    },
    "team": {
      "teamSize": 5,
      "assignedTasks": 45,
      "unassignedTasks": 5,
      "tasksByMember": {
        "John Doe": {
          "total": 10,
          "completed": 5,
          "inProgress": 3,
          "totalHours": 80.0
        }
      }
    }
  }
}
```

## 🎨 Componentes Reutilizables

### MetricsSelectorWidget
```dart
// Selector de métricas con checkboxes
MetricsSelectorWidget(
  metrics: currentMetrics,
  reportType: ReportType.project,
  onChanged: (newMetrics) {
    // Update state
  },
)
```

### DatePickerButton
```dart
// Botón para seleccionar fecha
_DatePickerButton(
  label: 'Desde',
  date: startDate,
  onDateSelected: (date) {
    // Update date
  },
)
```

### MetricRow
```dart
// Fila para mostrar métrica
_MetricRow(
  label: 'Total Tasks',
  value: '50',
)
```

## 🔗 Integración

### En Project Details Screen

```dart
// Agregar botón de reportes
IconButton(
  icon: Icon(Icons.analytics),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportBuilderScreen(
          reportService: getIt<ReportService>(),
          project: currentProject,
        ),
      ),
    );
  },
)
```

### En Dashboard

```dart
// Card de acceso rápido
Card(
  child: ListTile(
    leading: Icon(Icons.assessment),
    title: Text('Generar Reporte'),
    subtitle: Text('Crear reportes personalizados'),
    trailing: Icon(Icons.arrow_forward),
    onTap: () => Navigator.push(...),
  ),
)
```

## 📝 Ejemplo Completo

### Generar y Exportar Reporte

```dart
// 1. Obtener servicio
final reportService = ReportService(dio);

// 2. Generar reporte
final report = await reportService.generateProjectReport(
  projectId: 1,
  metrics: ['tasks', 'progress', 'time', 'team'],
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime(2024, 12, 31),
);

// 3. Exportar como PDF
final pdfPath = await reportService.exportReport(
  report: report,
  format: ReportExportFormat.pdf,
);

// 4. Mostrar resultado
print('Reporte guardado en: $pdfPath');

// 5. O compartir directamente
await reportService.shareReport(
  report: report,
  format: ReportExportFormat.excel,
);
```

## 🎯 Tips de UX

1. **Loading States**: Mostrar progress indicator durante generación
2. **Error Handling**: Mensajes claros cuando falla la generación
3. **Success Feedback**: Snackbar confirmando exportación exitosa
4. **Quick Actions**: Acceso rápido desde pantallas principales
5. **Template Preview**: Mostrar ejemplo de cada plantilla
6. **Recently Generated**: Lista de reportes recientes

---

**Última actualización**: 2025-10-14  
**Versión**: 1.0.0
