import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
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
        isAuthenticated: true,
      );

      final value = result.requireValue;
      expect(value, isNotNull);
      expect(value!.run, run);
      expect(value.userProfile, user);
      expect(value.reviews, [review]);
    });

    test('returns null data when the run does not exist', () {
      final result = buildRunDetailViewModel(
        runAsync: const AsyncData(null),
        userProfileAsync: AsyncData(buildUser()),
        reviewsAsync: const AsyncData(<Review>[]),
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
            watchReviewsForRunProvider(
              run.id,
            ).overrideWith((ref) => Stream.value([review])),
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
        await container.pump();
        await container.pump();

        final value = subscription.read().requireValue;
        expect(value, isNotNull);
        expect(value!.run, run);
        expect(value.userProfile, user);
        expect(value.reviews, [review]);
      },
    );
  });
}
