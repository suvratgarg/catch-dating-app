import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/events/domain/event.dart';
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
    final expandedHeight = width > 600 ? 220.0 : 260.0;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      backgroundColor: t.surface,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      title: CatchCollapsedSliverTitle(
        title: event.title,
        textKey: const ValueKey('event-detail-collapsed-title'),
      ),
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
            Positioned(
              left: CatchSpacing.s5,
              right: CatchSpacing.s5,
              bottom: CatchSpacing.s5,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
