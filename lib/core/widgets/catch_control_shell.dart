import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

enum CatchControlSize { floating, compact, md }

enum CatchControlShape { rounded, pill }

enum CatchControlTone { surface, raised }

abstract final class CatchControlMetrics {
  static const double floatingMinHeight = CatchSpacing.s11;
  static const double compactMinHeight = CatchSpacing.s12 + CatchSpacing.s1;
  static const double mdMinHeight = CatchSpacing.s12 + CatchSpacing.s2;
  static const double floatingIconExtent = CatchSpacing.s10;
  static const double compactIconExtent = compactMinHeight;
  static const double mdIconExtent = mdMinHeight;
  static const double stepperIconExtent = CatchSpacing.s11;

  static double minHeight(CatchControlSize size) => switch (size) {
    CatchControlSize.floating => floatingMinHeight,
    CatchControlSize.compact => compactMinHeight,
    CatchControlSize.md => mdMinHeight,
  };

  static double iconExtent(CatchControlSize size) => switch (size) {
    CatchControlSize.floating => floatingIconExtent,
    CatchControlSize.compact => compactIconExtent,
    CatchControlSize.md => mdIconExtent,
  };

  static BoxConstraints squareConstraints(double extent) => BoxConstraints(
    minWidth: extent,
    maxWidth: extent,
    minHeight: extent,
    maxHeight: extent,
  );

  static double radius(CatchControlShape shape) => switch (shape) {
    CatchControlShape.rounded => CatchRadius.sm,
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
          vertical: CatchSpacing.s0,
        ),
        CatchControlSize.compact => const EdgeInsets.symmetric(
          horizontal: CatchSpacing.s3,
          vertical: CatchSpacing.s0,
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
    final content = AnimatedContainer(
      duration: CatchMotion.fast,
      curve: CatchMotion.standardCurve,
      constraints: BoxConstraints(
        minHeight: CatchControlMetrics.minHeight(size),
      ),
      padding: padding ?? CatchControlMetrics.contentPadding(size),
      decoration: BoxDecoration(
        color: _fillColor(t),
        borderRadius: radius,
        border: Border.all(
          color: _borderColor(t),
          width: CatchStroke.underline,
        ),
        boxShadow: focused && !hasError
            ? CatchElevation.focusRing(t)
            : CatchElevation.none,
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

  Color _borderColor(CatchTokens t) {
    if (hasError) return t.danger;
    if (!enabled) return t.line;
    if (focused) return t.primary;
    return t.line2;
  }
}
