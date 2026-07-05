import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
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
    this.bottomPadding = CatchLayout.detailScreenBottomPadding,
  });

  final List<Event> events;
  final bool isHost;
  final ValueChanged<Event>? onEventSelected;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(
            CatchLayout.detailScreenHorizontalPadding,
            0,
            CatchLayout.detailScreenHorizontalPadding,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: CatchSection.divided(
              title: 'Schedule',
              child: SizedBox.shrink(),
            ),
          ),
        ),
        if (events.isEmpty)
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              CatchLayout.detailScreenHorizontalPadding,
              0,
              CatchLayout.detailScreenHorizontalPadding,
              bottomPadding,
            ),
            sliver: SliverToBoxAdapter(
              child: CatchEmptyState(
                icon: CatchIcons.calendarMonthOutlined,
                title: 'No events scheduled',
                message:
                    'Future events will appear here once the host publishes one.',
                layout: CatchEmptyStateLayout.inline,
              ),
            ),
          )
        else
          EventAgendaSliverList(
            events: events,
            badgeLabel: isHost ? 'HOSTED' : 'VIEW',
            statusBuilder: isHost ? (_) => EventTileStatus.hosted : null,
            onEventSelected: onEventSelected,
            padding: EdgeInsets.fromLTRB(
              CatchLayout.detailScreenHorizontalPadding,
              0,
              CatchLayout.detailScreenHorizontalPadding,
              bottomPadding,
            ),
          ),
      ],
    );
  }
}
