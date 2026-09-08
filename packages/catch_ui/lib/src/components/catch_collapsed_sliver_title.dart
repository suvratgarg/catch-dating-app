import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:flutter/material.dart';

/// Toolbar title that appears only after a flexible sliver header collapses.
class CatchCollapsedSliverTitle extends StatelessWidget {
  const CatchCollapsedSliverTitle({
    super.key,
    required this.title,
    this.textKey,
    this.color,
    this.style,
  });

  static const double _fadeExtent = CatchLayout.topBarCollapsedFadeExtent;

  final String title;
  final Key? textKey;
  final Color? color;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final settings = context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    final opacity = settings == null ? 1.0 : _opacityFor(settings);

    if (opacity <= 0) return const SizedBox.shrink();

    final t = CatchTokens.of(context);

    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: Text(
          title,
          key: textKey,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:
              style ?? CatchTextStyles.titleL(context, color: color ?? t.ink),
        ),
      ),
    );
  }

  static double _opacityFor(FlexibleSpaceBarSettings settings) {
    final distanceFromCollapsed = settings.currentExtent - settings.minExtent;
    if (distanceFromCollapsed <= 0) return 1.0;
    if (distanceFromCollapsed >= _fadeExtent) return 0.0;
    return 1 - (distanceFromCollapsed / _fadeExtent);
  }
}
