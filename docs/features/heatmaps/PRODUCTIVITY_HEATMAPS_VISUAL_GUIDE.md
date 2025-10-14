# 📊 Productivity Heatmaps - Visual Guide

## HourlyProductivityHeatmapWidget

```
╔═══════════════════════════════════════════════════════╗
║  🕐 Productividad por Hora        Individual [Toggle] ║
║  Horas trabajadas por franja horaria                  ║
╠═══════════════════════════════════════════════════════╣
║                                                        ║
║  00h ░░░░░░░░░░░░░░░░░░░░░░░░░░░░  0.0h              ║
║  01h ░░░░░░░░░░░░░░░░░░░░░░░░░░░░  0.0h              ║
║  02h ░░░░░░░░░░░░░░░░░░░░░░░░░░░░  0.0h              ║
║  ...                                                   ║
║  08h ▓░░░░░░░░░░░░░░░░░░░░░░░░░░░  0.5h              ║
║  09h ▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░░  1.2h              ║
║  10h ▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░░░  2.8h ⭐ PEAK     ║
║  11h ▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░  4.5h              ║
║  12h ▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░░░  3.2h              ║
║  13h ▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░  1.5h              ║
║  14h ▓▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░  2.1h              ║
║  15h ▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░░  3.8h              ║
║  16h ▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░  4.2h              ║
║  17h ▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░░░  3.5h              ║
║  18h ▓▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░  2.0h              ║
║  19h ▓░░░░░░░░░░░░░░░░░░░░░░░░░░░  0.9h              ║
║  20h ░░░░░░░░░░░░░░░░░░░░░░░░░░░░  0.3h              ║
║  ...                                                   ║
╠═══════════════════════════════════════════════════════╣
║  Legend: Menor [░][▒][▓][█][█] Mayor                 ║
╠═══════════════════════════════════════════════════════╣
║  📊 Insights                                          ║
║  ☀️  Mayor productividad en horario matutino (9-12h) ║
║  📈  Pico de actividad a las 10:00 AM                ║
║  📅  Promedio de 6.5 horas/día                       ║
╚═══════════════════════════════════════════════════════╝
```

### Características:
- 24 barras horizontales (una por hora)
- Color coding con 5 niveles de intensidad
- Identificación automática del pico horario
- Toggle para cambiar entre vista individual/equipo
- Insights generados automáticamente

---

## WeeklyProductivityHeatmapWidget

```
╔════════════════════════════════════════════════════════════════╗
║  📅 Productividad por Día         Individual [Toggle]          ║
║  Mapa de calor hora × día de la semana                         ║
╠════════════════════════════════════════════════════════════════╣
║      9h    12h   15h   18h   21h                               ║
║ Lun  0.5   1.5   0.8   0.5   0.0                               ║
║      ░░    ▒▒    ░░    ░░    ░░                                ║
║                                                                 ║
║ Mar  0.8   2.1   1.8   1.2   0.0   ⭐ DÍA MÁS PRODUCTIVO       ║
║      ▒▒    ▓▓    ▓▓    ▒▒    ░░                                ║
║                                                                 ║
║ Mié  0.6   1.8   1.2   0.9   0.0                               ║
║      ▒▒    ▓▓    ▒▒    ▒▒    ░░                                ║
║                                                                 ║
║ Jue  0.7   1.9   1.5   1.0   0.0                               ║
║      ▒▒    ▓▓    ▓▓    ▒▒    ░░                                ║
║                                                                 ║
║ Vie  0.4   1.2   0.9   0.6   0.0                               ║
║      ░░    ▒▒    ▒▒    ░░    ░░                                ║
║                                                                 ║
║ Sáb  0.2   0.8   0.0   0.0   0.0                               ║
║      ░░    ░░    ░░    ░░    ░░                                ║
║                                                                 ║
║ Dom  0.0   0.0   0.0   0.0   0.0                               ║
║      ░░    ░░    ░░    ░░    ░░                                ║
╠════════════════════════════════════════════════════════════════╣
║  Legend: Menor [░][▒][▓][█][█] Mayor                          ║
╠════════════════════════════════════════════════════════════════╣
║  📊 Insights                                                   ║
║  📅  Martes es tu día más productivo                          ║
║  ⏰  Pico de productividad: Martes 10:00 AM                   ║
║  📈  Promedio de 6.2 horas/día laboral                        ║
╚════════════════════════════════════════════════════════════════╝
```

### Características:
- Matriz de calor 7 días × múltiples horas
- Scroll horizontal para ver todas las franjas
- Tooltips interactivos por celda
- Identificación de patrones semanales
- Color coding consistente con el widget horario
- Toggle individual/equipo

---

## Color Coding System

Los colores representan la intensidad de productividad:

```
░░ Muy Baja  (<20%)  - surfaceContainerHighest
▒▒ Baja      (20-40%) - primaryContainer 40%
▓▓ Media     (40-60%) - primaryContainer 60%
██ Alta      (60-80%) - primary 70%
██ Muy Alta  (>80%)   - primary 100%
```

---

## Dashboard Integration

```
╔══════════════════════════════════════════════════════╗
║  🏠 Dashboard                                         ║
╠══════════════════════════════════════════════════════╣
║  [+] Agregar Widget                                  ║
╠══════════════════════════════════════════════════════╣
║                                                       ║
║  ┌─────────────────────────────────────────────┐    ║
║  │ 📊 Resumen del Día                    [≡][×]│    ║
║  │ Tareas: 5   Proyectos: 2   Horas: 6.5      │    ║
║  └─────────────────────────────────────────────┘    ║
║                                                       ║
║  ┌─────────────────────────────────────────────┐    ║
║  │ 🕐 Productividad por Hora         [≡][×]    │    ║
║  │ [Hourly Heatmap Widget]                     │    ║
║  │                                              │    ║
║  │ 09h ▓▓░░░ 1.2h                              │    ║
║  │ 10h ▓▓▓▓░ 2.8h ⭐                           │    ║
║  │ 11h ▓▓▓▓▓ 4.5h                              │    ║
║  │ ...                                          │    ║
║  └─────────────────────────────────────────────┘    ║
║                                                       ║
║  ┌─────────────────────────────────────────────┐    ║
║  │ 📅 Productividad por Día          [≡][×]    │    ║
║  │ [Weekly Heatmap Matrix]                     │    ║
║  │                                              │    ║
║  │      9h  12h  15h  18h                      │    ║
║  │ Lun  ░░  ▒▒   ░░   ░░                       │    ║
║  │ Mar  ▒▒  ▓▓   ▓▓   ▒▒  ⭐                   │    ║
║  │ ...                                          │    ║
║  └─────────────────────────────────────────────┘    ║
╚══════════════════════════════════════════════════════╝
```

### Features del Dashboard:
- ✅ Drag & drop para reordenar widgets
- ✅ Botón [≡] para arrastrar
- ✅ Botón [×] para eliminar
- ✅ Hover para mostrar controles
- ✅ Configuración persistente
- ✅ Widgets totalmente responsivos

---

## API Response Example

```json
{
  "success": true,
  "message": "Heatmap data retrieved successfully",
  "data": {
    "hourlyData": [
      0, 0, 0, 0, 0, 0, 0, 0.5, 1.2, 2.8, 4.5, 3.2, 
      1.5, 0.8, 2.1, 3.8, 4.2, 3.5, 2.0, 0.9, 0.3, 0, 0, 0
    ],
    "weeklyData": [0.5, 6.8, 7.2, 6.5, 5.1, 2.8, 0],
    "hourlyWeeklyMatrix": [
      [0, 0, ...], // Domingo
      [0.5, 1.2, ...], // Lunes
      [0.8, 2.1, ...], // Martes (más productivo)
      // ... resto de días
    ],
    "totalHours": 42.5,
    "avgHoursPerDay": 6.07,
    "peakHour": 10,
    "peakDay": 2,
    "topProductiveSlots": [
      { "day": 2, "hour": 10, "hours": 4.5 },
      { "day": 2, "hour": 11, "hours": 4.2 },
      { "day": 1, "hour": 10, "hours": 3.8 }
    ],
    "insights": [
      {
        "type": "peak_morning",
        "message": "Mayor productividad en horario matutino (9-12h)",
        "icon": "morning"
      },
      {
        "type": "peak_weekday",
        "message": "Martes es tu día más productivo",
        "icon": "calendar"
      },
      {
        "type": "high_productivity",
        "message": "Promedio alto de 6.1 horas/día",
        "icon": "trending_up"
      }
    ],
    "totalLogs": 48
  }
}
```

---

## Usage Examples

### Adding to Dashboard
```dart
// Usuario hace click en "Agregar Widget"
// Selecciona "Productividad por Hora"
// Sistema crea:
DashboardWidgetConfig(
  id: 'hourly_heatmap_123',
  type: DashboardWidgetType.hourlyProductivityHeatmap,
  position: 5,
  isVisible: true,
)
```

### Calling Backend API
```bash
# Individual view - últimos 7 días
GET /api/timelogs/heatmap?startDate=2024-10-07&endDate=2024-10-13&teamView=false

# Team view - último mes, proyecto específico
GET /api/timelogs/heatmap?startDate=2024-09-13&endDate=2024-10-13&teamView=true&projectId=42&workspaceId=7
```

---

## Insights Types

| Type | Message Example | Icon | Trigger Condition |
|------|----------------|------|-------------------|
| peak_morning | Mayor productividad en horario matutino (9-12h) | morning ☀️ | Peak hour entre 9-12 |
| peak_afternoon | Mayor productividad en horario vespertino (14-18h) | afternoon 🌆 | Peak hour entre 14-18 |
| peak_weekday | Martes es tu día más productivo | calendar 📅 | Peak day entre Lun-Vie |
| high_productivity | Promedio alto de 6.5 horas/día | trending_up 📈 | Avg > 6 horas/día |
| low_productivity | Promedio bajo de 2.5 horas/día | trending_down 📉 | Avg < 3 horas/día |

---

## Interactive Features

### Hourly Widget
- ✅ Hover sobre barra → muestra tooltip con hora exacta
- ✅ Toggle individual/equipo → recarga datos
- ✅ Identificación visual del pico (⭐)
- ✅ Animación suave de colores

### Weekly Widget  
- ✅ Hover sobre celda → tooltip con "Día HH:MM - X.Xh"
- ✅ Scroll horizontal para ver todas las horas
- ✅ Identificación del día más productivo
- ✅ Click en celda → (futuro) drill-down a tareas

---

## Performance Considerations

### Backend
- ✅ Single query para obtener todos los time logs
- ✅ Cálculos en memoria (eficiente)
- ✅ Índice en startTime para queries rápidas
- ✅ Filtros opcionales (no sobrecarga)

### Frontend
- ✅ Lazy loading de widgets
- ✅ Datos cacheados en provider
- ✅ Rebuild solo cuando cambian datos
- ✅ Scroll performance optimizado

---

## Security

- ✅ JWT authentication required
- ✅ Individual view: auto-filtra por userId
- ✅ Team view: solo workspace members
- ✅ Input validation con express-validator
- ✅ Rate limiting aplicado
- ✅ CORS configurado

---

This visual guide shows exactly how the productivity heatmaps look and function in the application.
