# 🧪 Checklist de Pruebas - Tarea 1.3

## 📋 Pruebas con Backend Real

### Fecha: 11 de Octubre, 2025

### Tester: [Tu nombre]

### Backend: http://localhost:3001

### Frontend: http://localhost:5000

---

## 🔐 Pre-requisitos

- [ ] Backend levantado en puerto 3001
- [ ] Base de datos con datos de prueba
- [ ] Usuario de prueba creado
- [ ] Al menos 1 workspace activo
- [ ] Al menos 5 tareas con diferentes:
  - Estados (planificadas, en progreso, completadas)
  - Prioridades (crítica, alta, media, baja)
  - Fechas (hoy, esta semana, próximas, sin fecha)

---

## 🚀 Fase 1: Navegación y Carga Inicial

### Login y Acceso

- [ ] Abrir http://localhost:5000
- [ ] Hacer login con credenciales de prueba
- [ ] Verificar redirección a Dashboard
- [ ] Tap en tab "Tareas" del bottom navigation
- [ ] **RESULTADO ESPERADO:** Pantalla AllTasksScreen se carga

### Visualización Inicial

- [ ] Verificar AppBar muestra "Tareas"
- [ ] Verificar TabBar muestra "Mis Tareas" y "Todas"
- [ ] Verificar botones: Search, Filters, Sort
- [ ] Verificar FAB "Nueva Tarea"
- [ ] **RESULTADO ESPERADO:** UI completa visible

---

## 📊 Fase 2: Agrupación Temporal

### Grupo "Hoy"

- [ ] Buscar sección con header "Hoy"
- [ ] Verificar ícono rojo `today`
- [ ] Verificar contador muestra número correcto
- [ ] Verificar tareas mostradas tienen fecha de hoy
- [ ] **RESULTADO:** **\_** tareas en grupo "Hoy"

### Grupo "Esta Semana"

- [ ] Buscar sección "Esta Semana"
- [ ] Verificar ícono naranja `calendar_view_week`
- [ ] Verificar contador correcto
- [ ] Verificar tareas entre mañana y fin de semana
- [ ] **RESULTADO:** **\_** tareas en "Esta Semana"

### Grupo "Próximas"

- [ ] Buscar sección "Próximas"
- [ ] Verificar ícono azul `upcoming`
- [ ] Verificar contador correcto
- [ ] Verificar tareas después del fin de semana
- [ ] **RESULTADO:** **\_** tareas en "Próximas"

### Grupo "Sin Fecha"

- [ ] Buscar sección "Sin Fecha"
- [ ] Verificar ícono gris `event_busy`
- [ ] Verificar contador correcto
- [ ] Verificar tareas sin fecha asignada
- [ ] **RESULTADO:** **\_** tareas en "Sin Fecha"

---

## 🎨 Fase 3: Visualización de TaskCard

### Elementos del Card

- [ ] Verificar barra de prioridad (izquierda, 4px ancho, 60px alto)
- [ ] Verificar ícono de estado (24px)
- [ ] Verificar título en negrita
- [ ] Verificar descripción (máx 2 líneas)
- [ ] Verificar badge de prioridad (esquina superior derecha)
- [ ] Verificar ícono de calendario y fecha
- [ ] Verificar badge de estado
- [ ] **RESULTADO ESPERADO:** Card con todos los elementos

### Colores de Prioridad

- [ ] Tarea crítica → Barra morada
- [ ] Tarea alta → Barra roja
- [ ] Tarea media → Barra naranja
- [ ] Tarea baja → Barra verde
- [ ] **RESULTADO ESPERADO:** Colores correctos

### Indicador de Retrasada

- [ ] Buscar tarea con endDate < hoy y status != completada
- [ ] Verificar badge rojo con ícono warning
- [ ] Verificar texto "Retrasada"
- [ ] **RESULTADO:** **\_** tareas retrasadas detectadas

### Tarea Completada

- [ ] Buscar tarea con status = completada
- [ ] Verificar título tiene `TextDecoration.lineThrough`
- [ ] Verificar ícono de estado en verde
- [ ] Verificar NO muestra botón Quick Complete
- [ ] **RESULTADO ESPERADO:** Visual diferenciado

---

## 🔄 Fase 4: Swipe Actions

### Swipe Derecha (Completar)

- [ ] Elegir tarea planificada o en progreso
- [ ] Swipe derecha (de izquierda a derecha)
- [ ] Verificar fondo verde con ícono check_circle
- [ ] Verificar texto "Completar"
- [ ] **ANIMACIÓN:** Fluida, sin lag

### Confirmación de Completar

- [ ] Soltar dedo (completar swipe)
- [ ] Verificar aparece AlertDialog
- [ ] Verificar título "Completar Tarea"
- [ ] Verificar mensaje con nombre de tarea
- [ ] Tap "Cancelar" → Verificar card vuelve a posición
- [ ] **RESULTADO:** Card NO se completó

### Completar Confirmado

- [ ] Repetir swipe derecha
- [ ] Tap "Completar" en dialog
- [ ] Verificar card desaparece o se marca como completada
- [ ] Verificar actualización en servidor (check en DB)
- [ ] **RESULTADO:** Tarea completada ✓

### Swipe Izquierda (Eliminar)

- [ ] Elegir otra tarea
- [ ] Swipe izquierda (de derecha a izquierda)
- [ ] Verificar fondo rojo con ícono delete
- [ ] Verificar texto "Eliminar"
- [ ] **ANIMACIÓN:** Fluida, sin lag

### Confirmación de Eliminar

- [ ] Soltar dedo
- [ ] Verificar AlertDialog
- [ ] Verificar título "Eliminar Tarea"
- [ ] Verificar mensaje "Esta acción no se puede deshacer"
- [ ] Tap "Cancelar" → Verificar card vuelve
- [ ] **RESULTADO:** Card NO se eliminó

### Eliminar Confirmado

- [ ] Repetir swipe izquierda
- [ ] Tap "Eliminar" (botón rojo)
- [ ] Verificar card desaparece
- [ ] Verificar eliminación en servidor (check en DB)
- [ ] **RESULTADO:** Tarea eliminada ✓

---

## ⚡ Fase 5: Quick Complete Button

### Visibilidad

- [ ] Verificar botón check_circle_outline visible en tareas NO completadas
- [ ] Verificar botón NO visible en tareas completadas
- [ ] **RESULTADO ESPERADO:** Condicional correcto

### Acción Quick Complete

- [ ] Elegir tarea planificada
- [ ] Tap en botón check_circle_outline
- [ ] Verificar aparece SnackBar
- [ ] Verificar mensaje: "✓ [Título] completada"
- [ ] Verificar acción "Deshacer" disponible
- [ ] **DURACIÓN:** 3 segundos antes de auto-cerrar

### Deshacer Completar

- [ ] Repetir Quick Complete
- [ ] Tap "Deshacer" en SnackBar
- [ ] Verificar tarea vuelve a estado anterior
- [ ] Verificar actualización en servidor
- [ ] **RESULTADO:** Undo funciona ✓

### Completar Confirmado

- [ ] Repetir Quick Complete
- [ ] Esperar 3 segundos (no tap en Deshacer)
- [ ] Verificar SnackBar desaparece
- [ ] Verificar tarea permanece completada
- [ ] **RESULTADO:** Tarea completada permanentemente ✓

---

## 🔍 Fase 6: Búsqueda

### Búsqueda por Título

- [ ] Tap en ícono Search (lupa)
- [ ] Verificar aparece AlertDialog con TextField
- [ ] Escribir parte del título de una tarea
- [ ] Tap "Buscar"
- [ ] Verificar solo muestra tareas que coinciden
- [ ] **BÚSQUEDA:** "******\_******"
- [ ] **RESULTADOS:** **\_** tareas encontradas

### Búsqueda por Descripción

- [ ] Repetir búsqueda
- [ ] Escribir texto que aparece en descripción
- [ ] Verificar encuentra tareas correctas
- [ ] **BÚSQUEDA:** "******\_******"
- [ ] **RESULTADOS:** **\_** tareas encontradas

### Limpiar Búsqueda

- [ ] Borrar texto de búsqueda
- [ ] Tap "Buscar" con campo vacío
- [ ] Verificar muestra todas las tareas nuevamente
- [ ] **RESULTADO:** Todas las tareas visibles ✓

---

## 🎛️ Fase 7: Filtros

### Abrir Bottom Sheet

- [ ] Tap en ícono Filters
- [ ] Verificar aparece ModalBottomSheet
- [ ] Verificar título "Filtros"
- [ ] Verificar sección "Estado"
- [ ] Verificar sección "Prioridad"
- [ ] **RESULTADO ESPERADO:** Sheet completo

### Filtro por Estado

- [ ] Seleccionar FilterChip "En progreso"
- [ ] Tap "Aplicar"
- [ ] Verificar solo muestra tareas en progreso
- [ ] Verificar badge en ícono Filters muestra "1"
- [ ] **RESULTADO:** **\_** tareas en progreso

### Filtro por Prioridad

- [ ] Abrir Filters nuevamente
- [ ] Seleccionar FilterChip "Crítica"
- [ ] Tap "Aplicar"
- [ ] Verificar muestra tareas en progreso Y críticas
- [ ] Verificar badge muestra "2"
- [ ] **RESULTADO:** **\_** tareas (intersección)

### Limpiar Filtros

- [ ] Abrir Filters
- [ ] Tap "Limpiar"
- [ ] Verificar todas las chips deseleccionadas
- [ ] Verificar badge desaparece
- [ ] Verificar muestra todas las tareas
- [ ] **RESULTADO:** Filtros limpiados ✓

### Múltiples Filtros

- [ ] Aplicar Estado: "Completadas"
- [ ] Aplicar Prioridad: "Alta"
- [ ] Verificar badge muestra "2"
- [ ] Verificar solo tareas completadas de prioridad alta
- [ ] **RESULTADO:** **\_** tareas (filtro combinado)

---

## 📈 Fase 8: Ordenamiento

### Ordenar por Fecha (Ascendente)

- [ ] Tap en ícono Sort (arrow_upward inicial)
- [ ] Seleccionar "Por fecha"
- [ ] Verificar ícono sigue siendo arrow_upward
- [ ] Verificar tareas ordenadas de más antigua a más reciente
- [ ] **RESULTADO:** Orden cronológico ✓

### Ordenar por Fecha (Descendente)

- [ ] Tap en Sort nuevamente
- [ ] Seleccionar "Por fecha" otra vez
- [ ] Verificar ícono cambia a arrow_downward
- [ ] Verificar tareas ordenadas de más reciente a más antigua
- [ ] **RESULTADO:** Orden cronológico invertido ✓

### Ordenar por Prioridad (Ascendente)

- [ ] Tap en Sort
- [ ] Seleccionar "Por prioridad"
- [ ] Verificar ícono vuelve a arrow_upward
- [ ] Verificar orden: Crítica → Alta → Media → Baja
- [ ] **RESULTADO:** Orden por prioridad ✓

### Ordenar por Prioridad (Descendente)

- [ ] Tap "Por prioridad" otra vez
- [ ] Verificar ícono arrow_downward
- [ ] Verificar orden: Baja → Media → Alta → Crítica
- [ ] **RESULTADO:** Orden invertido ✓

### Ordenar por Nombre (Ascendente)

- [ ] Tap en Sort
- [ ] Seleccionar "Por nombre"
- [ ] Verificar orden alfabético A-Z
- [ ] **RESULTADO:** A-Z ✓

### Ordenar por Nombre (Descendente)

- [ ] Tap "Por nombre" otra vez
- [ ] Verificar orden Z-A
- [ ] **RESULTADO:** Z-A ✓

---

## 📑 Fase 9: Tabs

### Tab "Mis Tareas"

- [ ] Verificar tab "Mis Tareas" está seleccionado por defecto
- [ ] Verificar solo muestra tareas asignadas al usuario actual
- [ ] Anotar cantidad: **\_** mis tareas
- [ ] **RESULTADO ESPERADO:** Solo tareas propias

### Tab "Todas"

- [ ] Tap en tab "Todas"
- [ ] Verificar muestra todas las tareas del workspace
- [ ] Anotar cantidad: **\_** todas las tareas
- [ ] **RESULTADO ESPERADO:** Más tareas que en "Mis Tareas"

### Estados Independientes - Filtros

- [ ] En tab "Todas", aplicar filtro por estado "Planificadas"
- [ ] Cambiar a tab "Mis Tareas"
- [ ] Verificar filtro NO está aplicado en "Mis Tareas"
- [ ] Volver a "Todas"
- [ ] Verificar filtro sigue aplicado
- [ ] **RESULTADO:** Estados independientes ✓

### Estados Independientes - Ordenamiento

- [ ] En tab "Mis Tareas", ordenar por prioridad
- [ ] Cambiar a "Todas"
- [ ] Verificar ordenamiento es independiente
- [ ] **RESULTADO:** Ordenamiento independiente ✓

---

## 🎯 Fase 10: Interacción con Backend

### Crear Nueva Tarea

- [ ] Tap en FAB "Nueva Tarea"
- [ ] Verificar navega a formulario de creación
- [ ] Crear tarea de prueba con fecha de hoy
- [ ] Guardar
- [ ] Volver a AllTasksScreen
- [ ] Verificar nueva tarea aparece en grupo "Hoy"
- [ ] **RESULTADO:** Tarea creada ✓

### Tap en Card (Navegar a Detalle)

- [ ] Tap en cualquier TaskCard
- [ ] Verificar muestra SnackBar "Abrir tarea: [Título]"
- [ ] TODO: Cuando se implemente navegación, verificar va a detalle
- [ ] **RESULTADO:** Tap detectado ✓

### Pull to Refresh

- [ ] En cualquier tab, hacer scroll hacia arriba
- [ ] Arrastrar hacia abajo para refresh
- [ ] Verificar aparece indicador de carga
- [ ] Verificar muestra SnackBar "Tareas actualizadas"
- [ ] Verificar datos se refrescan desde servidor
- [ ] **RESULTADO:** Refresh funciona ✓

---

## ⚡ Fase 11: Performance y Animaciones

### Performance con Muchas Tareas

- [ ] Crear/cargar al menos 20 tareas
- [ ] Scroll por toda la lista
- [ ] Verificar scroll fluido (60fps)
- [ ] Aplicar filtros
- [ ] Verificar respuesta rápida (<500ms)
- [ ] Ordenar tareas
- [ ] Verificar respuesta rápida (<500ms)
- [ ] **RESULTADO:** Performance aceptable ✓

### Animaciones de Swipe

- [ ] Hacer swipe derecha completo
- [ ] Verificar animación fluida, sin stuttering
- [ ] Hacer swipe derecha parcial y soltar
- [ ] Verificar card vuelve con animación suave
- [ ] Repetir con swipe izquierda
- [ ] **RESULTADO:** Animaciones fluidas ✓

### Transiciones entre Tabs

- [ ] Cambiar rápidamente entre tabs
- [ ] Verificar transición suave
- [ ] Verificar sin parpadeos o recargas innecesarias
- [ ] **RESULTADO:** Transiciones suaves ✓

---

## 🐛 Fase 12: Edge Cases

### Sin Tareas

- [ ] Eliminar/ocultar todas las tareas
- [ ] Verificar aparece estado vacío
- [ ] Verificar mensaje "¡Todo al día!"
- [ ] Verificar botón "Crear Tarea"
- [ ] **RESULTADO ESPERADO:** Empty state amigable

### Sin Workspace

- [ ] TODO: Probar sin workspace seleccionado
- [ ] Verificar muestra mensaje "No hay workspace seleccionado"
- [ ] Verificar botón "Seleccionar Workspace"
- [ ] **RESULTADO ESPERADO:** Validación correcta

### Filtros sin Resultados

- [ ] Aplicar filtros que no coincidan con ninguna tarea
- [ ] Verificar muestra lista vacía o mensaje apropiado
- [ ] **RESULTADO ESPERADO:** Manejo correcto

### Swipe en Tarea Completada

- [ ] Hacer swipe en tarea ya completada
- [ ] Verificar confirmación NO permite completar nuevamente
- [ ] O verificar lógica apropiada
- [ ] **RESULTADO:** Manejo correcto ✓

---

## 📝 Notas y Observaciones

### Bugs Encontrados

1.
2.
3.

### Mejoras Sugeridas

1.
2.
3.

### Performance

- Tiempo de carga inicial: **\_** ms
- Tiempo de aplicar filtros: **\_** ms
- Tiempo de ordenar: **\_** ms
- FPS durante scroll: **\_** fps

---

## ✅ Resumen Final

### Pruebas Completadas

- [ ] Fase 1: Navegación (\_\_/5)
- [ ] Fase 2: Agrupación Temporal (\_\_/4)
- [ ] Fase 3: Visualización de TaskCard (\_\_/4)
- [ ] Fase 4: Swipe Actions (\_\_/6)
- [ ] Fase 5: Quick Complete (\_\_/4)
- [ ] Fase 6: Búsqueda (\_\_/3)
- [ ] Fase 7: Filtros (\_\_/5)
- [ ] Fase 8: Ordenamiento (\_\_/6)
- [ ] Fase 9: Tabs (\_\_/4)
- [ ] Fase 10: Backend (\_\_/3)
- [ ] Fase 11: Performance (\_\_/3)
- [ ] Fase 12: Edge Cases (\_\_/4)

### Resultado General

- **Total de pruebas:** 51
- **Pruebas pasadas:** **\_**
- **Pruebas fallidas:** **\_**
- **Porcentaje:** **\_**%

### Estado Final

- [ ] ✅ Todas las pruebas pasaron - LISTO PARA PRODUCCIÓN
- [ ] ⚠️ Algunas pruebas fallaron - REQUIERE AJUSTES
- [ ] ❌ Muchas pruebas fallaron - REQUIERE REFACTORING

### Próximos Pasos

1.
2.
3.

---

_Checklist creado: 11 de Octubre, 2025_
_Tarea: 1.3 - All Tasks Screen Mejoras_
