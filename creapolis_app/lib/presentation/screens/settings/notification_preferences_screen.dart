import 'package:flutter/material.dart';

/// Pantalla de configuración de preferencias de notificación
class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  bool _isLoading = true;

  // Local state for switches
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _mentionNotifications = true;
  bool _commentReplyNotifications = true;
  bool _taskAssignedNotifications = true;
  bool _taskUpdatedNotifications = true;
  bool _projectUpdatedNotifications = true;
  bool _systemNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);

    // TODO: Load preferences from repository
    // For now, using defaults
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() => _isLoading = false);
  }

  Future<void> _updatePreferences() async {
    // TODO: Update preferences via repository
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preferencias actualizadas'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preferencias de Notificación')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildSection(
                  title: 'Canales de Notificación',
                  children: [
                    _buildSwitchTile(
                      title: 'Notificaciones Push',
                      subtitle:
                          'Recibir notificaciones en tiempo real en este dispositivo',
                      value: _pushEnabled,
                      onChanged: (value) {
                        setState(() => _pushEnabled = value);
                        _updatePreferences();
                      },
                      icon: Icons.notifications_active,
                    ),
                    _buildSwitchTile(
                      title: 'Notificaciones por Email',
                      subtitle: 'Recibir notificaciones por correo electrónico',
                      value: _emailEnabled,
                      onChanged: (value) {
                        setState(() => _emailEnabled = value);
                        _updatePreferences();
                      },
                      icon: Icons.email,
                    ),
                  ],
                ),
                const Divider(height: 32),
                _buildSection(
                  title: 'Tipos de Notificación',
                  subtitle:
                      'Selecciona qué eventos quieres recibir notificaciones',
                  children: [
                    _buildSwitchTile(
                      title: 'Menciones',
                      subtitle: 'Cuando alguien te menciona en un comentario',
                      value: _mentionNotifications,
                      onChanged: (value) {
                        setState(() => _mentionNotifications = value);
                        _updatePreferences();
                      },
                      icon: Icons.alternate_email,
                      enabled: _pushEnabled || _emailEnabled,
                    ),
                    _buildSwitchTile(
                      title: 'Respuestas a Comentarios',
                      subtitle: 'Cuando alguien responde a tu comentario',
                      value: _commentReplyNotifications,
                      onChanged: (value) {
                        setState(() => _commentReplyNotifications = value);
                        _updatePreferences();
                      },
                      icon: Icons.comment,
                      enabled: _pushEnabled || _emailEnabled,
                    ),
                    _buildSwitchTile(
                      title: 'Tareas Asignadas',
                      subtitle: 'Cuando te asignan una nueva tarea',
                      value: _taskAssignedNotifications,
                      onChanged: (value) {
                        setState(() => _taskAssignedNotifications = value);
                        _updatePreferences();
                      },
                      icon: Icons.assignment,
                      enabled: _pushEnabled || _emailEnabled,
                    ),
                    _buildSwitchTile(
                      title: 'Actualizaciones de Tareas',
                      subtitle: 'Cuando se actualiza una tarea que sigues',
                      value: _taskUpdatedNotifications,
                      onChanged: (value) {
                        setState(() => _taskUpdatedNotifications = value);
                        _updatePreferences();
                      },
                      icon: Icons.update,
                      enabled: _pushEnabled || _emailEnabled,
                    ),
                    _buildSwitchTile(
                      title: 'Actualizaciones de Proyectos',
                      subtitle: 'Cuando se actualiza un proyecto',
                      value: _projectUpdatedNotifications,
                      onChanged: (value) {
                        setState(() => _projectUpdatedNotifications = value);
                        _updatePreferences();
                      },
                      icon: Icons.folder,
                      enabled: _pushEnabled || _emailEnabled,
                    ),
                    _buildSwitchTile(
                      title: 'Notificaciones del Sistema',
                      subtitle: 'Actualizaciones y anuncios importantes',
                      value: _systemNotifications,
                      onChanged: (value) {
                        setState(() => _systemNotifications = value);
                        _updatePreferences();
                      },
                      icon: Icons.system_update,
                      enabled: _pushEnabled || _emailEnabled,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Las notificaciones push requieren permisos del sistema. '
                              'Si no recibes notificaciones, verifica la configuración de tu dispositivo.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSection({
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ],
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    bool enabled = true,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(color: enabled ? null : Colors.grey.shade400),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
        ),
      ),
      value: value,
      onChanged: enabled ? onChanged : null,
      secondary: Icon(
        icon,
        color: enabled ? Theme.of(context).primaryColor : Colors.grey.shade400,
      ),
      activeThumbColor: Theme.of(context).primaryColor,
    );
  }
}
