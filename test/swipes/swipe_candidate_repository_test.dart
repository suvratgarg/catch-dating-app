import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/swipes/data/swipe_candidate_repository.dart';
import 'package:catch_dating_app/swipes/data/swipe_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart';

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
    late FakeEventRepository eventRepository;
    late FakeEventParticipationRepository eventParticipationRepository;
    late FakeSwipeRepository swipeRepository;
    late FakePublicProfileRepository publicProfileRepository;
    late SwipeCandidateRepository repository;

    setUp(() {
      eventRepository = FakeEventRepository();
      eventParticipationRepository = FakeEventParticipationRepository();
      swipeRepository = FakeSwipeRepository();
      publicProfileRepository = FakePublicProfileRepository();
      repository = SwipeCandidateRepository(
        eventRepository,
        eventParticipationRepository,
        swipeRepository,
        publicProfileRepository,
      );
    });

    test('returns empty when the swipe window has closed', () async {
      final endedAt = DateTime.now().subtract(const Duration(hours: 25));
      eventRepository.fetchedEvent = buildEvent(
        id: 'event-closed',
        startTime: endedAt.subtract(const Duration(hours: 1)),
        endTime: endedAt,
      );

      final results = await repository.fetchCandidates(
        eventId: 'event-closed',
        currentUser: buildUser(),
      );

      expect(results, isEmpty);
      expect(eventParticipationRepository.lastFetchedEventId, isNull);
      expect(publicProfileRepository.lastRequestedUids, isNull);
    });

    test(
      'returns empty when the current user did not attend the event',
      () async {
        final endedAt = DateTime.now().subtract(const Duration(hours: 3));
        final event = buildEvent(
          id: 'event-not-attended',
          startTime: endedAt.subtract(const Duration(hours: 1)),
          endTime: endedAt,
          checkedInCount: 1,
        );
        eventRepository.fetchedEvent = event;
        eventParticipationRepository.eventParticipations[event.id] = [
          buildEventParticipation(
            event: event,
            uid: 'runner-2',
            status: EventParticipationStatus.attended,
            createdAt: DateTime(2026, 5, 6, 7, 1),
          ),
          buildEventParticipation(
            event: event,
            uid: 'runner-3',
            status: EventParticipationStatus.attended,
            createdAt: DateTime(2026, 5, 6, 7, 2),
          ),
        ];

        final results = await repository.fetchCandidates(
          eventId: 'event-not-attended',
          currentUser: buildUser(),
        );

        expect(results, isEmpty);
        expect(publicProfileRepository.lastRequestedUids, isNull);
      },
    );

    test(
      'filters swiped and incompatible profiles while preserving attendee order',
      () async {
        final endedAt = DateTime.now().subtract(const Duration(hours: 3));
        final event = buildEvent(
          id: 'event-open',
          startTime: endedAt.subtract(const Duration(hours: 1)),
          endTime: endedAt,
        );
        eventRepository.fetchedEvent = event;
        eventParticipationRepository.eventParticipations[event.id] = [
          buildEventParticipation(
            event: event,
            uid: 'runner-1',
            status: EventParticipationStatus.attended,
            createdAt: DateTime(2026, 5, 6, 7, 1),
          ),
          buildEventParticipation(
            event: event,
            uid: 'runner-a',
            status: EventParticipationStatus.attended,
            createdAt: DateTime(2026, 5, 6, 7, 2),
          ),
          buildEventParticipation(
            event: event,
            uid: 'runner-b',
            status: EventParticipationStatus.attended,
            createdAt: DateTime(2026, 5, 6, 7, 3),
          ),
          buildEventParticipation(
            event: event,
            uid: 'runner-c',
            status: EventParticipationStatus.attended,
            createdAt: DateTime(2026, 5, 6, 7, 4),
          ),
          buildEventParticipation(
            event: event,
            uid: 'runner-d',
            status: EventParticipationStatus.attended,
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

        final currentUser = buildUser().copyWith(
          interestedInGenders: const [Gender.woman],
          minAgePreference: 24,
          maxAgePreference: 32,
        );

        final results = await repository.fetchCandidates(
          eventId: 'event-open',
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
