import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
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
  });

  final String eventId;
  final Set<String> vibeIds;

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen> {
  Future<void> _recordSwipe(
    SwipeDirection direction, {
    ProfileReactionTarget? reactionTarget,
    String? comment,
  }) async {
    await ref
        .read(
          swipeQueueProvider(widget.eventId, vibeIds: widget.vibeIds).notifier,
        )
        .swipe(direction, reactionTarget: reactionTarget, comment: comment);
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
        loading: () => const CatchLoadingIndicator(),
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
                ),
              )
            : _CatchesProfileReview(
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

class _CatchesProfileReview extends StatelessWidget {
  const _CatchesProfileReview({
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
              final horizontalPadding = constraints.maxWidth > 700
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
                  bottomPadding: 112,
                  onReact: onReact,
                ),
              );
            },
          ),
        ),
        _CatchesTopOverlay(
          remainingCount: remainingCount,
          onBack: onBack,
          onFilters: onFilters,
        ),
        const _CatchesBottomScrim(),
        Positioned(
          left: CatchSpacing.s5,
          bottom: CatchSpacing.s4,
          child: CatchesPassButton(onPressed: onPass),
        ),
      ],
    );
  }
}

class _CatchesTopOverlay extends StatelessWidget {
  const _CatchesTopOverlay({
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
              _OverlayIconButton(
                tooltip: 'Back to Catches',
                icon: Icons.arrow_back_ios_new_rounded,
                onPressed: onBack,
              ),
              gapW10,
              Expanded(
                child: Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: t.surface.withValues(alpha: 0.84),
                      borderRadius: BorderRadius.circular(CatchRadius.pill),
                      border: Border.all(color: t.line.withValues(alpha: 0.72)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
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
              ),
              gapW10,
              _OverlayIconButton(
                tooltip: 'Filters',
                icon: Icons.tune_rounded,
                onPressed: onFilters,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverlayIconButton extends StatelessWidget {
  const _OverlayIconButton({
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

    return Tooltip(
      message: tooltip,
      child: Material(
        color: t.surface.withValues(alpha: 0.88),
        shape: const CircleBorder(),
        elevation: 3,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: 48,
            child: Icon(icon, color: t.ink, size: 22),
          ),
        ),
      ),
    );
  }
}

class _CatchesBottomScrim extends StatelessWidget {
  const _CatchesBottomScrim();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: 128,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                t.bg.withValues(alpha: 0.0),
                t.bg.withValues(alpha: 0.82),
                t.bg,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
