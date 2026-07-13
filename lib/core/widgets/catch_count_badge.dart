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
    if (child == null) {
      return count <= 0
          ? const SizedBox.shrink()
          : _CatchCountLabel(count: count);
    }
    if (count <= 0) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: Align(
              alignment: alignment,
              child: Transform.translate(
                offset: offset,
                child: _CatchCountLabel(count: count),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CatchCountLabel extends StatelessWidget {
  const _CatchCountLabel({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final label = catchCountLabel(count);

    return CatchSurface(
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
            child: Text(
              label,
              style: CatchTextStyles.statusLabel(context, color: t.primaryInk),
            ),
          ),
        ),
      ),
    );
  }
}
