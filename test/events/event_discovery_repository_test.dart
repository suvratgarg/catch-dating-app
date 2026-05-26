import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/events/data/event_discovery_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'events_test_helpers.dart';

void main() {
  group('EventDiscoveryQuery', () {
    test('normalizes city and sorts activity filters for stable families', () {
      final now = DateTime(2026, 5, 26, 10);
      final left = EventDiscoveryQuery.forCity(
        cityName: ' Mumbai ',
        startAt: now,
        activityKinds: const [ActivityKind.yoga, ActivityKind.running],
      );
      final right = EventDiscoveryQuery.forCity(
        cityName: 'mumbai',
        startAt: now,
        activityKinds: const [ActivityKind.running, ActivityKind.yoga],
      );

      expect(left, right);
      expect(left.hashCode, right.hashCode);
      expect(left.cityName, 'mumbai');
      expect(left.activityKinds, [ActivityKind.running, ActivityKind.yoga]);
    });
  });

  group('EventDiscoveryRepository', () {
    test(
      'queries indexed discovery fields before exact distance post-filtering',
      () async {
        final firestore = FakeFirebaseFirestore();
        final repository = EventDiscoveryRepository(firestore);
        final now = DateTime(2026, 5, 26, 10);
        final matchingEvent = buildEvent(
          id: 'event-matching',
          clubId: 'club-a',
          startTime: now.add(const Duration(days: 1)),
          startingPointLat: 19.001,
          startingPointLng: 72.001,
          eventFormat: EventFormatSnapshot.fromActivityKind(ActivityKind.yoga),
        );
        final farEvent = buildEvent(
          id: 'event-far',
          clubId: 'club-a',
          startTime: now.add(const Duration(days: 1)),
          startingPointLat: 19.2,
          startingPointLng: 72.2,
          eventFormat: EventFormatSnapshot.fromActivityKind(ActivityKind.yoga),
        );
        final otherCityEvent = buildEvent(
          id: 'event-other-city',
          clubId: 'club-b',
          startTime: now.add(const Duration(days: 1)),
          startingPointLat: 19.001,
          startingPointLng: 72.001,
          eventFormat: EventFormatSnapshot.fromActivityKind(ActivityKind.yoga),
        );
        final wrongActivityEvent = buildEvent(
          id: 'event-wrong-activity',
          clubId: 'club-a',
          startTime: now.add(const Duration(days: 1)),
          startingPointLat: 19.001,
          startingPointLng: 72.001,
          eventFormat: EventFormatSnapshot.fromActivityKind(
            ActivityKind.dinner,
          ),
        );
        final fullEvent = buildEvent(
          id: 'event-full',
          clubId: 'club-a',
          startTime: now.add(const Duration(days: 1)),
          startingPointLat: 19.001,
          startingPointLng: 72.001,
          eventFormat: EventFormatSnapshot.fromActivityKind(ActivityKind.yoga),
          bookedCount: 20,
          capacityLimit: 20,
        );
        await _seedDiscoverableEvent(firestore, matchingEvent);
        await _seedDiscoverableEvent(firestore, farEvent);
        await _seedDiscoverableEvent(
          firestore,
          otherCityEvent,
          cityName: 'delhi',
        );
        await _seedDiscoverableEvent(firestore, wrongActivityEvent);
        await _seedDiscoverableEvent(
          firestore,
          fullEvent,
          availability: 'full',
          hasOpenSpots: false,
        );

        final events = await repository.fetchDiscoverableEvents(
          EventDiscoveryQuery.forCity(
            cityName: 'mumbai',
            startAt: now,
            endBefore: now.add(const Duration(days: 7)),
            activityKinds: const [ActivityKind.yoga],
            center: const LocationCoordinate(19, 72),
            maxDistanceKm: 3,
            availabilityFilter: EventDiscoveryAvailabilityFilter.open,
          ),
        );

        expect(events.map((event) => event.id), ['event-matching']);
      },
    );

    test('provider builds a repository from Firebase providers', () async {
      final firestore = FakeFirebaseFirestore();
      final event = buildEvent(
        id: 'event-provider',
        clubId: 'club-provider',
        startTime: DateTime(2026, 5, 27, 10),
        startingPointLat: 19.001,
        startingPointLng: 72.001,
      );
      await _seedDiscoverableEvent(firestore, event);
      final container = ProviderContainer(
        overrides: [firebaseFirestoreProvider.overrideWithValue(firestore)],
      );
      addTearDown(container.dispose);

      final results = await container.read(
        discoverableEventsProvider(
          EventDiscoveryQuery.forCity(
            cityName: 'mumbai',
            startAt: DateTime(2026, 5, 26),
            endBefore: DateTime(2026, 6),
          ),
        ).future,
      );

      expect(results.map((event) => event.id), ['event-provider']);
    });

    test('uses viewer cohort indexes for open-slot discovery', () async {
      final firestore = FakeFirebaseFirestore();
      final repository = EventDiscoveryRepository(firestore);
      final now = DateTime(2026, 5, 26, 10);
      final matchingEvent = buildEvent(
        id: 'event-open-for-men',
        clubId: 'club-a',
        startTime: now.add(const Duration(days: 1)),
      );
      final blockedEvent = buildEvent(
        id: 'event-open-for-women',
        clubId: 'club-a',
        startTime: now.add(const Duration(days: 1)),
      );
      await _seedDiscoverableEvent(
        firestore,
        matchingEvent,
        openCohorts: const ['menInterestedInWomen'],
      );
      await _seedDiscoverableEvent(
        firestore,
        blockedEvent,
        openCohorts: const ['womenInterestedInMen'],
      );

      final events = await repository.fetchDiscoverableEvents(
        EventDiscoveryQuery.forCity(
          cityName: 'mumbai',
          startAt: now,
          availabilityFilter: EventDiscoveryAvailabilityFilter.open,
          viewerCohortId: 'menInterestedInWomen',
        ),
      );

      expect(events.map((event) => event.id), ['event-open-for-men']);
    });

    test('does not narrow general discovery by viewer cohort', () async {
      final firestore = FakeFirebaseFirestore();
      final repository = EventDiscoveryRepository(firestore);
      final now = DateTime(2026, 5, 26, 10);
      final event = buildEvent(
        id: 'event-visible-in-general-feed',
        clubId: 'club-a',
        startTime: now.add(const Duration(days: 1)),
      );
      await _seedDiscoverableEvent(
        firestore,
        event,
        openCohorts: const ['womenInterestedInMen'],
      );

      final events = await repository.fetchDiscoverableEvents(
        EventDiscoveryQuery.forCity(
          cityName: 'mumbai',
          startAt: now,
          viewerCohortId: 'menInterestedInWomen',
        ),
      );

      expect(events.map((event) => event.id), [
        'event-visible-in-general-feed',
      ]);
    });
  });
}

Future<void> _seedDiscoverableEvent(
  FakeFirebaseFirestore firestore,
  Event event, {
  String cityName = 'mumbai',
  String availability = 'open',
  bool hasOpenSpots = true,
  List<String> openCohorts = const [
    'menInterestedInWomen',
    'womenInterestedInMen',
    'queerOrOpen',
    'nonBinaryOrOther',
  ],
  List<String> waitlistCohorts = const [],
}) {
  final latitude = event.effectiveStartingPointLat;
  final longitude = event.effectiveStartingPointLng;
  return firestore.collection('events').doc(event.id).set({
    ...event.toJson(),
    'discoveryCityName': cityName,
    'discoveryActivityKind': event.activityKind.name,
    'discoveryGeoCell': latitude == null || longitude == null
        ? null
        : eventDiscoveryGeoCellFor(latitude: latitude, longitude: longitude),
    'discoveryHasOpenSpots': hasOpenSpots,
    'discoveryAvailability': availability,
    'discoveryOpenCohorts': openCohorts,
    'discoveryWaitlistCohorts': waitlistCohorts,
    'discoveryInviteRequired': false,
    'discoveryMembershipRequired': false,
    'discoveryManualApprovalRequired': false,
    'discoveryMinAge': event.constraints.minAge,
    'discoveryMaxAge': event.constraints.maxAge,
  });
}
