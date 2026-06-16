import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Handoff map radius ring with an optional tappable mono label.
class CatchDistanceRing extends StatelessWidget {
  const CatchDistanceRing({
    super.key,
    this.size = CatchLayout.distanceRingDefaultSize,
    this.label,
    this.onTap,
  });

  final double size;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final displayLabel = label?.trim();
    final hasLabel = displayLabel != null && displayLabel.isNotEmpty;
    final labelOverhang = hasLabel
        ? CatchLayout.distanceRingLabelOverhang
        : 0.0;

    return SizedBox(
      width: size,
      height: size + labelOverhang,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: labelOverhang,
            left: 0,
            right: 0,
            height: size,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: t.ink.withValues(alpha: CatchOpacity.distanceRing),
                  width: CatchLayout.distanceRingStrokeWidth,
                ),
              ),
            ),
          ),
          if (hasLabel)
            Positioned(
              top: 0,
              child: Semantics(
                button: onTap != null,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTap,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: t.surface.withValues(
                        alpha: CatchOpacity.distanceRingLabelFill,
                      ),
                      borderRadius: BorderRadius.circular(CatchRadius.pill),
                      border: Border.all(color: t.line2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: CatchLayout.distanceRingLabelHorizontal,
                        vertical: CatchSpacing.s1,
                      ),
                      child: Text(
                        displayLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CatchTextStyles.monoLabelS(context, color: t.ink)
                            .copyWith(
                              fontSize: CatchLayout.distanceRingLabelFontSize,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
