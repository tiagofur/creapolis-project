import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Extension para navegación con animaciones mejoradas
extension NavigationExtensions on BuildContext {
  
  /// Navegar con Hero animation
  Future<T?> pushWithHero<T>({
    required String path,
    Object? extra,
    String? heroTag,
  }) {
    return push(path, extra: extra);
  }

  /// Navegar con slide transition de derecha a izquierda
  Future<T?> pushWithSlide<T>(
    String path, {
    Object? extra,
    SlideDirection direction = SlideDirection.fromRight,
  }) {
    return push(path, extra: extra);
  }

  /// Navegar con fade transition
  Future<T?> pushWithFade<T>(
    String path, {
    Object? extra,
  }) {
    return push(path, extra: extra);
  }

  /// Navegar con scale transition
  Future<T?> pushWithScale<T>(
    String path, {
    Object? extra,
  }) {
    return push(path, extra: extra);
  }
}

enum SlideDirection {
  fromRight,
  fromLeft,
  fromTop,
  fromBottom,
}

/// Custom page transition builder para go_router
class SlidePageTransition extends CustomTransitionPage {
  SlidePageTransition({
    required super.key,
    required super.child,
    SlideDirection direction = SlideDirection.fromRight,
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final Offset begin;
            switch (direction) {
              case SlideDirection.fromRight:
                begin = const Offset(1.0, 0.0);
                break;
              case SlideDirection.fromLeft:
                begin = const Offset(-1.0, 0.0);
                break;
              case SlideDirection.fromTop:
                begin = const Offset(0.0, -1.0);
                break;
              case SlideDirection.fromBottom:
                begin = const Offset(0.0, 1.0);
                break;
            }

            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            final tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}

/// FAB positioning helper para diferentes tamaños de pantalla
class FABPosition {
  static const EdgeInsets mobile = EdgeInsets.only(right: 16, bottom: 16);
  static const EdgeInsets tablet = EdgeInsets.only(right: 24, bottom: 24);
  static const EdgeInsets desktop = EdgeInsets.only(right: 32, bottom: 32);

  static EdgeInsets responsive(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 600) {
      return mobile;
    } else if (width < 900) {
      return tablet;
    } else {
      return desktop;
    }
  }
}

/// Extended FAB con estados y animaciones
class MobileExtendedFAB extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isExtended;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? heroTag;

  const MobileExtendedFAB({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isExtended = true,
    this.backgroundColor,
    this.foregroundColor,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: FABPosition.responsive(context),
      child: isExtended
          ? FloatingActionButton.extended(
              heroTag: heroTag,
              onPressed: onPressed,
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              icon: Icon(icon),
              label: Text(label),
            )
          : FloatingActionButton(
              heroTag: heroTag,
              onPressed: onPressed,
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              child: Icon(icon),
            ),
    );
  }
}

/// FAB que se oculta/muestra al hacer scroll
class ScrollableFAB extends StatefulWidget {
  final Widget Function(bool isVisible) builder;
  final ScrollController scrollController;
  final double threshold;

  const ScrollableFAB({
    super.key,
    required this.builder,
    required this.scrollController,
    this.threshold = 50.0,
  });

  @override
  State<ScrollableFAB> createState() => _ScrollableFABState();
}

class _ScrollableFABState extends State<ScrollableFAB>
    with SingleTickerProviderStateMixin {
  bool _isVisible = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    widget.scrollController.addListener(_onScroll);
    _animationController.forward();
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = widget.scrollController.offset;
    
    if (offset > widget.threshold && _isVisible) {
      setState(() => _isVisible = false);
      _animationController.reverse();
    } else if (offset <= widget.threshold && !_isVisible) {
      setState(() => _isVisible = true);
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.builder(_isVisible),
    );
  }
}

/// Hero animation helper
class HeroImage extends StatelessWidget {
  final String tag;
  final ImageProvider image;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BorderRadius? borderRadius;

  const HeroImage({
    super.key,
    required this.tag,
    required this.image,
    this.width,
    this.height,
    this.fit,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Image(
          image: image,
          width: width,
          height: height,
          fit: fit ?? BoxFit.cover,
        ),
      ),
    );
  }
}

/// Transition builder para CustomTransitionPage
Widget fadeTransitionBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: animation,
    child: child,
  );
}

Widget scaleTransitionBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return ScaleTransition(
    scale: Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      ),
    ),
    child: FadeTransition(
      opacity: animation,
      child: child,
    ),
  );
}

/// Responsive breakpoints helper
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;

  /// Obtener número de columnas para grid responsive
  static int gridCrossAxisCount(BuildContext context, {
    int mobileColumns = 1,
    int tabletColumns = 2,
    int desktopColumns = 3,
  }) {
    if (isMobile(context)) return mobileColumns;
    if (isTablet(context)) return tabletColumns;
    return desktopColumns;
  }

  /// Obtener padding responsive
  static EdgeInsets responsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }
}

/// Animated navigation bar item
class AnimatedNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const AnimatedNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Safe area helper que respeta notches
class SafeScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;

  const SafeScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      backgroundColor: backgroundColor,
    );
  }
}
