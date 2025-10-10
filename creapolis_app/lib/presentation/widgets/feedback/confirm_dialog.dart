import 'package:flutter/material.dart';

/// Widget de diálogo de confirmación con variantes y animaciones
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final ConfirmDialogType type;
  final IconData? icon;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.type = ConfirmDialogType.normal,
    this.icon,
  });

  /// Mostrar diálogo de confirmación normal
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    IconData? icon,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
      ),
    );
  }

  /// Mostrar diálogo de advertencia (acciones destructivas)
  static Future<bool?> showWarning(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText ?? 'Eliminar',
        cancelText: cancelText,
        type: ConfirmDialogType.warning,
        icon: Icons.warning_amber_rounded,
      ),
    );
  }

  /// Mostrar diálogo de error
  static Future<bool?> showError(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        type: ConfirmDialogType.error,
        icon: Icons.error_outline_rounded,
      ),
    );
  }

  /// Mostrar diálogo de información
  static Future<bool?> showInfo(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        type: ConfirmDialogType.info,
        icon: Icons.info_outline_rounded,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Colores según el tipo
    final (iconColor, confirmColor) = switch (type) {
      ConfirmDialogType.normal => (colorScheme.primary, colorScheme.primary),
      ConfirmDialogType.warning => (Colors.orange, Colors.red),
      ConfirmDialogType.error => (colorScheme.error, colorScheme.error),
      ConfirmDialogType.info => (Colors.blue, Colors.blue),
    };

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono animado
            if (icon != null)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 32, color: iconColor),
                    ),
                  );
                },
              ),
            if (icon != null) const SizedBox(height: 16),

            // Título
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Mensaje
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Botones
            Row(
              children: [
                // Botón cancelar
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      onCancel?.call();
                      Navigator.of(context).pop(false);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(cancelText ?? 'Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),

                // Botón confirmar
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      onConfirm?.call();
                      Navigator.of(context).pop(true);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: confirmColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      confirmText ?? 'Confirmar',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Tipos de diálogo de confirmación
enum ConfirmDialogType { normal, warning, error, info }

/// Extension para facilitar el uso de ConfirmDialog
extension ConfirmDialogExtension on BuildContext {
  Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    IconData? icon,
  }) {
    return ConfirmDialog.show(
      this,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      icon: icon,
    );
  }

  Future<bool?> showWarningDialog({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
  }) {
    return ConfirmDialog.showWarning(
      this,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
    );
  }

  Future<bool?> showErrorDialog({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
  }) {
    return ConfirmDialog.showError(
      this,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
    );
  }

  Future<bool?> showInfoDialog({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
  }) {
    return ConfirmDialog.showInfo(
      this,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
    );
  }
}
