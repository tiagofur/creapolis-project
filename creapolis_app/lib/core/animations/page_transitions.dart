import 'package:flutter/material.dart';

/// Tipos de transiciones disponibles
enum PageTransitionType {
  fade,
  slide,
  scale,
  rotation,
  slideFromRight,
  slideFromLeft,
  slideFromBottom,
  slideFromTop,
}

/// Page Route con transiciones personalizadas
class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final PageTransitionType transitionType;
  final Duration duration;
  final Curve curve;

  CustomPageRoute({
    required this.page,
    this.transitionType = PageTransitionType.slideFromRight,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionDuration: duration,
         reverseTransitionDuration: duration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return _buildTransition(
             child: child,
             animation: animation,
             secondaryAnimation: secondaryAnimation,
             type: transitionType,
             curve: curve,
           );
         },
       );

  static Widget _buildTransition({
    required Widget child,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required PageTransitionType type,
    required Curve curve,
  }) {
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

    switch (type) {
      case PageTransitionType.fade:
        return FadeTransition(opacity: curvedAnimation, child: child);

      case PageTransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(opacity: curvedAnimation, child: child),
        );

      case PageTransitionType.rotation:
        return RotationTransition(
          turns: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(opacity: curvedAnimation, child: child),
        );

      case PageTransitionType.slideFromRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.slideFromLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.slideFromBottom:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.slideFromTop:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.slide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
    }
  }
}

/// Extension para facilitar navegación con transiciones
extension PageTransitionNavigation on BuildContext {
  /// Navegar con transición personalizada
  Future<T?> pushWithTransition<T>(
    Widget page, {
    PageTransitionType type = PageTransitionType.slideFromRight,
    Duration? duration,
    Curve? curve,
  }) {
    return Navigator.of(this).push<T>(
      CustomPageRoute<T>(
        page: page,
        transitionType: type,
        duration: duration ?? const Duration(milliseconds: 300),
        curve: curve ?? Curves.easeInOut,
      ),
    );
  }

  /// Reemplazar con transición
  Future<T?> pushReplacementWithTransition<T, TO>(
    Widget page, {
    PageTransitionType type = PageTransitionType.slideFromRight,
    Duration? duration,
    Curve? curve,
    TO? result,
  }) {
    return Navigator.of(this).pushReplacement<T, TO>(
      CustomPageRoute<T>(
        page: page,
        transitionType: type,
        duration: duration ?? const Duration(milliseconds: 300),
        curve: curve ?? Curves.easeInOut,
      ),
      result: result,
    );
  }
}

/// Transición de Fade rápida
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
}

/// Transición de Scale con Fade
class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  ScalePageRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          );

          return ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(curvedAnimation),
            child: FadeTransition(opacity: curvedAnimation, child: child),
          );
        },
      );
}

/// Transición de Slide suave
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Offset beginOffset;

  SlidePageRoute({
    required this.page,
    this.beginOffset = const Offset(1.0, 0.0),
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionDuration: const Duration(milliseconds: 300),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           final curvedAnimation = CurvedAnimation(
             parent: animation,
             curve: Curves.easeInOutCubic,
           );

           return SlideTransition(
             position: Tween<Offset>(
               begin: beginOffset,
               end: Offset.zero,
             ).animate(curvedAnimation),
             child: child,
           );
         },
       );
}
