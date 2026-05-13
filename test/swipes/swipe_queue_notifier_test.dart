import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/swipes/data/swipe_candidate_repository.dart';
import 'package:catch_dating_app/swipes/data/swipe_repository.dart';
import 'package:catch_dating_app/swipes/domain/swipe.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_queue_notifier.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../auth/auth_test_helpers.dart';
import '../runs/runs_test_helpers.dart';

class FakeSwipeRecordRepository extends Fake implements SwipeRepository {
  Swipe? recordedSwipe;
  final recordedSwipes = <Swipe>[];
  Completer<void>? recordCompleter;

  @override
  Future<void> recordSwipe({required Swipe swipe}) async {
    recordedSwipe = swipe;
    recordedSwipes.add(swipe);
    await recordCompleter?.future;
  }
}

class FakeSwipeCandidateRepository extends Fake
    implements SwipeCandidateRepository {
  @override
  Future<List<PublicProfile>> fetchCandidates({
    required String runId,
    required currentUser,
  }) async => const [];
}

class HangingUserProfileRepository extends Fake
    implements UserProfileRepository {
  @override
  Future<UserProfile?> fetchUserProfile({required String? uid}) =>
      Completer<UserProfile?>().future;
}

void main() {
  group('SwipeQueueNotifier.swipe', () {
    late FakeSwipeRecordRepository swipeRepository;
    late FakeSwipeCandidateRepository candidateRepository;
    late FakeAuthRepository authRepository;

    setUp(() {
      swipeRepository = FakeSwipeRecordRepository();
      candidateRepository = FakeSwipeCandidateRepository();
      authRepository = FakeAuthRepository();
      addTearDown(authRepository.dispose);
    });

    test('does not pop the queue when signed-in uid is unavailable', () async {
      final container = ProviderContainer(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value(null)),
          watchUserProfileProvider.overrideWith((ref) => Stream.value(null)),
          authRepositoryProvider.overrideWithValue(authRepository),
          swipeRepositoryProvider.overrideWith((ref) => swipeRepository),
          swipeCandidateRepositoryProvider.overrideWith(
            (ref) => candidateRepository,
          ),
        ],
      );
      addTearDown(container.dispose);

      final sub = container.listen(
        swipeQueueProvider('run-1'),
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(sub.close);
      await container.pump();

      final notifier = container.read(swipeQueueProvider('run-1').notifier);
      notifier.state = AsyncData([buildPublicProfile(uid: 'runner-2')]);

      await notifier.swipe(SwipeDirection.like);

      expect(swipeRepository.recordedSwipe, isNull);
      expect(
        container.read(swipeQueueProvider('run-1')).value?.map((p) => p.uid),
        ['runner-2'],
      );
    });

    test(
      'records the swipe and removes the top profile when uid is available',
      () async {
        authRepository.currentUserValue = TestUser(uid: 'runner-1');
        final container = ProviderContainer(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            watchUserProfileProvider.overrideWith(
              (ref) => Stream.value(buildUser(uid: 'runner-1')),
            ),
            authRepositoryProvider.overrideWithValue(authRepository),
            swipeRepositoryProvider.overrideWith((ref) => swipeRepository),
            swipeCandidateRepositoryProvider.overrideWith(
              (ref) => candidateRepository,
            ),
          ],
        );
        addTearDown(container.dispose);

        final sub = container.listen(
          swipeQueueProvider('run-9'),
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(sub.close);
        await container.pump();

        final notifier = container.read(swipeQueueProvider('run-9').notifier);
        notifier.state = AsyncData([
          buildPublicProfile(uid: 'runner-2'),
          buildPublicProfile(uid: 'runner-3'),
        ]);

        await notifier.swipe(SwipeDirection.pass);

        expect(swipeRepository.recordedSwipe?.swiperId, 'runner-1');
        expect(swipeRepository.recordedSwipe?.targetId, 'runner-2');
        expect(swipeRepository.recordedSwipe?.runId, 'run-9');
        expect(swipeRepository.recordedSwipe?.direction, SwipeDirection.pass);
        expect(
          container.read(swipeQueueProvider('run-9')).value?.map((p) => p.uid),
          ['runner-3'],
        );
      },
    );

    test(
      'ignores duplicate swipe attempts while a swipe write is pending',
      () async {
        authRepository.currentUserValue = TestUser(uid: 'runner-1');
        swipeRepository.recordCompleter = Completer<void>();
        final container = ProviderContainer(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            watchUserProfileProvider.overrideWith(
              (ref) => Stream.value(buildUser(uid: 'runner-1')),
            ),
            authRepositoryProvider.overrideWithValue(authRepository),
            swipeRepositoryProvider.overrideWith((ref) => swipeRepository),
            swipeCandidateRepositoryProvider.overrideWith(
              (ref) => candidateRepository,
            ),
          ],
        );
        addTearDown(container.dispose);

        final sub = container.listen(
          swipeQueueProvider('run-9'),
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(sub.close);
        await container.pump();

        final notifier = container.read(swipeQueueProvider('run-9').notifier);
        notifier.state = AsyncData([
          buildPublicProfile(uid: 'runner-2'),
          buildPublicProfile(uid: 'runner-3'),
        ]);

        final firstSwipe = notifier.swipe(SwipeDirection.like);
        final secondSwipe = notifier.swipe(SwipeDirection.pass);

        await pumpEventQueue();
        expect(swipeRepository.recordedSwipes, hasLength(1));
        expect(
          swipeRepository.recordedSwipes.single.direction,
          SwipeDirection.like,
        );

        swipeRepository.recordCompleter!.complete();
        await Future.wait([firstSwipe, secondSwipe]);

        expect(
          container.read(swipeQueueProvider('run-9')).value?.map((p) => p.uid),
          ['runner-3'],
        );
      },
    );

    test('surfaces a retryable timeout instead of loading forever', () async {
      final container = ProviderContainer(
        overrides: [
          swipeQueueLoadTimeoutProvider.overrideWithValue(
            const Duration(milliseconds: 1),
          ),
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
          userProfileRepositoryProvider.overrideWithValue(
            HangingUserProfileRepository(),
          ),
          swipeCandidateRepositoryProvider.overrideWith(
            (ref) => candidateRepository,
          ),
        ],
      );
      addTearDown(container.dispose);

      final sub = container.listen(
        swipeQueueProvider('run-1'),
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(sub.close);

      await Future<void>.delayed(const Duration(milliseconds: 5));
      await container.pump();

      final state = container.read(swipeQueueProvider('run-1'));
      expect(state.hasError, isTrue);
      expect(
        state.error,
        isA<BackendOperationException>()
            .having((e) => e.code, 'code', 'swipe-candidates-timeout')
            .having((e) => e.retryable, 'retryable', isTrue),
      );
    });
  });
}
