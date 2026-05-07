import 'package:catch_dating_app/runs/domain/run_participation.dart';
import 'package:catch_dating_app/swipes/data/swipe_candidate_repository.dart';
import 'package:catch_dating_app/swipes/data/swipe_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../runs/runs_test_helpers.dart';

class FakeSwipeRepository extends Fake implements SwipeRepository {
  String? lastRequestedUid;
  Set<String> swipedIds = const {};

  @override
  Future<Set<String>> fetchSwipedUserIds({required String uid}) async {
    lastRequestedUid = uid;
    return swipedIds;
  }
}

void main() {
  group('SwipeCandidateRepository', () {
    late FakeRunRepository runRepository;
    late FakeRunParticipationRepository runParticipationRepository;
    late FakeSwipeRepository swipeRepository;
    late FakePublicProfileRepository publicProfileRepository;
    late SwipeCandidateRepository repository;

    setUp(() {
      runRepository = FakeRunRepository();
      runParticipationRepository = FakeRunParticipationRepository();
      swipeRepository = FakeSwipeRepository();
      publicProfileRepository = FakePublicProfileRepository();
      repository = SwipeCandidateRepository(
        runRepository,
        runParticipationRepository,
        swipeRepository,
        publicProfileRepository,
      );
    });

    test('returns empty when the swipe window has closed', () async {
      final endedAt = DateTime.now().subtract(const Duration(hours: 25));
      runRepository.fetchedRun = buildRun(
        id: 'run-closed',
        startTime: endedAt.subtract(const Duration(hours: 1)),
        endTime: endedAt,
      );

      final results = await repository.fetchCandidates(
        runId: 'run-closed',
        currentUser: buildUser(uid: 'runner-1'),
      );

      expect(results, isEmpty);
      expect(runParticipationRepository.lastFetchedRunId, isNull);
      expect(publicProfileRepository.lastRequestedUids, isNull);
    });

    test(
      'returns empty when the current user did not attend the run',
      () async {
        final endedAt = DateTime.now().subtract(const Duration(hours: 3));
        final run = buildRun(
          id: 'run-not-attended',
          startTime: endedAt.subtract(const Duration(hours: 1)),
          endTime: endedAt,
          checkedInCount: 1,
        );
        runRepository.fetchedRun = run;
        runParticipationRepository.runParticipations[run.id] = [
          buildRunParticipation(
            run: run,
            uid: 'runner-2',
            status: RunParticipationStatus.attended,
            createdAt: DateTime(2026, 5, 6, 7, 1),
          ),
          buildRunParticipation(
            run: run,
            uid: 'runner-3',
            status: RunParticipationStatus.attended,
            createdAt: DateTime(2026, 5, 6, 7, 2),
          ),
        ];

        final results = await repository.fetchCandidates(
          runId: 'run-not-attended',
          currentUser: buildUser(uid: 'runner-1'),
        );

        expect(results, isEmpty);
        expect(publicProfileRepository.lastRequestedUids, isNull);
      },
    );

    test(
      'filters swiped and incompatible profiles while preserving attendee order',
      () async {
        final endedAt = DateTime.now().subtract(const Duration(hours: 3));
        final run = buildRun(
          id: 'run-open',
          startTime: endedAt.subtract(const Duration(hours: 1)),
          endTime: endedAt,
        );
        runRepository.fetchedRun = run;
        runParticipationRepository.runParticipations[run.id] = [
          buildRunParticipation(
            run: run,
            uid: 'runner-1',
            status: RunParticipationStatus.attended,
            createdAt: DateTime(2026, 5, 6, 7, 1),
          ),
          buildRunParticipation(
            run: run,
            uid: 'runner-a',
            status: RunParticipationStatus.attended,
            createdAt: DateTime(2026, 5, 6, 7, 2),
          ),
          buildRunParticipation(
            run: run,
            uid: 'runner-b',
            status: RunParticipationStatus.attended,
            createdAt: DateTime(2026, 5, 6, 7, 3),
          ),
          buildRunParticipation(
            run: run,
            uid: 'runner-c',
            status: RunParticipationStatus.attended,
            createdAt: DateTime(2026, 5, 6, 7, 4),
          ),
          buildRunParticipation(
            run: run,
            uid: 'runner-d',
            status: RunParticipationStatus.attended,
            createdAt: DateTime(2026, 5, 6, 7, 5),
          ),
        ];
        swipeRepository.swipedIds = {'runner-b'};
        publicProfileRepository.profiles = [
          buildPublicProfile(
            uid: 'runner-d',
            name: 'Runner D',
            age: 29,
            gender: Gender.woman,
          ),
          buildPublicProfile(
            uid: 'runner-c',
            name: 'Runner C',
            age: 23,
            gender: Gender.woman,
          ),
          buildPublicProfile(
            uid: 'runner-a',
            name: 'Runner A',
            age: 27,
            gender: Gender.woman,
          ),
        ];

        final currentUser = buildUser(uid: 'runner-1').copyWith(
          interestedInGenders: const [Gender.woman],
          minAgePreference: 24,
          maxAgePreference: 32,
        );

        final results = await repository.fetchCandidates(
          runId: 'run-open',
          currentUser: currentUser,
        );

        expect(swipeRepository.lastRequestedUid, 'runner-1');
        expect(publicProfileRepository.lastRequestedUids, [
          'runner-a',
          'runner-c',
          'runner-d',
        ]);
        expect(results.map((profile) => profile.uid).toList(), [
          'runner-a',
          'runner-d',
        ]);
      },
    );
  });
}
