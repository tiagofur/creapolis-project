import 'package:flutter/material.dart';

/// Pantalla que se muestra cuando el usuario no tiene workspaces
/// Inspirada en el diseño de onboarding de Notion, Slack y Asana
class EmptyWorkspaceScreen extends StatelessWidget {
  final VoidCallback? onCreateWorkspace;
  final VoidCallback? onCheckInvitations;

  const EmptyWorkspaceScreen({
    super.key,
    this.onCreateWorkspace,
    this.onCheckInvitations,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(isSmallScreen ? 24 : 48),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animación/Ilustración
                    _buildIllustration(context),

                    SizedBox(height: isSmallScreen ? 32 : 48),

                    // Título principal
                    Text(
                      '¡Bienvenido a Creapolis!',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // Subtítulo
                    Text(
                      'Comienza tu viaje creando tu primer workspace',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // Features Cards
                    _buildFeatureCards(context, isSmallScreen),

                    const SizedBox(height: 40),

                    // Botones de acción
                    _buildActionButtons(context, isSmallScreen),

                    const SizedBox(height: 24),

                    // Texto de ayuda
                    _buildHelpText(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Ilustración principal con animación
  Widget _buildIllustration(BuildContext context) {
    final theme = Theme.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.2),
                  theme.colorScheme.secondary.withValues(alpha: 0.2),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Círculos decorativos
                Positioned(
                  top: 30,
                  right: 40,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 35,
                  child: Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Icono principal
                Icon(
                  Icons.workspaces_outlined,
                  size: 100,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Cards de características
  Widget _buildFeatureCards(BuildContext context, bool isSmallScreen) {
    final features = [
      _FeatureData(
        icon: Icons.group_work,
        title: 'Colabora',
        description: 'Trabaja en equipo de forma sincronizada',
        color: Colors.blue,
      ),
      _FeatureData(
        icon: Icons.task_alt,
        title: 'Organiza',
        description: 'Gestiona proyectos y tareas eficientemente',
        color: Colors.green,
      ),
      _FeatureData(
        icon: Icons.trending_up,
        title: 'Crece',
        description: 'Escala con tu equipo sin límites',
        color: Colors.orange,
      ),
    ];

    if (isSmallScreen) {
      return Column(
        children: features
            .map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildFeatureCard(context, feature),
              ),
            )
            .toList(),
      );
    } else {
      return Row(
        children: features
            .map(
              (feature) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildFeatureCard(context, feature),
                ),
              ),
            )
            .toList(),
      );
    }
  }

  /// Card individual de característica
  Widget _buildFeatureCard(BuildContext context, _FeatureData feature) {
    final theme = Theme.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: feature.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(feature.icon, color: feature.color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              feature.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              feature.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Botones de acción
  Widget _buildActionButtons(BuildContext context, bool isSmallScreen) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Botón principal: Crear Workspace
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onCreateWorkspace,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Crear mi primer Workspace'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Separador con "o"
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade300)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'o',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.shade300)),
          ],
        ),

        const SizedBox(height: 16),

        // Botón secundario: Ver Invitaciones
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onCheckInvitations,
            icon: const Icon(Icons.mail_outline),
            label: const Text('Ver Invitaciones Pendientes'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Texto de ayuda inferior
  Widget _buildHelpText(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              '¿Primera vez? Un workspace es tu espacio de trabajo donde puedes organizar proyectos y colaborar con tu equipo.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Modelo de datos para las características
class _FeatureData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
