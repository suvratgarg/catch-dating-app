import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

String catchCountLabel(int count) => count > 99 ? '99+' : '$count';

/// Overlays a count pill on [child]; renders [child] alone when count <= 0.
class CatchCountBadge extends StatelessWidget {
  const CatchCountBadge({super.key, required this.count, required this.child});

  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return child;

    final t = CatchTokens.of(context);
    final label = catchCountLabel(count);

    return SizedBox(
      width: CatchLayout.appShellNavigationBadgeWidth,
      height: CatchLayout.appShellNavigationBadgeHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(alignment: Alignment.bottomCenter, child: child),
          Positioned(
            top: 0,
            right: 1,
            child: CatchSurface(
              radius: CatchRadius.pill,
              backgroundColor: t.primary,
              borderColor: t.surface,
              borderWidth: 1.5,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CatchSpacing.s1,
                    vertical: CatchStroke.hairline,
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: CatchTextStyles.statusLabel(
                        context,
                        color: t.primaryInk,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
