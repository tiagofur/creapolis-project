# 🎯 Guía de Uso: Tablero Kanban Avanzado

Esta guía explica cómo utilizar las nuevas características del tablero Kanban con WIP Limits y métricas.

---

## 📊 Acceder al Tablero Kanban

1. Navega a un proyecto que contenga tareas
2. En la vista de tareas, busca el selector de vista (generalmente en el AppBar)
3. Selecciona la vista "Kanban"

---

## 🎛️ Configurar WIP Limits

### ¿Qué son los WIP Limits?

Los **WIP Limits (Work In Progress Limits)** son límites en la cantidad de tareas que pueden estar simultáneamente en una columna. Ayudan a:
- Evitar sobrecarga de trabajo
- Mejorar el flujo de trabajo
- Identificar cuellos de botella
- Fomentar la finalización de tareas

### Cómo Configurar

1. En el tablero Kanban, haz clic en el botón de **configuración** (⚙️) en la esquina superior derecha
2. Se abrirá el diálogo "Configurar Tablero Kanban"
3. Para cada columna, puedes:
   - **Establecer un límite**: Ingresa un número (ejemplo: 5)
   - **Sin límite**: Deja el campo vacío
4. Haz clic en **"Guardar"**

### Ejemplo de Configuración

```
Planificadas:     (sin límite)
En Progreso:      5
Bloqueadas:       2
Completadas:      (sin límite)
Canceladas:       (sin límite)
```

Esta configuración:
- Permite hasta 5 tareas en progreso simultáneamente
- Limita a 2 el número de tareas bloqueadas
- No limita las tareas planificadas, completadas o canceladas

---

## ⚠️ Alertas Visuales

### Cuando se Excede un WIP Limit

El tablero mostrará **alertas visuales automáticas**:

1. **Borde rojo** alrededor del header de la columna
2. **Contador en rojo** mostrando "X/Límite" (ejemplo: "6/5")
3. **Icono de advertencia** (⚠️) junto al contador

### Al Mover una Tarea

Si intentas mover una tarea a una columna que excedería su WIP limit:
- La tarea **SÍ se moverá** (no está bloqueado)
- Aparecerá un **SnackBar naranja** con el mensaje:
  ```
  ⚠️ WIP limit excedido en "En Progreso" (6/5)
  ```

**Nota:** Las alertas son informativas y no bloquean acciones. Esto permite flexibilidad en casos excepcionales.

---

## 📈 Ver Métricas

### Métricas en Headers

En cada columna del tablero, verás métricas en tiempo real:

```
┌─────────────────────────────┐
│ 🔵 En Progreso         3/5  │
│ ⏱️ Lead Time: 4.2 días      │
│ ⚡ Cycle Time: 3.1 días     │
└─────────────────────────────┘
```

**Nota:** Las métricas solo aparecen si hay tareas completadas en el proyecto.

### Diálogo de Métricas Completo

1. Haz clic en el botón de **métricas** (📊) en la esquina superior derecha
2. Se abrirá el diálogo "Métricas del Tablero"

#### Métricas Generales

- **Work In Progress (WIP)**: Tareas actualmente en progreso o bloqueadas
- **Throughput (7 días)**: Número de tareas completadas en los últimos 7 días

#### Métricas por Columna

Para cada columna verás:
- **Tareas**: Cantidad actual de tareas en la columna
- **Lead Time**: Tiempo promedio desde creación hasta completado
- **Cycle Time**: Tiempo promedio de trabajo activo

---

## 📊 Explicación de Métricas

### Lead Time

**Definición:** Tiempo total desde que se crea una tarea hasta que se completa.

**Fórmula:** `Fecha de actualización - Fecha de creación`

**Ejemplo:**
- Tarea creada: 1 de enero
- Tarea completada: 10 de enero
- Lead Time: 9 días

**Utilidad:** Mide la velocidad de entrega percibida por el cliente.

### Cycle Time

**Definición:** Tiempo de trabajo activo en una tarea.

**Fórmula:** `Fecha de fin - Fecha de inicio`

**Ejemplo:**
- Tarea iniciada: 3 de enero
- Tarea finalizada: 10 de enero
- Cycle Time: 7 días

**Utilidad:** Mide la eficiencia del equipo en completar tareas una vez iniciadas.

### WIP (Work In Progress)

**Definición:** Número de tareas actualmente en progreso o bloqueadas.

**Fórmula:** `Cuenta de tareas con estado "En Progreso" o "Bloqueadas"`

**Utilidad:** Indica la carga de trabajo actual. Un WIP alto puede indicar sobrecarga.

### Throughput

**Definición:** Velocidad de entrega del equipo.

**Fórmula:** `Número de tareas completadas en un período`

**Ejemplo:** 12 tareas completadas en los últimos 7 días

**Utilidad:** Mide la productividad y permite predecir entregas futuras.

---

## 🎯 Drag & Drop

### Mover Tareas Entre Columnas

1. **Haz clic y mantén presionado** sobre una tarjeta de tarea
2. **Arrastra** la tarea hacia la columna destino
3. **Suelta** la tarea en la nueva posición

**Comportamiento:**
- ✅ La UI se actualiza inmediatamente
- ✅ El estado de la tarea se guarda en el backend
- ✅ Aparece un SnackBar verde confirmando el movimiento
- ✅ Las métricas se recalculan automáticamente
- ⚠️ Si excedes un WIP limit, verás una advertencia pero el movimiento se permite

### Reordenar Dentro de una Columna

1. Arrastra una tarea a otra posición dentro de la misma columna
2. El orden visual cambia
3. El estado de la tarea NO cambia (sigue en la misma columna)

---

## 💡 Mejores Prácticas

### Establecer WIP Limits

1. **Empieza con límites generosos**: Puedes ajustar después
2. **Observa patrones**: Mira cuántas tareas suele haber en cada columna
3. **WIP ideal para "En Progreso"**: Entre 1-3 tareas por persona del equipo
4. **Bloqueadas**: Mantén bajo (2-3), indica problemas si se excede

### Interpretar Métricas

- **Lead Time alto**: Puede indicar demoras en el proceso completo
- **Cycle Time alto**: Puede indicar tareas muy complejas o interrupciones
- **WIP alto constante**: Sobrecarga del equipo, considera reducir entradas
- **Throughput bajo**: Considera revisar procesos o recursos

### Usar Alertas

- **Borde rojo persistente**: Investiga por qué se acumulan tareas
- **WIP excedido frecuentemente**: Ajusta el límite o revisa el proceso
- **Muchas tareas bloqueadas**: Prioriza desbloquear antes de iniciar nuevas

---

## 🔧 Persistencia de Configuración

- **Por proyecto**: Cada proyecto tiene su propia configuración de WIP limits
- **Local**: La configuración se guarda en el navegador (SharedPreferences)
- **No sincronizada**: La configuración es personal y no se comparte con el equipo

**Nota:** Si limpias los datos del navegador, perderás la configuración.

---

## 🎨 Referencia Visual

### Estados del Header

#### Normal
```
┌─────────────────────────────┐
│ 🔵 En Progreso         3/5  │ ← Azul, dentro del límite
└─────────────────────────────┘
```

#### WIP Excedido
```
╔═════════════════════════════╗
║ 🔴 En Progreso    6/5  ⚠️  ║ ← Rojo, borde grueso, advertencia
╚═════════════════════════════╝
```

#### Sin WIP Limit
```
┌─────────────────────────────┐
│ 🟢 Completadas          12  │ ← Solo número, sin límite
└─────────────────────────────┘
```

---

## ❓ Preguntas Frecuentes

### ¿Puedo bloquear el movimiento de tareas cuando se excede el WIP?

No, por diseño las alertas son informativas y no bloqueantes. Esto permite flexibilidad en casos excepcionales. Si necesitas bloquear, considera implementar una política de equipo.

### ¿Por qué no veo métricas en los headers?

Las métricas de Lead Time y Cycle Time solo se muestran cuando hay tareas completadas en el proyecto. Si no hay tareas completadas, no hay datos para calcular promedios.

### ¿Cómo se calculan las métricas?

- Solo se consideran **tareas completadas**
- Los cálculos se hacen en **tiempo real**
- No hay caché, siempre reflejan el estado actual

### ¿La configuración se comparte con el equipo?

No, la configuración de WIP limits es personal y local al navegador. Cada miembro del equipo puede tener sus propios límites configurados.

### ¿Qué pasa si elimino un WIP limit?

1. Abre el diálogo de configuración
2. Borra el número del campo de límite (déjalo vacío)
3. Guarda
4. El contador mostrará solo el número de tareas, sin límite

---

## 🚀 Próximas Características (Roadmap)

Las siguientes características están preparadas pero no implementadas visualmente:

- **Swimlanes**: Agrupar tareas por prioridad, asignado, etc.
- **Gráficos de Cumulative Flow**: Visualización del flujo acumulado
- **Control Charts**: Estabilidad del proceso
- **Exportar métricas**: CSV, Excel, PDF

---

**¿Necesitas ayuda?** Contacta al equipo de soporte o revisa la documentación técnica en `KANBAN_WIP_LIMITS_IMPLEMENTATION.md`
