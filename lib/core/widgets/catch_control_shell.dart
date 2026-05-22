import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

enum CatchControlSize { floating, compact, md }

enum CatchControlShape { rounded, pill }

enum CatchControlTone { surface, raised }

abstract final class CatchControlMetrics {
  static const double floatingMinHeight = 44;
  static const double compactMinHeight = 52;
  static const double mdMinHeight = 56;
  static const double floatingIconExtent = 40;
  static const double compactIconExtent = compactMinHeight;
  static const double mdIconExtent = mdMinHeight;
  static const double stepperIconExtent = 44;

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

  static double radius(CatchControlShape shape) => switch (shape) {
    CatchControlShape.rounded => CatchRadius.sm,
    CatchControlShape.pill => CatchRadius.pill,
  };

  static EdgeInsets contentPadding(CatchControlSize size) => switch (size) {
    CatchControlSize.floating => const EdgeInsets.symmetric(horizontal: 12),
    CatchControlSize.compact => const EdgeInsets.symmetric(horizontal: 12),
    CatchControlSize.md => const EdgeInsets.symmetric(horizontal: 14),
  };

  static EdgeInsets textFieldContentPadding(CatchControlSize size) =>
      switch (size) {
        CatchControlSize.floating => const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 0,
        ),
        CatchControlSize.compact => const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 0,
        ),
        CatchControlSize.md => const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
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
        border: Border.all(color: _borderColor(t), width: 1.5),
        boxShadow: focused && !hasError
            ? [BoxShadow(color: t.primarySoft, blurRadius: 0, spreadRadius: 3)]
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
