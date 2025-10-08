# Diagrama de Flujo: Solución del Bug de Lista de Tareas

## ANTES (Problema)

```
┌─────────────────────────────────────────────────────────────────┐
│                      TaskBloc GLOBAL (Singleton)                 │
│                    Compartido por todas las pantallas            │
└─────────────────────────────────────────────────────────────────┘
                                   │
                    ┌──────────────┴──────────────┐
                    │                             │
                    ▼                             ▼
        ┌───────────────────────┐    ┌───────────────────────┐
        │  TasksListScreen      │    │  TaskDetailScreen     │
        │  Estado: TasksLoaded  │    │  Llama: LoadTaskById  │
        │  (lista de tareas)    │    │  Estado: TaskLoaded   │
        └───────────────────────┘    │  (una tarea)          │
                    ▲                 └───────────────────────┘
                    │                             │
                    │      ← Al regresar ←        │
                    └─────────────────────────────┘
                              ❌ PROBLEMA:
                    El estado es TaskLoaded (detalle),
                    no TasksLoaded (lista)
                    → Spinner infinito
```

## DESPUÉS (Solución)

```
┌─────────────────────────────────────────────────────────────────┐
│                      TaskBloc GLOBAL                             │
│              Usado SOLO por TasksListScreen                      │
│                   Estado: TasksLoaded                            │
└─────────────────────────────────────────────────────────────────┘
                             │
                             ▼
              ┌───────────────────────┐
              │  TasksListScreen      │
              │  Estado: TasksLoaded  │
              │  (lista de tareas)    │
              └───────────────────────┘
                             │
                             │  Navega a detalle →
                             ▼
              ┌───────────────────────┐
              │  TaskDetailScreen     │
              │                       │
              │  ┌─────────────────┐  │
              │  │ TaskBloc LOCAL  │  │
              │  │ (instancia nueva)│ │
              │  │ Estado: TaskLoaded│ │
              │  └─────────────────┘  │
              └───────────────────────┘
                             │
                             │  ← Regresa (BLoC local se cierra)
                             ▼
              ┌───────────────────────┐
              │  TasksListScreen      │
              │  Estado: TasksLoaded  │ ✅ CORRECTO
              │  (lista de tareas)    │
              └───────────────────────┘
```

## Ciclo de Vida del BLoC Local

```
TaskDetailScreen lifecycle:
─────────────────────────────────────────────────

initState()
   │
   ├─► _taskBloc = getIt<TaskBloc>()    ← Crea NUEVA instancia
   │
   └─► _taskBloc.add(LoadTaskByIdEvent) ← Carga tarea en BLoC LOCAL


Usuario ve la tarea...


dispose()
   │
   └─► _taskBloc.close()                ← Limpia BLoC LOCAL


Regresa a TasksListScreen
   │
   └─► BLoC GLOBAL sigue intacto       ✅ Estado preservado
```

## Inyección de Dependencias

```dart
// TaskBloc configurado con @injectable (NO singleton)
@injectable
class TaskBloc extends Bloc<TaskEvent, TaskState> { ... }

// Esto permite crear múltiples instancias:
final taskBlocGlobal = getIt<TaskBloc>();   // Para lista
final taskBlocLocal = getIt<TaskBloc>();    // Para detalle
// ↑ Son dos instancias DIFERENTES
```

## Beneficios de la Solución

✅ **Aislamiento de Estado**: El detalle no afecta la lista
✅ **Sin Recarga Innecesaria**: La lista mantiene su estado
✅ **Memoria Eficiente**: BLoC local se libera al salir
✅ **Escalable**: Fácil agregar más pantallas de detalle
✅ **Testeable**: Cada pantalla puede testearse independientemente
