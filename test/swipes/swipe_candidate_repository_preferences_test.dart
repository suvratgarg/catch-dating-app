import 'package:catch_dating_app/runs/domain/run_participation.dart';
import 'package:catch_dating_app/swipes/data/swipe_candidate_repository.dart';
import 'package:catch_dating_app/swipes/data/swipe_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../runs/runs_test_helpers.dart';

class FakeSwipeRepository extends Fake implements SwipeRepository {
  @override
  Future<Set<String>> fetchSwipedUserIds({required String uid}) async =>
      const {};
}

void main() {
  test(
    'normalizes invalid stored age preferences before filtering candidates',
    () async {
      final run = buildRun(
        id: 'run-open',
        startTime: DateTime.now().subtract(const Duration(hours: 4)),
        endTime: DateTime.now().subtract(const Duration(hours: 3)),
      );
      final runRepository = FakeRunRepository()..fetchedRun = run;
      final runParticipationRepository = FakeRunParticipationRepository()
        ..runParticipations[run.id] = [
          buildRunParticipation(
            run: run,
            uid: 'runner-1',
            status: RunParticipationStatus.attended,
            createdAt: DateTime(2026, 5, 6, 7, 1),
          ),
          buildRunParticipation(
            run: run,
            uid: 'runner-2',
            status: RunParticipationStatus.attended,
            createdAt: DateTime(2026, 5, 6, 7, 2),
          ),
        ];
      final publicProfileRepository = FakePublicProfileRepository()
        ..profiles = [
          buildPublicProfile(
            uid: 'runner-2',
            name: 'Runner 2',
            age: 30,
            gender: Gender.woman,
          ),
        ];
      final repository = SwipeCandidateRepository(
        runRepository,
        runParticipationRepository,
        FakeSwipeRepository(),
        publicProfileRepository,
      );

      final results = await repository.fetchCandidates(
        runId: 'run-open',
        currentUser: buildUser(uid: 'runner-1').copyWith(
          minAgePreference: 40,
          maxAgePreference: 20,
          interestedInGenders: const [Gender.woman],
        ),
      );

      expect(results.map((profile) => profile.uid).toList(), ['runner-2']);
    },
  );
}
