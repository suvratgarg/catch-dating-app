import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

class CatchPageDots extends StatelessWidget {
  const CatchPageDots({
    super.key,
    required this.selectedIndex,
    required this.itemCount,
    this.semanticLabel,
    this.selectedWidth = 22,
    this.dotWidth = 6,
    this.dotHeight = 6,
  });

  final int selectedIndex;
  final int itemCount;
  final String? semanticLabel;
  final double selectedWidth;
  final double dotWidth;
  final double dotHeight;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Semantics(
      label: semanticLabel,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: CatchSpacing.s1,
        runSpacing: CatchSpacing.s1,
        children: [
          for (var index = 0; index < itemCount; index += 1)
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              width: index == selectedIndex ? selectedWidth : dotWidth,
              height: dotHeight,
              decoration: BoxDecoration(
                color: index == selectedIndex
                    ? t.primary
                    : t.line2.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(CatchRadius.pill),
              ),
            ),
        ],
      ),
    );
  }
}
