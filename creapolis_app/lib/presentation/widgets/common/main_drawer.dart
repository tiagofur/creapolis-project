import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_logger.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../providers/workspace_context.dart';

/// Drawer principal de la aplicación con navegación y selector de workspace
class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Drawer(
      child: Column(
        children: [
          // Header con workspace activo
          _buildHeader(context),
          
          // Navegación principal
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavigationSection(context),
                const Divider(),
                _buildWorkspaceSection(context),
                const Divider(),
                _buildSettingsSection(context),
              ],
            ),
          ),
          
          // Footer con logout
          _buildFooter(context),
        ],
      ),
    );
  }

  /// Header con workspace activo
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Consumer<WorkspaceContext>(
      builder: (context, workspaceContext, _) {
        final activeWorkspace = workspaceContext.activeWorkspace;
        
        return DrawerHeader(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App title
              Text(
                'Creapolis',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Workspace activo
              if (activeWorkspace != null) ...[
                Text(
                  'Workspace Activo:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimary.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: colorScheme.onPrimary,
                      child: Text(
                        activeWorkspace.initials,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activeWorkspace.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            activeWorkspace.userRole.displayName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onPrimary.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Botón cambiar workspace
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cerrar drawer
                    context.push('/workspaces');
                  },
                  icon: Icon(
                    Icons.swap_horiz,
                    size: 16,
                    color: colorScheme.onPrimary,
                  ),
                  label: Text(
                    'Cambiar Workspace',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 12,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colorScheme.onPrimary),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: const Size(0, 32),
                  ),
                ),
              ] else ...[
                Text(
                  'Sin workspace activo',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push('/workspaces');
                  },
                  icon: Icon(
                    Icons.add,
                    size: 16,
                    color: colorScheme.onPrimary,
                  ),
                  label: Text(
                    'Seleccionar Workspace',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 12,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colorScheme.onPrimary),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: const Size(0, 32),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Sección de navegación principal
  Widget _buildNavigationSection(BuildContext context) {
    return Column(
      children: [
        _buildDrawerItem(
          context,
          icon: Icons.dashboard_outlined,
          title: 'Dashboard',
          onTap: () => _navigateTo(context, '/projects'),
        ),
        _buildDrawerItem(
          context,
          icon: Icons.folder_outlined,
          title: 'Proyectos',
          onTap: () => _navigateTo(context, '/projects'),
        ),
        _buildDrawerItem(
          context,
          icon: Icons.assignment_outlined,
          title: 'Mis Tareas',
          onTap: () => _navigateTo(context, '/tasks'),
        ),
        _buildDrawerItem(
          context,
          icon: Icons.access_time_outlined,
          title: 'Time Tracking',
          onTap: () => _navigateTo(context, '/time-tracking'),
        ),
        _buildDrawerItem(
          context,
          icon: Icons.calendar_today_outlined,
          title: 'Calendario',
          onTap: () => _navigateTo(context, '/calendar'),
        ),
      ],
    );
  }

  /// Sección de workspace y equipo
  Widget _buildWorkspaceSection(BuildContext context) {
    return Consumer<WorkspaceContext>(
      builder: (context, workspaceContext, _) {
        final hasWorkspace = workspaceContext.hasActiveWorkspace;
        
        return Column(
          children: [
            // Título de sección
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.group_outlined,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Equipo',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            
            if (hasWorkspace) ...[
              _buildDrawerItem(
                context,
                icon: Icons.people_outline,
                title: 'Miembros del Workspace',
                onTap: () => _navigateTo(context, '/workspace/${workspaceContext.activeWorkspace!.id}/members'),
              ),
              if (workspaceContext.canInviteMembers)
                _buildDrawerItem(
                  context,
                  icon: Icons.person_add_outlined,
                  title: 'Invitar Miembros',
                  onTap: () => _navigateTo(context, '/workspace/${workspaceContext.activeWorkspace!.id}/invite'),
                ),
              if (workspaceContext.canManageSettings)
                _buildDrawerItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: 'Configuración Workspace',
                  onTap: () => _navigateTo(context, '/workspace/${workspaceContext.activeWorkspace!.id}/settings'),
                ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Selecciona un workspace para ver opciones del equipo',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
            
            _buildDrawerItem(
              context,
              icon: Icons.mail_outline,
              title: 'Mis Invitaciones',
              onTap: () => _navigateTo(context, '/invitations'),
            ),
          ],
        );
      },
    );
  }

  /// Sección de configuración
  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      children: [
        _buildDrawerItem(
          context,
          icon: Icons.settings_outlined,
          title: 'Preferencias',
          onTap: () => _navigateTo(context, '/settings'),
        ),
        _buildDrawerItem(
          context,
          icon: Icons.help_outline,
          title: 'Ayuda',
          onTap: () => _navigateTo(context, '/help'),
        ),
        _buildDrawerItem(
          context,
          icon: Icons.info_outline,
          title: 'Acerca de',
          onTap: () => _navigateTo(context, '/about'),
        ),
      ],
    );
  }

  /// Footer con logout
  Widget _buildFooter(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: _buildDrawerItem(
        context,
        icon: Icons.logout,
        title: 'Cerrar Sesión',
        iconColor: colorScheme.error,
        textColor: colorScheme.error,
        onTap: () => _logout(context),
      ),
    );
  }

  /// Construir item del drawer
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: textColor ?? theme.colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  /// Navegar y cerrar drawer
  void _navigateTo(BuildContext context, String route) {
    Navigator.of(context).pop(); // Cerrar drawer
    context.push(route);
  }

  /// Logout
  void _logout(BuildContext context) {
    Navigator.of(context).pop(); // Cerrar drawer
    
    // Mostrar confirmación
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar diálogo
              AppLogger.info('[MainDrawer] Cerrando sesión del usuario');
              context.read<AuthBloc>().add(LogoutEvent());
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
