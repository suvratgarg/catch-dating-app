import 'dart:math' as math;

import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

enum CatchControlSize { floating, compact, md }

enum CatchControlShape { rounded, pill }

enum CatchControlTone { surface, raised }

abstract final class CatchControlMetrics {
  static const double floatingMinHeight = CatchSpacing.s11;
  static const double compactMinHeight = CatchLayout.controlCompactMinHeight;
  static const double mdMinHeight = CatchLayout.controlMdMinHeight;
  static const double floatingIconExtent = CatchSpacing.s10;
  static const double compactIconExtent = compactMinHeight;
  static const double mdIconExtent = mdMinHeight;
  static const double stepperIconExtent = CatchSpacing.s11;

  static double minHeight(CatchControlSize size) =>
      math.max(CatchPlatformTokens.minimumInteractiveExtent, switch (size) {
        CatchControlSize.floating => floatingMinHeight,
        CatchControlSize.compact => compactMinHeight,
        CatchControlSize.md => mdMinHeight,
      });

  static double iconExtent(CatchControlSize size) =>
      math.max(CatchPlatformTokens.minimumInteractiveExtent, switch (size) {
        CatchControlSize.floating => floatingIconExtent,
        CatchControlSize.compact => compactIconExtent,
        CatchControlSize.md => mdIconExtent,
      });

  static BoxConstraints squareConstraints(double extent) => BoxConstraints(
    minWidth: math.max(extent, CatchPlatformTokens.minimumInteractiveExtent),
    maxWidth: math.max(extent, CatchPlatformTokens.minimumInteractiveExtent),
    minHeight: math.max(extent, CatchPlatformTokens.minimumInteractiveExtent),
    maxHeight: math.max(extent, CatchPlatformTokens.minimumInteractiveExtent),
  );

  static double radius(CatchControlShape shape) => switch (shape) {
    // Boxed inputs use the design-system interactive-tile radius (12), not sm.
    CatchControlShape.rounded => CatchRadius.interactiveTile,
    CatchControlShape.pill => CatchRadius.pill,
  };

  static EdgeInsets contentPadding(CatchControlSize size) => switch (size) {
    CatchControlSize.floating => const EdgeInsets.symmetric(
      horizontal: CatchSpacing.s3,
    ),
    CatchControlSize.compact => const EdgeInsets.symmetric(
      horizontal: CatchSpacing.s3,
    ),
    CatchControlSize.md => const EdgeInsets.symmetric(
      horizontal: CatchSpacing.micro14,
    ),
  };

  static EdgeInsets textFieldContentPadding(CatchControlSize size) =>
      switch (size) {
        CatchControlSize.floating => const EdgeInsets.symmetric(
          horizontal: CatchSpacing.s3,
        ),
        CatchControlSize.compact => const EdgeInsets.symmetric(
          horizontal: CatchSpacing.s3,
        ),
        CatchControlSize.md => const EdgeInsets.symmetric(
          horizontal: CatchSpacing.micro14,
          vertical: CatchSpacing.micro14,
        ),
      };
}

class CatchControlShell extends StatelessWidget {
  const CatchControlShell({
    super.key,
    required this.child,
    this.size = CatchControlSize.md,
    this.shape = CatchControlShape.rounded,
    this.tone = CatchControlTone.surface,
    this.enabled = true,
    this.hasError = false,
    this.focused = false,
    this.padding,
    this.onTap,
    this.semanticButton = false,
  });

  final Widget child;
  final CatchControlSize size;
  final CatchControlShape shape;
  final CatchControlTone tone;
  final bool enabled;
  final bool hasError;
  final bool focused;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool semanticButton;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final radius = BorderRadius.circular(CatchControlMetrics.radius(shape));
    final border = CatchBorder.interactive(
      t,
      hasError
          ? CatchInteractiveBorderState.error
          : !enabled
          ? CatchInteractiveBorderState.disabled
          : focused
          ? CatchInteractiveBorderState.focused
          : CatchInteractiveBorderState.resting,
    );
    final contentPadding = padding ?? CatchControlMetrics.contentPadding(size);
    final content = AnimatedContainer(
      duration: CatchMotion.fast,
      curve: CatchMotion.standardCurve,
      constraints: BoxConstraints(
        minHeight: CatchControlMetrics.minHeight(size),
        minWidth: CatchPlatformTokens.minimumInteractiveExtent,
      ),
      // Reserve a stable emphasis-stroke footprint. The semantic border paints
      // in the foreground, so rest/error/focus widths never change layout.
      padding: contentPadding.add(const EdgeInsets.all(CatchStroke.emphasis)),
      decoration: BoxDecoration(
        color: _fillColor(t),
        borderRadius: radius,
        boxShadow: focused && !hasError
            ? CatchElevation.focusRing(t)
            : CatchElevation.none,
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: radius,
        border: border.all,
      ),
      child: child,
    );

    final tappable = onTap == null
        ? content
        : Material(
            color: Colors.transparent,
            borderRadius: radius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(onTap: onTap, borderRadius: radius, child: content),
          );

    if (!semanticButton) return tappable;
    return Semantics(button: true, enabled: enabled, child: tappable);
  }

  Color _fillColor(CatchTokens t) {
    if (!enabled) return t.raised;
    return switch (tone) {
      CatchControlTone.surface => t.surface,
      CatchControlTone.raised => t.raised,
    };
  }
}
