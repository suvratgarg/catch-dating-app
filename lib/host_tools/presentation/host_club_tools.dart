import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/stat_column.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/host_tools/presentation/host_event_tools.dart';
import 'package:flutter/material.dart';

class HostClubToolsPanel extends StatelessWidget {
  const HostClubToolsPanel({
    super.key,
    required this.club,
    required this.onEditClub,
    required this.onCreateEvent,
  });

  final Club club;
  final VoidCallback onEditClub;
  final VoidCallback onCreateEvent;

  @override
  Widget build(BuildContext context) {
    final palette = HostToolPalette.defaultPanel(context);

    return CatchSurface(
      padding: EdgeInsets.zero,
      backgroundColor: palette.background,
      borderColor: palette.border,
      radius: CatchRadius.lg,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: palette.gradientColors,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(CatchSpacing.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Wrap(
                  spacing: CatchSpacing.s2,
                  runSpacing: CatchSpacing.s1,
                  children: [
                    CatchBadge(
                      label: 'Host tools',
                      tone: CatchBadgeTone.brand,
                      uppercase: true,
                    ),
                    CatchBadge(
                      label: 'Club',
                      tone: CatchBadgeTone.neutral,
                      uppercase: true,
                    ),
                  ],
                ),
                gapH8,
                Text(
                  club.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.titleM(context),
                ),
                gapH4,
                Text(
                  'Manage this club and publish upcoming events.',
                  style: CatchTextStyles.bodyS(
                    context,
                    color: CatchTokens.of(context).ink2,
                  ),
                ),
                gapH12,
                CatchButton(
                  label: 'Add event',
                  onPressed: onCreateEvent,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  fullWidth: true,
                ),
                gapH10,
                CatchButton(
                  label: 'Edit club',
                  onPressed: onEditClub,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  variant: CatchButtonVariant.secondary,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HostStatsStrip extends StatelessWidget {
  const HostStatsStrip({super.key, required this.events});

  final List<Event> events;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final palette = HostToolPalette.defaultPanel(context);

    final totalBooked = events.fold(0, (sum, r) => sum + r.signedUpCount);
    final totalWaitlist = events.fold(0, (sum, r) => sum + r.waitlistCount);
    final baseRevenueEstimate = events.fold(
      0,
      (sum, r) => sum + r.signedUpCount * r.priceInPaise,
    );
    final usesDemandPricing = events.any(
      (event) => event.effectiveEventPolicy.usesDemandPricing,
    );

    return CatchSurface(
      padding: const EdgeInsets.all(CatchSpacing.s4),
      backgroundColor: palette.background,
      borderColor: palette.border,
      radius: CatchRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, size: 16, color: t.primary),
              gapW6,
              Text(
                'Your upcoming events',
                style: CatchTextStyles.labelL(context, color: t.primary),
              ),
            ],
          ),
          gapH12,
          Row(
            children: [
              Expanded(
                child: HostStatChip(
                  label: 'Booked',
                  value: '$totalBooked',
                  icon: Icons.check_circle_outline_rounded,
                ),
              ),
              gapW8,
              Expanded(
                child: HostStatChip(
                  label: 'Waitlist',
                  value: '$totalWaitlist',
                  icon: Icons.access_time_rounded,
                ),
              ),
              gapW8,
              Expanded(
                child: HostStatChip(
                  label: usesDemandPricing ? 'Base est.' : 'Revenue',
                  value: baseRevenueEstimate > 0
                      ? EventFormatters.priceInPaise(
                          baseRevenueEstimate,
                          currencyCode: events.isEmpty
                              ? defaultCurrencyCode
                              : events.first.currency,
                        )
                      : '-',
                  icon: Icons.payments_rounded,
                ),
              ),
            ],
          ),
          if (usesDemandPricing) ...[
            gapH8,
            Text(
              'Base estimate uses starting prices; demand-priced bookings may settle higher.',
              style: CatchTextStyles.bodyS(context, color: t.ink2),
            ),
          ],
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

    return CatchSurface(
      padding: const EdgeInsets.symmetric(
        vertical: CatchSpacing.s3,
        horizontal: CatchSpacing.s2,
      ),
      backgroundColor: t.surface,
      borderWidth: 0,
      radius: CatchRadius.sm,
      child: StatColumn(icon: icon, value: value, label: label, center: true),
    );
  }
}
