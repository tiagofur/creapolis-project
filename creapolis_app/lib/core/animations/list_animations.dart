import 'package:flutter/material.dart';

/// Widget para animar items de lista con efecto staggered
class StaggeredListAnimation extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final Offset slideOffset;

  const StaggeredListAnimation({
    super.key,
    required this.index,
    required this.child,
    this.delay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
    this.slideOffset = const Offset(0.0, 0.1),
  });

  @override
  Widget build(BuildContext context) {
    final totalDelay = delay * index;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration + totalDelay,
      curve: curve,
      builder: (context, value, child) {
        // Ajustar el valor para que empiece después del delay
        final adjustedValue =
            (value * (duration.inMilliseconds + totalDelay.inMilliseconds) -
                totalDelay.inMilliseconds) /
            duration.inMilliseconds;
        final clampedValue = adjustedValue.clamp(0.0, 1.0);

        return Opacity(
          opacity: clampedValue,
          child: Transform.translate(
            offset: Offset(
              slideOffset.dx * (1 - clampedValue) * 50,
              slideOffset.dy * (1 - clampedValue) * 50,
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Widget para animar la aparición de items en una lista
class FadeInListItem extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration delay;
  final Duration duration;

  const FadeInListItem({
    super.key,
    required this.index,
    required this.child,
    this.delay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<FadeInListItem> createState() => _FadeInListItemState();
}

class _FadeInListItemState extends State<FadeInListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Iniciar animación con delay
    Future.delayed(widget.delay * widget.index, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

/// AnimatedList builder helper
class AnimatedListHelper {
  /// Insertar item con animación
  static void insertItem(
    GlobalKey<AnimatedListState> listKey,
    int index,
    Widget Function(BuildContext, Animation<double>) builder, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    listKey.currentState?.insertItem(index, duration: duration);
  }

  /// Remover item con animación
  static void removeItem(
    GlobalKey<AnimatedListState> listKey,
    int index,
    Widget Function(BuildContext, Animation<double>) builder, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    listKey.currentState?.removeItem(
      index,
      (context, animation) => builder(context, animation),
      duration: duration,
    );
  }

  /// Builder por defecto para items removidos (fade out + slide)
  static Widget defaultRemovedItemBuilder(
    BuildContext context,
    Widget child,
    Animation<double> animation,
  ) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(opacity: animation, child: child),
    );
  }

  /// Builder para items insertados (fade in + slide)
  static Widget defaultInsertedItemBuilder(
    BuildContext context,
    Widget child,
    Animation<double> animation,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}

/// Widget para animar cambios en listas
class AnimatedListItem extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final bool isRemoving;

  const AnimatedListItem({
    super.key,
    required this.animation,
    required this.child,
    this.isRemoving = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isRemoving) {
      return SizeTransition(
        sizeFactor: animation,
        child: FadeTransition(opacity: animation, child: child),
      );
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.3, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}

/// Extension para facilitar animaciones en ListView
extension AnimatedListViewExtension on ListView {
  /// Crear ListView con animaciones staggered
  static Widget staggered({
    Key? key,
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    ScrollPhysics? physics,
    EdgeInsetsGeometry? padding,
    Duration itemDelay = const Duration(milliseconds: 50),
    Duration itemDuration = const Duration(milliseconds: 400),
  }) {
    return ListView.builder(
      key: key,
      itemCount: itemCount,
      physics: physics,
      padding: padding,
      itemBuilder: (context, index) {
        return StaggeredListAnimation(
          index: index,
          delay: itemDelay,
          duration: itemDuration,
          child: itemBuilder(context, index),
        );
      },
    );
  }
}
