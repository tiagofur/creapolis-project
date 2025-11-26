import 'package:flutter/material.dart';
import '../../../core/services/haptic_service.dart';

/// Helper para mostrar diálogos de confirmación con haptic feedback
class ConfirmationDialogs {
  /// Mostrar diálogo de confirmación para eliminación
  ///
  /// Retorna `true` si el usuario confirma, `false` si cancela
  static Future<bool> showDeleteConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String cancelText = 'Cancelar',
    String confirmText = 'Eliminar',
  }) async {
    // Haptic al mostrar diálogo de eliminación
    HapticService.warning();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              HapticService.lightImpact();
              Navigator.pop(context, false);
            },
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () {
              HapticService.destructive();
              Navigator.pop(context, true);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Mostrar diálogo de confirmación genérico
  static Future<bool> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String cancelText = 'Cancelar',
    String confirmText = 'Confirmar',
    Color? confirmColor,
  }) async {
    HapticService.lightImpact();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () {
              HapticService.mediumImpact();
              Navigator.pop(context, true);
            },
            style: confirmColor != null
                ? FilledButton.styleFrom(backgroundColor: confirmColor)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Mostrar diálogo de éxito con haptic
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
  }) async {
    HapticService.success();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle,
          color: Theme.of(context).colorScheme.primary,
          size: 48,
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Mostrar diálogo de error con haptic
  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
  }) async {
    HapticService.error();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.error,
          color: Theme.of(context).colorScheme.error,
          size: 48,
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
