import 'package:catch_dating_app/app_user/data/app_user_repository.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/presentation/run_detail_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'runs_test_helpers.dart';

void main() {
  group('buildRunDetailViewModel', () {
    test('returns loading while any dependency is still loading', () {
      final result = buildRunDetailViewModel(
        runAsync: const AsyncLoading(),
        appUserAsync: AsyncData(buildUser()),
        reviewsAsync: const AsyncData(<Review>[]),
      );

      expect(result.isLoading, isTrue);
    });

    test('returns data when all dependencies succeed', () {
      final run = buildRun(id: 'run-1');
      final user = buildUser(uid: 'runner-1');
      final review = buildReview(runId: 'run-1', reviewerUserId: 'runner-2');

      final result = buildRunDetailViewModel(
        runAsync: AsyncData(run),
        appUserAsync: AsyncData(user),
        reviewsAsync: AsyncData([review]),
      );

      final value = result.requireValue;
      expect(value, isNotNull);
      expect(value!.run, run);
      expect(value.appUser, user);
      expect(value.reviews, [review]);
    });

    test('returns null data when the run does not exist', () {
      final result = buildRunDetailViewModel(
        runAsync: const AsyncData(null),
        appUserAsync: AsyncData(buildUser()),
        reviewsAsync: const AsyncData(<Review>[]),
      );

      expect(result.value, isNull);
    });

    test('returns loading when the app user stream yields null', () {
      final result = buildRunDetailViewModel(
        runAsync: AsyncData(buildRun()),
        appUserAsync: const AsyncData(null),
        reviewsAsync: const AsyncData(<Review>[]),
      );

      expect(result.isLoading, isTrue);
    });

    test('surfaces run stream errors', () {
      final result = buildRunDetailViewModel(
        runAsync: AsyncError(StateError('run failed'), StackTrace.empty),
        appUserAsync: AsyncData(buildUser()),
        reviewsAsync: const AsyncData(<Review>[]),
      );

      expect(result.hasError, isTrue);
      expect(result.error, isA<StateError>());
    });

    test('surfaces app user stream errors', () {
      final result = buildRunDetailViewModel(
        runAsync: AsyncData(buildRun()),
        appUserAsync: AsyncError(StateError('user failed'), StackTrace.empty),
        reviewsAsync: const AsyncData(<Review>[]),
      );

      expect(result.hasError, isTrue);
      expect(result.error, isA<StateError>());
    });

    test('surfaces review stream errors instead of swallowing them', () {
      final result = buildRunDetailViewModel(
        runAsync: AsyncData(buildRun()),
        appUserAsync: AsyncData(buildUser()),
        reviewsAsync: AsyncError(
          StateError('reviews failed'),
          StackTrace.empty,
        ),
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
            watchRunProvider(run.id).overrideWith((ref) => Stream.value(run)),
            appUserStreamProvider.overrideWith((ref) => Stream.value(user)),
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
        await container.read(appUserStreamProvider.future);
        await container.read(watchReviewsForRunProvider(run.id).future);
        await container.pump();
        await container.pump();

        final value = subscription.read().requireValue;
        expect(value, isNotNull);
        expect(value!.run, run);
        expect(value.appUser, user);
        expect(value.reviews, [review]);
      },
    );
  });
}
