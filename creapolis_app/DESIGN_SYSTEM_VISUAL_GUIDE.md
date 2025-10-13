# 📱 Creapolis Design System - Guía Visual

Bienvenido al Design System de Creapolis. Esta guía proporciona una visualización rápida de los elementos clave del sistema de diseño.

---

## 🎨 Paleta de Colores

### Colores Primarios

| Color | Hex | Uso |
|-------|-----|-----|
| ![#3B82F6](https://via.placeholder.com/20/3B82F6/000000?text=+) **Primary** | `#3B82F6` | Acciones principales, botones, enlaces |
| ![#8B5CF6](https://via.placeholder.com/20/8B5CF6/000000?text=+) **Secondary** | `#8B5CF6` | Acciones secundarias, elementos de soporte |

### Colores Semánticos

| Color | Hex | Uso |
|-------|-----|-----|
| ![#10B981](https://via.placeholder.com/20/10B981/000000?text=+) **Success** | `#10B981` | Operaciones exitosas |
| ![#F59E0B](https://via.placeholder.com/20/F59E0B/000000?text=+) **Warning** | `#F59E0B` | Advertencias |
| ![#EF4444](https://via.placeholder.com/20/EF4444/000000?text=+) **Error** | `#EF4444` | Errores |
| ![#3B82F6](https://via.placeholder.com/20/3B82F6/000000?text=+) **Info** | `#3B82F6` | Información |

### Escala de Grises

| Color | Hex | Uso |
|-------|-----|-----|
| ![#FFFFFF](https://via.placeholder.com/20/FFFFFF/000000?text=+) **White** | `#FFFFFF` | Fondos, superficies |
| ![#F9FAFB](https://via.placeholder.com/20/F9FAFB/000000?text=+) **Grey 50** | `#F9FAFB` | Fondos muy claros |
| ![#E5E7EB](https://via.placeholder.com/20/E5E7EB/000000?text=+) **Grey 200** | `#E5E7EB` | Bordes |
| ![#6B7280](https://via.placeholder.com/20/6B7280/000000?text=+) **Grey 500** | `#6B7280` | Texto secundario |
| ![#374151](https://via.placeholder.com/20/374151/000000?text=+) **Grey 700** | `#374151` | Texto destacado |
| ![#111827](https://via.placeholder.com/20/111827/000000?text=+) **Grey 900** | `#111827` | Texto principal |

---

## 📝 Tipografía

### Escala de Tamaños

```
32px  ━━━━━  XXXL - Títulos principales
24px  ━━━━━  XXL - Títulos de página
20px  ━━━━━  XL - Títulos de sección
18px  ━━━━━  LG - Subtítulos
16px  ━━━━━  MD - Texto base (body)
14px  ━━━━━  SM - Texto secundario
12px  ━━━━━  XS - Captions, labels
```

### Pesos de Fuente

- **400** (Regular) - Texto de cuerpo
- **500** (Medium) - Etiquetas, texto destacado
- **600** (Semi-bold) - Subtítulos, botones
- **700** (Bold) - Títulos principales

---

## 📏 Espaciado

Sistema basado en múltiplos de 4px:

```
4px   │  XS  - Espaciado mínimo
8px   ││ SM  - Elementos relacionados
16px  ││││ MD  - Padding estándar
24px  ││││││ LG  - Márgenes de sección
32px  ││││││││ XL  - Separación grande
48px  ││││││││││││ XXL - Bloques principales
```

---

## 🔲 Bordes

| Radio | Uso |
|-------|-----|
| **4px** (sm) | Bordes sutiles |
| **8px** (md) | Botones, inputs |
| **12px** (lg) | Cards, modales |
| **16px** (xl) | Elementos grandes |
| **999px** (full) | Pills, avatares |

---

## 📱 Responsive Breakpoints

```
Mobile      0px ─────────────────────┤
Tablet    600px                      ├────────────────┤
Desktop  1200px                                       ├──────────→
```

### Grid Columns

- **Mobile** (< 600px): 2 columnas
- **Tablet** (600-1200px): 3 columnas
- **Desktop** (> 1200px): 4 columnas

---

## 🧩 Componentes Principales

### Botones

```dart
PrimaryButton        ┌─────────────────┐
(Acción principal)   │  Guardar Cambios │
                     └─────────────────┘

SecondaryButton      ┌─────────────────┐
(Acción secundaria)  │     Cancelar     │
                     └─────────────────┘
```

### Cards

```dart
CustomCard
┌──────────────────────────────┐
│  Título del Card              │
│  ─────────────────────       │
│  Contenido del card aquí...  │
│  Con padding de 16px         │
└──────────────────────────────┘
```

### Inputs

```dart
ValidatedTextField
┌──────────────────────────────┐
│ 📧 Email                      │
│ ┌──────────────────────────┐ │
│ │ usuario@ejemplo.com   ✓  │ │
│ └──────────────────────────┘ │
└──────────────────────────────┘
```

### Estados

```dart
LoadingWidget        ErrorWidget         EmptyWidget
     ⏳                  ❌                  📭
  Cargando...      Error: mensaje       No hay datos
                   [Reintentar]
```

### Badges

```dart
StatusBadge          PriorityBadge
┌──────────────┐    ┌──────────────┐
│ ▶ In Progress│    │ ⬆ High       │
└──────────────┘    └──────────────┘
```

---

## 🎯 Principios de Diseño

### 1. **Consistencia Visual**
Usar los tokens de diseño definidos (colores, espaciado, tipografía)

### 2. **Accesibilidad**
- Contraste WCAG AA mínimo
- Touch targets de 44x44px mínimo
- Texto base de 16px

### 3. **Progressive Disclosure**
- Mostrar información esencial primero
- Revelar detalles bajo demanda

### 4. **Responsive Design**
- Mobile-first approach
- Adaptación fluida entre breakpoints

### 5. **Performance**
- Animaciones a 60fps
- Transiciones < 300ms
- Feedback inmediato

---

## 📚 Documentación Completa

Para información detallada, consulta:

### Documentos Principales

- **[DESIGN_SYSTEM.md](./DESIGN_SYSTEM.md)**
  - Paleta de colores completa con valores hex
  - Sistema tipográfico detallado
  - Espaciado y grid system
  - Bordes, elevaciones y tokens de diseño
  - Principios y guías de uso

- **[COMPONENTS.md](./COMPONENTS.md)**
  - Todos los componentes con propiedades
  - Ejemplos de código completos
  - Cuándo usar cada componente
  - Guías de uso y mejores prácticas
  - Composición de componentes

### Guías Técnicas

- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - Arquitectura del proyecto
- **[GETTING_STARTED.md](./GETTING_STARTED.md)** - Guía de inicio
- **[FLUTTER_ROADMAP.md](./FLUTTER_ROADMAP.md)** - Roadmap de desarrollo

---

## 🚀 Inicio Rápido

### Usar un Color

```dart
import 'package:creapolis_app/core/theme/app_theme.dart';

Container(
  color: AppColors.primary,
  child: Text(
    'Texto',
    style: TextStyle(color: AppColors.white),
  ),
)
```

### Usar Espaciado

```dart
import 'package:creapolis_app/core/theme/app_dimensions.dart';

Padding(
  padding: EdgeInsets.all(AppSpacing.md),  // 16px
  child: Column(
    children: [
      Text('Item 1'),
      SizedBox(height: AppSpacing.sm),  // 8px
      Text('Item 2'),
    ],
  ),
)
```

### Usar un Componente

```dart
import 'package:creapolis_app/presentation/shared/widgets/primary_button.dart';

PrimaryButton(
  text: 'Guardar',
  icon: Icons.save,
  onPressed: () => _save(),
  isLoading: _isSaving,
)
```

### Usar Tipografía

```dart
import 'package:creapolis_app/core/theme/app_dimensions.dart';

Text(
  'Título',
  style: TextStyle(
    fontSize: AppFontSizes.xxl,  // 24px
    fontWeight: FontWeight.bold,
  ),
)
```

---

## ✅ Checklist de Diseño

Al crear una nueva pantalla o componente, verifica:

- [ ] Usar colores de `AppColors`, no hardcoded
- [ ] Seguir la escala de espaciado `AppSpacing`
- [ ] Usar tamaños de fuente de `AppFontSizes`
- [ ] Aplicar border radius consistente `AppBorderRadius`
- [ ] Componentes reutilizables cuando sea posible
- [ ] Validación de formularios con `ValidatedTextField`
- [ ] Estados de loading, error y empty implementados
- [ ] Responsive design (considerar mobile, tablet, desktop)
- [ ] Touch targets mínimo 44x44px
- [ ] Contraste de texto cumple WCAG AA
- [ ] Animaciones suaves (usar curves y duraciones del sistema)
- [ ] Feedback visual para todas las interacciones

---

## 🎨 Ejemplos Visuales

### Pantalla de Login

```
┌────────────────────────────────┐
│                                │
│     🏢 Creapolis              │  <- Logo + Título (32px)
│                                │
│  ┌──────────────────────────┐ │
│  │ 📧 Email                  │ │  <- ValidatedTextField
│  │ usuario@ejemplo.com    ✓ │ │
│  └──────────────────────────┘ │
│                                │
│  ┌──────────────────────────┐ │
│  │ 🔒 Contraseña            │ │  <- ValidatedTextField
│  │ ••••••••••             ✓ │ │
│  └──────────────────────────┘ │
│                                │
│  ┌──────────────────────────┐ │
│  │   Iniciar Sesión    →    │ │  <- PrimaryButton
│  └──────────────────────────┘ │
│                                │
│     ¿Olvidaste tu contraseña? │  <- TextButton
│                                │
└────────────────────────────────┘
```

### Card de Proyecto

```
┌────────────────────────────────────┐
│  Proyecto Alpha          ▶ Active │  <- Título + StatusBadge
│  ──────────────────────────────   │
│  Desarrollo de nueva función      │  <- Descripción
│  para el módulo de reportes       │
│                                    │
│  👥 5 miembros  📅 15 Oct 2025   │  <- Metadata
└────────────────────────────────────┘
```

---

## 📞 Soporte

¿Preguntas sobre el Design System?

1. Consulta la documentación completa en [DESIGN_SYSTEM.md](./DESIGN_SYSTEM.md)
2. Revisa ejemplos de componentes en [COMPONENTS.md](./COMPONENTS.md)
3. Contacta al equipo de diseño

---

**Versión**: 1.0.0  
**Última actualización**: Octubre 2025  
**Mantenido por**: Equipo Creapolis
