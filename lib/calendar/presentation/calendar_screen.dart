import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_segmented_control.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/stat_column.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_agenda_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarViewMode _mode = CalendarViewMode.agenda;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final uid = ref.watch(uidProvider).asData?.value;
    final runsAsync = uid == null
        ? const AsyncData(<Run>[])
        : ref.watch(watchSignedUpRunsProvider(uid));

    return Scaffold(
      backgroundColor: t.bg,
      appBar: const CatchTopBar(title: 'Calendar'),
      body: SafeArea(
        child: runsAsync.when(
          loading: () => const CatchLoadingIndicator(),
          error: (_, _) => _CalendarMessage(
            title: 'Calendar unavailable',
            body: 'Your booked runs could not be loaded.',
          ),
          data: (runs) {
            final summary = _CalendarRunSummary.from(runs, now: DateTime.now());

            return Builder(
              builder: (context) => CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _CalendarHeader(
                      mode: _mode,
                      onModeChanged: (mode) => setState(() => _mode = mode),
                      summary: summary,
                    ),
                  ),
                  if (runs.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _CalendarMessage(
                        title: 'No booked runs yet',
                        body:
                            'Runs you book will show up here by day and time.',
                      ),
                    )
                  else if (_mode == CalendarViewMode.agenda)
                    RunAgendaSliverList(
                      runs: summary.agendaRuns,
                      badgeLabel: 'JOINED',
                      today: summary.today,
                      preserveInputOrder: true,
                      onRunSelected: (run) => _openRunDetail(context, run),
                    )
                  else
                    _TimelineSliverList(
                      runs: summary.agendaRuns,
                      onRunSelected: (run) => _openRunDetail(context, run),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _openRunDetail(BuildContext context, Run run) {
    GoRouter.of(context).push(_calendarRunDetailPath(run));
  }
}

String _calendarRunDetailPath(Run run) {
  final runClubId = Uri.encodeComponent(run.runClubId);
  final runId = Uri.encodeComponent(run.id);
  return '/calendar/run-clubs/$runClubId/runs/$runId';
}

enum CalendarViewMode { agenda, timeline }

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.mode,
    required this.onModeChanged,
    required this.summary,
  });

  final CalendarViewMode mode;
  final ValueChanged<CalendarViewMode> onModeChanged;
  final _CalendarRunSummary summary;

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
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _monthLabel(summary.anchorDate),
                      style: CatchTextStyles.labelM(context),
                    ),
                    gapH2,
                    Text('Calendar', style: CatchTextStyles.displayM(context)),
                  ],
                ),
              ),
              CatchSegmentedControl<CalendarViewMode>(
                segments: const [
                  CatchSegment(value: CalendarViewMode.timeline, label: 'Day'),
                  CatchSegment(value: CalendarViewMode.agenda, label: 'Agenda'),
                ],
                selected: mode,
                onChanged: onModeChanged,
              ),
            ],
          ),
          gapH14,
          _WeekStrip(summary: summary),
          gapH14,
          CatchSurface(
            padding: const EdgeInsets.all(Sizes.p14),
            radius: CatchRadius.md,
            borderColor: t.line,
            child: Row(
              children: [
                Expanded(
                  child: StatColumn(
                    label: 'Booked',
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
  const _WeekStrip({required this.summary});

  final _CalendarRunSummary summary;

  @override
  Widget build(BuildContext context) {
    final anchor = summary.anchorDate;
    final monday = anchor.subtract(Duration(days: anchor.weekday - 1));
    final runDays = summary.runs
        .map((run) => DateUtils.dateOnly(run.startTime))
        .toSet();

    return Row(
      children: [
        for (var i = 0; i < 7; i++) ...[
          Expanded(
            child: _WeekDay(
              date: monday.add(Duration(days: i)),
              active: i == anchor.weekday - 1,
              hasRun: runDays.contains(
                DateUtils.dateOnly(monday.add(Duration(days: i))),
              ),
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
    required this.date,
    required this.active,
    required this.hasRun,
  });

  final DateTime date;
  final bool active;
  final bool hasRun;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final day = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][date.weekday - 1];

    return Container(
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
    );
  }
}

class _TimelineSliverList extends StatelessWidget {
  const _TimelineSliverList({required this.runs, required this.onRunSelected});

  final List<Run> runs;
  final ValueChanged<Run> onRunSelected;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        CatchSpacing.s2,
        CatchSpacing.s5,
        CatchSpacing.s6,
      ),
      sliver: SliverList.list(
        children: [
          Text('Day timeline', style: CatchTextStyles.labelM(context)),
          gapH12,
          for (final run in runs)
            _TimelineRun(run: run, onTap: () => onRunSelected(run)),
        ],
      ),
    );
  }
}

class _TimelineRun extends StatelessWidget {
  const _TimelineRun({required this.run, required this.onTap});

  final Run run;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 56,
            child: Text(
              RunFormatters.time(run.startTime),
              style: CatchTextStyles.bodyS(context, color: t.ink3),
            ),
          ),
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: t.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(child: Container(width: 1, color: t.line)),
            ],
          ),
          gapW12,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: CatchSurface(
                padding: const EdgeInsets.all(Sizes.p14),
                backgroundColor: t.primary,
                radius: CatchRadius.md,
                borderWidth: 0,
                onTap: onTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      run.meetingPoint,
                      style: CatchTextStyles.labelL(
                        context,
                        color: t.primaryInk,
                      ),
                    ),
                    gapH4,
                    Text(
                      '${RunFormatters.distanceKm(run.distanceKm)} · ${run.pace.label}',
                      style: CatchTextStyles.bodyS(
                        context,
                        color: t.primaryInk.withValues(alpha: 0.84),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
    required this.today,
    required this.anchorDate,
    required this.totalDistance,
    this.nextRun,
  });

  final List<Run> runs;
  final List<Run> agendaRuns;
  final DateTime today;
  final DateTime anchorDate;
  final double totalDistance;
  final Run? nextRun;

  static _CalendarRunSummary from(List<Run> runs, {required DateTime now}) {
    final sorted = [...runs]
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
