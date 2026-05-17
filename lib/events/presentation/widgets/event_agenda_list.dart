import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tiles.dart';
import 'package:flutter/material.dart';

typedef EventBadgeLabelBuilder = String? Function(Event event);
typedef ClubNameBuilder = String? Function(Event event);
typedef EventTileStatusBuilder = EventTileStatus Function(Event event);
typedef EventAgendaDayKeyBuilder = Key? Function(DateTime date);

class EventAgendaList extends StatelessWidget {
  const EventAgendaList({
    super.key,
    required this.events,
    this.onEventSelected,
    this.badgeLabel,
    this.badgeLabelBuilder,
    this.clubNameBuilder,
    this.statusBuilder,
    this.showClubName = false,
    this.today,
    this.preserveInputOrder = false,
    this.dayKeyBuilder,
  });

  final List<Event> events;
  final ValueChanged<Event>? onEventSelected;
  final String? badgeLabel;
  final EventBadgeLabelBuilder? badgeLabelBuilder;
  final ClubNameBuilder? clubNameBuilder;
  final EventTileStatusBuilder? statusBuilder;
  final bool showClubName;
  final DateTime? today;
  final bool preserveInputOrder;
  final EventAgendaDayKeyBuilder? dayKeyBuilder;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        EventAgendaSliverList(
          events: events,
          onEventSelected: onEventSelected,
          badgeLabel: badgeLabel,
          badgeLabelBuilder: badgeLabelBuilder,
          clubNameBuilder: clubNameBuilder,
          statusBuilder: statusBuilder,
          showClubName: showClubName,
          today: today,
          preserveInputOrder: preserveInputOrder,
          dayKeyBuilder: dayKeyBuilder,
        ),
      ],
    );
  }
}

class EventAgendaSliverList extends StatelessWidget {
  const EventAgendaSliverList({
    super.key,
    required this.events,
    this.onEventSelected,
    this.badgeLabel,
    this.badgeLabelBuilder,
    this.clubNameBuilder,
    this.statusBuilder,
    this.showClubName = false,
    this.today,
    this.preserveInputOrder = false,
    this.dayKeyBuilder,
  });

  final List<Event> events;
  final ValueChanged<Event>? onEventSelected;
  final String? badgeLabel;
  final EventBadgeLabelBuilder? badgeLabelBuilder;
  final ClubNameBuilder? clubNameBuilder;
  final EventTileStatusBuilder? statusBuilder;
  final bool showClubName;
  final DateTime? today;
  final bool preserveInputOrder;
  final EventAgendaDayKeyBuilder? dayKeyBuilder;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final grouped = _groupEvents(
      events,
      preserveInputOrder: preserveInputOrder,
    );
    final effectiveToday = today ?? DateTime.now();
    final children = [
      for (final entry in grouped.entries) ...[
        KeyedSubtree(
          key: dayKeyBuilder?.call(entry.key),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _dayLabel(entry.key, effectiveToday).toUpperCase(),
                style: CatchTextStyles.labelM(
                  context,
                  color: DateUtils.isSameDay(entry.key, effectiveToday)
                      ? t.primary
                      : t.ink3,
                ),
              ),
              gapH8,
              for (final event in entry.value) ...[
                Builder(
                  builder: (context) {
                    final effectiveBadge =
                        badgeLabelBuilder?.call(event) ?? badgeLabel;
                    return EventAgendaCard(
                      event: event,
                      badgeLabel: effectiveBadge,
                      clubName: clubNameBuilder?.call(event),
                      status:
                          statusBuilder?.call(event) ??
                          _statusForBadge(effectiveBadge),
                      showClubName: showClubName,
                      onTap: onEventSelected == null
                          ? null
                          : () => onEventSelected!.call(event),
                    );
                  },
                ),
                gapH10,
              ],
            ],
          ),
        ),
        gapH10,
      ],
    ];

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        CatchSpacing.s1,
        CatchSpacing.s5,
        CatchSpacing.s6,
      ),
      sliver: dayKeyBuilder == null
          ? SliverList.list(children: children)
          : SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
    );
  }
}

class EventAgendaCard extends StatelessWidget {
  const EventAgendaCard({
    super.key,
    required this.event,
    this.badgeLabel,
    this.clubName,
    this.status = EventTileStatus.open,
    this.showClubName = false,
    this.onTap,
  });

  final Event event;
  final String? badgeLabel;
  final String? clubName;
  final EventTileStatus status;
  final bool showClubName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return EventAgendaTile(
      data: EventTileData.fromEvent(
        event: event,
        status: status,
        clubName: clubName,
      ),
      onTap: onTap,
      showClubName: showClubName,
      badgeLabel: badgeLabel,
    );
  }
}

Map<DateTime, List<Event>> _groupEvents(
  List<Event> events, {
  required bool preserveInputOrder,
}) {
  final sorted = preserveInputOrder
      ? events
      : ([...events]..sort((a, b) => a.startTime.compareTo(b.startTime)));
  final grouped = <DateTime, List<Event>>{};
  for (final event in sorted) {
    final day = DateUtils.dateOnly(event.startTime);
    grouped.putIfAbsent(day, () => []).add(event);
  }
  return grouped;
}

String _dayLabel(DateTime date, DateTime today) {
  if (DateUtils.isSameDay(date, today)) return 'Today';
  return '${EventFormatters.shortWeekday(date)} · ${date.day} ${EventFormatters.shortMonth(date)}';
}

EventTileStatus _statusForBadge(String? badgeLabel) {
  return switch (badgeLabel?.toUpperCase()) {
    'JOINED' => EventTileStatus.joined,
    'SAVED' => EventTileStatus.saved,
    'PAST' => EventTileStatus.past,
    'WAITLISTED' => EventTileStatus.waitlisted,
    'ATTENDED' => EventTileStatus.attended,
    'HOSTED' => EventTileStatus.hosted,
    'FULL' => EventTileStatus.full,
    _ => EventTileStatus.open,
  };
}
