# 📱 Dashboard Interactivo - Guía Visual UI

## 🎨 Layout del Dashboard

```
┌─────────────────────────────────────────────────────────────┐
│  Creapolis                              🔔  👤              │
│  [≡] Dashboard                                              │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│  🔍 Filtros                              [Limpiar]          │
│  ┌──────────┐ ┌──────────┐                                 │
│  │📁Proyecto│ │📅 Fecha  │                                 │
│  └──────────┘ └──────────┘                                 │
│  ┌────────────────────┐ ┌───────────────────┐              │
│  │ Proyecto X    [×] │ │ 01/10 - 31/10 [×]│              │
│  └────────────────────┘ └───────────────────┘              │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│  📊 Métricas de Tareas                    [Filtrado]        │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐          │
│  │   ✓    │  │   ▶    │  │   ⚠    │  │   ⏰   │          │
│  │  15    │  │   8    │  │   3    │  │   5    │          │
│  │Completd│  │Progreso│  │Retrasad│  │Planeada│          │
│  └────────┘  └────────┘  └────────┘  └────────┘          │
│                                                             │
│  Progreso General                              75.5%        │
│  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░       │
│  15 de 20 tareas                     3 retrasadas           │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│  🥧 Distribución por Prioridad                              │
│                                                             │
│       ╱───────╲              ● Crítica: 3                  │
│      ╱    🟣   ╲             ● Alta: 5                      │
│     │  🔴    🟠 │            ● Media: 8                     │
│      ╲    🟢   ╱             ● Baja: 4                      │
│       ╲───────╱                                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│  📊 Progreso Semanal                                        │
│  Tareas completadas por día                                 │
│                                                             │
│   8 ┤                                    █                  │
│   7 ┤                                    █                  │
│   6 ┤              █                     █                  │
│   5 ┤        █     █                     █                  │
│   4 ┤  █     █     █           █         █                  │
│   3 ┤  █     █     █     █     █         █                  │
│   2 ┤  █     █     █     █     █         █                  │
│   1 ┤  █     █     █     █     █     █   █                  │
│   0 └──┴─────┴─────┴─────┴─────┴─────┴───┴──               │
│      Lun   Mar   Mié   Jue   Vie   Sáb  Dom                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│  ℹ️ Info del Workspace                                      │
│  ┌────┐                                                     │
│  │ 🏢 │  Mi Workspace Activo                                │
│  └────┘  3 proyectos · 15 tareas                           │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│  📝 Resumen del Día                         [Ver todo]      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                 │
│  │    📋    │  │    📁    │  │    ✓     │                 │
│  │    15    │  │     3    │  │    12    │                 │
│  │  Tareas  │  │Proyectos │  │Completad │                 │
│  └──────────┘  └──────────┘  └──────────┘                 │
│                                                             │
│  Progreso General                              60% complet  │
│  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░       │
│                                                             │
│  Próximas Tareas                                            │
│  ● [ALTA] Implementar dashboard                             │
│  ● [MEDIA] Revisar PRs pendientes                           │
│  ● [BAJA] Actualizar documentación                          │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 Vista Responsive - Mobile

```
┌───────────────────────────┐
│ Creapolis          🔔  👤 │
└───────────────────────────┘
┌───────────────────────────┐
│ 🔍 Filtros   [Limpiar]    │
│ 📁Proyecto  📅Fecha       │
│ [Proyecto X ×]            │
│ [01/10-31/10 ×]           │
└───────────────────────────┘
┌───────────────────────────┐
│ 📊 Métricas de Tareas     │
│ ┌────┐ ┌────┐             │
│ │ ✓  │ │ ▶  │             │
│ │ 15 │ │ 8  │             │
│ │Cmp │ │Prg │             │
│ └────┘ └────┘             │
│ ┌────┐ ┌────┐             │
│ │ ⚠  │ │ ⏰ │             │
│ │ 3  │ │ 5  │             │
│ │Ret │ │Pln │             │
│ └────┘ └────┘             │
│                           │
│ Progreso General   75.5%  │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓░░░  │
│ 15 de 20 tareas           │
│ 3 retrasadas              │
└───────────────────────────┘
┌───────────────────────────┐
│ 🥧 Distribución Prioridad │
│                           │
│    ╱─────╲                │
│   ╱ 🟣🔴 ╲               │
│   │🟠  🟢│               │
│    ╲─────╱                │
│                           │
│ ● Crítica: 3              │
│ ● Alta: 5                 │
│ ● Media: 8                │
│ ● Baja: 4                 │
└───────────────────────────┘
┌───────────────────────────┐
│ 📊 Progreso Semanal       │
│                           │
│ 8┤        █               │
│ 6┤  █  █  █               │
│ 4┤  █  █  █  █  █  █  █   │
│ 2┤  █  █  █  █  █  █  █   │
│ 0└──┴──┴──┴──┴──┴──┴──    │
│   L  M  X  J  V  S  D     │
└───────────────────────────┘
```

---

## 🖱️ Interacciones del Usuario

### 1. Aplicar Filtro de Proyecto

```
Usuario hace clic en [📁 Proyecto]
         ↓
┌─────────────────────────────┐
│ Seleccionar Proyecto        │
├─────────────────────────────┤
│ ✓ Proyecto Alpha            │ ← Seleccionado
│   Proyecto Beta             │
│   Proyecto Gamma            │
│   Proyecto Delta            │
└─────────────────────────────┘
         ↓
Filtro aplicado - Se actualiza dashboard
         ↓
┌─────────────────────────────┐
│ 🔍 Filtros      [Limpiar]   │
│ [Proyecto Alpha ×]          │
└─────────────────────────────┘
```

### 2. Aplicar Filtro de Fecha

```
Usuario hace clic en [📅 Fecha]
         ↓
┌─────────────────────────────┐
│   Octubre 2025              │
│ L  M  M  J  V  S  D         │
│ 1  2  3  4  5  6  7         │
│ 8  9 10 [11 12 13 14]       │ ← Rango seleccionado
│15 16 17 18 19 20 21         │
│22 23 24 25 26 27 28         │
│29 30 31                     │
└─────────────────────────────┘
         ↓
Filtro aplicado
         ↓
┌─────────────────────────────┐
│ 🔍 Filtros      [Limpiar]   │
│ [11/10 - 14/10 ×]           │
└─────────────────────────────┘
```

### 3. Interacción con Gráfico de Pastel

```
Usuario toca/hover sección "Alta"
         ↓
┌─────────────────────────────┐
│    ╱─────╲                  │
│   ╱  🟣  ╲   ← Destacado    │
│   │🔴(25%)│  ← Tooltip      │
│   │🟠  🟢│                  │
│    ╲─────╱                  │
└─────────────────────────────┘
```

### 4. Interacción con Gráfico de Barras

```
Usuario toca/hover barra del Miércoles
         ↓
┌─────────────────────────────┐
│        ┌────┐                │
│        │ █  │ ← Tooltip      │
│        │Mié │   "6 tareas"   │
│ █  █   │ 6  │   █   █   █    │
│ █  █   └────┘   █   █   █    │
└─────────────────────────────┘
```

---

## 🎨 Paleta de Colores

### Estados de Tareas
- **Completadas**: 🟢 Verde (`Colors.green`)
- **En Progreso**: 🔵 Azul (`Colors.blue`)
- **Retrasadas**: 🔴 Rojo (`Colors.red`)
- **Planificadas**: 🟠 Naranja (`Colors.orange`)

### Prioridades
- **Crítica**: 🟣 Morado (`Colors.purple`)
- **Alta**: 🔴 Rojo (`Colors.red`)
- **Media**: 🟠 Naranja (`Colors.orange`)
- **Baja**: 🟢 Verde (`Colors.green`)

### Elementos UI
- **Primary**: Azul del tema (`theme.colorScheme.primary`)
- **Container**: Gris claro (`theme.colorScheme.surfaceContainerHighest`)
- **Texto**: Negro/Blanco según tema (`theme.colorScheme.onSurface`)

---

## 📏 Breakpoints Responsive

### Desktop (>600px)
- KPI cards: 100px de ancho
- Gráficos: Tamaño completo con margen lateral
- Layout: Columna única con padding de 16px

### Mobile (<600px)
- KPI cards: 80px de ancho, modo compacto
- Gráficos: Ancho completo sin padding lateral
- Layout: Stack vertical con menos spacing

---

## 🔄 Estados de los Widgets

### TaskMetricsWidget

**Loading**:
```
┌───────────────────────────┐
│ 📊 Métricas de Tareas     │
│                           │
│         ⏳                │
│    Cargando...            │
│                           │
└───────────────────────────┘
```

**Error**:
```
┌───────────────────────────┐
│ 📊 Métricas de Tareas     │
│                           │
│         ⚠️                │
│ Error al cargar métricas  │
│                           │
└───────────────────────────┘
```

**Sin Datos**:
```
┌───────────────────────────┐
│ 📊 Métricas de Tareas     │
│                           │
│         📭                │
│   No hay tareas           │
│                           │
└───────────────────────────┘
```

### WeeklyProgressChartWidget

**Con Datos**:
```
┌───────────────────────────┐
│ 📊 Progreso Semanal       │
│ Tareas completadas/día    │
│                           │
│ 8┤        █               │
│ 6┤  █  █  █               │
│ 4┤  █  █  █  █  █  █  █   │
│ 2┤  █  █  █  █  █  █  █   │
│ 0└──┴──┴──┴──┴──┴──┴──    │
└───────────────────────────┘
```

**Sin Datos**:
```
┌───────────────────────────┐
│ 📊 Progreso Semanal       │
│ Tareas completadas/día    │
│                           │
│         📭                │
│ No hay datos para mostrar │
│                           │
└───────────────────────────┘
```

---

## 📱 Navegación y Flujo

### Desde Dashboard

```
Dashboard
   │
   ├─→ [Proyecto] → Bottom Sheet → Seleccionar → Aplicar Filtro
   │
   ├─→ [Fecha] → Date Picker → Seleccionar Rango → Aplicar Filtro
   │
   ├─→ [Limpiar] → Eliminar todos los filtros
   │
   ├─→ [Ver todo] (en Resumen) → Lista completa de tareas
   │
   └─→ [Tarea] → Detalle de tarea (futuro)
```

---

## 🎯 Casos de Uso Principales

### 1. Ver Métricas Generales
```
Usuario → Dashboard → Ve todas las métricas sin filtros
```

### 2. Ver Métricas de un Proyecto Específico
```
Usuario → Dashboard → [Proyecto] → Selecciona "Proyecto Alpha"
→ Todas las métricas se actualizan con datos del proyecto
```

### 3. Ver Progreso de la Semana Pasada
```
Usuario → Dashboard → [Fecha] → Selecciona rango de 7 días atrás
→ Gráficos muestran datos del período seleccionado
```

### 4. Comparar Prioridades
```
Usuario → Dashboard → Observa gráfico de pastel
→ Toca secciones para ver porcentajes exactos
→ Identifica que hay muchas tareas de alta prioridad
```

### 5. Identificar Tareas Retrasadas
```
Usuario → Dashboard → Ve KPI "Retrasadas" en rojo
→ 3 tareas retrasadas → Toma acción
```

---

## ✨ Animaciones y Transiciones

### Gráfico de Pastel
- **Entrada**: Fade in + scale (300ms)
- **Hover**: Sección crece (radius +10px) en 200ms
- **Tooltip**: Aparece con fade in (150ms)

### Gráfico de Barras
- **Entrada**: Barras crecen desde 0 (500ms, staggered)
- **Hover**: Barra cambia de color (200ms)
- **Tooltip**: Aparece sobre la barra (150ms)

### Filtros
- **Chip activo**: Aparece con slide in desde derecha (300ms)
- **Eliminar chip**: Slide out + fade out (250ms)
- **Bottom Sheet**: Slide up desde abajo (350ms)

---

## 🔍 Accesibilidad

### Elementos Implementados
- ✅ **Tooltips**: Todos los iconos tienen tooltip descriptivo
- ✅ **Contraste**: Colores cumplen WCAG AA
- ✅ **Tamaños táctiles**: Mínimo 44x44 píxeles
- ✅ **Texto legible**: Tamaño mínimo 12sp, recomendado 14sp+
- ✅ **Feedback visual**: Estados de hover/pressed visibles

### Mejoras Futuras
- [ ] Screen reader labels (Semantics)
- [ ] Navegación por teclado
- [ ] Modo de alto contraste
- [ ] Tamaños de fuente escalables

---

Esta guía visual muestra cómo se ve y funciona el dashboard interactivo implementado.
