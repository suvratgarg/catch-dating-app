import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/presentation/run_map_view_model.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'runs_test_helpers.dart';

void main() {
  group('buildRunMapViewModel', () {
    test(
      'deduplicates runs, keeps signed-up data, and sorts chronologically',
      () {
        final laterRecommended = buildRun(
          id: 'run-2',
          meetingPoint: 'Later',
          startTime: DateTime(2026, 1, 2, 7),
          startingPointLat: 19.1,
          startingPointLng: 72.9,
        );
        final recommendedDuplicate = buildRun(
          id: 'run-1',
          meetingPoint: 'Recommended copy',
          startTime: DateTime(2026, 1, 1, 7),
        );
        final signedUpDuplicate = buildRun(
          id: 'run-1',
          meetingPoint: 'Signed-up copy',
          startTime: DateTime(2026, 1, 1, 7),
          startingPointLat: 19.0,
          startingPointLng: 72.8,
        );

        final viewModel = buildRunMapViewModel(
          signedUpRuns: [signedUpDuplicate],
          recommendedRuns: [laterRecommended, recommendedDuplicate],
        );

        expect(viewModel.runs.map((run) => run.id), ['run-1', 'run-2']);
        expect(viewModel.runs.first.meetingPoint, 'Signed-up copy');
        expect(viewModel.pinnedRuns.map((run) => run.id), ['run-1', 'run-2']);
      },
    );

    test('filters map pins without dropping unpinned sheet rows', () {
      final pinned = buildRun(
        id: 'pinned',
        startTime: DateTime(2026, 1, 1, 7),
        startingPointLat: 19.0,
        startingPointLng: 72.8,
      );
      final unpinned = buildRun(
        id: 'unpinned',
        startTime: DateTime(2026, 1, 2, 7),
      );

      final viewModel = buildRunMapViewModel(
        signedUpRuns: [unpinned],
        recommendedRuns: [pinned],
      );

      expect(viewModel.runs.map((run) => run.id), ['pinned', 'unpinned']);
      expect(viewModel.pinnedRuns.map((run) => run.id), ['pinned']);
      expect(viewModel.selectedRun('unpinned'), unpinned);
    });
  });

  group('runMapViewModelProvider', () {
    test('combines profile, signed-up runs, and recommended runs', () async {
      final repository = FakeRunRepository();
      final user = buildUser(
        uid: 'runner-1',
        joinedRunClubIds: const ['club-1'],
      );
      final signedUpRun = buildRun(
        id: 'signed-up',
        startTime: DateTime(2026, 1, 1, 7),
        startingPointLat: 19.0,
        startingPointLng: 72.8,
      );
      final recommendedRun = buildRun(
        id: 'recommended',
        runClubId: 'club-1',
        startTime: DateTime(2026, 1, 2, 7),
        startingPointLat: 19.1,
        startingPointLng: 72.9,
      );
      repository.signedUpRuns[user.uid] = [signedUpRun];
      repository.recommendedRuns = [recommendedRun];

      final container = ProviderContainer(
        overrides: [
          watchUserProfileProvider.overrideWith((ref) => Stream.value(user)),
          runRepositoryProvider.overrideWith((ref) => repository),
        ],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(
        runMapViewModelProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      await container.read(watchUserProfileProvider.future);
      await container.read(watchSignedUpRunsProvider(user.uid).future);
      await container.read(
        recommendedRunsProvider(user.joinedRunClubIds).future,
      );
      await container.pump();

      final viewModel = subscription.read().requireValue;
      expect(viewModel.runs.map((run) => run.id), ['signed-up', 'recommended']);
      expect(viewModel.pinnedRuns.length, 2);
      expect(repository.recommendedClubIds, ['club-1']);
    });
  });
}
