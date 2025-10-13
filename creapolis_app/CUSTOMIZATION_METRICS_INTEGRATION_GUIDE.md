# Guía de Integración - Sistema de Métricas de Personalización

## 🎯 Resumen Ejecutivo

Este documento describe cómo integrar y usar el sistema de métricas de personalización implementado en Creapolis.

## ✅ Estado de Implementación

**Completado al 100%** - Todos los criterios de aceptación cumplidos:
- ✅ Registro de cambios y preferencias
- ✅ Dashboard interno para métricas
- ✅ Visualización de estadísticas clave
- ✅ Privacidad y anonimización de datos

## 🚀 Acceso Rápido

### Para Usuarios Finales

1. Abrir la aplicación Creapolis
2. Ir a la pestaña "Más" (More) en la navegación inferior
3. Buscar "Métricas de Personalización" en la sección "Información"
4. Hacer clic para ver el dashboard de métricas

### Para Desarrolladores

```dart
// Navegación programática
context.go('/customization-metrics');

// O usando nombre de ruta
context.goNamed('customization-metrics');
```

## 📊 Funcionalidades Disponibles

### 1. Vista de Métricas

La pantalla muestra:
- **Resumen general**: Total de eventos, usuarios, última actualización
- **Temas más usados**: Gráfico de barras con porcentajes
- **Layouts más usados**: Gráfico de barras con porcentajes
- **Widgets más usados**: Top 10 con gráficos
- **Tipos de eventos**: Distribución de actividades
- **Eventos recientes**: Últimas 10 acciones

### 2. Tracking Automático

El sistema registra automáticamente:
```
✅ Cambio de tema (light → dark, etc.)
✅ Cambio de layout (sidebar → bottomNavigation)
✅ Widget añadido al dashboard
✅ Widget eliminado del dashboard
✅ Reordenamiento de widgets
✅ Reset de dashboard
✅ Exportación de preferencias
✅ Importación de preferencias
```

### 3. Privacidad

**Datos que NO se registran:**
- ❌ Nombres de usuario
- ❌ Emails
- ❌ IDs de usuario
- ❌ Información personal

**Solo se registran:**
- ✅ Tipo de evento
- ✅ Valores de configuración
- ✅ Timestamps
- ✅ Metadatos anónimos

## 💻 Ejemplos de Código

### Tracking Manual de Eventos

```dart
import 'package:creapolis_app/core/services/customization_metrics_service.dart';

final metricsService = CustomizationMetricsService.instance;

// Registrar cambio de tema
await metricsService.trackThemeChange('light', 'dark');

// Registrar cambio de layout
await metricsService.trackLayoutChange('sidebar', 'bottomNavigation');

// Registrar widget añadido
await metricsService.trackWidgetAdded('quickStats');

// Registrar widget eliminado
await metricsService.trackWidgetRemoved('myTasks');

// Registrar reordenamiento
await metricsService.trackWidgetsReordered(['widget1', 'widget2', 'widget3']);

// Registrar reset
await metricsService.trackDashboardReset();
```

### Consultar Métricas

```dart
import 'package:creapolis_app/core/services/customization_metrics_service.dart';

final metricsService = CustomizationMetricsService.instance;

// Obtener todas las métricas
final metrics = metricsService.generateMetrics();

print('Total de eventos: ${metrics.totalEvents}');
print('Temas más usados:');
for (final stat in metrics.themeUsage) {
  print('  ${stat.item}: ${stat.count} (${stat.percentage.toStringAsFixed(1)}%)');
}

// Métricas para los últimos 7 días
final lastWeek = DateTime.now().subtract(Duration(days: 7));
final weeklyMetrics = metricsService.generateMetrics(
  startDate: lastWeek,
  endDate: DateTime.now(),
);

// Obtener eventos específicos
final themeEvents = metricsService.getEventsByType(
  CustomizationEventType.themeChanged,
);
print('Cambios de tema: ${themeEvents.length}');

// Total de eventos
print('Total acumulado: ${metricsService.totalEvents}');
```

### Limpieza de Datos

```dart
import 'package:creapolis_app/core/services/customization_metrics_service.dart';

final metricsService = CustomizationMetricsService.instance;

// Limpiar todos los eventos
final success = await metricsService.clearAllEvents();

if (success) {
  print('Métricas eliminadas correctamente');
} else {
  print('Error al eliminar métricas');
}
```

## 🔧 Configuración Adicional

### Agregar Restricción de Rol Admin

Si deseas restringir el acceso solo a administradores, puedes modificar la ruta:

```dart
// En app_router.dart
GoRoute(
  path: RoutePaths.customizationMetrics,
  name: RouteNames.customizationMetrics,
  redirect: (context, state) {
    // Obtener rol del usuario (ejemplo)
    final userRole = getUserRole(context); // Tu método para obtener rol
    
    if (userRole != UserRole.admin) {
      return '/'; // Redirigir a home si no es admin
    }
    return null; // Permitir acceso si es admin
  },
  builder: (context, state) => const CustomizationMetricsScreen(),
),
```

O agregar verificación en el menú:

```dart
// En more_screen.dart
// Solo mostrar el item si es admin
if (userRole == UserRole.admin) {
  _buildMenuItem(
    context,
    icon: Icons.analytics_outlined,
    title: 'Métricas de Personalización',
    subtitle: 'Estadísticas de uso de UI',
    onTap: () => context.go(RoutePaths.customizationMetrics),
  ),
}
```

## 📱 Testing

### Manual Testing

1. **Generar Eventos**
   ```
   1. Cambiar tema en Settings (light → dark)
   2. Añadir widget "Quick Stats" al dashboard
   3. Eliminar widget "Recent Activity"
   4. Reordenar widgets
   5. Resetear dashboard
   ```

2. **Verificar Métricas**
   ```
   1. Ir a More > Métricas de Personalización
   2. Verificar que se muestran 5+ eventos
   3. Verificar gráficos de temas
   4. Verificar gráficos de widgets
   5. Verificar lista de eventos recientes
   ```

3. **Verificar Persistencia**
   ```
   1. Cerrar app completamente
   2. Reabrir app
   3. Ir a métricas nuevamente
   4. Verificar que datos persisten
   ```

### Unit Testing

```bash
# Ejecutar todos los tests del servicio de métricas
flutter test test/core/services/customization_metrics_service_test.dart

# Ejecutar tests específicos
flutter test test/core/services/customization_metrics_service_test.dart --name "Registro de Eventos"
```

## 🎨 Personalización de UI

### Modificar Colores de Eventos

```dart
// En customization_metrics_screen.dart
Color _getEventTypeColor(CustomizationEventType type) {
  switch (type) {
    case CustomizationEventType.themeChanged:
      return Colors.blue; // Cambiar a tu color preferido
    case CustomizationEventType.widgetAdded:
      return Colors.green; // Cambiar a tu color preferido
    // ... etc
  }
}
```

### Modificar Límite de Eventos

```dart
// En customization_metrics_service.dart
static const int _maxEventsStored = 1000; // Cambiar a tu límite preferido
```

### Cambiar Formato de Fechas

```dart
// En customization_metrics_screen.dart
String _formatDate(DateTime date) {
  return DateFormat('dd/MM/yyyy HH:mm').format(date); // Modificar formato
}
```

## 🔄 Flujo de Datos

```
Usuario realiza acción
    ↓
Servicio de preferencias detecta cambio
    ↓
Llama a CustomizationMetricsService.trackXxx()
    ↓
Evento se crea y almacena en SharedPreferences
    ↓
Usuario abre pantalla de métricas
    ↓
CustomizationMetricsService.generateMetrics()
    ↓
Se calculan estadísticas agregadas
    ↓
UI muestra gráficos y tablas
```

## 📦 Estructura de Archivos

```
creapolis_app/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   └── storage_keys.dart              (modificado)
│   │   └── services/
│   │       ├── customization_metrics_service.dart  (nuevo)
│   │       ├── dashboard_preferences_service.dart  (modificado)
│   │       └── role_based_preferences_service.dart (modificado)
│   ├── domain/
│   │   └── entities/
│   │       ├── customization_event.dart       (nuevo)
│   │       └── customization_metrics.dart     (nuevo)
│   ├── presentation/
│   │   └── screens/
│   │       ├── customization_metrics_screen.dart  (nuevo)
│   │       └── more/
│   │           └── more_screen.dart           (modificado)
│   ├── routes/
│   │   └── app_router.dart                    (modificado)
│   └── main.dart                              (modificado)
└── test/
    └── core/
        └── services/
            └── customization_metrics_service_test.dart  (nuevo)
```

## 🐛 Troubleshooting

### Problema: No se registran eventos

**Solución:**
1. Verificar que el servicio esté inicializado en `main.dart`
2. Comprobar logs en consola para errores
3. Verificar que SharedPreferences tenga permisos

### Problema: Métricas no persisten

**Solución:**
1. Verificar que `_saveEvents()` se llame después de cada evento
2. Comprobar que SharedPreferences funcione correctamente
3. Revisar logs de error en el servicio

### Problema: Pantalla vacía

**Solución:**
1. Verificar que haya al menos un evento registrado
2. Comprobar que el servicio esté inicializado
3. Verificar navegación a la ruta correcta

## 📞 Soporte

Para dudas o problemas:
1. Revisar documentación completa en `CUSTOMIZATION_METRICS_COMPLETED.md`
2. Revisar tests en `test/core/services/customization_metrics_service_test.dart`
3. Consultar código fuente con comentarios inline

## ✨ Próximas Mejoras Sugeridas

1. **Backend Integration**
   - Sincronizar eventos con servidor
   - Métricas agregadas de todos los usuarios
   - Dashboard centralizado para administradores

2. **Visualizaciones Avanzadas**
   - Gráficos de línea para tendencias temporales
   - Mapa de calor de actividad
   - Comparativas entre períodos

3. **Exportación**
   - Exportar a CSV
   - Exportar a PDF
   - Compartir reportes

4. **Notificaciones**
   - Alertas cuando se alcancen umbrales
   - Reportes periódicos automáticos
   - Resumen semanal/mensual

---

**Última actualización:** 2025-10-13  
**Versión:** 1.0.0  
**Estado:** ✅ Completado
