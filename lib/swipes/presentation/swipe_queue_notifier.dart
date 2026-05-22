import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/swipes/data/swipe_candidate_repository.dart';
import 'package:catch_dating_app/swipes/data/swipe_repository.dart';
import 'package:catch_dating_app/swipes/domain/swipe.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'swipe_queue_notifier.g.dart';

const _swipeQueueLoadContext = BackendErrorContext(
  service: BackendService.firestore,
  action: 'load swipe candidates',
  resource: 'swipe_candidates',
);

@visibleForTesting
@Riverpod(keepAlive: true)
Duration swipeQueueLoadTimeout(Ref ref) => const Duration(seconds: 12);

/// **Pattern C: Async state controller**
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
  bool _recordingSwipe = false;

  @override
  Future<List<PublicProfile>> build(
    String eventId, {
    Set<String> vibeIds = const {},
  }) async {
    if (ref.watch(isObviouslyOfflineProvider)) {
      final cachedProfiles = state.value;
      if (cachedProfiles != null) return cachedProfiles;
      throw obviousOfflineException(context: _swipeQueueLoadContext);
    }

    final timeout = ref.watch(swipeQueueLoadTimeoutProvider);
    final currentUserId = await _loadStep(
      ref.watch(uidProvider.future),
      timeout,
    );
    if (currentUserId == null) return [];

    final currentUser = await _loadStep(
      ref
          .read(userProfileRepositoryProvider)
          .fetchUserProfile(uid: currentUserId),
      timeout,
    );
    if (currentUser == null) return [];
    final candidates = await _loadStep(
      ref
          .read(swipeCandidateRepositoryProvider)
          .fetchCandidates(eventId: eventId, currentUser: currentUser),
      timeout,
    );
    if (vibeIds.isEmpty) return candidates;

    final vibeProfiles = <PublicProfile>[];
    final rest = <PublicProfile>[];
    for (final p in candidates) {
      (vibeIds.contains(p.uid) ? vibeProfiles : rest).add(p);
    }
    return [...vibeProfiles, ...rest];
  }

  Future<void> swipe(
    SwipeDirection direction, {
    ProfileReactionTarget? reactionTarget,
    String? comment,
  }) async {
    if (_recordingSwipe) return;

    final profiles = state.value;
    if (profiles == null || profiles.isEmpty) return;

    final currentUserId =
        ref.read(watchUserProfileProvider).asData?.value?.uid ??
        ref.read(uidProvider).asData?.value;
    final target = profiles.first;

    if (currentUserId == null) return;

    final normalizedComment = normalizeSwipeReactionComment(comment);
    final effectiveReactionTarget = direction == SwipeDirection.like
        ? reactionTarget
        : null;

    _recordingSwipe = true;
    try {
      await ref
          .read(swipeRepositoryProvider)
          .recordSwipe(
            swipe: Swipe(
              swiperId: currentUserId,
              targetId: target.uid,
              eventId: eventId,
              direction: direction,
              reactionTargetId: effectiveReactionTarget?.id,
              reactionTargetType: effectiveReactionTarget?.type,
              reactionTargetLabel: effectiveReactionTarget?.label,
              reactionTargetPreview: effectiveReactionTarget?.preview,
              comment: direction == SwipeDirection.like
                  ? normalizedComment
                  : null,
              createdAt: DateTime.now(),
            ),
          );

      final latestProfiles = state.value ?? profiles;
      if (latestProfiles.isEmpty) return;

      if (latestProfiles.first.uid == target.uid) {
        state = AsyncData(latestProfiles.sublist(1));
        return;
      }

      state = AsyncData(
        latestProfiles.where((profile) => profile.uid != target.uid).toList(),
      );
    } finally {
      _recordingSwipe = false;
    }
  }
}

Future<T> _loadStep<T>(Future<T> future, Duration timeout) =>
    future.timeout(timeout, onTimeout: _swipeQueueLoadTimedOut);

Never _swipeQueueLoadTimedOut() {
  throw const BackendOperationException(
    code: 'swipe-candidates-timeout',
    message:
        'Swipe profiles are taking too long to load. Please check your connection and try again.',
    context: _swipeQueueLoadContext,
    retryable: true,
  );
}
