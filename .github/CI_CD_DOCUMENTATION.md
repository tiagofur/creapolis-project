# 🚀 CI/CD Pipeline Documentation

**Creapolis Project - Continuous Integration & Deployment**  
**Fecha:** 13 de octubre, 2025  
**Estado:** ✅ Implementado  
**Version:** 1.0.0

---

## 📋 Resumen Ejecutivo

Sistema completo de CI/CD implementado con GitHub Actions que automatiza testing, builds y deployments para el proyecto Creapolis.

### Características Principales

- ✅ **Testing Automático** en cada PR
- ✅ **Builds Automáticos** para Android/iOS
- ✅ **Despliegue a Staging** desde rama develop
- ✅ **Notificaciones** de estado del pipeline
- ✅ **Cobertura de Código** con Codecov
- ✅ **Quality Gates** automáticos

---

## 🔄 Workflows Implementados

### 1. Backend CI (`backend-ci.yml`)

**Trigger:**
- Push a `main` o `develop`
- Pull Requests a `main` o `develop`
- Solo cuando hay cambios en `backend/**`

**Jobs:**
- **Test**: Ejecuta tests con PostgreSQL
- **Build**: Genera build de producción

**Pasos:**
1. Checkout del código
2. Setup de Node.js 20
3. Instalación de dependencias (`npm ci`)
4. Setup de base de datos de prueba
5. Ejecución de tests con coverage
6. Upload de coverage a Codecov
7. Build del proyecto

**Variables de Entorno Requeridas:**
```env
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/creapolis_test
JWT_SECRET=test-secret-key
NODE_ENV=test
```

**Secrets Opcionales:**
- `CODECOV_TOKEN`: Para reportes de cobertura

---

### 2. Flutter CI (`flutter-ci.yml`)

**Trigger:**
- Push a `main` o `develop`
- Pull Requests a `main` o `develop`
- Solo cuando hay cambios en `creapolis_app/**`

**Jobs:**
- **analyze-and-test**: Análisis y testing
- **code-quality**: Métricas de calidad

**Pasos:**
1. Checkout del código
2. Setup de Flutter 3.27.1
3. Instalación de dependencias (`flutter pub get`)
4. Generación de código (`build_runner`)
5. Análisis estático (`flutter analyze`)
6. Check de formateo (`dart format`)
7. Ejecución de tests con coverage
8. Upload de coverage a Codecov

**Secrets Opcionales:**
- `CODECOV_TOKEN`: Para reportes de cobertura

---

### 3. Android Build (`android-build.yml`)

**Trigger:**
- Push a `main` o `develop`
- Pull Requests a `main`
- Tags `v*` (releases)
- Manual dispatch

**Jobs:**
- **build-android**: Build APK y App Bundle

**Builds:**
- **Debug APK**: Para PRs y branches
- **Release APK**: Para tags y manual
- **App Bundle**: Para releases en Play Store

**Artefactos Generados:**
- `android-apk-{sha}`: APK debug/release
- `android-bundle-{sha}`: App Bundle (.aab)

**Secrets para Signing (Opcional):**
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_KEY_ALIAS`

---

### 4. iOS Build (`ios-build.yml`)

**Trigger:**
- Push a `main` o `develop`
- Pull Requests a `main`
- Tags `v*` (releases)
- Manual dispatch

**Jobs:**
- **build-ios**: Build para iOS

**Builds:**
- **Debug**: Build sin firma
- **Release**: Build con/sin firma según configuración
- **Archive + IPA**: Para distribución (solo con certificados)

**Requisitos:**
- macOS runner
- CocoaPods instalado
- Certificados de desarrollo (opcional)

**Secrets para Signing (Opcional):**
- `IOS_MATCH_PASSWORD`
- `IOS_FASTLANE_PASSWORD`

---

### 5. Deploy to Staging (`deploy-staging.yml`)

**Trigger:**
- Push a rama `develop`
- Manual dispatch

**Environments:**
- `staging`: Backend
- `staging-web`: Flutter Web

**Jobs:**

#### deploy-backend
1. Build Docker image
2. Ejecuta migraciones de DB
3. Deploy a servidor staging
4. Health check
5. Notificación Slack

#### deploy-flutter-web
1. Build Flutter web
2. Deploy a servidor web staging
3. Upload artifacts
4. Notificación Slack

**Secrets Requeridos:**
```
# Backend Staging
STAGING_DATABASE_URL
STAGING_HOST
STAGING_USER
STAGING_SSH_KEY

# Web Staging
STAGING_API_URL
STAGING_WEB_HOST
STAGING_WEB_USER
STAGING_WEB_SSH_KEY

# Notificaciones
SLACK_WEBHOOK
```

---

### 6. Pull Request Checks (`pr-checks.yml`)

**Trigger:**
- Pull Requests a `main` o `develop`

**Features:**
- Detección inteligente de cambios
- Ejecución selectiva de checks
- Comentarios automáticos en PR
- Resumen de resultados

**Jobs:**
- **pr-info**: Información del PR
- **detect-changes**: Detecta qué cambió
- **backend-checks**: Checks de backend (condicional)
- **flutter-checks**: Checks de Flutter (condicional)
- **all-checks-passed**: Resumen final

---

### 7. Pipeline Notifications (`notifications.yml`)

**Trigger:**
- Completación de cualquier workflow principal

**Notificaciones:**
- ✅ **Slack**: Todos los workflows
- 📧 **Email**: Solo fallos
- 🐛 **GitHub Issues**: Fallos en main

**Tipos de Notificaciones:**
1. **Slack**: Estado de workflows con detalles
2. **Email**: Alertas de fallos críticos
3. **GitHub Issues**: Auto-creación en fallos de main

**Secrets Opcionales:**
```
SLACK_WEBHOOK
MAIL_SERVER
MAIL_PORT
MAIL_USERNAME
MAIL_PASSWORD
NOTIFICATION_EMAIL
```

---

## 🎯 Flujo de Trabajo Típico

### Desarrollo de Feature

```mermaid
graph LR
    A[Create Branch] --> B[Commit Changes]
    B --> C[Push to GitHub]
    C --> D[PR Checks Run]
    D --> E{Checks Pass?}
    E -->|Yes| F[Review & Merge]
    E -->|No| B
    F --> G[Deploy to Staging]
```

### Proceso Completo

1. **Developer crea PR**
   - PR Checks workflow se ejecuta
   - Detecta cambios (backend/flutter)
   - Ejecuta tests relevantes
   - Comenta resultados en PR

2. **Merge a develop**
   - Backend CI ejecuta tests completos
   - Flutter CI ejecuta tests + análisis
   - Deploy to Staging ejecuta
   - Notificaciones enviadas

3. **Merge a main**
   - Todos los CI workflows ejecutan
   - Builds de release generados
   - Notificaciones críticas activas

4. **Tag release (v*)**
   - Android Build genera APK + Bundle firmados
   - iOS Build genera IPA firmado
   - GitHub Release creado automáticamente

---

## 📊 Badges y Reportes

### Status Badges

Agrega estos badges a tu README:

```markdown
![Backend CI](https://github.com/tiagofur/creapolis-project/workflows/Backend%20CI/badge.svg)
![Flutter CI](https://github.com/tiagofur/creapolis-project/workflows/Flutter%20CI/badge.svg)
![Android Build](https://github.com/tiagofur/creapolis-project/workflows/Android%20Build/badge.svg)
![iOS Build](https://github.com/tiagofur/creapolis-project/workflows/iOS%20Build/badge.svg)
```

### Codecov Badge

```markdown
[![codecov](https://codecov.io/gh/tiagofur/creapolis-project/branch/main/graph/badge.svg)](https://codecov.io/gh/tiagofur/creapolis-project)
```

---

## 🔐 Configuración de Secrets

### Secrets Requeridos

#### Para CI/CD Básico (Testing)
- `CODECOV_TOKEN` (opcional): Token de Codecov

#### Para Android Builds Firmados
```bash
ANDROID_KEYSTORE_PASSWORD=your-keystore-password
ANDROID_KEY_PASSWORD=your-key-password
ANDROID_KEY_ALIAS=your-key-alias
```

#### Para iOS Builds Firmados
```bash
IOS_MATCH_PASSWORD=your-match-password
IOS_FASTLANE_PASSWORD=your-fastlane-password
```

#### Para Staging Deployment
```bash
# Backend
STAGING_DATABASE_URL=postgresql://user:pass@host:5432/db
STAGING_HOST=staging.example.com
STAGING_USER=deploy
STAGING_SSH_KEY=-----BEGIN OPENSSH PRIVATE KEY-----...

# Web
STAGING_API_URL=https://api-staging.example.com
STAGING_WEB_HOST=staging-web.example.com
STAGING_WEB_USER=deploy
STAGING_WEB_SSH_KEY=-----BEGIN OPENSSH PRIVATE KEY-----...
```

#### Para Notificaciones
```bash
SLACK_WEBHOOK=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=notifications@example.com
MAIL_PASSWORD=your-app-password
NOTIFICATION_EMAIL=team@example.com
```

### Cómo Configurar Secrets

1. Ve a tu repositorio en GitHub
2. Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Agrega nombre y valor
5. Click "Add secret"

---

## 🚀 Guía de Uso

### Ejecutar Tests en PR

Los tests se ejecutan automáticamente. Para ejecutar manualmente:

```bash
# Backend
cd backend
npm test

# Flutter
cd creapolis_app
flutter test
```

### Trigger Manual de Workflows

Algunos workflows soportan dispatch manual:

1. Ve a Actions en GitHub
2. Selecciona el workflow
3. Click "Run workflow"
4. Elige branch y parámetros
5. Click "Run workflow"

### Crear Release

Para crear un release con builds firmados:

```bash
# 1. Actualizar versión en package.json y pubspec.yaml
# 2. Commit cambios
git add .
git commit -m "chore: bump version to 1.0.0"

# 3. Crear tag
git tag -a v1.0.0 -m "Release version 1.0.0"

# 4. Push tag
git push origin v1.0.0

# Los workflows automáticamente:
# - Buildearan Android APK + Bundle
# - Buildearan iOS IPA (si hay certificados)
# - Crearán GitHub Release con artefactos
```

---

## 🐛 Troubleshooting

### Tests Fallan en CI pero Pasan Localmente

**Problema**: Diferencias de ambiente

**Solución**:
```bash
# Asegúrate de usar las mismas versiones
node --version  # Debe ser 20.x
flutter --version  # Debe ser 3.27.1

# Limpia cache
cd backend && npm ci
cd creapolis_app && flutter clean && flutter pub get
```

### Android Build Falla

**Problema**: Falta configuración de signing

**Solución**:
- Para development: El workflow genera APK sin firmar
- Para production: Configura los secrets de Android

### iOS Build Falla

**Problema**: Falta certificados

**Solución**:
- Para development: El workflow genera build sin firmar
- Para production: Configura Fastlane Match

### Staging Deploy Falla

**Problema**: Secrets no configurados

**Solución**:
- El workflow es graceful, solo avisa si faltan secrets
- Configura secrets de staging para activar deployment

---

## 📈 Métricas y Monitoreo

### Métricas Rastreadas

1. **Test Coverage**
   - Backend: Via Codecov
   - Flutter: Via Codecov
   - Target: >80%

2. **Build Times**
   - Backend: ~2-3 min
   - Flutter: ~5-7 min
   - Android: ~8-10 min
   - iOS: ~10-15 min

3. **Success Rate**
   - Monitoreado via GitHub Actions
   - Alertas automáticas en fallos

### Dashboards

- **GitHub Actions**: Ver en repositorio → Actions
- **Codecov**: https://codecov.io/gh/tiagofur/creapolis-project

---

## 🔄 Mantenimiento

### Actualizar Flutter Version

Edita `.github/workflows/flutter-ci.yml`, `android-build.yml`, `ios-build.yml`:

```yaml
- uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.27.1'  # Cambiar aquí
```

### Actualizar Node.js Version

Edita `.github/workflows/backend-ci.yml`, `deploy-staging.yml`:

```yaml
- uses: actions/setup-node@v4
  with:
    node-version: '20'  # Cambiar aquí
```

### Agregar Nuevo Workflow

1. Crea archivo en `.github/workflows/`
2. Define triggers y jobs
3. Actualiza `notifications.yml` si necesario
4. Documenta en este archivo

---

## 📚 Recursos

### Documentación GitHub Actions
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)

### Actions Usadas
- [actions/checkout](https://github.com/actions/checkout)
- [actions/setup-node](https://github.com/actions/setup-node)
- [subosito/flutter-action](https://github.com/subosito/flutter-action)
- [codecov/codecov-action](https://github.com/codecov/codecov-action)
- [dorny/paths-filter](https://github.com/dorny/paths-filter)

### Best Practices
- [GitHub Actions Best Practices](https://docs.github.com/en/actions/learn-github-actions/best-practices-for-github-actions)
- [Security Hardening](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)

---

## 🎓 Training

### Para Nuevos Desarrolladores

1. **Lectura Requerida**
   - Este documento completo
   - [GitHub Actions Quickstart](https://docs.github.com/en/actions/quickstart)

2. **Práctica**
   - Crear un PR de prueba
   - Observar ejecución de workflows
   - Revisar logs y resultados

3. **Recursos**
   - Slack channel: #ci-cd
   - Tech lead: @tiagofur

---

## 📞 Soporte

### Problemas con CI/CD

1. **Check los logs**: GitHub Actions → Workflow → Job → Steps
2. **Busca en Issues**: Puede ser problema conocido
3. **Pregunta en Slack**: #ci-cd channel
4. **Contacta Tech Lead**: @tiagofur

### Reportar Bugs

Crea issue con:
- Workflow afectado
- Link al run fallido
- Logs relevantes
- Pasos para reproducir

---

## 🔮 Roadmap

### Próximas Mejoras

- [ ] **Docker Registry**: Push images a registry
- [ ] **Production Deployment**: Auto-deploy a producción
- [ ] **E2E Tests**: Integration con Playwright
- [ ] **Performance Tests**: Benchmarks automáticos
- [ ] **Security Scanning**: SAST/DAST integration
- [ ] **Dependency Updates**: Dependabot config
- [ ] **Release Notes**: Auto-generación desde commits

---

**Última actualización**: 13 de octubre, 2025  
**Mantenedor**: @tiagofur  
**Version**: 1.0.0
