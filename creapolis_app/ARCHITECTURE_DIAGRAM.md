# Arquitectura del Sistema de Personalización por Rol

## 📐 Diagrama de Componentes

```
┌─────────────────────────────────────────────────────────────────────┐
│                          CREAPOLIS APP                               │
└─────────────────────────────────────────────────────────────────────┘
                                  │
                    ┌─────────────┼─────────────┐
                    │                           │
         ┌──────────▼──────────┐     ┌─────────▼──────────┐
         │   User Login/Auth   │     │   Main App Init    │
         └──────────┬──────────┘     └─────────┬──────────┘
                    │                           │
                    │ UserRole                  │ init()
                    │                           │
         ┌──────────▼───────────────────────────▼──────────┐
         │    RoleBasedPreferencesService                  │
         │    (Singleton)                                  │
         ├─────────────────────────────────────────────────┤
         │  • loadUserPreferences(UserRole)                │
         │  • setThemeOverride(String)                     │
         │  • setDashboardOverride(DashboardConfig)        │
         │  • clearThemeOverride()                         │
         │  • resetToRoleDefaults()                        │
         │  • getEffectiveThemeMode()                      │
         │  • getEffectiveDashboardConfig()                │
         └──────────┬──────────────────────┬───────────────┘
                    │                      │
       ┌────────────▼───────┐   ┌─────────▼────────────┐
       │ SharedPreferences  │   │  RoleBasedUIConfig   │
       │  (Persistence)     │   │    (Defaults)        │
       └────────────┬───────┘   └──────────┬───────────┘
                    │                       │
                    │                       │ forRole(UserRole)
                    │                       │
       ┌────────────▼───────────────────────▼───────────┐
       │         UserUIPreferences                      │
       │    (User Settings + Overrides)                 │
       ├────────────────────────────────────────────────┤
       │  • userRole: UserRole                          │
       │  • themeModeOverride?: String                  │
       │  • layoutTypeOverride?: String                 │
       │  • dashboardConfigOverride?: DashboardConfig   │
       │                                                │
       │  • getEffectiveThemeMode()                     │
       │  • getEffectiveLayoutType()                    │
       │  • getEffectiveDashboardConfig()               │
       └────────────┬───────────────────────────────────┘
                    │
       ┌────────────┴────────────┬──────────────────────┐
       │                         │                      │
┌──────▼───────┐      ┌─────────▼──────┐    ┌─────────▼────────────┐
│ThemeProvider │      │  DashboardScreen│    │ RoleBasedPreferences │
│   (Theme)    │      │   (UI Display)  │    │   Screen (Config)    │
└──────────────┘      └─────────────────┘    └──────────────────────┘
```

---

## 🔄 Flujo de Datos - Login

```
┌──────────┐
│  Login   │
└────┬─────┘
     │
     │ User { role: UserRole.admin }
     ▼
┌─────────────────────────────────────┐
│ RoleBasedPreferencesService         │
│   .loadUserPreferences(admin)       │
└────┬────────────────────────────────┘
     │
     │ 1. Check SharedPreferences
     │    → Found? Load UserUIPreferences
     │    → Not found? Create defaults for role
     ▼
┌─────────────────────────────────────┐
│ UserUIPreferences                   │
│   userRole: admin                   │
│   themeModeOverride: null           │ ← No override
│   dashboardConfigOverride: null     │ ← No override
└────┬────────────────────────────────┘
     │
     │ 2. Get effective config
     ▼
┌─────────────────────────────────────┐
│ RoleBasedUIConfig.adminDefaults()   │
│   themeModeDefault: 'system'        │
│   dashboardConfig: 6 widgets        │
└────┬────────────────────────────────┘
     │
     │ 3. Apply to UI
     ▼
┌─────────────────────────────────────┐
│ Dashboard renders with:             │
│   • System theme                    │
│   • 6 widgets (admin default)       │
└─────────────────────────────────────┘
```

---

## 🎨 Flujo de Datos - Personalización

```
┌──────────────────────┐
│ User clicks "Edit"   │
│ on Theme setting     │
└────┬─────────────────┘
     │
     ▼
┌─────────────────────────────────────┐
│ RoleBasedPreferencesScreen          │
│   _toggleThemeOverride()            │
└────┬────────────────────────────────┘
     │
     │ Call service method
     ▼
┌─────────────────────────────────────┐
│ RoleBasedPreferencesService         │
│   .setThemeOverride('dark')         │
└────┬────────────────────────────────┘
     │
     │ 1. Update current preferences
     ▼
┌─────────────────────────────────────┐
│ UserUIPreferences (updated)         │
│   userRole: admin                   │
│   themeModeOverride: 'dark'         │ ← Override set!
│   dashboardConfigOverride: null     │
└────┬────────────────────────────────┘
     │
     │ 2. Save to SharedPreferences
     ▼
┌─────────────────────────────────────┐
│ SharedPreferences.setString(        │
│   'role_based_ui_preferences',      │
│   json.encode(preferences)          │
│ )                                   │
└────┬────────────────────────────────┘
     │
     │ 3. Notify UI
     ▼
┌─────────────────────────────────────┐
│ UI Updates:                         │
│   • Theme changes to Dark           │
│   • "Personalizado" chip appears    │
│   • Button icon changes to clear    │
└─────────────────────────────────────┘
```

---

## 🔁 Flujo de Datos - Resetear

```
┌──────────────────────┐
│ User clicks "Reset"  │
│ in AppBar            │
└────┬─────────────────┘
     │
     ▼
┌─────────────────────────────────────┐
│ Show Confirmation Dialog            │
│   "¿Resetear configuración?"        │
└────┬────────────────────────────────┘
     │
     │ User confirms
     ▼
┌─────────────────────────────────────┐
│ RoleBasedPreferencesService         │
│   .resetToRoleDefaults()            │
└────┬────────────────────────────────┘
     │
     │ 1. Create fresh preferences
     ▼
┌─────────────────────────────────────┐
│ UserUIPreferences (reset)           │
│   userRole: admin                   │
│   themeModeOverride: null           │ ← Cleared
│   layoutTypeOverride: null          │ ← Cleared
│   dashboardConfigOverride: null     │ ← Cleared
└────┬────────────────────────────────┘
     │
     │ 2. Save to SharedPreferences
     │ 3. Reload UI
     ▼
┌─────────────────────────────────────┐
│ UI Resets to Role Defaults:         │
│   • All "Personalizado" chips gone  │
│   • Theme = role default            │
│   • Dashboard = role default        │
│   • SnackBar: "Reseteado"           │
└─────────────────────────────────────┘
```

---

## 👥 Configuración por Rol

### Admin (Administrador)

```
┌────────────────────────────────────────┐
│         ADMIN DEFAULT CONFIG           │
├────────────────────────────────────────┤
│ Theme:  System                         │
│ Layout: Bottom Navigation              │
│                                        │
│ Dashboard Widgets: 6                   │
│  1. 🏢 Workspace Info                  │
│  2. 📊 Quick Stats                     │
│  3. 📋 Quick Actions                   │
│  4. 📁 My Projects                     │
│  5. ✅ My Tasks                        │
│  6. 📝 Recent Activity                 │
│                                        │
│ Filosofía: Visión completa y control   │
└────────────────────────────────────────┘
```

### Project Manager (Gestor de Proyecto)

```
┌────────────────────────────────────────┐
│    PROJECT MANAGER DEFAULT CONFIG      │
├────────────────────────────────────────┤
│ Theme:  System                         │
│ Layout: Bottom Navigation              │
│                                        │
│ Dashboard Widgets: 5                   │
│  1. 🏢 Workspace Info                  │
│  2. 📁 My Projects      ← Priorizado   │
│  3. 📊 Quick Stats                     │
│  4. ✅ My Tasks                        │
│  5. 📝 Recent Activity                 │
│                                        │
│ Filosofía: Gestión de proyectos        │
└────────────────────────────────────────┘
```

### Team Member (Miembro del Equipo)

```
┌────────────────────────────────────────┐
│      TEAM MEMBER DEFAULT CONFIG        │
├────────────────────────────────────────┤
│ Theme:  Light                          │
│ Layout: Bottom Navigation              │
│                                        │
│ Dashboard Widgets: 4                   │
│  1. 🏢 Workspace Info                  │
│  2. ✅ My Tasks         ← Priorizado   │
│  3. 📊 Quick Stats                     │
│  4. 📁 My Projects                     │
│                                        │
│ Filosofía: Foco en tareas diarias      │
└────────────────────────────────────────┘
```

---

## 🗂️ Estructura de Datos

### SharedPreferences Storage

```json
{
  "role_based_ui_preferences": {
    "userRole": "admin",
    "themeModeOverride": "dark",
    "layoutTypeOverride": null,
    "dashboardConfigOverride": {
      "widgets": [
        {
          "id": "workspace_info_123456",
          "type": "workspaceInfo",
          "position": 0,
          "isVisible": true
        },
        {
          "id": "my_tasks_123457",
          "type": "myTasks",
          "position": 1,
          "isVisible": true
        }
      ],
      "lastModified": "2025-10-13T14:30:00.000Z"
    }
  }
}
```

---

## 🔀 Estados de Override

### Sin Override (Usando Default del Rol)

```
UserUIPreferences {
  userRole: admin
  themeModeOverride: null        ← No override
  dashboardConfigOverride: null  ← No override
}

↓ getEffectiveThemeMode() ↓

RoleBasedUIConfig.adminDefaults() {
  themeModeDefault: 'system'     ← Retorna este
}

Result: 'system'
```

### Con Override (Personalizado)

```
UserUIPreferences {
  userRole: admin
  themeModeOverride: 'dark'      ← Override presente
  dashboardConfigOverride: null
}

↓ getEffectiveThemeMode() ↓

Return: themeModeOverride       ← Retorna el override

Result: 'dark'
```

---

## 🧩 Clases Principales

### RoleBasedUIConfig (Inmutable)

```dart
class RoleBasedUIConfig {
  final UserRole role;
  final String themeModeDefault;
  final String layoutTypeDefault;
  final DashboardConfig dashboardConfig;
  
  // Factory constructors
  factory RoleBasedUIConfig.adminDefaults()
  factory RoleBasedUIConfig.projectManagerDefaults()
  factory RoleBasedUIConfig.teamMemberDefaults()
  factory RoleBasedUIConfig.forRole(UserRole role)
}
```

### UserUIPreferences (Mutable)

```dart
class UserUIPreferences {
  final UserRole userRole;
  final String? themeModeOverride;      // null = use role default
  final String? layoutTypeOverride;     // null = use role default
  final DashboardConfig? dashboardConfigOverride;  // null = use role default
  
  // Getters for effective config
  String getEffectiveThemeMode()
  String getEffectiveLayoutType()
  DashboardConfig getEffectiveDashboardConfig()
  
  // Checks
  bool get hasThemeOverride
  bool get hasLayoutOverride
  bool get hasDashboardOverride
  
  // Serialization
  factory UserUIPreferences.fromJson(Map<String, dynamic> json)
  Map<String, dynamic> toJson()
}
```

### RoleBasedPreferencesService (Singleton)

```dart
class RoleBasedPreferencesService {
  static final instance = RoleBasedPreferencesService._();
  
  // State
  SharedPreferences? _prefs;
  UserUIPreferences? _currentUserPreferences;
  
  // Core methods
  Future<void> init()
  Future<UserUIPreferences> loadUserPreferences(UserRole userRole)
  Future<bool> saveUserPreferences(UserUIPreferences preferences)
  
  // Theme overrides
  Future<bool> setThemeOverride(String themeMode)
  Future<bool> clearThemeOverride()
  
  // Dashboard overrides
  Future<bool> setDashboardOverride(DashboardConfig config)
  Future<bool> clearDashboardOverride()
  
  // Layout overrides
  Future<bool> setLayoutOverride(String layoutType)
  Future<bool> clearLayoutOverride()
  
  // Reset
  Future<bool> resetToRoleDefaults()
  
  // Getters
  String? getEffectiveThemeMode()
  String? getEffectiveLayoutType()
  DashboardConfig? getEffectiveDashboardConfig()
  RoleBasedUIConfig? getRoleBaseConfig()
}
```

---

## 📈 Escalabilidad

### Añadir Nuevo Rol

```dart
// 1. Añadir al enum en user.dart
enum UserRole {
  admin,
  projectManager,
  teamMember,
  viewer,  // ← Nuevo rol
}

// 2. Crear factory en role_based_ui_config.dart
factory RoleBasedUIConfig.viewerDefaults() {
  return RoleBasedUIConfig(
    role: UserRole.viewer,
    themeModeDefault: 'light',
    layoutTypeDefault: 'bottomNavigation',
    dashboardConfig: DashboardConfig(
      widgets: [/* widgets para viewer */],
      lastModified: DateTime.now(),
    ),
  );
}

// 3. Actualizar forRole()
factory RoleBasedUIConfig.forRole(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return RoleBasedUIConfig.adminDefaults();
    case UserRole.projectManager:
      return RoleBasedUIConfig.projectManagerDefaults();
    case UserRole.teamMember:
      return RoleBasedUIConfig.teamMemberDefaults();
    case UserRole.viewer:  // ← Nuevo case
      return RoleBasedUIConfig.viewerDefaults();
  }
}

// 4. Añadir tests
test('viewer debe tener N widgets por defecto', () {
  final viewerConfig = RoleBasedUIConfig.viewerDefaults();
  expect(viewerConfig.dashboardConfig.widgets.length, N);
});
```

### Añadir Nueva Configuración

```dart
// 1. Añadir campo a RoleBasedUIConfig
class RoleBasedUIConfig {
  final UserRole role;
  final String themeModeDefault;
  final String layoutTypeDefault;
  final DashboardConfig dashboardConfig;
  final String fontSizeDefault;  // ← Nueva configuración
}

// 2. Añadir campo a UserUIPreferences
class UserUIPreferences {
  final UserRole userRole;
  final String? themeModeOverride;
  final String? fontSizeOverride;  // ← Nuevo override
}

// 3. Añadir métodos al servicio
Future<bool> setFontSizeOverride(String fontSize) async { /* ... */ }
Future<bool> clearFontSizeOverride() async { /* ... */ }
String? getEffectiveFontSize() { /* ... */ }

// 4. Actualizar UI
Widget _buildFontSizePreferenceCard() { /* ... */ }
```

---

**Fecha de Creación**: 13 de Octubre, 2025  
**Versión**: 1.0  
**Estado**: Arquitectura Implementada
