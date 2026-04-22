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
    late FakeSwipeRepository swipeRepository;
    late FakePublicProfileRepository publicProfileRepository;
    late SwipeCandidateRepository repository;

    setUp(() {
      runRepository = FakeRunRepository();
      swipeRepository = FakeSwipeRepository();
      publicProfileRepository = FakePublicProfileRepository();
      repository = SwipeCandidateRepository(
        runRepository,
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
        attendedUserIds: const ['runner-1', 'runner-2'],
      );

      final results = await repository.fetchCandidates(
        runId: 'run-closed',
        currentUser: buildUser(uid: 'runner-1'),
      );

      expect(results, isEmpty);
      expect(publicProfileRepository.lastRequestedUids, isNull);
    });

    test(
      'returns empty when the current user did not attend the run',
      () async {
        final endedAt = DateTime.now().subtract(const Duration(hours: 3));
        runRepository.fetchedRun = buildRun(
          id: 'run-not-attended',
          startTime: endedAt.subtract(const Duration(hours: 1)),
          endTime: endedAt,
          attendedUserIds: const ['runner-2', 'runner-3'],
        );

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
        runRepository.fetchedRun = buildRun(
          id: 'run-open',
          startTime: endedAt.subtract(const Duration(hours: 1)),
          endTime: endedAt,
          attendedUserIds: const [
            'runner-1',
            'runner-a',
            'runner-b',
            'runner-c',
            'runner-d',
          ],
        );
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
