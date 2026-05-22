import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_detail_hero_backdrop.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_photo_header.dart';
import 'package:flutter/material.dart';

class EventDetailHeroAppBar extends StatelessWidget {
  const EventDetailHeroAppBar({
    super.key,
    required this.event,
    required this.isSaved,
    required this.savePending,
    required this.onBack,
    required this.onShare,
    required this.onToggleSaved,
    required this.showAddToCalendar,
    required this.onAddToCalendar,
  });

  final Event event;
  final bool isSaved;
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
    final hasPhoto = CatchDetailHeroBackdrop.hasImage(event.photoUrl);
    final expandedHeight = width > 600
        ? (hasPhoto ? 220.0 : 172.0)
        : (hasPhoto ? 300.0 : 220.0);

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      backgroundColor: t.surface,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CatchTopBarIconAction(
          icon: Icons.arrow_back_ios_new_rounded,
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
              icon: Icons.ios_share_rounded,
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
                icon: Icons.calendar_month_outlined,
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
            icon: isSaved
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
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
            Positioned(
              left: CatchSpacing.s5,
              right: CatchSpacing.s5,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.displayL(
                      context,
                      color: Colors.white,
                    ),
                  ),
                  gapH8,
                  Row(
                    children: [
                      const Icon(
                        Icons.event_outlined,
                        size: 16,
                        color: Colors.white70,
                      ),
                      gapW4,
                      Expanded(
                        child: Text(
                          '${event.longDateLabel} · ${event.timeRangeLabel}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CatchTextStyles.bodyS(
                            context,
                            color: Colors.white.withValues(alpha: 0.82),
                          ),
                        ),
                      ),
                    ],
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
