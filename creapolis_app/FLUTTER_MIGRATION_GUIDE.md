# 🔄 Guía de Migración de APIs Deprecated en Flutter

> **Fecha de actualización**: 3 de octubre, 2025  
> **Flutter version**: 3.27+  
> **Dart version**: 3.9+

## 📋 Índice de Cambios

1. [Color.withOpacity() → withValues()](#1-colorwithopacity--withvalues)
2. [Logger.level = Level.nothing → Level.off](#2-loggerlevel--levelnothing--leveloff)
3. [Super parameters](#3-super-parameters)
4. [TextTheme properties (Material 3)](#4-texttheme-properties)
5. [Proceso de actualización](#5-proceso-de-actualización)

---

## 1. Color.withOpacity() → withValues()

### ❌ DEPRECATED (genera warning)

```dart
color.withOpacity(0.6)
Colors.blue.withOpacity(0.5)
Theme.of(context).colorScheme.primary.withOpacity(0.8)
```

### ✅ CORRECTO (Flutter 3.27+)

```dart
color.withValues(alpha: 0.6)
Colors.blue.withValues(alpha: 0.5)
Theme.of(context).colorScheme.primary.withValues(alpha: 0.8)
```

### 📚 Documentación

- **Razón del cambio**: Prevenir pérdida de precisión al convertir entre espacios de color
- **Migración**: Buscar y reemplazar `.withOpacity(` por `.withValues(alpha: `
- **Comando**: `flutter analyze` para encontrar usos

### 💡 Casos de uso avanzados

```dart
// Solo alpha
color.withValues(alpha: 0.5)

// Cambiar múltiples canales
color.withValues(
  alpha: 0.8,
  red: 1.0,
  green: 0.5,
  blue: 0.3,
)

// En tema
Theme.of(context).textTheme.bodyLarge?.copyWith(
  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
)
```

---

## 2. Logger.level = Level.nothing → Level.off

### ❌ DEPRECATED (logger package)

```dart
Logger.level = Level.nothing;
```

### ✅ CORRECTO

```dart
Logger.level = Level.off;
```

### 📚 Documentación

- **Razón del cambio**: Consistencia con convenciones de logging (off es más estándar)
- **Package**: `logger` package v2.0+
- **Uso**: Para desactivar logs en producción

---

## 3. Super parameters

### ❌ VIEJO (verboso)

```dart
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class AuthFailure extends Failure {
  const AuthFailure({required String message}) : super(message);
}
```

### ✅ NUEVO (Dart 2.17+)

```dart
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}
```

### 📚 Documentación

- **Lint rule**: `use_super_parameters`
- **Beneficio**: Reduce código repetitivo
- **Auto-fix**: `dart fix --apply` puede aplicar automáticamente

### 💡 Ejemplos más complejos

```dart
// Con múltiples parámetros
class CustomWidget extends StatelessWidget {
  final String title;

  const CustomWidget({
    required this.title,
    super.key,  // ← super parameter
  });
}

// Con super nombrado
class MyException implements Exception {
  const MyException({required super.message});
}
```

---

## 4. TextTheme properties

### ❌ DEPRECATED (Material 2)

```dart
textTheme.headline1    // Grande display
textTheme.headline2
textTheme.headline3
textTheme.headline4
textTheme.headline5
textTheme.headline6    // Pequeño headline
textTheme.bodyText1    // Body grande
textTheme.bodyText2    // Body normal
textTheme.subtitle1
textTheme.subtitle2
textTheme.caption      // Texto pequeño
textTheme.button       // Texto de botones
textTheme.overline     // Overline texto
```

### ✅ CORRECTO (Material 3)

```dart
textTheme.displayLarge     // era headline1
textTheme.displayMedium    // era headline2
textTheme.displaySmall     // era headline3
textTheme.headlineLarge    // era headline4
textTheme.headlineMedium   // era headline5
textTheme.headlineSmall    // era headline6
textTheme.bodyLarge        // era bodyText1
textTheme.bodyMedium       // era bodyText2
textTheme.bodySmall        // era caption
textTheme.labelLarge       // era button
textTheme.labelMedium      // nuevo
textTheme.labelSmall       // nuevo
textTheme.titleLarge       // era subtitle1
textTheme.titleMedium      // era subtitle2
textTheme.titleSmall       // nuevo
```

### 📚 Documentación

- **Material 3 Typography**: https://m3.material.io/styles/typography
- **Migration guide**: https://docs.flutter.dev/release/breaking-changes/text-theme-2021

### 🎨 Tabla de conversión completa

| Material 2 (deprecated) | Material 3 (nuevo) | Uso típico                 |
| ----------------------- | ------------------ | -------------------------- |
| `headline1`             | `displayLarge`     | Títulos muy grandes (96pt) |
| `headline2`             | `displayMedium`    | Títulos grandes (60pt)     |
| `headline3`             | `displaySmall`     | Títulos medianos (48pt)    |
| `headline4`             | `headlineLarge`    | Headers (34pt)             |
| `headline5`             | `headlineMedium`   | Headers (24pt)             |
| `headline6`             | `headlineSmall`    | Headers pequeños (20pt)    |
| `bodyText1`             | `bodyLarge`        | Body destacado (16pt)      |
| `bodyText2`             | `bodyMedium`       | Body normal (14pt)         |
| `caption`               | `bodySmall`        | Captions (12pt)            |
| `button`                | `labelLarge`       | Botones (14pt bold)        |
| `subtitle1`             | `titleLarge`       | Subtítulos (16pt)          |
| `subtitle2`             | `titleMedium`      | Subtítulos (14pt)          |

---

## 5. Proceso de Actualización

### 🔍 Paso 1: Detectar deprecated APIs

```bash
# Analizar proyecto
flutter analyze

# Ver lista de issues
flutter analyze --write=analyze_results.txt
```

### 🔧 Paso 2: Auto-fix cuando sea posible

```bash
# Ver qué se puede arreglar automáticamente
dart fix --dry-run

# Aplicar fixes automáticos
dart fix --apply
```

### 📖 Paso 3: Buscar documentación

1. **Flutter API docs**: https://api.flutter.dev/
   - Buscar la clase/método deprecated
   - Leer el mensaje de `@Deprecated()`
2. **Flutter changelog**: https://docs.flutter.dev/release/breaking-changes
   - Buscar migration guides oficiales
3. **Package documentation**:
   - Para packages de terceros: pub.dev/packages/[nombre]
   - Revisar CHANGELOG.md del package

### ✏️ Paso 4: Actualizar código manualmente

```dart
// Ejemplo de búsqueda en VS Code:
// 1. Ctrl+Shift+F (buscar en todos los archivos)
// 2. Buscar: \.withOpacity\(
// 3. Reemplazar por: .withValues(alpha:
// 4. Revisar cada caso antes de reemplazar
```

### ✅ Paso 5: Verificar cambios

```bash
# Analizar nuevamente
flutter analyze

# Ejecutar tests
flutter test

# Probar en emulador/dispositivo
flutter run
```

---

## 📊 Checklist de Migración

### Antes de cada actualización de Flutter:

- [ ] Leer release notes de Flutter
- [ ] Revisar breaking changes
- [ ] Hacer backup del código
- [ ] Ejecutar `flutter analyze`
- [ ] Documentar deprecated APIs encontradas

### Durante la migración:

- [ ] Ejecutar `dart fix --apply` para auto-fixes
- [ ] Actualizar deprecated APIs manualmente
- [ ] Buscar documentación para cada cambio
- [ ] Probar cada cambio
- [ ] Actualizar tests si es necesario

### Después de la migración:

- [ ] Verificar `flutter analyze` sin warnings
- [ ] Ejecutar todos los tests
- [ ] Probar app en múltiples dispositivos
- [ ] Revisar performance
- [ ] Actualizar documentación del proyecto

---

## 🔗 Referencias Útiles

### Documentación oficial

- [Flutter API Docs](https://api.flutter.dev/)
- [Flutter Breaking Changes](https://docs.flutter.dev/release/breaking-changes)
- [Dart Language Evolution](https://dart.dev/guides/language/evolution)
- [Material 3 Guidelines](https://m3.material.io/)

### Herramientas

- `flutter analyze` - Analizar código
- `dart fix` - Auto-reparar issues
- `dart format` - Formatear código
- VS Code Flutter extension - Warnings inline

### Comandos útiles

```bash
# Ver versión actual
flutter --version

# Actualizar Flutter
flutter upgrade

# Limpiar proyecto
flutter clean

# Obtener dependencias
flutter pub get

# Actualizar dependencias
flutter pub upgrade --major-versions
```

---

## 💡 Tips Adicionales

### ⚡ Migración rápida con regex

**Para withOpacity:**

```regex
# Buscar (regex enabled):
\.withOpacity\(([0-9.]+)\)

# Reemplazar con:
.withValues(alpha: $1)
```

### 🎯 Prevenir deprecated en CI/CD

```yaml
# .github/workflows/flutter.yml
- name: Analyze code
  run: |
    flutter analyze --fatal-infos
    # Falla si hay deprecated warnings
```

### 📝 Documentar cambios en CHANGELOG

```markdown
## [1.2.0] - 2025-10-03

### Changed

- Migrado de `withOpacity()` a `withValues()` (Flutter 3.27+)
- Actualizado TextTheme a Material 3 naming
- Reemplazado `Level.nothing` por `Level.off` en logger
```

---

**Última actualización**: 3 de octubre, 2025  
**Mantenido por**: Flutter Developer Agent  
**Proyecto**: Creapolis
