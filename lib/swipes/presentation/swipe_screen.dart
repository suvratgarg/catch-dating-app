import 'dart:async';

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/responsive/component_breakpoints.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/swipes/domain/swipe.dart';
import 'package:catch_dating_app/swipes/presentation/profile_surface.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_empty_content.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_queue_notifier.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/catches_pass_button.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_reaction_controls.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/swipe_empty_state.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({
    super.key,
    required this.eventId,
    this.vibeIds = const {},
    this.now,
  });

  final String eventId;
  final Set<String> vibeIds;
  final DateTime? now;

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen> {
  Future<void> _recordSwipe(
    SwipeDirection direction, {
    ProfileReactionTarget? reactionTarget,
    String? comment,
  }) async {
    Future<void> performSwipe() => ref
        .read(
          swipeQueueProvider(
            widget.eventId,
            vibeIds: widget.vibeIds,
          ).notifier,
        )
        .swipe(direction, reactionTarget: reactionTarget, comment: comment);

    try {
      await performSwipe();
    } catch (error) {
      // The deck only advances after the write succeeds, so on failure we keep
      // the current profile and surface the error instead of silently stalling.
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.swipes,
          onRetry: () {
            unawaited(performSwipe());
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final queueAsync = ref.watch(
      swipeQueueProvider(widget.eventId, vibeIds: widget.vibeIds),
    );
    final eventAsync = ref.watch(watchEventProvider(widget.eventId));
    final currentUserAsync = ref.watch(watchUserProfileProvider);
    final currentUser = currentUserAsync.asData?.value;
    final currentUserParticipation = currentUser == null
        ? null
        : ref
              .watch(
                watchEventParticipationProvider(
                  widget.eventId,
                  currentUser.uid,
                ),
              )
              .asData
              ?.value;

    return Scaffold(
      backgroundColor: t.bg,
      body: queueAsync.when(
        loading: () => const CatchesProfileReviewSkeleton(),
        error: (e, _) => CatchErrorState.fromError(
          e,
          context: AppErrorContext.swipes,
          onRetry: () => ref.invalidate(
            swipeQueueProvider(widget.eventId, vibeIds: widget.vibeIds),
          ),
        ),
        data: (profiles) => profiles.isEmpty
            ? SwipeEmptyState(
                content: buildSwipeEmptyContent(
                  event: eventAsync.asData?.value,
                  currentUser: currentUser,
                  currentUserParticipation: currentUserParticipation,
                  now: widget.now,
                ),
              )
            : CatchesProfileReview(
                profile: profiles.first,
                remainingCount: profiles.length,
                viewerProfile: currentUser,
                sharedRunTitle: eventAsync.asData?.value?.title,
                onBack: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.goNamed(Routes.swipeHubScreen.name);
                  }
                },
                onFilters: () => context.pushNamed(Routes.filtersScreen.name),
                onPass: () => _recordSwipe(SwipeDirection.pass),
                onReact: (target, comment) => _recordSwipe(
                  SwipeDirection.like,
                  reactionTarget: target,
                  comment: comment,
                ),
              ),
      ),
    );
  }
}

class CatchesProfileReviewSkeleton extends StatelessWidget {
  const CatchesProfileReviewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: ProfileSurfaceSkeleton(
            bottomPadding: CatchLayout.catchesProfileBottomPadding,
          ),
        ),
        const CatchesTopOverlaySkeleton(),
        const CatchesBottomScrim(),
        Positioned(
          left: CatchSpacing.s5,
          bottom: CatchSpacing.s4,
          child: CatchesPassButtonSkeleton(),
        ),
      ],
    );
  }
}

class CatchesProfileReview extends StatelessWidget {
  const CatchesProfileReview({
    super.key,
    required this.profile,
    required this.remainingCount,
    required this.onBack,
    required this.onFilters,
    required this.onPass,
    required this.onReact,
    this.viewerProfile,
    this.sharedRunTitle,
  });

  final PublicProfile profile;
  final int remainingCount;
  final VoidCallback onBack;
  final VoidCallback onFilters;
  final VoidCallback onPass;
  final ProfileReactionCallback onReact;
  final UserProfile? viewerProfile;
  final String? sharedRunTitle;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding =
                  constraints.maxWidth >
                      ComponentBreakpoints.catchesWidePaddingBreakpoint
                  ? CatchSpacing.s8
                  : 0.0;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: ProfileSurface(
                  key: ValueKey(profile.uid),
                  profile: profile,
                  mode: ProfileSurfaceMode.catches,
                  viewerProfile: viewerProfile,
                  sharedRunTitle: sharedRunTitle,
                  bottomPadding: CatchLayout.catchesProfileBottomPadding,
                  onReact: onReact,
                ),
              );
            },
          ),
        ),
        CatchesTopOverlay(
          remainingCount: remainingCount,
          onBack: onBack,
          onFilters: onFilters,
        ),
        const CatchesBottomScrim(),
        Positioned(
          left: CatchSpacing.s5,
          bottom: CatchSpacing.s4,
          child: CatchesPassButton(onPressed: onPass),
        ),
      ],
    );
  }
}

class CatchesTopOverlaySkeleton extends StatelessWidget {
  const CatchesTopOverlaySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            CatchSpacing.s4,
            CatchSpacing.s3,
            CatchSpacing.s4,
            0,
          ),
          child: Row(
            children: [
              const OverlayIconSkeleton(),
              gapW10,
              Expanded(
                child: Center(
                  child: CatchSkeleton.box(
                    width: CatchSpacing.s16 * 3,
                    height: CatchSpacing.s9,
                    radius: CatchRadius.pill,
                    borderColor: t.line.withValues(
                      alpha: CatchOpacity.floatingChromeBorder,
                    ),
                  ),
                ),
              ),
              gapW10,
              const OverlayIconSkeleton(),
            ],
          ),
        ),
      ),
    );
  }
}

class OverlayIconSkeleton extends StatelessWidget {
  const OverlayIconSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CatchSkeleton.circle();
  }
}

class CatchesPassButtonSkeleton extends StatelessWidget {
  const CatchesPassButtonSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CatchSkeleton.circle(size: CatchLayout.passButtonExtent);
  }
}

class CatchesTopOverlay extends StatelessWidget {
  const CatchesTopOverlay({
    super.key,
    required this.remainingCount,
    required this.onBack,
    required this.onFilters,
  });

  final int remainingCount;
  final VoidCallback onBack;
  final VoidCallback onFilters;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            CatchSpacing.s4,
            CatchSpacing.s3,
            CatchSpacing.s4,
            0,
          ),
          child: Row(
            children: [
              OverlayIconAction(
                tooltip: 'Back to Catches',
                icon: CatchIcons.arrowBackIosNewRounded,
                onPressed: onBack,
              ),
              gapW10,
              Expanded(
                child: Center(
                  child: CatchSurface(
                    radius: CatchRadius.pill,
                    backgroundColor: t.surface.withValues(
                      alpha: CatchOpacity.floatingChromeFill,
                    ),
                    borderColor: t.line.withValues(
                      alpha: CatchOpacity.floatingChromeBorder,
                    ),
                    boxShadow: CatchElevation.card,
                    padding: const EdgeInsets.symmetric(
                      horizontal: CatchSpacing.s4,
                      vertical: CatchSpacing.s2,
                    ),
                    child: Text(
                      'Catches · $remainingCount left',
                      style: CatchTextStyles.labelM(context, color: t.ink),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              gapW10,
              OverlayIconAction(
                tooltip: 'Filters',
                icon: CatchIcons.tuneRounded,
                onPressed: onFilters,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OverlayIconAction extends StatelessWidget {
  const OverlayIconAction({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Semantics(
      label: tooltip,
      button: true,
      child: Tooltip(
        message: tooltip,
        child: CatchIconButton(
          size: CatchLayout.floatingControlExtent,
          background: t.surface.withValues(alpha: CatchOpacity.floatingControlFill),
          onTap: onPressed,
          child: Icon(icon, color: t.ink, size: CatchIcon.row),
        ),
      ),
    );
  }
}

class CatchesBottomScrim extends StatelessWidget {
  const CatchesBottomScrim({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: CatchLayout.bottomActionScrimHeight,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                t.bg.withValues(alpha: CatchOpacity.none),
                t.bg.withValues(alpha: CatchOpacity.bottomActionScrim),
                t.bg,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
