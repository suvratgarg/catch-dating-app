import 'package:catch_dating_app/swipes/domain/swipe.dart';
import 'package:catch_dating_app/swipes/presentation/profile_card.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_queue_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({super.key, required this.runId});

  final String runId;

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
    await ref.read(swipeQueueProvider(widget.runId).notifier).swipe(swipeDir);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final queueAsync = ref.watch(swipeQueueProvider(widget.runId));

    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: queueAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (profiles) => profiles.isEmpty
            ? const _EmptyState()
            : Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: CardSwiper(
                        controller: _controller,
                        cardsCount: profiles.length,
                        onSwipe: _onSwipe,
                        allowedSwipeDirection:
                            const AllowedSwipeDirection.only(
                          left: true,
                          right: true,
                        ),
                        cardBuilder: (
                          context,
                          index,
                          horizontalOffsetPercentage,
                          verticalOffsetPercentage,
                        ) =>
                            ProfileCard(
                          profile: profiles[index],
                          horizontalOffsetPercentage:
                              horizontalOffsetPercentage,
                        ),
                      ),
                    ),
                  ),
                  _ActionButtons(
                    onPass: () =>
                        _controller.swipe(CardSwiperDirection.left),
                    onLike: () =>
                        _controller.swipe(CardSwiperDirection.right),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.onPass, required this.onLike});

  final VoidCallback onPass;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CircleButton(
            icon: Icons.close_rounded,
            color: colorScheme.error,
            onTap: onPass,
          ),
          _CircleButton(
            icon: Icons.favorite_rounded,
            color: Colors.green,
            onTap: onLike,
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      elevation: 4,
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Icon(icon, color: color, size: 32),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_run_rounded,
              size: 72,
              color: colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text('No more runners', style: textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Join more runs to meet new people',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
