import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Detail-route fade and spring-scale viewport for cards, tickets and rows.
class CatchFadeScaleViewport extends StatelessWidget {
  const CatchFadeScaleViewport({
    super.key,
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: CatchMotion.standardCurve,
      reverseCurve: CatchMotion.easeInCubicCurve,
    );
    final scale = Tween<double>(begin: 0.985, end: 1).animate(curvedAnimation);
    return FadeTransition(
      opacity: curvedAnimation,
      child: ScaleTransition(scale: scale, child: child),
    );
  }
}
