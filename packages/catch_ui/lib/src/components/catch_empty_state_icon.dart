import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_empty_state_types.dart';
import 'package:flutter/material.dart';

class CatchEmptyStateIcon extends StatelessWidget {
  const CatchEmptyStateIcon({
    super.key,
    required this.icon,
    required this.style,
    this.size,
    this.containerSize,
  });

  final IconData icon;
  final CatchEmptyStateIconStyle style;
  final double? size;
  final double? containerSize;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final bubbleSize = containerSize ?? 76;

    return switch (style) {
      CatchEmptyStateIconStyle.plain => Icon(
        icon,
        size: size ?? 34,
        color: t.ink3,
      ),
      CatchEmptyStateIconStyle.bubble => SizedBox.square(
        dimension: bubbleSize,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: t.primarySoft,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: size ?? 34, color: t.primary),
        ),
      ),
    };
  }
}
