# 🔴 Fix: Error "dependOnInheritedWidgetOfExactType called before initState()"

## 🐛 Problema

Al cambiar a modo Kanban, aparecía este error:

```
dependOnInheritedWidgetOfExactType<_InheritedTheme>() or
dependOnInheritedElement() was called before
_KanbanBoardViewState.initState() completed.
```

### Causa Raíz

El error ocurría porque:

1. En `initState()` llamábamos `_lists = _buildLists()`
2. `_buildLists()` construía headers con `_buildHeader(column, taskCount)`
3. `_buildHeader()` usaba `Theme.of(context).textTheme.titleMedium`
4. ❌ **`Theme.of(context)` NO puede usarse en `initState()`** porque el widget no está completamente montado en el árbol de widgets

### Regla de Flutter

> `Theme.of(context)`, `MediaQuery.of(context)`, y cualquier `InheritedWidget` solo pueden usarse:
>
> - En el método `build()`
> - En métodos llamados desde `build()`
> - NUNCA en `initState()`, constructores, o antes de que el widget esté montado

## ✅ Solución

Mover la construcción de `_lists` del `initState()` al método `build()`:

### Antes (❌ Error):

```dart
class _KanbanBoardViewState extends State<KanbanBoardView> {
  late List<DragAndDropList> _lists;

  @override
  void initState() {
    super.initState();
    _lists = _buildLists(); // ❌ Llama _buildHeader() que usa Theme.of(context)
  }

  List<DragAndDropList> _buildLists() {
    return _columns.map((column) {
      return DragAndDropList(
        header: _buildHeader(column, count), // ❌ Sin context
        // ...
      );
    }).toList();
  }

  Widget _buildHeader(_KanbanColumn column, int count) {
    return Container(
      child: Text(
        column.title,
        style: Theme.of(context).textTheme.titleMedium, // ❌ ERROR AQUÍ
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DragAndDropLists(children: _lists); // Usa lista pre-construida
  }
}
```

### Después (✅ Funciona):

```dart
class _KanbanBoardViewState extends State<KanbanBoardView> {
  List<DragAndDropList> _lists = []; // ✅ Inicializada vacía

  // ✅ REMOVED: initState() y didUpdateWidget()

  List<DragAndDropList> _buildLists(BuildContext context) { // ✅ Recibe context
    return _columns.map((column) {
      return DragAndDropList(
        header: _buildHeader(context, column, count), // ✅ Pasa context
        // ...
      );
    }).toList();
  }

  Widget _buildHeader(BuildContext context, _KanbanColumn column, int count) { // ✅ Context como parámetro
    return Container(
      child: Text(
        column.title,
        style: Theme.of(context).textTheme.titleMedium, // ✅ Context disponible
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _lists = _buildLists(context); // ✅ Construye AQUÍ donde context está disponible
    return DragAndDropLists(children: _lists);
  }
}
```

## 🔑 Puntos Clave

1. **`Theme.of(context)` solo funciona en `build()` o métodos llamados desde `build()`**
2. **`initState()` ocurre ANTES de que el widget esté en el árbol** - no hay acceso a InheritedWidgets
3. **Solución**: Pasar `BuildContext` como parámetro a métodos que lo necesitan
4. **Alternativa**: Construir widgets en `build()` en lugar de en `initState()`

## 📊 Comparación de Ciclo de Vida

```
┌─────────────────────────────────────────────────┐
│ CICLO DE VIDA DEL STATEFUL WIDGET               │
├─────────────────────────────────────────────────┤
│                                                  │
│ 1. Constructor()                                 │
│    ❌ NO context, NO InheritedWidgets           │
│                                                  │
│ 2. initState()                                   │
│    ❌ NO context válido para Theme/MediaQuery   │
│    ⚠️  Widget no está en el árbol todavía       │
│                                                  │
│ 3. didChangeDependencies()                       │
│    ⚠️  Primer lugar donde context es válido      │
│    ✅ Pero se llama muchas veces                 │
│                                                  │
│ 4. build(BuildContext context) ⭐                │
│    ✅ Context TOTALMENTE válido                  │
│    ✅ Acceso a Theme, MediaQuery, etc.           │
│    ✅ Mejor lugar para construir UI              │
│                                                  │
│ 5. dispose()                                     │
│    ❌ NO context                                 │
│                                                  │
└─────────────────────────────────────────────────┘
```

## 🎯 Resultado

- ✅ **Sin errores** al cambiar a modo Kanban
- ✅ **Theme.of(context)** funciona correctamente
- ✅ **Headers se construyen** con estilos del tema
- ✅ **Drag & drop funcional** (fix previo intacto)

## 📚 Referencias

- [Flutter Docs: State lifecycle](https://api.flutter.dev/flutter/widgets/State-class.html)
- [Flutter Docs: InheritedWidget](https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html)
- [Common Error: InheritedWidget called before initState](https://docs.flutter.dev/testing/errors)

---

**Fecha:** 9 de Octubre, 2025  
**Estado:** ✅ Completado y funcionando  
**Error Resuelto:** `dependOnInheritedWidgetOfExactType` en `initState()`
