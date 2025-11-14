import 'package:flutter/material.dart';
import 'package:creapolis_app/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/services/dashboard_preferences_service.dart';
import '../../../core/services/role_based_preferences_service.dart';
import '../../../domain/entities/dashboard_widget_config.dart';
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
      _userPreferences ??= UserUIPreferences(userRole: UserRole.teamMember);
      _roleConfig = _roleService.getRoleBaseConfig();
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.loadRolePrefsError(e.toString()) ?? 'Error al cargar preferencias: $e')),
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
        title: Text(AppLocalizations.of(context)?.resetConfigTitle ?? 'Resetear Configuración'),
        content: Text(AppLocalizations.of(context)?.resetConfigMessage ?? '¿Deseas resetear toda tu configuración a los valores por defecto de tu rol?\n\nEsto eliminará todas tus personalizaciones.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)?.reset ?? 'Resetear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _roleService.resetToRoleDefaults();
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? (l10n?.resetConfigSuccess ?? 'Configuración reseteada correctamente') : (l10n?.resetConfigError ?? 'Error al resetear configuración')),
          ),
        );
        if (success) {
          _loadPreferences();
        }
      }
    }
  }

  Future<void> _exportPreferences() async {
    final l10n = AppLocalizations.of(context);
    try {
      // Mostrar diálogo de carga
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      final filePath = await _roleService.exportPreferences();

      if (mounted) {
        Navigator.pop(context); // Cerrar diálogo de carga
      }

      if (filePath == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al exportar preferencias'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Mostrar diálogo con opciones de compartir o ver ubicación
      if (mounted) {
        final action = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)?.exportSuccessTitle ?? 'Exportación Exitosa'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)?.exportSuccessMessage ?? 'Tus preferencias han sido exportadas correctamente.'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    filePath,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'close'),
                child: Text(AppLocalizations.of(context)?.close ?? 'Cerrar'),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context, 'share'),
                icon: const Icon(Icons.share),
                label: Text(AppLocalizations.of(context)?.share ?? 'Compartir'),
              ),
            ],
          ),
        );

        if (action == 'share') {
          await Share.shareXFiles(
            [XFile(filePath)],
            subject: l10n?.shareSubject ?? 'Mis preferencias de Creapolis',
            text: l10n?.shareText ?? 'Archivo de preferencias exportado desde Creapolis',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Cerrar diálogo de carga si está abierto
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.exportPrefsError(e.toString()) ?? 'Error al exportar preferencias: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importPreferences() async {
    final l10n = AppLocalizations.of(context);
    try {
      // Mostrar advertencia antes de importar
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)?.importPrefsTitle ?? 'Importar Preferencias'),
          content: Text(AppLocalizations.of(context)?.importPrefsMessage ?? 'Importar preferencias reemplazará tu configuración actual.\n\n¿Deseas continuar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppLocalizations.of(context)?.continueLabel ?? 'Continuar'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Abrir selector de archivo
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: l10n?.selectPrefsFileTitle ?? 'Seleccionar archivo de preferencias',
      );

      if (result == null || result.files.isEmpty) {
        return; // Usuario canceló
      }

      final filePath = result.files.first.path;
      if (filePath == null) {
        if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.filePathError ?? 'No se pudo obtener la ruta del archivo'),
            backgroundColor: Colors.red,
          ),
        );
        }
        return;
      }

      // Mostrar diálogo de carga
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      final success = await _roleService.importPreferences(filePath);

      if (mounted) {
        Navigator.pop(context); // Cerrar diálogo de carga
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? (l10n?.importPrefsSuccess ?? 'Preferencias importadas correctamente') : (l10n?.importPrefsError ?? 'Error al importar preferencias - Verifica el archivo')),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );

        if (success) {
          _loadPreferences();
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Cerrar diálogo de carga si está abierto
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.importPrefsErrorDetail(e.toString()) ?? 'Error al importar preferencias: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
        appBar: AppBar(title: Text(AppLocalizations.of(context)?.rolePreferencesTitle ?? 'Preferencias por Rol')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_userPreferences == null || _roleConfig == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)?.rolePreferencesTitle ?? 'Preferencias por Rol')),
        body: const Center(
          child: Text('No se pudieron cargar las preferencias'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.rolePreferencesTitle ?? 'Preferencias por Rol'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: AppLocalizations.of(context)?.moreOptions ?? 'Más opciones',
            onSelected: (value) {
              switch (value) {
                case 'reset':
                  _resetToRoleDefaults();
                  break;
                case 'export':
                  _exportPreferences();
                  break;
                case 'import':
                  _importPreferences();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    const Icon(Icons.restore),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)?.resetToDefaults ?? 'Resetear a defaults'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    const Icon(Icons.upload_file),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)?.exportPreferences ?? 'Exportar preferencias'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    const Icon(Icons.download),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)?.importPreferences ?? 'Importar preferencias'),
                  ],
                ),
              ),
            ],
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
          _buildExportImportCard(),
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
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
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
                Text(AppLocalizations.of(context)?.themeTitle ?? 'Tema', style: Theme.of(context).textTheme.titleMedium),
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
                AppLocalizations.of(context)?.currentThemeLabel(_getThemeLabel(context, effectiveTheme)) ?? 'Tema actual: ${_getThemeLabel(context, effectiveTheme)}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                hasOverride
                    ? (AppLocalizations.of(context)?.usingCustomizationDefault(_getThemeLabel(context, defaultTheme)) ?? 'Estás usando tu personalización (default: ${_getThemeLabel(context, defaultTheme)})')
                    : (AppLocalizations.of(context)?.usingRoleDefault ?? 'Usando el default de tu rol'),
              ),
              trailing: IconButton(
                icon: Icon(hasOverride ? Icons.clear : Icons.edit),
                tooltip: hasOverride
                    ? (AppLocalizations.of(context)?.revertToRoleDefault ?? 'Volver a default del rol')
                    : (AppLocalizations.of(context)?.customizeTheme ?? 'Personalizar tema'),
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
                Text(AppLocalizations.of(context)?.dashboardTitle ?? 'Dashboard',
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
                AppLocalizations.of(context)?.widgetsConfigured(effectiveConfig.widgets.length) ?? '${effectiveConfig.widgets.length} widgets configurados',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                hasOverride
                    ? (AppLocalizations.of(context)?.usingCustomization ?? 'Estás usando tu personalización')
                    : (AppLocalizations.of(context)?.usingRoleDashboardDefault ?? 'Usando el dashboard por defecto de tu rol'),
              ),
              trailing: IconButton(
                icon: Icon(hasOverride ? Icons.clear : Icons.edit),
                tooltip: hasOverride
                    ? (AppLocalizations.of(context)?.revertToRoleDefault ?? 'Volver a default del rol')
                    : (AppLocalizations.of(context)?.customizeDashboard ?? 'Personalizar dashboard'),
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

  Widget _buildExportImportCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.import_export),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)?.exportImportTitle ?? 'Exportar / Importar',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context)?.exportImportDescription ?? 'Guarda o restaura tu configuración completa. Útil para respaldar preferencias o transferirlas entre dispositivos.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _exportPreferences,
                    icon: const Icon(Icons.upload_file, size: 20),
                    label: Text(AppLocalizations.of(context)?.export ?? 'Exportar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _importPreferences,
                    icon: const Icon(Icons.download, size: 20),
                    label: Text(AppLocalizations.of(context)?.import ?? 'Importar'),
                  ),
                ),
              ],
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
                Text(AppLocalizations.of(context)?.howItWorksTitle ?? '¿Cómo funciona?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildHelpItem(AppLocalizations.of(context)?.howItWorksStep1Title ?? '1. Configuración Base', AppLocalizations.of(context)?.howItWorksStep1Desc ?? 'Cada rol tiene una configuración por defecto optimizada.'),
            const SizedBox(height: 8),
            _buildHelpItem(AppLocalizations.of(context)?.howItWorksStep2Title ?? '2. Personalización', AppLocalizations.of(context)?.howItWorksStep2Desc ?? 'Puedes cambiar cualquier configuración según tus preferencias.'),
            const SizedBox(height: 8),
            _buildHelpItem(AppLocalizations.of(context)?.howItWorksStep3Title ?? '3. Indicadores', AppLocalizations.of(context)?.howItWorksStep3Desc ?? 'Los elementos "Personalizado" muestran qué has modificado.'),
            const SizedBox(height: 8),
            _buildHelpItem(AppLocalizations.of(context)?.howItWorksStep4Title ?? '4. Resetear', AppLocalizations.of(context)?.howItWorksStep4Desc ?? 'Usa el botón de resetear para volver a los defaults del rol.'),
            const SizedBox(height: 8),
            _buildHelpItem(AppLocalizations.of(context)?.howItWorksStep5Title ?? '5. Exportar/Importar', AppLocalizations.of(context)?.howItWorksStep5Desc ?? 'Respalda tu configuración o transfiérela entre dispositivos.'),
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
                style: TextStyle(fontSize: 12, color: Colors.amber.shade800),
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

  String _getThemeLabel(BuildContext context, String theme) {
    switch (theme) {
      case 'light':
        return AppLocalizations.of(context)?.themeLight ?? 'Claro';
      case 'dark':
        return AppLocalizations.of(context)?.themeDark ?? 'Oscuro';
      case 'system':
        return AppLocalizations.of(context)?.themeSystem ?? 'Sistema';
      default:
        return theme;
    }
  }
}



