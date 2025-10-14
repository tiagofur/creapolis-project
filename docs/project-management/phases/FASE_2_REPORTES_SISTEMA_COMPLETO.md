# 📊 Sistema de Reportes Personalizables - Documentación

## 🎯 Descripción General

Sistema completo para generar, personalizar y exportar reportes de proyectos y workspaces en múltiples formatos (PDF, Excel, CSV). Incluye plantillas predefinidas y builder personalizable.

## ✨ Características Implementadas

### Backend (Node.js/Express)

#### Servicios
- **report.service.js**: Generación de reportes con métricas calculadas
- **csv-export.service.js**: Exportación a formato CSV
- **excel-export.service.js**: Exportación a Excel con múltiples hojas
- **pdf-export.service.js**: Generación de PDFs profesionales

#### APIs REST

```
GET /api/reports/templates
- Retorna lista de plantillas predefinidas
- No requiere parámetros

GET /api/reports/project/:projectId
- Genera reporte de un proyecto específico
- Query params:
  - format: 'json' | 'csv' | 'excel' | 'pdf' (default: 'json')
  - metrics: Lista de métricas separadas por coma (opcional)
  - startDate: Fecha inicio filtro (opcional)
  - endDate: Fecha fin filtro (opcional)

GET /api/reports/workspace/:workspaceId
- Genera reporte de un workspace
- Query params: Iguales a project report

POST /api/reports/custom
- Genera reporte usando plantilla predefinida
- Body:
  {
    "templateId": "project_summary",
    "entityType": "project" | "workspace",
    "entityId": 123,
    "format": "json" | "csv" | "excel" | "pdf",
    "startDate": "2024-01-01T00:00:00Z", // opcional
    "endDate": "2024-12-31T23:59:59Z"    // opcional
  }
```

### Frontend (Flutter)

#### Entidades de Dominio

**Report**
```dart
class Report {
  final String id;
  final String name;
  final ReportType type; // project | workspace
  final int entityId;
  final Map<String, dynamic> data;
  final DateTime generatedAt;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> metrics;
  final String? templateId;
}
```

**ReportTemplate**
```dart
class ReportTemplate {
  final String id;
  final String name;
  final String description;
  final List<String> metrics;
  final String format;
  final ReportTemplateCategory category;
}
```

#### Pantallas

1. **ReportBuilderScreen**: Constructor de reportes personalizados
   - Selector de métricas
   - Filtro por rango de fechas
   - Nombre personalizado

2. **ReportTemplatesScreen**: Galería de plantillas
   - 6 plantillas predefinidas
   - Filtro por categoría
   - Generación rápida

3. **ReportPreviewScreen**: Vista previa y exportación
   - Visualización de métricas
   - Exportación multi-formato
   - Compartir funcionalidad

#### Servicio

**ReportService**
```dart
// Obtener plantillas
Future<List<ReportTemplate>> getTemplates()

// Generar reporte de proyecto
Future<Report> generateProjectReport({
  required int projectId,
  List<String>? metrics,
  DateTime? startDate,
  DateTime? endDate,
})

// Generar reporte de workspace
Future<Report> generateWorkspaceReport({
  required int workspaceId,
  List<String>? metrics,
  DateTime? startDate,
  DateTime? endDate,
})

// Exportar reporte
Future<String> exportReport({
  required Report report,
  required ReportExportFormat format,
})

// Compartir reporte
Future<void> shareReport({
  required Report report,
  required ReportExportFormat format,
})
```

## 📋 Plantillas Predefinidas

### 1. Resumen de Proyecto
- **ID**: `project_summary`
- **Categoría**: Proyecto
- **Métricas**: tasks, progress, time, team
- **Uso**: Vista general del estado del proyecto

### 2. Proyecto Detallado
- **ID**: `project_detailed`
- **Categoría**: Proyecto
- **Métricas**: tasks, progress, time, team, dependencies
- **Uso**: Análisis completo con todas las métricas

### 3. Desempeño del Equipo
- **ID**: `team_performance`
- **Categoría**: Equipo
- **Métricas**: team, productivity, time
- **Uso**: Análisis de productividad y carga de trabajo

### 4. Seguimiento de Tiempo
- **ID**: `time_tracking`
- **Categoría**: Tiempo
- **Métricas**: time, tasks
- **Uso**: Reporte de horas trabajadas y estimaciones

### 5. Resumen Ejecutivo
- **ID**: `executive_summary`
- **Categoría**: Ejecutivo
- **Métricas**: progress, tasks
- **Uso**: Vista de alto nivel para stakeholders

### 6. Vista General del Workspace
- **ID**: `workspace_overview`
- **Categoría**: Workspace
- **Métricas**: projects, tasks, team
- **Uso**: Resumen de todos los proyectos

## 📊 Métricas Disponibles

### Tasks (Tareas)
```json
{
  "total": 50,
  "byStatus": {
    "planned": 10,
    "inProgress": 20,
    "completed": 20
  },
  "completionRate": 40.0
}
```

### Progress (Progreso)
```json
{
  "totalTasks": 50,
  "completedTasks": 20,
  "inProgressTasks": 20,
  "overdueTasks": 5,
  "overallProgress": 40,
  "velocity": 0.4
}
```

### Time (Tiempo)
```json
{
  "totalEstimatedHours": 500.0,
  "totalActualHours": 450.0,
  "totalLoggedHours": 440.0,
  "variance": 50.0,
  "variancePercentage": -10.0,
  "efficiency": 111
}
```

### Team (Equipo)
```json
{
  "teamSize": 5,
  "assignedTasks": 45,
  "unassignedTasks": 5,
  "averageTasksPerMember": 9.0,
  "tasksByMember": {
    "John Doe": {
      "total": 10,
      "completed": 5,
      "inProgress": 3,
      "totalHours": 80.0
    }
  }
}
```

### Projects (Proyectos - solo workspace)
```json
{
  "total": 10,
  "withTasks": 8,
  "totalTasks": 150,
  "avgTasksPerProject": 15.0
}
```

### Productivity (Productividad - solo workspace)
```json
{
  "completedTasks": 60,
  "totalHours": 1000.0,
  "completedHours": 800.0,
  "productivityRate": 80.0
}
```

## 🚀 Uso

### Desde Flutter App

#### 1. Crear Reporte Personalizado

```dart
// Navegar al builder
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ReportBuilderScreen(
      reportService: reportService,
      project: currentProject, // o workspace: currentWorkspace
    ),
  ),
);
```

#### 2. Usar Plantilla

```dart
// Navegar a plantillas
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ReportTemplatesScreen(
      reportService: reportService,
      project: currentProject,
    ),
  ),
);
```

#### 3. Exportar Directamente

```dart
// Generar y exportar
final report = await reportService.generateProjectReport(
  projectId: 1,
  metrics: ['tasks', 'progress', 'time'],
);

// Exportar como PDF
final filePath = await reportService.exportReport(
  report: report,
  format: ReportExportFormat.pdf,
);

// O compartir
await reportService.shareReport(
  report: report,
  format: ReportExportFormat.excel,
);
```

### Desde API REST

#### Ejemplo: Generar reporte PDF de proyecto

```bash
curl -X GET \
  "http://localhost:3001/api/reports/project/1?format=pdf&metrics=tasks,progress,time" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -o report.pdf
```

#### Ejemplo: Usar plantilla para Excel

```bash
curl -X POST \
  "http://localhost:3001/api/reports/custom" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "templateId": "project_summary",
    "entityType": "project",
    "entityId": 1,
    "format": "excel"
  }' \
  -o report.xlsx
```

## 📦 Dependencias

### Backend
```json
{
  "json2csv": "Exportación CSV",
  "exceljs": "Generación de archivos Excel",
  "pdfkit": "Generación de PDFs"
}
```

### Flutter
```yaml
dependencies:
  dio: "HTTP client"
  path_provider: "Acceso a directorios"
  share_plus: "Compartir archivos"
  intl: "Formateo de fechas"
```

## 🔧 Configuración

### Backend

1. Instalar dependencias:
```bash
cd backend
npm install json2csv exceljs pdfkit
```

2. Las rutas ya están registradas en `server.js`

### Flutter

1. Las dependencias ya están en `pubspec.yaml`

2. Registrar servicio en DI (si usas inyección de dependencias):
```dart
// En injection.dart
@module
abstract class ReportModule {
  @lazySingleton
  ReportService reportService(Dio dio) => ReportService(dio);
}
```

## 🎨 Personalización

### Agregar Nueva Métrica

#### Backend

1. En `report.service.js`, agregar método de cálculo:
```javascript
_calculateNewMetric(data) {
  // Calcular métrica
  return {
    value1: ...,
    value2: ...
  };
}
```

2. Agregar en `generateProjectReport`:
```javascript
if (metrics.includes('newMetric')) {
  reportData.metrics.newMetric = this._calculateNewMetric(data);
}
```

#### Flutter

1. Actualizar `ReportMetrics`:
```dart
class ReportMetrics {
  final bool includeNewMetric;
  // ...
}
```

2. Agregar en `MetricsSelectorWidget`

### Agregar Nueva Plantilla

En `report.service.js`:
```javascript
getReportTemplates() {
  return [
    // ... plantillas existentes
    {
      id: 'custom_template',
      name: 'Mi Plantilla',
      description: 'Descripción',
      metrics: ['tasks', 'custom'],
      format: 'standard',
    },
  ];
}
```

## 📝 Notas Técnicas

### Formatos de Exportación

- **JSON**: Datos en bruto, ideal para procesamiento programático
- **CSV**: Múltiples secciones separadas por headers, compatible con Excel
- **Excel**: Múltiples hojas con formato, headers destacados
- **PDF**: Documento profesional con secciones y formato

### Consideraciones de Rendimiento

- Los reportes de workspace pueden ser grandes si hay muchos proyectos
- El filtrado por fechas mejora el rendimiento
- Los PDFs se generan en memoria, considerar límites para datasets grandes

### Seguridad

- Todas las rutas requieren autenticación
- Los usuarios solo pueden generar reportes de proyectos/workspaces a los que tienen acceso
- Los archivos exportados se guardan temporalmente en el dispositivo del usuario

## 🐛 Troubleshooting

### Error: "Failed to generate report"
- Verificar que el proyecto/workspace existe
- Confirmar que el usuario tiene acceso
- Revisar que las métricas solicitadas son válidas

### Error: "Failed to export report"
- Verificar permisos de escritura en el dispositivo
- Confirmar espacio disponible
- Revisar logs del backend para errores de generación

### PDF vacío o corrupto
- Verificar que pdfkit está instalado correctamente
- Revisar logs de generación en backend
- Confirmar que hay datos para generar el reporte

## 🚀 Próximas Mejoras

- [ ] Scheduler automático de reportes
- [ ] Envío por email
- [ ] Gráficos en reportes PDF
- [ ] Comparación de reportes
- [ ] Reportes de múltiples proyectos
- [ ] Export a PowerPoint
- [ ] Dashboards interactivos

## 📞 Soporte

Para problemas o preguntas:
1. Revisar esta documentación
2. Revisar logs del backend y Flutter
3. Contactar al equipo de desarrollo

---

**Implementado**: 2025-10-14  
**Versión**: 1.0.0  
**Autor**: GitHub Copilot Agent
