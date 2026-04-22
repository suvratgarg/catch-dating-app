import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StrideCard extends ConsumerWidget {
  const StrideCard({super.key, required this.tokens, required this.uid});

  final CatchTokens tokens;
  final String uid;

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  /// Returns the Monday of the week containing [date].
  static DateTime _weekStart(DateTime date) =>
      DateTime(date.year, date.month, date.day - (date.weekday - 1));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = tokens;
    final attendedAsync = ref.watch(attendedRunsProvider(uid));
    final attended = attendedAsync.asData?.value ?? [];

    final now = DateTime.now();
    final weekStart = _weekStart(now);
    final weekEnd = weekStart.add(const Duration(days: 7));
    final isToday = now.weekday - 1; // 0 = Mon

    final thisWeek = attended
        .where(
          (r) =>
              r.startTime.isAfter(weekStart) && r.startTime.isBefore(weekEnd),
        )
        .toList();

    // Sum km per weekday (0=Mon … 6=Sun).
    final kmPerDay = List<double>.filled(7, 0);
    for (final run in thisWeek) {
      final dayIdx = run.startTime.weekday - 1;
      kmPerDay[dayIdx] += run.distanceKm;
    }

    final totalKm = kmPerDay.fold<double>(0, (s, v) => s + v);
    final maxKm = kmPerDay.fold<double>(0, (m, v) => v > m ? v : m);

    return Container(
      padding: const EdgeInsets.all(Sizes.p18),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(CatchRadius.cardLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your stride · this week',
            style: CatchTextStyles.displaySm(context),
          ),
          gapH8,
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                totalKm.toStringAsFixed(1),
                style: CatchTextStyles.displayXl(
                  context,
                ).copyWith(fontSize: 36, letterSpacing: -1),
              ),
              gapW6,
              Text(
                'km · ${thisWeek.length} run${thisWeek.length == 1 ? '' : 's'}',
                style: CatchTextStyles.bodySm(context),
              ),
            ],
          ),
          gapH10,
          SizedBox(
            height: 58,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < 7; i++) ...[
                  if (i > 0) gapW6,
                  Expanded(
                    child: StrideBarColumn(
                      fraction: maxKm > 0 ? kmPerDay[i] / maxKm : 0,
                      dayLabel: _days[i],
                      isToday: i == isToday,
                      tokens: t,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StrideBarColumn extends StatelessWidget {
  const StrideBarColumn({
    super.key,
    required this.fraction,
    required this.dayLabel,
    required this.isToday,
    required this.tokens,
  });

  final double fraction;
  final String dayLabel;
  final bool isToday;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: fraction > 0 ? fraction : 0.04,
              child: Container(
                decoration: BoxDecoration(
                  color: fraction > 0
                      ? tokens.primary.withValues(alpha: isToday ? 0.5 : 1)
                      : tokens.line2,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        gapH4,
        Text(
          dayLabel,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            color: tokens.ink3,
          ),
        ),
      ],
    );
  }
}
