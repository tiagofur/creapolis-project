# 🎨 Referencia Visual: Tablero Kanban con WIP Limits

**Versión:** 1.0  
**Fecha:** 13 de octubre de 2025

Este documento proporciona una referencia visual en texto ASCII de cómo se verá el nuevo tablero Kanban.

---

## 📱 Vista Completa del Tablero

```
┌────────────────────────────────────────────────────────────────────────────────┐
│ Tablero Kanban                                              [⚙️ Config] [📊 Métricas] │
├────────────────────────────────────────────────────────────────────────────────┤
│                                                                                │
│ ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌──────┐ │
│ │Planificadas │  │En Progreso  │  │ Bloqueadas  │  │Completadas  │  │Cancel│ │
│ │     3       │  │   5/5  ⚠️   │  │    2/2  ⚠️  │  │     12      │  │  1   │ │
│ │             │  │Lead: 4.2d   │  │Lead: 8.5d   │  │Lead: 3.8d   │  │      │ │
│ │             │  │Cycle: 3.1d  │  │Cycle: 6.2d  │  │Cycle: 2.9d  │  │      │ │
│ ├─────────────┤  ╞═════════════╡  ╞═════════════╡  ├─────────────┤  ├──────┤ │
│ │             │  ║             ║  ║             ║  │             │  │      │ │
│ │ ┌─────────┐ │  ║ ┌─────────┐ ║  ║ ┌─────────┐ ║  │ ┌─────────┐ │  │      │ │
│ │ │ Task 1  │ │  ║ │ Task 4  │ ║  ║ │ Task 7  │ ║  │ │ Task 10 │ │  │      │ │
│ │ └─────────┘ │  ║ └─────────┘ ║  ║ └─────────┘ ║  │ └─────────┘ │  │      │ │
│ │             │  ║             ║  ║             ║  │             │  │      │ │
│ │ ┌─────────┐ │  ║ ┌─────────┐ ║  ║ ┌─────────┐ ║  │ ┌─────────┐ │  │      │ │
│ │ │ Task 2  │ │  ║ │ Task 5  │ ║  ║ │ Task 8  │ ║  │ │ Task 11 │ │  │      │ │
│ │ └─────────┘ │  ║ └─────────┘ ║  ║ └─────────┘ ║  │ └─────────┘ │  │      │ │
│ │             │  ║             ║  ║             ║  │             │  │      │ │
│ │ ┌─────────┐ │  ║ ┌─────────┐ ║  ║             ║  │ ┌─────────┐ │  │      │ │
│ │ │ Task 3  │ │  ║ │ Task 6  │ ║  ║             ║  │ │ Task 12 │ │  │      │ │
│ │ └─────────┘ │  ║ └─────────┘ ║  ║             ║  │ └─────────┘ │  │      │ │
│ │             │  ║             ║  ║             ║  │     ...     │  │      │ │
│ └─────────────┘  ╞═════════════╡  ╞═════════════╡  └─────────────┘  └──────┘ │
│                  ║ ┌─────────┐ ║                                              │
│                  ║ │ Task 9  │ ║  ← Nota: Bordes gruesos rojos                │
│                  ║ └─────────┘ ║     cuando WIP excedido                      │
│                  ╚═════════════╝                                              │
└────────────────────────────────────────────────────────────────────────────────┘
```

**Notas:**
- `║` = Borde rojo cuando WIP excedido
- `⚠️` = Icono de advertencia visible
- `Lead: X.Xd` = Lead Time en días
- `Cycle: X.Xd` = Cycle Time en días
- Los números rojos indican WIP excedido

---

## 🎯 Header de Columna - Estados

### Estado 1: Normal (Sin WIP o Dentro del Límite)

```
┌─────────────────────────────────┐
│ 🔵 En Progreso           3/5    │ ← Azul, dentro del límite
│ ⏱️  Lead Time: 4.2 días          │
│ ⚡ Cycle Time: 3.1 días         │
└─────────────────────────────────┘
```

- Fondo: Azul muy claro (`#E3F2FD`)
- Borde: Gris claro
- Contador: Azul con fondo azul claro
- Sin iconos de advertencia

### Estado 2: WIP Excedido

```
╔═════════════════════════════════╗
║ 🔴 En Progreso      [6/5]  ⚠️  ║ ← Rojo, WIP excedido
║ ⏱️  Lead Time: 4.2 días          ║
║ ⚡ Cycle Time: 3.1 días         ║
╚═════════════════════════════════╝
```

- Fondo: Rojo muy claro (`#FFEBEE`)
- Borde: Rojo grueso (2px, `#F44336`)
- Contador: Texto blanco en fondo rojo sólido
- Icono de advertencia: `⚠️` visible y prominente

### Estado 3: Sin WIP Limit Configurado

```
┌─────────────────────────────────┐
│ 🟢 Completadas            12    │ ← Verde, sin límite
│ ⏱️  Lead Time: 3.8 días          │
│ ⚡ Cycle Time: 2.9 días         │
└─────────────────────────────────┘
```

- Fondo: Verde muy claro
- Borde: Gris claro
- Contador: Solo número, sin "/límite"
- Sin iconos de advertencia

### Estado 4: Columna Vacía

```
┌─────────────────────────────────┐
│ ⚪ Canceladas              0    │
│                                 │
│         📭                      │
│     Sin tareas                  │
│                                 │
└─────────────────────────────────┘
```

- No muestra métricas (no hay datos)
- Icono de inbox vacío
- Mensaje "Sin tareas"

---

## 🔧 Diálogo de Configuración

```
┌─────────────────────────────────────────────┐
│ Configurar Tablero Kanban              [×] │
├─────────────────────────────────────────────┤
│                                             │
│  WIP Limits por Columna                     │
│  ─────────────────────────                  │
│                                             │
│  Planificadas        [ Sin límite      ]    │
│  En Progreso         [ 5               ]    │
│  Bloqueadas          [ 2               ]    │
│  Completadas         [ Sin límite      ]    │
│  Canceladas          [ Sin límite      ]    │
│                                             │
│  💡 Tip: Deja vacío para sin límite         │
│                                             │
├─────────────────────────────────────────────┤
│                      [Cancelar]  [Guardar] │
└─────────────────────────────────────────────┘
```

**Interacciones:**
- Campos de texto aceptan solo números
- Vacío = sin límite
- Enter en campo = siguiente campo
- Escape = cancelar
- Enter en último campo = guardar

---

## 📊 Diálogo de Métricas

```
┌─────────────────────────────────────────────────────────┐
│ Métricas del Tablero                               [×] │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Métricas Generales                                     │
│  ──────────────────                                     │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 💼 Work In Progress (WIP)           5           │   │
│  │    Tareas en progreso + bloqueadas              │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📈 Throughput (7 días)         12 tareas        │   │
│  │    Velocidad de entrega semanal                 │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  ─────────────────────────────────────────────────────  │
│                                                         │
│  Métricas por Columna                                   │
│  ────────────────────                                   │
│                                                         │
│  ╔═══════════════════════════════════════════════╗     │
│  ║ Planificadas                               3  ║     │
│  ║ Lead Time: N/A   Cycle Time: N/A             ║     │
│  ╚═══════════════════════════════════════════════╝     │
│                                                         │
│  ╔═══════════════════════════════════════════════╗     │
│  ║ En Progreso                                5  ║     │
│  ║ Lead Time: 4.2 días   Cycle Time: 3.1 días   ║     │
│  ╚═══════════════════════════════════════════════╝     │
│                                                         │
│  ╔═══════════════════════════════════════════════╗     │
│  ║ Completadas                               12  ║     │
│  ║ Lead Time: 3.8 días   Cycle Time: 2.9 días   ║     │
│  ╚═══════════════════════════════════════════════╝     │
│                                                         │
│  [Más columnas...]                                      │
│                                                         │
├─────────────────────────────────────────────────────────┤
│                                            [Cerrar]    │
└─────────────────────────────────────────────────────────┘
```

**Características:**
- Scroll vertical si hay muchas columnas
- N/A cuando no hay datos suficientes
- Colores por tipo de métrica:
  - WIP: Azul
  - Throughput: Verde
  - Columnas: Gris con bordes

---

## 🎬 Animaciones y Feedback

### 1. Drag & Drop

```
Inicio del Drag:
┌─────────────┐
│ Task 1      │ ← Click y hold
└─────────────┘

Durante el Drag:
    ┌─────────────┐
    │▒▒▒▒▒▒▒▒▒▒▒▒▒│ ← Sombra (elevación)
    │ Task 1      │
    │▒▒▒▒▒▒▒▒▒▒▒▒▒│
    └─────────────┘
         ↓ Movimiento con mouse

Al Soltar (Sin exceder WIP):
┌─────────────────────────────────────────────┐
│ ✓ Tarea "Task 1" movida a "En Progreso"    │ ← SnackBar verde
└─────────────────────────────────────────────┘

Al Soltar (Excediendo WIP):
┌─────────────────────────────────────────────┐
│ ⚠️ WIP limit excedido en "En Progreso" (6/5)│ ← SnackBar naranja
└─────────────────────────────────────────────┘
```

### 2. Guardar Configuración

```
Antes:
┌─────────────────────────────────┐
│ En Progreso            5        │
└─────────────────────────────────┘

Usuario configura WIP = 5

Después:
┌─────────────────────────────────┐
│ En Progreso           5/5       │ ← Aparece límite
└─────────────────────────────────┘

SnackBar:
┌─────────────────────────────────┐
│ ✓ Configuración guardada        │ ← Verde, 2 segundos
└─────────────────────────────────┘
```

### 3. Exceder WIP

```
Estado Normal (3/5):
┌─────────────────────────────────┐
│ 🔵 En Progreso          3/5     │
└─────────────────────────────────┘

Arrastrar tarea #4:
┌─────────────────────────────────┐
│ 🔵 En Progreso          4/5     │ ← Todavía OK
└─────────────────────────────────┘

Arrastrar tarea #5:
┌─────────────────────────────────┐
│ 🔵 En Progreso          5/5     │ ← Justo en el límite
└─────────────────────────────────┘

Arrastrar tarea #6:
╔═════════════════════════════════╗
║ 🔴 En Progreso      [6/5]  ⚠️  ║ ← ¡BOOM! Animación de borde rojo
╚═════════════════════════════════╝
        ↓
┌─────────────────────────────────────────────┐
│ ⚠️ WIP limit excedido en "En Progreso" (6/5)│
└─────────────────────────────────────────────┘
```

---

## 🎨 Paleta de Colores

### Estados de Columna

```
Planificadas:
  Normal:   #9E9E9E (Gris)
  Fondo:    #F5F5F5 (Gris muy claro)

En Progreso:
  Normal:   #2196F3 (Azul)
  Fondo:    #E3F2FD (Azul muy claro)
  Excedido: #F44336 (Rojo) + borde
  
Bloqueadas:
  Normal:   #F44336 (Rojo)
  Fondo:    #FFEBEE (Rojo muy claro)
  Excedido: Borde rojo más grueso

Completadas:
  Normal:   #4CAF50 (Verde)
  Fondo:    #E8F5E9 (Verde muy claro)

Canceladas:
  Normal:   #BDBDBD (Gris claro)
  Fondo:    #FAFAFA (Blanco grisáceo)
```

### Feedback Visual

```
SnackBar Éxito:
  Fondo: #4CAF50 (Verde)
  Texto: #FFFFFF (Blanco)
  Icono: ✓

SnackBar Advertencia:
  Fondo: #FF9800 (Naranja)
  Texto: #FFFFFF (Blanco)
  Icono: ⚠️

SnackBar Error:
  Fondo: #F44336 (Rojo)
  Texto: #FFFFFF (Blanco)
  Icono: ✕
```

---

## 📐 Dimensiones

### Tablero

```
Altura mínima viewport: 600px
Ancho recomendado: 1400px+

Columna:
  Ancho: 300px
  Alto: Dinámico (min 400px)
  Espaciado: 16px entre columnas

Header:
  Altura normal: ~90px (con métricas)
  Altura sin métricas: ~60px
  Padding: 16px

Task Card:
  Ancho: 284px (300px - 16px padding)
  Alto: Variable según contenido
  Margen: 4px vertical, 8px horizontal
```

### Diálogos

```
Configuración:
  Ancho: 400px
  Alto: Dinámico (max 600px)

Métricas:
  Ancho: 500px
  Alto: Dinámico (max 700px, scroll)
```

---

## 🔤 Tipografía

### Headers

```
Título de columna:
  Font: Roboto Medium
  Tamaño: 16px
  Peso: 600
  Color: Color del estado

Contador:
  Font: Roboto Bold
  Tamaño: 12px
  Peso: 700

Métricas inline:
  Font: Roboto Regular
  Tamaño: 10px
  Color: #616161 (Gris oscuro)
```

### Diálogos

```
Título:
  Font: Roboto Medium
  Tamaño: 20px
  Peso: 500

Cuerpo:
  Font: Roboto Regular
  Tamaño: 14px

Labels:
  Font: Roboto Regular
  Tamaño: 12px
  Color: #757575
```

---

## 🎭 Estados Interactivos

### Botones del Toolbar

```
Normal:
  [⚙️ Config]
  Fondo: Transparente
  Hover: Gris claro (#F5F5F5)

Hover:
  [⚙️ Config]
   ▲▲▲▲▲▲▲▲
  Fondo: Gris claro
  Cursor: pointer

Pressed:
  [⚙️ Config]
  Fondo: Gris medio (#E0E0E0)
  Elevación reducida
```

### Task Cards durante Drag

```
Normal:
┌─────────────┐
│ Task 1      │
│ Priority: H │
└─────────────┘
Elevación: 2dp

Hover:
┌─────────────┐
│ Task 1      │ ← Cursor: grab
│ Priority: H │
└─────────────┘
Elevación: 3dp

Dragging:
  ┌─────────────┐
  │▒Task 1▒▒▒▒▒▒│ ← Cursor: grabbing
  │▒Priority: H▒│
  └─────────────┘
Elevación: 8dp
Opacidad: 0.9
```

---

## 📱 Responsive

### Desktop (> 1200px)

```
┌────────────────────────────────────────────────────┐
│  [Planif]  [En Progreso]  [Bloq]  [Complet]  [Canc]│
│    3           5/5          2/2      12        1   │
└────────────────────────────────────────────────────┘
```

Todas las columnas visibles simultáneamente

### Tablet (768px - 1200px)

```
┌──────────────────────────────────────┐
│ [Planif] [En Prog] [Bloq] [Complet] →│
│   3        5/5       2/2      12     │
└──────────────────────────────────────┘
```

Scroll horizontal para última columna

### Mobile (< 768px)

```
┌──────────────────┐
│ [Planif] [En Pr→]│
│   3        5/5   │
└──────────────────┘
```

Scroll horizontal significativo
Métricas inline ocultas, solo en diálogo

---

## 🎯 Casos de Uso Visuales

### Caso 1: Configurar por Primera Vez

```
Paso 1: Tablero sin configurar
┌─────────────────────────────────┐
│ En Progreso            5        │ ← Solo contador
└─────────────────────────────────┘

Paso 2: Abrir configuración
┌─────────────────────────────┐
│ Configurar Tablero Kanban   │
│ En Progreso  [ 5           ]│ ← Ingresar límite
└─────────────────────────────┘

Paso 3: Resultado
┌─────────────────────────────────┐
│ En Progreso           5/5       │ ← Aparece límite
└─────────────────────────────────┘
```

### Caso 2: WIP Excedido

```
Situación:
- Límite: 5
- Tareas actuales: 6

Vista:
╔═════════════════════════════════╗
║ 🔴 En Progreso     [6/5]  ⚠️   ║ ← Rojo, borde grueso
║ ⏱️  Lead Time: 4.2 días          ║
║ ⚡ Cycle Time: 3.1 días         ║
╚═════════════════════════════════╝

Acción:
"Tengo demasiadas tareas, debo mover algunas
 o completar las actuales antes de iniciar más"
```

### Caso 3: Análisis de Métricas

```
Usuario abre diálogo de métricas:

Observa:
- Throughput: 12 tareas/semana ✅
- WIP actual: 7 ⚠️ (alto)
- Lead Time Bloqueadas: 8.5 días ⚠️ (muy alto)
- Lead Time En Progreso: 4.2 días ✅

Conclusión:
"Hay muchas tareas bloqueadas, aumentando
 el Lead Time. Priorizar desbloqueo."
```

---

## ✨ Conclusión

Este documento proporciona una referencia visual completa de la implementación del tablero Kanban con WIP Limits. Úsalo como guía durante el desarrollo y testing para asegurar consistencia visual.

**Próximo Paso:** Ejecutar tests manuales usando `KANBAN_TEST_PLAN.md` y comparar con estas referencias visuales.

---

**Documento:** Referencia Visual v1.0  
**Fecha:** 13 de octubre de 2025  
**Autor:** GitHub Copilot
