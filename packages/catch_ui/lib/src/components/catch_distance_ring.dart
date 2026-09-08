import 'dart:math' as math;

import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_distance_ring_viewport.dart';
import 'package:flutter/material.dart';

/// Map radius ring with an optional readable, wrapping control-role label.
class CatchDistanceRing extends StatelessWidget {
  const CatchDistanceRing({
    super.key,
    this.size = CatchLayout.distanceRingDefaultSize,
    this.fitAvailable = false,
    this.label,
    this.semanticLabel,
    this.semanticHint,
    this.onTap,
  });

  final double size;
  final bool fitAvailable;
  final String? label;
  final String? semanticLabel;
  final String? semanticHint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (fitAvailable) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final available = CatchLayout.distanceRingAvailableDiameterFor(
            constraints.biggest,
          );
          return CatchDistanceRingViewport(
            size: math.min(size, available),
            label: label,
            semanticLabel: semanticLabel,
            semanticHint: semanticHint,
            onTap: onTap,
          );
        },
      );
    }
    return CatchDistanceRingViewport(
      size: size,
      label: label,
      semanticLabel: semanticLabel,
      semanticHint: semanticHint,
      onTap: onTap,
    );
  }
}
