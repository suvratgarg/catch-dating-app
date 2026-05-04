import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/swipes/data/swipe_candidate_repository.dart';
import 'package:catch_dating_app/swipes/data/swipe_repository.dart';
import 'package:catch_dating_app/swipes/domain/swipe.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'swipe_queue_notifier.g.dart';

/// **Pattern C: AsyncNotifier with async state**
///
/// Used when state is loaded asynchronously AND needs to be mutated after load:
/// - [build()] returns `Future<T>` — Riverpod manages the AsyncValue lifecycle
///   (loading / data / error) automatically.
/// - Methods like [swipe] mutate the loaded state by removing the first
///   profile from the list. Since state is `AsyncData<List<...>>`, the
///   mutation is synchronous (just `state = AsyncData(newList)`).
/// - The UI watches with `.when(loading:error:data:)` for the initial load
///   and uses the current state for mutations.
///
/// **When to use this pattern:** Data that needs an async fetch to initialize
/// followed by synchronous state mutations (pagination, queue operations,
/// local filtering of fetched data).
@riverpod
class SwipeQueueNotifier extends _$SwipeQueueNotifier {
  @override
  Future<List<PublicProfile>> build(
    String runId, {
    Set<String> vibeIds = const {},
  }) async {
    final currentUser = await ref.watch(watchUserProfileProvider.future);
    if (currentUser == null) return [];
    final candidates = await ref
        .read(swipeCandidateRepositoryProvider)
        .fetchCandidates(runId: runId, currentUser: currentUser);
    if (vibeIds.isEmpty) return candidates;

    final vibeProfiles = <PublicProfile>[];
    final rest = <PublicProfile>[];
    for (final p in candidates) {
      (vibeIds.contains(p.uid) ? vibeProfiles : rest).add(p);
    }
    return [...vibeProfiles, ...rest];
  }

  Future<void> swipe(SwipeDirection direction) async {
    final profiles = state.value;
    if (profiles == null || profiles.isEmpty) return;

    final currentUserId = ref.read(authRepositoryProvider).currentUser?.uid;
    final target = profiles.first;

    if (currentUserId == null) return;

    await ref
        .read(swipeRepositoryProvider)
        .recordSwipe(
          swipe: Swipe(
            swiperId: currentUserId,
            targetId: target.uid,
            runId: runId,
            direction: direction,
            createdAt: DateTime.now(),
          ),
        );

    state = AsyncData(profiles.sublist(1));
  }
}
