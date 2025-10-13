# 🚀 CI/CD Quick Reference

Guía rápida para desarrolladores sobre el pipeline de CI/CD de Creapolis.

---

## 📋 ¿Qué se Ejecuta Cuando?

### En cada Pull Request

✅ **Automático**
- Tests del código modificado (Backend o Flutter)
- Análisis estático de código
- Verificación de formateo
- Comentarios automáticos con resultados

### En Push a `develop`

✅ **Automático**
- Todos los tests
- Build de artefactos
- **Deploy automático a Staging**
- Notificaciones de estado

### En Push a `main`

✅ **Automático**
- Todos los tests
- Build de artefactos
- Validaciones completas
- Notificaciones críticas

### En Tag `v*` (Release)

✅ **Automático**
- Build firmado de Android (APK + AAB)
- Build firmado de iOS (IPA)
- Creación de GitHub Release
- Upload de artefactos

---

## 🎯 Comandos Locales Antes de Push

### Backend

```bash
cd backend

# Ejecutar tests
npm test

# Ver coverage
npm test -- --coverage

# Linter (si existe)
npm run lint
```

### Flutter

```bash
cd creapolis_app

# Ejecutar tests
flutter test

# Tests con coverage
flutter test --coverage

# Análisis de código
flutter analyze

# Verificar formato
dart format --set-exit-if-changed .

# Arreglar formato
dart format .

# Generar código
dart run build_runner build --delete-conflicting-outputs
```

---

## 🔍 Ver Estado de Workflows

### En GitHub Web

1. Ve a tu repositorio
2. Click en pestaña **Actions**
3. Selecciona un workflow para ver historial
4. Click en un run para ver detalles

### Badges en README

Los badges muestran el estado actual:
- 🟢 Verde: Passing
- 🔴 Rojo: Failing
- 🟡 Amarillo: Running

---

## 🐛 Workflow Falló - ¿Qué Hacer?

### 1. Ver los Logs

```
GitHub → Actions → Click en el workflow fallido → Click en el job → Ver logs
```

### 2. Reproducir Localmente

```bash
# Backend
cd backend
npm ci
npm test

# Flutter
cd creapolis_app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
```

### 3. Común: Tests Fallan

**Problema**: Tests pasan localmente pero fallan en CI

**Soluciones**:
- Verifica versiones de Node.js / Flutter
- Limpia cache: `npm ci` / `flutter clean`
- Revisa variables de entorno
- Revisa dependencias de servicios (DB)

### 4. Común: Build de Android/iOS Falla

**Problema**: Falta configuración de signing

**Solución**:
- En PRs: Se genera build sin firmar (esperado)
- En releases: Configura secrets de signing

---

## 🚀 Crear un Release

### Paso a Paso

```bash
# 1. Actualiza versiones
# backend/package.json
# creapolis_app/pubspec.yaml

# 2. Commit
git add .
git commit -m "chore: bump version to 1.2.0"

# 3. Crea tag
git tag -a v1.2.0 -m "Release 1.2.0"

# 4. Push
git push origin main
git push origin v1.2.0

# 5. Espera a que workflows terminen (10-15 min)
# 6. Revisa GitHub Releases para artefactos
```

---

## 📊 Secrets Necesarios

### Para Testing (Opcional)
- `CODECOV_TOKEN`: Coverage reports

### Para Android Release
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_KEY_ALIAS`

### Para iOS Release
- `IOS_MATCH_PASSWORD`
- `IOS_FASTLANE_PASSWORD`

### Para Staging Deploy
- `STAGING_DATABASE_URL`
- `STAGING_HOST`
- `STAGING_USER`
- `STAGING_SSH_KEY`
- `STAGING_API_URL`
- `STAGING_WEB_HOST`
- `STAGING_WEB_USER`
- `STAGING_WEB_SSH_KEY`

### Para Notificaciones
- `SLACK_WEBHOOK`
- `MAIL_SERVER`, `MAIL_PORT`, `MAIL_USERNAME`, `MAIL_PASSWORD`
- `NOTIFICATION_EMAIL`

---

## 💡 Tips

### Evitar Ejecutar Workflows Innecesarios

Los workflows se ejecutan selectivamente basados en los archivos cambiados:
- Cambios en `backend/**` → Solo Backend CI
- Cambios en `creapolis_app/**` → Solo Flutter CI
- Cambios en ambos → Ambos workflows

### Formato de Commit Messages

Usa conventional commits para mejor legibilidad:
```
feat: nueva funcionalidad
fix: corrección de bug
chore: tareas de mantenimiento
docs: documentación
test: tests
ci: cambios en CI/CD
```

### Skip CI (Emergencias)

Para commits que no necesitan CI:
```bash
git commit -m "docs: fix typo [skip ci]"
```

---

## 📞 Ayuda

- **Documentación completa**: [.github/CI_CD_DOCUMENTATION.md](./CI_CD_DOCUMENTATION.md)
- **Problemas**: Crea un issue
- **Preguntas**: Slack #ci-cd

---

**Quick Start**: Push → PR → Auto-checks → Merge → Auto-deploy ✨
