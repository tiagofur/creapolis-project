import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_logger.dart';
import '../../../routes/app_router.dart';
import '../../../routes/route_builder.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Más opciones')),
      body: ListView(
        children: [
          // Header con avatar y nombre de usuario
          _buildUserHeader(context),
          const Divider(),

          // Sección de Gestión
          _buildSectionHeader(context, 'Gestión'),
          _buildMenuItem(
            context,
            icon: Icons.business,
            title: 'Workspaces',
            subtitle: 'Gestionar workspaces',
            onTap: () => context.goToWorkspaces(),
          ),
          _buildMenuItem(
            context,
            icon: Icons.mail_outline,
            title: 'Invitaciones',
            subtitle: 'Ver invitaciones pendientes',
            onTap: () => context.goToInvitations(),
          ),

          const Divider(),

          // Sección de Configuración
          _buildSectionHeader(context, 'Configuración'),
          _buildMenuItem(
            context,
            icon: Icons.settings,
            title: 'Ajustes',
            subtitle: 'Configuración de la aplicación',
            onTap: () => context.goToSettings(),
          ),
          _buildMenuItem(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notificaciones',
            subtitle: 'Gestionar notificaciones',
            onTap: () {
              // TODO: Navegar a configuración de notificaciones
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Configuración de notificaciones - Por implementar',
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.palette_outlined,
            title: 'Tema',
            subtitle: 'Modo claro/oscuro',
            onTap: () {
              // TODO: Navegar a configuración de tema
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configuración de tema - Por implementar'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),

          const Divider(),

          // Sección de Información
          _buildSectionHeader(context, 'Información'),
          _buildMenuItem(
            context,
            icon: Icons.analytics_outlined,
            title: 'Métricas de Personalización',
            subtitle: 'Estadísticas de uso de UI',
            onTap: () => context.go(RoutePaths.customizationMetrics),
          ),
          _buildMenuItem(
            context,
            icon: Icons.info_outline,
            title: 'Acerca de',
            subtitle: 'Información de la aplicación',
            onTap: () => _showAboutDialog(context),
          ),
          _buildMenuItem(
            context,
            icon: Icons.help_outline,
            title: 'Ayuda',
            subtitle: 'Centro de ayuda y soporte',
            onTap: () {
              // TODO: Navegar a ayuda
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Centro de ayuda - Por implementar'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacidad',
            subtitle: 'Política de privacidad',
            onTap: () {
              // TODO: Mostrar política de privacidad
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Política de privacidad - Por implementar'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),

          const Divider(),

          // Botón de cerrar sesión
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: OutlinedButton.icon(
              onPressed: () => _handleLogout(context),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red),
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
                  'Usuario', // TODO: Obtener nombre real del usuario
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'usuario@example.com', // TODO: Obtener email real
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.push('/profile'),
            icon: const Icon(Icons.edit),
            tooltip: 'Editar perfil',
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
      applicationName: 'Creapolis',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.business,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
      applicationLegalese: '© 2025 Creapolis. Todos los derechos reservados.',
      children: [
        const SizedBox(height: 16),
        const Text(
          'Creapolis es una herramienta de gestión de proyectos y tareas '
          'diseñada para ayudar a equipos a colaborar de manera efectiva.',
        ),
      ],
    );
  }

  /// Manejar cierre de sesión
  Future<void> _handleLogout(BuildContext context) async {
    // Mostrar diálogo de confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      AppLogger.info('MoreScreen: Usuario cerrando sesión');
      await AppRouter.logout(context);
    }
  }
}
