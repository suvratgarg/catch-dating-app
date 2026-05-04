import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_error_text.dart';
import 'package:catch_dating_app/core/widgets/section_header.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/swipes/domain/swipe_window.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/attended_run_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SwipeHubScreen extends ConsumerWidget {
  const SwipeHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidAsync = ref.watch(uidProvider);
    final t = CatchTokens.of(context);

    return Scaffold(
      backgroundColor: t.bg,
      body: uidAsync.when(
        loading: () => const CatchSkeletonList(count: 3),
        error: (e, _) => CatchErrorText(e),
        data: (uid) {
          if (uid == null) return const SizedBox.shrink();

          final runsAsync = ref.watch(watchAttendedRunsProvider(uid));

          return runsAsync.when(
            loading: () => const CatchSkeletonList(count: 3),
            error: (e, _) => CatchErrorText(e),
            data: (runs) {
              final activeRuns = runsWithOpenSwipeWindow(runs);

              if (activeRuns.isEmpty) {
                return _CatchesEmptyState(tokens: t);
              }

              return _CatchesHubContent(activeRuns: activeRuns, tokens: t);
            },
          );
        },
      ),
    );
  }
}

class _CatchesHubContent extends StatelessWidget {
  const _CatchesHubContent({required this.activeRuns, required this.tokens});

  final List<Run> activeRuns;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    final featuredRun = activeRuns.first;
    final remaining = swipeWindowClosesAt(
      featuredRun,
    ).difference(DateTime.now());

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          CatchSpacing.s5,
          Sizes.p8,
          CatchSpacing.s5,
          Sizes.p24,
        ),
        children: [
          _CatchesHeader(tokens: t),
          gapH16,
          _CatchesIntroCard(
            tokens: t,
            run: featuredRun,
            remaining: remaining,
            onTap: () => context.pushNamed(
              Routes.swipeRunScreen.name,
              pathParameters: {'runId': featuredRun.id},
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Open catch windows',
                  style: CatchTextStyles.titleL(context),
                ),
              ),
              Text(
                '${activeRuns.length}',
                style: CatchTextStyles.mono(context, color: t.primary),
              ),
            ],
          ),
          gapH12,
          for (final run in activeRuns) ...[
            AttendedRunTile(run: run),
            if (run != activeRuns.last) gapH12,
          ],
        ],
      ),
    );
  }
}

class _CatchesHeader extends StatelessWidget {
  const _CatchesHeader({required this.tokens});

  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: 'CATCHES', heavy: true),
              gapH2,
              Text('After the run', style: CatchTextStyles.displayL(context)),
            ],
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: t.primarySoft,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.favorite_rounded, color: t.primary, size: 21),
        ),
      ],
    );
  }
}

class _CatchesIntroCard extends StatelessWidget {
  const _CatchesIntroCard({
    required this.tokens,
    required this.run,
    required this.remaining,
    required this.onTap,
  });

  final CatchTokens tokens;
  final Run run;
  final Duration remaining;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = tokens;

    return CatchSurface(
      onTap: onTap,
      padding: const EdgeInsets.all(Sizes.p20),
      gradient: t.heroGrad,
      borderWidth: 0,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -34,
            top: -42,
            child: Icon(
              Icons.favorite_rounded,
              size: 156,
              color: Colors.white.withValues(alpha: 0.13),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '24H WINDOW OPEN',
                style: CatchTextStyles.labelM(
                  context,
                  color: Colors.white,
                ).copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.4),
              ),
              gapH10,
              Text(
                "You ran together.\nNow it's okay to swipe.",
                style: CatchTextStyles.displayL(
                  context,
                  color: Colors.white,
                ).copyWith(height: 1.08),
              ),
              gapH10,
              Text(
                'Only checked-in runners from ${run.title} are here.',
                style: CatchTextStyles.bodyS(
                  context,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              gapH18,
              Row(
                children: [
                  _PillStat(
                    label: 'Closes in',
                    value: _formatCountdown(remaining),
                    tokens: t,
                  ),
                  gapW10,
                  _PillStat(
                    label: 'Roster',
                    value: '${run.attendedUserIds.length}',
                    tokens: t,
                  ),
                ],
              ),
              gapH18,
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(CatchRadius.pill),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Start catching',
                  style: CatchTextStyles.titleM(context, color: t.ink),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatCountdown(Duration remaining) {
    if (remaining.isNegative) return 'Closed';
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }
}

class _PillStat extends StatelessWidget {
  const _PillStat({
    required this.label,
    required this.value,
    required this.tokens,
  });

  final String label;
  final String value;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CatchSurface(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        radius: CatchRadius.md,
        backgroundColor: Colors.white.withValues(alpha: 0.17),
        borderColor: Colors.white.withValues(alpha: 0.18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: CatchTextStyles.bodyS(
                context,
                color: Colors.white.withValues(alpha: 0.78),
              ),
            ),
            gapH2,
            Text(
              value,
              style: CatchTextStyles.mono(context, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatchesEmptyState extends StatelessWidget {
  const _CatchesEmptyState({required this.tokens});

  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          CatchSpacing.s5,
          Sizes.p8,
          CatchSpacing.s5,
          Sizes.p24,
        ),
        children: [
          _CatchesHeader(tokens: t),
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.12),
          CatchSurface(
            padding: const EdgeInsets.all(Sizes.p20),
            borderColor: t.line,
            child: Column(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: t.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.directions_run_rounded,
                    size: 34,
                    color: t.primary,
                  ),
                ),
                gapH18,
                Text(
                  'No active catches',
                  style: CatchTextStyles.displayM(context),
                  textAlign: TextAlign.center,
                ),
                gapH8,
                Text(
                  'Book a group run, show up, and your 24-hour catch window opens here after check-in.',
                  style: CatchTextStyles.bodyM(context, color: t.ink2),
                  textAlign: TextAlign.center,
                ),
                gapH18,
                CatchButton(
                  label: 'Find a run',
                  onPressed: () => context.go(Routes.runClubsListScreen.path),
                  variant: CatchButtonVariant.secondary,
                ),
              ],
            ),
          ),
          gapH18,
          CatchSurface(
            padding: const EdgeInsets.all(Sizes.p16),
            tone: CatchSurfaceTone.raised,
            borderColor: t.line,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_clock_rounded, color: t.accent, size: 20),
                gapW10,
                Expanded(
                  child: Text(
                    'Dating stays locked until you actually run together. No cold swiping strangers.',
                    style: CatchTextStyles.bodyS(context, color: t.ink2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
