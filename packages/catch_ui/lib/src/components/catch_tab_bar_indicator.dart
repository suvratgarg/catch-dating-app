import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

class CatchTabBarIndicator extends StatelessWidget {
  const CatchTabBarIndicator({
    super.key,
    required this.color,
    required this.focused,
  });

  final Color color;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    final disabledAnimations = MediaQuery.maybeOf(context)?.disableAnimations;
    return AnimatedContainer(
      duration: disabledAnimations == true
          ? Duration.zero
          : CatchMotion.standard,
      curve: CatchMotion.standardCurve,
      decoration: ShapeDecoration(
        color: color,
        shape: StadiumBorder(
          side: focused
              ? CatchBorder.resolve(
                  CatchTokens.of(context),
                  CatchBorderRole.focus,
                ).side
              : BorderSide.none,
        ),
      ),
    );
  }
}
