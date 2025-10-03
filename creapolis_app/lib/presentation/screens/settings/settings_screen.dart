import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/calendar_event.dart' as domain;
import '../../../injection.dart';
import '../../bloc/calendar/calendar_bloc.dart';
import '../../bloc/calendar/calendar_event.dart';
import '../../bloc/calendar/calendar_state.dart';

/// Pantalla de configuración
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<CalendarBloc>()..add(const LoadConnectionStatusEvent()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Configuración')),
        body: ListView(
          children: [
            // Sección de Integraciones
            _IntegrationsSection(),
            const Divider(),

            // Otras secciones de configuración pueden ir aquí
            _buildSection(
              context,
              title: 'Notificaciones',
              icon: Icons.notifications,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Configuración de notificaciones próximamente',
                    ),
                  ),
                );
              },
            ),
            _buildSection(
              context,
              title: 'Perfil',
              icon: Icons.person,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Configuración de perfil próximamente'),
                  ),
                );
              },
            ),
            _buildSection(
              context,
              title: 'Acerca de',
              icon: Icons.info,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Información de la app próximamente'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

/// Sección de integraciones
class _IntegrationsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.integration_instructions, color: colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Integraciones',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Google Calendar Integration
        BlocConsumer<CalendarBloc, CalendarState>(
          listener: (context, state) {
            if (state is CalendarConnecting) {
              _launchAuthUrl(context, state.authUrl);
            } else if (state is CalendarConnected) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Google Calendar conectado exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
              // Recargar estado
              context.read<CalendarBloc>().add(
                const LoadConnectionStatusEvent(),
              );
            } else if (state is CalendarDisconnected) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Google Calendar desconectado')),
              );
              // Recargar estado
              context.read<CalendarBloc>().add(
                const LoadConnectionStatusEvent(),
              );
            } else if (state is CalendarError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: colorScheme.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is CalendarLoading) {
              return const ListTile(
                leading: CircularProgressIndicator(),
                title: Text('Cargando...'),
              );
            }

            domain.CalendarConnection? connection;
            if (state is ConnectionStatusLoaded) {
              connection = state.connection;
            } else if (state is CalendarEventsLoaded) {
              connection = state.connection;
            } else if (state is CalendarConnected) {
              connection = state.connection;
            }

            final isConnected = connection?.isConnected ?? false;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Logo de Google Calendar
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Icon(
                            Icons.calendar_today,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Información
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Google Calendar',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (connection?.userEmail != null)
                                Text(
                                  connection!.userEmail!,
                                  style: theme.textTheme.bodySmall,
                                )
                              else
                                Text(
                                  'Sincroniza tus eventos y disponibilidad',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Badge de estado
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isConnected
                                ? Colors.green.shade100
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isConnected ? Icons.check_circle : Icons.circle,
                                size: 14,
                                color: isConnected ? Colors.green : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isConnected ? 'Conectado' : 'Desconectado',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isConnected
                                      ? Colors.green
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Botón de acción
                    SizedBox(
                      width: double.infinity,
                      child: isConnected
                          ? OutlinedButton.icon(
                              onPressed: () => _confirmDisconnect(context),
                              icon: const Icon(Icons.link_off),
                              label: const Text('Desconectar'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorScheme.error,
                              ),
                            )
                          : FilledButton.icon(
                              onPressed: () {
                                context.read<CalendarBloc>().add(
                                  const ConnectCalendarEvent(),
                                );
                              },
                              icon: const Icon(Icons.link),
                              label: const Text('Conectar Google Calendar'),
                            ),
                    ),

                    // Información adicional si está conectado
                    if (isConnected && connection?.connectedAt != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Conectado el ${_formatDate(connection!.connectedAt!)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Abrir URL de autorización en el navegador
  Future<void> _launchAuthUrl(BuildContext context, String authUrl) async {
    AppLogger.info('SettingsScreen: Abriendo URL de autorización');

    final uri = Uri.parse(authUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);

      // Mostrar diálogo para ingresar código manualmente
      if (context.mounted) {
        _showOAuthCodeDialog(context);
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el navegador'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Mostrar diálogo para ingresar código OAuth
  void _showOAuthCodeDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Autorización de Google Calendar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Se ha abierto tu navegador. Por favor autoriza la aplicación y copia el código de autorización aquí:',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Código de autorización',
                border: OutlineInputBorder(),
                hintText: 'Pega el código aquí',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<CalendarBloc>().add(
                const LoadConnectionStatusEvent(),
              );
            },
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final code = controller.text.trim();
              if (code.isNotEmpty) {
                Navigator.of(dialogContext).pop();
                context.read<CalendarBloc>().add(CompleteOAuthEvent(code));
              }
            },
            child: const Text('Conectar'),
          ),
        ],
      ),
    );
  }

  /// Confirmar desconexión
  Future<void> _confirmDisconnect(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Desconectar Google Calendar'),
        content: const Text(
          '¿Estás seguro de que deseas desconectar Google Calendar?\n\n'
          'Perderás el acceso a los eventos sincronizados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Desconectar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<CalendarBloc>().add(const DisconnectCalendarEvent());
    }
  }

  /// Formatear fecha
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
