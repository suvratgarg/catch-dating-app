import 'package:catch_dating_app/chats/presentation/widgets/chat_event_context_copy.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_tile.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_activity_visuals.dart';
import 'package:flutter/material.dart';

const EdgeInsets _contextHeaderOuterPadding = EdgeInsets.fromLTRB(
  CatchSpacing.s3,
  CatchSpacing.s2,
  CatchSpacing.s3,
  0,
);

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
        : AppTimeFormatters.weekdayDayMonth(event.startTime);
    final stamp = chatContextStampFor(event);

    return Padding(
      padding: _contextHeaderOuterPadding,
      child: CatchSurface(
        radius: CatchRadius.md,
        backgroundColor: visual?.soft ?? t.primarySoft,
        borderColor: accent.withValues(alpha: CatchOpacity.subtleBorder),
        padding: const EdgeInsets.symmetric(
          horizontal: CatchSpacing.s3,
          vertical: CatchSpacing.micro10,
        ),
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
                    style: CatchTextStyles.badge(
                      context,
                      color: accent,
                    ).copyWith(fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                  gapH2,
                  Text(
                    date == null ? title : '$title · $date',
                    style: CatchTextStyles.chatThreadContext(
                      context,
                      color: t.ink,
                    ),
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
