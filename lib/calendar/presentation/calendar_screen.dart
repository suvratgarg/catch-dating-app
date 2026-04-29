import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        : ref.watch(signedUpRunsProvider(uid));

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: runsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _CalendarMessage(
            title: 'Calendar unavailable',
            body: 'Your booked runs could not be loaded.',
            tokens: t,
          ),
          data: (runs) => Column(
            children: [
              _CalendarHeader(
                mode: _mode,
                onModeChanged: (mode) => setState(() => _mode = mode),
                runs: runs,
                tokens: t,
              ),
              Expanded(
                child: runs.isEmpty
                    ? _CalendarMessage(
                        title: 'No booked runs yet',
                        body:
                            'Runs you book will show up here by day and time.',
                        tokens: t,
                      )
                    : _mode == CalendarViewMode.agenda
                    ? _AgendaView(runs: runs, tokens: t)
                    : _TimelineView(runs: runs, tokens: t),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum CalendarViewMode { agenda, timeline }

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.mode,
    required this.onModeChanged,
    required this.runs,
    required this.tokens,
  });

  final CalendarViewMode mode;
  final ValueChanged<CalendarViewMode> onModeChanged;
  final List<Run> runs;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    final sortedRuns = [...runs]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final totalDistance = sortedRuns.fold<double>(
      0,
      (sum, run) => sum + run.distanceKm,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.screenH,
        Sizes.p8,
        CatchSpacing.screenH,
        Sizes.p12,
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
                      _monthLabel(sortedRuns),
                      style: CatchTextStyles.labelSm(context),
                    ),
                    gapH2,
                    Text('Calendar', style: CatchTextStyles.displayMd(context)),
                  ],
                ),
              ),
              _ModeToggle(
                mode: mode,
                onModeChanged: onModeChanged,
                tokens: tokens,
              ),
            ],
          ),
          gapH14,
          _WeekStrip(runs: sortedRuns, tokens: tokens),
          gapH14,
          Container(
            padding: const EdgeInsets.all(Sizes.p14),
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: BorderRadius.circular(CatchRadius.card),
              border: Border.all(color: tokens.line),
            ),
            child: Row(
              children: [
                _HeaderStat(
                  label: 'Booked',
                  value: '${runs.length}',
                  tokens: tokens,
                ),
                _StatDivider(tokens: tokens),
                _HeaderStat(
                  label: 'Distance',
                  value: '${totalDistance.round()} km',
                  tokens: tokens,
                ),
                _StatDivider(tokens: tokens),
                _HeaderStat(
                  label: 'Next',
                  value: sortedRuns.isEmpty
                      ? 'None'
                      : RunFormatters.time(sortedRuns.first.startTime),
                  tokens: tokens,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _monthLabel(List<Run> runs) {
    if (runs.isEmpty) return 'Your runs';
    final date = runs.first.startTime;
    return '${_monthName(date.month)} ${date.year}';
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.mode,
    required this.onModeChanged,
    required this.tokens,
  });

  final CalendarViewMode mode;
  final ValueChanged<CalendarViewMode> onModeChanged;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.raised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tokens.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            _ModeButton(
              label: 'Day',
              selected: mode == CalendarViewMode.timeline,
              onTap: () => onModeChanged(CalendarViewMode.timeline),
              tokens: tokens,
            ),
            _ModeButton(
              label: 'Agenda',
              selected: mode == CalendarViewMode.agenda,
              onTap: () => onModeChanged(CalendarViewMode.agenda),
              tokens: tokens,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.tokens,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? tokens.ink : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          style: CatchTextStyles.caption(
            context,
            color: selected ? tokens.surface : tokens.ink2,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.runs, required this.tokens});

  final List<Run> runs;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    final anchor = runs.isEmpty ? DateTime.now() : runs.first.startTime;
    final monday = anchor.subtract(Duration(days: anchor.weekday - 1));
    final runDays = runs
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
              tokens: tokens,
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
    required this.tokens,
  });

  final DateTime date;
  final bool active;
  final bool hasRun;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    final day = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][date.weekday - 1];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: active ? tokens.ink : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            day,
            style: CatchTextStyles.caption(
              context,
              color: active
                  ? tokens.surface.withValues(alpha: 0.72)
                  : tokens.ink3,
            ),
          ),
          gapH2,
          Text(
            '${date.day}',
            style: CatchTextStyles.labelMd(
              context,
              color: active ? tokens.surface : tokens.ink,
            ),
          ),
          gapH4,
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: hasRun ? tokens.primary : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _AgendaView extends StatelessWidget {
  const _AgendaView({required this.runs, required this.tokens});

  final List<Run> runs;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    final grouped = _groupRuns(runs);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.screenH,
        Sizes.p4,
        CatchSpacing.screenH,
        Sizes.p24,
      ),
      children: [
        for (final entry in grouped.entries) ...[
          Text(
            _dayLabel(entry.key).toUpperCase(),
            style: CatchTextStyles.labelSm(
              context,
              color: DateUtils.isSameDay(entry.key, DateTime.now())
                  ? tokens.primary
                  : tokens.ink3,
            ),
          ),
          gapH8,
          for (final run in entry.value) ...[
            _AgendaRunCard(run: run, tokens: tokens),
            gapH10,
          ],
          gapH10,
        ],
      ],
    );
  }
}

class _AgendaRunCard extends StatelessWidget {
  const _AgendaRunCard({required this.run, required this.tokens});

  final Run run;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sizes.p14),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(CatchRadius.card),
        border: Border.all(color: tokens.line),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 64,
            decoration: BoxDecoration(
              color: tokens.primary,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  RunFormatters.time(run.startTime),
                  style: CatchTextStyles.labelSm(context),
                ),
                gapH4,
                Text(
                  run.meetingPoint,
                  style: CatchTextStyles.labelMd(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                gapH4,
                Text(
                  '${RunFormatters.distanceKm(run.distanceKm)} · ${run.pace.label} · ${run.signedUpUserIds.length}/${run.capacityLimit}',
                  style: CatchTextStyles.bodySm(context, color: tokens.ink2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: tokens.primarySoft,
              borderRadius: BorderRadius.circular(CatchRadius.button),
            ),
            child: Text(
              'JOINED',
              style: CatchTextStyles.labelSm(context, color: tokens.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineView extends StatelessWidget {
  const _TimelineView({required this.runs, required this.tokens});

  final List<Run> runs;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    final sorted = [...runs]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.screenH,
        Sizes.p8,
        CatchSpacing.screenH,
        Sizes.p24,
      ),
      children: [
        Text('Day timeline', style: CatchTextStyles.labelSm(context)),
        gapH12,
        for (final run in sorted) _TimelineRun(run: run, tokens: tokens),
      ],
    );
  }
}

class _TimelineRun extends StatelessWidget {
  const _TimelineRun({required this.run, required this.tokens});

  final Run run;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 56,
            child: Text(
              RunFormatters.time(run.startTime),
              style: CatchTextStyles.caption(context, color: tokens.ink3),
            ),
          ),
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: tokens.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(child: Container(width: 1, color: tokens.line)),
            ],
          ),
          gapW12,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                padding: const EdgeInsets.all(Sizes.p14),
                decoration: BoxDecoration(
                  color: tokens.primary,
                  borderRadius: BorderRadius.circular(CatchRadius.card),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      run.meetingPoint,
                      style: CatchTextStyles.labelMd(
                        context,
                        color: tokens.primaryInk,
                      ),
                    ),
                    gapH4,
                    Text(
                      '${RunFormatters.distanceKm(run.distanceKm)} · ${run.pace.label}',
                      style: CatchTextStyles.bodySm(
                        context,
                        color: tokens.primaryInk.withValues(alpha: 0.84),
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

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({
    required this.label,
    required this.value,
    required this.tokens,
  });

  final String label;
  final String value;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: CatchTextStyles.labelSm(context)),
          gapH2,
          Text(
            value,
            style: CatchTextStyles.displaySm(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider({required this.tokens});

  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: tokens.line,
    );
  }
}

class _CalendarMessage extends StatelessWidget {
  const _CalendarMessage({
    required this.title,
    required this.body,
    required this.tokens,
  });

  final String title;
  final String body;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              color: tokens.primary,
              size: 44,
            ),
            gapH12,
            Text(title, style: CatchTextStyles.displaySm(context)),
            gapH6,
            Text(
              body,
              textAlign: TextAlign.center,
              style: CatchTextStyles.bodyMd(context, color: tokens.ink2),
            ),
          ],
        ),
      ),
    );
  }
}

Map<DateTime, List<Run>> _groupRuns(List<Run> runs) {
  final sorted = [...runs]..sort((a, b) => a.startTime.compareTo(b.startTime));
  final grouped = <DateTime, List<Run>>{};
  for (final run in sorted) {
    final day = DateUtils.dateOnly(run.startTime);
    grouped.putIfAbsent(day, () => []).add(run);
  }
  return grouped;
}

String _dayLabel(DateTime date) {
  if (DateUtils.isSameDay(date, DateTime.now())) return 'Today';
  return '${_weekdayName(date.weekday)} · ${date.day} ${_monthName(date.month)}';
}

String _weekdayName(int weekday) {
  return const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];
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
