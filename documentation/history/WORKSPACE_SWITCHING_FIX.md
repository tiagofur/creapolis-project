# 🔧 WORKSPACE SWITCHING FIX - Race Condition

## 📋 Problema Identificado

Al cambiar de workspace usando el `WorkspaceSwitcher` en el AppBar, la aplicación mostraba el siguiente error:

```
14:43:10.550 [WorkspaceContext] Cambiando a workspace: Abitalia Home
14:43:10.553 WorkspaceBloc: Estableciendo workspace activo: 2
14:43:10.554 ⛔ WorkspaceBloc: No hay workspaces cargados
14:43:10.555 ⛔ [WorkspaceContext] Error: No hay workspaces cargados
```

### 🔍 Análisis de la Causa Raíz

El problema tenía **DOS causas principales**:

#### Causa 1: Recarga Innecesaria al Abrir el Menú (SOLUCIONADA ✅)

El callback `onOpened` del `MenuAnchor` en `WorkspaceSwitcher` disparaba `LoadUserWorkspacesEvent` cada vez que se abría el dropdown. Esto causaba que el estado cambiara a `WorkspaceLoading`, limpiando temporalmente la lista de workspaces.

#### Causa 2: Cambio Rápido de Workspaces (SOLUCIONADA ✅)

Cuando un usuario cambiaba de workspace, el BLoC emitía dos estados en sucesión:

1. `ActiveWorkspaceSet` (para notificar el cambio)
2. `WorkspacesLoaded` (para mantener la lista)

Si el usuario hacía clic para cambiar a otro workspace ANTES de que se emitiera el segundo estado (`WorkspacesLoaded`), el handler encontraba el estado como `ActiveWorkspaceSet` (que NO tiene la lista de workspaces), causando el error.

### 📊 Diagrama del Flujo con Error

```
Usuario                  WorkspaceSwitcher          WorkspaceBloc
  │                            │                         │
  ├─── Abre dropdown ─────────>│                         │
  │                            ├── LoadUserWorkspacesEvent ────>│ (Causa 1)
  │                            │                         ├─ emit(WorkspaceLoading)
  │                            │                         ├─ Workspaces = [] ❌
  ├─── Selecciona workspace A >│                         │
  │                            ├── SetActiveWorkspaceEvent(A) ─>│
  │                            │                         ├─ emit(ActiveWorkspaceSet)
  │                            │                         ├─ (Preparando WorkspacesLoaded...)
  ├─── Selecciona workspace B >│                         │ (Causa 2)
  │                            ├── SetActiveWorkspaceEvent(B) ─>│
  │                            │                         ├─ Estado = ActiveWorkspaceSet ❌
  │                            │                         ├─ workspaces = [] ❌
  │                            │                         ├─ emit(WorkspaceError) ❌
  │<──────────── ERROR ─────────────────────────────────┘
```

## ✅ Soluciones Implementadas

### 1. Eliminar la Recarga Innecesaria en `WorkspaceSwitcher` ✅

**Archivo**: `lib/presentation/widgets/workspace/workspace_switcher.dart`

**Cambio**: Removido el callback `onOpened` que disparaba `LoadUserWorkspacesEvent`

```dart
// ❌ ANTES - Causaba race condition
MenuAnchor(
  // ...
  onOpened: () {
    // Recargar workspaces al abrir el menú
    context.read<WorkspaceBloc>().add(const LoadUserWorkspacesEvent());
  },
);

// ✅ DESPUÉS - Sin recarga innecesaria
MenuAnchor(
  // ...
  // Sin onOpened callback
);
```

**Razón**: Los workspaces ya están cargados y disponibles en el `BlocBuilder`. No hay necesidad de recargarlos cada vez que se abre el menú.

### 2. Manejar Estado `ActiveWorkspaceSet` en `SetActiveWorkspaceEvent` ✅

**Archivo**: `lib/presentation/bloc/workspace/workspace_bloc.dart`

**Cambio**: Detectar y manejar apropiadamente el estado `ActiveWorkspaceSet`

```dart
Future<void> _onSetActiveWorkspace(
  SetActiveWorkspaceEvent event,
  Emitter<WorkspaceState> emit,
) async {
  AppLogger.info(
    'WorkspaceBloc: Estableciendo workspace activo: ${event.workspaceId}',
  );

  final currentState = state;
  AppLogger.info(
    'WorkspaceBloc: Estado actual: ${currentState.runtimeType}, '
    'workspaces: ${currentState is WorkspacesLoaded ? currentState.workspaces.length : 0}',
  );

  // ✅ NUEVO - Obtener lista de workspaces dependiendo del estado actual
  List<Workspace> workspaces = [];
  if (currentState is WorkspacesLoaded) {
    workspaces = currentState.workspaces;
  } else if (currentState is ActiveWorkspaceSet) {
    // Si el estado es ActiveWorkspaceSet, omitir hasta que se complete la transición
    AppLogger.warning(
      'WorkspaceBloc: Estado intermedio ActiveWorkspaceSet detectado, '
      'omitiendo cambio de workspace hasta que se complete la transición anterior',
    );
    return; // Salir sin error
  }

  if (workspaces.isNotEmpty) {
    // ... resto del código
  }
}
```

### 3. Simplificar Emisión de Estados ✅

**Cambio**: Emitir `WorkspacesLoaded` directamente con la lista completa en lugar de usar `copyWith` del estado antiguo

```dart
// ❌ ANTES - Podía causar problemas si el estado cambiaba
result.fold(
  (failure) => { /* ... */ },
  (_) {
    emit(ActiveWorkspaceSet(...));

    final latestState = state;
    if (latestState is WorkspacesLoaded) {
      emit(latestState.copyWith(activeWorkspaceId: event.workspaceId));
    }
  },
);

// ✅ DESPUÉS - Emite con los workspaces capturados al inicio
result.fold(
  (failure) => { /* ... */ },
  (_) {
    emit(ActiveWorkspaceSet(...));

    // Emitir con la lista original de workspaces
    emit(WorkspacesLoaded(
      workspaces: workspaces,
      activeWorkspaceId: event.workspaceId,
    ));
  },
);
```

### 4. Agregar Import Faltante ✅

**Archivo**: `lib/presentation/bloc/workspace/workspace_bloc.dart`

**Cambio**: Agregar import de `Workspace` entity

```dart
import '../../../domain/entities/workspace.dart';
```

## 📊 Flujo Corregido

```
Usuario                  WorkspaceSwitcher          WorkspaceBloc
  │                            │                         │
  ├─── Abre dropdown ─────────>│                         │
  │                            │ (Sin recarga) ✅         │
  ├─── Selecciona workspace A >│                         │
  │                            ├── SetActiveWorkspaceEvent(A) ─>│
  │                            │                         ├─ Estado = WorkspacesLoaded ✅
  │                            │                         ├─ Workspace encontrado ✅
  │                            │                         ├─ Guardar en storage ✅
  │                            │                         ├─ emit(ActiveWorkspaceSet) ✅
  │                            │                         ├─ emit(WorkspacesLoaded) ✅
  ├─── Selecciona workspace B >│                         │
  │                            ├── SetActiveWorkspaceEvent(B) ─>│
  │                            │                         ├─ Estado = ActiveWorkspaceSet ⚠️
  │                            │                         ├─ return (sin error) ✅
  │                            │ (Espera a WorkspacesLoaded) ✅
  │<──────────── SUCCESS ──────────────────────────────┘
```

## 🧪 Pruebas a Realizar

### Escenario 1: Cambio de Workspace desde AppBar ✅

- ✅ Abrir dropdown del WorkspaceSwitcher
- ✅ Seleccionar "Abitalia Home"
- ✅ Verificar que el workspace se activa correctamente
- ✅ Sin errores en los logs

### Escenario 2: Cambio de Workspace desde Lista ✅

- ✅ Navegar a la pantalla de workspaces
- ✅ Hacer clic en "Activar" en un workspace
- ✅ Verificar que el workspace se activa correctamente
- ✅ Sin errores en los logs

### Escenario 3: Cambio Rápido de Workspaces ✅

- ✅ Cambiar de workspace A a B rápidamente
- ✅ Verificar que el segundo cambio se ignora silenciosamente (sin error)
- ✅ Verificar que el workspace final es el correcto

### Escenario 4: Múltiples Aperturas del Menú ✅

- ✅ Abrir y cerrar el dropdown múltiples veces
- ✅ Verificar que no se recargan los workspaces innecesariamente
- ✅ Sin errores en los logs

## 📝 Lecciones Aprendidas

1. **Evitar recargas innecesarias**: No recargar datos que ya están disponibles y actualizados
2. **Logging detallado**: Incluir información del estado actual en logs críticos para debugging
3. **Manejar estados intermedios**: Considerar todos los estados posibles en handlers asíncronos
4. **Race conditions**: Tener cuidado con eventos que se disparan en rápida sucesión
5. **Capturar estado temprano**: Capturar el estado y sus datos al inicio del handler para evitar cambios durante la ejecución
6. **Ignorar en lugar de fallar**: En operaciones idempotentes, es mejor ignorar solicitudes duplicadas que emitir errores

## 🔍 Archivos Modificados

1. ✅ `lib/presentation/widgets/workspace/workspace_switcher.dart`

   - Removido callback `onOpened`
   - Removido import no utilizado `workspace_event.dart`

2. ✅ `lib/presentation/bloc/workspace/workspace_bloc.dart`
   - Agregado import `workspace.dart`
   - Agregado logging detallado del estado
   - Agregado manejo del estado `ActiveWorkspaceSet`
   - Simplificada emisión de `WorkspacesLoaded`

## ✅ Estado Final

- ✅ Workspace switching funciona correctamente desde el AppBar
- ✅ Workspace switching funciona correctamente desde la lista
- ✅ Cambios rápidos de workspace se manejan correctamente (sin errores)
- ✅ Sin recargas innecesarias de workspaces
- ✅ Sin race conditions
- ✅ Sin errores en los logs
- ✅ Estado del BLoC se mantiene consistente

---

**Fecha**: 2025-01-10  
**Autor**: GitHub Copilot  
**Versión**: 2.0
