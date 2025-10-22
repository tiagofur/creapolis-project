import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/workspace_context.dart';
import '../workspace/workspace_switcher.dart';

/// AppBar personalizado de Creapolis con workspace switcher integrado
///
/// Este AppBar muestra:
/// - Título de la pantalla
/// - Workspace activo (usando WorkspaceSwitcher)
/// - Acciones personalizadas
///
/// Inspirado en Notion, Slack y Asana donde el workspace activo
/// siempre es visible en el header global
class CreopolisAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Título principal del AppBar (ej: "Proyectos", "Tareas", "Dashboard")
  final String title;

  /// Widget personalizado para el título (opcional, si se proporciona ignora [title])
  final Widget? titleWidget;

  /// Acciones adicionales (botones de acción en el lado derecho)
  final List<Widget>? actions;

  /// Mostrar el workspace switcher
  final bool showWorkspaceSwitcher;

  /// Usar versión compacta del workspace switcher (solo icono)
  final bool compactWorkspaceSwitcher;

  /// Widget leading personalizado (por defecto usa back button o drawer)
  final Widget? leading;

  /// Mostrar automáticamente el leading widget
  final bool automaticallyImplyLeading;

  /// Color de fondo del AppBar (por defecto usa el del tema)
  final Color? backgroundColor;

  /// Elevación del AppBar
  final double? elevation;

  /// Mostrar subtítulo con nombre del workspace debajo del título
  /// (alternativa al switcher para pantallas muy compactas)
  final bool showWorkspaceSubtitle;

  /// Widget para mostrar debajo del AppBar (típicamente TabBar)
  final PreferredSizeWidget? bottom;

  const CreopolisAppBar({
    super.key,
    required this.title,
    this.titleWidget,
    this.actions,
    this.showWorkspaceSwitcher = true,
    this.compactWorkspaceSwitcher = false,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.elevation,
    this.showWorkspaceSubtitle = false,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workspaceContext = context.watch<WorkspaceContext>();
    final activeWorkspace = workspaceContext.activeWorkspace;

    // Determinar si mostrar workspace subtitle
    final showSubtitle =
        showWorkspaceSubtitle &&
        activeWorkspace != null &&
        !showWorkspaceSwitcher;

    // Determinar si mostrar botón de retroceso
    // Si no hay leading personalizado y automaticallyImplyLeading es true
    Widget? effectiveLeading = leading;
    if (leading == null && automaticallyImplyLeading) {
      // Verificar si podemos hacer pop
      final canPop = Navigator.of(context).canPop();
      if (canPop) {
        effectiveLeading = IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Volver',
        );
      }
    }

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: elevation,
      leading: effectiveLeading,
      automaticallyImplyLeading: false, // Lo manejamos manualmente
      bottom: bottom,
      title: showSubtitle
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                titleWidget ?? Text(title),
                const SizedBox(height: 2),
                Text(
                  '📁 ${activeWorkspace.name}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )
          : titleWidget ?? Text(title),
      actions: [
        // Workspace Switcher siempre visible para permitir selección rápida
        if (showWorkspaceSwitcher) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: WorkspaceSwitcher(
              compact: compactWorkspaceSwitcher,
              showCreateButton: true,
            ),
          ),
        ],

        // Acciones personalizadas
        if (actions != null) ...actions!,
      ],
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}

/// AppBar de Creapolis con título de múltiples líneas
///
/// Útil para pantallas donde queremos mostrar un saludo + nombre de usuario
/// como en el Dashboard
class CreopolisAppBarWithSubtitle extends StatelessWidget
    implements PreferredSizeWidget {
  /// Título principal (línea superior)
  final String title;

  /// Subtítulo (línea inferior)
  final String subtitle;

  /// Estilo del título
  final TextStyle? titleStyle;

  /// Estilo del subtítulo
  final TextStyle? subtitleStyle;

  /// Acciones adicionales
  final List<Widget>? actions;

  /// Mostrar el workspace switcher
  final bool showWorkspaceSwitcher;

  /// Usar versión compacta del workspace switcher
  final bool compactWorkspaceSwitcher;

  /// Widget leading personalizado
  final Widget? leading;

  /// Mostrar automáticamente el leading widget
  final bool automaticallyImplyLeading;

  /// Color de fondo del AppBar
  final Color? backgroundColor;

  /// Elevación del AppBar
  final double? elevation;

  const CreopolisAppBarWithSubtitle({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
    this.actions,
    this.showWorkspaceSwitcher = true,
    this.compactWorkspaceSwitcher = false,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    context.watch<WorkspaceContext>();

    // Determinar si mostrar botón de retroceso
    Widget? effectiveLeading = leading;
    if (leading == null && automaticallyImplyLeading) {
      final canPop = Navigator.of(context).canPop();
      if (canPop) {
        effectiveLeading = IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Volver',
        );
      }
    }

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: elevation,
      leading: effectiveLeading,
      automaticallyImplyLeading: false, // Lo manejamos manualmente
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: titleStyle ?? theme.textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style:
                subtitleStyle ??
                theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
      actions: [
        // Workspace Switcher siempre visible para permitir selección rápida
        if (showWorkspaceSwitcher) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: WorkspaceSwitcher(
              compact: compactWorkspaceSwitcher,
              showCreateButton: true,
            ),
          ),
        ],

        // Acciones personalizadas
        if (actions != null) ...actions!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Variante compacta del AppBar para uso en pantallas secundarias
/// o cuando el espacio es limitado
class CompactCreopolisAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  /// Título del AppBar
  final String title;

  /// Acciones adicionales
  final List<Widget>? actions;

  /// Widget leading personalizado
  final Widget? leading;

  /// Mostrar automáticamente el leading widget
  final bool automaticallyImplyLeading;

  const CompactCreopolisAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<WorkspaceContext>();

    // Determinar si mostrar botón de retroceso
    Widget? effectiveLeading = leading;
    if (leading == null && automaticallyImplyLeading) {
      final canPop = Navigator.of(context).canPop();
      if (canPop) {
        effectiveLeading = IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Volver',
        );
      }
    }

    return AppBar(
      leading: effectiveLeading,
      automaticallyImplyLeading: false, // Lo manejamos manualmente
      title: Text(title),
      actions: [
        // Workspace Switcher compacto siempre visible para facilitar el cambio
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: WorkspaceSwitcher(compact: true, showCreateButton: false),
        ),

        // Acciones personalizadas
        if (actions != null) ...actions!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
