import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:flutter/material.dart';

class RunAgendaList extends StatelessWidget {
  const RunAgendaList({
    super.key,
    required this.runs,
    this.onRunSelected,
    this.badgeLabel,
    this.today,
  });

  final List<Run> runs;
  final ValueChanged<Run>? onRunSelected;
  final String? badgeLabel;
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        RunAgendaSliverList(
          runs: runs,
          onRunSelected: onRunSelected,
          badgeLabel: badgeLabel,
          today: today,
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
    this.today,
  });

  final List<Run> runs;
  final ValueChanged<Run>? onRunSelected;
  final String? badgeLabel;
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final grouped = _groupRuns(runs);
    final effectiveToday = today ?? DateTime.now();

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        Sizes.p4,
        CatchSpacing.s5,
        Sizes.p24,
      ),
      sliver: SliverList.list(
        children: [
          for (final entry in grouped.entries) ...[
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
              RunAgendaRunCard(
                run: run,
                badgeLabel: badgeLabel,
                onTap: onRunSelected == null
                    ? null
                    : () => onRunSelected!.call(run),
              ),
              gapH10,
            ],
            gapH10,
          ],
        ],
      ),
    );
  }
}

class RunAgendaRunCard extends StatelessWidget {
  const RunAgendaRunCard({
    super.key,
    required this.run,
    this.badgeLabel,
    this.onTap,
  });

  final Run run;
  final String? badgeLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      padding: const EdgeInsets.all(Sizes.p14),
      radius: CatchRadius.md,
      borderColor: t.line,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 4,
            height: 64,
            decoration: BoxDecoration(
              color: t.primary,
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
                  style: CatchTextStyles.labelM(context),
                ),
                gapH4,
                Text(
                  run.meetingPoint,
                  style: CatchTextStyles.labelL(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                gapH4,
                Text(
                  '${RunFormatters.distanceKm(run.distanceKm)} · ${run.pace.label} · ${run.signedUpUserIds.length}/${run.capacityLimit}',
                  style: CatchTextStyles.bodyS(context, color: t.ink2),
                ),
              ],
            ),
          ),
          if (badgeLabel != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: t.primarySoft,
                borderRadius: BorderRadius.circular(CatchRadius.pill),
              ),
              child: Text(
                badgeLabel!,
                style: CatchTextStyles.labelM(context, color: t.primary),
              ),
            ),
          ],
        ],
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

String _dayLabel(DateTime date, DateTime today) {
  if (DateUtils.isSameDay(date, today)) return 'Today';
  return '${RunFormatters.shortWeekday(date)} · ${date.day} ${RunFormatters.shortMonth(date)}';
}
