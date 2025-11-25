# 🧪 Plan de Pruebas: Kanban con WIP Limits

**Fecha:** 13 de octubre de 2025  
**Feature:** Tablero Kanban con WIP Limits y Métricas  
**Versión:** 1.0

---

## 📋 Resumen de Pruebas

| Área | Tests | Estado |
|------|-------|--------|
| Configuración WIP | 5 | ⏳ Pendiente |
| Alertas Visuales | 4 | ⏳ Pendiente |
| Métricas | 6 | ⏳ Pendiente |
| Drag & Drop | 5 | ⏳ Pendiente |
| Persistencia | 3 | ⏳ Pendiente |
| **Total** | **23** | **⏳ Pendiente** |

---

## 🔧 Setup Inicial

### Prerequisitos

1. ✅ Flutter instalado
2. ✅ Dependencia `drag_and_drop_lists: ^0.4.2` en pubspec.yaml
3. ✅ Proyecto con tareas de prueba

### Datos de Prueba Recomendados

Crear un proyecto con:
- 3 tareas en estado "Planificadas"
- 5 tareas en estado "En Progreso"
- 2 tareas en estado "Bloqueadas"
- 8 tareas en estado "Completadas" (con fechas variadas)
- 1 tarea en estado "Canceladas"

---

## 1️⃣ Tests de Configuración de WIP Limits

### Test 1.1: Abrir Diálogo de Configuración

**Objetivo:** Verificar que el diálogo se abre correctamente

**Pasos:**
1. Navegar a la vista Kanban
2. Hacer clic en el botón de configuración (⚙️)

**Resultado Esperado:**
- ✅ Se abre un diálogo modal
- ✅ Título: "Configurar Tablero Kanban"
- ✅ Se muestran 5 filas (una por cada estado)
- ✅ Cada fila tiene nombre de columna y campo de texto
- ✅ Botones "Cancelar" y "Guardar"

---

### Test 1.2: Establecer WIP Limit

**Objetivo:** Configurar un límite y verificar persistencia

**Pasos:**
1. Abrir diálogo de configuración
2. En "En Progreso", ingresar el número "5"
3. Hacer clic en "Guardar"
4. Verificar el header de la columna "En Progreso"

**Resultado Esperado:**
- ✅ Diálogo se cierra
- ✅ SnackBar verde: "✓ Configuración guardada"
- ✅ Header muestra "5/5" (o X/5 según tareas actuales)
- ✅ Al recargar la página, el límite persiste

---

### Test 1.3: Modificar WIP Limit Existente

**Objetivo:** Cambiar un límite ya configurado

**Pasos:**
1. Con límite de 5 configurado en "En Progreso"
2. Abrir diálogo de configuración
3. Cambiar el límite a "3"
4. Guardar

**Resultado Esperado:**
- ✅ Campo muestra el valor anterior "5"
- ✅ Se puede cambiar a "3"
- ✅ Al guardar, header muestra "X/3"

---

### Test 1.4: Eliminar WIP Limit

**Objetivo:** Quitar un límite establecido

**Pasos:**
1. Con límite configurado en "En Progreso"
2. Abrir diálogo de configuración
3. Borrar el contenido del campo (dejarlo vacío)
4. Guardar

**Resultado Esperado:**
- ✅ Campo se limpia correctamente
- ✅ Al guardar, header muestra solo "X" (sin límite)
- ✅ No aparecen alertas de WIP aunque haya muchas tareas

---

### Test 1.5: Cancelar Configuración

**Objetivo:** Verificar que cancelar no guarda cambios

**Pasos:**
1. Abrir diálogo de configuración
2. Cambiar un límite
3. Hacer clic en "Cancelar"

**Resultado Esperado:**
- ✅ Diálogo se cierra
- ✅ Los cambios NO se aplican
- ✅ Header mantiene configuración anterior

---

## 2️⃣ Tests de Alertas Visuales

### Test 2.1: WIP Normal (Dentro del Límite)

**Objetivo:** Verificar apariencia cuando no se excede

**Setup:**
- Configurar límite de 5 en "En Progreso"
- Tener 3 tareas en la columna

**Resultado Esperado:**
- ✅ Header con fondo normal (azul claro)
- ✅ Contador: "3/5" en color azul
- ✅ Sin borde rojo
- ✅ Sin icono de advertencia

---

### Test 2.2: WIP Excedido (Alerta Visual)

**Objetivo:** Verificar alertas cuando se excede el límite

**Setup:**
- Configurar límite de 3 en "En Progreso"
- Tener 5 tareas en la columna

**Resultado Esperado:**
- ✅ Header con fondo rojo claro
- ✅ Borde rojo grueso alrededor del header
- ✅ Contador: "5/3" en color rojo con fondo rojo
- ✅ Icono de advertencia (⚠️) visible

---

### Test 2.3: SnackBar al Exceder WIP en Drag

**Objetivo:** Verificar advertencia al mover tarea que excederá límite

**Setup:**
- Configurar límite de 3 en "Bloqueadas"
- Tener 3 tareas en "Bloqueadas"

**Pasos:**
1. Arrastrar una tarea de otra columna a "Bloqueadas"
2. Soltar la tarea

**Resultado Esperado:**
- ✅ Tarea se mueve correctamente
- ✅ Aparece SnackBar naranja
- ✅ Mensaje: "⚠️ WIP limit excedido en 'Bloqueadas' (4/3)"
- ✅ Header muestra alertas visuales (borde rojo, etc.)

---

### Test 2.4: Sin Límite Configurado

**Objetivo:** Verificar que no aparecen alertas sin límite

**Setup:**
- Sin límite configurado en "Completadas"
- Tener 15 tareas en la columna

**Resultado Esperado:**
- ✅ Header con fondo normal
- ✅ Contador: "15" (sin límite mostrado)
- ✅ Sin bordes rojos ni advertencias

---

## 3️⃣ Tests de Métricas

### Test 3.1: Métricas en Header (Inline)

**Objetivo:** Verificar que aparecen métricas en headers

**Setup:**
- Tener al menos 2 tareas completadas con fechas diferentes

**Resultado Esperado:**
- ✅ En columnas con tareas completadas:
  - Línea "⏱️ Lead Time: X.X días"
  - Línea "⚡ Cycle Time: X.X días"
- ✅ En columnas sin tareas completadas:
  - No aparecen métricas (solo header básico)

---

### Test 3.2: Abrir Diálogo de Métricas

**Objetivo:** Verificar que el diálogo se abre

**Pasos:**
1. En vista Kanban, hacer clic en botón de métricas (📊)

**Resultado Esperado:**
- ✅ Se abre diálogo "Métricas del Tablero"
- ✅ Sección de métricas generales
- ✅ Sección de métricas por columna
- ✅ Botón "Cerrar"

---

### Test 3.3: Métricas Generales

**Objetivo:** Verificar cálculo de WIP y Throughput

**Setup:**
- 3 tareas en "En Progreso"
- 2 tareas en "Bloqueadas"
- 5 tareas completadas en los últimos 7 días

**Resultado Esperado:**
- ✅ "Work In Progress (WIP): 5" (3 + 2)
- ✅ "Throughput (7 días): 5 tareas"
- ✅ Iconos y colores correctos

---

### Test 3.4: Lead Time Correcto

**Objetivo:** Verificar cálculo de Lead Time

**Setup:**
- Tarea 1: Creada 1-ene, Completada 10-ene (9 días)
- Tarea 2: Creada 2-ene, Completada 7-ene (5 días)
- Promedio esperado: 7 días

**Resultado Esperado:**
- ✅ Lead Time mostrado: "7.0 días" (o cercano)
- ✅ Solo considera tareas completadas

---

### Test 3.5: Cycle Time Correcto

**Objetivo:** Verificar cálculo de Cycle Time

**Setup:**
- Tarea 1: Inicio 3-ene, Fin 10-ene (7 días)
- Tarea 2: Inicio 4-ene, Fin 7-ene (3 días)
- Promedio esperado: 5 días

**Resultado Esperado:**
- ✅ Cycle Time mostrado: "5.0 días" (o cercano)
- ✅ Solo considera tareas completadas

---

### Test 3.6: Métricas por Columna

**Objetivo:** Verificar detalle de cada columna

**Pasos:**
1. Abrir diálogo de métricas
2. Revisar sección "Métricas por Columna"

**Resultado Esperado:**
- ✅ Cada columna tiene una card
- ✅ Muestra: Tareas, Lead Time, Cycle Time
- ✅ "N/A" cuando no hay datos
- ✅ Números correctos según datos

---

## 4️⃣ Tests de Drag & Drop

### Test 4.1: Drag Dentro de Misma Columna

**Objetivo:** Reordenar tareas sin cambiar estado

**Pasos:**
1. En columna "En Progreso" con 3+ tareas
2. Arrastrar tarea de posición 1 a posición 3
3. Soltar

**Resultado Esperado:**
- ✅ Tarea cambia de posición visualmente
- ✅ Estado de la tarea NO cambia (sigue en "En Progreso")
- ✅ No aparece SnackBar de confirmación
- ✅ Cambio es inmediato

---

### Test 4.2: Drag Entre Columnas

**Objetivo:** Mover tarea y cambiar estado

**Pasos:**
1. Arrastrar tarea de "Planificadas"
2. Soltar en "En Progreso"

**Resultado Esperado:**
- ✅ Tarea desaparece de "Planificadas"
- ✅ Tarea aparece en "En Progreso"
- ✅ SnackBar verde: "✓ Tarea 'XXX' movida a 'En Progreso'"
- ✅ Contador de ambas columnas se actualiza
- ✅ Cambio persiste al recargar

---

### Test 4.3: Actualización de Backend

**Objetivo:** Verificar que cambios se guardan

**Pasos:**
1. Mover tarea entre columnas
2. Esperar 2 segundos
3. Recargar la página completa (F5)

**Resultado Esperado:**
- ✅ Tarea sigue en nueva columna
- ✅ Estado actualizado en backend
- ✅ No se perdió el cambio

---

### Test 4.4: Recálculo de Métricas en Drag

**Objetivo:** Verificar que métricas se actualizan

**Setup:**
- Ver métricas antes del drag
- Mover tarea completada entre columnas (simular cambio)

**Pasos:**
1. Abrir diálogo de métricas (anotar valores)
2. Cerrar diálogo
3. Mover tarea entre columnas
4. Abrir diálogo de métricas nuevamente

**Resultado Esperado:**
- ✅ Contadores de tareas actualizados
- ✅ Métricas recalculadas (pueden cambiar)
- ✅ No hay delay visible

---

### Test 4.5: Feedback Visual Durante Drag

**Objetivo:** Verificar animaciones y feedback

**Pasos:**
1. Hacer clic y mantener en una tarea
2. Mover el mouse mientras se arrastra
3. Soltar

**Resultado Esperado:**
- ✅ Tarea se "levanta" con sombra
- ✅ Se puede ver dónde se soltará
- ✅ Animación suave al soltar
- ✅ Otras tareas se reorganizan

---

## 5️⃣ Tests de Persistencia

### Test 5.1: Persistencia de WIP Limits

**Objetivo:** Verificar que configuración sobrevive recargas

**Pasos:**
1. Configurar WIP limits en todas las columnas
2. Recargar página (F5)
3. Verificar headers

**Resultado Esperado:**
- ✅ Todos los límites persisten
- ✅ Headers muestran "X/Límite" correctamente
- ✅ Alertas visuales si corresponde

---

### Test 5.2: Persistencia por Proyecto

**Objetivo:** Verificar que cada proyecto tiene su configuración

**Pasos:**
1. En Proyecto A, configurar límite de 5 en "En Progreso"
2. Cambiar a Proyecto B
3. Configurar límite de 3 en "En Progreso"
4. Volver a Proyecto A

**Resultado Esperado:**
- ✅ Proyecto A sigue mostrando límite de 5
- ✅ Proyecto B mantiene límite de 3
- ✅ Configuraciones independientes

---

### Test 5.3: Limpiar Datos del Navegador

**Objetivo:** Verificar comportamiento al limpiar cache

**Pasos:**
1. Configurar WIP limits
2. Limpiar datos del navegador (localStorage)
3. Recargar aplicación

**Resultado Esperado:**
- ✅ WIP limits se resetean (sin límites)
- ✅ Headers muestran solo contador
- ✅ No hay errores de aplicación

---

## 📊 Reporte de Resultados

### Formato de Reporte

Para cada test, anotar:

```
Test X.X: [Nombre del Test]
Estado: ✅ Pasa | ❌ Falla | ⚠️ Parcial
Notas: [Cualquier observación]
```

### Criterio de Aceptación

La feature se considera **APROBADA** si:
- ✅ Al menos 20/23 tests pasan (87%)
- ✅ Todos los tests críticos pasan (marcados con 🔴)
- ✅ No hay bugs bloqueantes

### Tests Críticos 🔴

- Test 1.2: Establecer WIP Limit
- Test 2.2: WIP Excedido (Alerta Visual)
- Test 3.3: Métricas Generales
- Test 4.2: Drag Entre Columnas
- Test 5.1: Persistencia de WIP Limits

---

## 🐛 Registro de Bugs

Si encuentras bugs, documenta:

```
Bug #X
Severidad: 🔴 Crítico | 🟠 Alto | 🟡 Medio | 🟢 Bajo
Descripción: [Qué pasó]
Pasos para Reproducir:
  1. [Paso 1]
  2. [Paso 2]
Resultado Esperado: [Qué debería pasar]
Resultado Actual: [Qué pasó realmente]
```

---

## ✅ Checklist Final

Antes de aprobar la feature:

- [ ] Todos los tests ejecutados
- [ ] Reporte de resultados completado
- [ ] Bugs documentados (si hay)
- [ ] Tests críticos pasados
- [ ] Performance aceptable (< 1s para drag & drop)
- [ ] UI responsiva en diferentes resoluciones
- [ ] Documentación revisada

---

**Fecha de Ejecución:** _______________  
**Ejecutado por:** _______________  
**Resultado:** ✅ APROBADO | ❌ RECHAZADO | ⚠️ CON OBSERVACIONES

---

## 📝 Notas Adicionales

[Espacio para notas del tester]
