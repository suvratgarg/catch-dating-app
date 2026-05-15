import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
import 'package:catch_dating_app/core/widgets/person_row.dart';
import 'package:catch_dating_app/host_tools/presentation/host_club_tools.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/runs/data/run_participation_repository.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_participation_roster.dart';
import 'package:catch_dating_app/runs/presentation/widgets/who_is_running.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HostRunManageRouteScreen extends ConsumerWidget {
  const HostRunManageRouteScreen({
    super.key,
    required this.runClubId,
    required this.runId,
  });

  final String runClubId;
  final String runId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidAsync = ref.watch(uidProvider);
    final runClubAsync = ref.watch(fetchRunClubProvider(runClubId));
    final runAsync = ref.watch(watchRunProvider(runId));

    final loading =
        uidAsync.isLoading || runClubAsync.isLoading || runAsync.isLoading;
    if (loading) {
      return Scaffold(
        backgroundColor: CatchTokens.of(context).bg,
        body: const SafeArea(child: Center(child: CatchLoadingIndicator())),
      );
    }

    final error = uidAsync.error ?? runClubAsync.error ?? runAsync.error;
    if (error != null) {
      return CatchErrorScaffold.fromError(
        error,
        context: AppErrorContext.run,
        onRetry: () {
          ref.invalidate(fetchRunClubProvider(runClubId));
          ref.invalidate(watchRunProvider(runId));
        },
      );
    }

    final uid = uidAsync.asData?.value;
    final runClub = runClubAsync.asData?.value;
    final run = runAsync.asData?.value;
    if (runClub == null || run == null) {
      return const CatchErrorScaffold(
        title: 'Run not found',
        message: 'This hosted run is no longer available.',
      );
    }

    if (uid == null || runClub.hostUserId != uid) {
      return const CatchErrorScaffold(
        title: 'Action unavailable',
        message: 'You can manage only runs that you host.',
        icon: Icons.block_rounded,
      );
    }

    return HostRunManageScreen(
      runClub: runClub,
      run: run,
      onBackToSuccess: () => Navigator.of(context).maybePop(),
    );
  }
}

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
    final rosterAsync = ref.watch(watchRunParticipationRosterProvider(run.id));
    final roster = rosterAsync.asData?.value;
    final bookedCount = roster?.bookedCount ?? run.signedUpCount;
    final waitlistCount = roster?.waitlistedCount ?? run.waitlistCount;
    final revenueRupees = bookedCount * (run.priceInPaise ~/ 100);

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
                gapW12,
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
            gapH18,
            if (run.isFull) ...[
              CatchSurface(
                padding: const EdgeInsets.all(CatchSpacing.s4),
                backgroundColor: t.ink,
                borderWidth: 0,
                radius: CatchRadius.lg,
                child: Row(
                  children: [
                    Icon(Icons.lock_rounded, color: t.surface, size: 18),
                    gapW10,
                    Text(
                      'FULL',
                      style: CatchTextStyles.titleM(context, color: t.surface),
                    ),
                  ],
                ),
              ),
              gapH12,
            ],
            Row(
              children: [
                Expanded(
                  child: HostStatChip(
                    icon: Icons.check_circle_outline_rounded,
                    value: '$bookedCount/${run.capacityLimit}',
                    label: 'Booked',
                  ),
                ),
                gapW8,
                Expanded(
                  child: HostStatChip(
                    icon: Icons.access_time_rounded,
                    value: '$waitlistCount',
                    label: 'Waitlist',
                  ),
                ),
                gapW8,
                Expanded(
                  child: HostStatChip(
                    icon: Icons.currency_rupee_rounded,
                    value: revenueRupees > 0 ? '₹$revenueRupees' : '-',
                    label: 'Revenue',
                  ),
                ),
              ],
            ),
            gapH20,
            _HostRunSummaryCard(runClub: runClub, run: run),
            gapH20,
            _HostRosterHeader(
              icon: Icons.groups_2_outlined,
              title: 'Roster',
              count: bookedCount,
            ),
            gapH10,
            _HostRunRosterSection(
              rosterAsync: rosterAsync,
              runId: run.id,
              selector: (roster) => roster.bookedIds,
              emptyText: 'No bookings yet.',
              loadingText: 'Loading bookings...',
              trailingLabel: run.isFree ? 'FREE' : 'PAID',
            ),
            gapH20,
            _HostRosterHeader(
              icon: Icons.pending_actions_outlined,
              title: 'Waitlist',
              count: waitlistCount,
            ),
            gapH10,
            _HostRunRosterSection(
              rosterAsync: rosterAsync,
              runId: run.id,
              selector: (roster) => roster.waitlistedIds,
              emptyText: 'No one is waiting.',
              loadingText: 'Loading waitlist...',
              trailingLabel: 'WAITLIST',
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s4,
        vertical: CatchSpacing.s3,
      ),
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
            gapW10,
            Text(label, style: CatchTextStyles.bodyS(context, color: t.ink2)),
            gapW16,
            Expanded(
              child: Text(
                value,
                style: CatchTextStyles.labelL(context),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (showDivider) ...[gapH12, Divider(color: t.line, height: 1), gapH12],
      ],
    );
  }
}

class _HostRosterHeader extends StatelessWidget {
  const _HostRosterHeader({
    required this.icon,
    required this.title,
    required this.count,
  });

  final IconData icon;
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Row(
      children: [
        Icon(icon, size: 18, color: t.ink2),
        gapW8,
        Text(title, style: CatchTextStyles.titleM(context)),
        const Spacer(),
        CatchBadge(
          label: '$count',
          tone: count == 0 ? CatchBadgeTone.neutral : CatchBadgeTone.brand,
        ),
      ],
    );
  }
}

class _HostRunRosterSection extends ConsumerWidget {
  const _HostRunRosterSection({
    required this.rosterAsync,
    required this.runId,
    required this.selector,
    required this.emptyText,
    required this.loadingText,
    required this.trailingLabel,
  });

  final AsyncValue<RunParticipationRoster> rosterAsync;
  final String runId;
  final List<String> Function(RunParticipationRoster roster) selector;
  final String emptyText;
  final String loadingText;
  final String trailingLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return rosterAsync.when(
      loading: () => _HostRunRosterLoading(text: loadingText),
      error: (e, _) => CatchInlineErrorState.fromError(
        e,
        context: AppErrorContext.run,
        compact: true,
        onRetry: () =>
            ref.invalidate(watchRunParticipationRosterProvider(runId)),
      ),
      data: (roster) => _HostRunUserList(
        userIds: selector(roster),
        emptyText: emptyText,
        trailingLabel: trailingLabel,
      ),
    );
  }
}

class _HostRunRosterLoading extends StatelessWidget {
  const _HostRunRosterLoading({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      padding: const EdgeInsets.all(CatchSpacing.s4),
      borderColor: t.line,
      radius: CatchRadius.lg,
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: t.primary),
          ),
          gapW12,
          Text(text, style: CatchTextStyles.bodyS(context, color: t.ink2)),
        ],
      ),
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
              iconSize: 36,
              padding: const EdgeInsets.symmetric(
                horizontal: CatchSpacing.s4,
                vertical: CatchSpacing.s6,
              ),
              titleStyle: CatchTextStyles.titleM(context),
              messageStyle: CatchTextStyles.bodyS(context, color: t.ink2),
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
