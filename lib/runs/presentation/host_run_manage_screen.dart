import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
import 'package:catch_dating_app/core/widgets/person_row.dart';
import 'package:catch_dating_app/core/widgets/stat_column.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/widgets/who_is_running.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HostRunManageScreen extends ConsumerWidget {
  const HostRunManageScreen({
    super.key,
    required this.runClub,
    required this.run,
    required this.onBackToSuccess,
  });

  final RunClub runClub;
  final Run run;
  final VoidCallback onBackToSuccess;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final revenueRupees = run.signedUpCount * (run.priceInPaise ~/ 100);

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            CatchSpacing.s5,
            12,
            CatchSpacing.s5,
            24,
          ),
          children: [
            Row(
              children: [
                IconBtn(
                  onTap: onBackToSuccess,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: t.ink,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HOST MANAGE',
                        style: CatchTextStyles.labelM(context, color: t.ink3)
                            .copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                      ),
                      Text(run.title, style: CatchTextStyles.titleL(context)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (run.isFull) ...[
              CatchSurface(
                padding: const EdgeInsets.all(14),
                backgroundColor: t.ink,
                borderWidth: 0,
                radius: CatchRadius.lg,
                child: Row(
                  children: [
                    Icon(Icons.lock_rounded, color: t.surface, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      'FULL',
                      style: CatchTextStyles.titleM(context, color: t.surface),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                _HostRunStatCard(
                  icon: Icons.check_circle_outline_rounded,
                  value: '${run.signedUpCount}/${run.capacityLimit}',
                  label: 'Booked',
                ),
                const SizedBox(width: 8),
                _HostRunStatCard(
                  icon: Icons.access_time_rounded,
                  value: '${run.waitlistUserIds.length}',
                  label: 'Waitlist',
                ),
                const SizedBox(width: 8),
                _HostRunStatCard(
                  icon: Icons.currency_rupee_rounded,
                  value: revenueRupees > 0 ? '₹$revenueRupees' : '-',
                  label: 'Revenue',
                ),
              ],
            ),
            const SizedBox(height: 20),
            _HostRunSummaryCard(runClub: runClub, run: run),
            const SizedBox(height: 20),
            Text('Roster', style: CatchTextStyles.titleL(context)),
            const SizedBox(height: 10),
            _HostRunUserList(
              userIds: run.signedUpUserIds,
              emptyText: 'No bookings yet.',
              trailingLabel: run.isFree ? 'FREE' : 'PAID',
            ),
            const SizedBox(height: 20),
            Text('Waitlist', style: CatchTextStyles.titleL(context)),
            const SizedBox(height: 10),
            _HostRunUserList(
              userIds: run.waitlistUserIds,
              emptyText: 'No one is waiting.',
              trailingLabel: 'WAITLIST',
            ),
          ],
        ),
      ),
    );
  }
}

class _HostRunStatCard extends StatelessWidget {
  const _HostRunStatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Expanded(
      child: CatchSurface(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        borderColor: t.line,
        radius: CatchRadius.lg,
        child: StatColumn(icon: icon, value: value, label: label),
      ),
    );
  }
}

class _HostRunSummaryCard extends StatelessWidget {
  const _HostRunSummaryCard({required this.runClub, required this.run});

  final RunClub runClub;
  final Run run;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final price = run.isFree ? 'Free' : '₹${run.priceInPaise ~/ 100}';

    return CatchSurface(
      padding: const EdgeInsets.all(16),
      borderColor: t.line,
      radius: CatchRadius.lg,
      child: Column(
        children: [
          _HostRunSummaryRow(
            icon: Icons.groups_rounded,
            label: 'Club',
            value: runClub.name,
          ),
          _HostRunSummaryRow(
            icon: Icons.location_on_outlined,
            label: 'Meet',
            value: run.meetingPoint,
          ),
          _HostRunSummaryRow(
            icon: Icons.route_rounded,
            label: 'Run',
            value:
                '${run.distanceKm.toStringAsFixed(1)} km · ${run.pace.label}',
          ),
          _HostRunSummaryRow(
            icon: Icons.payments_outlined,
            label: 'Price',
            value: price,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _HostRunSummaryRow extends StatelessWidget {
  const _HostRunSummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: t.ink2, size: 18),
            const SizedBox(width: 10),
            Text(label, style: CatchTextStyles.bodyS(context, color: t.ink2)),
            const Spacer(),
            Flexible(
              child: Text(
                value,
                style: CatchTextStyles.labelL(context),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (showDivider) ...[
          const SizedBox(height: 12),
          Divider(color: t.line, height: 1),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _HostRunUserList extends ConsumerWidget {
  const _HostRunUserList({
    required this.userIds,
    required this.emptyText,
    required this.trailingLabel,
  });

  final List<String> userIds;
  final String emptyText;
  final String trailingLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final profilesAsync = ref.watch(runnerProfilesProvider(userIds));
    final profiles = profilesAsync.asData?.value ?? {};

    return CatchSurface(
      borderColor: t.line,
      radius: CatchRadius.lg,
      clipBehavior: Clip.antiAlias,
      child: userIds.isEmpty
          ? CatchEmptyState(
              icon: Icons.group_outlined,
              title: emptyText,
              message: 'New sign-ups will appear here.',
              surface: false,
              iconStyle: CatchEmptyStateIconStyle.plain,
              padding: const EdgeInsets.all(16),
            )
          : Column(
              children: [
                for (var i = 0; i < userIds.length; i++) ...[
                  PersonRow(
                    data: PersonRowData(
                      name: profiles[userIds[i]]?.$1 ?? 'Runner',
                      imageUrl: profiles[userIds[i]]?.$2,
                      seed: userIds[i],
                      metaLine: profilesAsync.isLoading
                          ? 'Loading profile...'
                          : profiles[userIds[i]] == null
                          ? 'Profile unavailable'
                          : null,
                    ),
                    trailing: CatchBadge(
                      label: trailingLabel,
                      tone: trailingLabel == 'WAITLIST'
                          ? CatchBadgeTone.neutral
                          : CatchBadgeTone.brand,
                      uppercase: true,
                    ),
                  ),
                  if (i < userIds.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(left: 72),
                      child: Divider(color: t.line, height: 1),
                    ),
                ],
              ],
            ),
    );
  }
}
