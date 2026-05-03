import 'package:catch_dating_app/core/firestore_error_message.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/routing/go_router.dart';
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
    final currentUserAsync = ref.watch(userProfileStreamProvider);

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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(firestoreErrorMessage(e))),
        data: (profiles) => profiles.isEmpty
            ? SwipeEmptyState(
                content: buildSwipeEmptyContent(
                  run: runAsync.asData?.value,
                  currentUser: currentUserAsync.asData?.value,
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: CardSwiper(
                        controller: _controller,
                        cardsCount: profiles.length,
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
                            ) => GestureDetector(
                              onTap: () => context.pushNamed(
                                Routes.publicProfileScreen.name,
                                pathParameters: {'uid': profiles[index].uid},
                                extra: profiles[index],
                              ),
                              child: ProfileCard(
                                profile: profiles[index],
                                horizontalOffsetPercentage:
                                    horizontalOffsetPercentage,
                              ),
                            ),
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
