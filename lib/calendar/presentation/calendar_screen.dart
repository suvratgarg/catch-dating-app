import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/presentation/club_name_lookup.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/stat_column.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/data/saved_event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_agenda_list.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  static const double _calendarDragThreshold = 8;

  final Map<DateTime, GlobalKey> _daySectionKeys = {};

  DateTime? _selectedDate;
  bool _calendarExpanded = false;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final uid = ref.watch(uidProvider).asData?.value;
    final signedUpEventsAsync = uid == null
        ? const AsyncData(<Event>[])
        : ref.watch(watchSignedUpEventsProvider(uid));
    final savedEventsAsync = uid == null
        ? const AsyncData(<Event>[])
        : ref.watch(watchSavedEventDetailsForUserProvider(uid));

    return Scaffold(
      backgroundColor: t.bg,
      appBar: const CatchTopBar(title: 'Calendar'),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (signedUpEventsAsync.isLoading || savedEventsAsync.isLoading) {
              return const CatchLoadingIndicator();
            }
            if (signedUpEventsAsync.hasError || savedEventsAsync.hasError) {
              return const _CalendarMessage(
                title: 'Calendar unavailable',
                body: 'Your planned events could not be loaded.',
              );
            }

            final signedUpEvents =
                signedUpEventsAsync.asData?.value ?? const <Event>[];
            final savedEvents =
                savedEventsAsync.asData?.value ?? const <Event>[];
            final summary = _CalendarEventSummary.from(
              signedUpEvents: signedUpEvents,
              savedEvents: savedEvents,
              now: DateTime.now(),
            );
            final selectedDate = _selectedDate ?? summary.anchorDate;
            final clubNamesAsync = ref.watch(
              clubNameLookupProvider(
                ClubNameLookupQuery(
                  summary.events.map((event) => event.clubId),
                ),
              ),
            );

            return NotificationListener<ScrollNotification>(
              onNotification: _handleCalendarScrollNotification,
              child: CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _CalendarDateHeaderDelegate(
                      height: _CalendarDateHeader.heightFor(
                        context,
                        expanded: _calendarExpanded,
                      ),
                      child: _CalendarDateHeader(
                        summary: summary,
                        selectedDate: selectedDate,
                        expanded: _calendarExpanded,
                        onDateSelected: _selectDate,
                        onTodayPressed: () => _selectDate(summary.today),
                        onVerticalDragDelta: _handleCalendarHeaderDragDelta,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _CalendarStatsHeader(summary: summary),
                  ),
                  ..._buildCalendarEventSlivers(
                    context: context,
                    summary: summary,
                    clubNamesAsync: clubNamesAsync,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _openEventDetail(BuildContext context, Event event) {
    GoRouter.of(context).push(_calendarEventDetailPath(event), extra: event);
  }

  void _selectDate(DateTime date) {
    final day = DateUtils.dateOnly(date);
    setState(() => _selectedDate = day);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final dayContext = _daySectionKeys[day]?.currentContext;
      if (dayContext == null) return;
      final alignment = _agendaRevealAlignment(dayContext);
      Scrollable.ensureVisible(
        dayContext,
        duration: CatchMotion.calendarScroll,
        curve: CatchMotion.easeOutCubicCurve,
        alignment: alignment,
      );
    });
  }

  double _agendaRevealAlignment(BuildContext dayContext) {
    final scrollable = Scrollable.maybeOf(dayContext);
    final viewportHeight = scrollable?.position.viewportDimension;
    if (viewportHeight == null || viewportHeight <= 0) return 0.18;

    return ((_CalendarDateHeader.heightFor(
                  context,
                  expanded: _calendarExpanded,
                ) +
                CatchSpacing.s2) /
            viewportHeight)
        .clamp(0.12, 0.32)
        .toDouble();
  }

  bool _handleCalendarScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) return false;

    if (notification is ScrollUpdateNotification) {
      final delta = notification.dragDetails?.delta.dy;
      if (delta != null) {
        _handleCalendarDragDelta(
          delta,
          scrollPixels: notification.metrics.pixels,
        );
      }
    } else if (notification is OverscrollNotification) {
      final delta = notification.dragDetails?.delta.dy;
      if (delta != null) {
        _handleCalendarDragDelta(
          delta,
          scrollPixels: notification.metrics.pixels,
        );
      }
    } else if (notification is UserScrollNotification &&
        notification.direction == ScrollDirection.reverse) {
      _setCalendarExpanded(false);
    }

    return false;
  }

  void _handleCalendarHeaderDragDelta(double delta) {
    _handleCalendarDragDelta(delta, scrollPixels: 0);
  }

  void _handleCalendarDragDelta(double delta, {required double scrollPixels}) {
    if (delta > _calendarDragThreshold && scrollPixels <= CatchSpacing.s4) {
      _setCalendarExpanded(true);
    } else if (delta < -_calendarDragThreshold) {
      _setCalendarExpanded(false);
    }
  }

  void _setCalendarExpanded(bool expanded) {
    if (_calendarExpanded == expanded) return;
    setState(() => _calendarExpanded = expanded);
  }

  Key _agendaDayKey(DateTime date) {
    final day = DateUtils.dateOnly(date);
    return _daySectionKeys.putIfAbsent(
      day,
      () => GlobalKey(debugLabel: 'calendar-agenda-day-${_dateKey(day)}'),
    );
  }

  List<Widget> _buildCalendarEventSlivers({
    required BuildContext context,
    required _CalendarEventSummary summary,
    required AsyncValue<Map<String, String>> clubNamesAsync,
  }) {
    if (summary.events.isEmpty) {
      return const [
        SliverFillRemaining(
          child: _CalendarMessage(
            title: 'No planned events yet',
            body: 'Events you book or save will show up here by day and time.',
          ),
        ),
      ];
    }

    final clubNames = clubNamesAsync.asData?.value;
    if (clubNames == null) {
      return [
        SliverFillRemaining(
          child: clubNamesAsync.hasError
              ? const _CalendarMessage(
                  title: 'Calendar unavailable',
                  body: 'Club names could not be loaded.',
                )
              : const CatchLoadingIndicator(),
        ),
      ];
    }

    return [
      EventAgendaSliverList(
        events: summary.agendaEvents,
        showClubName: true,
        clubNameBuilder: (event) => clubNames[event.clubId],
        badgeLabelBuilder: (event) =>
            summary.isSavedOnly(event) ? 'SAVED' : 'JOINED',
        statusBuilder: (event) => summary.isSavedOnly(event)
            ? EventTileStatus.saved
            : EventTileStatus.joined,
        today: summary.today,
        preserveInputOrder: true,
        dayKeyBuilder: _agendaDayKey,
        onEventSelected: (event) => _openEventDetail(context, event),
      ),
    ];
  }
}

String _calendarEventDetailPath(Event event) {
  final clubId = Uri.encodeComponent(event.clubId);
  final eventId = Uri.encodeComponent(event.id);
  return '/calendar/clubs/$clubId/events/$eventId';
}

class _CalendarDateHeader extends StatelessWidget {
  const _CalendarDateHeader({
    required this.summary,
    required this.selectedDate,
    required this.expanded,
    required this.onDateSelected,
    required this.onTodayPressed,
    required this.onVerticalDragDelta,
  });

  final _CalendarEventSummary summary;
  final DateTime selectedDate;
  final bool expanded;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onTodayPressed;
  final ValueChanged<double> onVerticalDragDelta;

  static double heightFor(BuildContext context, {required bool expanded}) {
    final scaler = MediaQuery.textScalerOf(context);
    final monthHeight = scaler.scale(26) * 1.12;
    final titleRowHeight = monthHeight < 36 ? 36.0 : monthHeight;
    final weekdayHeight = scaler.scale(13) * 1.45;
    final dateHeight = scaler.scale(13) * 1.30;
    final weekStripHeight =
        CatchLayout.calendarWeekStripVerticalInsetTotal +
        weekdayHeight +
        CatchSpacing.micro2 +
        dateHeight +
        CatchSpacing.s1 +
        4;
    if (expanded) {
      final monthWeekdayHeight = scaler.scale(11) * 1.30;
      const monthDayHeight = 40.0;
      return CatchSpacing.s2 +
          titleRowHeight +
          CatchSpacing.s4 +
          monthWeekdayHeight +
          CatchSpacing.s2 +
          (monthDayHeight * 6) +
          CatchLayout.calendarMonthGridGapTotal +
          CatchSpacing.s3 +
          CatchSpacing.micro2;
    }

    return CatchSpacing.s2 +
        titleRowHeight +
        CatchSpacing.micro14 +
        weekStripHeight +
        CatchSpacing.s3 +
        CatchSpacing.micro2;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: expanded
          ? 'Calendar date header. Drag up to collapse the month.'
          : 'Calendar date header. Drag down to expand the month.',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: (details) =>
            onVerticalDragDelta(details.delta.dy),
        child: Padding(
          padding: CatchInsets.pageHeaderCompact,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CalendarTitleRow(
                title: _monthLabel(selectedDate),
                onTodayPressed: onTodayPressed,
              ),
              gapH14,
              if (expanded)
                _MonthGrid(
                  summary: summary,
                  selectedDate: selectedDate,
                  onDateSelected: onDateSelected,
                )
              else
                _WeekStrip(
                  summary: summary,
                  selectedDate: selectedDate,
                  onDateSelected: onDateSelected,
                ),
            ],
          ),
        ),
      ),
    );
  }

  static String _monthLabel(DateTime date) {
    return '${_monthName(date.month)} ${date.year}';
  }
}

class _CalendarTitleRow extends StatelessWidget {
  const _CalendarTitleRow({required this.title, required this.onTodayPressed});

  final String title;
  final VoidCallback onTodayPressed;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: CatchTextStyles.headlineS(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        gapW12,
        CatchButton(
          label: 'Today',
          onPressed: onTodayPressed,
          variant: CatchButtonVariant.secondary,
          size: CatchButtonSize.sm,
          foregroundColor: t.ink,
          borderColor: t.line,
        ),
      ],
    );
  }
}

class _CalendarDateHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _CalendarDateHeaderDelegate({
    required this.child,
    required this.height,
  });

  final Widget child;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final t = CatchTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.bg,
        border: overlapsContent
            ? Border(bottom: BorderSide(color: t.line))
            : null,
      ),
      child: SizedBox.expand(child: child),
    );
  }

  @override
  bool shouldRebuild(covariant _CalendarDateHeaderDelegate oldDelegate) {
    return child != oldDelegate.child || height != oldDelegate.height;
  }
}

class _CalendarStatsHeader extends StatelessWidget {
  const _CalendarStatsHeader({required this.summary});

  final _CalendarEventSummary summary;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        CatchSpacing.micro2,
        CatchSpacing.s5,
        CatchSpacing.s3,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: CatchLayout.maxContentWidth,
          ),
          child: CatchSurface(
            padding: CatchInsets.tileContentCompact,
            radius: CatchRadius.md,
            borderColor: t.line,
            child: Row(
              children: [
                Expanded(
                  child: StatColumn(
                    key: const ValueKey('calendar.stats.planned'),
                    label: 'Planned',
                    value: '${summary.events.length}',
                  ),
                ),
                const _StatDivider(),
                Expanded(
                  child: StatColumn(
                    key: const ValueKey('calendar.stats.distance'),
                    label: 'Distance',
                    value: '${summary.totalDistance.round()} km',
                  ),
                ),
                const _StatDivider(),
                Expanded(
                  child: StatColumn(
                    key: const ValueKey('calendar.stats.next'),
                    label: 'Next',
                    value: summary.nextEvent == null
                        ? 'None'
                        : EventFormatters.time(summary.nextEvent!.startTime),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.summary,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final _CalendarEventSummary summary;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final anchor = selectedDate;
    final monday = anchor.subtract(Duration(days: anchor.weekday - 1));
    final eventDays = summary.events
        .map((event) => DateUtils.dateOnly(event.startTime))
        .toSet();

    return Row(
      children: [
        for (var i = 0; i < 7; i++) ...[
          Expanded(
            child: Builder(
              builder: (context) {
                final date = DateUtils.dateOnly(monday.add(Duration(days: i)));
                return EventDateMarker(
                  key: _calendarWeekDayKey(date),
                  date: date,
                  active: DateUtils.isSameDay(date, selectedDate),
                  hasEvent: eventDays.contains(date),
                  onTap: () => onDateSelected(date),
                );
              },
            ),
          ),
          if (i < 6) gapW4,
        ],
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.summary,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final _CalendarEventSummary summary;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(selectedDate.year, selectedDate.month);
    final gridStart = firstOfMonth.subtract(
      Duration(days: firstOfMonth.weekday % DateTime.daysPerWeek),
    );
    final eventDays = summary.events
        .map((event) => DateUtils.dateOnly(event.startTime))
        .toSet();

    return Column(
      children: [
        Row(
          children: [
            for (final day in const ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
              Expanded(
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: CatchTextStyles.labelM(context),
                ),
              ),
          ],
        ),
        gapH8,
        for (var week = 0; week < 6; week += 1) ...[
          Row(
            children: [
              for (
                var weekday = 0;
                weekday < DateTime.daysPerWeek;
                weekday += 1
              )
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final date = DateUtils.dateOnly(
                        gridStart.add(
                          Duration(
                            days: (week * DateTime.daysPerWeek) + weekday,
                          ),
                        ),
                      );
                      final inMonth = date.month == selectedDate.month;
                      return EventDateMarker(
                        key: inMonth ? _calendarMonthDayKey(date) : null,
                        date: date,
                        layout: EventDateMarkerLayout.monthGrid,
                        enabled: inMonth,
                        active: DateUtils.isSameDay(date, selectedDate),
                        today: DateUtils.isSameDay(date, summary.today),
                        hasEvent: eventDays.contains(date),
                        onTap: () => onDateSelected(date),
                      );
                    },
                  ),
                ),
            ],
          ),
          if (week < 5) gapH6,
        ],
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CatchLayout.calendarStatDividerHorizontalMargin,
      ),
      child: SizedBox(
        width: CatchStroke.hairline,
        height: CatchLayout.calendarStatDividerHeight,
        child: ColoredBox(color: t.line),
      ),
    );
  }
}

class _CalendarMessage extends StatelessWidget {
  const _CalendarMessage({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CatchEmptyState(
        icon: CatchIcons.calendarMonthOutlined,
        title: title,
        message: body,
        surface: false,
        iconStyle: CatchEmptyStateIconStyle.plain,
        iconSize: CatchLayout.calendarEmptyIconSize,
        padding: CatchInsets.contentSpacious,
        titleStyle: CatchTextStyles.titleL(context),
        messageStyle: CatchTextStyles.proseM(
          context,
          color: CatchTokens.of(context).ink2,
        ),
      ),
    );
  }
}

class _CalendarEventSummary {
  const _CalendarEventSummary({
    required this.events,
    required this.agendaEvents,
    required this.savedOnlyEventIds,
    required this.today,
    required this.anchorDate,
    required this.totalDistance,
    this.nextEvent,
  });

  final List<Event> events;
  final List<Event> agendaEvents;
  final Set<String> savedOnlyEventIds;
  final DateTime today;
  final DateTime anchorDate;
  final double totalDistance;
  final Event? nextEvent;

  bool isSavedOnly(Event event) => savedOnlyEventIds.contains(event.id);

  static _CalendarEventSummary from({
    required List<Event> signedUpEvents,
    List<Event> savedEvents = const <Event>[],
    required DateTime now,
  }) {
    final signedUpIds = signedUpEvents.map((event) => event.id).toSet();
    final savedOnlyEventIds = <String>{};
    final byId = <String, Event>{};

    for (final event in savedEvents) {
      if (event.isCancelled || !event.startTime.isAfter(now)) continue;
      byId[event.id] = event;
      if (!signedUpIds.contains(event.id)) savedOnlyEventIds.add(event.id);
    }
    for (final event in signedUpEvents) {
      byId[event.id] = event;
    }

    final sorted = byId.values.toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final today = DateUtils.dateOnly(now);
    final totalDistance = sorted.fold<double>(
      0,
      (sum, event) => sum + event.distanceKm,
    );

    final upcoming = <Event>[];
    final past = <Event>[];
    for (final event in sorted) {
      if (event.startTime.isBefore(now)) {
        past.add(event);
      } else {
        upcoming.add(event);
      }
    }

    final nextEvent = upcoming.isEmpty ? null : upcoming.first;
    final latestPastFirst = [...past]
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    final anchorDate = nextEvent?.startTime ?? today;

    return _CalendarEventSummary(
      events: sorted,
      agendaEvents: [...upcoming, ...latestPastFirst],
      savedOnlyEventIds: savedOnlyEventIds,
      today: today,
      anchorDate: anchorDate,
      totalDistance: totalDistance,
      nextEvent: nextEvent,
    );
  }
}

String _monthName(int month) {
  return const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ][month - 1];
}

Key _calendarWeekDayKey(DateTime date) {
  return ValueKey<String>('calendar-week-day-${_dateKey(date)}');
}

Key _calendarMonthDayKey(DateTime date) {
  return ValueKey<String>('calendar-month-day-${_dateKey(date)}');
}

String _dateKey(DateTime date) {
  final day = DateUtils.dateOnly(date);
  final month = day.month.toString().padLeft(2, '0');
  final dateOfMonth = day.day.toString().padLeft(2, '0');
  return '${day.year}-$month-$dateOfMonth';
}
