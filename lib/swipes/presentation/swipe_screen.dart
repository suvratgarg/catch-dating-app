import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
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
      appBar: CatchTopBar(
        title: 'Discover',
        actions: [
          CatchTopBarIconAction(
            tooltip: 'Filters',
            icon: Icons.tune_rounded,
            onPressed: () => context.pushNamed(Routes.filtersScreen.name),
          ),
        ],
      ),
      body: queueAsync.when(
        loading: () => const CatchLoadingIndicator(),
        error: (e, _) => CatchErrorState.fromError(
          e,
          context: AppErrorContext.profile,
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
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        MediaQuery.of(context).size.width > 600 ? 48 : 16,
                        16,
                        MediaQuery.of(context).size.width > 600 ? 48 : 16,
                        8,
                      ),
                      child: CardSwiper(
                        key: ValueKey(
                          profiles.map((profile) => profile.uid).join('|'),
                        ),
                        controller: _controller,
                        cardsCount: profiles.length,
                        numberOfCardsDisplayed: profiles.length.clamp(1, 3),
                        onSwipe: _onSwipe,
                        allowedSwipeDirection: const AllowedSwipeDirection.only(
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
                              return Semantics(
                                button: true,
                                label: 'Open ${profile.name} profile',
                                child: GestureDetector(
                                  onTap: () => context.pushNamed(
                                    Routes.publicProfileScreen.name,
                                    pathParameters: {'uid': profile.uid},
                                    extra: profile,
                                  ),
                                  child: ProfileCard(
                                    profile: profile,
                                    horizontalOffsetPercentage:
                                        horizontalOffsetPercentage,
                                  ),
                                ),
                              );
                            },
                      ),
                    ),
                  ),
                  SwipeActionButtons(
                    onPass: () => _controller.swipe(CardSwiperDirection.left),
                    onLike: () => _controller.swipe(CardSwiperDirection.right),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
      ),
    );
  }
}
