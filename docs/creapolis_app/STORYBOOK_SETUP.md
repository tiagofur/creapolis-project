# 📚 Storybook Setup Guide para Creapolis

Guía para configurar Storybook en el proyecto Flutter de Creapolis para documentación visual e interactiva de componentes.

> ⚠️ **Estado**: Esta es una guía de referencia para futura implementación. El proyecto actualmente cuenta con documentación completa en Markdown ([COMPONENTS.md](./COMPONENTS.md)).

---

## 🎯 ¿Qué es Storybook?

Storybook es una herramienta de desarrollo para construir y documentar componentes de UI de forma aislada. Permite:

- 📖 Documentar componentes visualmente
- 🧪 Probar componentes en diferentes estados
- 🎨 Ver todos los componentes en un solo lugar
- 🔄 Iteración rápida sin ejecutar toda la app
- 👥 Colaboración entre diseño y desarrollo

---

## 🚀 Alternativas para Flutter

### Opción 1: Widgetbook (Recomendado)

Widgetbook es la alternativa más popular de Storybook para Flutter.

#### Instalación

```yaml
# pubspec.yaml
dev_dependencies:
  widgetbook: ^3.7.0
  widgetbook_annotation: ^3.1.0

dependencies:
  widgetbook_core: ^3.7.0
```

#### Setup Básico

1. **Crear archivo de Widgetbook**

```dart
// lib/widgetbook.dart
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import 'core/theme/app_theme.dart';
import 'presentation/shared/widgets/primary_button.dart';
import 'presentation/shared/widgets/secondary_button.dart';
import 'presentation/shared/widgets/custom_card.dart';

void main() {
  runApp(const WidgetbookApp());
}

class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: [
        WidgetbookCategory(
          name: '🎨 Design System',
          children: [
            _buildButtonsFolder(),
            _buildCardsFolder(),
            _buildInputsFolder(),
            _buildFeedbackFolder(),
          ],
        ),
      ],
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(
              name: 'Light',
              data: AppTheme.lightTheme,
            ),
            WidgetbookTheme(
              name: 'Dark',
              data: AppTheme.darkTheme,
            ),
          ],
        ),
        DeviceFrameAddon(
          devices: [
            Devices.ios.iPhone13,
            Devices.android.samsungGalaxyS20,
            Devices.android.tablet,
          ],
        ),
        TextScaleAddon(
          scales: [1.0, 1.5, 2.0],
        ),
      ],
    );
  }
}
```

2. **Documentar Botones**

```dart
WidgetbookFolder _buildButtonsFolder() {
  return WidgetbookFolder(
    name: 'Botones',
    children: [
      // Primary Button
      WidgetbookComponent(
        name: 'PrimaryButton',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: (context) => Center(
              child: PrimaryButton(
                text: context.knobs.text(
                  label: 'Texto',
                  initialValue: 'Guardar',
                ),
                onPressed: () {},
              ),
            ),
          ),
          WidgetbookUseCase(
            name: 'Con Icono',
            builder: (context) => Center(
              child: PrimaryButton(
                text: 'Iniciar Sesión',
                icon: Icons.login,
                onPressed: () {},
              ),
            ),
          ),
          WidgetbookUseCase(
            name: 'Loading',
            builder: (context) => Center(
              child: PrimaryButton(
                text: 'Guardando...',
                isLoading: true,
                onPressed: null,
              ),
            ),
          ),
          WidgetbookUseCase(
            name: 'Full Width',
            builder: (context) => Padding(
              padding: const EdgeInsets.all(16),
              child: PrimaryButton(
                text: 'Continuar',
                isFullWidth: true,
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      
      // Secondary Button
      WidgetbookComponent(
        name: 'SecondaryButton',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: (context) => Center(
              child: SecondaryButton(
                text: context.knobs.text(
                  label: 'Texto',
                  initialValue: 'Cancelar',
                ),
                onPressed: () {},
              ),
            ),
          ),
          WidgetbookUseCase(
            name: 'Con Icono',
            builder: (context) => Center(
              child: SecondaryButton(
                text: 'Exportar',
                icon: Icons.download,
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
```

3. **Documentar Cards**

```dart
WidgetbookFolder _buildCardsFolder() {
  return WidgetbookFolder(
    name: 'Cards',
    children: [
      WidgetbookComponent(
        name: 'CustomCard',
        useCases: [
          WidgetbookUseCase(
            name: 'Simple',
            builder: (context) => Padding(
              padding: const EdgeInsets.all(16),
              child: CustomCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Título del Card',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Contenido del card con información relevante.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
          WidgetbookUseCase(
            name: 'Clickeable',
            builder: (context) => Padding(
              padding: const EdgeInsets.all(16),
              child: CustomCard(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Card clickeado')),
                  );
                },
                child: ListTile(
                  leading: const Icon(Icons.folder),
                  title: const Text('Proyecto Alpha'),
                  subtitle: const Text('3 tareas pendientes'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
```

4. **Ejecutar Widgetbook**

```bash
# Crear un nuevo target en run configurations
flutter run -t lib/widgetbook.dart

# O ejecutar directamente
flutter run lib/widgetbook.dart
```

---

### Opción 2: Dashbook

Alternativa más ligera que Widgetbook.

```yaml
dev_dependencies:
  dashbook: ^0.1.5
```

```dart
import 'package:dashbook/dashbook.dart';
import 'package:flutter/material.dart';

void main() {
  final dashbook = Dashbook.dualTheme(
    light: ThemeData.light(),
    dark: ThemeData.dark(),
  );

  dashbook
    .storiesOf('Buttons')
    .add('Primary', (context) {
      return PrimaryButton(
        text: context.textProperty('text', 'Guardar'),
        onPressed: () {},
      );
    })
    .add('Secondary', (context) {
      return SecondaryButton(
        text: context.textProperty('text', 'Cancelar'),
        onPressed: () {},
      );
    });

  runApp(dashbook);
}
```

---

### Opción 3: Flutter Gallery (Showcase App)

Crear una app de demostración propia.

```dart
// lib/gallery/main.dart
import 'package:flutter/material.dart';

void main() => runApp(const ComponentGalleryApp());

class ComponentGalleryApp extends StatelessWidget {
  const ComponentGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Creapolis Component Gallery',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const GalleryHome(),
    );
  }
}

class GalleryHome extends StatelessWidget {
  const GalleryHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Component Gallery')),
      body: ListView(
        children: [
          _CategoryHeader(title: 'Botones'),
          _ComponentTile(
            title: 'Primary Button',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ButtonsGallery(),
              ),
            ),
          ),
          _CategoryHeader(title: 'Cards'),
          _ComponentTile(
            title: 'Custom Card',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CardsGallery(),
              ),
            ),
          ),
          // ... más componentes
        ],
      ),
    );
  }
}
```

---

## 📁 Estructura Recomendada

```
lib/
├── widgetbook/                   # Si usas Widgetbook
│   ├── main.dart                 # Entry point de Widgetbook
│   ├── folders/
│   │   ├── buttons_folder.dart
│   │   ├── cards_folder.dart
│   │   ├── inputs_folder.dart
│   │   └── feedback_folder.dart
│   └── addons/
│       └── custom_addons.dart
│
├── gallery/                      # Si creas tu propia Gallery
│   ├── main.dart
│   ├── home.dart
│   └── screens/
│       ├── buttons_gallery.dart
│       ├── cards_gallery.dart
│       └── inputs_gallery.dart
│
└── presentation/
    └── shared/
        └── widgets/              # Componentes reales
```

---

## 🎨 Documentar Design Tokens

### Colores

```dart
WidgetbookFolder _buildDesignTokensFolder() {
  return WidgetbookFolder(
    name: 'Design Tokens',
    children: [
      WidgetbookComponent(
        name: 'Colores',
        useCases: [
          WidgetbookUseCase(
            name: 'Primarios',
            builder: (context) => ColorPalette(
              colors: {
                'Primary': AppColors.primary,
                'Primary Dark': AppColors.primaryDark,
                'Primary Light': AppColors.primaryLight,
                'Secondary': AppColors.secondary,
              },
            ),
          ),
          WidgetbookUseCase(
            name: 'Semánticos',
            builder: (context) => ColorPalette(
              colors: {
                'Success': AppColors.success,
                'Warning': AppColors.warning,
                'Error': AppColors.error,
                'Info': AppColors.info,
              },
            ),
          ),
        ],
      ),
    ],
  );
}

class ColorPalette extends StatelessWidget {
  final Map<String, Color> colors;

  const ColorPalette({super.key, required this.colors});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: colors.length,
      itemBuilder: (context, index) {
        final entry = colors.entries.elementAt(index);
        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: entry.value,
              border: Border.all(color: Colors.grey),
            ),
          ),
          title: Text(entry.key),
          subtitle: Text(_colorToHex(entry.value)),
        );
      },
    );
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}
```

---

## 🔧 Scripts Útiles

Añadir a `package.json` o crear scripts de shell:

```bash
#!/bin/bash
# run-widgetbook.sh

echo "🚀 Ejecutando Widgetbook..."
flutter run -t lib/widgetbook/main.dart -d chrome

# Para web
# flutter run -t lib/widgetbook/main.dart -d web-server --web-port=8080

# Para compilar para producción
# flutter build web -t lib/widgetbook/main.dart -o build/widgetbook
```

---

## 📊 Ventajas y Desventajas

### Widgetbook

**Pros:**
- ✅ Diseñado específicamente para Flutter
- ✅ Soporta knobs (controles interactivos)
- ✅ Múltiples dispositivos y temas
- ✅ Generación automática con anotaciones
- ✅ Documentación integrada

**Cons:**
- ❌ Curva de aprendizaje inicial
- ❌ Dependencia adicional

### Dashbook

**Pros:**
- ✅ Más ligero que Widgetbook
- ✅ Fácil de configurar
- ✅ Suficiente para proyectos pequeños

**Cons:**
- ❌ Menos features que Widgetbook
- ❌ Menos mantenido

### Gallery Custom

**Pros:**
- ✅ Control total
- ✅ Sin dependencias extra
- ✅ Puede ser parte de la app

**Cons:**
- ❌ Más trabajo manual
- ❌ Menos features out-of-the-box

---

## 🎯 Recomendación

Para Creapolis, recomendamos:

### Corto Plazo (Actual)
Mantener la **documentación en Markdown** ([COMPONENTS.md](./COMPONENTS.md)):
- ✅ Ya está implementada
- ✅ Fácil de mantener
- ✅ No requiere ejecución
- ✅ Versionable en Git

### Mediano Plazo
Si el equipo crece o se necesita documentación visual interactiva, implementar **Widgetbook**:
- Mejor para demostraciones a stakeholders
- Útil para testing visual
- Facilita colaboración diseño-desarrollo

### Implementación Gradual

1. **Fase 1** (Actual) ✅
   - Documentación en Markdown completa

2. **Fase 2** (Futuro)
   - Agregar Widgetbook para componentes principales
   - Mantener Markdown como referencia rápida

3. **Fase 3** (Si es necesario)
   - Automatización de screenshots
   - CI/CD para publicar Widgetbook
   - Integración con diseño en Figma

---

## 📚 Recursos

### Widgetbook
- [Documentación oficial](https://docs.widgetbook.io/)
- [GitHub](https://github.com/widgetbook/widgetbook)
- [Ejemplos](https://github.com/widgetbook/widgetbook/tree/main/examples)

### Dashbook
- [GitHub](https://github.com/erickzanardo/dashbook)
- [Pub.dev](https://pub.dev/packages/dashbook)

### Alternativas
- [Flutter Catalog](https://github.com/X-Wei/flutter_catalog)
- [Flutter Gallery (oficial)](https://github.com/flutter/gallery)

---

## ✅ Checklist de Implementación

Si decides implementar Widgetbook:

- [ ] Añadir dependencias al `pubspec.yaml`
- [ ] Crear estructura de carpetas `widgetbook/`
- [ ] Crear archivo principal `widgetbook/main.dart`
- [ ] Documentar componentes básicos (botones, cards)
- [ ] Añadir addons (temas, dispositivos, text scale)
- [ ] Configurar scripts de ejecución
- [ ] Documentar proceso en README
- [ ] (Opcional) Configurar CI/CD para publicar
- [ ] (Opcional) Integrar con Figma

---

**Estado**: Guía de referencia  
**Prioridad**: Baja (documentación actual es suficiente)  
**Esfuerzo estimado**: 2-3 días para implementación completa  
**Mantenido por**: Equipo Creapolis
