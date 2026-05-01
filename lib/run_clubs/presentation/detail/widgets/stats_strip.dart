import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
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
          StatCell(value: '${club.memberCount}', label: 'Members'),
          Container(width: 1, height: 36, color: t.line),
          StatCell(value: '$upcomingCount', label: 'Upcoming'),
          Container(width: 1, height: 36, color: t.line),
          StatCell(
            value: club.rating > 0 ? club.rating.toStringAsFixed(1) : '—',
            label: 'Rating',
          ),
        ],
      ),
    );
  }
}

class StatCell extends StatelessWidget {
  const StatCell({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(value, style: CatchTextStyles.mono(context)),
          const SizedBox(height: 2),
          Text(
            label,
            style: CatchTextStyles.bodyS(context, color: t.ink3),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
