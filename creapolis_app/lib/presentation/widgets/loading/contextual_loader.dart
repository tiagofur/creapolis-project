import 'package:flutter/material.dart';

/// Widget de loading contextual para operaciones específicas
///
/// Muestra diferentes tipos de loaders según el contexto:
/// - Mini loader para botones
/// - Loader inline para operaciones en listas
/// - Loader overlay para operaciones que bloquean la UI
class ContextualLoader extends StatelessWidget {
  /// Tipo de loader
  final LoaderType type;

  /// Mensaje a mostrar (opcional)
  final String? message;

  /// Color del loader (usa tema si no se especifica)
  final Color? color;

  /// Tamaño del loader
  final double size;

  const ContextualLoader({
    super.key,
    this.type = LoaderType.circular,
    this.message,
    this.color,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loaderColor = color ?? theme.colorScheme.primary;

    Widget loader;
    switch (type) {
      case LoaderType.circular:
        loader = SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
          ),
        );
        break;
      case LoaderType.linear:
        loader = SizedBox(
          width: size * 4,
          child: LinearProgressIndicator(
            minHeight: 2,
            valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
            backgroundColor: loaderColor.withValues(alpha: 0.2),
          ),
        );
        break;
      case LoaderType.dots:
        loader = _DotsLoader(color: loaderColor, size: size);
        break;
    }

    if (message != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          loader,
          const SizedBox(width: 8),
          Text(
            message!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      );
    }

    return loader;
  }

  /// Constructor para usar en botones
  factory ContextualLoader.button({String? message, Color? color}) {
    return ContextualLoader(
      type: LoaderType.circular,
      message: message,
      color: color,
      size: 16,
    );
  }

  /// Constructor para usar inline en listas
  factory ContextualLoader.inline({String? message, Color? color}) {
    return ContextualLoader(
      type: LoaderType.dots,
      message: message,
      color: color,
      size: 8,
    );
  }

  /// Constructor para operaciones con barra de progreso
  factory ContextualLoader.progress({String? message, Color? color}) {
    return ContextualLoader(
      type: LoaderType.linear,
      message: message,
      color: color,
      size: 20,
    );
  }
}

/// Loader de puntos animados
class _DotsLoader extends StatefulWidget {
  final Color color;
  final double size;

  const _DotsLoader({required this.color, required this.size});

  @override
  State<_DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<_DotsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 4,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delay = index * 0.2;
              final value = (_controller.value - delay).clamp(0.0, 1.0);
              final scale = (1.0 - (value - 0.5).abs() * 2).clamp(0.5, 1.0);

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

/// Widget de overlay de loading que bloquea la UI
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? backgroundColor;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: backgroundColor ?? Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const ContextualLoader(size: 32),
                        if (message != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            message!,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Tipos de loader disponibles
enum LoaderType { circular, linear, dots }
