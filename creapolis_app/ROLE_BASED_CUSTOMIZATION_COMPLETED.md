# Personalización Avanzada por Rol - Implementación Completada

## 📋 Resumen

Se ha implementado un sistema completo de personalización de UI basado en roles que permite:
- **Configuraciones base por rol**: Cada rol (admin, projectManager, teamMember) tiene configuración predefinida
- **Override personalizado**: Los usuarios pueden personalizar sobre los defaults del rol
- **Persistencia**: Las personalizaciones se guardan localmente
- **Indicadores visuales**: El UI muestra qué está usando defaults vs personalizado
- **Reseteo**: Opción para volver a los defaults del rol

---

## 🎯 Criterios de Aceptación

✅ **Definición de roles y dashboards/templates por defecto**
- 3 roles definidos: admin, projectManager, teamMember
- Cada rol tiene su configuración base de:
  - Tema (light/dark/system)
  - Layout (sidebar/bottomNavigation)
  - Widgets de dashboard (cantidad y tipo)

✅ **Capacidad de override por usuario**
- Sistema de overrides sobre configuración base del rol
- Los overrides se guardan en SharedPreferences
- Métodos para establecer/limpiar overrides individuales

✅ **Interfaz de configuración adaptada al rol**
- Pantalla dedicada `RoleBasedPreferencesScreen`
- Muestra información del rol actual
- Indicadores "Personalizado" en elementos con override
- Descripciones específicas por rol

✅ **Pruebas con al menos 2 roles distintos**
- Suite completa de tests con 24 casos
- Tests específicos para admin, projectManager y teamMember
- Tests de persistencia, overrides y cambios de rol

---

## 📁 Archivos Creados

### 1. Entidades de Dominio

**`lib/domain/entities/role_based_ui_config.dart`** (~258 líneas)
- `RoleBasedUIConfig`: Configuración base por rol
  - `adminDefaults()`: 6 widgets, tema system
  - `projectManagerDefaults()`: 5 widgets, tema system
  - `teamMemberDefaults()`: 4 widgets, tema light
- `UserUIPreferences`: Preferencias con overrides
  - Gestión de overrides (theme, layout, dashboard)
  - Getters para configuración efectiva
  - Serialización JSON

### 2. Servicios

**`lib/core/services/role_based_preferences_service.dart`** (~330 líneas)
- Servicio singleton para gestión de preferencias
- Métodos principales:
  - `loadUserPreferences(UserRole)`: Carga preferencias del usuario
  - `saveUserPreferences(UserUIPreferences)`: Persiste preferencias
  - `setThemeOverride(String)`: Establece override de tema
  - `setLayoutOverride(String)`: Establece override de layout
  - `setDashboardOverride(DashboardConfig)`: Establece override de dashboard
  - `clearThemeOverride()`: Elimina override de tema
  - `clearLayoutOverride()`: Elimina override de layout
  - `clearDashboardOverride()`: Elimina override de dashboard
  - `resetToRoleDefaults()`: Resetea todo a defaults del rol
  - `getEffectiveThemeMode()`: Obtiene tema efectivo
  - `getEffectiveLayoutType()`: Obtiene layout efectivo
  - `getEffectiveDashboardConfig()`: Obtiene dashboard efectivo

### 3. UI

**`lib/presentation/screens/settings/role_based_preferences_screen.dart`** (~540 líneas)
- Pantalla completa de configuración
- Componentes:
  - Card de información del rol con descripción
  - Card de configuración de tema con indicador de override
  - Card de configuración de dashboard con indicador de override
  - Card de ayuda explicativa
  - Botón de resetear en AppBar
- Interacciones:
  - Toggle de overrides
  - Confirmación antes de resetear
  - Feedback visual con SnackBars

### 4. Tests

**`test/core/services/role_based_preferences_service_test.dart`** (~370 líneas)
- 24 casos de test organizados en 10 grupos:
  1. Inicialización
  2. Carga de preferencias (3 tests)
  3. Theme Overrides (4 tests)
  4. Dashboard Overrides (2 tests)
  5. Role-Based Defaults (8 tests)
  6. Reset to Role Defaults (1 test)
  7. Persistence (2 tests)
  8. Role Change Handling (1 test)
  9. Layout Overrides (2 tests)
  10. Effective Configuration (2 tests)

### 5. Modificaciones

**`lib/core/constants/storage_keys.dart`** (+3 líneas)
- Añadido: `roleBasedUIPreferences` key

**`lib/main.dart`** (+3 líneas)
- Import del servicio
- Inicialización en startup

---

## 🏗️ Arquitectura

### Flujo de Datos

```
1. Login/Startup
   └─> RoleBasedPreferencesService.loadUserPreferences(userRole)
       └─> Carga preferencias o crea defaults para el rol
       
2. Usuario Navega
   └─> UI consulta preferencias efectivas
       └─> Aplica defaults del rol + overrides del usuario
       
3. Usuario Personaliza
   └─> UI llama a setThemeOverride/setDashboardOverride/etc
       └─> Servicio persiste override en SharedPreferences
       └─> UI se actualiza con nueva configuración
       
4. Usuario Resetea
   └─> UI llama a resetToRoleDefaults()
       └─> Servicio elimina todos los overrides
       └─> UI vuelve a defaults del rol
```

### Configuraciones por Rol

#### Admin (Administrador)
- **Widgets**: 6 (todos disponibles)
  1. Workspace Info
  2. Quick Stats
  3. Quick Actions
  4. My Projects
  5. My Tasks
  6. Recent Activity
- **Tema**: System (sigue preferencia del SO)
- **Layout**: Bottom Navigation
- **Filosofía**: Acceso completo, visión general

#### Project Manager (Gestor de Proyecto)
- **Widgets**: 5 (enfocado en gestión)
  1. Workspace Info
  2. My Projects ← Priorizado
  3. Quick Stats
  4. My Tasks
  5. Recent Activity
- **Tema**: System
- **Layout**: Bottom Navigation
- **Filosofía**: Gestión de proyectos y coordinación

#### Team Member (Miembro del Equipo)
- **Widgets**: 4 (enfocado en ejecución)
  1. Workspace Info
  2. My Tasks ← Priorizado
  3. Quick Stats
  4. My Projects
- **Tema**: Light (más simple)
- **Layout**: Bottom Navigation
- **Filosofía**: Foco en tareas diarias

---

## 🔧 Uso

### Para Desarrolladores

#### Cargar Preferencias al Login
```dart
// En el AuthBloc o donde manejes el login
final roleService = RoleBasedPreferencesService.instance;
final prefs = await roleService.loadUserPreferences(user.role);

// Aplicar configuración efectiva
final theme = prefs.getEffectiveThemeMode();
final dashboard = prefs.getEffectiveDashboardConfig();
```

#### Establecer un Override
```dart
// Override de tema
await roleService.setThemeOverride('dark');

// Override de dashboard
final customConfig = DashboardConfig(widgets: [...]);
await roleService.setDashboardOverride(customConfig);
```

#### Limpiar un Override
```dart
// Volver al tema default del rol
await roleService.clearThemeOverride();

// Volver al dashboard default del rol
await roleService.clearDashboardOverride();
```

#### Resetear Todo
```dart
// Volver a defaults del rol en todo
await roleService.resetToRoleDefaults();
```

### Para Usuarios

1. **Ver Configuración de Rol**
   - Navegar a Configuración > Preferencias por Rol
   - Ver información del rol actual
   - Ver configuración base y overrides activos

2. **Personalizar**
   - Click en botón "Editar" junto a Tema o Dashboard
   - Sistema crea un override sobre el default del rol
   - Indicador "Personalizado" aparece

3. **Volver a Default**
   - Click en botón "X" junto a elemento personalizado
   - Sistema elimina override y vuelve al default del rol

4. **Resetear Todo**
   - Click en botón "Resetear" en AppBar
   - Confirmar en diálogo
   - Sistema elimina todos los overrides

---

## 🧪 Cobertura de Tests

### Tests Implementados

**Total**: 24 tests en 10 grupos

1. **Inicialización**: Verifica que el servicio se inicializa correctamente
2. **Load User Preferences**: Tests para los 3 roles sin datos guardados
3. **Theme Overrides**: Set, clear, efectivo sin override, efectivo con override
4. **Dashboard Overrides**: Set, clear con verificación de widgets
5. **Role-Based Defaults**: 
   - Cantidad de widgets por rol
   - Priorización de widgets por rol
   - Tema default por rol
6. **Reset**: Reseteo completo de preferencias
7. **Persistence**: Guardar y recuperar entre sesiones, limpiar
8. **Role Change**: Manejo de cambio de rol
9. **Layout Overrides**: Set, clear
10. **Effective Configuration**: Retornar override vs default

### Ejecutar Tests

```bash
cd creapolis_app
flutter test test/core/services/role_based_preferences_service_test.dart
```

---

## 📊 Estadísticas

### Líneas de Código

| Archivo | Líneas | Tipo |
|---------|--------|------|
| `role_based_ui_config.dart` | 258 | Entidad |
| `role_based_preferences_service.dart` | 330 | Servicio |
| `role_based_preferences_screen.dart` | 540 | UI |
| `role_based_preferences_service_test.dart` | 370 | Test |
| `storage_keys.dart` | +3 | Config |
| `main.dart` | +3 | Init |
| **TOTAL** | **~1504** | |

### Características por Rol

| Característica | Admin | Project Manager | Team Member |
|---------------|-------|-----------------|-------------|
| Widgets por defecto | 6 | 5 | 4 |
| Tema por defecto | System | System | Light |
| Widget prioritario | Stats | Projects | Tasks |
| Acciones rápidas | ✅ | ❌ | ❌ |

---

## 🚀 Próximas Mejoras

### Implementadas en Futuro Sprint
- [ ] Múltiples perfiles por usuario
- [ ] Compartir configuración entre usuarios del mismo rol
- [ ] Importar/exportar configuración
- [ ] Configuración avanzada por rol (colores, tipografía)
- [ ] Dashboard templates predefinidos adicionales
- [ ] Analytics de uso de widgets por rol
- [ ] A/B testing de configuraciones por rol
- [ ] Sugerencias de personalización basadas en uso

### Integraciones Pendientes
- [ ] Sincronizar preferencias con backend
- [ ] Notificaciones cuando hay nuevas opciones de personalización
- [ ] Configuración de permisos visuales por rol

---

## 📝 Notas Técnicas

### Decisiones de Diseño

1. **Singleton Service**: Garantiza única instancia y estado consistente
2. **Overrides Opcionales**: Permite null para indicar "usar default del rol"
3. **Configuración por Rol Factory**: Facilita añadir nuevos roles
4. **Persistencia Local**: SharedPreferences para rapidez y offline-first
5. **Tests Exhaustivos**: Cobertura de casos edge (cambio de rol, persistencia)

### Consideraciones de Performance

- Carga lazy de preferencias (solo cuando se necesitan)
- Configuraciones cacheadas en memoria
- Serialización eficiente con JSON
- Tests unitarios rápidos (sin dependencias externas)

### Compatibilidad

- Compatible con sistema existente de ThemeProvider
- Compatible con DashboardPreferencesService
- No rompe funcionalidad existente
- Migración transparente (defaults si no hay datos)

---

## 🐛 Testing Manual

### Escenarios de Test

1. **Usuario Nuevo - Admin**
   - Login como admin
   - Verificar 6 widgets en dashboard
   - Verificar tema system

2. **Usuario Nuevo - Team Member**
   - Login como team member
   - Verificar 4 widgets en dashboard
   - Verificar tema light
   - Verificar "My Tasks" como segundo widget

3. **Personalización**
   - Cambiar tema a dark
   - Verificar indicador "Personalizado"
   - Cerrar sesión y volver a entrar
   - Verificar tema dark persiste

4. **Reseteo**
   - Con overrides activos
   - Click en "Resetear"
   - Confirmar
   - Verificar vuelve a defaults del rol

5. **Cambio de Rol**
   - Usuario con overrides como admin
   - Cambiar rol a team member
   - Verificar defaults del nuevo rol
   - Verificar overrides del admin no aplican

---

## 📞 Soporte

Para preguntas o problemas:
- **Código**: Revisar tests para ejemplos de uso
- **UI**: Revisar `role_based_preferences_screen.dart`
- **Lógica**: Revisar `role_based_preferences_service.dart`
- **Entidades**: Revisar `role_based_ui_config.dart`

---

**Fecha de Implementación**: 13 de Octubre, 2025  
**Branch**: `copilot/define-user-roles-ui-config`  
**Estado**: ✅ Implementación Completa  
**Próximo Paso**: Review y Merge
