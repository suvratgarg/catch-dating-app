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

    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: t.surface,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CatchTopBarIconAction(
          icon: Icons.arrow_back_ios_new_rounded,
          tooltip: 'Back',
          background: t.surface,
          onPressed: onBack,
          foregroundColor: t.ink,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Builder(
            builder: (buttonContext) => CatchTopBarIconAction(
              icon: Icons.ios_share_rounded,
              tooltip: 'Share event',
              background: t.surface,
              onPressed: () => onShare(buttonContext),
              foregroundColor: t.ink,
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
                background: t.surface,
                onPressed: () => onAddToCalendar(buttonContext),
                foregroundColor: t.ink,
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
            background: t.surface,
            onPressed: savePending ? null : onToggleSaved,
            foregroundColor: t.ink,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: EventPhotoHeader(event: event),
      ),
    );
  }
}
