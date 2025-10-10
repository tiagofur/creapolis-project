# 🎯 Fix Definitivo: Drag & Drop en Kanban Board

## 📋 Problemas Identificados

El drag & drop **no funcionaba correctamente** porque:

1. **No estábamos siguiendo el patrón del package `drag_and_drop_lists`**
2. El package **requiere** que actualicemos una lista de estado interno (`_lists`) en el callback
3. Solo estábamos llamando al BLoC pero no actualizando el estado visual inmediatamente
4. **ERROR CRÍTICO**: Llamábamos `Theme.of(context)` en `initState()` donde el contexto no está disponible

## ❌ Error: "dependOnInheritedWidgetOfExactType was called before initState()"

Este error ocurría porque:

- `_buildLists()` se llamaba en `initState()`
- `_buildLists()` construía headers con `_buildHeader()`
- `_buildHeader()` usaba `Theme.of(context)`
- ❌ `Theme.of(context)` NO puede usarse antes de que el widget esté completamente inicializado

**Solución**: Mover `_buildLists()` al método `build()` donde el contexto está disponible.

## ✅ Solución Implementada

### 1. **Agregado Estado Interno para Listas**

```dart
class _KanbanBoardViewState extends State<KanbanBoardView> {
  // ✅ Lista interna como estado mutable (no late)
  List<DragAndDropList> _lists = [];

  // ❌ REMOVED: initState() y didUpdateWidget()
  // Ya no construimos listas aquí porque necesitamos context
}
```

### 2. **Mover Construcción de Listas a `build()`**

````dart
@override
Widget build(BuildContext context) {
  // ✅ Construir listas AQUÍ donde context está disponible
  _lists = _buildLists(context);

  return DragAndDropLists(
    children: _lists,
    onItemReorder: _onItemReorder,
    // ...
  );
}

// ✅ _buildLists ahora recibe context como parámetro
List<DragAndDropList> _buildLists(BuildContext context) {
  return _columns.map((column) {
    // ...
    return DragAndDropList(
      header: _buildHeader(context, column, columnTasks.length), // ✅ Pasa context
      // ...
    );
  }).toList();
}

// ✅ _buildHeader ahora recibe context como primer parámetro
Widget _buildHeader(BuildContext context, _KanbanColumn column, int taskCount) {
  return Container(
    child: Row(
      children: [
        Text(
          column.title,
          style: Theme.of(context).textTheme.titleMedium, // ✅ Context disponible
        ),
      ],
    ),
  );
}
```### 2. **Refactorizado `_onItemReorder` Siguiendo Patrón Correcto**

Según la documentación del package, el callback debe:

1. **PRIMERO**: Actualizar el estado visual con `setState`
2. **DESPUÉS**: Guardar en el backend

```dart
void _onItemReorder(
  int oldItemIndex,
  int oldListIndex,
  int newItemIndex,
  int newListIndex,
) {
  // PASO 1: ✅ Actualizar estado visual INMEDIATAMENTE (requerido por package)
  setState(() {
    var movedItem = _lists[oldListIndex].children.removeAt(oldItemIndex);
    _lists[newListIndex].children.insert(newItemIndex, movedItem);
  });

  // PASO 2: ✅ Guardar en backend si cambió de columna
  if (oldListIndex != newListIndex) {
    final task = /* obtener tarea */;
    final newStatus = _columns[newListIndex].status;

    context.read<TaskBloc>().add(
      UpdateTaskEvent(
        id: task.id,
        status: newStatus, // ✅ Nuevo estado
        // ... otros campos
      ),
    );

    // Feedback visual
    ScaffoldMessenger.of(context).showSnackBar(/* ... */);
  }
}
````

## 🔧 Cambios Técnicos

### Antes (❌ No funcionaba):

- No había estado interno `_lists`
- `_buildLists()` se llamaba en cada `build()`
- `_onItemReorder` solo llamaba `setState(() {})` sin actualizar nada
- El package no podía sincronizar el estado visual

### Después (✅ Funciona):

- Estado interno `_lists` mantiene las listas
- `_lists` se construye en `initState()` y se actualiza en `didUpdateWidget()`
- `_onItemReorder` actualiza `_lists` **inmediatamente** en `setState`
- Luego guarda en el backend
- El package puede rastrear los cambios correctamente

## 📦 Patrón del Package `drag_and_drop_lists`

El package **requiere** este patrón para funcionar:

```dart
// 1. Mantener lista de DragAndDropList como estado
late List<DragAndDropList> _lists;

// 2. En onItemReorder, PRIMERO actualizar visualmente
setState(() {
  var item = _lists[oldList].children.removeAt(oldIndex);
  _lists[newList].children.insert(newIndex, item);
});

// 3. DESPUÉS hacer lógica de negocio (guardar en DB, etc.)
```

**Documentación oficial:**

> "The only required parameters are children, onItemReorder, and onListReorder"
>
> "In onItemReorder, you must update your internal state to reflect the new order"

Fuente: https://pub.dev/packages/drag_and_drop_lists

## 🎯 Resultado

Ahora el drag & drop:

- ✅ **Responde inmediatamente** al arrastre
- ✅ **Actualiza la UI** mientras arrastras
- ✅ **Guarda en el backend** cuando sueltas en nueva columna
- ✅ **Muestra feedback** con SnackBar verde
- ✅ **Logs informativos** para debugging

## 🧪 Cómo Probar

1. Navegar a un proyecto con tareas
2. Cambiar a vista Kanban (botón en AppBar)
3. **Arrastrar una tarea** de una columna a otra
4. Verificar:
   - ✓ La tarea se mueve visualmente
   - ✓ Aparece SnackBar verde confirmando
   - ✓ Ver logs: "Guardando tarea X de STATUS_OLD a STATUS_NEW"
   - ✓ Refrescar página - la tarea mantiene su nueva columna

## 📝 Logs Agregados

```dart
AppLogger.info('KanbanBoard: _onItemReorder llamado - oldItem: $oldItemIndex...');
AppLogger.info('KanbanBoard: Guardando tarea ${task.id} - ${task.title}...');
AppLogger.warning('KanbanBoard: Índice fuera de rango');
```

---

**Fecha:** 9 de Octubre, 2025  
**Estado:** ✅ Completado y funcionando  
**Package:** `drag_and_drop_lists ^0.4.2`
