import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/runs/data/run_participation_repository.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/data/saved_run_repository.dart';
import 'package:catch_dating_app/runs/domain/run_participation.dart';
import 'package:catch_dating_app/runs/domain/saved_run.dart';
import 'package:catch_dating_app/runs/presentation/run_detail_controller.dart';
import 'package:catch_dating_app/runs/presentation/run_detail_view_model.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'runs_test_helpers.dart';

void main() {
  group('buildRunDetailViewModel', () {
    test('returns loading while any dependency is still loading', () {
      final result = buildRunDetailViewModel(
        runAsync: const AsyncLoading(),
        userProfileAsync: AsyncData(buildUser()),
        reviewsAsync: const AsyncData(<Review>[]),
        runClubAsync: AsyncData(buildRunClub()),
        savedRunAsync: const AsyncData(null),
        participationAsync: const AsyncData(null),
        currentUid: 'runner-1',
        isAuthenticated: true,
      );

      expect(result.isLoading, isTrue);
    });

    test('returns data when all dependencies succeed', () {
      final run = buildRun(id: 'run-1');
      final user = buildUser(uid: 'runner-1');
      final review = buildReview(runId: 'run-1', reviewerUserId: 'runner-2');

      final result = buildRunDetailViewModel(
        runAsync: AsyncData(run),
        userProfileAsync: AsyncData(user),
        reviewsAsync: AsyncData([review]),
        runClubAsync: AsyncData(buildRunClub(hostUserId: 'runner-1')),
        savedRunAsync: const AsyncData(null),
        participationAsync: const AsyncData(null),
        currentUid: 'runner-1',
        isAuthenticated: true,
      );

      final value = result.requireValue;
      expect(value, isNotNull);
      expect(value!.run, run);
      expect(value.userProfile, user);
      expect(value.reviews, [review]);
      expect(value.isHost, isTrue);
      expect(value.isSaved, isFalse);
      expect(value.participation, isNull);
    });

    test('returns saved state from the saved run relationship doc', () {
      final result = buildRunDetailViewModel(
        runAsync: AsyncData(buildRun(id: 'run-1')),
        userProfileAsync: AsyncData(buildUser(uid: 'runner-1')),
        reviewsAsync: const AsyncData(<Review>[]),
        runClubAsync: AsyncData(buildRunClub()),
        savedRunAsync: AsyncData(
          SavedRun(
            id: savedRunId(uid: 'runner-1', runId: 'run-1'),
            uid: 'runner-1',
            runId: 'run-1',
            savedAt: DateTime(2026, 1, 1),
          ),
        ),
        currentUid: 'runner-1',
        isAuthenticated: true,
        participationAsync: const AsyncData(null),
      );

      expect(result.requireValue!.isSaved, isTrue);
    });

    test('returns participation state from the run participation edge', () {
      final participation = _participation(
        runId: 'run-1',
        uid: 'runner-1',
        status: RunParticipationStatus.signedUp,
      );

      final result = buildRunDetailViewModel(
        runAsync: AsyncData(buildRun(id: 'run-1')),
        userProfileAsync: AsyncData(buildUser(uid: 'runner-1')),
        reviewsAsync: const AsyncData(<Review>[]),
        runClubAsync: AsyncData(buildRunClub()),
        savedRunAsync: const AsyncData(null),
        participationAsync: AsyncData(participation),
        currentUid: 'runner-1',
        isAuthenticated: true,
      );

      expect(result.requireValue!.participation, participation);
    });

    test('returns null data when the run does not exist', () {
      final result = buildRunDetailViewModel(
        runAsync: const AsyncData(null),
        userProfileAsync: AsyncData(buildUser()),
        reviewsAsync: const AsyncData(<Review>[]),
        runClubAsync: AsyncData(buildRunClub()),
        savedRunAsync: const AsyncData(null),
        participationAsync: const AsyncData(null),
        currentUid: 'runner-1',
        isAuthenticated: true,
      );

      expect(result.value, isNull);
    });

    test('returns data with null userProfile when user is authenticated and '
        'the app user stream yields null', () {
      final result = buildRunDetailViewModel(
        runAsync: AsyncData(buildRun()),
        userProfileAsync: const AsyncData(null),
        reviewsAsync: const AsyncData(<Review>[]),
        runClubAsync: AsyncData(buildRunClub()),
        savedRunAsync: const AsyncData(null),
        participationAsync: const AsyncData(null),
        currentUid: 'runner-1',
        isAuthenticated: true,
      );

      expect(result.requireValue, isNotNull);
      expect(result.requireValue!.userProfile, isNull);
    });

    test('surfaces run stream errors', () {
      final result = buildRunDetailViewModel(
        runAsync: AsyncError(StateError('run failed'), StackTrace.empty),
        userProfileAsync: AsyncData(buildUser()),
        reviewsAsync: const AsyncData(<Review>[]),
        runClubAsync: AsyncData(buildRunClub()),
        savedRunAsync: const AsyncData(null),
        participationAsync: const AsyncData(null),
        currentUid: 'runner-1',
        isAuthenticated: true,
      );

      expect(result.hasError, isTrue);
      expect(result.error, isA<StateError>());
    });

    test('surfaces app user stream errors', () {
      final result = buildRunDetailViewModel(
        runAsync: AsyncData(buildRun()),
        userProfileAsync: AsyncError(
          StateError('user failed'),
          StackTrace.empty,
        ),
        reviewsAsync: const AsyncData(<Review>[]),
        runClubAsync: AsyncData(buildRunClub()),
        savedRunAsync: const AsyncData(null),
        participationAsync: const AsyncData(null),
        currentUid: 'runner-1',
        isAuthenticated: true,
      );

      expect(result.hasError, isTrue);
      expect(result.error, isA<StateError>());
    });

    test('surfaces review stream errors instead of swallowing them', () {
      final result = buildRunDetailViewModel(
        runAsync: AsyncData(buildRun()),
        userProfileAsync: AsyncData(buildUser()),
        reviewsAsync: AsyncError(
          StateError('reviews failed'),
          StackTrace.empty,
        ),
        runClubAsync: AsyncData(buildRunClub()),
        savedRunAsync: const AsyncData(null),
        participationAsync: const AsyncData(null),
        currentUid: 'runner-1',
        isAuthenticated: true,
      );

      expect(result.hasError, isTrue);
      expect(result.error, isA<StateError>());
    });

    test(
      'provider wires together the run, user, and reviews streams',
      () async {
        final run = buildRun(id: 'run-77');
        final user = buildUser(uid: 'runner-77');
        final review = buildReview(runId: 'run-77');
        final container = ProviderContainer(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-77')),
            watchRunProvider(run.id).overrideWith((ref) => Stream.value(run)),
            watchUserProfileProvider.overrideWith((ref) => Stream.value(user)),
            fetchRunClubProvider(run.runClubId).overrideWith(
              (ref) async => buildRunClub(hostUserId: 'runner-77'),
            ),
            watchReviewsForRunProvider(
              run.id,
            ).overrideWith((ref) => Stream.value([review])),
            watchSavedRunProvider(
              user.uid,
              run.id,
            ).overrideWith((ref) => Stream.value(null)),
            watchRunParticipationProvider(
              run.id,
              user.uid,
            ).overrideWith((ref) => Stream.value(null)),
          ],
        );
        addTearDown(container.dispose);
        final subscription = container.listen(
          runDetailViewModelProvider(run.id),
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(subscription.close);

        await container.read(watchRunProvider(run.id).future);
        await container.read(watchUserProfileProvider.future);
        await container.read(watchReviewsForRunProvider(run.id).future);
        await container.read(watchSavedRunProvider(user.uid, run.id).future);
        await container.read(
          watchRunParticipationProvider(run.id, user.uid).future,
        );
        await container.pump();
        await container.pump();

        final value = subscription.read().requireValue;
        expect(value, isNotNull);
        expect(value!.run, run);
        expect(value.userProfile, user);
        expect(value.reviews, [review]);
        expect(value.isHost, isTrue);
        expect(value.isSaved, isFalse);
        expect(value.participation, isNull);
      },
    );
  });

  group('RunDetailController', () {
    test('saves an unsaved run and returns the new saved state', () async {
      final repository = FakeSavedRunRepository();
      final container = ProviderContainer(
        overrides: [savedRunRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final nowSaved = await container
          .read(runDetailControllerProvider.notifier)
          .toggleSavedRun(
            run: buildRun(id: 'run-9'),
            userProfile: buildUser(uid: 'runner-9'),
            isSaved: false,
          );

      expect(nowSaved, isTrue);
      expect(repository.savedUid, 'runner-9');
      expect(repository.savedRunId, 'run-9');
      expect(repository.unsavedRunId, isNull);
    });

    test('unsaves a saved run and returns the new saved state', () async {
      final repository = FakeSavedRunRepository();
      final container = ProviderContainer(
        overrides: [savedRunRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final nowSaved = await container
          .read(runDetailControllerProvider.notifier)
          .toggleSavedRun(
            run: buildRun(id: 'run-10'),
            userProfile: buildUser(uid: 'runner-10'),
            isSaved: true,
          );

      expect(nowSaved, isFalse);
      expect(repository.unsavedUid, 'runner-10');
      expect(repository.unsavedRunId, 'run-10');
      expect(repository.savedRunId, isNull);
    });
  });
}

RunParticipation _participation({
  required String runId,
  required String uid,
  required RunParticipationStatus status,
}) {
  final now = DateTime(2026, 1, 1);
  return RunParticipation(
    id: runParticipationId(runId: runId, uid: uid),
    runId: runId,
    runClubId: 'club-1',
    uid: uid,
    status: status,
    createdAt: now,
    updatedAt: now,
  );
}
