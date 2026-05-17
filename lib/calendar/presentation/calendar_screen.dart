import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/presentation/club_name_lookup.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  final Map<DateTime, GlobalKey> _daySectionKeys = {};

  DateTime? _selectedDate;

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

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _CalendarHeader(
                    summary: summary,
                    selectedDate: selectedDate,
                    onDateSelected: _selectDate,
                  ),
                ),
                ..._buildCalendarEventSlivers(
                  context: context,
                  summary: summary,
                  clubNamesAsync: clubNamesAsync,
                ),
              ],
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
      Scrollable.ensureVisible(
        dayContext,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        alignment: 0.08,
      );
    });
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

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.summary,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final _CalendarEventSummary summary;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        CatchSpacing.s2,
        CatchSpacing.s5,
        CatchSpacing.s3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _monthLabel(selectedDate),
            style: CatchTextStyles.displayM(context),
          ),
          gapH14,
          _WeekStrip(
            summary: summary,
            selectedDate: selectedDate,
            onDateSelected: onDateSelected,
          ),
          gapH14,
          CatchSurface(
            padding: const EdgeInsets.all(Sizes.p14),
            radius: CatchRadius.md,
            borderColor: t.line,
            child: Row(
              children: [
                Expanded(
                  child: StatColumn(
                    label: 'Planned',
                    value: '${summary.events.length}',
                  ),
                ),
                const _StatDivider(),
                Expanded(
                  child: StatColumn(
                    label: 'Distance',
                    value: '${summary.totalDistance.round()} km',
                  ),
                ),
                const _StatDivider(),
                Expanded(
                  child: StatColumn(
                    label: 'Next',
                    value: summary.nextEvent == null
                        ? 'None'
                        : EventFormatters.time(summary.nextEvent!.startTime),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _monthLabel(DateTime date) {
    return '${_monthName(date.month)} ${date.year}';
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
                return _WeekDay(
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

class _WeekDay extends StatelessWidget {
  const _WeekDay({
    super.key,
    required this.date,
    required this.active,
    required this.hasEvent,
    required this.onTap,
  });

  final DateTime date;
  final bool active;
  final bool hasEvent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final day = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][date.weekday - 1];

    return Semantics(
      button: true,
      selected: active,
      label: '$day ${date.day}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: active ? t.ink : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  day,
                  style: CatchTextStyles.bodyS(
                    context,
                    color: active ? t.surface.withValues(alpha: 0.72) : t.ink3,
                  ),
                ),
                gapH2,
                Text(
                  '${date.day}',
                  style: CatchTextStyles.labelL(
                    context,
                    color: active ? t.surface : t.ink,
                  ),
                ),
                gapH4,
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: hasEvent ? t.primary : Colors.transparent,
                    shape: BoxShape.circle,
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

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Container(
      width: 1,
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: t.line,
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
        icon: Icons.calendar_month_outlined,
        title: title,
        message: body,
        surface: false,
        iconStyle: CatchEmptyStateIconStyle.plain,
        iconSize: 44,
        padding: const EdgeInsets.all(CatchSpacing.s6),
        titleStyle: CatchTextStyles.titleL(context),
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

String _dateKey(DateTime date) {
  final day = DateUtils.dateOnly(date);
  final month = day.month.toString().padLeft(2, '0');
  final dateOfMonth = day.day.toString().padLeft(2, '0');
  return '${day.year}-$month-$dateOfMonth';
}
