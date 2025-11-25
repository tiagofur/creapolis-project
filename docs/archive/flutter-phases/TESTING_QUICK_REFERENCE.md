# 🚀 Testing Quick Reference - Creapolis App

**Guía Rápida de Comandos de Testing**  
**Para:** Desarrolladores y QA  
**Última actualización:** 13 de octubre, 2025

---

## ⚡ Comandos Más Usados

### Ejecutar Todos los Tests

```bash
cd creapolis_app
flutter test
```

### Ejecutar Tests con Coverage

```bash
flutter test --coverage
```

### Ver Resultados Detallados

```bash
flutter test -r expanded
```

---

## 📁 Tests por Categoría

### Unit Tests

```bash
# Todos los unit tests
flutter test test/domain/ test/core/ test/data/

# Solo use cases
flutter test test/domain/usecases/

# Solo services
flutter test test/core/services/

# Solo models
flutter test test/data/models/
```

### Widget Tests

```bash
# Todos los widget tests
flutter test test/presentation/widgets/

# Widget específico
flutter test test/presentation/widgets/workspace_card_test.dart
```

### BLoC Tests

```bash
# Todos los BLoC tests
flutter test test/presentation/bloc/

# BLoC específico
flutter test test/presentation/bloc/workspace_bloc_test.dart
```

### Integration Tests

```bash
# Todos los integration tests
flutter test test/integration/

# Flow específico
flutter test test/integration/workspace_flow_test.dart
```

---

## 📊 Coverage Reports

### Generar Coverage

```bash
# 1. Ejecutar tests con coverage
flutter test --coverage

# 2. Generar HTML report (requiere lcov)
genhtml coverage/lcov.info -o coverage/html

# 3. Abrir en navegador
# macOS
open coverage/html/index.html

# Linux
xdg-open coverage/html/index.html

# Windows
start coverage/html/index.html
```

### Ver Coverage Summary

```bash
# Resumen en terminal
lcov --summary coverage/lcov.info

# Por directorio
lcov --summary coverage/lcov.info | grep "lib/"
```

### Verificar Coverage Mínimo

```bash
# Verificar >= 80%
lcov --summary coverage/lcov.info | grep "lines" | grep -E "([8-9][0-9]|100)\."
```

---

## 🔧 Instalar Herramientas

### lcov (para coverage HTML)

**macOS:**
```bash
brew install lcov
```

**Ubuntu/Debian:**
```bash
sudo apt-get install lcov
```

**Windows:**
```bash
choco install lcov
```

---

## 🧪 Test Individual

### Por Archivo

```bash
flutter test test/path/to/file_test.dart
```

### Por Test Name

```bash
flutter test --name "test name pattern"
```

### Por Tag

```bash
flutter test --tags integration
```

---

## 🔍 Debug Tests

### Con Output Detallado

```bash
flutter test -r expanded test/path/to/file_test.dart
```

### Solo Tests que Fallan

```bash
flutter test --fail-fast
```

### Con Logs

```bash
flutter test -r json > test_results.json
```

---

## 🔄 Re-generar Mocks

```bash
# Generar todos los mocks
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (regenera automáticamente)
flutter pub run build_runner watch --delete-conflicting-outputs
```

---

## 📈 Métricas Actuales

| Métrica | Valor |
|---------|-------|
| Total Tests | 290+ |
| Test Files | 19 |
| Coverage | ~85% |
| Unit Tests | 87 |
| Widget Tests | 101 |
| BLoC Tests | 54 |
| Integration Tests | 48 |

---

## ✅ Checklist antes de Commit

- [ ] `flutter test` - Todos los tests pasan
- [ ] `flutter test --coverage` - Coverage >= 80%
- [ ] Tests nuevos para código nuevo
- [ ] Mocks regenerados si cambiaron interfaces
- [ ] Tests actualizados si cambió funcionalidad

---

## 🎯 Tests por Feature

### Workspace System

```bash
# Use cases
flutter test test/domain/usecases/workspace/

# BLoCs
flutter test test/presentation/bloc/workspace_bloc_test.dart
flutter test test/presentation/bloc/workspace_invitation_bloc_test.dart
flutter test test/presentation/bloc/workspace_member_bloc_test.dart

# Widgets
flutter test test/presentation/widgets/workspace_card_test.dart
flutter test test/presentation/widgets/member_card_test.dart
flutter test test/presentation/widgets/invitation_card_test.dart
flutter test test/presentation/widgets/role_badge_test.dart

# Integration
flutter test test/integration/workspace_flow_test.dart
flutter test test/integration/member_management_flow_test.dart
```

### Customization System

```bash
# Services
flutter test test/core/services/role_based_preferences_service_test.dart
flutter test test/core/services/customization_metrics_service_test.dart

# Provider
flutter test test/presentation/providers/theme_provider_test.dart
```

---

## 🐛 Troubleshooting

### Tests Fallan - "Unable to load asset"

**Solución:** Agregar assets en `pubspec.yaml` o usar test fixtures

### Tests Fallan - "Mock not registered"

**Solución:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Coverage no se genera

**Solución:** Verificar que lcov esté instalado y en PATH

### Tests muy lentos

**Solución:** Ejecutar en paralelo (default) o reducir scope:
```bash
flutter test test/domain/  # Solo unit tests
```

---

## 📚 Documentación

- **Estrategia Completa:** `TESTING_STRATEGY.md`
- **Coverage Report:** `TESTING_COVERAGE_REPORT.md`
- **Manual Testing:** `MANUAL_TESTING_GUIDE.md`
- **Flutter Docs:** https://docs.flutter.dev/testing

---

## 💡 Tips Útiles

### Ejecutar Tests Rápido

```bash
# Skip download de dependencias si ya están
flutter test --no-pub
```

### Limpiar y Re-test

```bash
flutter clean
flutter pub get
flutter test
```

### Test en Modo Watch (externo)

```bash
# Instalar
dart pub global activate test_runner

# Usar
test_runner watch
```

### Ver Solo Failures

```bash
flutter test 2>&1 | grep "FAILED\|✗"
```

---

## 🎓 Para Nuevos Desarrolladores

### Primera Vez

1. Clonar repo
2. `cd creapolis_app`
3. `flutter pub get`
4. `flutter test` - Verificar todo pasa
5. `flutter test --coverage` - Generar coverage
6. Leer `TESTING_STRATEGY.md`

### Agregar Nuevo Feature

1. Escribir tests primero (TDD) o junto con código
2. Ejecutar `flutter test` frecuentemente
3. Verificar coverage >= 80%
4. Actualizar documentación si es necesario

### Before Pull Request

```bash
# 1. Tests pasan
flutter test

# 2. Coverage >= 80%
flutter test --coverage
lcov --summary coverage/lcov.info

# 3. Código formateado
flutter format .

# 4. No hay warnings
flutter analyze
```

---

**Mantén esta guía abierta mientras desarrollas para referencia rápida!**

---

**Última actualización:** 13 de octubre, 2025  
**Mantenido por:** Equipo Creapolis  
**Más info:** Ver `TESTING_STRATEGY.md`
