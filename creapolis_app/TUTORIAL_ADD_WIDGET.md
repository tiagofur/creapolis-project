# 🎓 Tutorial: Cómo Añadir un Nuevo Widget al Dashboard

Este tutorial muestra cómo añadir un nuevo widget personalizado al sistema de widgets del dashboard.

## Ejemplo: Weekly Progress Widget

Vamos a añadir un widget que muestra el progreso semanal de tareas completadas.

### Paso 1: Crear el Widget (Ya hecho)

Ya hemos creado `weekly_progress_widget.dart` como ejemplo.

```dart
// lib/presentation/screens/dashboard/widgets/weekly_progress_widget.dart
class WeeklyProgressWidget extends StatelessWidget {
  const WeeklyProgressWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    // ... implementación del widget
  }
}
```

### Paso 2: Añadir el Tipo al Enum

Editar `lib/domain/entities/dashboard_widget_config.dart`:

```dart
/// Tipos de widgets disponibles para el dashboard
enum DashboardWidgetType {
  quickStats,
  myTasks,
  myProjects,
  recentActivity,
  quickActions,
  workspaceInfo,
  weeklyProgress,  // 👈 AÑADIR AQUÍ
}
```

### Paso 3: Añadir Metadata del Widget

En el mismo archivo `dashboard_widget_config.dart`, añadir metadata en la extensión:

```dart
extension DashboardWidgetTypeExtension on DashboardWidgetType {
  /// Nombre legible del widget
  String get displayName {
    switch (this) {
      // ... casos existentes ...
      case DashboardWidgetType.weeklyProgress:  // 👈 AÑADIR
        return 'Progreso Semanal';
    }
  }

  /// Descripción del widget
  String get description {
    switch (this) {
      // ... casos existentes ...
      case DashboardWidgetType.weeklyProgress:  // 👈 AÑADIR
        return 'Gráfico de progreso de tareas por día';
    }
  }

  /// Icono representativo del widget
  String get iconName {
    switch (this) {
      // ... casos existentes ...
      case DashboardWidgetType.weeklyProgress:  // 👈 AÑADIR
        return 'trending_up';
    }
  }
}
```

### Paso 4: Registrar en el Factory

Editar `lib/presentation/screens/dashboard/widgets/dashboard_widget_factory.dart`:

#### 4.1: Añadir Import

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/dashboard_widget_config.dart';
import '../../../providers/workspace_context.dart';
import '../widgets/daily_summary_card.dart';
import '../widgets/my_projects_widget.dart';
import '../widgets/my_tasks_widget.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/recent_activity_list.dart';
import '../widgets/weekly_progress_widget.dart';  // 👈 AÑADIR
```

#### 4.2: Añadir Case en el Switch

```dart
class DashboardWidgetFactory {
  static Widget buildWidget(
    BuildContext context,
    DashboardWidgetConfig config, {
    VoidCallback? onRemove,
  }) {
    Widget child;

    switch (config.type) {
      // ... casos existentes ...
      
      case DashboardWidgetType.weeklyProgress:  // 👈 AÑADIR
        child = const WeeklyProgressWidget();
        break;
    }

    return DraggableWidget(
      key: ValueKey(config.id),
      config: config,
      onRemove: onRemove,
      child: child,
    );
  }
}
```

### Paso 5: (Opcional) Añadir Icono Custom

Si el icono no está en Material Icons, añadir handler en `add_widget_bottom_sheet.dart`:

```dart
IconData _getIconData(String iconName) {
  switch (iconName) {
    case 'insights':
      return Icons.insights;
    case 'task_alt':
      return Icons.task_alt;
    case 'folder':
      return Icons.folder;
    case 'history':
      return Icons.history;
    case 'grid_view':
      return Icons.grid_view;
    case 'business':
      return Icons.business;
    case 'trending_up':  // 👈 AÑADIR
      return Icons.trending_up;
    default:
      return Icons.widgets;
  }
}
```

### Paso 6: ¡Listo! Probar el Widget

1. Abrir la app y navegar al Dashboard
2. Click en botón "Personalizar"
3. Click en FAB "Añadir Widget"
4. Buscar "Progreso Semanal" en la lista
5. Click para añadirlo
6. El widget aparece en el dashboard
7. Puede arrastrarse, reordenarse y eliminarse como los demás

## 📋 Checklist Rápida

Cuando añades un nuevo widget, asegúrate de:

- [ ] Crear el widget component (`.dart`)
- [ ] Añadir tipo al `DashboardWidgetType` enum
- [ ] Añadir `displayName` en la extensión
- [ ] Añadir `description` en la extensión
- [ ] Añadir `iconName` en la extensión
- [ ] Import del widget en `dashboard_widget_factory.dart`
- [ ] Case del widget en el switch del factory
- [ ] (Opcional) Icono handler en `add_widget_bottom_sheet.dart`
- [ ] Probar añadir, reordenar, eliminar

## 🎯 Buenas Prácticas

### 1. Estructura del Widget

```dart
class MyCustomWidget extends StatelessWidget {
  const MyCustomWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con título e icono
            _buildHeader(context),
            
            const SizedBox(height: 16),
            
            // Contenido principal
            _buildContent(context),
            
            // (Opcional) Footer con acciones
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.my_icon,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Mi Widget',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () => _onViewMore(context),
          child: const Text('Ver más'),
        ),
      ],
    );
  }
  
  // ... resto de métodos
}
```

### 2. Usar Tema Consistentemente

```dart
// ✅ BIEN - Usa colores del tema
color: theme.colorScheme.primary
textStyle: theme.textTheme.titleMedium

// ❌ MAL - Colores hardcodeados
color: Colors.blue
textStyle: TextStyle(fontSize: 16)
```

### 3. Estado Vacío

```dart
Widget _buildContent(BuildContext context) {
  if (data.isEmpty) {
    return _buildEmptyState(context);
  }
  
  return _buildDataList(context);
}

Widget _buildEmptyState(BuildContext context) {
  return Center(
    child: Column(
      children: [
        Icon(Icons.inbox_outlined, size: 48),
        const SizedBox(height: 8),
        Text('No hay datos disponibles'),
      ],
    ),
  );
}
```

### 4. Loading States

```dart
Widget _buildContent(BuildContext context) {
  return BlocBuilder<MyBloc, MyState>(
    builder: (context, state) {
      if (state is LoadingState) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (state is ErrorState) {
        return _buildErrorState(context, state.message);
      }
      
      if (state is LoadedState) {
        return _buildLoadedContent(context, state.data);
      }
      
      return const SizedBox.shrink();
    },
  );
}
```

### 5. Responsive Design

```dart
Widget build(BuildContext context) {
  final isSmallScreen = MediaQuery.of(context).size.width < 600;
  
  return Card(
    child: Padding(
      padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
      child: Column(
        children: [
          // Adaptar layout según tamaño de pantalla
          if (isSmallScreen)
            _buildMobileLayout(context)
          else
            _buildDesktopLayout(context),
        ],
      ),
    ),
  );
}
```

## 🔍 Debugging

### Ver Configuración Actual

```dart
void _debugConfig() {
  final config = DashboardPreferencesService.instance.getDashboardConfig();
  print('Widgets configurados: ${config.widgets.length}');
  for (var widget in config.widgets) {
    print('  - ${widget.type.displayName} (pos: ${widget.position})');
  }
}
```

### Reset Manual (para desarrollo)

```dart
// En una consola o método de debug
await DashboardPreferencesService.instance.resetDashboardConfig();
```

## 📚 Recursos Adicionales

- [Material Design Guidelines](https://m3.material.io/)
- [Flutter Widget Catalog](https://flutter.dev/docs/development/ui/widgets)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)

## 🤝 Contribuir

Al añadir un nuevo widget:

1. Asegúrate de que sigue las guías de estilo
2. Incluye documentación (dartdoc comments)
3. Maneja estados vacíos y de error
4. Usa tema consistentemente
5. Prueba en diferentes tamaños de pantalla
6. Considera accesibilidad (semantic labels, contraste)

## ⚡ Tips Avanzados

### Widget con Configuración Propia

Si tu widget necesita configuración adicional:

```dart
class DashboardWidgetConfig {
  final String id;
  final DashboardWidgetType type;
  final int position;
  final bool isVisible;
  final Map<String, dynamic>? settings;  // 👈 Config adicional

  // Ejemplo de uso:
  // settings: {
  //   'itemCount': 5,
  //   'showDetails': true,
  // }
}
```

### Widget con Actualización Automática

```dart
class LiveDataWidget extends StatefulWidget {
  @override
  State<LiveDataWidget> createState() => _LiveDataWidgetState();
}

class _LiveDataWidgetState extends State<LiveDataWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 30), (_) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  // ...
}
```

### Widget con Animaciones

```dart
class AnimatedWidget extends StatefulWidget {
  @override
  State<AnimatedWidget> createState() => _AnimatedWidgetState();
}

class _AnimatedWidgetState extends State<AnimatedWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  // ...
}
```
