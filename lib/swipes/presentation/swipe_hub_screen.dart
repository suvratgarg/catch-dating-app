import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_screen_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_header.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/swipes/presentation/catches_hub_screen_state.dart';
import 'package:catch_dating_app/swipes/presentation/catches_hub_view_model.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_keys.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/attended_event_tile.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
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

    final showHubChrome = state is CatchesHubEmpty || state is CatchesHubReady;
    final t = CatchTokens.of(context);

    final slivers = <Widget>[CatchesHubStateView(state: state)];
    if (!showHubChrome) {
      return CatchRootScreenScaffold.fullBleed(
        header: const SizedBox.shrink(),
        slivers: slivers,
      );
    }
    return CatchRootScreenScaffold.standard(
      header: CatchScreenHeaderTitle.block(
        eyebrow: context.l10n.swipesSwipeHubScreenTitleCatches,
        title: context.l10n.swipesSwipeHubScreenTextAfterTheEvent,
        actions: [
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
      ),
      slivers: slivers,
    );
  }
}

class CatchesHubStateView extends ConsumerWidget {
  const CatchesHubStateView({super.key, required this.state});

  final CatchesHubScreenState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (state) {
      CatchesHubAccessLoading() => const SliverToBoxAdapter(
        child: CatchSkeletonList(),
      ),
      CatchesHubAccessError(:final error) => CatchSliverErrorState.fromError(
        error,
        context: AppErrorContext.auth,
        onRetry: () => ref.invalidate(uidProvider),
      ),
      CatchesHubSignedOut() => const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      ),
      CatchesHubEventsLoading() => const SliverToBoxAdapter(
        child: CatchSkeletonList(),
      ),
      CatchesHubEventsError(:final uid, :final error) =>
        CatchSliverErrorState.fromError(
          error,
          context: AppErrorContext.event,
          onRetry: () => ref.invalidate(watchAttendedEventsProvider(uid)),
        ),
      CatchesHubEmpty() => CatchSliverStateViewport(
        child: CatchesHubEmptyState(
          onFindEvent: () => context.go(Routes.exploreScreen.path),
        ),
      ),
      final CatchesHubReady ready => SliverToBoxAdapter(
        child: CatchesHubContent(
          state: ready,
          onOpenCatch: (row) => context.push(row.openCatchRoute),
          onOpenRecap: (row) => context.push(row.recapRoute),
        ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CatchesIntroCard(
          row: featuredRun,
          onTap: () => onOpenCatch(featuredRun),
        ),
        gapH24,
        CatchSectionHeader(
          title: context.l10n.swipesSwipeHubScreenTitleOpenCatchWindows,
          heavy: true,
          padding: CatchInsets.sectionItemBottomGap,
          trailing: Text(
            context.l10n.swipesSwipeHubScreenTextLength(
              length: state.rows.length,
            ),
            style: CatchTextStyles.mono(context, color: t.primary),
          ),
        ),
        CatchSectionList(
          emptyStateOmitted: true,
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
      label: context.l10n.swipesSwipeHubScreenLabelStartCatching,
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
                  context.l10n.swipesSwipeHubScreenText24hWindowOpen,
                  style: CatchTextStyles.kicker(context, color: t.ink),
                ),
                gapH10,
                Text(
                  context.l10n.swipesSwipeHubScreenTextYouRanTogetherNow,
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
                      label: context.l10n.swipesSwipeHubScreenLabelClosesIn,
                      value: row.introCountdownLabel,
                    ),
                    gapW10,
                    PillStat(
                      label: context.l10n.swipesSwipeHubScreenLabelRoster,
                      value: row.attendedCountLabel,
                    ),
                  ],
                ),
                gapH18,
                CatchButton(
                  label: context.l10n.swipesSwipeHubScreenLabelStartCatching,
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
        padding: CatchInsets.catchesHubMetricContent,
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

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatchEmptyState(
            icon: CatchIcons.directionsRunRounded,
            title: context.l10n.swipesSwipeHubScreenTitleNoActiveCatches,
            message: context.l10n.swipesSwipeHubScreenMessageBookAGroupEvent,
            action: CatchButton(
              label: context.l10n.swipesSwipeHubScreenLabelFindAnEvent,
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
                    context.l10n.swipesSwipeHubScreenTextDatingStaysLockedUntil,
                    style: CatchTextStyles.proseM(context, color: t.ink2),
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
