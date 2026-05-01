import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

enum CatchSurfaceTone { surface, raised, primarySoft, transparent }

enum CatchSurfaceElevation { none, raised, overlay }

/// Canonical Catch surface primitive for cards, panels, and tappable tiles.
class CatchSurface extends StatelessWidget {
  const CatchSurface({
    super.key,
    required this.child,
    this.tone = CatchSurfaceTone.surface,
    this.elevation = CatchSurfaceElevation.none,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.radius = CatchRadius.lg,
    this.borderColor,
    this.borderWidth = 1,
    this.backgroundColor,
    this.gradient,
    this.boxShadow,
    this.clipBehavior = Clip.none,
    this.onTap,
    this.duration = CatchMotion.fast,
  });

  final Widget child;
  final CatchSurfaceTone tone;
  final CatchSurfaceElevation elevation;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double radius;
  final Color? borderColor;
  final double borderWidth;
  final Color? backgroundColor;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;
  final Clip clipBehavior;
  final VoidCallback? onTap;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final borderRadius = BorderRadius.circular(radius);
    final foreground = Padding(
      padding: padding ?? EdgeInsets.zero,
      child: child,
    );
    final decorated = AnimatedContainer(
      duration: duration,
      curve: CatchMotion.standardCurve,
      width: width,
      height: height,
      margin: margin,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: gradient == null ? backgroundColor ?? _color(t) : null,
        gradient: gradient,
        borderRadius: borderRadius,
        border: borderColor == null || borderWidth <= 0
            ? null
            : Border.all(color: borderColor!, width: borderWidth),
        boxShadow: boxShadow ?? _shadows,
      ),
      child: onTap == null
          ? foreground
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: borderRadius,
                child: foreground,
              ),
            ),
    );

    if (onTap == null) return decorated;
    return Semantics(button: true, child: decorated);
  }

  Color _color(CatchTokens t) {
    return switch (tone) {
      CatchSurfaceTone.surface => t.surface,
      CatchSurfaceTone.raised => t.raised,
      CatchSurfaceTone.primarySoft => t.primarySoft,
      CatchSurfaceTone.transparent => Colors.transparent,
    };
  }

  List<BoxShadow> get _shadows {
    return switch (elevation) {
      CatchSurfaceElevation.none => CatchElevation.none,
      CatchSurfaceElevation.raised => CatchElevation.raised,
      CatchSurfaceElevation.overlay => CatchElevation.overlay,
    };
  }
}
