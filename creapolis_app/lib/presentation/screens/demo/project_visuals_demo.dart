import 'package:flutter/material.dart';

import '../../../domain/entities/project.dart';
import '../../widgets/project/project_card.dart';
import '../../widgets/project/project_relation_marker.dart';

/// Pantalla de demostración de los marcadores visuales de proyectos
/// 
/// Esta pantalla muestra ejemplos de los tres tipos de relación:
/// 1. Personal
/// 2. Compartido por mí
/// 3. Compartido conmigo
/// 
/// **Solo para propósitos de testing y demostración**
class ProjectVisualsDemo extends StatelessWidget {
  const ProjectVisualsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Usuario actual de ejemplo (ID = 1)
    const currentUserId = 1;
    
    // Proyectos de ejemplo
    final personalProject = _createSampleProject(
      id: 1,
      name: 'Proyecto Personal',
      description: 'Este proyecto es solo mío',
      managerId: currentUserId,
    );
    
    final sharedByMeProject = _createSampleProject(
      id: 2,
      name: 'Proyecto Compartido por Mí',
      description: 'He invitado a otros colaboradores',
      managerId: currentUserId,
    );
    
    final sharedWithMeProject = _createSampleProject(
      id: 3,
      name: 'Proyecto Compartido Conmigo',
      description: 'Otro usuario me invitó a colaborar',
      managerId: 99, // Otro usuario
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo: Marcadores Visuales'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Título y descripción
          Text(
            'Personalización Visual de Workflows',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ejemplos de los tres tipos de relación con proyectos',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          
          // Sección 1: Proyecto Personal
          _buildSection(
            context,
            title: '1. Proyecto Personal',
            description: 'Sin marcador adicional (diseño limpio)',
            child: SizedBox(
              height: 280,
              child: ProjectCard(
                project: personalProject,
                currentUserId: currentUserId,
                hasOtherMembers: false, // Sin otros miembros
                onTap: () => _showInfo(context, 'Proyecto Personal'),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Sección 2: Compartido por mí
          _buildSection(
            context,
            title: '2. Compartido por Mí',
            description: 'Badge púrpura con icono de compartir',
            child: SizedBox(
              height: 280,
              child: ProjectCard(
                project: sharedByMeProject,
                currentUserId: currentUserId,
                hasOtherMembers: true, // Tiene otros miembros
                onTap: () => _showInfo(context, 'Compartido por Mí'),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Sección 3: Compartido conmigo
          _buildSection(
            context,
            title: '3. Compartido Conmigo',
            description: 'Badge verde con icono de grupo',
            child: SizedBox(
              height: 280,
              child: ProjectCard(
                project: sharedWithMeProject,
                currentUserId: currentUserId,
                hasOtherMembers: true, // Tiene otros miembros
                onTap: () => _showInfo(context, 'Compartido Conmigo'),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Sección 4: Solo Marcadores
          _buildSection(
            context,
            title: 'Marcadores Individuales',
            description: 'Widgets standalone para usar en otros contextos',
            child: Column(
              children: [
                const SizedBox(height: 8),
                // Marcador: Personal (no se muestra)
                _buildMarkerExample(
                  context,
                  'Personal',
                  ProjectRelationType.personal,
                  'No muestra marcador',
                ),
                const SizedBox(height: 12),
                // Marcador: Compartido por mí
                _buildMarkerExample(
                  context,
                  'Compartido por mí',
                  ProjectRelationType.sharedByMe,
                  'Color secundario (púrpura)',
                ),
                const SizedBox(height: 12),
                // Marcador: Compartido conmigo
                _buildMarkerExample(
                  context,
                  'Compartido conmigo',
                  ProjectRelationType.sharedWithMe,
                  'Color terciario (verde)',
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Información adicional
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Información',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoItem(
                    context,
                    'Color primario',
                    'Todos los proyectos usan el mismo color azul (#3B82F6)',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoItem(
                    context,
                    'Extensibilidad',
                    'Fácil agregar nuevos tipos de relación o personalizar colores',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoItem(
                    context,
                    'Documentación',
                    'Ver WORKFLOW_VISUAL_PERSONALIZATION.md para más detalles',
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
  
  /// Construir una sección con título y descripción
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String description,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
  
  /// Construir ejemplo de marcador individual
  Widget _buildMarkerExample(
    BuildContext context,
    String label,
    ProjectRelationType type,
    String note,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  note,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ProjectRelationMarker(relationType: type),
        ],
      ),
    );
  }
  
  /// Construir item de información
  Widget _buildInfoItem(BuildContext context, String title, String content) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: content),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  /// Crear proyecto de ejemplo
  Project _createSampleProject({
    required int id,
    required String name,
    required String description,
    required int managerId,
  }) {
    final now = DateTime.now();
    
    return Project(
      id: id,
      name: name,
      description: description,
      startDate: now,
      endDate: now.add(const Duration(days: 365)),
      status: ProjectStatus.active,
      managerId: managerId,
      managerName: 'Usuario $managerId',
      workspaceId: 1,
      createdAt: now,
      updatedAt: now,
    );
  }
  
  /// Mostrar información del tipo de proyecto
  void _showInfo(BuildContext context, String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tocaste un proyecto: $type'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}



