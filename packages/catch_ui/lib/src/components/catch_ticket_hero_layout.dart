import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

typedef CatchTicketHeroSectionBuilder =
    Widget Function(BuildContext context, bool compact);

/// Canonical adaptive flight for a large ticket hero.
///
/// It owns the visual/body split and fitted body width so callers only
/// provide semantic sections rather than measuring the collapsing hero box.
class CatchTicketHeroLayout extends StatelessWidget {
  const CatchTicketHeroLayout({
    super.key,
    required this.visualBuilder,
    required this.divider,
    required this.bodyBuilder,
  });

  final CatchTicketHeroSectionBuilder visualBuilder;
  final Widget divider;
  final CatchTicketHeroSectionBuilder bodyBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxHeight <
            CatchLayout.eventDetailTicketCompactHeightThreshold;
        final visualHeight =
            (constraints.maxHeight *
                    (compact
                        ? CatchLayout.eventDetailTicketVisualCompactRatio
                        : CatchLayout.eventDetailTicketVisualExpandedRatio))
                .clamp(
                  CatchLayout.eventDetailTicketVisualMinHeight,
                  CatchLayout.eventDetailTicketVisualMaxHeight,
                )
                .toDouble();
        final bodyPadding = compact
            ? const EdgeInsets.fromLTRB(
                CatchSpacing.s4,
                CatchSpacing.s2,
                CatchSpacing.s4,
                CatchSpacing.s3,
              )
            : CatchInsets.pageBody.copyWith(
                top: CatchSpacing.s4,
                bottom: CatchSpacing.s5,
              );
        final bodyWidth = constraints.maxWidth > bodyPadding.horizontal
            ? constraints.maxWidth - bodyPadding.horizontal
            : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: visualHeight,
              child: visualBuilder(context, compact),
            ),
            divider,
            Expanded(
              child: Padding(
                padding: bodyPadding,
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: bodyWidth,
                    child: bodyBuilder(context, compact),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
