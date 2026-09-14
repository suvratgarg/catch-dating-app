import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

class CatchStatusIndicator extends StatelessWidget {
  const CatchStatusIndicator({
    super.key,
    this.color,
    this.size = CatchLayout.badgeMdDotExtent,
    this.borderColor,
    this.semanticsLabel,
  });

  final Color? color;
  final double size;
  final Color? borderColor;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final dot = DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? t.primary,
        shape: BoxShape.circle,
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: SizedBox.square(dimension: size),
    );
    return semanticsLabel == null
        ? dot
        : Semantics(
            label: semanticsLabel,
            child: ExcludeSemantics(child: dot),
          );
  }
}
