import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/swipes/data/swipe_candidate_repository.dart';
import 'package:catch_dating_app/swipes/data/swipe_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart';

class FakeSwipeRepository extends Fake implements SwipeRepository {
  @override
  Future<Set<String>> fetchSwipedUserIds({required String uid}) async =>
      const {};
}

void main() {
  test(
    'normalizes invalid stored age preferences before filtering candidates',
    () async {
      final event = buildEvent(
        id: 'event-open',
        startTime: DateTime.now().subtract(const Duration(hours: 4)),
        endTime: DateTime.now().subtract(const Duration(hours: 3)),
      );
      final eventRepository = FakeEventRepository()..fetchedEvent = event;
      final eventParticipationRepository = FakeEventParticipationRepository()
        ..eventParticipations[event.id] = [
          buildEventParticipation(
            event: event,
            uid: 'runner-1',
            status: EventParticipationStatus.attended,
            createdAt: DateTime(2026, 5, 6, 7, 1),
          ),
          buildEventParticipation(
            event: event,
            uid: 'runner-2',
            status: EventParticipationStatus.attended,
            createdAt: DateTime(2026, 5, 6, 7, 2),
          ),
        ];
      final publicProfileRepository = FakePublicProfileRepository()
        ..profiles = [
          buildPublicProfile(
            uid: 'runner-2',
            name: 'Runner 2',
            gender: Gender.woman,
          ),
        ];
      final repository = SwipeCandidateRepository(
        eventRepository,
        eventParticipationRepository,
        FakeSwipeRepository(),
        publicProfileRepository,
      );

      final results = await repository.fetchCandidates(
        eventId: 'event-open',
        currentUser: buildUser().copyWith(
          minAgePreference: 40,
          maxAgePreference: 20,
          interestedInGenders: const [Gender.woman],
        ),
      );

      expect(results.map((profile) => profile.uid).toList(), ['runner-2']);
    },
  );
}
