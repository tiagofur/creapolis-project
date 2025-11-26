import 'package:flutter/material.dart';

/// Extensión para agregar gestos de swipe y long press a widgets
mixin SwipeActionsMixin<T extends StatefulWidget> on State<T> {
  
  /// Construir widget con swipe actions (deslizar para eliminar/editar)
  Widget buildSwipeable({
    required Widget child,
    required BuildContext context,
    VoidCallback? onDelete,
    VoidCallback? onEdit,
    VoidCallback? onArchive,
    Color? deleteColor,
    Color? editColor,
    Color? archiveColor,
  }) {
    return Dismissible(
      key: ValueKey(DateTime.now().millisecondsSinceEpoch),
      background: _buildSwipeBackground(
        context,
        Alignment.centerLeft,
        editColor ?? Colors.blue,
        Icons.edit,
        'Editar',
      ),
      secondaryBackground: _buildSwipeBackground(
        context,
        Alignment.centerRight,
        deleteColor ?? Colors.red,
        Icons.delete,
        'Eliminar',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd && onEdit != null) {
          onEdit();
          return false; // No dismiss, solo ejecutar acción
        } else if (direction == DismissDirection.endToStart && onDelete != null) {
          // Mostrar confirmación para eliminar
          return await _showDeleteConfirmation(context);
        }
        return false;
      },
      child: child,
    );
  }

  Widget _buildSwipeBackground(
    BuildContext context,
    Alignment alignment,
    Color color,
    IconData icon,
    String label,
  ) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: color,
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Extension methods para confirmaciones
extension SwipeActionsHelpers on State {
  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text('¿Estás seguro de que quieres eliminar este elemento?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Construir widget con long press menu contextual
  Widget buildWithContextMenu({
    required Widget child,
    required BuildContext context,
    required List<ContextMenuItem> menuItems,
  }) {
    return GestureDetector(
      onLongPress: () => _showContextMenu(context, menuItems),
      child: child,
    );
  }

  Future<void> _showContextMenu(
    BuildContext context,
    List<ContextMenuItem> menuItems,
  ) async {
    final RenderBox? overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;

    if (overlay == null) return;

    await showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(100, 100, 0, 0), // Posición aproximada
        Offset.zero & overlay.size,
      ),
      items: menuItems
          .map((item) => PopupMenuItem(
                value: item.key,
                child: Row(
                  children: [
                    Icon(item.icon, size: 20, color: item.color),
                    const SizedBox(width: 12),
                    Text(item.label),
                  ],
                ),
              ))
          .toList(),
      elevation: 8,
    ).then((value) {
      if (value != null) {
        final item = menuItems.firstWhere((m) => m.key == value);
        item.onTap();
      }
    });
  }
}

/// Item de menú contextual
class ContextMenuItem {
  final String key;
  final String label;
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const ContextMenuItem({
    required this.key,
    required this.label,
    required this.icon,
    this.color,
    required this.onTap,
  });
}

/// Extension para mostrar bottom sheets con estilo consistente
extension BottomSheetExtension on BuildContext {
  
  /// Mostrar bottom sheet modal con estilo Material Design 3
  Future<T?> showMobileBottomSheet<T>({
    required Widget child,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
  }) {
    return showModalBottomSheet<T>(
      context: this,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor ?? Theme.of(this).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => child,
    );
  }

  /// Mostrar bottom sheet con header estándar
  Future<T?> showMobileBottomSheetWithHeader<T>({
    required String title,
    required Widget child,
    List<Widget>? actions,
    bool isScrollControlled = true,
  }) {
    return showMobileBottomSheet<T>(
      isScrollControlled: isScrollControlled,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(this).colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(this).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  if (actions != null) ...actions,
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mostrar bottom sheet de selección (lista de opciones)
  Future<T?> showSelectionBottomSheet<T>({
    required String title,
    required List<SelectionItem<T>> items,
    T? selectedValue,
  }) {
    return showMobileBottomSheetWithHeader<T>(
      title: title,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = item.value == selectedValue;
          
          return ListTile(
            leading: item.icon != null
                ? Icon(
                    item.icon,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  )
                : null,
            title: Text(
              item.label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
            ),
            subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
            trailing: isSelected
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () => Navigator.pop(context, item.value),
          );
        },
      ),
    );
  }

  /// Mostrar bottom sheet de confirmación
  Future<bool> showConfirmationBottomSheet({
    required String title,
    required String message,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    bool isDangerous = false,
  }) async {
    final result = await showMobileBottomSheetWithHeader<bool>(
      title: title,
      isScrollControlled: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            message,
            style: Theme.of(this).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(this, false),
                  child: Text(cancelLabel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(this, true),
                  style: isDangerous
                      ? FilledButton.styleFrom(
                          backgroundColor: Theme.of(this).colorScheme.error,
                        )
                      : null,
                  child: Text(confirmLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
}

/// Item de selección para bottom sheets
class SelectionItem<T> {
  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;

  const SelectionItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
  });
}

/// Widget helper para RefreshIndicator con estilo mejorado
class MobileRefreshIndicator extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final Color? color;
  final Color? backgroundColor;

  const MobileRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? Theme.of(context).colorScheme.primary,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      strokeWidth: 3,
      displacement: 40,
      child: child,
    );
  }
}
