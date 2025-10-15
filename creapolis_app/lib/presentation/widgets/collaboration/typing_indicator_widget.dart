import 'package:flutter/material.dart';
import '../../../data/models/collaboration_model.dart';

/// Widget to display typing indicators
class TypingIndicatorWidget extends StatelessWidget {
  final Map<String, TypingIndicator> typingIndicators;
  final String? currentField;

  const TypingIndicatorWidget({
    super.key,
    required this.typingIndicators,
    this.currentField,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filter indicators for current field
    final relevantIndicators = currentField != null
        ? typingIndicators.values
              .where((indicator) => indicator.field == currentField)
              .cast<TypingIndicator>()
              .toList()
        : <TypingIndicator>[];

    if (relevantIndicators.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTypingDots(theme),
          const SizedBox(width: 8),
          Text(
            _buildTypingText(relevantIndicators),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDots(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: _AnimatedDot(
            delay: Duration(milliseconds: index * 200),
            color: theme.colorScheme.primary,
          ),
        );
      }),
    );
  }

  String _buildTypingText(List<TypingIndicator> indicators) {
    if (indicators.length == 1) {
      return '${indicators.first.userName} está escribiendo...';
    } else if (indicators.length == 2) {
      return '${indicators.first.userName} y ${indicators.last.userName} están escribiendo...';
    } else {
      return '${indicators.first.userName} y ${indicators.length - 1} más están escribiendo...';
    }
  }
}

class _AnimatedDot extends StatefulWidget {
  final Duration delay;
  final Color color;

  const _AnimatedDot({required this.delay, required this.color});

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat(reverse: true);
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: _animation.value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}



