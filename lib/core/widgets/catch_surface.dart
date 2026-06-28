import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

enum CatchSurfaceRole { base, card, tinted, message }

enum CatchSurfaceTone { surface, raised, primarySoft, transparent }

enum CatchSurfaceElevation { none, card, raised, overlay }

enum CatchSurfaceMessageTone { primary, success, warning, danger, neutral }

/// Canonical Catch surface primitive for cards, panels, and tappable tiles.
class CatchSurface extends StatelessWidget {
  const CatchSurface({
    super.key,
    required this.child,
    this.role = CatchSurfaceRole.base,
    this.tone = CatchSurfaceTone.surface,
    this.elevation = CatchSurfaceElevation.none,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.radius = CatchRadius.lg,
    this.borderRadius,
    this.borderColor,
    this.borderWidth = 1,
    this.backgroundColor,
    this.gradient,
    this.boxShadow,
    this.clipBehavior = Clip.none,
    this.onTap,
    this.duration = CatchMotion.fast,
  }) : title = null,
       message = null,
       messageIcon = null,
       messageTone = CatchSurfaceMessageTone.primary;

  const CatchSurface.card({
    super.key,
    required this.child,
    this.padding = CatchInsets.contentRelaxed,
    this.margin,
    this.width,
    this.height,
    this.borderColor,
    this.boxShadow,
    this.tone = CatchSurfaceTone.surface,
    this.onTap,
    this.duration = CatchMotion.fast,
  }) : role = CatchSurfaceRole.card,
       elevation = CatchSurfaceElevation.card,
       radius = CatchRadius.md,
       borderRadius = null,
       borderWidth = 1,
       backgroundColor = null,
       gradient = null,
       clipBehavior = Clip.none,
       title = null,
       message = null,
       messageIcon = null,
       messageTone = CatchSurfaceMessageTone.primary;

  const CatchSurface.tinted({
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
    this.duration = CatchMotion.fast,
  }) : role = CatchSurfaceRole.tinted,
       tone = CatchSurfaceTone.primarySoft,
       elevation = CatchSurfaceElevation.none,
       width = null,
       height = null,
       borderColor = null,
       borderWidth = 0,
       gradient = null,
       boxShadow = null,
       clipBehavior = Clip.none,
       onTap = null,
       title = null,
       message = null,
       messageIcon = null,
       messageTone = CatchSurfaceMessageTone.primary;

  const CatchSurface.message({
    super.key,
    required this.message,
    this.messageIcon,
    this.messageTone = CatchSurfaceMessageTone.primary,
    this.title,
    this.padding = CatchInsets.tileContentCompact,
    this.margin,
    this.width,
    this.height,
    this.duration = CatchMotion.fast,
  }) : role = CatchSurfaceRole.message,
       child = null,
       tone = CatchSurfaceTone.surface,
       elevation = CatchSurfaceElevation.none,
       radius = CatchRadius.md,
       borderRadius = null,
       borderColor = null,
       borderWidth = 1,
       backgroundColor = null,
       gradient = null,
       boxShadow = null,
       clipBehavior = Clip.none,
       onTap = null;

  final Widget? child;
  final CatchSurfaceRole role;
  final CatchSurfaceTone tone;
  final CatchSurfaceElevation elevation;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double radius;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final Color? backgroundColor;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;
  final Clip clipBehavior;
  final VoidCallback? onTap;
  final Duration duration;
  final String? title;
  final String? message;
  final IconData? messageIcon;
  final CatchSurfaceMessageTone messageTone;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final effectiveDuration =
        MediaQuery.maybeOf(context)?.disableAnimations == true
        ? Duration.zero
        : duration;
    if (role == CatchSurfaceRole.message) {
      return _buildMessageSurface(context, t);
    }

    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(radius);
    final foreground = Padding(
      padding: padding ?? EdgeInsets.zero,
      child: child!,
    );
    final borderDecoration = borderColor == null || borderWidth <= 0
        ? null
        : BoxDecoration(
            borderRadius: effectiveBorderRadius,
            border: Border.all(color: borderColor!, width: borderWidth),
          );
    final decorated = AnimatedContainer(
      duration: effectiveDuration,
      curve: CatchMotion.standardCurve,
      width: width,
      height: height,
      margin: margin,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: gradient == null ? backgroundColor ?? _color(t) : null,
        gradient: gradient,
        borderRadius: effectiveBorderRadius,
        boxShadow: boxShadow ?? _shadows,
      ),
      foregroundDecoration: borderDecoration,
      child: onTap == null
          ? foreground
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: effectiveBorderRadius,
                child: foreground,
              ),
            ),
    );

    if (onTap == null) return decorated;
    return Semantics(button: true, child: decorated);
  }

  Widget _buildMessageSurface(BuildContext context, CatchTokens t) {
    final isNeutral = messageTone == CatchSurfaceMessageTone.neutral;
    final toneColor = switch (messageTone) {
      CatchSurfaceMessageTone.primary => t.primary,
      CatchSurfaceMessageTone.success => t.success,
      CatchSurfaceMessageTone.warning => t.warning,
      CatchSurfaceMessageTone.danger => t.danger,
      CatchSurfaceMessageTone.neutral => t.ink2,
    };

    return CatchSurface(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      radius: CatchRadius.md,
      tone: isNeutral ? CatchSurfaceTone.transparent : CatchSurfaceTone.surface,
      backgroundColor: isNeutral
          ? null
          : Color.alphaBlend(
              toneColor.withValues(alpha: CatchOpacity.calloutFill),
              t.surface,
            ),
      borderColor: isNeutral ? t.line : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: CatchStroke.hairline),
            child: Icon(
              messageIcon ?? CatchIcons.sparkle,
              size: CatchIcon.md,
              color: isNeutral ? t.ink2 : toneColor,
            ),
          ),
          const SizedBox(width: CatchSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null && title!.isNotEmpty) ...[
                  Text(title!, style: CatchTextStyles.labelL(context)),
                  const SizedBox(height: CatchSpacing.s1),
                ],
                Text(message!, style: CatchTextStyles.bodyS(context)),
              ],
            ),
          ),
        ],
      ),
    );
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
      CatchSurfaceElevation.card => CatchElevation.card,
      CatchSurfaceElevation.raised => CatchElevation.raised,
      CatchSurfaceElevation.overlay => CatchElevation.overlay,
    };
  }
}
