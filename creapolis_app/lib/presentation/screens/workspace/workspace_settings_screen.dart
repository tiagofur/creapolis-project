import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/workspace.dart';
import '../../../injection.dart';
import '../../bloc/workspace/workspace_bloc.dart';
import '../../bloc/workspace/workspace_event.dart';
import '../../bloc/workspace/workspace_state.dart';

/// Pantalla de configuración avanzada de workspace
class WorkspaceSettingsScreen extends StatefulWidget {
  final Workspace workspace;

  const WorkspaceSettingsScreen({super.key, required this.workspace});

  @override
  State<WorkspaceSettingsScreen> createState() =>
      _WorkspaceSettingsScreenState();
}

class _WorkspaceSettingsScreenState extends State<WorkspaceSettingsScreen> {
  late WorkspaceSettings _settings;
  bool _hasChanges = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _settings = widget.workspace.settings;
  }

  void _updateSetting(WorkspaceSettings newSettings) {
    setState(() {
      _settings = newSettings;
      _hasChanges = true;
    });
  }

  Future<bool> _confirmDiscard() async {
    if (!_hasChanges) return true;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Descartar cambios?'),
        content: const Text(
          'Tienes cambios sin guardar. ¿Estás seguro de salir sin guardarlos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  void _handleSave() {
    context.read<WorkspaceBloc>().add(
      UpdateWorkspaceEvent(
        workspaceId: widget.workspace.id,
        name: widget.workspace.name,
        description: widget.workspace.description,
        type: widget.workspace.type,
        settings: _settings,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<WorkspaceBloc>(),
      child: PopScope(
        canPop: !_hasChanges,
        onPopInvoked: (didPop) async {
          if (!didPop && _hasChanges) {
            final shouldPop = await _confirmDiscard();
            if (shouldPop && context.mounted) {
              Navigator.of(context).pop();
            }
          }
        },
        child: BlocConsumer<WorkspaceBloc, WorkspaceState>(
          listener: (context, state) {
            if (state is WorkspaceLoading) {
              setState(() => _isLoading = true);
            } else if (state is WorkspaceUpdated) {
              setState(() {
                _isLoading = false;
                _hasChanges = false;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configuración guardada exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );

              Navigator.of(context).pop(true);
            } else if (state is WorkspaceError) {
              setState(() => _isLoading = false);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Configuración'),
                elevation: 0,
                actions: [
                  if (_hasChanges)
                    TextButton.icon(
                      onPressed: _isLoading ? null : _handleSave,
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
              body: Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Info del workspace
                      _buildWorkspaceInfo(),
                      const SizedBox(height: 24),

                      // Sección: General
                      _buildSectionHeader('General'),
                      _buildGeneralSettings(),
                      const SizedBox(height: 24),

                      // Sección: Miembros
                      _buildSectionHeader('Miembros'),
                      _buildMemberSettings(),
                      const SizedBox(height: 24),

                      // Sección: Regional
                      _buildSectionHeader('Configuración Regional'),
                      _buildRegionalSettings(),
                      const SizedBox(height: 32),

                      // Zona peligrosa
                      if (widget.workspace.isOwner) ...[
                        _buildSectionHeader('Zona Peligrosa'),
                        _buildDangerZone(),
                      ],
                    ],
                  ),

                  // Loading overlay
                  if (_isLoading)
                    Container(
                      color: Colors.black54,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWorkspaceInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              backgroundImage: widget.workspace.avatarUrl != null
                  ? NetworkImage(widget.workspace.avatarUrl!)
                  : null,
              child: widget.workspace.avatarUrl == null
                  ? Text(
                      widget.workspace.initials,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.workspace.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.workspace.type.displayName,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Asignación automática de miembros'),
            subtitle: const Text(
              'Asignar automáticamente nuevos miembros a proyectos',
            ),
            value: _settings.autoAssignNewMembers,
            onChanged: (value) {
              _updateSetting(_settings.copyWith(autoAssignNewMembers: value));
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Plantilla de proyecto por defecto'),
            subtitle: Text(_settings.defaultProjectTemplate ?? 'Ninguna'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showProjectTemplateSelector();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMemberSettings() {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Permitir invitaciones de invitados'),
            subtitle: const Text(
              'Los invitados pueden invitar a otros miembros',
            ),
            value: _settings.allowGuestInvites,
            onChanged: (value) {
              _updateSetting(_settings.copyWith(allowGuestInvites: value));
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Requerir verificación de email'),
            subtitle: const Text(
              'Los nuevos miembros deben verificar su email',
            ),
            value: _settings.requireEmailVerification,
            onChanged: (value) {
              _updateSetting(
                _settings.copyWith(requireEmailVerification: value),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRegionalSettings() {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: const Text('Zona horaria'),
            subtitle: Text(_settings.timezone),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showTimezoneSelector();
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Idioma'),
            subtitle: Text(_getLanguageName(_settings.language)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showLanguageSelector();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.red[700]),
                const SizedBox(width: 8),
                Text(
                  'Acciones irreversibles',
                  style: TextStyle(
                    color: Colors.red[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _handleDeleteWorkspace,
              icon: const Icon(Icons.delete_forever),
              label: const Text('Eliminar Workspace'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red[700],
                side: BorderSide(color: Colors.red[300]!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProjectTemplateSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Plantilla por defecto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String?>(
              title: const Text('Ninguna'),
              value: null,
              groupValue: _settings.defaultProjectTemplate,
              onChanged: (value) {
                _updateSetting(
                  _settings.copyWith(defaultProjectTemplate: value),
                );
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String?>(
              title: const Text('Desarrollo de Software'),
              value: 'software_dev',
              groupValue: _settings.defaultProjectTemplate,
              onChanged: (value) {
                _updateSetting(
                  _settings.copyWith(defaultProjectTemplate: value),
                );
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String?>(
              title: const Text('Marketing'),
              value: 'marketing',
              groupValue: _settings.defaultProjectTemplate,
              onChanged: (value) {
                _updateSetting(
                  _settings.copyWith(defaultProjectTemplate: value),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTimezoneSelector() {
    final timezones = [
      'UTC',
      'America/New_York',
      'America/Los_Angeles',
      'America/Mexico_City',
      'Europe/London',
      'Europe/Paris',
      'Asia/Tokyo',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zona horaria'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: timezones.length,
            itemBuilder: (context, index) {
              final tz = timezones[index];
              return RadioListTile<String>(
                title: Text(tz),
                value: tz,
                groupValue: _settings.timezone,
                onChanged: (value) {
                  if (value != null) {
                    _updateSetting(_settings.copyWith(timezone: value));
                    Navigator.of(context).pop();
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    final languages = {
      'es': 'Español',
      'en': 'English',
      'pt': 'Português',
      'fr': 'Français',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Idioma'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.entries.map((entry) {
            return RadioListTile<String>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: _settings.language,
              onChanged: (value) {
                if (value != null) {
                  _updateSetting(_settings.copyWith(language: value));
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    const languages = {
      'es': 'Español',
      'en': 'English',
      'pt': 'Português',
      'fr': 'Français',
    };
    return languages[code] ?? code;
  }

  void _handleDeleteWorkspace() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar workspace?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Esta acción NO se puede deshacer. Se eliminarán:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('• Todos los proyectos'),
            const Text('• Todas las tareas'),
            const Text('• Todos los miembros'),
            const Text('• Todo el historial'),
            const SizedBox(height: 12),
            Text(
              '¿Estás absolutamente seguro?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<WorkspaceBloc>().add(
                DeleteWorkspaceEvent(widget.workspace.id),
              );
              Navigator.of(context).pop(); // Salir de settings
              Navigator.of(context).pop(); // Salir de detail
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar definitivamente'),
          ),
        ],
      ),
    );
  }
}
