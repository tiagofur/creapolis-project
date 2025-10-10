import 'package:flutter/material.dart';

/// Widget de Toast personalizado con posiciones configurables
class AppToast {
  AppToast._();

  /// Mostrar toast en la posición especificada
  static void show(
    BuildContext context, {
    required String message,
    ToastPosition position = ToastPosition.bottom,
    ToastDuration duration = ToastDuration.short,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        position: position,
        duration: duration,
        icon: icon,
        backgroundColor: backgroundColor,
        textColor: textColor,
      ),
    );

    overlay.insert(overlayEntry);

    // Remover el overlay después de la duración
    Future.delayed(duration.duration, () {
      overlayEntry.remove();
    });
  }

  /// Toast de éxito
  static void success(
    BuildContext context,
    String message, {
    ToastPosition position = ToastPosition.bottom,
  }) {
    show(
      context,
      message: message,
      position: position,
      icon: Icons.check_circle,
      backgroundColor: Colors.green,
    );
  }

  /// Toast de error
  static void error(
    BuildContext context,
    String message, {
    ToastPosition position = ToastPosition.bottom,
  }) {
    show(
      context,
      message: message,
      position: position,
      icon: Icons.error,
      backgroundColor: Colors.red,
    );
  }

  /// Toast de información
  static void info(
    BuildContext context,
    String message, {
    ToastPosition position = ToastPosition.bottom,
  }) {
    show(
      context,
      message: message,
      position: position,
      icon: Icons.info,
      backgroundColor: Colors.blue,
    );
  }

  /// Toast de advertencia
  static void warning(
    BuildContext context,
    String message, {
    ToastPosition position = ToastPosition.bottom,
  }) {
    show(
      context,
      message: message,
      position: position,
      icon: Icons.warning,
      backgroundColor: Colors.orange,
    );
  }
}

/// Widget interno del Toast
class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastPosition position;
  final ToastDuration duration;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const _ToastWidget({
    required this.message,
    required this.position,
    required this.duration,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: widget.position == ToastPosition.top
          ? const Offset(0, -1)
          : const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // Iniciar animación de salida antes de que termine
    Future.delayed(
      widget.duration.duration - const Duration(milliseconds: 300),
      () {
        if (mounted) {
          _controller.reverse();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      top: widget.position == ToastPosition.top ? 50 : null,
      bottom: widget.position == ToastPosition.bottom ? 50 : null,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color:
                      widget.backgroundColor ??
                      theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: widget.textColor ?? Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Flexible(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: widget.textColor ?? Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Posiciones disponibles para el toast
enum ToastPosition { top, center, bottom }

/// Duraciones disponibles para el toast
enum ToastDuration {
  short(Duration(seconds: 2)),
  long(Duration(seconds: 4));

  final Duration duration;
  const ToastDuration(this.duration);
}

/// Extension para facilitar el uso de AppToast
extension AppToastExtension on BuildContext {
  void showToast(
    String message, {
    ToastPosition position = ToastPosition.bottom,
  }) {
    AppToast.show(this, message: message, position: position);
  }

  void showSuccessToast(String message) {
    AppToast.success(this, message);
  }

  void showErrorToast(String message) {
    AppToast.error(this, message);
  }

  void showInfoToast(String message) {
    AppToast.info(this, message);
  }

  void showWarningToast(String message) {
    AppToast.warning(this, message);
  }
}
