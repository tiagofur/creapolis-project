import 'package:flutter/material.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/haptic_service.dart';

/// Widget que trackea el interés del usuario en una feature.
///
/// Envuelve cualquier widget y registra cuando el usuario:
/// - Toca el widget (indica interés)
/// - Mantiene presionado (indica interés alto)
///
/// Uso:
/// ```dart
/// TrackableFeature(
///   featureName: 'Colaboración',
///   featureCategory: 'workspaces',
///   pageIndex: 1,
///   child: _buildFeatureRow(...),
/// )
/// ```
class TrackableFeature extends StatefulWidget {
  final String featureName;
  final String featureCategory;
  final int pageIndex;
  final Widget child;
  final VoidCallback? onTap;

  const TrackableFeature({
    super.key,
    required this.featureName,
    required this.featureCategory,
    required this.pageIndex,
    required this.child,
    this.onTap,
  });

  @override
  State<TrackableFeature> createState() => _TrackableFeatureState();
}

class _TrackableFeatureState extends State<TrackableFeature> {
  bool _isPressed = false;
  DateTime? _pressStartTime;

  void _onTapDown(TapDownDetails details) {
    _pressStartTime = DateTime.now();
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    final interactionDuration = _pressStartTime != null
        ? DateTime.now().difference(_pressStartTime!).inMilliseconds
        : null;

    AnalyticsService.trackFeatureInterest(
      featureName: widget.featureName,
      featureCategory: widget.featureCategory,
      pageIndex: widget.pageIndex,
      interactionDurationMs: interactionDuration,
    );

    HapticService.lightImpact();
    setState(() => _isPressed = false);
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: _isPressed
                ? Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
