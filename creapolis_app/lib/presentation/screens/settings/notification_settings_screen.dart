import 'package:flutter/material.dart';
import '../../../core/services/firebase_messaging_service.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/datasources/push_notification_remote_datasource.dart';
import '../../../injection.dart';

/// Pantalla de configuración de notificaciones.
///
/// Permite al usuario:
/// - Habilitar/deshabilitar notificaciones push globalmente
/// - Configurar preferencias por tipo de notificación
/// - Ver el estado actual del token FCM
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  // Preferencias
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _mentionNotifications = true;
  bool _commentReplyNotifications = true;
  bool _taskAssignedNotifications = true;
  bool _taskUpdatedNotifications = true;
  bool _projectUpdatedNotifications = true;
  bool _systemNotifications = true;

  // FCM Token info
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dataSource = getIt<PushNotificationRemoteDataSource>();
      final prefs = await dataSource.getPreferences();

      // Obtener token FCM
      final messagingService = getIt<FirebaseMessagingService>();
      _fcmToken = messagingService.fcmToken;

      setState(() {
        _pushEnabled = prefs['pushEnabled'] ?? true;
        _emailEnabled = prefs['emailEnabled'] ?? false;
        _mentionNotifications = prefs['mentionNotifications'] ?? true;
        _commentReplyNotifications = prefs['commentReplyNotifications'] ?? true;
        _taskAssignedNotifications = prefs['taskAssignedNotifications'] ?? true;
        _taskUpdatedNotifications = prefs['taskUpdatedNotifications'] ?? true;
        _projectUpdatedNotifications =
            prefs['projectUpdatedNotifications'] ?? true;
        _systemNotifications = prefs['systemNotifications'] ?? true;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Error loading notification preferences: $e');
      setState(() {
        _error = 'Error al cargar preferencias';
        _isLoading = false;
      });
    }
  }

  Future<void> _savePreferences() async {
    setState(() => _isSaving = true);

    try {
      final dataSource = getIt<PushNotificationRemoteDataSource>();
      await dataSource.updatePreferences({
        'pushEnabled': _pushEnabled,
        'emailEnabled': _emailEnabled,
        'mentionNotifications': _mentionNotifications,
        'commentReplyNotifications': _commentReplyNotifications,
        'taskAssignedNotifications': _taskAssignedNotifications,
        'taskUpdatedNotifications': _taskUpdatedNotifications,
        'projectUpdatedNotifications': _projectUpdatedNotifications,
        'systemNotifications': _systemNotifications,
      });

      HapticService.success();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preferencias guardadas'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Error saving notification preferences: $e');
      HapticService.error();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _updatePreference(String key, bool value) {
    HapticService.selectionClick();
    setState(() {
      switch (key) {
        case 'pushEnabled':
          _pushEnabled = value;
          break;
        case 'emailEnabled':
          _emailEnabled = value;
          break;
        case 'mentionNotifications':
          _mentionNotifications = value;
          break;
        case 'commentReplyNotifications':
          _commentReplyNotifications = value;
          break;
        case 'taskAssignedNotifications':
          _taskAssignedNotifications = value;
          break;
        case 'taskUpdatedNotifications':
          _taskUpdatedNotifications = value;
          break;
        case 'projectUpdatedNotifications':
          _projectUpdatedNotifications = value;
          break;
        case 'systemNotifications':
          _systemNotifications = value;
          break;
      }
    });
    _savePreferences();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorState(theme)
          : _buildContent(theme),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(_error!, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _loadPreferences,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return ListView(
      children: [
        // Estado de conexión
        if (_fcmToken != null) ...[
          _buildStatusCard(theme),
          const SizedBox(height: 8),
        ],

        // Canales de notificación
        _buildSectionHeader('Canales'),
        SwitchListTile(
          title: const Text('Notificaciones Push'),
          subtitle: const Text('Recibir notificaciones en este dispositivo'),
          value: _pushEnabled,
          onChanged: (value) => _updatePreference('pushEnabled', value),
          secondary: Icon(
            Icons.notifications_active,
            color: _pushEnabled ? theme.colorScheme.primary : null,
          ),
        ),
        SwitchListTile(
          title: const Text('Correo Electrónico'),
          subtitle: const Text('Recibir resúmenes y alertas por correo'),
          value: _emailEnabled,
          onChanged: (value) => _updatePreference('emailEnabled', value),
          secondary: Icon(
            Icons.email,
            color: _emailEnabled ? theme.colorScheme.primary : null,
          ),
        ),

        const Divider(),

        // Tipos de notificación
        _buildSectionHeader('Tipos de Notificación'),
        AnimatedOpacity(
          opacity: _pushEnabled ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 200),
          child: AbsorbPointer(
            absorbing: !_pushEnabled,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Menciones'),
                  subtitle: const Text(
                    'Cuando alguien te menciona en un comentario',
                  ),
                  value: _mentionNotifications,
                  onChanged: (value) =>
                      _updatePreference('mentionNotifications', value),
                  secondary: const Icon(Icons.alternate_email),
                ),
                SwitchListTile(
                  title: const Text('Respuestas a comentarios'),
                  subtitle: const Text(
                    'Cuando alguien responde a tu comentario',
                  ),
                  value: _commentReplyNotifications,
                  onChanged: (value) =>
                      _updatePreference('commentReplyNotifications', value),
                  secondary: const Icon(Icons.reply),
                ),
                SwitchListTile(
                  title: const Text('Tareas asignadas'),
                  subtitle: const Text('Cuando te asignan una nueva tarea'),
                  value: _taskAssignedNotifications,
                  onChanged: (value) =>
                      _updatePreference('taskAssignedNotifications', value),
                  secondary: const Icon(Icons.assignment_ind),
                ),
                SwitchListTile(
                  title: const Text('Actualizaciones de tareas'),
                  subtitle: const Text(
                    'Cambios en tareas que sigues o te son asignadas',
                  ),
                  value: _taskUpdatedNotifications,
                  onChanged: (value) =>
                      _updatePreference('taskUpdatedNotifications', value),
                  secondary: const Icon(Icons.update),
                ),
                SwitchListTile(
                  title: const Text('Actualizaciones de proyecto'),
                  subtitle: const Text('Cambios importantes en tus proyectos'),
                  value: _projectUpdatedNotifications,
                  onChanged: (value) =>
                      _updatePreference('projectUpdatedNotifications', value),
                  secondary: const Icon(Icons.folder_special),
                ),
                SwitchListTile(
                  title: const Text('Notificaciones del sistema'),
                  subtitle: const Text('Mantenimiento, actualizaciones, etc.'),
                  value: _systemNotifications,
                  onChanged: (value) =>
                      _updatePreference('systemNotifications', value),
                  secondary: const Icon(Icons.info),
                ),
              ],
            ),
          ),
        ),

        if (!_pushEnabled)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Activa las notificaciones push para configurar los tipos de notificación.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStatusCard(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.check_circle, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dispositivo registrado',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Las notificaciones push están configuradas correctamente',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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
