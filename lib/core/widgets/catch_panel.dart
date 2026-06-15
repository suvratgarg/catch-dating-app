import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

/// Handoff `Panel`: bounded card surface for self-contained groups and flow
/// stages.
class CatchPanel extends StatelessWidget {
  const CatchPanel({
    super.key,
    required this.child,
    this.padding = CatchInsets.contentRelaxed,
    this.margin,
    this.width,
    this.height,
    this.borderColor,
    this.tone = CatchSurfaceTone.surface,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? borderColor;
  final CatchSurfaceTone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      tone: tone,
      elevation: CatchSurfaceElevation.card,
      radius: CatchRadius.md,
      borderColor: borderColor ?? t.line,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      onTap: onTap,
      child: child,
    );
  }
}
