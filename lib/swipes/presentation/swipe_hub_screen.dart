import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_tile.dart';
import 'package:catch_dating_app/core/widgets/catch_section_header.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/swipes/presentation/catches_hub_screen_state.dart';
import 'package:catch_dating_app/swipes/presentation/catches_hub_view_model.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_keys.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/attended_event_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SwipeHubScreen extends ConsumerWidget {
  const SwipeHubScreen({super.key, this.now});

  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidAsync = ref.watch(uidProvider);
    final referenceNow = now ?? DateTime.now();
    final userId = uidAsync.asData?.value;
    final eventsAsync = userId == null
        ? null
        : ref.watch(watchAttendedEventsProvider(userId));
    final state = buildCatchesHubScreenState(
      uid: uidAsync,
      attendedEvents: eventsAsync,
      now: referenceNow,
    );

    return Scaffold(
      backgroundColor: CatchTokens.of(context).bg,
      body: CatchesHubStateView(state: state),
    );
  }
}

class CatchesHubStateView extends ConsumerWidget {
  const CatchesHubStateView({super.key, required this.state});

  final CatchesHubScreenState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (state) {
      CatchesHubAccessLoading() => const CatchSkeletonList(),
      CatchesHubAccessError(:final error) => CatchErrorState.fromError(
        error,
        context: AppErrorContext.auth,
        onRetry: () => ref.invalidate(uidProvider),
      ),
      CatchesHubSignedOut() => const SizedBox.shrink(),
      CatchesHubEventsLoading() => const CatchSkeletonList(),
      CatchesHubEventsError(:final uid, :final error) =>
        CatchErrorState.fromError(
          error,
          context: AppErrorContext.event,
          onRetry: () => ref.invalidate(watchAttendedEventsProvider(uid)),
        ),
      CatchesHubEmpty() => CatchesHubEmptyState(
        onFindEvent: () => context.go(Routes.exploreScreen.path),
      ),
      final CatchesHubReady ready => CatchesHubContent(
        state: ready,
        onOpenCatch: (row) => context.push(row.openCatchRoute),
        onOpenRecap: (row) => context.push(row.recapRoute),
      ),
    };
  }
}

class CatchesHubContent extends StatelessWidget {
  const CatchesHubContent({
    super.key,
    required this.state,
    required this.onOpenCatch,
    required this.onOpenRecap,
  });

  final CatchesHubReady state;
  final ValueChanged<CatchesHubEventRow> onOpenCatch;
  final ValueChanged<CatchesHubEventRow> onOpenRecap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final featuredRun = state.featuredRow;

    return SafeArea(
      child: ListView(
        padding: CatchInsets.pageBodyHero,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: CatchLayout.maxContentWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CatchesHubHeader(),
                  gapH16,
                  CatchesIntroCard(
                    row: featuredRun,
                    onTap: () => onOpenCatch(featuredRun),
                  ),
                  gapH24,
                  CatchSectionHeader(
                    title: 'Open catch windows',
                    heavy: true,
                    padding: const EdgeInsets.only(bottom: CatchSpacing.s3),
                    trailing: Text(
                      '${state.rows.length}',
                      style: CatchTextStyles.mono(context, color: t.primary),
                    ),
                  ),
                  CatchSectionList(
                    gap: CatchSpacing.s3,
                    children: [
                      for (final row in state.rows)
                        AttendedEventTile(
                          row: row,
                          onOpenCatch: () => onOpenCatch(row),
                          onOpenRecap: () => onOpenRecap(row),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CatchesHubHeader extends StatelessWidget {
  const CatchesHubHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CatchSectionHeader(title: 'Catches', heavy: true),
              gapH2,
              Text('After the event', style: CatchTextStyles.headline(context)),
            ],
          ),
        ),
        CatchIconTile(
          icon: CatchIcons.favoriteRounded,
          iconColor: t.primary,
          backgroundColor: t.primarySoft,
          borderColor: t.primarySoft,
          size: CatchIconButton.navSize,
          iconSize: CatchIcon.md,
          radius: CatchRadius.pill,
        ),
      ],
    );
  }
}

class CatchesIntroCard extends StatelessWidget {
  const CatchesIntroCard({super.key, required this.row, required this.onTap});

  final CatchesHubEventRow row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Semantics(
      label: 'Start catching',
      button: true,
      child: CatchSurface(
        key: SwipeKeys.activeCatchWindowCard,
        onTap: onTap,
        padding: CatchInsets.contentRelaxed,
        gradient: t.heroGrad,
        borderWidth: 0,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: CatchLayout.catchesHubBackgroundIconRightOffset,
              top: CatchLayout.catchesHubBackgroundIconTopOffset,
              child: Icon(
                CatchIcons.favoriteRounded,
                size: CatchLayout.catchesHubBackgroundIconSize,
                color: t.ink.withValues(alpha: CatchOpacity.clubRatingFill),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '24H WINDOW OPEN',
                  style: CatchTextStyles.kicker(context, color: t.ink),
                ),
                gapH10,
                Text(
                  'You ran together.\nNow you can catch.',
                  style: CatchTextStyles.headline(context, color: t.ink),
                ),
                gapH10,
                Text(
                  row.introSubtitle,
                  style: CatchTextStyles.proseM(
                    context,
                    color: t.ink.withValues(
                      alpha: CatchOpacity.photoSlotDeleteChrome,
                    ),
                  ),
                ),
                gapH18,
                Row(
                  children: [
                    PillStat(
                      label: 'Closes in',
                      value: row.introCountdownLabel,
                    ),
                    gapW10,
                    PillStat(label: 'Roster', value: row.attendedCountLabel),
                  ],
                ),
                gapH18,
                const CatchButton(
                  label: 'Start catching',
                  onPressed: null,
                  variant: CatchButtonVariant.light,
                  fullWidth: true,
                  isInteractive: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PillStat extends StatelessWidget {
  const PillStat({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Expanded(
      child: CatchSurface(
        padding: const EdgeInsets.symmetric(
          horizontal: CatchSpacing.s3,
          vertical: CatchSpacing.micro10,
        ),
        radius: CatchRadius.md,
        backgroundColor: t.ink.withValues(alpha: CatchOpacity.photoScrimMedium),
        borderColor: t.ink.withValues(
          alpha: CatchOpacity.eventSuccessSubtleBorder,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: CatchTextStyles.supporting(
                context,
                color: t.ink.withValues(
                  alpha: CatchOpacity.rosterFilterSelectedLabel,
                ),
              ),
            ),
            gapH2,
            Text(value, style: CatchTextStyles.mono(context, color: t.ink)),
          ],
        ),
      ),
    );
  }
}

class CatchesHubEmptyState extends StatelessWidget {
  const CatchesHubEmptyState({super.key, required this.onFindEvent});

  final VoidCallback onFindEvent;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: CatchInsets.pageBodyHero.copyWith(bottom: 0),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: CatchLayout.maxContentWidth,
                  ),
                  child: const CatchesHubHeader(),
                ),
              ),
            ),
          ),
          SliverLayoutBuilder(
            builder: (context, constraints) {
              final remainingHeight =
                  constraints.viewportMainAxisExtent -
                  constraints.precedingScrollExtent;
              return SliverToBoxAdapter(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: remainingHeight.clamp(0.0, double.infinity),
                  ),
                  child: Padding(
                    padding: CatchInsets.pageBodyHero.copyWith(
                      top: CatchSpacing.s4,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: CatchLayout.maxContentWidth,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CatchEmptyState(
                              icon: CatchIcons.directionsRunRounded,
                              title: 'No active catches',
                              message:
                                  'Book a group event, show up, and your 24-hour catch window opens here after check-in.',
                              action: CatchButton(
                                label: 'Find an event',
                                onPressed: onFindEvent,
                                variant: CatchButtonVariant.secondary,
                              ),
                            ),
                            gapH18,
                            CatchSurface(
                              padding: CatchInsets.content,
                              tone: CatchSurfaceTone.raised,
                              borderColor: t.line,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    CatchIcons.lockClockRounded,
                                    color: t.primary,
                                    size: CatchIcon.control,
                                  ),
                                  gapW10,
                                  Expanded(
                                    child: Text(
                                      'Dating stays locked until you actually run together. No cold stranger browsing.',
                                      style: CatchTextStyles.proseM(
                                        context,
                                        color: t.ink2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
