import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_agenda_list.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tiles.dart';
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
            CatchSpacing.s5,
            0,
            CatchSpacing.s5,
            12,
          ),
          sliver: SliverToBoxAdapter(
            child: Text('Schedule', style: CatchTextStyles.titleL(context)),
          ),
        ),
        if (events.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              CatchSpacing.s5,
              0,
              CatchSpacing.s5,
              20,
            ),
            sliver: SliverToBoxAdapter(
              child: CatchEmptyState(
                icon: Icons.calendar_month_outlined,
                title: 'No events scheduled',
                message: isHost
                    ? 'Publish an event when this club is ready to meet.'
                    : 'Future events will appear here once the host publishes one.',
                layout: CatchEmptyStateLayout.inline,
                iconSize: 22,
                iconContainerSize: 44,
                padding: const EdgeInsets.all(CatchSpacing.s4),
                titleStyle: CatchTextStyles.titleS(context),
                messageStyle: CatchTextStyles.bodyS(
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
          ),
      ],
    );
  }
}
