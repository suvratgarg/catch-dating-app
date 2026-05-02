import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/swipes/data/swipe_candidate_repository.dart';
import 'package:catch_dating_app/swipes/data/swipe_repository.dart';
import 'package:catch_dating_app/swipes/domain/swipe.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'swipe_queue_notifier.g.dart';

@riverpod
class SwipeQueueNotifier extends _$SwipeQueueNotifier {
  @override
  Future<List<PublicProfile>> build(
    String runId, {
    Set<String> vibeIds = const {},
  }) async {
    final currentUser = await ref.watch(userProfileStreamProvider.future);
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
