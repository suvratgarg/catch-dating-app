import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_ticket_divider.dart';
import 'package:flutter/material.dart';

typedef CatchTicketSectionBuilder =
    Widget Function(BuildContext context, bool compact);

/// Ticket material with a hero recipe for a bounded, collapsing surface.
///
/// Owns the media/body split, perforation and fitted body width. Both builders
/// receive the same compact state; callers retain content and outer paint.
class CatchTicket extends StatelessWidget {
  const CatchTicket.hero({
    super.key,
    required this.mediaBuilder,
    this.lineColor,
    required this.bodyBuilder,
  });

  final CatchTicketSectionBuilder mediaBuilder;
  final Color? lineColor;
  final CatchTicketSectionBuilder bodyBuilder;

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
              child: mediaBuilder(context, compact),
            ),
            CatchTicketDivider(lineColor: lineColor),
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
