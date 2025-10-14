# 🚀 Quick Start - Sistema de Reportes

## Para Desarrolladores

### Backend Setup (1 minuto)

Las dependencias ya están instaladas. El sistema está listo para usar.

### Frontend Integration (5 minutos)

#### 1. Inyectar el Servicio

Si usas inyección de dependencias (get_it), agregar en tu archivo de DI:

```dart
// lib/injection.dart
import 'package:creapolis_app/presentation/services/report_service.dart';

void configureDependencies() {
  // ... otros servicios
  
  // Report Service
  getIt.registerLazySingleton<ReportService>(
    () => ReportService(getIt<Dio>()),
  );
}
```

Si no usas DI, puedes instanciarlo directamente:

```dart
final reportService = ReportService(dio);
```

#### 2. Agregar Navegación

**Opción A: Desde Pantalla de Proyecto**

```dart
// En tu ProjectDetailScreen o similar
AppBar(
  title: Text(project.name),
  actions: [
    // ... otros botones
    IconButton(
      icon: const Icon(Icons.analytics),
      tooltip: 'Reportes',
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.build),
                  title: const Text('Crear Reporte Personalizado'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportBuilderScreen(
                          reportService: getIt<ReportService>(),
                          project: project,
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.dashboard),
                  title: const Text('Usar Plantilla'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportTemplatesScreen(
                          reportService: getIt<ReportService>(),
                          project: project,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    ),
  ],
)
```

**Opción B: Desde Dashboard**

```dart
// En tu DashboardScreen
GridView(
  children: [
    // ... otros cards
    Card(
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReportTemplatesScreen(
              reportService: getIt<ReportService>(),
              workspace: currentWorkspace,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assessment, size: 48),
            SizedBox(height: 8),
            Text('Reportes'),
          ],
        ),
      ),
    ),
  ],
)
```

**Opción C: Agregar a Router**

Si usas go_router:

```dart
// En tu app_router.dart
GoRoute(
  path: '/reports/builder',
  builder: (context, state) {
    final project = state.extra as Project?;
    return ReportBuilderScreen(
      reportService: getIt<ReportService>(),
      project: project,
    );
  },
),
GoRoute(
  path: '/reports/templates',
  builder: (context, state) {
    final project = state.extra as Project?;
    return ReportTemplatesScreen(
      reportService: getIt<ReportService>(),
      project: project,
    );
  },
),
```

#### 3. Imports Necesarios

```dart
import 'package:creapolis_app/presentation/screens/reports/report_builder_screen.dart';
import 'package:creapolis_app/presentation/screens/reports/report_templates_screen.dart';
import 'package:creapolis_app/presentation/services/report_service.dart';
```

### Listo! 🎉

El sistema está completamente integrado y listo para usar.

---

## Para Usuarios Finales

### Crear un Reporte Personalizado

1. **Abrir el proyecto** del cual quieres un reporte
2. **Tap en el ícono de analytics** (📊) en la barra superior
3. **Seleccionar "Crear Reporte Personalizado"**
4. **Configurar tu reporte:**
   - Nombre descriptivo
   - Seleccionar métricas (Tareas, Progreso, Tiempo, Equipo)
   - Opcionalmente: filtrar por rango de fechas
5. **Tap en "Generar Reporte"**
6. **Vista previa** del reporte
7. **Exportar:**
   - Tap en el ícono de descarga (📥)
   - Elegir formato: PDF, Excel o CSV
   - O compartir directamente

### Usar una Plantilla

1. **Abrir el proyecto**
2. **Tap en analytics** (📊)
3. **Seleccionar "Usar Plantilla"**
4. **Elegir una plantilla:**
   - 📊 Resumen de Proyecto
   - 📋 Proyecto Detallado
   - 👥 Desempeño del Equipo
   - ⏱️ Seguimiento de Tiempo
   - 📈 Resumen Ejecutivo
5. **El reporte se genera automáticamente**
6. **Vista previa y exportar**

### Tips

- 💡 Usa **filtros de fecha** para reportes mensuales o trimestrales
- 💡 **Resumen Ejecutivo** es ideal para stakeholders
- 💡 **Desempeño del Equipo** ayuda en retrospectivas
- 💡 **Exporta a Excel** si necesitas hacer cálculos adicionales
- 💡 **Comparte como PDF** para presentaciones profesionales

---

## Testing Rápido

### Backend (usando cURL)

```bash
# 1. Obtener plantillas
curl -X GET "http://localhost:3001/api/reports/templates" \
  -H "Authorization: Bearer YOUR_TOKEN"

# 2. Generar reporte JSON
curl -X GET "http://localhost:3001/api/reports/project/1?format=json" \
  -H "Authorization: Bearer YOUR_TOKEN"

# 3. Descargar PDF
curl -X GET "http://localhost:3001/api/reports/project/1?format=pdf" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -o reporte.pdf

# 4. Usar plantilla
curl -X POST "http://localhost:3001/api/reports/custom" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "templateId": "project_summary",
    "entityType": "project",
    "entityId": 1,
    "format": "excel"
  }' \
  -o reporte.xlsx
```

### Flutter (Hot Reload)

1. Agregar botón temporal en cualquier pantalla:
```dart
FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportTemplatesScreen(
          reportService: ReportService(dio),
          project: Project(
            id: 1,
            name: "Test Project",
            // ... otros campos requeridos
          ),
        ),
      ),
    );
  },
  child: Icon(Icons.analytics),
)
```

2. Hot reload y probar

---

## Troubleshooting

### "ReportService not found"
Asegúrate de haber agregado el import:
```dart
import 'package:creapolis_app/presentation/services/report_service.dart';
```

### "Cannot find module 'json2csv'"
Reinstalar dependencias del backend:
```bash
cd backend
npm install
```

### "Failed to generate report"
- Verificar que el backend esté corriendo
- Confirmar que tienes datos en el proyecto/workspace
- Revisar que el token de autorización sea válido

### PDF/Excel vacío
- Confirmar que hay tareas en el proyecto
- Verificar que las métricas solicitadas tienen datos
- Revisar logs del backend para errores

---

## Próximos Pasos

Una vez integrado, puedes:

1. **Personalizar plantillas** - Agregar nuevas en `report.service.js`
2. **Agregar métricas** - Extender calculadores de métricas
3. **Mejorar UI** - Customizar colores y estilos
4. **Scheduler** - Agregar cron jobs para reportes automáticos
5. **Email** - Integrar envío de reportes por correo

---

**¿Necesitas ayuda?** 
- Revisa `FASE_2_REPORTES_SISTEMA_COMPLETO.md` para documentación completa
- Revisa `FASE_2_REPORTES_GUIA_VISUAL.md` para guía visual

**Implementado por**: GitHub Copilot Agent  
**Fecha**: 2025-10-14
