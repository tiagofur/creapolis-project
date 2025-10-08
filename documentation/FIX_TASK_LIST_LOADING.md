# Fix: Lista de Tareas Queda Eternamente Cargando

## Problema

Cuando el usuario navegaba desde un proyecto a una tarea específica y luego regresaba al proyecto, la lista de tareas quedaba con un spinner infinito de carga.

## Causa Raíz

El `TaskBloc` era compartido globalmente en toda la aplicación (singleton en `main.dart`). Cuando se navegaba a la pantalla de detalle de tarea:

1. **TasksListScreen** tenía el BLoC en estado `TasksLoaded` (con la lista de tareas)
2. **TaskDetailScreen** llamaba a `LoadTaskByIdEvent` en el **mismo BLoC**
3. El estado cambiaba a `TaskLoading` → `TaskLoaded` (con una sola tarea)
4. Al regresar, **TasksListScreen** seguía escuchando el mismo BLoC pero ahora en estado `TaskLoaded` (detalle), no `TasksLoaded` (lista)
5. El `BlocBuilder` no encontraba el estado `TasksLoaded`, causando el spinner infinito

## Solución

Se implementaron dos cambios principales:

### 1. TaskBloc Local para TaskDetailScreen

- Creamos una instancia local de `TaskBloc` para la pantalla de detalle
- Esto evita que el detalle modifique el estado del BLoC global usado por la lista
- El BLoC local se cierra cuando se sale de la pantalla

**Archivo modificado:** `lib/presentation/screens/tasks/task_detail_screen.dart`

```dart
class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late final TimeTrackingBloc _timeTrackingBloc;
  late final TaskBloc _taskBloc; // ← BLoC local

  @override
  void initState() {
    super.initState();
    _taskBloc = getIt<TaskBloc>(); // ← Instancia separada
    _taskBloc.add(LoadTaskByIdEvent(widget.taskId));
    // ...
  }

  @override
  void dispose() {
    _taskBloc.close(); // ← Se limpia al salir
    _timeTrackingBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskBloc>.value(value: _taskBloc), // ← Proporciona el BLoC local
        // ...
      ],
      // ...
    );
  }
}
```

### 2. Mejora en TasksListScreen

- Agregamos `WidgetsBindingObserver` para detectar cuando la pantalla vuelve a estar visible
- Verificamos el estado del BLoC antes de recargar (evita cargas innecesarias)
- Solo recargamos si no estamos ya en el estado correcto

**Archivo modificado:** `lib/presentation/screens/tasks/tasks_list_screen.dart`

```dart
class _TasksListScreenState extends State<TasksListScreen>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTasks();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadTasks(); // ← Recarga cuando vuelve a estar visible
    }
  }

  void _loadTasks() {
    final currentState = context.read<TaskBloc>().state;
    // Solo cargar si no estamos ya en TasksLoaded
    if (currentState is! TasksLoaded) {
      context.read<TaskBloc>().add(LoadTasksByProjectEvent(widget.projectId));
    }
  }
}
```

### 3. Actualización del Router

- Pasamos el `projectId` al `TaskDetailScreen` para que sepa a qué proyecto pertenece

**Archivo modificado:** `lib/routes/app_router.dart`

```dart
GoRoute(
  path: RoutePaths.taskDetail,
  name: RouteNames.taskDetail,
  builder: (context, state) {
    final projectId = state.pathParameters['projectId'] ?? '0';
    final taskId = state.pathParameters['taskId'] ?? '0';
    return TaskDetailScreen(
      taskId: int.parse(taskId),
      projectId: int.parse(projectId), // ← Nuevo parámetro
    );
  },
),
```

## Verificación

El código fue verificado con:

- ✅ `flutter analyze` - Sin errores críticos
- ✅ `flutter test` - Todos los tests pasaron

## Patrón de Diseño

Esta solución sigue el patrón **BLoC por Pantalla** para pantallas de detalle:

- **BLoC Global**: Para listas y vistas compartidas (TasksListScreen usa el global)
- **BLoC Local**: Para vistas de detalle que no deben afectar el estado compartido (TaskDetailScreen)

## Alternativas Consideradas

1. **Preservar ambos estados**: Modificar el BLoC para mantener tanto lista como detalle → Más complejo, innecesario
2. **Recargar siempre**: Hacer que TasksListScreen recargue en `initState` → Ineficiente, llamadas API innecesarias
3. **Usar diferentes estados**: Crear estados separados → Requiere cambios mayores en la arquitectura

## Fecha

8 de octubre de 2025
