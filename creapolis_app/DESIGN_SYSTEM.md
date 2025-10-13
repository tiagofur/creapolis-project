# 🎨 Creapolis Design System

Sistema de diseño completo que establece las bases visuales y de interacción de la aplicación Creapolis.

---

## 📋 Tabla de Contenidos

- [Paleta de Colores](#-paleta-de-colores)
- [Tipografía](#-tipografía)
- [Espaciado](#-espaciado)
- [Grid System y Responsive](#-grid-system-y-responsive)
- [Bordes y Elevaciones](#-bordes-y-elevaciones)
- [Componentes](#-componentes)
- [Tokens de Diseño](#-tokens-de-diseño)

---

## 🎨 Paleta de Colores

### Colores Primarios

```dart
// Azul - Color principal de la marca
AppColors.primary = #3B82F6      // Blue 500
AppColors.primaryDark = #2563EB  // Blue 600
AppColors.primaryLight = #60A5FA // Blue 400
```

**Uso**: Acciones principales, botones primarios, enlaces, elementos destacados.

### Colores Secundarios

```dart
// Púrpura - Color secundario
AppColors.secondary = #8B5CF6      // Purple 500
AppColors.secondaryDark = #7C3AED  // Purple 600
AppColors.secondaryLight = #A78BFA // Purple 400
```

**Uso**: Acciones secundarias, elementos de soporte, características especiales.

### Colores Semánticos

#### Estados

```dart
AppColors.success = #10B981  // Green 500 - Operaciones exitosas
AppColors.warning = #F59E0B  // Orange 500 - Advertencias
AppColors.error = #EF4444    // Red 500 - Errores
AppColors.info = #3B82F6     // Blue 500 - Información
```

#### Estados de Tareas

```dart
AppColors.statusPlanned = #6B7280      // Grey 500 - Tarea planificada
AppColors.statusInProgress = #3B82F6   // Blue 500 - Tarea en progreso
AppColors.statusCompleted = #10B981    // Green 500 - Tarea completada
```

**Uso**:
- `success`: Confirmaciones, operaciones completadas, tareas finalizadas
- `warning`: Alertas no críticas, campos que requieren atención
- `error`: Errores, validaciones fallidas, operaciones canceladas
- `info`: Mensajes informativos, tooltips, ayuda contextual

### Colores Neutros

Escala de grises completa para texto, fondos y elementos de interfaz:

```dart
AppColors.white = #FFFFFF
AppColors.grey50 = #F9FAFB   // Fondos muy claros
AppColors.grey100 = #F3F4F6  // Fondos claros
AppColors.grey200 = #E5E7EB  // Bordes, divisores
AppColors.grey300 = #D1D5DB  // Bordes destacados
AppColors.grey400 = #9CA3AF  // Texto deshabilitado
AppColors.grey500 = #6B7280  // Texto secundario
AppColors.grey600 = #4B5563  // Texto principal
AppColors.grey700 = #374151  // Texto destacado
AppColors.grey800 = #1F2937  // Superficies oscuras
AppColors.grey900 = #111827  // Texto principal oscuro
AppColors.black = #000000
```

### Colores de Fondo

```dart
// Tema Claro
AppColors.background = #F9FAFB  // Grey 50 - Fondo general
AppColors.surface = #FFFFFF     // White - Superficies (cards, modals)

// Tema Oscuro
AppColors.backgroundDark = #111827  // Grey 900 - Fondo general
AppColors.surfaceDark = #1F2937     // Grey 800 - Superficies
```

### Guía de Uso de Colores

| Elemento | Color | Contraste |
|----------|-------|-----------|
| Botón primario | `primary` sobre `white` | ✅ WCAG AAA |
| Botón secundario | `secondary` sobre `white` | ✅ WCAG AAA |
| Texto principal | `grey900` sobre `white` | ✅ WCAG AAA |
| Texto secundario | `grey600` sobre `white` | ✅ WCAG AA |
| Enlaces | `primary` sobre `white` | ✅ WCAG AAA |
| Éxito | `success` sobre `white` | ✅ WCAG AAA |
| Error | `error` sobre `white` | ✅ WCAG AAA |

---

## 📝 Tipografía

### Familias Tipográficas

```dart
// Sistema por defecto
Primary Font: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif
Monospace Font: 'SF Mono', Monaco, 'Courier New', monospace
```

**Características**:
- Fuente del sistema nativa para máximo rendimiento
- Excelente legibilidad en todas las plataformas
- Soporte completo para Material Design 3

### Escala Tipográfica

```dart
AppFontSizes.xs = 12.0    // Etiquetas pequeñas, badges
AppFontSizes.sm = 14.0    // Texto secundario, captions
AppFontSizes.md = 16.0    // Texto base (body)
AppFontSizes.lg = 18.0    // Subtítulos, texto destacado
AppFontSizes.xl = 20.0    // Títulos de sección
AppFontSizes.xxl = 24.0   // Títulos de página
AppFontSizes.xxxl = 32.0  // Títulos grandes, heros
```

### Estilos de Texto

#### Títulos (Headlines)

```dart
// H1 - Títulos principales de pantalla
TextStyle(
  fontSize: AppFontSizes.xxxl,  // 32px
  fontWeight: FontWeight.bold,   // 700
  height: 1.2,                   // Line height
)

// H2 - Títulos de sección
TextStyle(
  fontSize: AppFontSizes.xxl,    // 24px
  fontWeight: FontWeight.bold,   // 700
  height: 1.3,
)

// H3 - Subtítulos
TextStyle(
  fontSize: AppFontSizes.xl,     // 20px
  fontWeight: FontWeight.w600,   // 600
  height: 1.4,
)

// H4 - Títulos pequeños
TextStyle(
  fontSize: AppFontSizes.lg,     // 18px
  fontWeight: FontWeight.w600,   // 600
  height: 1.4,
)
```

#### Texto de Cuerpo (Body)

```dart
// Body Large - Texto principal destacado
TextStyle(
  fontSize: AppFontSizes.lg,     // 18px
  fontWeight: FontWeight.normal, // 400
  height: 1.6,
)

// Body Medium - Texto principal (base)
TextStyle(
  fontSize: AppFontSizes.md,     // 16px
  fontWeight: FontWeight.normal, // 400
  height: 1.5,
)

// Body Small - Texto secundario
TextStyle(
  fontSize: AppFontSizes.sm,     // 14px
  fontWeight: FontWeight.normal, // 400
  height: 1.5,
)
```

#### Etiquetas y Captions

```dart
// Caption - Metadatos, timestamps
TextStyle(
  fontSize: AppFontSizes.xs,     // 12px
  fontWeight: FontWeight.normal, // 400
  height: 1.4,
  color: AppColors.grey500,
)

// Label - Etiquetas de formularios
TextStyle(
  fontSize: AppFontSizes.sm,     // 14px
  fontWeight: FontWeight.w500,   // 500
  height: 1.4,
)

// Button Text - Texto de botones
TextStyle(
  fontSize: AppFontSizes.md,     // 16px
  fontWeight: FontWeight.w600,   // 600
  letterSpacing: 0.5,
)
```

### Pesos de Fuente

```dart
FontWeight.w400  // Normal/Regular - Texto de cuerpo
FontWeight.w500  // Medium - Etiquetas, texto destacado
FontWeight.w600  // Semi-bold - Subtítulos, botones
FontWeight.w700  // Bold - Títulos principales
```

---

## 📏 Espaciado

Sistema de espaciado consistente basado en múltiplos de 4px:

```dart
AppSpacing.xs = 4.0    // Espaciado extra pequeño
AppSpacing.sm = 8.0    // Espaciado pequeño
AppSpacing.md = 16.0   // Espaciado medio (base)
AppSpacing.lg = 24.0   // Espaciado grande
AppSpacing.xl = 32.0   // Espaciado extra grande
AppSpacing.xxl = 48.0  // Espaciado doble extra grande
```

### Guía de Uso

| Tamaño | Uso Recomendado |
|--------|-----------------|
| `xs` (4px) | Espaciado interno mínimo, gaps en iconos |
| `sm` (8px) | Separación entre elementos relacionados, padding en chips |
| `md` (16px) | Padding estándar de cards, separación entre secciones |
| `lg` (24px) | Márgenes de sección, padding de pantallas |
| `xl` (32px) | Separación mayor entre secciones |
| `xxl` (48px) | Separación de bloques principales |

### Ejemplos de Aplicación

```dart
// Card interno
padding: EdgeInsets.all(AppSpacing.md)  // 16px

// Entre elementos en lista
SizedBox(height: AppSpacing.sm)  // 8px

// Márgenes de pantalla
padding: EdgeInsets.all(AppSpacing.lg)  // 24px

// Separación de secciones principales
SizedBox(height: AppSpacing.xl)  // 32px
```

---

## 📱 Grid System y Responsive

### Breakpoints

Sistema responsive de 3 niveles:

```dart
ViewConstants.tabletBreakpoint = 600    // Transición móvil → tablet
ViewConstants.desktopBreakpoint = 1200  // Transición tablet → desktop
```

### Grid de Columnas

```dart
// Móvil (< 600px)
ViewConstants.mobileCrossAxisCount = 2    // 2 columnas

// Tablet (600px - 1200px)
ViewConstants.tabletCrossAxisCount = 3    // 3 columnas

// Desktop (> 1200px)
ViewConstants.desktopCrossAxisCount = 4   // 4 columnas
```

### Layout Responsivo

```dart
// Ejemplo de implementación
int getCrossAxisCount(double width) {
  if (width >= ViewConstants.desktopBreakpoint) {
    return ViewConstants.desktopCrossAxisCount;  // 4
  } else if (width >= ViewConstants.tabletBreakpoint) {
    return ViewConstants.tabletCrossAxisCount;   // 3
  }
  return ViewConstants.mobileCrossAxisCount;     // 2
}
```

### Densidades de Vista

Sistema de Progressive Disclosure con dos densidades:

```dart
enum ProjectViewDensity {
  compact,      // Vista compacta - más información en menos espacio
  comfortable,  // Vista cómoda - más espaciado y legibilidad
}
```

#### Vista Compacta

```dart
ViewConstants.compactCardMinHeight = 140
ViewConstants.compactPadding = 12
ViewConstants.compactSpacing = 8
ViewConstants.compactHeaderHeight = 32
ViewConstants.compactTitleFontSize = 15
```

**Uso**: Cuando el usuario necesita ver muchos elementos a la vez, escaneo rápido.

#### Vista Cómoda

```dart
ViewConstants.comfortableCardMinHeight = 180
ViewConstants.comfortablePadding = 16
ViewConstants.comfortableSpacing = 12
ViewConstants.comfortableHeaderHeight = 36
ViewConstants.comfortableTitleFontSize = 16
```

**Uso**: Cuando el usuario trabaja con pocos elementos, requiere más detalle.

---

## 🔲 Bordes y Elevaciones

### Border Radius

```dart
AppBorderRadius.sm = 4.0     // Bordes sutiles
AppBorderRadius.md = 8.0     // Botones, inputs (estándar)
AppBorderRadius.lg = 12.0    // Cards, modales
AppBorderRadius.xl = 16.0    // Elementos grandes
AppBorderRadius.full = 999.0 // Completamente redondeado (pills, avatares)
```

### Guía de Uso de Bordes

| Elemento | Border Radius |
|----------|---------------|
| Botones | `md` (8px) |
| Inputs de formulario | `md` (8px) |
| Cards | `lg` (12px) |
| Modales/Bottom sheets | `lg` (12px) |
| Chips/Pills | `full` (999px) |
| Avatares | `full` (999px) |
| Status badges | `lg` (12px) |

### Elevaciones (Shadows)

```dart
// Card elevation
elevation: 2  // Sombra sutil para cards

// Modal elevation
elevation: 8  // Sombra más pronunciada para modales

// Floating Action Button
elevation: 6  // Sombra media para botones flotantes
```

**Principio**: Usar elevaciones consistentes para establecer jerarquía visual.

---

## 🧩 Componentes

Ver [COMPONENTS.md](./COMPONENTS.md) para documentación detallada de todos los componentes.

### Componentes Disponibles

#### Botones
- `PrimaryButton` - Acciones principales
- `SecondaryButton` - Acciones secundarias
- `TextButton` - Acciones terciarias
- `OutlinedButton` - Acciones alternativas

#### Cards
- `CustomCard` - Card base personalizable
- Variantes con `onTap` para elementos interactivos

#### Inputs
- `ValidatedTextField` - Input con validación
- `ValidatedDropdown` - Dropdown con validación
- `ValidatedCheckbox` - Checkbox con validación

#### Feedback
- `LoadingWidget` - Estado de carga
- `ErrorWidget` - Estado de error con retry
- `EmptyWidget` - Estado vacío

#### Status
- `StatusBadgeWidget` - Badge de estado de tarea
- `PriorityBadgeWidget` - Badge de prioridad

---

## 🎯 Tokens de Diseño

### Animaciones

```dart
// Duraciones
ViewConstants.hoverTransition = 200ms       // Hover effects
ViewConstants.fadeTransition = 150ms        // Fade in/out
ViewConstants.collapseTransition = 300ms    // Secciones colapsables
ViewConstants.densityTransition = 250ms     // Cambio de densidad

// Curves
ViewConstants.smoothCurve = Curves.easeInOutCubic   // Animaciones principales
ViewConstants.collapseCurve = Curves.easeInOutQuart // Colapsos
ViewConstants.hoverCurve = Curves.easeOut           // Hover
```

### Iconos

```dart
// Tamaños de iconos
ViewConstants.smallIconSize = 14    // Iconos en badges
ViewConstants.mediumIconSize = 18   // Iconos en botones
ViewConstants.largeIconSize = 24    // Iconos destacados
```

### Opacidades

```dart
// Overlays
ViewConstants.hoverOverlayOpacity = 0.03        // Tema claro
ViewConstants.hoverOverlayOpacityDark = 0.05    // Tema oscuro

// Estados deshabilitados
opacity: 0.5  // Elementos deshabilitados

// Texto secundario
opacity: 0.6  // Texto de menor importancia
```

---

## 📐 Principios de Diseño

### 1. Consistencia Visual

- Usar los colores y espaciados definidos en este sistema
- Mantener border radius y elevaciones consistentes
- Seguir la jerarquía tipográfica establecida

### 2. Accesibilidad

- **Contraste**: Todos los textos cumplen WCAG AA mínimo
- **Tamaño**: Texto base mínimo de 16px para legibilidad
- **Touch targets**: Mínimo 44x44px para elementos interactivos
- **Feedback**: Siempre proporcionar retroalimentación visual de acciones

### 3. Progressive Disclosure

- Mostrar información esencial primero
- Revelar detalles bajo demanda (hover, click, expand)
- Usar densidades de vista para control del usuario

### 4. Responsive Design

- Mobile-first approach
- Adaptación fluida entre breakpoints
- Grid system flexible basado en contenido

### 5. Performance

- Animaciones suaves (60fps)
- Transiciones rápidas (<300ms)
- Feedback inmediato de interacciones

---

## 🔗 Referencias

- [Material Design 3](https://m3.material.io/)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Flutter Theme Documentation](https://docs.flutter.dev/cookbook/design/themes)

---

## 📚 Documentación Relacionada

- [COMPONENTS.md](./COMPONENTS.md) - Biblioteca de componentes
- [ARCHITECTURE.md](./ARCHITECTURE.md) - Arquitectura de la aplicación
- [GETTING_STARTED.md](./GETTING_STARTED.md) - Guía de inicio

---

**Última actualización**: Octubre 2025  
**Versión**: 1.0.0  
**Mantenido por**: Equipo Creapolis
