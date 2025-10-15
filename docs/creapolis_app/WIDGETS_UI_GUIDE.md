# 🎨 Widgets Personalizables - Guía Visual de UI

## Vista Normal (Modo Lectura)

```
┌────────────────────────────────────────────────────────┐
│ ← Creapolis          [✏️ Personalizar] [🔔] [👤]      │
├────────────────────────────────────────────────────────┤
│                                                        │
│  ┌──────────────────────────────────────────────────┐ │
│  │ 🏢  Mi Workspace             [Cambiar]           │ │
│  │     3 workspaces disponibles                     │ │
│  └──────────────────────────────────────────────────┘ │
│                                                        │
│  ┌──────────────────────────────────────────────────┐ │
│  │ 📊 Resumen del Día               [Ver todo]      │ │
│  │                                                  │ │
│  │  📝 5 tareas pendientes    📁 3 proyectos activos│ │
│  │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │ │
│  │                                     65%          │ │
│  └──────────────────────────────────────────────────┘ │
│                                                        │
│  ┌──────────────────────────────────────────────────┐ │
│  │ ⚡ Acciones Rápidas                              │ │
│  │                                                  │ │
│  │  [➕ Nuevo    ] [✓ Nueva      ]                 │ │
│  │  [  Proyecto ] [  Tarea      ]                  │ │
│  │                                                  │ │
│  │  [📂 Ver      ] [📋 Ver       ]                 │ │
│  │  [  Proyectos] [  Tareas     ]                  │ │
│  └──────────────────────────────────────────────────┘ │
│                                                        │
│  ┌──────────────────────────────────────────────────┐ │
│  │ ✓ Mis Tareas                     [Ver todas]    │ │
│  │                                                  │ │
│  │  • Actualizar documentación         [Media]     │ │
│  │  • Meeting con equipo               [Alta]      │ │
│  │  • Revisar código                   [Baja]      │ │
│  └──────────────────────────────────────────────────┘ │
│                                                        │
│  ┌──────────────────────────────────────────────────┐ │
│  │ 📁 Mis Proyectos                 [Ver todos]    │ │
│  │                                                  │ │
│  │  • Proyecto Alpha              ● En Progreso    │ │
│  │  • Proyecto Beta               ● Planificado    │ │
│  └──────────────────────────────────────────────────┘ │
│                                                        │
│  ┌──────────────────────────────────────────────────┐ │
│  │ 🕐 Actividad Reciente            [Ver toda]     │ │
│  │                                                  │ │
│  │  Juan completó "Tarea X"          Hace 2 horas  │ │
│  │  María creó "Proyecto Y"          Hace 1 día    │ │
│  └──────────────────────────────────────────────────┘ │
│                                                        │
└────────────────────────────────────────────────────────┘
```

## Vista Edición (Modo Personalización)

```
┌────────────────────────────────────────────────────────┐
│ ← Creapolis     [✓ Guardar] [↺ Reset] [🔔] [👤]       │
├────────────────────────────────────────────────────────┤
│                                                        │
│  ┌──────────────────────────────────────────────────┐ │
│  │ 🏢  Mi Workspace         [☰ Drag] [✕ Quitar]    │ │
│  │     3 workspaces disponibles                     │ │
│  └──────────────────────────────────────────────────┘ │
│      ↕️ (draggable)                                   │
│  ┌──────────────────────────────────────────────────┐ │
│  │ 📊 Resumen del Día       [☰ Drag] [✕ Quitar]    │ │
│  │  📝 5 tareas   📁 3 proyectos    ━━━━━━━━ 65%   │ │
│  └──────────────────────────────────────────────────┘ │
│      ↕️ (draggable)                                   │
│  ┌──────────────────────────────────────────────────┐ │
│  │ ⚡ Acciones Rápidas      [☰ Drag] [✕ Quitar]    │ │
│  │  [➕ Nuevo  ] [✓ Nueva ]  [📂 Ver  ] [📋 Ver  ] │ │
│  └──────────────────────────────────────────────────┘ │
│      ↕️ (draggable)                                   │
│  ┌──────────────────────────────────────────────────┐ │
│  │ ✓ Mis Tareas            [☰ Drag] [✕ Quitar]    │ │
│  │  • Actualizar documentación                      │ │
│  └──────────────────────────────────────────────────┘ │
│      ↕️ (draggable)                                   │
│  ┌──────────────────────────────────────────────────┐ │
│  │ 📁 Mis Proyectos        [☰ Drag] [✕ Quitar]    │ │
│  │  • Proyecto Alpha    • Proyecto Beta             │ │
│  └──────────────────────────────────────────────────┘ │
│      ↕️ (draggable)                                   │
│  ┌──────────────────────────────────────────────────┐ │
│  │ 🕐 Actividad Reciente   [☰ Drag] [✕ Quitar]    │ │
│  │  Juan completó "Tarea X"    María creó "Proj Y" │ │
│  └──────────────────────────────────────────────────┘ │
│                                                        │
│                                        ┌─────────────┐ │
│                                        │ ➕ Añadir   │ │
│                                        │   Widget    │ │
│                                        └─────────────┘ │
└────────────────────────────────────────────────────────┘
```

## Bottom Sheet - Añadir Widget

```
┌────────────────────────────────────────────────────────┐
│              ────  (drag handle)                       │
│                                                        │
│  ➕ Añadir Widget                               [✕]   │
│  ──────────────────────────────────────────────────── │
│                                                        │
│  ┌──────────────────────────────────────────────────┐ │
│  │ [📊]  Resumen del Día                       →    │ │
│  │       Resumen de tareas y proyectos del día      │ │
│  └──────────────────────────────────────────────────┘ │
│                                                        │
│  ┌──────────────────────────────────────────────────┐ │
│  │ [✓]   Mis Tareas                            →    │ │
│  │       Lista de tus tareas activas                │ │
│  └──────────────────────────────────────────────────┘ │
│                                                        │
│  ┌──────────────────────────────────────────────────┐ │
│  │ [📁]  Mis Proyectos                         →    │ │
│  │       Lista de proyectos recientes               │ │
│  └──────────────────────────────────────────────────┘ │
│                                                        │
│  ┌──────────────────────────────────────────────────┐ │
│  │ [🕐]  Actividad Reciente                    →    │ │
│  │       Actividad reciente en tus proyectos        │ │
│  └──────────────────────────────────────────────────┘ │
│                                                        │
└────────────────────────────────────────────────────────┘
```

## Estado Vacío

```
┌────────────────────────────────────────────────────────┐
│ ← Creapolis          [✏️ Personalizar] [🔔] [👤]      │
├────────────────────────────────────────────────────────┤
│                                                        │
│                                                        │
│                        📦                              │
│                    (widget icon)                       │
│                                                        │
│              Tu dashboard está vacío                   │
│                                                        │
│        Añade widgets para personalizar                 │
│             tu experiencia                             │
│                                                        │
│              ┌─────────────────┐                       │
│              │ ➕ Añadir Widget │                       │
│              └─────────────────┘                       │
│                                                        │
│                                                        │
└────────────────────────────────────────────────────────┘
```

## Diálogo de Confirmación - Reset

```
        ┌─────────────────────────────┐
        │  Resetear Configuración      │
        ├─────────────────────────────┤
        │                             │
        │  ¿Estás seguro de que       │
        │  quieres restaurar la       │
        │  configuración por defecto  │
        │  del dashboard?             │
        │                             │
        ├─────────────────────────────┤
        │  [Cancelar]    [Resetear]   │
        └─────────────────────────────┘
```

## Interacciones

### Modo Normal
- **Pull-to-refresh**: Refresca datos de los widgets
- **Click en widget**: Navega a vista detallada (según widget)
- **Click "Personalizar"**: Entra en modo edición

### Modo Edición
- **Arrastrar widget**: Cambia orden (visual feedback con elevación)
- **Click en ✕**: Elimina widget (sin confirmación)
- **Click en ➕**: Abre bottom sheet para añadir
- **Click "Guardar"**: Sale de modo edición y persiste cambios
- **Click "Reset"**: Muestra diálogo de confirmación

### Bottom Sheet
- **Scroll**: Lista todos los widgets disponibles
- **Click en widget**: Lo añade y cierra el bottom sheet
- **Click en ✕**: Cierra sin añadir
- **Swipe down**: Cierra sin añadir

## Estados Visuales

### Widget Normal
- Fondo: Card color del tema
- Bordes: Redondeados (12px)
- Elevación: 1
- Padding: 16px

### Widget Hover (modo edición)
- Fondo: Card color del tema
- Botones: Visibles (Drag + Eliminar)
- Cursor: Pointer

### Widget Siendo Arrastrado
- Fondo: Card color del tema
- Elevación: 8
- Opacidad: 0.8
- Cursor: Grabbing

### FAB
- Color: Primary del tema
- Icono: ➕
- Texto: "Añadir Widget"
- Posición: Bottom-right
- Solo visible en modo edición

## Animaciones

- **Entrada de modo edición**: Fade in de botones (200ms)
- **Salida de modo edición**: Fade out de botones (200ms)
- **Reordenar**: Smooth transition (300ms)
- **Añadir widget**: Slide in from bottom (400ms)
- **Eliminar widget**: Fade out + scale down (300ms)
- **Bottom sheet**: Slide up (300ms)

## Responsive

### Mobile (< 600px)
- FAB: Extended (con texto)
- Cards: Full width
- Bottom sheet: 90% altura max

### Tablet (600px - 1024px)
- FAB: Extended (con texto)
- Cards: Full width con max-width 800px
- Bottom sheet: 70% altura max

### Desktop (> 1024px)
- FAB: Extended (con texto)
- Cards: Full width con max-width 1000px
- Bottom sheet: 60% altura max
- Hover effects: Activos

## Accesibilidad

- **Semántica**: Todos los botones tienen labels
- **Keyboard**: Tab navigation funcional
- **Screen readers**: Anuncios de cambios de estado
- **Touch targets**: Mínimo 48x48px
- **Contraste**: WCAG AA compliant
