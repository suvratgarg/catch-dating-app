import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

class ExploreDarkPill extends StatelessWidget {
  const ExploreDarkPill(this.label, {super.key, this.compact = false});

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final pillPadding = EdgeInsets.symmetric(
      horizontal: compact
          ? CatchLayout.compactDarkPillHorizontalPadding
          : CatchSpacing.s3,
      vertical: compact
          ? CatchLayout.compactDarkPillVerticalPadding
          : CatchSpacing.s2,
    );

    return CatchSurface(
      radius: CatchRadius.pill,
      backgroundColor: t.ink,
      borderWidth: 0,
      padding: pillPadding,
      child: Text(
        label,
        style: CatchTextStyles.labelM(context, color: t.primaryInk),
      ),
    );
  }
}

class ExploreMonoLabel extends StatelessWidget {
  const ExploreMonoLabel(this.label, {super.key, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: CatchTextStyles.kicker(context, color: color),
    );
  }
}
