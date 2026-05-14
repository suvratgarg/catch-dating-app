import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/stat_column.dart';
import 'package:catch_dating_app/run_clubs/presentation/run_club_name_lookup.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/data/saved_run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_agenda_list.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_tiles/run_tiles.dart';
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
    final signedUpRunsAsync = uid == null
        ? const AsyncData(<Run>[])
        : ref.watch(watchSignedUpRunsProvider(uid));
    final savedRunsAsync = uid == null
        ? const AsyncData(<Run>[])
        : ref.watch(watchSavedRunDetailsForUserProvider(uid));

    return Scaffold(
      backgroundColor: t.bg,
      appBar: const CatchTopBar(title: 'Calendar'),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (signedUpRunsAsync.isLoading || savedRunsAsync.isLoading) {
              return const CatchLoadingIndicator();
            }
            if (signedUpRunsAsync.hasError || savedRunsAsync.hasError) {
              return const _CalendarMessage(
                title: 'Calendar unavailable',
                body: 'Your planned runs could not be loaded.',
              );
            }

            final signedUpRuns =
                signedUpRunsAsync.asData?.value ?? const <Run>[];
            final savedRuns = savedRunsAsync.asData?.value ?? const <Run>[];
            final summary = _CalendarRunSummary.from(
              signedUpRuns: signedUpRuns,
              savedRuns: savedRuns,
              now: DateTime.now(),
            );
            final selectedDate = _selectedDate ?? summary.anchorDate;
            final clubNamesAsync = ref.watch(
              runClubNameLookupProvider(
                RunClubNameLookupQuery(
                  summary.runs.map((run) => run.runClubId),
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
                ..._buildCalendarRunSlivers(
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

  void _openRunDetail(BuildContext context, Run run) {
    GoRouter.of(context).push(_calendarRunDetailPath(run));
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

  List<Widget> _buildCalendarRunSlivers({
    required BuildContext context,
    required _CalendarRunSummary summary,
    required AsyncValue<Map<String, String>> clubNamesAsync,
  }) {
    if (summary.runs.isEmpty) {
      return const [
        SliverFillRemaining(
          child: _CalendarMessage(
            title: 'No planned runs yet',
            body: 'Runs you book or save will show up here by day and time.',
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
                  body: 'Run club names could not be loaded.',
                )
              : const CatchLoadingIndicator(),
        ),
      ];
    }

    return [
      RunAgendaSliverList(
        runs: summary.agendaRuns,
        showClubName: true,
        clubNameBuilder: (run) => clubNames[run.runClubId],
        badgeLabelBuilder: (run) =>
            summary.isSavedOnly(run) ? 'SAVED' : 'JOINED',
        statusBuilder: (run) => summary.isSavedOnly(run)
            ? RunTileStatus.saved
            : RunTileStatus.joined,
        today: summary.today,
        preserveInputOrder: true,
        dayKeyBuilder: _agendaDayKey,
        onRunSelected: (run) => _openRunDetail(context, run),
      ),
    ];
  }
}

String _calendarRunDetailPath(Run run) {
  final runClubId = Uri.encodeComponent(run.runClubId);
  final runId = Uri.encodeComponent(run.id);
  return '/calendar/run-clubs/$runClubId/runs/$runId';
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.summary,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final _CalendarRunSummary summary;
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
                    value: '${summary.runs.length}',
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
                    value: summary.nextRun == null
                        ? 'None'
                        : RunFormatters.time(summary.nextRun!.startTime),
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

  final _CalendarRunSummary summary;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final anchor = selectedDate;
    final monday = anchor.subtract(Duration(days: anchor.weekday - 1));
    final runDays = summary.runs
        .map((run) => DateUtils.dateOnly(run.startTime))
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
                  hasRun: runDays.contains(date),
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
    required this.hasRun,
    required this.onTap,
  });

  final DateTime date;
  final bool active;
  final bool hasRun;
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
                    color: hasRun ? t.primary : Colors.transparent,
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

class _CalendarRunSummary {
  const _CalendarRunSummary({
    required this.runs,
    required this.agendaRuns,
    required this.savedOnlyRunIds,
    required this.today,
    required this.anchorDate,
    required this.totalDistance,
    this.nextRun,
  });

  final List<Run> runs;
  final List<Run> agendaRuns;
  final Set<String> savedOnlyRunIds;
  final DateTime today;
  final DateTime anchorDate;
  final double totalDistance;
  final Run? nextRun;

  bool isSavedOnly(Run run) => savedOnlyRunIds.contains(run.id);

  static _CalendarRunSummary from({
    required List<Run> signedUpRuns,
    List<Run> savedRuns = const <Run>[],
    required DateTime now,
  }) {
    final signedUpIds = signedUpRuns.map((run) => run.id).toSet();
    final savedOnlyRunIds = <String>{};
    final byId = <String, Run>{};

    for (final run in savedRuns) {
      if (run.isCancelled || !run.startTime.isAfter(now)) continue;
      byId[run.id] = run;
      if (!signedUpIds.contains(run.id)) savedOnlyRunIds.add(run.id);
    }
    for (final run in signedUpRuns) {
      byId[run.id] = run;
    }

    final sorted = byId.values.toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final today = DateUtils.dateOnly(now);
    final totalDistance = sorted.fold<double>(
      0,
      (sum, run) => sum + run.distanceKm,
    );

    final upcoming = <Run>[];
    final past = <Run>[];
    for (final run in sorted) {
      if (run.startTime.isBefore(now)) {
        past.add(run);
      } else {
        upcoming.add(run);
      }
    }

    final nextRun = upcoming.isEmpty ? null : upcoming.first;
    final latestPastFirst = [...past]
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    final anchorDate = nextRun?.startTime ?? today;

    return _CalendarRunSummary(
      runs: sorted,
      agendaRuns: [...upcoming, ...latestPastFirst],
      savedOnlyRunIds: savedOnlyRunIds,
      today: today,
      anchorDate: anchorDate,
      totalDistance: totalDistance,
      nextRun: nextRun,
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
