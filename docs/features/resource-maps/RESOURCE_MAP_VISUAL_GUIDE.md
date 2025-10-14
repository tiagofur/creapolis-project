# 🎨 Guía Visual: Mapa de Asignación de Recursos

## 📱 Capturas de Pantalla de la Funcionalidad

### 1. Vista Principal - Grid View

```
┌─────────────────────────────────────────────────────┐
│ ← Mapa de Recursos    [Grid] [Filter] [Sort] [↻]  │
├─────────────────────────────────────────────────────┤
│                                                     │
│  📅 [Selector de Rango de Fechas]                  │
│     [01/10/2025] ──────────────────→ [31/10/2025]  │
│                                                     │
│  📊 [Tarjeta de Estadísticas]                      │
│     👥 12 Miembros | ⚠️ 3 Sobrecargados            │
│     ⏱️ 45.2h Promedio | 🎯 78% Utilización         │
│                                                     │
│  ┌──────────────────┐  ┌──────────────────┐        │
│  │  👤 Juan Pérez   │  │  👤 María García │        │
│  │  ⚠️ Sobrecargado │  │  ✅ Disponible   │        │
│  │  ⏱️ 120h • 8.5h/d│  │  ⏱️ 80h • 5.3h/d │        │
│  │  📋 15 tareas    │  │  📋 10 tareas    │        │
│  │                  │  │                  │        │
│  │  [Tareas ▼]     │  │  [Tareas ▼]     │        │
│  └──────────────────┘  └──────────────────┘        │
│                                                     │
│  ┌──────────────────┐  ┌──────────────────┐        │
│  │  👤 Pedro López  │  │  👤 Ana Martínez │        │
│  │  🔵 Carga Normal │  │  ✅ Disponible   │        │
│  │  ⏱️ 95h • 6.8h/d │  │  ⏱️ 65h • 4.3h/d │        │
│  │  📋 12 tareas    │  │  📋 8 tareas     │        │
│  └──────────────────┘  └──────────────────┘        │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### 2. Vista de Lista Expandida

```
┌─────────────────────────────────────────────────────┐
│ ← Mapa de Recursos    [List] [Filter] [Sort] [↻]   │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │  👤 Juan Pérez           ⚠️ Sobrecargado [▼]│   │
│  │  ─────────────────────────────────────────  │   │
│  │  ⏱️ 120h total  •  📅 8.5h/día  •  📋 15    │   │
│  │  ─────────────────────────────────────────  │   │
│  │                                             │   │
│  │  📋 Tareas Asignadas (15)                   │   │
│  │                                             │   │
│  │  ┌─────────────────────────────────────┐   │   │
│  │  │ ⋮⋮ Implementar Login         🔵 EN P│   │   │
│  │  │ ⏱️ 8.0h • 📅 01/10 - 03/10 (3d)     │   │   │
│  │  │ ⌚ Mantén presionado para reasignar  │   │   │
│  │  └─────────────────────────────────────┘   │   │
│  │                                             │   │
│  │  ┌─────────────────────────────────────┐   │   │
│  │  │ ⋮⋮ Diseñar Dashboard         🟢 COM │   │   │
│  │  │ ⏱️ 12.0h • 📅 04/10 - 06/10 (3d)    │   │   │
│  │  │ ⌚ Mantén presionado para reasignar  │   │   │
│  │  └─────────────────────────────────────┘   │   │
│  │                                             │   │
│  │  📅 Carga Diaria                            │   │
│  │  🟢 < 6h  🟠 6-8h  🔴 > 8h                  │   │
│  │                                             │   │
│  │  Semana 1: [🟢][🟠][🔴][🔴][🟠][⚪][⚪]    │   │
│  │  Semana 2: [🔴][🟠][🟠][🟢][🟢][⚪][⚪]    │   │
│  │                                             │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### 3. Drag & Drop en Acción

```
┌─────────────────────────────────────────────────────┐
│ ← Mapa de Recursos                        [↻]       │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Origen (Juan Pérez - Sobrecargado)                │
│  ┌──────────────────────────────────────────┐      │
│  │  📋 Tareas Asignadas (15)                │      │
│  │  ┌────────────────────────────┐          │      │
│  │  │ ⋮⋮ Implementar Login  [🔵] │ ⬅ Drag   │      │
│  │  │ (semi-transparente 30%)     │          │      │
│  │  └────────────────────────────┘          │      │
│  │  ┌────────────────────────────┐          │      │
│  │  │ ⋮⋮ Diseñar Dashboard  [🟢] │          │      │
│  │  └────────────────────────────┘          │      │
│  └──────────────────────────────────────────┘      │
│                                                     │
│      ┌────────────────────────────────┐            │
│      │ ╔════════════════════════════╗ │ ⬅ Feedback │
│      │ ║ 📋 Implementar Login       ║ │   Drag     │
│      │ ║ 🔵 EN PROGRESO             ║ │   (elevado)│
│      │ ║ ⏱️ 8.0h • 📅 01/10-03/10  ║ │            │
│      │ ╚════════════════════════════╝ │            │
│      └────────────────────────────────┘            │
│                    │                                │
│                    │ Arrastrando...                 │
│                    ↓                                │
│  Destino (María García - Disponible)               │
│  ┌──────────────────────────────────────────┐      │
│  │  ╔════════════════════════════════════╗  │ ⬅ Drop│
│  │  ║  📋 Tareas Asignadas (10)          ║  │   Zone│
│  │  ║  (Borde azul resaltado)            ║  │   Hover│
│  │  ╚════════════════════════════════════╝  │      │
│  │  ┌────────────────────────────┐          │      │
│  │  │ ⋮⋮ Crear API REST     [🔵] │          │      │
│  │  └────────────────────────────┘          │      │
│  └──────────────────────────────────────────┘      │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### 4. Diálogo de Confirmación

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│         ┌─────────────────────────────┐             │
│         │  Reasignar tarea            │             │
│         ├─────────────────────────────┤             │
│         │                             │             │
│         │  ¿Deseas reasignar          │             │
│         │  "Implementar Login"        │             │
│         │  a María García?            │             │
│         │                             │             │
│         │  ┌─────────┐  ┌──────────┐  │             │
│         │  │Cancelar │  │Reasignar │  │             │
│         │  └─────────┘  └──────────┘  │             │
│         └─────────────────────────────┘             │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### 5. Feedback Post-Reasignación

```
┌─────────────────────────────────────────────────────┐
│ ← Mapa de Recursos                                  │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ╔══════════════════════════════════════════════╗  │
│  ║ ✅ Tarea reasignada a María García          ║  │
│  ║    exitosamente                              ║  │
│  ╚══════════════════════════════════════════════╝  │
│                                                     │
│  Juan Pérez (Actualizado)                          │
│  ┌──────────────────────────────────────────┐      │
│  │  👤 Juan Pérez      🔵 Carga Normal      │      │
│  │  ⏱️ 112h • 8.0h/d • 📋 14 tareas        │      │
│  │  (Ya no está sobrecargado)               │      │
│  └──────────────────────────────────────────┘      │
│                                                     │
│  María García (Actualizado)                        │
│  ┌──────────────────────────────────────────┐      │
│  │  👤 María García    🔵 Carga Normal      │      │
│  │  ⏱️ 88h • 5.9h/d • 📋 11 tareas         │      │
│  │  (Recibió nueva tarea)                   │      │
│  └──────────────────────────────────────────┘      │
│                                                     │
└─────────────────────────────────────────────────────┘
```

## 🎨 Paleta de Colores

### Estados de Usuario
```
┌──────────────────────────────────────────┐
│ ⚠️ Sobrecargado                           │
│ Background: errorContainer (Rojo claro)  │
│ Text: onErrorContainer (Rojo oscuro)     │
│ Icon: warning                            │
├──────────────────────────────────────────┤
│ ✅ Disponible                             │
│ Background: green.shade100 (Verde claro) │
│ Text: green.shade800 (Verde oscuro)      │
│ Icon: check_circle                       │
├──────────────────────────────────────────┤
│ 🔵 Carga Normal                           │
│ Background: blue.shade100 (Azul claro)   │
│ Text: blue.shade800 (Azul oscuro)        │
│ Icon: none                               │
└──────────────────────────────────────────┘
```

### Carga Diaria (Calendario)
```
Intensidad de Color
──────────────────────────────────────
🟢 < 6 horas      │ Colors.green.shade100
🟠 6-8 horas      │ Colors.orange.shade100
🔴 > 8 horas      │ Colors.red.shade100
⚪ Sin carga      │ Colors.grey.shade200
```

### Estados de Tarea
```
┌────────────────────────┬──────────────────┐
│ Estado                 │ Color            │
├────────────────────────┼──────────────────┤
│ 🔵 EN PROGRESO         │ Blue             │
│ 🟢 COMPLETADA          │ Green            │
│ ⚫ PLANIFICADA          │ Grey             │
│ 🔴 BLOQUEADA           │ Red              │
│ ⚫ CANCELADA            │ Grey.shade600    │
└────────────────────────┴──────────────────┘
```

## 🎭 Animaciones y Transiciones

### 1. Hover sobre DragTarget
```
Animación: AnimatedContainer
Duración: 200ms
Cambios:
  - Border: 0px → 2px (primary color)
  - BoxShadow: none → blur 8px + spread 2px
  - Color shadow: primary con alpha 0.3
```

### 2. Dragging Feedback
```
Widget: Material con elevation: 8
Ancho: 280px (fijo)
Cambios visuales:
  - Background: primaryContainer
  - Border: primary, width: 2px
  - BorderRadius: 8px
  - Text color: onPrimaryContainer
```

### 3. Child When Dragging
```
Efecto: Opacity(0.3)
Mantiene posición original
Semi-transparente para feedback visual
```

### 4. Card Expansion
```
Trigger: onTap en header
Animation: setState con icon rotate
  - expand_more → expand_less
  - Muestra/oculta lista de tareas
```

## 🔄 Flujo de Usuario Típico

### Escenario: Reasignar tarea de usuario sobrecargado

```
1. Entrar al Mapa de Recursos
   ↓
   Pantalla muestra grid con todos los recursos
   Juan aparece con badge "⚠️ Sobrecargado"

2. Aplicar filtro "Sobrecargados"
   ↓
   Solo muestra Juan y otros 2 usuarios sobrecargados

3. Expandir card de Juan
   ↓
   Ve sus 15 tareas asignadas
   Identifica "Implementar Login" como candidata

4. Long Press en "Implementar Login"
   ↓
   Tarea se eleva con efecto visual
   La tarea original queda semi-transparente

5. Arrastrar sobre card de María
   ↓
   Card de María se resalta con borde azul
   Visual feedback confirma hover

6. Soltar tarea
   ↓
   Aparece diálogo de confirmación
   "¿Deseas reasignar 'Implementar Login' a María García?"

7. Confirmar reasignación
   ↓
   Backend actualiza assignedUserId
   SnackBar verde: "✅ Tarea reasignada exitosamente"

8. Vista se actualiza automáticamente
   ↓
   Juan: 112h (8.0h/d) - 14 tareas - 🔵 Carga Normal
   María: 88h (5.9h/d) - 11 tareas - 🔵 Carga Normal
   
   Objetivo: ✅ Balanceo de carga exitoso
```

## 📐 Layout y Responsive

### Grid View (2 columnas)
```
Configuración:
- crossAxisCount: 2
- childAspectRatio: 0.85
- crossAxisSpacing: 12
- mainAxisSpacing: 12

Ideal para:
- Tablets en landscape
- Pantallas grandes (> 600dp)
- Vista rápida de todo el equipo
```

### List View (1 columna)
```
Configuración:
- ListView.builder con separators
- Padding: 16px horizontal
- Spacing: 12px entre cards

Ideal para:
- Móviles en portrait
- Análisis detallado de recursos
- Visualización de calendario diario
```

### Breakpoints Sugeridos
```
Mobile Portrait:  < 600dp  → List View recomendado
Mobile Landscape: 600-900dp → Grid View funcional
Tablet:          > 900dp   → Grid View óptimo
```

## 🎯 Patrones de Interacción

### Gestos Soportados
```
┌──────────────────┬────────────────────────────┐
│ Gesto            │ Acción                     │
├──────────────────┼────────────────────────────┤
│ Tap en header    │ Expandir/colapsar card     │
│ Long press       │ Iniciar drag de tarea      │
│ Drag             │ Mover tarea sobre usuarios │
│ Drop             │ Reasignar tarea            │
│ Pull to refresh  │ Actualizar datos           │
│ Tap en botón     │ Cambiar vista/filtro/orden │
└──────────────────┴────────────────────────────┘
```

### Feedback Visual
```
┌──────────────────────────┬─────────────────────┐
│ Acción                   │ Feedback            │
├──────────────────────────┼─────────────────────┤
│ Long press iniciado      │ Vibración + elevate │
│ Drag sobre target válido │ Borde azul + shadow │
│ Drop exitoso             │ SnackBar verde      │
│ Error en reasignación    │ SnackBar rojo       │
│ Filtro activo            │ Banner informativo  │
│ Carga en progreso        │ CircularIndicator   │
└──────────────────────────┴─────────────────────┘
```

## 💡 Tips de Uso

### Para maximizar eficiencia:

1. **Usa filtros específicos**
   - "Sobrecargados" para identificar problemas
   - "Disponibles" para encontrar capacidad libre

2. **Aprovecha el ordenamiento**
   - Por disponibilidad: identifica quién puede tomar más trabajo
   - Por carga: balancea de mayor a menor

3. **Revisa el calendario diario**
   - Identifica días específicos con sobrecarga
   - Planifica reasignaciones considerando fechas

4. **Confirma antes de reasignar**
   - Verifica skills del usuario destino
   - Considera dependencias de tareas

5. **Usa vista grid para overview**
   - Rápida identificación de problemas
   - Vista general del equipo

6. **Usa vista lista para análisis**
   - Detalles de cada recurso
   - Calendario diario visible

---

**Última actualización**: 14 de Octubre, 2025
