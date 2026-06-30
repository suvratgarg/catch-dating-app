import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
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
    this.padding = const EdgeInsets.fromLTRB(
      CatchLayout.detailScreenHorizontalPadding,
      CatchLayout.agendaListTopPadding,
      CatchLayout.detailScreenHorizontalPadding,
      CatchLayout.agendaListBottomPadding,
    ),
    this.dayLabelBottomGap = CatchLayout.agendaDayLabelBottomGap,
    this.itemGap = CatchLayout.agendaItemGap,
    this.groupGap = CatchLayout.agendaGroupGap,
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
  final EdgeInsetsGeometry padding;
  final double dayLabelBottomGap;
  final double itemGap;
  final double groupGap;

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
          padding: padding,
          dayLabelBottomGap: dayLabelBottomGap,
          itemGap: itemGap,
          groupGap: groupGap,
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
    this.padding = const EdgeInsets.fromLTRB(
      CatchLayout.detailScreenHorizontalPadding,
      CatchLayout.agendaListTopPadding,
      CatchLayout.detailScreenHorizontalPadding,
      CatchLayout.agendaListBottomPadding,
    ),
    this.dayLabelBottomGap = CatchLayout.agendaDayLabelBottomGap,
    this.itemGap = CatchLayout.agendaItemGap,
    this.groupGap = CatchLayout.agendaGroupGap,
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
  final EdgeInsetsGeometry padding;
  final double dayLabelBottomGap;
  final double itemGap;
  final double groupGap;

  @override
  Widget build(BuildContext context) {
    final grouped = _groupEvents(
      events,
      preserveInputOrder: preserveInputOrder,
    );
    final effectiveToday = today ?? DateTime.now();
    final entries = grouped.entries.toList(growable: false);
    final children = [
      for (var groupIndex = 0; groupIndex < entries.length; groupIndex++) ...[
        KeyedSubtree(
          key: dayKeyBuilder?.call(entries[groupIndex].key),
          child: _AgendaDayGroup(
            date: entries[groupIndex].key,
            events: entries[groupIndex].value,
            today: effectiveToday,
            onEventSelected: onEventSelected,
            badgeLabel: badgeLabel,
            badgeLabelBuilder: badgeLabelBuilder,
            clubNameBuilder: clubNameBuilder,
            statusBuilder: statusBuilder,
            showClubName: showClubName,
            dayLabelBottomGap: dayLabelBottomGap,
            itemGap: itemGap,
          ),
        ),
        if (groupIndex < entries.length - 1) SizedBox(height: groupGap),
      ],
    ];

    return SliverPadding(
      padding: padding,
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

class EventAgendaSliverSkeleton extends StatelessWidget {
  const EventAgendaSliverSkeleton({
    super.key,
    this.count = 4,
    this.padding = const EdgeInsets.fromLTRB(
      CatchLayout.detailScreenHorizontalPadding,
      CatchLayout.agendaListTopPadding,
      CatchLayout.detailScreenHorizontalPadding,
      CatchLayout.agendaListBottomPadding,
    ),
    this.dayLabelBottomGap = CatchLayout.agendaDayLabelBottomGap,
    this.itemGap = CatchLayout.agendaItemGap,
  });

  final int count;
  final EdgeInsetsGeometry padding;
  final double dayLabelBottomGap;
  final double itemGap;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: SliverList.list(
        children: [
          CatchSkeleton.text(width: CatchLayout.skeletonTextEyebrowWidth),
          SizedBox(height: dayLabelBottomGap),
          for (var i = 0; i < count; i++) ...[
            const _EventAgendaTileSkeleton(),
            if (i < count - 1) SizedBox(height: itemGap),
          ],
        ],
      ),
    );
  }
}

class _EventAgendaTileSkeleton extends StatelessWidget {
  const _EventAgendaTileSkeleton();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      borderColor: t.line2,
      radius: CatchRadius.md,
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CatchSkeleton.custom(
              child: Container(
                width: CatchLayout.eventDateRailWidth,
                decoration: const BoxDecoration(
                  color: CatchTokens.editorialLight,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(CatchRadius.md),
                  ),
                ),
                child: Padding(
                  padding: CatchInsets.contentDense,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CatchSkeleton.text(
                        width: CatchLayout.skeletonTextDateWidth,
                      ),
                      gapH6,
                      CatchSkeleton.text(
                        width: CatchLayout.skeletonTextMicroWidth,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: CatchInsets.listBody,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        CatchSkeleton.circle(
                          size: CatchLayout.eventTypeDisplaySize,
                        ),
                        gapW8,
                        Expanded(child: CatchSkeleton.text()),
                        gapW8,
                        CatchSkeleton.box(
                          width: CatchLayout.skeletonTextChipWidth,
                          height: CatchSpacing.s5,
                          radius: CatchRadius.pill,
                        ),
                      ],
                    ),
                    gapH8,
                    CatchSkeleton.text(),
                    gapH6,
                    FractionallySizedBox(
                      widthFactor: 0.72,
                      child: CatchSkeleton.text(),
                    ),
                    gapH10,
                    Row(
                      children: [
                        CatchSkeleton.circle(size: CatchIcon.profileRunStat),
                        gapW8,
                        CatchSkeleton.text(
                          width: CatchLayout.skeletonTextRowWidth,
                        ),
                      ],
                    ),
                    gapH8,
                    CatchSkeleton.text(width: CatchLayout.skeletonTextBodyWidth),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgendaDayGroup extends StatelessWidget {
  const _AgendaDayGroup({
    required this.date,
    required this.events,
    required this.today,
    required this.onEventSelected,
    required this.badgeLabel,
    required this.badgeLabelBuilder,
    required this.clubNameBuilder,
    required this.statusBuilder,
    required this.showClubName,
    required this.dayLabelBottomGap,
    required this.itemGap,
  });

  final DateTime date;
  final List<Event> events;
  final DateTime today;
  final ValueChanged<Event>? onEventSelected;
  final String? badgeLabel;
  final EventBadgeLabelBuilder? badgeLabelBuilder;
  final ClubNameBuilder? clubNameBuilder;
  final EventTileStatusBuilder? statusBuilder;
  final bool showClubName;
  final double dayLabelBottomGap;
  final double itemGap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _dayLabel(date, today).toUpperCase(),
          style: CatchTextStyles.labelM(
            context,
            color: DateUtils.isSameDay(date, today) ? t.primary : t.ink3,
          ),
        ),
        SizedBox(height: dayLabelBottomGap),
        for (var eventIndex = 0; eventIndex < events.length; eventIndex++) ...[
          Builder(
            builder: (context) {
              final event = events[eventIndex];
              final effectiveBadge = badgeLabelBuilder?.call(event) ?? badgeLabel;
              final clubName = clubNameBuilder?.call(event);
              final status =
                  statusBuilder?.call(event) ?? _statusForBadge(effectiveBadge);
              return EventAgendaTile(
                data: EventTileData.fromEvent(
                  event: event,
                  status: status,
                  clubName: clubName,
                ),
                showClubName: showClubName,
                badgeLabel: effectiveBadge,
                onTap: onEventSelected == null
                    ? null
                    : () => onEventSelected!(event),
              );
            },
          ),
          if (eventIndex < events.length - 1) SizedBox(height: itemGap),
        ],
      ],
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
