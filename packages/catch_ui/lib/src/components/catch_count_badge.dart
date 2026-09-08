import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_surface.dart';
import 'package:flutter/material.dart';

String catchCountLabel(int count) => count > 99 ? '99+' : '$count';

/// Canonical integer count marker.
///
/// The default constructor overlays the count on [child]. Use
/// [CatchCountBadge.label] when a semantic adapter needs the count marker by
/// itself. Both forms hide at zero and share the same `99+` clamp.
class CatchCountBadge extends StatelessWidget {
  const CatchCountBadge({
    super.key,
    required this.count,
    required Widget this._child,
    this.alignment = Alignment.topRight,
    this.offset = const Offset(-2, 2),
  }) : semanticsLabel = null;

  const CatchCountBadge.label({
    super.key,
    required this.count,
    this.semanticsLabel,
  }) : _child = null,
       alignment = Alignment.center,
       offset = Offset.zero;

  final int count;
  final String? semanticsLabel;
  final Widget? _child;
  final AlignmentGeometry alignment;
  final Offset offset;

  /// Width reserved by an attached control for the scaled count marker.
  static double labelWidth(BuildContext context, int count) {
    if (count <= 0) return 0;
    final painter = TextPainter(
      text: TextSpan(
        text: catchCountLabel(count),
        style: CatchTextStyles.statusLabel(context),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final width = CatchLayout.countBadgeWidth(painter.width);
    painter.dispose();
    return width;
  }

  @override
  Widget build(BuildContext context) {
    final child = _child;
    if (count <= 0 && child != null) return child;

    final t = CatchTokens.of(context);
    final label = count <= 0
        ? const SizedBox.shrink()
        : CatchSurface(
            radius: CatchRadius.pill,
            backgroundColor: t.primary,
            borderColor: t.surface,
            borderWidth: CatchLayout.countBadgeBorderWidth,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: CatchLayout.countBadgeMinExtent,
                minHeight: CatchLayout.countBadgeMinExtent,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CatchLayout.countBadgeHorizontalPadding,
                  vertical: CatchLayout.countBadgeVerticalPadding,
                ),
                child: Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: Text(
                    catchCountLabel(count),
                    style: CatchTextStyles.statusLabel(
                      context,
                      color: t.primaryInk,
                    ),
                  ),
                ),
              ),
            ),
          );
    if (child == null) {
      return semanticsLabel == null
          ? label
          : Semantics(
              label: semanticsLabel,
              child: ExcludeSemantics(child: label),
            );
    }

    return Stack(
      // A count must not loosen the constraints that its child receives.
      // Otherwise full-width controls shrink while the marker stays at the
      // original far edge; zero and nonzero counts would change the control.
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: OverflowBox(
              alignment: alignment,
              minWidth: 0,
              maxWidth: double.infinity,
              minHeight: 0,
              maxHeight: double.infinity,
              child: Transform.translate(offset: offset, child: label),
            ),
          ),
        ),
      ],
    );
  }
}
