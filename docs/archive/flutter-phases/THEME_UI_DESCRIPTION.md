# Theme Customization UI - Visual Description

## Settings Screen - Appearance Section

### Layout Overview
```
╔════════════════════════════════════╗
║ ← Configuración                    ║
╠════════════════════════════════════╣
║                                    ║
║  🎨 APARIENCIA                     ║
║                                    ║
║  ┌──────────────────────────────┐ ║
║  │ 🌗 Tema                      │ ║
║  │                              │ ║
║  │  ┌─────────────────────────┐│ ║
║  │  │ ☀️ Claro              ✓ ││ ║
║  │  └─────────────────────────┘│ ║
║  │                              │ ║
║  │  ┌─────────────────────────┐│ ║
║  │  │ 🌙 Oscuro                ││ ║
║  │  └─────────────────────────┘│ ║
║  │                              │ ║
║  │  ┌─────────────────────────┐│ ║
║  │  │ 🔄 Seguir sistema        ││ ║
║  │  └─────────────────────────┘│ ║
║  └──────────────────────────────┘ ║
║                                    ║
║  ┌──────────────────────────────┐ ║
║  │ 📱 Tipo de navegación        │ ║
║  │                              │ ║
║  │ Selecciona cómo prefieres    │ ║
║  │ navegar por la aplicación    │ ║
║  │                              │ ║
║  │  ┌─────────────────────────┐│ ║
║  │  │ 📋 Barra lateral         ││ ║
║  │  │ Menú de navegación en    ││ ║
║  │  │ el lateral               ││ ║
║  │  └─────────────────────────┘│ ║
║  │                              │ ║
║  │  ┌─────────────────────────┐│ ║
║  │  │ 📱 Navegación inferior ✓ ││ ║
║  │  │ Menú de navegación en    ││ ║
║  │  │ la parte inferior        ││ ║
║  │  └─────────────────────────┘│ ║
║  └──────────────────────────────┘ ║
║                                    ║
║  ─────────────────────────────────║
║                                    ║
║  🔗 INTEGRACIONES                  ║
║  ...                               ║
╚════════════════════════════════════╝
```

## Light Mode UI

### Colors Applied
- **Background**: #F9FAFB (grey-50)
- **Surface**: #FFFFFF (white)
- **Primary**: #3B82F6 (blue)
- **Text**: #111827 (grey-900)
- **Border**: #E5E7EB (grey-200)

### Visual Style
- Clean, bright appearance
- High contrast text
- Subtle shadows on cards
- Blue accents for selected items
- Light grey borders

### Card Appearance
```
┌────────────────────────┐
│ 🌗 Tema                │  ← Blue icon
│                        │
│ ┌────────────────────┐ │
│ │ ☀️ Claro         ✓ │ │  ← Selected (blue border, light blue background)
│ └────────────────────┘ │
│                        │
│ ┌────────────────────┐ │
│ │ 🌙 Oscuro          │ │  ← Not selected (grey border, transparent background)
│ └────────────────────┘ │
└────────────────────────┘
```

## Dark Mode UI

### Colors Applied
- **Background**: #111827 (grey-900)
- **Surface**: #1F2937 (grey-800)
- **Primary**: #60A5FA (light-blue)
- **Text**: #F3F4F6 (grey-100)
- **Border**: #374151 (grey-700)

### Visual Style
- Dark, comfortable for eyes
- Reduced brightness
- Lighter text on dark background
- Lighter blue accents for better visibility
- Darker grey borders

### Card Appearance
```
┌────────────────────────┐  ← Dark grey card background
│ 🌗 Tema                │  ← Light blue icon
│                        │
│ ┌────────────────────┐ │
│ │ ☀️ Claro           │ │  ← Not selected (dark grey border)
│ └────────────────────┘ │
│                        │
│ ┌────────────────────┐ │
│ │ 🌙 Oscuro        ✓ │ │  ← Selected (light blue border, blue tint background)
│ └────────────────────┘ │
└────────────────────────┘
```

## Interactive States

### Theme Option - Not Selected
```
┌──────────────────────────────┐
│ 🌙  Oscuro                   │  ← Grey outline, transparent background
└──────────────────────────────┘
```

### Theme Option - Selected
```
┌══════════════════════════════┐
│ 🌙  Oscuro                 ✓ │  ← Blue outline (2px), light blue tint background
└══════════════════════════════┘
```

### Theme Option - Hover/Press
```
┌──────────────────────────────┐
│ 🌙  Oscuro                   │  ← Ripple effect, slight elevation
└──────────────────────────────┘
```

## Layout Option Cards

### Not Selected
```
┌──────────────────────────────┐
│ 📋  Barra lateral            │
│     Menú de navegación en    │
│     el lateral               │
└──────────────────────────────┘
```

### Selected
```
┌══════════════════════════════┐
│ 📱  Navegación inferior    ✓ │
│     Menú de navegación en    │
│     la parte inferior        │
└══════════════════════════════┘
```

## Responsive Behavior

### Portrait (Mobile)
- Full width cards with 16px horizontal margin
- Stacked vertically
- Touch-optimized spacing (minimum 48dp tap targets)

### Landscape (Mobile)
- Same layout as portrait
- Slightly more vertical scrolling

### Tablet
- Cards can be wider but centered
- More breathing room with increased margins
- Better utilization of horizontal space

## Animations

### Theme Switch Transition
```
Light Theme → Dark Theme
  ↓
[Fade Out] (100ms)
  ↓
[Theme Change]
  ↓
[Fade In] (100ms)
  ↓
Dark Theme
```

Duration: ~200ms total
Curve: Ease-in-out

### Selection Animation
```
Tap on option
  ↓
[Ripple Effect] (Material ripple)
  ↓
[Border Color Change] (Blue highlight)
  ↓
[Background Tint] (Light blue background)
  ↓
[Check Icon Appear] (Scale up from 0 to 1)
```

Duration: ~300ms total
Curve: Ease-out

## Accessibility

### Screen Reader Announcements
- "Tema: Claro, seleccionado"
- "Tema: Oscuro, no seleccionado"
- "Tema: Seguir sistema, no seleccionado"
- "Tipo de navegación: Barra lateral"
- "Tipo de navegación: Navegación inferior, seleccionado"

### Touch Targets
- Minimum 48dp × 48dp for all interactive elements
- Adequate spacing between options (8dp)
- Clear visual feedback on interaction

### High Contrast
- Both themes meet WCAG AA standards
- 4.5:1 contrast ratio for text
- 3:1 contrast ratio for UI components

## Design Tokens

### Spacing
- Section padding: 16dp
- Card margin: 16dp horizontal, 8dp vertical
- Card padding: 16dp
- Option spacing: 8dp between items
- Icon-text spacing: 12dp

### Typography
- Section title: titleLarge, bold
- Card title: titleMedium, bold
- Option text: bodyLarge
- Subtitle text: bodySmall

### Borders
- Option border radius: 8dp
- Card border radius: 12dp
- Selected border width: 2dp
- Unselected border width: 1dp

### Elevation
- Cards: elevation 2
- Selected options: subtle elevation on press

## Integration Points

### AppBar
- Theme-aware colors
- Title: "Configuración"
- Back button (automatic from navigation)

### Navigation
- Accessible from main menu
- Can be accessed from profile settings
- Deep link: `/settings/appearance`

### Persistence Indicator
- No explicit indicator needed
- Changes save automatically
- No "Save" button required
- Instant feedback through UI update

---

**Note**: Since this is a visual description, actual implementation may vary slightly based on Material Design 3 guidelines and Flutter's rendering engine. The described UI follows Material Design principles and Flutter best practices.
