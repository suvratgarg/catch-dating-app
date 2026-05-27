import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_corner_sash.dart';
import 'package:catch_dating_app/core/widgets/catch_event_card_hero.dart';
import 'package:catch_dating_app/core/widgets/catch_kicker.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_photo_header.dart';
import 'package:flutter/material.dart';

class EventDetailHeroAppBar extends StatelessWidget {
  const EventDetailHeroAppBar({
    super.key,
    required this.event,
    required this.isSaved,
    required this.isHost,
    required this.participation,
    required this.savePending,
    required this.onBack,
    required this.onShare,
    required this.onToggleSaved,
    required this.showAddToCalendar,
    required this.onAddToCalendar,
  });

  final Event event;
  final bool isSaved;
  final bool isHost;
  final EventParticipation? participation;
  final bool savePending;
  final VoidCallback onBack;
  final ValueChanged<BuildContext> onShare;
  final VoidCallback onToggleSaved;
  final bool showAddToCalendar;
  final ValueChanged<BuildContext> onAddToCalendar;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final width = MediaQuery.of(context).size.width;
    final expandedHeight = width > 600 ? 220.0 : 300.0;
    final sash = _sashSpec(
      isHost: isHost,
      isSaved: isSaved,
      participation: participation,
    );

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      backgroundColor: t.surface,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CatchTopBarIconAction(
          icon: CatchIcons.backArrow,
          tooltip: 'Back',
          backgroundColor: Colors.black.withValues(alpha: 0.35),
          onPressed: onBack,
          foregroundColor: Colors.white,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Builder(
            builder: (buttonContext) => CatchTopBarIconAction(
              icon: CatchIcons.platformShare(
                platform: Theme.of(context).platform,
              ),
              tooltip: 'Share event',
              backgroundColor: Colors.black.withValues(alpha: 0.35),
              onPressed: () => onShare(buttonContext),
              foregroundColor: Colors.white,
            ),
          ),
        ),
        if (showAddToCalendar)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
            child: Builder(
              builder: (buttonContext) => CatchTopBarIconAction(
                icon: CatchIcons.calendarAdd,
                tooltip: 'Add to calendar',
                backgroundColor: Colors.black.withValues(alpha: 0.35),
                onPressed: () => onAddToCalendar(buttonContext),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
          child: CatchTopBarIconAction(
            icon: isSaved ? CatchIcons.saved : CatchIcons.savedOutlined,
            tooltip: isSaved ? 'Unsave event' : 'Save event',
            backgroundColor: Colors.black.withValues(alpha: 0.35),
            onPressed: savePending ? null : onToggleSaved,
            foregroundColor: Colors.white,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Stack(
          fit: StackFit.expand,
          children: [
            EventPhotoHeader(event: event),
            if (sash != null)
              Positioned(
                top: kToolbarHeight + 12,
                left: CatchSpacing.s5,
                child: CatchCornerSash(
                  label: sash.label,
                  icon: sash.icon,
                  tone: sash.tone,
                ),
              ),
            Positioned(
              left: CatchSpacing.s5,
              right: CatchSpacing.s5,
              bottom: CatchSpacing.s5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CatchKicker(
                    label:
                        '${EventFormatters.shortWeekday(event.startTime)} · ${EventFormatters.time(event.startTime)}',
                    color: Colors.white.withValues(alpha: 0.92),
                    size: CatchKickerSize.md,
                  ),
                  gapH8,
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.displayL(
                      context,
                      color: Colors.white,
                    ),
                  ),
                  gapH6,
                  Text(
                    '${event.longDateLabel} · ${event.timeRangeLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.supporting(
                      context,
                      color: Colors.white.withValues(alpha: 0.86),
                    ),
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

CatchEventSashSpec? _sashSpec({
  required bool isHost,
  required bool isSaved,
  required EventParticipation? participation,
}) {
  if (isHost) {
    return CatchEventSashSpec(
      label: 'You host',
      icon: CatchIcons.hostBadge,
      tone: CatchSashTone.solid,
    );
  }
  switch (participation?.status) {
    case EventParticipationStatus.signedUp:
      return CatchEventSashSpec(
        label: "You're in",
        icon: CatchIcons.joinedCheck,
        tone: CatchSashTone.success,
      );
    case EventParticipationStatus.waitlisted:
      return CatchEventSashSpec(
        label: 'Waitlisted',
        icon: CatchIcons.waitlisted,
        tone: CatchSashTone.solid,
      );
    case EventParticipationStatus.attended:
      return const CatchEventSashSpec(
        label: 'Attended',
        tone: CatchSashTone.success,
      );
    case EventParticipationStatus.cancelled:
    case EventParticipationStatus.deleted:
    case null:
      break;
  }
  if (isSaved) {
    return CatchEventSashSpec(
      label: 'Saved',
      icon: CatchIcons.saved,
      tone: CatchSashTone.solid,
    );
  }
  return null;
}
