import 'package:catch_dating_app/chats/presentation/widgets/chat_event_context_copy.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_tile.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_activity_visuals.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatEventContextHeader extends StatelessWidget {
  const ChatEventContextHeader({super.key, required this.event});

  final Event? event;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final event = this.event;
    final visual = event == null
        ? null
        : eventActivityVisual(event.activityKind, context: context);
    final accent = visual?.accent ?? t.primary;
    final title = event?.title ?? 'the same event';
    final date = event == null
        ? null
        : DateFormat('EEE d MMM').format(event.startTime);
    final stamp = chatContextStampFor(event);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s3,
        CatchSpacing.s2,
        CatchSpacing.s3,
        0,
      ),
      child: CatchSurface(
        backgroundColor: visual?.soft ?? t.primarySoft,
        borderColor: accent.withValues(alpha: CatchOpacity.subtleBorder),
        padding: const EdgeInsets.all(CatchSpacing.s3),
        child: Row(
          children: [
            CatchIconTile(
              icon: visual?.icon ?? CatchIcons.chatBubbleOutlineRounded,
              iconColor: accent,
              backgroundColor: t.surface,
              borderColor: accent.withValues(alpha: CatchOpacity.subtleBorder),
              size: 36,
              radius: CatchRadius.pill,
            ),
            gapW10,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stamp,
                    style: CatchTextStyles.labelM(
                      context,
                      color: accent,
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
