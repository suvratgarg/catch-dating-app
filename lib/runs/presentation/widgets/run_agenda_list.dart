import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_tiles/run_tiles.dart';
import 'package:flutter/material.dart';

typedef RunBadgeLabelBuilder = String? Function(Run run);
typedef RunClubNameBuilder = String? Function(Run run);
typedef RunTileStatusBuilder = RunTileStatus Function(Run run);
typedef RunAgendaDayKeyBuilder = Key? Function(DateTime date);

class RunAgendaList extends StatelessWidget {
  const RunAgendaList({
    super.key,
    required this.runs,
    this.onRunSelected,
    this.badgeLabel,
    this.badgeLabelBuilder,
    this.clubNameBuilder,
    this.statusBuilder,
    this.showClubName = false,
    this.today,
    this.preserveInputOrder = false,
    this.dayKeyBuilder,
  });

  final List<Run> runs;
  final ValueChanged<Run>? onRunSelected;
  final String? badgeLabel;
  final RunBadgeLabelBuilder? badgeLabelBuilder;
  final RunClubNameBuilder? clubNameBuilder;
  final RunTileStatusBuilder? statusBuilder;
  final bool showClubName;
  final DateTime? today;
  final bool preserveInputOrder;
  final RunAgendaDayKeyBuilder? dayKeyBuilder;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        RunAgendaSliverList(
          runs: runs,
          onRunSelected: onRunSelected,
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

class RunAgendaSliverList extends StatelessWidget {
  const RunAgendaSliverList({
    super.key,
    required this.runs,
    this.onRunSelected,
    this.badgeLabel,
    this.badgeLabelBuilder,
    this.clubNameBuilder,
    this.statusBuilder,
    this.showClubName = false,
    this.today,
    this.preserveInputOrder = false,
    this.dayKeyBuilder,
  });

  final List<Run> runs;
  final ValueChanged<Run>? onRunSelected;
  final String? badgeLabel;
  final RunBadgeLabelBuilder? badgeLabelBuilder;
  final RunClubNameBuilder? clubNameBuilder;
  final RunTileStatusBuilder? statusBuilder;
  final bool showClubName;
  final DateTime? today;
  final bool preserveInputOrder;
  final RunAgendaDayKeyBuilder? dayKeyBuilder;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final grouped = _groupRuns(runs, preserveInputOrder: preserveInputOrder);
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
              for (final run in entry.value) ...[
                Builder(
                  builder: (context) {
                    final effectiveBadge =
                        badgeLabelBuilder?.call(run) ?? badgeLabel;
                    return RunAgendaRunCard(
                      run: run,
                      badgeLabel: effectiveBadge,
                      clubName: clubNameBuilder?.call(run),
                      status:
                          statusBuilder?.call(run) ??
                          _statusForBadge(effectiveBadge),
                      showClubName: showClubName,
                      onTap: onRunSelected == null
                          ? null
                          : () => onRunSelected!.call(run),
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

class RunAgendaRunCard extends StatelessWidget {
  const RunAgendaRunCard({
    super.key,
    required this.run,
    this.badgeLabel,
    this.clubName,
    this.status = RunTileStatus.open,
    this.showClubName = false,
    this.onTap,
  });

  final Run run;
  final String? badgeLabel;
  final String? clubName;
  final RunTileStatus status;
  final bool showClubName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return RunAgendaTile(
      data: RunTileData.fromRun(run: run, status: status, clubName: clubName),
      onTap: onTap,
      showClubName: showClubName,
      badgeLabel: badgeLabel,
    );
  }
}

Map<DateTime, List<Run>> _groupRuns(
  List<Run> runs, {
  required bool preserveInputOrder,
}) {
  final sorted = preserveInputOrder
      ? runs
      : ([...runs]..sort((a, b) => a.startTime.compareTo(b.startTime)));
  final grouped = <DateTime, List<Run>>{};
  for (final run in sorted) {
    final day = DateUtils.dateOnly(run.startTime);
    grouped.putIfAbsent(day, () => []).add(run);
  }
  return grouped;
}

String _dayLabel(DateTime date, DateTime today) {
  if (DateUtils.isSameDay(date, today)) return 'Today';
  return '${RunFormatters.shortWeekday(date)} · ${date.day} ${RunFormatters.shortMonth(date)}';
}

RunTileStatus _statusForBadge(String? badgeLabel) {
  return switch (badgeLabel?.toUpperCase()) {
    'JOINED' => RunTileStatus.joined,
    'SAVED' => RunTileStatus.saved,
    'PAST' => RunTileStatus.past,
    'WAITLISTED' => RunTileStatus.waitlisted,
    'ATTENDED' => RunTileStatus.attended,
    'HOSTED' => RunTileStatus.hosted,
    'FULL' => RunTileStatus.full,
    _ => RunTileStatus.open,
  };
}
