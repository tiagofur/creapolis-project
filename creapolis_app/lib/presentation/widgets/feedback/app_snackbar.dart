import 'package:flutter/material.dart';

/// Sistema de Snackbars mejorados con diferentes tipos y acciones
class AppSnackbar {
  AppSnackbar._();

  /// Mostrar snackbar de éxito
  static void success(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle,
      backgroundColor: Colors.green,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  /// Mostrar snackbar de error
  static void error(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context,
      message: message,
      icon: Icons.error,
      backgroundColor: Colors.red,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  /// Mostrar snackbar de información
  static void info(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      icon: Icons.info,
      backgroundColor: Colors.blue,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  /// Mostrar snackbar de advertencia
  static void warning(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      icon: Icons.warning,
      backgroundColor: Colors.orange,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  /// Mostrar snackbar personalizado
  static void custom(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      icon: icon,
      backgroundColor: backgroundColor,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    String? actionLabel,
    VoidCallback? onAction,
    required Duration duration,
  }) {
    // Limpiar snackbar anterior si existe
    ScaffoldMessenger.of(context).clearSnackBars();

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: duration,
      action: actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onAction ?? () {},
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

/// Extension para facilitar el uso de AppSnackbar
extension AppSnackbarExtension on BuildContext {
  void showSuccess(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    AppSnackbar.success(
      this,
      message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  void showError(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    AppSnackbar.error(
      this,
      message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  void showInfo(String message, {String? actionLabel, VoidCallback? onAction}) {
    AppSnackbar.info(
      this,
      message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  void showWarning(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    AppSnackbar.warning(
      this,
      message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}



