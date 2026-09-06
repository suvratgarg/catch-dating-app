import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_distance_ring_label.dart';
import 'package:flutter/material.dart';

/// Fixed-diameter ring geometry and optional edge-label placement.
class CatchDistanceRingViewport extends StatelessWidget {
  const CatchDistanceRingViewport({
    super.key,
    required this.size,
    required this.label,
    required this.semanticLabel,
    required this.semanticHint,
    required this.onTap,
  });

  final double size;
  final String? label;
  final String? semanticLabel;
  final String? semanticHint;
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
              child: CatchDistanceRingLabel(
                label: displayLabel,
                semanticLabel: semanticLabel,
                semanticHint: semanticHint,
                onTap: onTap,
              ),
            ),
        ],
      ),
    );
  }
}
