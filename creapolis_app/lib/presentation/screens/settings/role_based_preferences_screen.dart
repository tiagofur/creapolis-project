import 'package:flutter/material.dart';

import '../../../core/services/dashboard_preferences_service.dart';
import '../../../core/services/role_based_preferences_service.dart';
import '../../../domain/entities/role_based_ui_config.dart';
import '../../../domain/entities/user.dart';

/// Pantalla de configuración de preferencias basadas en rol
///
/// Permite al usuario:
/// - Ver la configuración base de su rol
/// - Personalizar tema, layout y widgets
/// - Ver indicadores de qué está usando defaults vs overrides
/// - Resetear a los defaults del rol
class RoleBasedPreferencesScreen extends StatefulWidget {
  const RoleBasedPreferencesScreen({super.key});

  @override
  State<RoleBasedPreferencesScreen> createState() =>
      _RoleBasedPreferencesScreenState();
}

class _RoleBasedPreferencesScreenState
    extends State<RoleBasedPreferencesScreen> {
  final _roleService = RoleBasedPreferencesService.instance;
  final _dashboardService = DashboardPreferencesService.instance;

  UserUIPreferences? _userPreferences;
  RoleBasedUIConfig? _roleConfig;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);

    try {
      _userPreferences = _roleService.currentUserPreferences;
      if (_userPreferences == null) {
        // Si no hay preferencias cargadas, usar un default
        _userPreferences = UserUIPreferences(userRole: UserRole.teamMember);
      }
      _roleConfig = _roleService.getRoleBaseConfig();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar preferencias: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resetToRoleDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetear Configuración'),
        content: const Text(
          '¿Deseas resetear toda tu configuración a los valores por defecto de tu rol?\n\n'
          'Esto eliminará todas tus personalizaciones.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Resetear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _roleService.resetToRoleDefaults();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Configuración reseteada correctamente'
                  : 'Error al resetear configuración',
            ),
          ),
        );
        if (success) {
          _loadPreferences();
        }
      }
    }
  }

  Future<void> _toggleThemeOverride() async {
    if (_userPreferences == null) return;

    if (_userPreferences!.hasThemeOverride) {
      // Quitar override
      await _roleService.clearThemeOverride();
    } else {
      // Poner override al valor opuesto del default
      final defaultTheme = _roleConfig?.themeModeDefault ?? 'system';
      final newTheme = defaultTheme == 'light' ? 'dark' : 'light';
      await _roleService.setThemeOverride(newTheme);
    }

    _loadPreferences();
  }

  Future<void> _toggleDashboardOverride() async {
    if (_userPreferences == null) return;

    if (_userPreferences!.hasDashboardOverride) {
      // Quitar override
      await _roleService.clearDashboardOverride();
    } else {
      // Poner override con la configuración actual del dashboard
      final currentConfig = _dashboardService.getDashboardConfig();
      await _roleService.setDashboardOverride(currentConfig);
    }

    _loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Preferencias por Rol'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_userPreferences == null || _roleConfig == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Preferencias por Rol'),
        ),
        body: const Center(
          child: Text('No se pudieron cargar las preferencias'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferencias por Rol'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Resetear a defaults del rol',
            onPressed: _resetToRoleDefaults,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildRoleInfoCard(),
          const SizedBox(height: 16),
          _buildThemePreferenceCard(),
          const SizedBox(height: 16),
          _buildDashboardPreferenceCard(),
          const SizedBox(height: 16),
          _buildHelpCard(),
        ],
      ),
    );
  }

  Widget _buildRoleInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getRoleIcon(_userPreferences!.userRole),
                  color: _getRoleColor(_userPreferences!.userRole),
                ),
                const SizedBox(width: 8),
                Text(
                  'Tu Rol: ${_userPreferences!.userRole.displayName}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getRoleDescription(_userPreferences!.userRole),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tu rol determina la configuración base de la interfaz. '
                      'Puedes personalizarla según tus preferencias.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemePreferenceCard() {
    final hasOverride = _userPreferences!.hasThemeOverride;
    final effectiveTheme = _userPreferences!.getEffectiveThemeMode();
    final defaultTheme = _roleConfig!.themeModeDefault;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.palette),
                const SizedBox(width: 8),
                Text(
                  'Tema',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (hasOverride)
                  Chip(
                    label: const Text('Personalizado'),
                    backgroundColor: Colors.green.shade100,
                    labelStyle: TextStyle(
                      color: Colors.green.shade900,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(
                _getThemeIcon(effectiveTheme),
                color: hasOverride ? Colors.green : Colors.grey,
              ),
              title: Text(
                'Tema actual: ${_getThemeLabel(effectiveTheme)}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                hasOverride
                    ? 'Estás usando tu personalización (default: ${_getThemeLabel(defaultTheme)})'
                    : 'Usando el default de tu rol',
              ),
              trailing: IconButton(
                icon: Icon(hasOverride ? Icons.clear : Icons.edit),
                tooltip: hasOverride
                    ? 'Volver a default del rol'
                    : 'Personalizar tema',
                onPressed: _toggleThemeOverride,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardPreferenceCard() {
    final hasOverride = _userPreferences!.hasDashboardOverride;
    final effectiveConfig = _userPreferences!.getEffectiveDashboardConfig();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.dashboard),
                const SizedBox(width: 8),
                Text(
                  'Dashboard',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (hasOverride)
                  Chip(
                    label: const Text('Personalizado'),
                    backgroundColor: Colors.green.shade100,
                    labelStyle: TextStyle(
                      color: Colors.green.shade900,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(
                Icons.widgets,
                color: hasOverride ? Colors.green : Colors.grey,
              ),
              title: Text(
                '${effectiveConfig.widgets.length} widgets configurados',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                hasOverride
                    ? 'Estás usando tu personalización'
                    : 'Usando el dashboard por defecto de tu rol',
              ),
              trailing: IconButton(
                icon: Icon(hasOverride ? Icons.clear : Icons.edit),
                tooltip: hasOverride
                    ? 'Volver a default del rol'
                    : 'Personalizar dashboard',
                onPressed: _toggleDashboardOverride,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: effectiveConfig.widgets
                  .take(6)
                  .map(
                    (w) => Chip(
                      label: Text(
                        w.type.displayName,
                        style: const TextStyle(fontSize: 11),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpCard() {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.help_outline, color: Colors.amber.shade900),
                const SizedBox(width: 8),
                Text(
                  '¿Cómo funciona?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.amber.shade900,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildHelpItem(
              '1. Configuración Base',
              'Cada rol tiene una configuración por defecto optimizada.',
            ),
            const SizedBox(height: 8),
            _buildHelpItem(
              '2. Personalización',
              'Puedes cambiar cualquier configuración según tus preferencias.',
            ),
            const SizedBox(height: 8),
            _buildHelpItem(
              '3. Indicadores',
              'Los elementos "Personalizado" muestran qué has modificado.',
            ),
            const SizedBox(height: 8),
            _buildHelpItem(
              '4. Resetear',
              'Usa el botón de resetear para volver a los defaults del rol.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '•',
          style: TextStyle(
            fontSize: 20,
            color: Colors.amber.shade900,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.amber.shade900,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.amber.shade800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.projectManager:
        return Icons.manage_accounts;
      case UserRole.teamMember:
        return Icons.person;
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.projectManager:
        return Colors.blue;
      case UserRole.teamMember:
        return Colors.green;
    }
  }

  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Tienes acceso completo a todas las funciones y configuraciones del sistema.';
      case UserRole.projectManager:
        return 'Gestionas proyectos y coordinas equipos. Tu dashboard prioriza la gestión.';
      case UserRole.teamMember:
        return 'Colaboras en proyectos y completas tareas. Tu dashboard se enfoca en el trabajo diario.';
    }
  }

  IconData _getThemeIcon(String theme) {
    switch (theme) {
      case 'light':
        return Icons.light_mode;
      case 'dark':
        return Icons.dark_mode;
      case 'system':
        return Icons.settings_brightness;
      default:
        return Icons.palette;
    }
  }

  String _getThemeLabel(String theme) {
    switch (theme) {
      case 'light':
        return 'Claro';
      case 'dark':
        return 'Oscuro';
      case 'system':
        return 'Sistema';
      default:
        return theme;
    }
  }
}
