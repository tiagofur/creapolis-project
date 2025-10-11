# 📱 Guía de Migración del Router

## 🎯 Resumen de Cambios

Hemos actualizado el sistema de rutas para:

1. ✅ **Eliminar el hash (#) de las URLs** - URLs limpias como `/workspaces/1/projects/5`
2. ✅ **Incluir IDs en las rutas** - Contexto completo en la URL
3. ✅ **Estructura anidada** - Refleja la jerarquía workspace → project → task
4. ✅ **Soporte para deep linking** - URLs compartibles
5. ✅ **Mejor experiencia en refresh** - Mantiene el contexto

## 🆕 Nueva Estructura de URLs

### Antes (❌ URLs antiguas)

```
http://localhost:49690/#/projects
http://localhost:49690/#/projects/5
http://localhost:49690/#/projects/5/tasks/10
```

### Después (✅ URLs nuevas)

```
http://localhost:49690/workspaces
http://localhost:49690/workspaces/1/projects
http://localhost:49690/workspaces/1/projects/5
http://localhost:49690/workspaces/1/projects/5/tasks/10
http://localhost:49690/workspaces/1/projects/5/gantt
```

## 🔧 Cómo Usar las Nuevas Rutas

### Opción 1: Extension Methods (✨ RECOMENDADO)

Importa el helper:

```dart
import 'package:creapolis_app/routes/route_builder.dart';
```

Usa los extension methods directamente en `BuildContext`:

```dart
// Navegación simple
context.goToWorkspaces();
context.goToProjects(workspaceId);
context.goToProject(workspaceId, projectId);
context.goToTask(workspaceId, projectId, taskId);

// Vistas especiales
context.goToGantt(workspaceId, projectId);
context.goToWorkload(workspaceId, projectId);

// Push (mantiene en el stack)
context.pushToProject(workspaceId, projectId);
context.pushToTask(workspaceId, projectId, taskId);
```

### Opción 2: RouteBuilder Class

```dart
import 'package:creapolis_app/routes/route_builder.dart';
import 'package:go_router/go_router.dart';

// Construir la ruta
final route = RouteBuilder.projectDetail(workspaceId, projectId);

// Navegar
context.go(route);
context.push(route);
```

### Opción 3: RoutePaths (legacy, pero funciona)

```dart
import 'package:creapolis_app/routes/app_router.dart';
import 'package:go_router/go_router.dart';

final route = RoutePaths.projectDetail(workspaceId, projectId);
context.go(route);
```

## 📝 Ejemplos de Migración

### Ejemplo 1: Navegar a un Proyecto

**Antes:**

```dart
context.push('/projects/$projectId');
```

**Después:**

```dart
// Con extension method (RECOMENDADO)
context.goToProject(workspaceId, projectId);

// O con RouteBuilder
context.push(RouteBuilder.projectDetail(workspaceId, projectId));
```

### Ejemplo 2: Navegar a una Tarea

**Antes:**

```dart
context.push('/projects/$projectId/tasks/$taskId');
```

**Después:**

```dart
// Con extension method (RECOMENDADO)
context.goToTask(workspaceId, projectId, taskId);

// O con RouteBuilder
context.push(RouteBuilder.taskDetail(workspaceId, projectId, taskId));
```

### Ejemplo 3: Navegar al Gantt Chart

**Antes:**

```dart
context.push('/projects/$projectId/gantt');
```

**Después:**

```dart
// Con extension method (RECOMENDADO)
context.goToGantt(workspaceId, projectId);

// O con RouteBuilder
context.push(RouteBuilder.gantt(workspaceId, projectId));
```

## 🔍 Obtener el WorkspaceId

En muchos casos, necesitarás el `workspaceId` actual. Aquí algunas opciones:

### Desde el Provider

```dart
import 'package:provider/provider.dart';
import 'package:creapolis_app/presentation/providers/workspace_provider.dart';

final workspaceProvider = context.read<WorkspaceProvider>();
final workspaceId = workspaceProvider.currentWorkspace?.id ?? 0;

// Navegar
context.goToProjects(workspaceId);
```

### Desde los Parámetros de la Ruta (si ya estás en una ruta con workspace)

```dart
// En un screen que recibe el workspaceId
class ProjectsListScreen extends StatelessWidget {
  final int? workspaceId;

  const ProjectsListScreen({this.workspaceId});

  @override
  Widget build(BuildContext context) {
    // Usar el workspaceId recibido
    final wId = workspaceId ?? context.read<WorkspaceProvider>().currentWorkspace?.id ?? 0;

    // Navegar a un proyecto
    onProjectTap: (projectId) => context.goToProject(wId, projectId),
  }
}
```

## 📋 Lista de Archivos a Actualizar

Estos archivos contienen navegación que debe actualizarse:

### 🔴 Alta Prioridad (rompe la funcionalidad)

- [ ] `lib/presentation/screens/projects/projects_list_screen.dart`
- [ ] `lib/presentation/screens/projects/project_detail_screen.dart`
- [ ] `lib/presentation/screens/tasks/tasks_list_screen.dart`
- [ ] `lib/presentation/screens/tasks/task_detail_screen.dart`
- [ ] `lib/presentation/widgets/project_card.dart`
- [ ] `lib/presentation/widgets/task_card.dart`

### 🟡 Media Prioridad (funcionalidad reducida)

- [ ] `lib/presentation/screens/gantt/gantt_chart_screen.dart`
- [ ] `lib/presentation/screens/workload/workload_screen.dart`
- [ ] `lib/presentation/screens/workspace/workspace_list_screen.dart`
- [ ] `lib/presentation/widgets/app_drawer.dart`

### 🟢 Baja Prioridad (edge cases)

- [ ] `lib/presentation/screens/auth/login_screen.dart`
- [ ] `lib/presentation/screens/auth/register_screen.dart`

## ⚠️ Consideraciones Importantes

### 1. Workspace Context Obligatorio

Todas las rutas de proyectos y tareas **requieren un workspaceId**. Si no tienes un workspace activo, debes:

- Redirigir a `/workspaces` para que el usuario seleccione uno
- O usar el workspace por defecto del usuario

### 2. Deep Linking

Las nuevas URLs son compartibles. Si alguien abre:

```
http://localhost:49690/workspaces/1/projects/5/tasks/10
```

La aplicación debe:

1. Verificar autenticación
2. Validar permisos al workspace
3. Cargar el workspace, proyecto y tarea
4. Mostrar la pantalla correcta

### 3. Refresh Behavior

Con las nuevas rutas, al hacer refresh:

- La URL se mantiene (ej: `/workspaces/1/projects/5`)
- GoRouter parsea los parámetros (wId=1, pId=5)
- El screen recibe estos parámetros y carga los datos

### 4. Back Button

El navegador respeta la jerarquía:

```
/workspaces/1/projects/5/tasks/10
         ↓ back
/workspaces/1/projects/5
         ↓ back
/workspaces/1/projects
         ↓ back
/workspaces/1
         ↓ back
/workspaces
```

## 🎓 Mejores Prácticas

### ✅ DO

```dart
// Usar extension methods
context.goToProject(workspaceId, projectId);

// Validar workspaceId antes de navegar
if (workspaceId > 0) {
  context.goToProject(workspaceId, projectId);
} else {
  context.goToWorkspaces();
}

// Pasar IDs como parámetros, no como strings en la ruta
context.goToTask(workspaceId, projectId, taskId);
```

### ❌ DON'T

```dart
// No construir rutas manualmente
context.push('/workspaces/$wId/projects/$pId'); // ❌

// No usar pushNamed sin named routes
context.pushNamed('project', params: {...}); // ❌

// No navegar sin validar workspace
context.goToProject(0, projectId); // ❌ No workspace!
```

## 🚀 Próximos Pasos

1. **Actualizar Screens Críticos** (ProjectsListScreen, ProjectDetailScreen, etc.)
2. **Actualizar Widgets de Navegación** (ProjectCard, TaskCard, AppDrawer)
3. **Implementar Deep Link Handler** para validar permisos en URLs compartidas
4. **Agregar State Restoration** para mantener scroll position, filtros, etc.
5. **Testing** de todas las rutas y navegación

## 📚 Referencias

- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Flutter URL Strategy](https://docs.flutter.dev/ui/navigation/url-strategies)
- [Deep Linking in Flutter](https://docs.flutter.dev/ui/navigation/deep-linking)
