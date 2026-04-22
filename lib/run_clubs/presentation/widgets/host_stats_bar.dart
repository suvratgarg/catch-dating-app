import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter/material.dart';

class HostStatsBar extends StatelessWidget {
  const HostStatsBar({super.key, required this.runs});

  final List<Run> runs;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    final totalBooked =
        runs.fold(0, (sum, r) => sum + r.signedUpUserIds.length);
    final totalWaitlist =
        runs.fold(0, (sum, r) => sum + r.waitlistUserIds.length);
    final revenueRupees = runs.fold(
        0,
        (sum, r) =>
            sum + r.signedUpUserIds.length * (r.priceInPaise ~/ 100));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.primarySoft,
        borderRadius: BorderRadius.circular(CatchRadius.card),
        border: Border.all(color: t.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, size: 16, color: t.primary),
              const SizedBox(width: 6),
              Text('Your upcoming runs',
                  style: CatchTextStyles.labelMd(context, color: t.primary)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: HostStatChip(
                  label: 'Booked',
                  value: '$totalBooked',
                  icon: Icons.check_circle_outline_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: HostStatChip(
                  label: 'Waitlist',
                  value: '$totalWaitlist',
                  icon: Icons.access_time_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: HostStatChip(
                  label: 'Revenue',
                  value: revenueRupees > 0 ? '₹$revenueRupees' : '—',
                  icon: Icons.currency_rupee_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HostStatChip extends StatelessWidget {
  const HostStatChip({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: t.primary),
          const SizedBox(height: 4),
          Text(value, style: CatchTextStyles.labelLg(context)),
          Text(label,
              style: CatchTextStyles.caption(context, color: t.ink3),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
