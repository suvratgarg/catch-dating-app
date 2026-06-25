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
        CatchStatStripItem(
          value: club.rating > 0 ? club.rating.toStringAsFixed(1) : '—',
          label: 'Rating',
        ),
        CatchStatStripItem(value: '${club.reviewCount}', label: 'Reviews'),
        CatchStatStripItem(value: _establishedLabel(club), label: 'Est.'),
      ],
    );
  }
}

String _establishedLabel(Club club) {
  const months = <String>[
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];
  final month = months[(club.createdAt.month - 1).clamp(0, 11)];
  final year = (club.createdAt.year % 100).toString().padLeft(2, '0');
  return '$month \'$year';
}
