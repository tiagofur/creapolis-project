import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:creapolis_app/l10n/app_localizations.dart';
import '../../../core/utils/app_logger.dart';
import '../../../routes/app_router.dart';
import '../../../routes/route_builder.dart';
import '../../screens/settings/notification_preferences_screen.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../providers/locale_provider.dart';

/// Pantalla del menú More con opciones adicionales.
///
/// Accesible desde: Bottom Navigation > Más
///
/// Opciones disponibles:
/// - Workspaces (gestionar workspaces)
/// - Invitaciones (ver invitaciones pendientes)
/// - Configuración (ajustes de la app)
/// - Acerca de (información de la app)
/// - Cerrar sesión
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.moreTitle)),
      body: ListView(
        children: [
          // Header con avatar y nombre de usuario
          _buildUserHeader(context),
          const Divider(),

          // Sección de Gestión
          _buildSectionHeader(context, l10n.managementSection),
          _buildMenuItem(
            context,
            icon: Icons.business,
            title: l10n.workspacesTitle,
            subtitle: l10n.workspacesSubtitle,
            onTap: () => context.goToWorkspaces(),
          ),
          _buildMenuItem(
            context,
            icon: Icons.mail_outline,
            title: l10n.invitationsTitle,
            subtitle: l10n.invitationsSubtitle,
            onTap: () => context.goToInvitations(),
          ),

          const Divider(),

          // Sección de Configuración
          _buildSectionHeader(context, l10n.settingsTitle),
          _buildMenuItem(
            context,
            icon: Icons.settings,
            title: l10n.settingsTitle,
            subtitle: l10n.settingsSubtitle,
            onTap: () => context.goToSettings(),
          ),
          _buildMenuItem(
            context,
            icon: Icons.notifications_outlined,
            title: l10n.notificationsTitle,
            subtitle: l10n.notificationsSubtitle,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const NotificationPreferencesScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.language,
            title: l10n.languageTitle,
            subtitle: _currentLanguageLabel(context),
            onTap: () => _showLanguageDialog(context),
          ),
          _buildMenuItem(
            context,
            icon: Icons.palette_outlined,
            title: l10n.themeTitle,
            subtitle: l10n.themeSubtitle,
            onTap: () {
              context.goToSettings();
            },
          ),

          const Divider(),

          // Sección de Información
          _buildSectionHeader(context, l10n.infoSection),
          _buildMenuItem(
            context,
            icon: Icons.analytics_outlined,
            title: l10n.customizationMetricsTitle,
            subtitle: l10n.customizationMetricsSubtitle,
            onTap: () => context.go(RoutePaths.customizationMetrics),
          ),
          _buildMenuItem(
            context,
            icon: Icons.info_outline,
            title: l10n.aboutTitle,
            subtitle: l10n.aboutSubtitle,
            onTap: () => _showAboutDialog(context),
          ),
          _buildMenuItem(
            context,
            icon: Icons.help_outline,
            title: l10n.helpTitle,
            subtitle: l10n.helpSubtitle,
            onTap: () {
              _showHelpDialog(context);
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.privacy_tip_outlined,
            title: l10n.privacyTitle,
            subtitle: l10n.privacySubtitle,
            onTap: () {
              _showPrivacyDialog(context);
            },
          ),

          const Divider(),

          // Botón de cerrar sesión
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: OutlinedButton.icon(
              onPressed: () => _handleLogout(context),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: Text(
                l10n.logout,
                style: const TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          // Versión de la app
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Creapolis v1.0.0',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Header con información del usuario
  Widget _buildUserHeader(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final authState = context.watch<AuthBloc>().state;
    final String userName =
        authState is AuthAuthenticated ? authState.user.name : 'Usuario';
    final String userEmail =
        authState is AuthAuthenticated ? authState.user.email : 'usuario@example.com';

    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(
              Icons.person,
              size: 32,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.go(RoutePaths.profile),
            icon: const Icon(Icons.edit),
            tooltip: l10n.editProfile,
          ),
        ],
      ),
    );
  }

  /// Header de sección
  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Item del menú
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  /// Mostrar diálogo de About
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppLocalizations.of(context)?.appName ?? 'Creapolis',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.business,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
      applicationLegalese: AppLocalizations.of(context)?.applicationLegalese ?? '© 2025 Creapolis. Todos los derechos reservados.',
      children: [
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context)?.aboutContent ?? 'Creapolis es una herramienta de gestión de proyectos y tareas diseñada para ayudar a equipos a colaborar de manera efectiva.'),
      ],
    );
  }

  /// Manejar cierre de sesión
  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.logout ?? 'Cerrar Sesión'),
        content: Text(AppLocalizations.of(context)?.confirmLogoutMessage ?? '¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)?.logout ?? 'Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      AppLogger.info('MoreScreen: Usuario cerrando sesión');
      await AppRouter.logout(context);
    }
  }
  void _showHelpDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.helpTitle ?? 'Centro de ayuda'),
        content: Text(AppLocalizations.of(context)?.helpContent ?? 'Visita nuestro centro de ayuda para guías y soporte. Próximamente integraremos enlaces directos desde la app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.close ?? 'Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.privacyTitle ?? 'Política de privacidad'),
        content: SingleChildScrollView(child: Text(AppLocalizations.of(context)?.privacyContent ?? '')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.close ?? 'Cerrar'),
          ),
        ],
      ),
    );
  }

  String _currentLanguageLabel(BuildContext context) {
    final locale = context.read<LocaleProvider>().locale;
    final l10n = AppLocalizations.of(context)!;
    if (locale == null) return l10n.systemLanguageLabel;
    switch (locale.languageCode) {
      case 'es':
        return l10n.spanishLabel;
      case 'en':
        return l10n.englishLabel;
      default:
        return locale.toLanguageTag();
    }
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.selectLanguageTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageTile(
              label: l10n.systemLanguageLabel,
              selected: context.read<LocaleProvider>().locale == null,
              onTap: () {
                context.read<LocaleProvider>().setLocale(null);
                Navigator.of(dialogContext).pop();
              },
            ),
            _LanguageTile(
              label: l10n.spanishLabel,
              selected: context.read<LocaleProvider>().locale?.languageCode == 'es',
              onTap: () {
                context.read<LocaleProvider>().setLocale(const Locale('es'));
                Navigator.of(dialogContext).pop();
              },
            ),
            _LanguageTile(
              label: l10n.englishLabel,
              selected: context.read<LocaleProvider>().locale?.languageCode == 'en',
              onTap: () {
                context.read<LocaleProvider>().setLocale(const Locale('en'));
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

}

class _LanguageTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(label),
      onTap: onTap,
    );
  }
}
