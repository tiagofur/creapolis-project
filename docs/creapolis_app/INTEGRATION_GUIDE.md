# Guía de Integración - Personalización por Rol

Esta guía muestra cómo integrar el sistema de personalización por rol en diferentes partes de la aplicación.

---

## 🚀 Integración Básica

### 1. Al Login del Usuario

```dart
// En AuthBloc o donde manejes el login exitoso
import 'package:creapolis_app/core/services/role_based_preferences_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RoleBasedPreferencesService _roleService;
  
  Future<void> _onLoginSuccess(User user) async {
    // Cargar preferencias basadas en el rol del usuario
    final preferences = await _roleService.loadUserPreferences(user.role);
    
    // Las preferencias están ahora cargadas y listas para usar
    emit(AuthStateAuthenticated(user: user));
  }
}
```

### 2. En el Dashboard

```dart
// En DashboardScreen
import 'package:creapolis_app/core/services/role_based_preferences_service.dart';

class _DashboardScreenState extends State<DashboardScreen> {
  final _roleService = RoleBasedPreferencesService.instance;
  
  @override
  void initState() {
    super.initState();
    _loadDashboardConfig();
  }
  
  Future<void> _loadDashboardConfig() async {
    // Obtener la configuración efectiva de dashboard
    final config = _roleService.getEffectiveDashboardConfig();
    
    if (config != null) {
      setState(() {
        _dashboardConfig = config;
      });
    }
  }
}
```

### 3. Con ThemeProvider

```dart
// En ThemeProvider o donde manejes el tema
import 'package:creapolis_app/core/services/role_based_preferences_service.dart';

class ThemeProvider extends ChangeNotifier {
  final RoleBasedPreferencesService _roleService;
  
  Future<void> loadThemeForUser() async {
    // Obtener tema efectivo del usuario
    final themeMode = _roleService.getEffectiveThemeMode();
    
    if (themeMode != null) {
      // Aplicar tema
      await setThemeMode(AppThemeMode.fromString(themeMode));
    }
  }
}
```

---

## 🎯 Casos de Uso Específicos

### Caso 1: Mostrar Configuración del Rol en el Profile

```dart
// En ProfileScreen
import 'package:creapolis_app/core/services/role_based_preferences_service.dart';
import 'package:creapolis_app/domain/entities/role_based_ui_config.dart';

Widget _buildRoleSummary(BuildContext context) {
  final roleService = RoleBasedPreferencesService.instance;
  final preferences = roleService.currentUserPreferences;
  
  if (preferences == null) {
    return const SizedBox.shrink();
  }
  
  final hasCustomizations = preferences.hasThemeOverride ||
      preferences.hasLayoutOverride ||
      preferences.hasDashboardOverride;
  
  return Card(
    child: ListTile(
      leading: Icon(
        _getRoleIcon(preferences.userRole),
        color: _getRoleColor(preferences.userRole),
      ),
      title: Text(preferences.userRole.displayName),
      subtitle: Text(
        hasCustomizations
            ? 'Configuración personalizada'
            : 'Usando configuración por defecto',
      ),
      trailing: hasCustomizations
          ? const Icon(Icons.star, color: Colors.amber)
          : null,
    ),
  );
}
```

### Caso 2: Verificar si Usuario Puede Realizar Acción

```dart
// En cualquier pantalla donde necesites verificar el rol
import 'package:creapolis_app/core/services/role_based_preferences_service.dart';

class ProjectSettingsScreen extends StatelessWidget {
  bool _canDeleteProject() {
    final roleService = RoleBasedPreferencesService.instance;
    final preferences = roleService.currentUserPreferences;
    
    // Solo admins pueden eliminar proyectos
    return preferences?.userRole == UserRole.admin;
  }
  
  Widget _buildDeleteButton(BuildContext context) {
    if (!_canDeleteProject()) {
      return const SizedBox.shrink();
    }
    
    return ElevatedButton.icon(
      onPressed: _handleDelete,
      icon: const Icon(Icons.delete),
      label: const Text('Eliminar Proyecto'),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
    );
  }
}
```

### Caso 3: Personalizar Widget Basado en Rol

```dart
// Widget que se adapta según el rol
import 'package:creapolis_app/core/services/role_based_preferences_service.dart';

class RoleAdaptiveStatsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final roleService = RoleBasedPreferencesService.instance;
    final preferences = roleService.currentUserPreferences;
    
    if (preferences == null) {
      return const CircularProgressIndicator();
    }
    
    switch (preferences.userRole) {
      case UserRole.admin:
        return _buildAdminStats();
      case UserRole.projectManager:
        return _buildProjectManagerStats();
      case UserRole.teamMember:
        return _buildTeamMemberStats();
    }
  }
  
  Widget _buildAdminStats() {
    return Column(
      children: [
        StatCard(title: 'Total Usuarios', value: '150'),
        StatCard(title: 'Total Proyectos', value: '45'),
        StatCard(title: 'Workspaces Activos', value: '12'),
      ],
    );
  }
  
  Widget _buildProjectManagerStats() {
    return Column(
      children: [
        StatCard(title: 'Mis Proyectos', value: '8'),
        StatCard(title: 'Tareas Pendientes', value: '23'),
        StatCard(title: 'Team Members', value: '15'),
      ],
    );
  }
  
  Widget _buildTeamMemberStats() {
    return Column(
      children: [
        StatCard(title: 'Mis Tareas', value: '12'),
        StatCard(title: 'Completadas Hoy', value: '5'),
        StatCard(title: 'En Progreso', value: '3'),
      ],
    );
  }
}
```

### Caso 4: Onboarding Basado en Rol

```dart
// En OnboardingScreen o FirstTimeUserExperience
import 'package:creapolis_app/core/services/role_based_preferences_service.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _roleService = RoleBasedPreferencesService.instance;
  
  List<OnboardingPage> _getOnboardingPages() {
    final preferences = _roleService.currentUserPreferences;
    
    if (preferences == null) {
      return _getDefaultPages();
    }
    
    switch (preferences.userRole) {
      case UserRole.admin:
        return [
          OnboardingPage(
            title: 'Bienvenido Administrador',
            description: 'Tienes acceso completo a todas las funciones',
            image: 'assets/admin_welcome.png',
          ),
          OnboardingPage(
            title: 'Gestiona Usuarios',
            description: 'Puedes añadir, editar y eliminar usuarios',
            image: 'assets/manage_users.png',
          ),
          // ... más páginas para admin
        ];
        
      case UserRole.projectManager:
        return [
          OnboardingPage(
            title: 'Bienvenido Gestor',
            description: 'Coordina proyectos y equipos eficientemente',
            image: 'assets/pm_welcome.png',
          ),
          // ... más páginas para PM
        ];
        
      case UserRole.teamMember:
        return [
          OnboardingPage(
            title: 'Bienvenido al Equipo',
            description: 'Colabora y completa tus tareas',
            image: 'assets/member_welcome.png',
          ),
          // ... más páginas para team member
        ];
    }
  }
}
```

### Caso 5: Notificaciones Basadas en Rol

```dart
// En NotificationService
import 'package:creapolis_app/core/services/role_based_preferences_service.dart';

class NotificationService {
  final RoleBasedPreferencesService _roleService;
  
  Future<void> sendNotification(String message, {String? actionUrl}) async {
    final preferences = _roleService.currentUserPreferences;
    
    if (preferences == null) return;
    
    // Personalizar notificación según el rol
    final notification = _buildRoleBasedNotification(
      preferences.userRole,
      message,
      actionUrl,
    );
    
    await _showNotification(notification);
  }
  
  NotificationConfig _buildRoleBasedNotification(
    UserRole role,
    String message,
    String? actionUrl,
  ) {
    switch (role) {
      case UserRole.admin:
        return NotificationConfig(
          title: '🔔 Admin',
          message: message,
          priority: NotificationPriority.high,
          actionUrl: actionUrl,
        );
        
      case UserRole.projectManager:
        return NotificationConfig(
          title: '📋 Proyecto',
          message: message,
          priority: NotificationPriority.medium,
          actionUrl: actionUrl,
        );
        
      case UserRole.teamMember:
        return NotificationConfig(
          title: '✅ Tarea',
          message: message,
          priority: NotificationPriority.normal,
          actionUrl: actionUrl,
        );
    }
  }
}
```

---

## 🔧 Helpers y Utilities

### Helper para Iconos y Colores por Rol

```dart
// En core/utils/role_helpers.dart
import 'package:flutter/material.dart';
import 'package:creapolis_app/domain/entities/user.dart';

class RoleHelpers {
  static IconData getIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.projectManager:
        return Icons.manage_accounts;
      case UserRole.teamMember:
        return Icons.person;
    }
  }
  
  static Color getColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.projectManager:
        return Colors.blue;
      case UserRole.teamMember:
        return Colors.green;
    }
  }
  
  static String getDisplayName(UserRole role) {
    return role.displayName;
  }
  
  static String getDescription(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Acceso completo a todas las funciones del sistema';
      case UserRole.projectManager:
        return 'Gestiona proyectos y coordina equipos';
      case UserRole.teamMember:
        return 'Colabora en proyectos y completa tareas';
    }
  }
}
```

### Extension para UserRole

```dart
// En domain/entities/user.dart
extension UserRoleExtension on UserRole {
  IconData get icon {
    switch (this) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.projectManager:
        return Icons.manage_accounts;
      case UserRole.teamMember:
        return Icons.person;
    }
  }
  
  Color get color {
    switch (this) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.projectManager:
        return Colors.blue;
      case UserRole.teamMember:
        return Colors.green;
    }
  }
  
  String get description {
    switch (this) {
      case UserRole.admin:
        return 'Acceso completo a todas las funciones';
      case UserRole.projectManager:
        return 'Gestiona proyectos y coordina equipos';
      case UserRole.teamMember:
        return 'Colabora en proyectos y completa tareas';
    }
  }
  
  bool get canManageUsers => this == UserRole.admin;
  bool get canCreateProjects => this != UserRole.teamMember;
  bool get canDeleteProjects => this == UserRole.admin;
}

// Uso:
final user = currentUser;
print(user.role.displayName);  // "Administrador"
print(user.role.description);  // "Acceso completo..."
if (user.role.canManageUsers) {
  // Mostrar opción de gestión de usuarios
}
```

---

## 🎨 Widgets Reutilizables

### RoleBadge Widget

```dart
// En presentation/widgets/common/role_badge.dart
import 'package:flutter/material.dart';
import 'package:creapolis_app/domain/entities/user.dart';

class RoleBadge extends StatelessWidget {
  final UserRole role;
  final bool showIcon;
  
  const RoleBadge({
    Key? key,
    required this.role,
    this.showIcon = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: role.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: role.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(role.icon, size: 16, color: role.color),
            const SizedBox(width: 4),
          ],
          Text(
            role.displayName,
            style: TextStyle(
              color: role.color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Uso:
RoleBadge(role: user.role)
```

### CustomizationIndicator Widget

```dart
// En presentation/widgets/common/customization_indicator.dart
import 'package:flutter/material.dart';

class CustomizationIndicator extends StatelessWidget {
  final bool isCustomized;
  
  const CustomizationIndicator({
    Key? key,
    required this.isCustomized,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (!isCustomized) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 12, color: Colors.green.shade900),
          const SizedBox(width: 4),
          Text(
            'Personalizado',
            style: TextStyle(
              color: Colors.green.shade900,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Uso:
final preferences = roleService.currentUserPreferences;
CustomizationIndicator(isCustomized: preferences?.hasThemeOverride ?? false)
```

---

## 🧪 Testing con Roles

### Setup de Tests

```dart
// En test/helpers/test_helpers.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:creapolis_app/core/services/role_based_preferences_service.dart';
import 'package:creapolis_app/domain/entities/user.dart';

Future<void> setupTestWithRole(UserRole role) async {
  SharedPreferences.setMockInitialValues({});
  
  final service = RoleBasedPreferencesService.instance;
  await service.init();
  await service.loadUserPreferences(role);
}

Future<void> setupTestWithCustomizedRole(
  UserRole role, {
  String? themeOverride,
  DashboardConfig? dashboardOverride,
}) async {
  await setupTestWithRole(role);
  
  final service = RoleBasedPreferencesService.instance;
  
  if (themeOverride != null) {
    await service.setThemeOverride(themeOverride);
  }
  
  if (dashboardOverride != null) {
    await service.setDashboardOverride(dashboardOverride);
  }
}
```

### Widget Test con Roles

```dart
// En test/presentation/screens/dashboard_screen_test.dart
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('DashboardScreen Role-Based Tests', () {
    testWidgets('Admin ve 6 widgets por defecto', (tester) async {
      await setupTestWithRole(UserRole.admin);
      
      await tester.pumpWidget(
        MaterialApp(home: DashboardScreen()),
      );
      
      expect(find.byType(DashboardWidget), findsNWidgets(6));
    });
    
    testWidgets('Team Member ve 4 widgets por defecto', (tester) async {
      await setupTestWithRole(UserRole.teamMember);
      
      await tester.pumpWidget(
        MaterialApp(home: DashboardScreen()),
      );
      
      expect(find.byType(DashboardWidget), findsNWidgets(4));
    });
  });
}
```

---

## 📊 Analytics por Rol

### Tracking de Uso

```dart
// En analytics_service.dart
import 'package:creapolis_app/core/services/role_based_preferences_service.dart';

class AnalyticsService {
  final RoleBasedPreferencesService _roleService;
  
  Future<void> trackEvent(String eventName, Map<String, dynamic> properties) async {
    final preferences = _roleService.currentUserPreferences;
    
    if (preferences != null) {
      // Añadir información del rol a todos los eventos
      properties['user_role'] = preferences.userRole.name;
      properties['has_customizations'] = 
          preferences.hasThemeOverride ||
          preferences.hasLayoutOverride ||
          preferences.hasDashboardOverride;
    }
    
    await _sendEvent(eventName, properties);
  }
  
  Future<void> trackCustomization(String customizationType) async {
    await trackEvent('customization_changed', {
      'customization_type': customizationType,
    });
  }
}
```

---

## 🚨 Manejo de Errores

### Error Handling

```dart
// En cualquier lugar donde uses el servicio
import 'package:creapolis_app/core/services/role_based_preferences_service.dart';

Future<void> loadUserPreferencesSafely(UserRole role) async {
  final service = RoleBasedPreferencesService.instance;
  
  try {
    final preferences = await service.loadUserPreferences(role);
    
    // Usar preferencias
    _applyPreferences(preferences);
  } catch (e) {
    // Log error
    AppLogger.error('Error al cargar preferencias', e);
    
    // Mostrar mensaje al usuario
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error al cargar configuración. Usando valores por defecto.'),
      ),
    );
    
    // Usar defaults
    _applyDefaultConfiguration();
  }
}
```

---

## 📝 Checklist de Integración

- [ ] Inicializar servicio en main.dart
- [ ] Cargar preferencias al login
- [ ] Aplicar configuración en ThemeProvider
- [ ] Aplicar configuración en DashboardScreen
- [ ] Añadir navegación a RoleBasedPreferencesScreen
- [ ] Añadir RoleBadge en ProfileScreen
- [ ] Implementar helpers de rol
- [ ] Añadir tests para diferentes roles
- [ ] Implementar analytics por rol
- [ ] Documentar uso en README del equipo

---

**Fecha**: 13 de Octubre, 2025  
**Versión**: 1.0  
**Para**: Equipo de Desarrollo Creapolis
