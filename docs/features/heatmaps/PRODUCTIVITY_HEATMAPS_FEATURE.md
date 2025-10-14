# 🔥 Productivity Heatmaps - Feature Documentation

## Overview

Esta funcionalidad implementa mapas de calor de productividad que permiten visualizar patrones de trabajo por hora y día de la semana, tanto a nivel individual como de equipo.

## Criterios de Aceptación ✅

- ✅ Heatmap por hora del día
- ✅ Heatmap por día de la semana  
- ✅ Vista individual y de equipo
- ✅ Identificación de picos de productividad
- ✅ Insights automáticos

## Arquitectura

### Backend

#### Endpoint Principal
```
GET /api/timelogs/heatmap
```

**Query Parameters:**
- `startDate` (opcional): Fecha de inicio en formato ISO 8601
- `endDate` (opcional): Fecha de fin en formato ISO 8601
- `projectId` (opcional): Filtrar por proyecto específico
- `workspaceId` (opcional): ID del workspace (requerido para vista de equipo)
- `teamView` (boolean): `true` para vista de equipo, `false` para individual

**Response Structure:**
```json
{
  "success": true,
  "message": "Heatmap data retrieved successfully",
  "data": {
    "hourlyData": [0, 0, 0, ..., 0],           // 24 valores (horas 0-23)
    "weeklyData": [0, 0, 0, 0, 0, 0, 0],       // 7 valores (Dom-Sáb)
    "hourlyWeeklyMatrix": [                     // Matriz 7x24
      [0, 0, ...],  // Domingo
      [0, 0, ...],  // Lunes
      ...
    ],
    "totalHours": 42.5,
    "avgHoursPerDay": 6.07,
    "peakHour": 10,                             // 10:00 AM
    "peakDay": 2,                               // Martes (0=Dom, 1=Lun, 2=Mar...)
    "topProductiveSlots": [
      {
        "day": 2,
        "hour": 10,
        "hours": 4.5
      },
      ...
    ],
    "insights": [
      {
        "type": "peak_morning",
        "message": "Mayor productividad en horario matutino (9-12h)",
        "icon": "morning"
      },
      ...
    ],
    "totalLogs": 48
  }
}
```

#### Service Layer

**Archivo:** `backend/src/services/timelog.service.js`

Método principal:
```javascript
async getProductivityHeatmap(userId, { 
  startDate, 
  endDate, 
  projectId, 
  teamView, 
  workspaceId 
})
```

**Lógica de Insights Automáticos:**

1. **Peak Morning/Afternoon:** Identifica si el pico de productividad está en la mañana (9-12h) o tarde (14-18h)
2. **Peak Weekday:** Identifica el día más productivo de la semana
3. **High/Low Productivity:** Evalúa el promedio de horas por día
4. **Top Productive Slots:** Top 3 combinaciones día-hora más productivas

#### Tests

**Archivo:** `backend/tests/timelog.test.js`

Tests implementados:
- ✅ Get productivity heatmap data
- ✅ Filter heatmap by date range
- ✅ Support individual view mode
- ✅ Return valid peak hour and day
- ✅ Return top productive slots

Para ejecutar:
```bash
cd backend
npm test -- timelog.test.js
```

### Frontend

#### Widgets

##### 1. HourlyProductivityHeatmapWidget

**Archivo:** `creapolis_app/lib/presentation/screens/dashboard/widgets/hourly_productivity_heatmap_widget.dart`

**Características:**
- Visualización de barras horizontales para 24 horas (0-23h)
- Color coding en 5 niveles de intensidad
- Toggle individual/equipo
- Insights automáticos con iconos
- Leyenda de colores
- Tooltip con información detallada

**Uso:**
```dart
HourlyProductivityHeatmapWidget(
  isTeamView: false, // individual por defecto
)
```

##### 2. WeeklyProductivityHeatmapWidget

**Archivo:** `creapolis_app/lib/presentation/screens/dashboard/widgets/weekly_productivity_heatmap_widget.dart`

**Características:**
- Matriz de calor 7 días × 24 horas
- Scroll horizontal para ver todas las horas
- Muestra solo franjas horarias clave (9h, 12h, 15h, 18h, 21h)
- Color coding en 5 niveles de intensidad
- Toggle individual/equipo
- Insights automáticos
- Tooltips con información por celda

**Uso:**
```dart
WeeklyProductivityHeatmapWidget(
  isTeamView: false, // individual por defecto
)
```

#### Entities

**Archivo:** `creapolis_app/lib/domain/entities/productivity_heatmap.dart`

Entidades principales:
- `ProductivityHeatmap`: Entidad principal con todos los datos
- `ProductiveSlot`: Representa un slot productivo (día, hora, horas trabajadas)
- `ProductivityInsight`: Representa un insight (tipo, mensaje, icono)

#### Data Layer

**Archivo:** `creapolis_app/lib/data/datasources/time_log_remote_datasource.dart`

Método agregado:
```dart
Future<Map<String, dynamic>> getProductivityHeatmap({
  DateTime? startDate,
  DateTime? endDate,
  int? projectId,
  bool teamView = false,
  int? workspaceId,
})
```

#### Dashboard Integration

**Archivo:** `creapolis_app/lib/domain/entities/dashboard_widget_config.dart`

Nuevos tipos de widget:
- `DashboardWidgetType.hourlyProductivityHeatmap`
- `DashboardWidgetType.weeklyProductivityHeatmap`

**Metadata:**
- Display Name: "Productividad por Hora" / "Productividad por Día"
- Icons: `schedule` / `calendar_view_week`
- Descriptions: Mapas de calor de productividad

## Color Coding

El sistema de colores utiliza 5 niveles de intensidad basados en el porcentaje de horas trabajadas respecto al máximo:

| Intensidad | Rango       | Color                                    |
|-----------|-------------|------------------------------------------|
| Muy Baja  | < 20%       | `surfaceContainerHighest`                |
| Baja      | 20% - 40%   | `primaryContainer` con 40% opacidad      |
| Media     | 40% - 60%   | `primaryContainer` con 60% opacidad      |
| Alta      | 60% - 80%   | `primary` con 70% opacidad               |
| Muy Alta  | > 80%       | `primary`                                |

## Uso en el Dashboard

1. Navegar al Dashboard personalizable
2. Click en "Agregar Widget" (botón +)
3. Seleccionar "Productividad por Hora" o "Productividad por Día"
4. El widget se agrega al dashboard
5. Usar el toggle para cambiar entre vista individual y de equipo
6. Arrastrar para reordenar o eliminar con el botón X

## Próximos Pasos (Opcional)

### Mejoras Sugeridas:
1. **Conectar con API real:** Actualmente los widgets usan datos mock. Integrar con el servicio de datos.
2. **Selector de rango de fechas:** Agregar date picker para filtrar por período
3. **Filtro por proyecto:** Agregar dropdown para filtrar por proyecto específico
4. **Exportar datos:** Permitir exportar el heatmap como imagen o CSV
5. **Animaciones:** Agregar transiciones suaves al cambiar entre vistas
6. **Comparación de períodos:** Permitir comparar dos períodos diferentes
7. **Drill-down:** Click en una celda para ver detalles de las tareas

### Tests Frontend (Pendiente):
1. Unit tests para entidades
2. Widget tests para los heatmaps
3. Integration tests para el flujo completo

## Notas Técnicas

### Prisma Schema
El feature utiliza el modelo `TimeLog` existente:
```prisma
model TimeLog {
  id        Int       @id @default(autoincrement())
  taskId    Int
  userId    Int
  startTime DateTime
  endTime   DateTime?
  duration  Float?
  createdAt DateTime  @default(now())
  updatedAt DateTime  @updatedAt
  task      Task      @relation(fields: [taskId], references: [id])
  user      User      @relation(fields: [userId], references: [id])
  
  @@index([startTime])
}
```

### Consideraciones de Performance

1. **Consultas optimizadas:** El endpoint usa un solo query para obtener todos los time logs necesarios
2. **Cálculos en memoria:** Los agregados se calculan en memoria una vez obtenidos los datos
3. **Índice en startTime:** Asegura que las consultas por rango de fechas sean rápidas
4. **Filtros opcionales:** Todos los filtros son opcionales para no sobrecargar la query

### Seguridad

1. **Autenticación requerida:** Todos los endpoints requieren token JWT válido
2. **Autorización:** Vista individual filtra por userId automáticamente
3. **Vista de equipo:** Solo muestra datos de usuarios en el workspace del usuario actual
4. **Validación de inputs:** Express-validator valida todos los parámetros

## Ejemplos de Uso

### Backend API Call
```bash
# Vista individual de últimos 7 días
curl -X GET "http://localhost:3001/api/timelogs/heatmap?startDate=2024-01-01&endDate=2024-01-07&teamView=false" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Vista de equipo filtrada por proyecto
curl -X GET "http://localhost:3001/api/timelogs/heatmap?projectId=123&teamView=true&workspaceId=456" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Frontend Widget
```dart
// En el dashboard
DashboardWidgetFactory.buildWidget(
  context,
  DashboardWidgetConfig(
    id: 'hourly_heatmap_1',
    type: DashboardWidgetType.hourlyProductivityHeatmap,
    position: 5,
  ),
)
```

## Changelog

### v1.0.0 - 2024-10-13
- ✅ Implementación inicial del endpoint backend
- ✅ Tests completos del endpoint
- ✅ Widgets de Flutter para ambos tipos de heatmap
- ✅ Integración con el sistema de dashboard
- ✅ Data layer completo (entities + datasource)
- ✅ Insights automáticos
- ✅ Vista individual/equipo

## Soporte

Para preguntas o issues, contactar al equipo de desarrollo o crear un issue en el repositorio.
