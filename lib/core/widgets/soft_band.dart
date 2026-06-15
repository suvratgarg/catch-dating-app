import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

/// Handoff `SoftBand`: a quiet primary-soft inset row for privacy notes, tips,
/// and secondary details inside panels or sections.
class SoftBand extends StatelessWidget {
  const SoftBand({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: CatchSpacing.micro14,
      vertical: CatchSpacing.s3,
    ),
    this.margin,
    this.radius = CatchRadius.sm,
    this.borderRadius,
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return CatchSurface(
      tone: CatchSurfaceTone.primarySoft,
      padding: padding,
      margin: margin,
      radius: radius,
      borderRadius: borderRadius,
      borderWidth: 0,
      backgroundColor: backgroundColor,
      child: child,
    );
  }
}
