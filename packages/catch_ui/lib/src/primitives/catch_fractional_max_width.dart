import 'package:flutter/material.dart';

/// Sizes a child to a fraction of its local lane, capped at an absolute width.
///
/// The inner alignment loosens the fractional box's tight constraint before
/// applying the cap, preserving the smaller of the two limits without a
/// build-time measurement.
class CatchFractionalMaxWidth extends StatelessWidget {
  const CatchFractionalMaxWidth({
    super.key,
    required this.fraction,
    required this.maxWidth,
    required this.child,
    this.alignment = Alignment.center,
  });

  final double fraction;
  final double maxWidth;
  final AlignmentGeometry alignment;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: fraction,
      child: Align(
        alignment: alignment,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
