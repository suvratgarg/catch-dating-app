import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/stat_column.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_event_tools.dart';
import 'package:flutter/material.dart';

class HostClubManagementPanel extends StatelessWidget {
  const HostClubManagementPanel({
    super.key,
    required this.club,
    required this.events,
    required this.onEditClub,
    required this.onCreateEvent,
  });

  final Club club;
  final List<Event> events;
  final VoidCallback onEditClub;
  final VoidCallback onCreateEvent;

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
                  'Manage this club, publish events, and track upcoming demand.',
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                ),
                gapH12,
                Row(
                  children: [
                    Expanded(
                      child: HostStatChip(
                        label: 'Booked',
                        value: '$totalBooked',
                        icon: CatchIcons.checkCircleOutlineRounded,
                      ),
                    ),
                    gapW8,
                    Expanded(
                      child: HostStatChip(
                        label: 'Waitlist',
                        value: '$totalWaitlist',
                        icon: CatchIcons.accessTimeRounded,
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
                        icon: CatchIcons.paymentsRounded,
                      ),
                    ),
                  ],
                ),
                if (usesDemandPricing) ...[
                  gapH8,
                  Text(
                    'Base estimate uses starting prices; demand-priced bookings may settle higher.',
                    style: CatchTextStyles.supporting(context, color: t.ink2),
                  ),
                ],
                gapH12,
                CatchButton(
                  label: 'Add event',
                  onPressed: onCreateEvent,
                  icon: Icon(CatchIcons.addRounded, size: 18),
                  fullWidth: true,
                ),
                gapH10,
                CatchButton(
                  label: 'Edit club',
                  onPressed: onEditClub,
                  icon: Icon(CatchIcons.editOutlined, size: 18),
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
