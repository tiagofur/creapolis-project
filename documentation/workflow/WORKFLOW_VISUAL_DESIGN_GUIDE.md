# 🎨 Visual Design Guide - Workflow Markers

## Diseño Visual de Marcadores de Proyectos

Este documento muestra el diseño visual final de los marcadores de workflows implementados.

## 📱 Vista General de Tipos de Proyectos

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│                        CREAPOLIS - PROYECTOS                                │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────┐  ┌──────────────────────┐  ┌──────────────────────┐
│  │ [Activo]            │  │ [Activo] [↗️ Comp.] │  │ [Activo] [👥 Comp.] │
│  ├──────────────────────┤  ├──────────────────────┤  ├──────────────────────┤
│  │                      │  │                      │  │                      │
│  │  Proyecto Personal   │  │  Proyecto Equipo     │  │  Proyecto Invitado   │
│  │                      │  │                      │  │                      │
│  │  Mi proyecto solo    │  │  Compartido con el   │  │  Me invitaron a      │
│  │                      │  │  equipo              │  │  colaborar           │
│  │                      │  │                      │  │                      │
│  │  ████████░░░░ 60%    │  │  ██████░░░░░░ 40%    │  │  ████████████ 80%    │
│  │                      │  │                      │  │                      │
│  │  📅 01/01 - 31/12   │  │  📅 15/03 - 30/11   │  │  📅 01/02 - 31/10   │
│  │  👤 Juan (Yo)       │  │  👤 Juan (Yo)       │  │  👤 María           │
│  │                      │  │                      │  │                      │
│  └──────────────────────┘  └──────────────────────┘  └──────────────────────┘
│       PERSONAL                COMPARTIDO POR MÍ        COMPARTIDO CONMIGO
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 🎨 Anatomía de un ProjectCard

### Proyecto Personal (Sin Marcador)
```
┌───────────────────────────────────────────┐
│ ┌─────────────────────────────────────┐   │
│ │ [Activo]                    ⚠️      │   │ ← Header AZUL (#3B82F6)
│ └─────────────────────────────────────┘   │
│                                           │
│   Nombre del Proyecto                     │ ← Título
│                                           │
│   Descripción breve del proyecto que      │ ← Descripción (3 líneas max)
│   estoy desarrollando actualmente...      │
│                                           │
│   ████████████████░░░░░░░░░░░░ 65%       │ ← Barra progreso AZUL
│                                           │
│   📅 01/01/2025 - 31/12/2025             │ ← Fechas
│   👤 Juan Pérez                          │ ← Manager
│                                           │
│ ┌─────────────────────────────────────┐   │
│ │ [Editar]               [Eliminar]   │   │ ← Acciones
│ └─────────────────────────────────────┘   │
└───────────────────────────────────────────┘
```

### Proyecto Compartido por Mí
```
┌───────────────────────────────────────────┐
│ ┌─────────────────────────────────────┐   │
│ │ [Activo] [↗️ Compartido por mí]     │   │ ← Header AZUL + Badge PÚRPURA
│ └─────────────────────────────────────┘   │
│                                           │
│   Proyecto Colaborativo                   │
│                                           │
│   Este proyecto lo comparto con mi        │
│   equipo de desarrollo...                 │
│                                           │
│   ████████░░░░░░░░░░░░░░░░░░ 40%         │
│                                           │
│   📅 15/03/2025 - 30/11/2025             │
│   👤 Juan Pérez (Tú)                     │
│                                           │
│ ┌─────────────────────────────────────┐   │
│ │ [Editar]               [Eliminar]   │   │
│ └─────────────────────────────────────┘   │
└───────────────────────────────────────────┘
```

### Proyecto Compartido Conmigo
```
┌───────────────────────────────────────────┐
│ ┌─────────────────────────────────────┐   │
│ │ [Activo] [👥 Compartido conmigo]    │   │ ← Header AZUL + Badge VERDE
│ └─────────────────────────────────────┘   │
│                                           │
│   Sistema de Gestión                      │
│                                           │
│   Me invitaron a colaborar en este        │
│   proyecto del equipo central...          │
│                                           │
│   ██████████████████░░░░░░░ 70%          │
│                                           │
│   📅 01/02/2025 - 31/10/2025             │
│   👤 María García (Manager)              │
│                                           │
│ ┌─────────────────────────────────────┐   │
│ │ [Ver Detalles]                      │   │ ← Solo vista
│ └─────────────────────────────────────┘   │
└───────────────────────────────────────────┘
```

## 🏷️ Diseño de Badges/Marcadores

### Marcador "Compartido por mí"
```
┌──────────────────────┐
│ ↗️  Compartido por mí │  ← Color: Púrpura #8B5CF6
└──────────────────────┘    Border: Púrpura 30% opacity
     ↑        ↑             Background: Púrpura 10% opacity
   Icono    Texto           Font: 11px, weight: 600
  (share)
```

### Marcador "Compartido conmigo"
```
┌──────────────────────┐
│ 👥  Compartido conmigo│  ← Color: Verde #10B981
└──────────────────────┘    Border: Verde 30% opacity
     ↑        ↑             Background: Verde 10% opacity
   Icono    Texto           Font: 11px, weight: 600
  (people)
```

## 🎨 Paleta de Colores

```
┌─────────────────────────────────────────────────┐
│                                                 │
│  COLOR PRIMARIO (Base)                          │
│  ████████████  #3B82F6  (Azul)                  │
│  Para: Header, barra de progreso               │
│                                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│  COLOR SECUNDARIO (Badge 1)                     │
│  ████████████  #8B5CF6  (Púrpura)               │
│  Para: "Compartido por mí"                      │
│                                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│  COLOR TERCIARIO (Badge 2)                      │
│  ████████████  #10B981  (Verde)                 │
│  Para: "Compartido conmigo"                     │
│                                                 │
└─────────────────────────────────────────────────┘
```

## 📐 Especificaciones de Diseño

### ProjectCard
```
Dimensiones:
- Width: Match parent (Grid: 0.75 aspect ratio)
- Min Height: 280px
- Padding: 12px
- Border Radius: 12px
- Elevation: 2

Header:
- Background: Primary (#3B82F6)
- Padding: 12px horizontal, 8px vertical
- Text Color: White
- Font: Bold, 12px

Badge:
- Height: Auto (content)
- Padding: 6px horizontal, 3px vertical
- Border Radius: 10px
- Icon Size: 14px
- Font Size: 11px
- Font Weight: 600
- Spacing between icon and text: 4px

Progress Bar:
- Height: 6px
- Border Radius: 4px
- Color: Primary (#3B82F6)
- Background: Surface variant
```

### Marcadores
```
Container:
- Padding: 6px horizontal, 3px vertical
- Border Radius: 10px
- Border Width: 1px
- Border Opacity: 30%
- Background Opacity: 10%

Icon:
- Size: 12-14px (configurable)
- Color: Badge color

Text:
- Font Size: 10-11px (configurable)
- Font Weight: 600
- Color: Badge color

Spacing:
- Between icon and text: 4px
- From border to content: 6px horizontal, 3px vertical
```

## 🔄 Estados Interactivos

### Normal State
```
┌──────────────────────┐
│ ↗️  Compartido por mí │  Opacity: 100%
└──────────────────────┘  Shadow: None
```

### Hover State (Desktop)
```
┌──────────────────────┐
│ ↗️  Compartido por mí │  Opacity: 100%
└──────────────────────┘  Shadow: Elevation 4
```

### Pressed State
```
┌──────────────────────┐
│ ↗️  Compartido por mí │  Opacity: 80%
└──────────────────────┘  Shadow: None
```

## 📱 Responsive Behavior

### Mobile (< 600px)
```
┌─────────────────────────────┐
│  [Grid 2 columns]           │
│  ┌──────┐  ┌──────┐         │
│  │      │  │      │         │
│  │ Card │  │ Card │         │
│  │      │  │      │         │
│  └──────┘  └──────┘         │
│  ┌──────┐  ┌──────┐         │
│  │      │  │      │         │
│  │ Card │  │ Card │         │
│  │      │  │      │         │
│  └──────┘  └──────┘         │
└─────────────────────────────┘
```

### Tablet (600px - 1200px)
```
┌─────────────────────────────────────────┐
│  [Grid 3 columns]                       │
│  ┌──────┐  ┌──────┐  ┌──────┐          │
│  │      │  │      │  │      │          │
│  │ Card │  │ Card │  │ Card │          │
│  │      │  │      │  │      │          │
│  └──────┘  └──────┘  └──────┘          │
└─────────────────────────────────────────┘
```

### Desktop (> 1200px)
```
┌─────────────────────────────────────────────────────┐
│  [Grid 3-4 columns with more spacing]               │
│  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐            │
│  │      │  │      │  │      │  │      │            │
│  │ Card │  │ Card │  │ Card │  │ Card │            │
│  │      │  │      │  │      │  │      │            │
│  └──────┘  └──────┘  └──────┘  └──────┘            │
└─────────────────────────────────────────────────────┘
```

## 🎯 Decisiones de Diseño

### ✅ Por qué un solo color base (azul)?
- **Consistencia visual**: Todos los proyectos son iguales en importancia
- **Reduce fatiga visual**: No hay que procesar múltiples colores
- **Jerarquía clara**: Los marcadores destacan sobre el fondo uniforme

### ✅ Por qué badges en lugar de colores diferentes?
- **Información explícita**: El badge dice exactamente qué es
- **Extensible**: Fácil agregar nuevos tipos sin cambiar la paleta
- **Accesibilidad**: No depende solo del color para distinguir

### ✅ Por qué proyectos personales sin marcador?
- **Diseño limpio**: Reduce el ruido visual
- **Enfoque en lo importante**: Los compartidos son la excepción, no la regla
- **Usabilidad**: Menos elementos = más espacio para contenido

## 📊 Comparación: Antes vs Después

### ❌ ANTES (Diseño Antiguo)
```
┌──────────────────────┐
│ [Header Verde]       │  ← Diferentes colores por estado
├──────────────────────┤
│ Proyecto A           │
│ ████ 50%             │  ← Color verde también
└──────────────────────┘

┌──────────────────────┐
│ [Header Naranja]     │  ← Difícil distinguir relación
├──────────────────────┤
│ Proyecto B           │
│ ████ 30%             │  ← Color naranja también
└──────────────────────┘
```

### ✅ DESPUÉS (Diseño Nuevo)
```
┌──────────────────────┐
│ [Activo]             │  ← Siempre azul
├──────────────────────┤
│ Proyecto A           │
│ ████ 50%             │  ← Siempre azul
└──────────────────────┘

┌──────────────────────┐
│ [Activo] [👥 Comp.]  │  ← Badge claro = compartido
├──────────────────────┤
│ Proyecto B           │
│ ████ 30%             │  ← Siempre azul
└──────────────────────┘
```

## 🎬 Flujo de Usuario

```
Usuario abre app
      ↓
Ve lista de proyectos
      ↓
Escanea visualmente los cards
      ↓
┌─────────────────────────────────────┐
│ Identifica rápidamente:             │
│ - Sin badge = Solo yo               │
│ - Badge púrpura = Yo compartí       │
│ - Badge verde = Me compartieron     │
└─────────────────────────────────────┘
      ↓
Hace tap en el proyecto deseado
      ↓
Navega a detalles
```

## 📚 Referencias de Implementación

- **Entity**: `lib/domain/entities/project.dart`
- **Widget Badge**: `lib/presentation/widgets/project/project_relation_marker.dart`
- **Card**: `lib/presentation/widgets/project/project_card.dart`
- **Theme**: `lib/core/theme/app_theme.dart`

---

**Diseñado con**: Material Design 3  
**Principios**: Consistencia, Claridad, Accesibilidad  
**Última revisión**: 2025-10-10
