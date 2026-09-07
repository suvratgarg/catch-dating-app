import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

class CatchButtonLoadingDots extends StatelessWidget {
  const CatchButtonLoadingDots({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const ValueKey('catch-button-loading'),
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Padding(
          padding: EdgeInsets.only(left: index == 0 ? 0 : CatchSpacing.s1),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color.withValues(
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
}
