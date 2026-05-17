import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatEventContextHeader extends StatelessWidget {
  const ChatEventContextHeader({super.key, required this.event});

  final Event? event;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final title = event?.title ?? 'the same event';
    final date = event == null
        ? null
        : DateFormat('EEE d MMM').format(event!.startTime);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s3,
        CatchSpacing.s2,
        CatchSpacing.s3,
        0,
      ),
      child: CatchSurface(
        tone: CatchSurfaceTone.primarySoft,
        borderColor: t.line,
        padding: const EdgeInsets.all(CatchSpacing.s3),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: t.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.directions_run_rounded, color: t.primary),
            ),
            gapW10,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YOU BOTH RAN',
                    style: CatchTextStyles.labelM(
                      context,
                      color: t.primary,
                    ).copyWith(fontWeight: FontWeight.w800),
                  ),
                  gapH2,
                  Text(
                    date == null ? title : '$title · $date',
                    style: CatchTextStyles.bodyS(
                      context,
                      color: t.ink,
                    ).copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
