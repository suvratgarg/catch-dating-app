import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/stat_column.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:flutter/material.dart';

class StatsStrip extends StatelessWidget {
  const StatsStrip({
    super.key,
    required this.club,
    required this.upcomingCount,
  });

  final RunClub club;
  final int upcomingCount;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: t.raised,
        borderRadius: BorderRadius.circular(CatchRadius.md),
        border: Border.all(color: t.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: StatColumn(
              value: '${club.memberCount}',
              label: 'Members',
              monoValue: true,
              center: true,
            ),
          ),
          Container(width: 1, height: 36, color: t.line),
          Expanded(
            child: StatColumn(
              value: '$upcomingCount',
              label: 'Upcoming',
              monoValue: true,
              center: true,
            ),
          ),
          Container(width: 1, height: 36, color: t.line),
          Expanded(
            child: StatColumn(
              value: club.rating > 0 ? club.rating.toStringAsFixed(1) : '—',
              label: 'Rating',
              monoValue: true,
              center: true,
            ),
          ),
        ],
      ),
    );
  }
}
