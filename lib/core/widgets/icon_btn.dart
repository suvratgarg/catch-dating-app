import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Circular 40 px icon button used in top-bars, map overlays, and nav rows.
///
/// Mirrors the `IconBtn` primitive in primitives.jsx:
/// - 40 × 40 circle
/// - [CatchTokens.raised] fill (or custom [background])
/// - 1 px [CatchTokens.line] border
/// - ripple via [InkWell]
///
/// Usage:
/// ```dart
/// IconBtn(onTap: () {}, child: Icon(Icons.notifications_outlined))
///
/// // Solid dark variant (map filter button)
/// IconBtn(background: t.ink, child: Icon(Icons.tune, color: t.surface))
///
/// // Frosted-glass (over hero photos) — pass semi-transparent bg
/// IconBtn(background: Colors.white.withOpacity(0.9), child: ...)
/// ```
class IconBtn extends StatelessWidget {
  const IconBtn({
    super.key,
    required this.child,
    this.onTap,
    this.background,
    this.size = 40,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;

  /// Override fill colour. Defaults to [CatchTokens.raised].
  final Color? background;

  /// Diameter of the button circle. Defaults to 40.
  final double size;

  /// Override shape radius. Defaults to [CatchRadius.pill] (full circle).
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final radius = borderRadius ?? CatchRadius.pill;
    final bg = background ?? t.raised;

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: t.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox.square(
          dimension: size,
          child: Center(child: child),
        ),
      ),
    );
  }
}
