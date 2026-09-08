import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

enum CatchLoadingIndicatorVariant { circular, dots }

/// Indeterminate activity feedback with circular and static inline-dot recipes.
class CatchLoadingIndicator extends StatelessWidget {
  const CatchLoadingIndicator({
    super.key,
    this.strokeWidth = CatchStroke.progressIndicator,
    this.color,
  }) : variant = CatchLoadingIndicatorVariant.circular;

  /// Compact motion-independent feedback for busy button content.
  const CatchLoadingIndicator.dots({super.key, required Color this.color})
    : strokeWidth = CatchStroke.progressIndicator,
      variant = CatchLoadingIndicatorVariant.dots;

  final CatchLoadingIndicatorVariant variant;
  final double strokeWidth;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (variant == CatchLoadingIndicatorVariant.dots) {
      return Row(
        key: const ValueKey('catch-button-loading'),
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : CatchSpacing.s1),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color!.withValues(
                  alpha: CatchOpacity.loadingDotAlphas[index],
                ),
                borderRadius: BorderRadius.circular(CatchRadius.pill),
              ),
              child: const SizedBox.square(dimension: CatchSpacing.micro6),
            ),
          );
        }),
      );
    }
    return Center(
      child: CircularProgressIndicator(strokeWidth: strokeWidth, color: color),
    );
  }
}
