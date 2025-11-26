import 'package:flutter/material.dart';

/// Widget de ilustración que se adapta automáticamente al tema claro/oscuro.
///
/// Proporciona ilustraciones con múltiples capas, efectos de gradiente y
/// decoraciones que respetan el tema actual de la aplicación.
///
/// Uso:
/// ```dart
/// AdaptiveIllustration(
///   icon: Icons.rocket_launch_rounded,
///   type: IllustrationType.primary,
///   size: 200,
///   semanticLabel: 'Ilustración de bienvenida',
/// )
/// ```
class AdaptiveIllustration extends StatelessWidget {
  /// Icono principal de la ilustración
  final IconData icon;

  /// Tipo de ilustración (determina la paleta de colores)
  final IllustrationType type;

  /// Tamaño del contenedor (ancho y alto)
  final double size;

  /// Iconos secundarios decorativos (opcional)
  final List<IconData>? decorativeIcons;

  /// Si debe mostrar el efecto de resplandor
  final bool showGlow;

  /// Si debe mostrar las partículas decorativas
  final bool showParticles;

  /// Etiqueta semántica para lectores de pantalla (opcional)
  /// Si es null, la ilustración será ignorada por los lectores de pantalla
  final String? semanticLabel;

  const AdaptiveIllustration({
    super.key,
    required this.icon,
    this.type = IllustrationType.primary,
    this.size = 200,
    this.decorativeIcons,
    this.showGlow = true,
    this.showParticles = true,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = _getColors(theme, isDark);

    Widget illustration = SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Capa de resplandor (solo en modo oscuro o si showGlow)
          if (showGlow)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(
                        alpha: isDark ? 0.3 : 0.15,
                      ),
                      blurRadius: size * 0.4,
                      spreadRadius: size * 0.05,
                    ),
                  ],
                ),
              ),
            ),

          // Círculo exterior con gradiente
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.containerLight, colors.containerDark],
              ),
              border: Border.all(color: colors.border, width: 2),
            ),
          ),

          // Círculo interior
          Container(
            width: size * 0.75,
            height: size * 0.75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.innerCircle,
              border: Border.all(color: colors.innerBorder, width: 1.5),
            ),
          ),

          // Partículas decorativas
          if (showParticles) ..._buildParticles(colors, isDark),

          // Iconos decorativos
          if (decorativeIcons != null) ..._buildDecorativeIcons(colors),

          // Icono principal
          Icon(icon, size: size * 0.4, color: colors.icon),
        ],
      ),
    );

    // Envolver con Semantics si hay etiqueta
    if (semanticLabel != null) {
      return Semantics(image: true, label: semanticLabel, child: illustration);
    }

    // Si no hay semanticLabel, excluir de accesibilidad
    return ExcludeSemantics(child: illustration);
  }

  List<Widget> _buildParticles(_IllustrationColors colors, bool isDark) {
    final particleSize = size * 0.04;
    final particles = <Widget>[];

    // Posiciones de las partículas (relativas al centro)
    final positions = [
      Offset(-size * 0.35, -size * 0.25),
      Offset(size * 0.38, -size * 0.18),
      Offset(-size * 0.28, size * 0.32),
      Offset(size * 0.32, size * 0.28),
      Offset(-size * 0.15, -size * 0.42),
      Offset(size * 0.18, size * 0.4),
    ];

    for (var i = 0; i < positions.length; i++) {
      final pos = positions[i];
      final isLarge = i % 2 == 0;

      particles.add(
        Positioned(
          left: size / 2 + pos.dx - particleSize / 2,
          top: size / 2 + pos.dy - particleSize / 2,
          child: Container(
            width: isLarge ? particleSize * 1.5 : particleSize,
            height: isLarge ? particleSize * 1.5 : particleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.particle.withValues(alpha: isDark ? 0.8 : 0.6),
            ),
          ),
        ),
      );
    }

    return particles;
  }

  List<Widget> _buildDecorativeIcons(_IllustrationColors colors) {
    if (decorativeIcons == null || decorativeIcons!.isEmpty) return [];

    final icons = <Widget>[];
    final iconSize = size * 0.12;

    // Posiciones para los iconos decorativos
    final positions = [
      Offset(-size * 0.38, -size * 0.1),
      Offset(size * 0.4, size * 0.05),
      Offset(size * 0.1, size * 0.42),
    ];

    for (var i = 0; i < decorativeIcons!.length && i < positions.length; i++) {
      final pos = positions[i];

      icons.add(
        Positioned(
          left: size / 2 + pos.dx - iconSize / 2,
          top: size / 2 + pos.dy - iconSize / 2,
          child: Container(
            padding: EdgeInsets.all(iconSize * 0.3),
            decoration: BoxDecoration(
              color: colors.decorativeIconBg,
              shape: BoxShape.circle,
              border: Border.all(color: colors.decorativeIconBorder, width: 1),
            ),
            child: Icon(
              decorativeIcons![i],
              size: iconSize * 0.6,
              color: colors.decorativeIcon,
            ),
          ),
        ),
      );
    }

    return icons;
  }

  _IllustrationColors _getColors(ThemeData theme, bool isDark) {
    final colorScheme = theme.colorScheme;

    switch (type) {
      case IllustrationType.primary:
        return _IllustrationColors(
          primary: colorScheme.primary,
          containerLight: isDark
              ? colorScheme.primaryContainer.withValues(alpha: 0.4)
              : colorScheme.primaryContainer,
          containerDark: isDark
              ? colorScheme.primaryContainer.withValues(alpha: 0.2)
              : colorScheme.primaryContainer.withValues(alpha: 0.7),
          border: isDark
              ? colorScheme.primary.withValues(alpha: 0.3)
              : colorScheme.primaryContainer,
          innerCircle: isDark
              ? colorScheme.primaryContainer.withValues(alpha: 0.5)
              : colorScheme.primaryContainer.withValues(alpha: 0.8),
          innerBorder: isDark
              ? colorScheme.primary.withValues(alpha: 0.4)
              : colorScheme.primary.withValues(alpha: 0.2),
          icon: colorScheme.primary,
          particle: colorScheme.primary,
          decorativeIconBg: isDark
              ? colorScheme.surface
              : colorScheme.primaryContainer,
          decorativeIconBorder: isDark
              ? colorScheme.primary.withValues(alpha: 0.3)
              : colorScheme.primary.withValues(alpha: 0.2),
          decorativeIcon: colorScheme.primary,
        );

      case IllustrationType.secondary:
        return _IllustrationColors(
          primary: colorScheme.secondary,
          containerLight: isDark
              ? colorScheme.secondaryContainer.withValues(alpha: 0.4)
              : colorScheme.secondaryContainer,
          containerDark: isDark
              ? colorScheme.secondaryContainer.withValues(alpha: 0.2)
              : colorScheme.secondaryContainer.withValues(alpha: 0.7),
          border: isDark
              ? colorScheme.secondary.withValues(alpha: 0.3)
              : colorScheme.secondaryContainer,
          innerCircle: isDark
              ? colorScheme.secondaryContainer.withValues(alpha: 0.5)
              : colorScheme.secondaryContainer.withValues(alpha: 0.8),
          innerBorder: isDark
              ? colorScheme.secondary.withValues(alpha: 0.4)
              : colorScheme.secondary.withValues(alpha: 0.2),
          icon: colorScheme.secondary,
          particle: colorScheme.secondary,
          decorativeIconBg: isDark
              ? colorScheme.surface
              : colorScheme.secondaryContainer,
          decorativeIconBorder: isDark
              ? colorScheme.secondary.withValues(alpha: 0.3)
              : colorScheme.secondary.withValues(alpha: 0.2),
          decorativeIcon: colorScheme.secondary,
        );

      case IllustrationType.tertiary:
        return _IllustrationColors(
          primary: colorScheme.tertiary,
          containerLight: isDark
              ? colorScheme.tertiaryContainer.withValues(alpha: 0.4)
              : colorScheme.tertiaryContainer,
          containerDark: isDark
              ? colorScheme.tertiaryContainer.withValues(alpha: 0.2)
              : colorScheme.tertiaryContainer.withValues(alpha: 0.7),
          border: isDark
              ? colorScheme.tertiary.withValues(alpha: 0.3)
              : colorScheme.tertiaryContainer,
          innerCircle: isDark
              ? colorScheme.tertiaryContainer.withValues(alpha: 0.5)
              : colorScheme.tertiaryContainer.withValues(alpha: 0.8),
          innerBorder: isDark
              ? colorScheme.tertiary.withValues(alpha: 0.4)
              : colorScheme.tertiary.withValues(alpha: 0.2),
          icon: colorScheme.tertiary,
          particle: colorScheme.tertiary,
          decorativeIconBg: isDark
              ? colorScheme.surface
              : colorScheme.tertiaryContainer,
          decorativeIconBorder: isDark
              ? colorScheme.tertiary.withValues(alpha: 0.3)
              : colorScheme.tertiary.withValues(alpha: 0.2),
          decorativeIcon: colorScheme.tertiary,
        );

      case IllustrationType.success:
        final successColor = Colors.green;
        return _IllustrationColors(
          primary: successColor,
          containerLight: isDark
              ? successColor.withValues(alpha: 0.2)
              : successColor.withValues(alpha: 0.15),
          containerDark: isDark
              ? successColor.withValues(alpha: 0.1)
              : successColor.withValues(alpha: 0.1),
          border: successColor.withValues(alpha: isDark ? 0.3 : 0.2),
          innerCircle: successColor.withValues(alpha: isDark ? 0.3 : 0.2),
          innerBorder: successColor.withValues(alpha: isDark ? 0.4 : 0.3),
          icon: successColor,
          particle: successColor,
          decorativeIconBg: isDark
              ? colorScheme.surface
              : successColor.withValues(alpha: 0.1),
          decorativeIconBorder: successColor.withValues(alpha: 0.3),
          decorativeIcon: successColor,
        );

      case IllustrationType.warning:
        final warningColor = Colors.orange;
        return _IllustrationColors(
          primary: warningColor,
          containerLight: isDark
              ? warningColor.withValues(alpha: 0.2)
              : warningColor.withValues(alpha: 0.15),
          containerDark: isDark
              ? warningColor.withValues(alpha: 0.1)
              : warningColor.withValues(alpha: 0.1),
          border: warningColor.withValues(alpha: isDark ? 0.3 : 0.2),
          innerCircle: warningColor.withValues(alpha: isDark ? 0.3 : 0.2),
          innerBorder: warningColor.withValues(alpha: isDark ? 0.4 : 0.3),
          icon: warningColor,
          particle: warningColor,
          decorativeIconBg: isDark
              ? colorScheme.surface
              : warningColor.withValues(alpha: 0.1),
          decorativeIconBorder: warningColor.withValues(alpha: 0.3),
          decorativeIcon: warningColor,
        );

      case IllustrationType.error:
        final errorColor = colorScheme.error;
        return _IllustrationColors(
          primary: errorColor,
          containerLight: isDark
              ? colorScheme.errorContainer.withValues(alpha: 0.4)
              : colorScheme.errorContainer,
          containerDark: isDark
              ? colorScheme.errorContainer.withValues(alpha: 0.2)
              : colorScheme.errorContainer.withValues(alpha: 0.7),
          border: errorColor.withValues(alpha: isDark ? 0.3 : 0.2),
          innerCircle: isDark
              ? colorScheme.errorContainer.withValues(alpha: 0.5)
              : colorScheme.errorContainer.withValues(alpha: 0.8),
          innerBorder: errorColor.withValues(alpha: isDark ? 0.4 : 0.3),
          icon: errorColor,
          particle: errorColor,
          decorativeIconBg: isDark
              ? colorScheme.surface
              : colorScheme.errorContainer,
          decorativeIconBorder: errorColor.withValues(alpha: 0.3),
          decorativeIcon: errorColor,
        );

      case IllustrationType.neutral:
        return _IllustrationColors(
          primary: colorScheme.outline,
          containerLight: isDark
              ? colorScheme.surfaceContainerHighest
              : colorScheme.surfaceContainerHigh,
          containerDark: isDark
              ? colorScheme.surfaceContainerHigh
              : colorScheme.surfaceContainer,
          border: colorScheme.outline.withValues(alpha: 0.3),
          innerCircle: colorScheme.surfaceContainerHighest,
          innerBorder: colorScheme.outline.withValues(alpha: 0.2),
          icon: colorScheme.onSurfaceVariant,
          particle: colorScheme.outline,
          decorativeIconBg: colorScheme.surface,
          decorativeIconBorder: colorScheme.outline.withValues(alpha: 0.2),
          decorativeIcon: colorScheme.onSurfaceVariant,
        );
    }
  }
}

/// Tipos de ilustración disponibles
enum IllustrationType {
  primary,
  secondary,
  tertiary,
  success,
  warning,
  error,
  neutral,
}

/// Colores internos para las ilustraciones
class _IllustrationColors {
  final Color primary;
  final Color containerLight;
  final Color containerDark;
  final Color border;
  final Color innerCircle;
  final Color innerBorder;
  final Color icon;
  final Color particle;
  final Color decorativeIconBg;
  final Color decorativeIconBorder;
  final Color decorativeIcon;

  const _IllustrationColors({
    required this.primary,
    required this.containerLight,
    required this.containerDark,
    required this.border,
    required this.innerCircle,
    required this.innerBorder,
    required this.icon,
    required this.particle,
    required this.decorativeIconBg,
    required this.decorativeIconBorder,
    required this.decorativeIcon,
  });
}

/// Extensión con ilustraciones predefinidas para casos comunes
extension PredefinedIllustrations on AdaptiveIllustration {
  /// Ilustración de bienvenida/onboarding
  static Widget welcome({double size = 200}) {
    return AdaptiveIllustration(
      icon: Icons.rocket_launch_rounded,
      type: IllustrationType.primary,
      size: size,
      decorativeIcons: const [Icons.star_rounded, Icons.auto_awesome],
    );
  }

  /// Ilustración de workspaces
  static Widget workspace({double size = 200}) {
    return AdaptiveIllustration(
      icon: Icons.business_rounded,
      type: IllustrationType.secondary,
      size: size,
      decorativeIcons: const [
        Icons.people_rounded,
        Icons.folder_shared_rounded,
      ],
    );
  }

  /// Ilustración de proyectos
  static Widget projects({double size = 200}) {
    return AdaptiveIllustration(
      icon: Icons.folder_rounded,
      type: IllustrationType.tertiary,
      size: size,
      decorativeIcons: const [
        Icons.task_alt_rounded,
        Icons.calendar_month_rounded,
      ],
    );
  }

  /// Ilustración de colaboración
  static Widget collaboration({double size = 200}) {
    return AdaptiveIllustration(
      icon: Icons.groups_rounded,
      type: IllustrationType.primary,
      size: size,
      decorativeIcons: const [
        Icons.chat_bubble_rounded,
        Icons.notifications_rounded,
      ],
    );
  }

  /// Ilustración de estado vacío genérico
  static Widget empty({double size = 200, IconData? icon}) {
    return AdaptiveIllustration(
      icon: icon ?? Icons.inbox_rounded,
      type: IllustrationType.neutral,
      size: size,
      showGlow: false,
    );
  }

  /// Ilustración de éxito
  static Widget success({double size = 200}) {
    return AdaptiveIllustration(
      icon: Icons.check_circle_rounded,
      type: IllustrationType.success,
      size: size,
    );
  }

  /// Ilustración de error
  static Widget error({double size = 200}) {
    return AdaptiveIllustration(
      icon: Icons.error_rounded,
      type: IllustrationType.error,
      size: size,
      showParticles: false,
    );
  }

  /// Ilustración de advertencia
  static Widget warning({double size = 200}) {
    return AdaptiveIllustration(
      icon: Icons.warning_rounded,
      type: IllustrationType.warning,
      size: size,
    );
  }

  /// Ilustración para no hay proyectos
  static Widget noProjects({double size = 200}) {
    return AdaptiveIllustration(
      icon: Icons.folder_off_rounded,
      type: IllustrationType.neutral,
      size: size,
      decorativeIcons: const [Icons.add_circle_outline],
      showGlow: false,
    );
  }

  /// Ilustración para no hay tareas
  static Widget noTasks({double size = 200}) {
    return AdaptiveIllustration(
      icon: Icons.task_outlined,
      type: IllustrationType.neutral,
      size: size,
      decorativeIcons: const [Icons.add_task],
      showGlow: false,
    );
  }

  /// Ilustración para búsqueda sin resultados
  static Widget noResults({double size = 200}) {
    return AdaptiveIllustration(
      icon: Icons.search_off_rounded,
      type: IllustrationType.neutral,
      size: size,
      showGlow: false,
      showParticles: false,
    );
  }
}
