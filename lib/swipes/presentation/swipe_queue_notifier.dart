import 'package:catch_dating_app/app_user/data/app_user_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/swipes/data/swipe_candidate_repository.dart';
import 'package:catch_dating_app/swipes/data/swipe_repository.dart';
import 'package:catch_dating_app/swipes/domain/swipe.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'swipe_queue_notifier.g.dart';

@riverpod
class SwipeQueueNotifier extends _$SwipeQueueNotifier {
  @override
  Future<List<PublicProfile>> build(String runId) async {
    final currentUser = await ref.watch(appUserStreamProvider.future);
    if (currentUser == null) return [];
    return ref
        .read(swipeCandidateRepositoryProvider)
        .fetchCandidates(runId: runId, currentUser: currentUser);
  }

  Future<void> swipe(SwipeDirection direction) async {
    final profiles = state.value;
    if (profiles == null || profiles.isEmpty) return;

    final currentUser = ref.read(appUserStreamProvider).value;
    final target = profiles.first;

    if (currentUser != null) {
      await ref.read(swipeRepositoryProvider).recordSwipe(
        swipe: Swipe(
          swiperId: currentUser.uid,
          targetId: target.uid,
          runId: runId,
          direction: direction,
          createdAt: DateTime.now(),
        ),
      );
    }

    state = AsyncData(profiles.sublist(1));
  }
}
