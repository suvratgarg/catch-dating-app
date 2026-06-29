import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Bridges preview-tab overscroll back into the outer [NestedScrollView] header,
/// creating a unified scroll experience where upward drags in the preview tab
/// collapse the profile header before the preview content scrolls.
class PreviewHeaderBridgeScrollPhysics extends ClampingScrollPhysics {
  const PreviewHeaderBridgeScrollPhysics({
    required this.onForwardScroll,
    super.parent,
  });

  final double Function(double scrollDelta) onForwardScroll;

  @override
  PreviewHeaderBridgeScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return PreviewHeaderBridgeScrollPhysics(
      onForwardScroll: onForwardScroll,
      parent: buildParent(ancestor),
    );
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    final childOffset = super.applyPhysicsToUserOffset(position, offset);
    if (childOffset >= 0) return childOffset;

    final consumedByHeader = onForwardScroll(-childOffset);
    if (consumedByHeader <= 0) return childOffset;

    return childOffset + math.min(consumedByHeader, -childOffset);
  }
}
