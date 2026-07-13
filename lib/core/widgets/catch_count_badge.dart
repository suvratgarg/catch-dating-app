import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
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
    required Widget child,
    this.alignment = Alignment.topRight,
    this.offset = const Offset(-2, 2),
  }) : _child = child;

  const CatchCountBadge.label({super.key, required this.count})
    : _child = null,
      alignment = Alignment.center,
      offset = Offset.zero;

  final int count;
  final Widget? _child;
  final AlignmentGeometry alignment;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    final child = _child;
    if (count <= 0) return child ?? const SizedBox.shrink();

    final t = CatchTokens.of(context);
    final label = CatchSurface(
      radius: CatchRadius.pill,
      backgroundColor: t.primary,
      borderColor: t.surface,
      borderWidth: CatchStroke.underline,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: CatchLayout.countBadgeMinExtent,
          minHeight: CatchLayout.countBadgeMinExtent,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: CatchSpacing.s1,
            vertical: CatchStroke.hairline,
          ),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: Text(
              catchCountLabel(count),
              style: CatchTextStyles.statusLabel(context, color: t.primaryInk),
            ),
          ),
        ),
      ),
    );
    if (child == null) return label;

    return Stack(
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
