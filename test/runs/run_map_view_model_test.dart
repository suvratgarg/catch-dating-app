import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/run_clubs/data/run_club_membership_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club_membership.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/data/saved_run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_map_center.dart';
import 'package:catch_dating_app/runs/presentation/run_map_view_model.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'runs_test_helpers.dart';

RunClubMembership _membership({
  required String clubId,
  String uid = 'runner-1',
}) => RunClubMembership(
  id: runClubMembershipId(clubId: clubId, uid: uid),
  clubId: clubId,
  uid: uid,
  role: RunClubMembershipRole.member,
  status: RunClubMembershipStatus.active,
  joinedAt: DateTime(2026, 1, 1),
);

void main() {
  group('buildRunMapViewModel', () {
    final now = DateTime(2026, 1, 1);

    test(
      'deduplicates runs, keeps signed-up data, and sorts chronologically',
      () {
        final laterRecommended = buildRun(
          id: 'run-2',
          meetingPoint: 'Later',
          startTime: DateTime(2026, 1, 3, 7),
          startingPointLat: 19.1,
          startingPointLng: 72.9,
        );
        final recommendedDuplicate = buildRun(
          id: 'run-1',
          meetingPoint: 'Recommended copy',
          startTime: DateTime(2026, 1, 2, 7),
        );
        final signedUpDuplicate = buildRun(
          id: 'run-1',
          meetingPoint: 'Signed-up copy',
          startTime: DateTime(2026, 1, 2, 7),
          startingPointLat: 19.0,
          startingPointLng: 72.8,
        );

        final viewModel = buildRunMapViewModel(
          signedUpRuns: [signedUpDuplicate],
          savedRuns: const [],
          recommendedRuns: [laterRecommended, recommendedDuplicate],
          now: now,
        );

        expect(viewModel.runs.map((run) => run.id), ['run-1', 'run-2']);
        expect(viewModel.runs.first.meetingPoint, 'Signed-up copy');
        expect(viewModel.pinnedRuns.map((run) => run.id), ['run-1', 'run-2']);
      },
    );

    test('filters map pins without dropping unpinned sheet rows', () {
      final pinned = buildRun(
        id: 'pinned',
        startTime: DateTime(2026, 1, 2, 7),
        startingPointLat: 19.0,
        startingPointLng: 72.8,
      );
      final unpinned = buildRun(
        id: 'unpinned',
        startTime: DateTime(2026, 1, 3, 7),
      );

      final viewModel = buildRunMapViewModel(
        signedUpRuns: [unpinned],
        savedRuns: const [],
        recommendedRuns: [pinned],
        now: now,
      );

      expect(viewModel.runs.map((run) => run.id), ['pinned', 'unpinned']);
      expect(viewModel.pinnedRuns.map((run) => run.id), ['pinned']);
      expect(viewModel.selectedRun('unpinned'), unpinned);
    });

    test('filters past and cancelled runs out of the map surface', () {
      final past = buildRun(id: 'past', startTime: DateTime(2025, 12, 31, 7));
      final cancelled = buildRun(
        id: 'cancelled',
        startTime: DateTime(2026, 1, 2, 7),
        status: RunLifecycleStatus.cancelled,
      );
      final upcoming = buildRun(
        id: 'upcoming',
        startTime: DateTime(2026, 1, 2, 8),
        startingPointLat: 19.0,
        startingPointLng: 72.8,
      );

      final viewModel = buildRunMapViewModel(
        signedUpRuns: [past, upcoming],
        savedRuns: const [],
        recommendedRuns: [cancelled],
        now: now,
      );

      expect(viewModel.runs.map((run) => run.id), ['upcoming']);
      expect(viewModel.pinnedRuns.map((run) => run.id), ['upcoming']);
    });
  });

  group('resolveRunMapInitialCenter', () {
    test('prefers device location over selected city and run pins', () {
      final center = resolveRunMapInitialCenter(
        deviceLocation: const LocationCoordinate(22.7, 75.8),
        selectedCity: const CityData(
          name: 'mumbai',
          label: 'Mumbai',
          latitude: 19.076,
          longitude: 72.8777,
        ),
        pinnedRuns: [
          buildRun(startingPointLat: 23.0225, startingPointLng: 72.5714),
        ],
      );

      expect(center.latitude, 22.7);
      expect(center.longitude, 75.8);
    });

    test('falls back to the selected city before run pins', () {
      final center = resolveRunMapInitialCenter(
        selectedCity: const CityData(
          name: 'indore',
          label: 'Indore',
          latitude: 22.7196,
          longitude: 75.8577,
        ),
        pinnedRuns: [
          buildRun(startingPointLat: 23.0225, startingPointLng: 72.5714),
        ],
      );

      expect(center.latitude, 22.7196);
      expect(center.longitude, 75.8577);
    });

    test(
      'uses the first pin only when location and selected city are absent',
      () {
        final center = resolveRunMapInitialCenter(
          pinnedRuns: [
            buildRun(startingPointLat: 23.0225, startingPointLng: 72.5714),
          ],
        );

        expect(center.latitude, 23.0225);
        expect(center.longitude, 72.5714);
      },
    );
  });

  group('runMapViewModelProvider', () {
    test('combines profile, signed-up, saved, and recommended runs', () async {
      final repository = FakeRunRepository();
      final savedRunRepository = FakeSavedRunRepository();
      final user = buildUser(uid: 'runner-1');
      final signedUpRun = buildRun(
        id: 'signed-up',
        startTime: DateTime.now().add(const Duration(days: 1)),
        startingPointLat: 19.0,
        startingPointLng: 72.8,
      );
      final recommendedRun = buildRun(
        id: 'recommended',
        runClubId: 'club-1',
        startTime: DateTime.now().add(const Duration(days: 2)),
        startingPointLat: 19.1,
        startingPointLng: 72.9,
      );
      final savedRun = buildRun(
        id: 'saved',
        startTime: DateTime.now().add(const Duration(hours: 12)),
        startingPointLat: 19.2,
        startingPointLng: 72.7,
      );
      repository.signedUpRuns[user.uid] = [signedUpRun];
      repository.recommendedRuns = [recommendedRun];
      savedRunRepository.savedRunDetails[user.uid] = [savedRun];

      final container = ProviderContainer(
        overrides: [
          watchUserProfileProvider.overrideWith((ref) => Stream.value(user)),
          watchActiveRunClubMembershipsForUserProvider(user.uid).overrideWith(
            (ref) => Stream.value([_membership(clubId: 'club-1')]),
          ),
          runRepositoryProvider.overrideWith((ref) => repository),
          savedRunRepositoryProvider.overrideWithValue(savedRunRepository),
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
      await container.read(
        watchActiveRunClubMembershipsForUserProvider(user.uid).future,
      );
      await container.read(watchSignedUpRunsProvider(user.uid).future);
      await container.read(
        watchSavedRunDetailsForUserProvider(user.uid).future,
      );
      await container.read(
        recommendedRunsProvider(
          RecommendedRunsQuery.fromClubIds(const ['club-1']),
        ).future,
      );
      await container.pump();

      final viewModel = subscription.read().requireValue;
      expect(viewModel.runs.map((run) => run.id), [
        'saved',
        'signed-up',
        'recommended',
      ]);
      expect(viewModel.pinnedRuns.length, 3);
      expect(repository.recommendedClubIds, ['club-1']);
    });
  });
}
