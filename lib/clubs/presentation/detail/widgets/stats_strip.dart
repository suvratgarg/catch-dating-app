import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/widgets/catch_stat_strip.dart';
import 'package:flutter/material.dart';

class StatsStrip extends StatelessWidget {
  const StatsStrip({
    super.key,
    required this.club,
    required this.upcomingCount,
  });

  final Club club;
  final int upcomingCount;

  @override
  Widget build(BuildContext context) {
    return CatchStatStrip(
      items: [
        CatchStatStripItem(value: '${club.memberCount}', label: 'Members'),
        CatchStatStripItem(value: '$upcomingCount', label: 'Upcoming'),
        CatchStatStripItem(
          value: club.rating > 0 ? club.rating.toStringAsFixed(1) : '—',
          label: 'Rating',
        ),
      ],
    );
  }
}
