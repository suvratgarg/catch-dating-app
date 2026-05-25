import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_tile.dart';
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
            CatchIconTile(
              icon: Icons.directions_run_rounded,
              iconColor: t.primary,
              backgroundColor: t.surface,
              borderColor: Colors.transparent,
              size: 36,
              radius: CatchRadius.pill,
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
                    style: CatchTextStyles.supporting(
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
