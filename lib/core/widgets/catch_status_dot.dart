import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

class CatchStatusDot extends StatelessWidget {
  const CatchStatusDot({
    super.key,
    this.color,
    this.size = 7,
    this.borderColor,
  });

  final Color? color;
  final double size;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? t.primary,
        shape: BoxShape.circle,
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: SizedBox.square(dimension: size),
    );
  }
}
