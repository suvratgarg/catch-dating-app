import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Scrolls overflowing content while keeping short content at least as tall as
/// the available viewport.
///
/// This is the box-layout counterpart to `SliverFillRemaining`: full-screen
/// flows can keep their content vertically grounded without each feature
/// measuring and rebuilding against local constraints.
class CatchFillViewportScrollView extends StatelessWidget {
  const CatchFillViewportScrollView({
    super.key,
    required this.child,
    this.scrollViewKey,
    this.padding = EdgeInsets.zero,
    this.maxContentWidth,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final Key? scrollViewKey;
  final EdgeInsetsGeometry padding;
  final double? maxContentWidth;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        key: scrollViewKey,
        child: Align(
          alignment: alignment,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
              minWidth: math.min(
                constraints.maxWidth,
                maxContentWidth ?? constraints.maxWidth,
              ),
              maxWidth: maxContentWidth ?? constraints.maxWidth,
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
