# 🎨 Demo: Personalización Visual de Workflows

Este directorio contiene pantallas de demostración para características de la aplicación.

## ProjectVisualsDemo

**Archivo**: `project_visuals_demo.dart`

### Descripción
Pantalla de demostración que muestra los tres tipos de relación con proyectos:
1. **Personal** - Proyecto sin compartir
2. **Compartido por mí** - Proyecto que el usuario comparte con otros
3. **Compartido conmigo** - Proyecto compartido por otro usuario

### Cómo Acceder

#### Opción 1: Agregar a las rutas (Recomendado para desarrollo)

Editar `lib/routes/app_router.dart`:

```dart
GoRoute(
  path: '/demo/project-visuals',
  builder: (context, state) => const ProjectVisualsDemo(),
),
```

Luego navegar desde cualquier pantalla:
```dart
context.push('/demo/project-visuals');
```

#### Opción 2: Agregar botón temporal en ProjectsListScreen

En `lib/presentation/screens/projects/projects_list_screen.dart`, agregar en el AppBar:

```dart
IconButton(
  icon: const Icon(Icons.palette),
  tooltip: 'Demo Visual',
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProjectVisualsDemo(),
      ),
    );
  },
),
```

#### Opción 3: Ejecutar directamente

Crear archivo temporal `main_demo.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:creapolis_app/core/theme/app_theme.dart';
import 'package:creapolis_app/presentation/screens/demo/project_visuals_demo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo Visual',
      theme: AppTheme.lightTheme,
      home: const ProjectVisualsDemo(),
    );
  }
}
```

Ejecutar:
```bash
flutter run -t lib/main_demo.dart
```

### Características

La demo muestra:

- ✅ 3 tipos de ProjectCard con diferentes relaciones
- ✅ Marcadores visuales en acción
- ✅ Ejemplos de marcadores standalone
- ✅ Información sobre el esquema de colores
- ✅ Diseño responsive
- ✅ Interacción con tap

### Uso

Simplemente abrir la pantalla y observar:

1. **Primer card** - Proyecto Personal (sin marcador)
2. **Segundo card** - Compartido por mí (badge púrpura)
3. **Tercer card** - Compartido conmigo (badge verde)

Hacer tap en cualquier card mostrará un SnackBar con el tipo de proyecto.

### Notas

⚠️ Esta es una pantalla de **demostración** con datos de ejemplo hardcoded.
No debe incluirse en producción. Se recomienda:

1. Usar solo en modo DEBUG
2. Eliminar antes del release
3. O agregar detrás de feature flag

### Ver También

- `WORKFLOW_VISUAL_PERSONALIZATION.md` - Documentación completa
- `WORKFLOW_VISUAL_TESTING_GUIDE.md` - Guía de testing
- `WORKFLOW_VISUAL_IMPLEMENTATION_SUMMARY.md` - Resumen de implementación
