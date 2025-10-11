import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Speed Dial (FAB expandible) para creación rápida de recursos.
///
/// Muestra un FAB principal que al hacer tap se expande mostrando
/// opciones para crear tareas, proyectos y workspaces.
///
/// Características:
/// - Animación de apertura/cierre fluida
/// - Backdrop semi-transparente
/// - Labels descriptivos
/// - Iconos contextuales
/// - Callbacks para cada acción
class QuickCreateSpeedDial extends StatefulWidget {
  /// Callback cuando se solicita crear una tarea
  final VoidCallback? onCreateTask;

  /// Callback cuando se solicita crear un proyecto
  final VoidCallback? onCreateProject;

  /// Callback cuando se solicita crear un workspace
  final VoidCallback? onCreateWorkspace;

  /// Si es true, muestra la opción de crear workspace
  final bool showWorkspaceOption;

  /// Color del FAB principal
  final Color? backgroundColor;

  /// Color del ícono del FAB principal
  final Color? foregroundColor;

  const QuickCreateSpeedDial({
    super.key,
    this.onCreateTask,
    this.onCreateProject,
    this.onCreateWorkspace,
    this.showWorkspaceOption = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<QuickCreateSpeedDial> createState() => _QuickCreateSpeedDialState();
}

class _QuickCreateSpeedDialState extends State<QuickCreateSpeedDial>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _close() {
    if (_isExpanded) {
      setState(() {
        _isExpanded = false;
        _controller.reverse();
      });
    }
  }

  void _handleCreateTask() {
    _close();
    widget.onCreateTask?.call();
  }

  void _handleCreateProject() {
    _close();
    widget.onCreateProject?.call();
  }

  void _handleCreateWorkspace() {
    _close();
    widget.onCreateWorkspace?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? theme.colorScheme.primary;
    final foregroundColor =
        widget.foregroundColor ?? theme.colorScheme.onPrimary;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Backdrop para cerrar al hacer tap fuera
        if (_isExpanded)
          GestureDetector(
            onTap: _close,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              width: double.infinity,
              height: double.infinity,
            ),
          ),

        // Opciones del Speed Dial
        ..._buildSpeedDialOptions(theme),

        // FAB Principal
        FloatingActionButton(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          onPressed: _toggle,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * math.pi / 4, // 45 grados
                child: Icon(_isExpanded ? Icons.close : Icons.add, size: 28),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSpeedDialOptions(ThemeData theme) {
    final options = <Widget>[];
    int index = 0;

    // Opción: Nueva Tarea
    if (widget.onCreateTask != null) {
      options.add(
        _buildSpeedDialOption(
          icon: Icons.task_alt,
          label: 'Nueva Tarea',
          backgroundColor: Colors.blue,
          onTap: _handleCreateTask,
          index: index++,
          theme: theme,
        ),
      );
    }

    // Opción: Nuevo Proyecto
    if (widget.onCreateProject != null) {
      options.add(
        _buildSpeedDialOption(
          icon: Icons.folder,
          label: 'Nuevo Proyecto',
          backgroundColor: Colors.orange,
          onTap: _handleCreateProject,
          index: index++,
          theme: theme,
        ),
      );
    }

    // Opción: Nuevo Workspace
    if (widget.showWorkspaceOption && widget.onCreateWorkspace != null) {
      options.add(
        _buildSpeedDialOption(
          icon: Icons.business,
          label: 'Nuevo Workspace',
          backgroundColor: Colors.purple,
          onTap: _handleCreateWorkspace,
          index: index++,
          theme: theme,
        ),
      );
    }

    return options.reversed.toList();
  }

  Widget _buildSpeedDialOption({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required VoidCallback onTap,
    required int index,
    required ThemeData theme,
  }) {
    // Espaciado entre opciones: 72px (56 del FAB + 16 de gap)
    final double offset = (index + 1) * 72.0;

    return Positioned(
      bottom: offset,
      right: 0,
      child: AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          // Animación de deslizamiento y fade
          return Transform.translate(
            offset: Offset(0, (1 - _expandAnimation.value) * 20),
            child: Opacity(opacity: _expandAnimation.value, child: child),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Mini FAB
            FloatingActionButton.small(
              heroTag: 'speed_dial_$label',
              backgroundColor: backgroundColor,
              foregroundColor: Colors.white,
              onPressed: onTap,
              child: Icon(icon, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
