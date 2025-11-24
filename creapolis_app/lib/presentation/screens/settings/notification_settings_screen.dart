import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _projectUpdates = true;
  bool _taskAssignments = true;
  bool _mentions = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: ListView(
        children: [
          _buildSectionHeader('Canales'),
          SwitchListTile(
            title: const Text('Notificaciones Push'),
            subtitle: const Text('Recibir notificaciones en este dispositivo'),
            value: _pushNotifications,
            onChanged: (value) => setState(() => _pushNotifications = value),
          ),
          SwitchListTile(
            title: const Text('Correo Electrónico'),
            subtitle: const Text('Recibir resumenes y alertas por correo'),
            value: _emailNotifications,
            onChanged: (value) => setState(() => _emailNotifications = value),
          ),
          const Divider(),
          _buildSectionHeader('Tipos de Notificación'),
          SwitchListTile(
            title: const Text('Actualizaciones de Proyecto'),
            value: _projectUpdates,
            onChanged: (value) => setState(() => _projectUpdates = value),
          ),
          SwitchListTile(
            title: const Text('Asignación de Tareas'),
            value: _taskAssignments,
            onChanged: (value) => setState(() => _taskAssignments = value),
          ),
          SwitchListTile(
            title: const Text('Menciones'),
            subtitle: const Text('Cuando alguien te menciona en un comentario'),
            value: _mentions,
            onChanged: (value) => setState(() => _mentions = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
