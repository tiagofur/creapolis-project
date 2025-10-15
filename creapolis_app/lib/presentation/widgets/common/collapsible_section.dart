import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/view_constants.dart';
import '../../../core/utils/app_logger.dart';
import '../../../injection.dart';

/// Widget reutilizable para crear secciones colapsables/expandibles
///
/// Este widget implementa el patrón de Progressive Disclosure,
/// permitiendo al usuario mostrar u ocultar contenido bajo demanda.
///
/// Características:
/// - Animación suave al expandir/colapsar
/// - Estado persistente opcional (usando storageKey)
/// - Callback cuando cambia el estado
/// - Icono que rota al expandir/colapsar
/// - Contador opcional de items
/// - Estilo consistente con Material Design 3
///
/// Ejemplo de uso:
/// ```dart
/// CollapsibleSection(
///   title: 'Detalles del Proyecto',
///   icon: Icons.info_outline,
///   storageKey: 'project_details',
///   initiallyExpanded: false,
///   child: Column(
///     children: [
///       Text('Fecha de inicio: 15/10/2025'),
///       Text('Manager: Juan Pérez'),
///     ],
///   ),
/// )
/// ```
class CollapsibleSection extends StatefulWidget {
  /// Título de la sección
  final String title;

  /// Icono que representa la sección
  final IconData icon;

  /// Contenido de la sección (visible cuando está expandida)
  final Widget child;

  /// Si la sección debe estar expandida inicialmente
  final bool initiallyExpanded;

  /// Key para guardar el estado en storage (opcional)
  /// Si se proporciona, el estado se guardará en SharedPreferences
  final String? storageKey;

  /// Callback cuando el estado de expansión cambia
  final ValueChanged<bool>? onExpandChanged;

  /// Contador opcional de items (ej: "Detalles (4)")
  final int? itemCount;

  /// Si se debe mostrar un divider después del header
  final bool showDivider;

  /// Padding personalizado para el contenido
  final EdgeInsetsGeometry? contentPadding;

  const CollapsibleSection({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.initiallyExpanded = true,
    this.storageKey,
    this.onExpandChanged,
    this.itemCount,
    this.showDivider = true,
    this.contentPadding,
  });

  @override
  State<CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<CollapsibleSection>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _animationController;
  late Animation<double> _iconRotation;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;

    // Configurar controlador de animación
    _animationController = AnimationController(
      duration: ViewConstants.collapseTransition,
      vsync: this,
      value: _isExpanded ? 1.0 : 0.0,
    );

    // Animación de rotación del icono (0° a 180°)
    _iconRotation =
        Tween<double>(
          begin: 0.0,
          end: 0.5, // 0.5 * 2π = 180°
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: ViewConstants.collapseCurve,
          ),
        );

    // Animación de altura del contenido
    _heightFactor = CurvedAnimation(
      parent: _animationController,
      curve: ViewConstants.collapseCurve,
    );

    if (widget.storageKey != null) {
      _loadExpandedState();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Toggle del estado expandido/colapsado
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });

    // Notificar cambio
    widget.onExpandChanged?.call(_isExpanded);

    if (widget.storageKey != null) {
      _saveExpandedState();
    }
  }

  SharedPreferences get _preferences => getIt<SharedPreferences>();

  String get _prefsKey => 'collapsible_section_${widget.storageKey!}';

  void _loadExpandedState() {
    try {
      final storedValue = _preferences.getBool(_prefsKey);
      if (storedValue == null) {
        return;
      }

      _isExpanded = storedValue;
      _animationController.value = _isExpanded ? 1.0 : 0.0;
    } catch (error, stackTrace) {
      AppLogger.error(
        'CollapsibleSection: error al cargar estado persistido',
        error,
        stackTrace,
      );
    }
  }

  Future<void> _saveExpandedState() async {
    try {
      await _preferences.setBool(_prefsKey, _isExpanded);
    } catch (error, stackTrace) {
      AppLogger.error(
        'CollapsibleSection: error al guardar estado persistido',
        error,
        stackTrace,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: ViewConstants.sectionSpacing),
      elevation: 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header clickeable
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(ViewConstants.cardBorderRadius),
            child: Container(
              height: ViewConstants.sectionHeaderHeight,
              padding: EdgeInsets.symmetric(
                horizontal: ViewConstants.comfortablePadding,
              ),
              child: Row(
                children: [
                  // Icono de la sección
                  Icon(
                    widget.icon,
                    size: ViewConstants.mediumIconSize,
                    color: _isExpanded
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),

                  // Título
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _isExpanded
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),

                  // Contador opcional
                  if (widget.itemCount != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(
                          ViewConstants.chipBorderRadius,
                        ),
                      ),
                      child: Text(
                        '${widget.itemCount}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Icono de expandir/colapsar (con rotación animada)
                  RotationTransition(
                    turns: _iconRotation,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Divider
          if (widget.showDivider && _isExpanded)
            Divider(
              height: 1,
              thickness: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),

          // Contenido expandible (con animación)
          SizeTransition(
            sizeFactor: _heightFactor,
            axisAlignment: -1.0,
            child: Padding(
              padding:
                  widget.contentPadding ??
                  const EdgeInsets.all(ViewConstants.sectionContentPadding),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget simplificado para descripción expandible con "Ver más"
///
/// Similar a CollapsibleSection pero optimizado para texto largo
/// con botón "Ver más" / "Ver menos" en lugar de header clickeable.
class ExpandableDescription extends StatefulWidget {
  /// Texto de la descripción
  final String text;

  /// Número máximo de líneas cuando está colapsada
  final int collapsedMaxLines;

  /// Si debe estar expandida inicialmente
  final bool initiallyExpanded;

  /// Estilo del texto
  final TextStyle? textStyle;

  const ExpandableDescription({
    super.key,
    required this.text,
    this.collapsedMaxLines = ViewConstants.descriptionCollapsedMaxLines,
    this.initiallyExpanded = false,
    this.textStyle,
  });

  @override
  State<ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription> {
  late bool _isExpanded;
  bool _showExpandButton = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;

    // Determinar si el texto es suficientemente largo para mostrar botón
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfExpandable();
    });
  }

  void _checkIfExpandable() {
    // Simple heurística: si el texto tiene más caracteres que el umbral
    if (widget.text.length > ViewConstants.descriptionAutoCollapseThreshold) {
      if (mounted) {
        setState(() {
          _showExpandButton = true;
        });
      }
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: Text(
            widget.text,
            style: widget.textStyle ?? theme.textTheme.bodyMedium,
            maxLines: widget.collapsedMaxLines,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(
            widget.text,
            style: widget.textStyle ?? theme.textTheme.bodyMedium,
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: ViewConstants.fadeTransition,
        ),
        if (_showExpandButton) ...[
          const SizedBox(height: 8),
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isExpanded ? 'Ver menos' : 'Ver más',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: ViewConstants.smallIconSize,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
