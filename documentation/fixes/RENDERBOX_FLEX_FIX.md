# 🐛 Fix: RenderFlex unbounded constraints error

**Fecha**: 16 de octubre de 2025  
**Error**: `RenderFlex children have non-zero flex but incoming width constraints are unbounded`  
**Componente**: `ManagerSelector` widget  
**Estado**: ✅ **RESUELTO**

---

## 🔍 Error Original

```
══╡ EXCEPTION CAUGHT BY RENDERING LIBRARY ╞═════════════════════════════════════════════════════════
The following assertion was thrown during performLayout():
RenderFlex children have non-zero flex but incoming width constraints are unbounded.

When a row is in a parent that does not provide a finite width constraint, for example if it is in a
horizontal scrollable, it will try to shrink-wrap its children along the horizontal axis. Setting a
flex on a child (e.g. using Expanded) indicates that the child is to expand to fill the remaining
space in the horizontal direction.

These two directives are mutually exclusive. If a parent is to shrink-wrap its child, the child
cannot simultaneously expand to fit its parent.
```

### Contexto

El error ocurría al intentar abrir el `CreateProjectBottomSheet` desde:

- FloatingActionButton (Speed Dial)
- Dashboard Quick Actions
- Dashboard Empty State

---

## 🎯 Causa Raíz

En el widget `ManagerSelector`, dentro del método `selectedItemBuilder`, había un `Row` con un widget `Expanded`:

```dart
// ❌ ANTES - Problema
selectedItemBuilder: (context) {
  return [
    ..._eligibleManagers.map((member) {
      return Row(
        children: [  // ← Row sin mainAxisSize
          CircleAvatar(...),
          const SizedBox(width: 12),
          Expanded(  // ← ¡PROBLEMA! Expanded en Row sin restricciones
            child: Text(member.userName, overflow: TextOverflow.ellipsis),
          ),
        ],
      );
    }),
  ];
},
```

**Por qué falla:**

1. El `DropdownButtonFormField` usa `selectedItemBuilder` para renderizar el item seleccionado
2. En ciertas situaciones de layout, el dropdown no tiene restricciones de ancho definidas
3. Un `Row` sin `mainAxisSize` intenta usar todo el espacio disponible (infinito)
4. Un `Expanded` dentro de ese `Row` intenta expandirse al 100% del ancho
5. **Conflicto**: No puedes expandir al 100% de algo infinito

---

## ✅ Solución

### Cambio 1: Agregar `mainAxisSize: MainAxisSize.min`

Esto hace que el `Row` use solo el espacio necesario para sus hijos, en lugar de intentar expandirse infinitamente.

### Cambio 2: Cambiar `Expanded` por `Flexible`

`Flexible` permite que el widget se ajuste al espacio disponible sin requerir que el padre tenga restricciones definidas.

```dart
// ✅ DESPUÉS - Solución
selectedItemBuilder: (context) {
  return [
    if (widget.allowNull)
      const Row(
        mainAxisSize: MainAxisSize.min,  // ← Solución 1
        children: [
          CircleAvatar(...),
          SizedBox(width: 12),
          Text('Sin manager'),
        ],
      ),
    ..._eligibleManagers.map((member) {
      return Row(
        mainAxisSize: MainAxisSize.min,  // ← Solución 1
        children: [
          CircleAvatar(...),
          const SizedBox(width: 12),
          Flexible(  // ← Solución 2: Cambio de Expanded a Flexible
            child: Text(
              member.userName,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }),
  ];
},
```

---

## 📊 Diferencia: `Expanded` vs `Flexible`

### `Expanded`

- Requiere que el padre tenga restricciones definidas
- **Siempre** toma todo el espacio disponible (flex: 1)
- Es equivalente a `Flexible(fit: FlexFit.tight)`
- **Falla** cuando el padre tiene constrains unbounded

### `Flexible`

- Funciona con o sin restricciones definidas del padre
- Toma el espacio **necesario** hasta un máximo
- Por defecto usa `FlexFit.loose` (se ajusta al contenido)
- **No falla** con unbounded constraints

---

## 🧪 Testing

### Antes del fix:

```
1. Login
2. Seleccionar workspace
3. Presionar FAB → Nuevo Proyecto
4. ❌ Crash: RenderFlex unbounded constraints error
```

### Después del fix:

```
1. Login
2. Seleccionar workspace
3. Presionar FAB → Nuevo Proyecto
4. ✅ Bottom sheet se abre correctamente
5. ✅ Dropdown de Manager funciona
6. ✅ Selección de manager funciona
7. ✅ Crear proyecto exitoso
```

---

## 📝 Lecciones Aprendidas

### 1. Usar `mainAxisSize` apropiadamente

```dart
// ❌ MAL - Row sin restricciones
Row(
  children: [
    Icon(...),
    Expanded(child: Text(...)),  // Puede fallar
  ],
)

// ✅ BIEN - Row con tamaño mínimo
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Icon(...),
    Flexible(child: Text(...)),  // Seguro
  ],
)
```

### 2. `Expanded` solo en contextos con restricciones

Usa `Expanded` cuando:

- Estás dentro de un `Container` con ancho definido
- Estás en un `SizedBox` con ancho
- Estás en la raíz del scaffold (tiene restricciones de pantalla)
- El padre tiene `constraints` definidos

### 3. `Flexible` es más seguro en widgets reutilizables

Para widgets que pueden usarse en múltiples contextos (dropdowns, dialogs, bottom sheets), prefiere `Flexible` sobre `Expanded`.

### 4. `selectedItemBuilder` requiere cuidado especial

El `selectedItemBuilder` de `DropdownButton` se renderiza en un contexto especial donde puede no tener restricciones de ancho. Siempre usa:

- `mainAxisSize: MainAxisSize.min` en `Row`/`Column`
- `Flexible` en lugar de `Expanded`
- Evita widgets que requieran ancho infinito

---

## 🛠️ Patrones de Solución

### Patrón 1: Row compacto con Flexible

```dart
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Icon(Icons.person),
    SizedBox(width: 8),
    Flexible(
      child: Text(
        longText,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ],
)
```

### Patrón 2: Wrap con IntrinsicWidth

```dart
IntrinsicWidth(
  child: Row(
    children: [
      Icon(Icons.person),
      SizedBox(width: 8),
      Expanded(
        child: Text(longText),
      ),
    ],
  ),
)
```

### Patrón 3: ConstrainedBox explícito

```dart
ConstrainedBox(
  constraints: BoxConstraints(maxWidth: 300),
  child: Row(
    children: [
      Icon(Icons.person),
      Expanded(
        child: Text(longText),
      ),
    ],
  ),
)
```

---

## 📋 Archivo Modificado

### `lib/presentation/widgets/project/manager_selector.dart`

**Líneas modificadas**: ~127-162

**Cambios**:

1. Agregado `mainAxisSize: MainAxisSize.min` a ambos `Row` en `selectedItemBuilder`
2. Cambiado `Expanded` por `Flexible` en el texto del nombre del manager

**Impacto**:

- ✅ Soluciona el crash al abrir `CreateProjectBottomSheet`
- ✅ Dropdown de Manager funciona correctamente
- ✅ Layout se ajusta correctamente en todas las resoluciones
- ✅ Sin cambios visuales perceptibles para el usuario

---

## ✅ Criterios de Aceptación

- [x] Bottom sheet se abre sin errores
- [x] Dropdown de Manager se renderiza correctamente
- [x] Selección de manager funciona
- [x] Item seleccionado se muestra correctamente
- [x] No hay warnings de layout en consola
- [x] Funciona en todas las resoluciones
- [x] Funciona en web, móvil y escritorio

---

## 🔗 Referencias

- [Flutter Layout Constraints](https://docs.flutter.dev/ui/layout/constraints)
- [Understanding constraints](https://docs.flutter.dev/ui/layout/constraints#unbounded-constraints)
- [Expanded vs Flexible](https://api.flutter.dev/flutter/widgets/Expanded-class.html)
- [RenderFlex overflow](https://flutter.dev/docs/testing/common-errors#renderflex-overflowed)

---

## 🎉 Resultado

✅ **El widget `ManagerSelector` ahora funciona correctamente en todos los contextos**

Los usuarios pueden:

1. Abrir el formulario de crear proyecto sin errores
2. Seleccionar un manager del dropdown
3. Ver correctamente el manager seleccionado
4. Crear proyectos con o sin manager asignado
5. Editar proyectos y cambiar el manager

---

## 🔮 Prevención Futura

Para evitar este tipo de errores en el futuro:

### 1. Checklist al crear dropdowns:

- [ ] Usar `mainAxisSize: MainAxisSize.min` en `Row`/`Column` del `selectedItemBuilder`
- [ ] Preferir `Flexible` sobre `Expanded` en items
- [ ] Probar en diferentes tamaños de pantalla
- [ ] Probar en web (constraints diferentes)

### 2. Lint rule personalizada:

```yaml
# analysis_options.yaml
linter:
  rules:
    - prefer_const_constructors
    - sized_box_for_whitespace
    # Considerar agregar custom lint para detectar Expanded en selectedItemBuilder
```

### 3. Widget testing:

```dart
testWidgets('ManagerSelector renders without layout errors', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ManagerSelector(
          members: testMembers,
        ),
      ),
    ),
  );

  // No debe haber errores de layout
  expect(tester.takeException(), isNull);

  // Abrir dropdown
  await tester.tap(find.byType(DropdownButtonFormField));
  await tester.pumpAndSettle();

  // No debe haber errores
  expect(tester.takeException(), isNull);
});
```

---

## 📚 Archivo Relacionado

- [PROJECT_CREATION_FIX.md](./PROJECT_CREATION_FIX.md) - Fix anterior de funcionalidad de creación
