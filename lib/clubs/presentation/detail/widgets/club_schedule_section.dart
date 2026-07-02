import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/shared/event_agenda_list.dart';
import 'package:catch_dating_app/events/shared/event_tiles/event_tiles.dart';
import 'package:flutter/material.dart';

class ClubScheduleSection extends StatelessWidget {
  const ClubScheduleSection({
    super.key,
    required this.events,
    this.isHost = false,
    this.onEventSelected,
  });

  final List<Event> events;
  final bool isHost;
  final ValueChanged<Event>? onEventSelected;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            CatchLayout.detailScreenHorizontalPadding,
            0,
            CatchLayout.detailScreenHorizontalPadding,
            CatchLayout.detailScreenSectionTitleBottomGap,
          ),
          sliver: SliverToBoxAdapter(
            child: Text('Schedule', style: CatchTextStyles.titleL(context)),
          ),
        ),
        if (events.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              CatchLayout.detailScreenHorizontalPadding,
              0,
              CatchLayout.detailScreenHorizontalPadding,
              CatchLayout.detailScreenBottomPadding,
            ),
            sliver: SliverToBoxAdapter(
              child: CatchEmptyState(
                icon: CatchIcons.calendarMonthOutlined,
                title: 'No events scheduled',
                message:
                    'Future events will appear here once the host publishes one.',
                layout: CatchEmptyStateLayout.inline,
                iconSize: CatchIcon.row,
                iconContainerSize: 44,
                padding: CatchInsets.content,
                titleStyle: CatchTextStyles.sectionTitle(context),
                messageStyle: CatchTextStyles.supporting(
                  context,
                  color: CatchTokens.of(context).ink2,
                ),
              ),
            ),
          )
        else
          EventAgendaSliverList(
            events: events,
            badgeLabel: isHost ? 'HOSTED' : 'VIEW',
            statusBuilder: isHost ? (_) => EventTileStatus.hosted : null,
            onEventSelected: onEventSelected,
            padding: const EdgeInsets.fromLTRB(
              CatchLayout.detailScreenHorizontalPadding,
              0,
              CatchLayout.detailScreenHorizontalPadding,
              CatchLayout.detailScreenBottomPadding,
            ),
          ),
      ],
    );
  }
}
