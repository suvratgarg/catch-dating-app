import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/runs/data/run_participation_repository.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/swipes/domain/swipe.dart';
import 'package:catch_dating_app/swipes/presentation/profile_card.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_empty_content.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_queue_notifier.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/swipe_action_buttons.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/swipe_empty_state.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({super.key, required this.runId, this.vibeIds = const {}});

  final String runId;
  final Set<String> vibeIds;

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen> {
  late final CardSwiperController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CardSwiperController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) async {
    final swipeDir = direction == CardSwiperDirection.right
        ? SwipeDirection.like
        : SwipeDirection.pass;
    await ref
        .read(
          swipeQueueProvider(widget.runId, vibeIds: widget.vibeIds).notifier,
        )
        .swipe(swipeDir);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final queueAsync = ref.watch(
      swipeQueueProvider(widget.runId, vibeIds: widget.vibeIds),
    );
    final runAsync = ref.watch(watchRunProvider(widget.runId));
    final currentUserAsync = ref.watch(watchUserProfileProvider);
    final currentUser = currentUserAsync.asData?.value;
    final currentUserParticipation = currentUser == null
        ? null
        : ref
              .watch(
                watchRunParticipationProvider(widget.runId, currentUser.uid),
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
            swipeQueueProvider(widget.runId, vibeIds: widget.vibeIds),
          ),
        ),
        data: (profiles) => profiles.isEmpty
            ? SwipeEmptyState(
                content: buildSwipeEmptyContent(
                  run: runAsync.asData?.value,
                  currentUser: currentUser,
                  currentUserParticipation: currentUserParticipation,
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              MediaQuery.of(context).size.width > 600 ? 48 : 8,
                              6,
                              MediaQuery.of(context).size.width > 600 ? 48 : 8,
                              0,
                            ),
                            child: CardSwiper(
                              key: ValueKey(
                                profiles
                                    .map((profile) => profile.uid)
                                    .join('|'),
                              ),
                              controller: _controller,
                              cardsCount: profiles.length,
                              numberOfCardsDisplayed: 1,
                              padding: EdgeInsets.zero,
                              onSwipe: _onSwipe,
                              allowedSwipeDirection:
                                  const AllowedSwipeDirection.only(
                                    left: true,
                                    right: true,
                                  ),
                              cardBuilder:
                                  (
                                    context,
                                    index,
                                    horizontalOffsetPercentage,
                                    verticalOffsetPercentage,
                                  ) {
                                    if (index >= profiles.length) {
                                      return const SizedBox.shrink();
                                    }
                                    final profile = profiles[index];
                                    return ProfileCard(
                                      profile: profile,
                                      horizontalOffsetPercentage:
                                          horizontalOffsetPercentage,
                                      bottomPadding: 140,
                                    );
                                  },
                            ),
                          ),
                        ),
                        _SwipeDeckTopOverlay(
                          remainingCount: profiles.length,
                          onBack: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.goNamed(Routes.swipeHubScreen.name);
                            }
                          },
                          onFilters: () =>
                              context.pushNamed(Routes.filtersScreen.name),
                        ),
                        const _SwipeDeckBottomScrim(),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 10,
                          child: SwipeActionButtons(
                            onPass: () =>
                                _controller.swipe(CardSwiperDirection.left),
                            onLike: () =>
                                _controller.swipe(CardSwiperDirection.right),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SwipeDeckTopOverlay extends StatelessWidget {
  const _SwipeDeckTopOverlay({
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

class _SwipeDeckBottomScrim extends StatelessWidget {
  const _SwipeDeckBottomScrim();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: 156,
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
