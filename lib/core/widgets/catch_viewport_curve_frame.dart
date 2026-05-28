import 'dart:math' as math;

import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Clips inset content to the device viewport's top-corner curve.
///
/// Flutter does not expose the physical display corner radius directly, so this
/// derives the curve from the active view's safe-area inset and shortest side.
/// The result keeps a constant base inset, then deflates the top viewport curve
/// by that inset so content follows the phone glass instead of forming a hard
/// rectangle near the top corners.
class CatchViewportCurveFrame extends StatelessWidget {
  const CatchViewportCurveFrame({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.paddingKey,
    this.backgroundColor,
    this.cornerRadius = CatchRadius.lg,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Key? paddingKey;
  final Color? backgroundColor;
  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final textDirection = Directionality.of(context);
    final resolvedPadding = padding.resolve(textDirection);
    final viewportTopRadius = catchViewportTopCornerRadius(
      MediaQuery.of(context),
      fallbackRadius: cornerRadius,
    );

    return ClipRSuperellipse(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      clipper: _CatchViewportCurveFrameClipper(
        padding: resolvedPadding,
        viewportTopRadius: viewportTopRadius,
        cornerRadius: cornerRadius,
      ),
      child: ColoredBox(
        color: backgroundColor ?? t.surface,
        child: Padding(key: paddingKey, padding: padding, child: child),
      ),
    );
  }
}

double catchViewportTopCornerRadius(
  MediaQueryData mediaQuery, {
  double fallbackRadius = CatchRadius.lg,
}) {
  final shortestSide = mediaQuery.size.shortestSide;
  final topInset = mediaQuery.padding.top;
  if (shortestSide <= 0 || topInset <= 0) return fallbackRadius;

  final maxRadius = math.max(fallbackRadius, shortestSide * 0.18);
  final derivedRadius = topInset * 1.08;
  return derivedRadius.clamp(fallbackRadius, maxRadius).toDouble();
}

class _CatchViewportCurveFrameClipper extends CustomClipper<RSuperellipse> {
  const _CatchViewportCurveFrameClipper({
    required this.padding,
    required this.viewportTopRadius,
    required this.cornerRadius,
  });

  final EdgeInsets padding;
  final double viewportTopRadius;
  final double cornerRadius;

  @override
  RSuperellipse getClip(Size size) {
    final left = padding.left.clamp(0.0, size.width / 2).toDouble();
    final top = padding.top.clamp(0.0, size.height / 2).toDouble();
    final right = math.max(left, size.width - padding.right);
    final bottom = math.max(top, size.height - padding.bottom);
    final rect = Rect.fromLTRB(left, top, right, bottom);
    if (rect.isEmpty) {
      return RSuperellipse.fromRectAndCorners(Offset.zero & size);
    }

    final topDeflate = math.min(left, top);
    final topRadius = math.max(cornerRadius, viewportTopRadius - topDeflate);
    final maxCorner = rect.shortestSide / 2;

    return RSuperellipse.fromRectAndCorners(
      rect,
      topLeft: Radius.circular(math.min(topRadius, maxCorner)),
      topRight: Radius.circular(math.min(topRadius, maxCorner)),
      bottomLeft: Radius.circular(math.min(cornerRadius, maxCorner)),
      bottomRight: Radius.circular(math.min(cornerRadius, maxCorner)),
    );
  }

  @override
  bool shouldReclip(_CatchViewportCurveFrameClipper oldClipper) {
    return padding != oldClipper.padding ||
        viewportTopRadius != oldClipper.viewportTopRadius ||
        cornerRadius != oldClipper.cornerRadius;
  }
}
