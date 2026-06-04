import 'dart:async';

import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_constraints.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'events_test_helpers.dart';

class TestFirebaseFunctions extends Fake implements FirebaseFunctions {
  final callables = <String, TestHttpsCallable>{};

  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) {
    return callables.putIfAbsent(name, () => TestHttpsCallable(name));
  }
}

class TestHttpsCallable extends Fake implements HttpsCallable {
  TestHttpsCallable(this.name);

  final String name;
  final calls = <Object?>[];
  Object? resultData;

  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async {
    calls.add(parameters);
    return TestHttpsCallableResult<T>(resultData as T);
  }
}

class TestHttpsCallableResult<T> extends Fake
    implements HttpsCallableResult<T> {
  TestHttpsCallableResult(this.dataValue);

  final T dataValue;

  @override
  T get data => dataValue;
}

void main() {
  group('EventRepository', () {
    late FakeFirebaseFirestore firestore;
    late TestFirebaseFunctions functions;
    late EventRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      functions = TestFirebaseFunctions();
      repository = EventRepository(firestore, functions);
    });

    test('generateId uses an auto-generated document reference', () async {
      final generatedId = repository.generateId();

      expect(generatedId, isNotEmpty);
      final generatedDoc = await firestore
          .collection('events')
          .doc(generatedId)
          .get();
      expect(generatedDoc.exists, isFalse);
    });

    test(
      'converter round-trips Firestore data and injects the document id',
      () async {
        final rawEvent = buildEvent(
          id: 'event-88',
          constraints: const EventConstraints(minAge: 21, maxWomen: 6),
        );

        await _seedEvent(firestore, rawEvent);

        final decoded = await repository.fetchEvent(rawEvent.id);
        final encoded =
            (await firestore.collection('events').doc(rawEvent.id).get())
                .data()!;

        expect(decoded?.id, 'event-88');
        expect(decoded?.meetingPoint, 'Carter Road');
        expect(encoded.containsKey('id'), isFalse);
        expect(encoded['clubId'], 'club-1');
        expect(encoded['constraints'], {
          'minAge': 21,
          'maxAge': 99,
          'maxMen': null,
          'maxWomen': 6,
        });
        expect(decoded?.constraints, rawEvent.constraints);
      },
    );

    test('fetchEvent returns the decoded event when found', () async {
      final event = buildEvent();
      await _seedEvent(firestore, event);

      expect(await repository.fetchEvent('event-1'), event);
    });

    test('fetchEvent returns null when the document is missing', () async {
      expect(await repository.fetchEvent('event-missing'), isNull);
    });

    test(
      'watchEvent emits the decoded event when the document exists',
      () async {
        final event = buildEvent();
        await _seedEvent(firestore, event);

        await expectLater(repository.watchEvent('event-1'), emits(event));
      },
    );

    test('watchEvent emits null when the document is missing', () async {
      await expectLater(repository.watchEvent('event-missing'), emits(null));
    });

    test(
      'watchEventsForClub filters by club id and orders by start time',
      () async {
        final later = buildEvent(
          id: 'later',
          clubId: 'club-2',
          startTime: DateTime.now().add(const Duration(hours: 5)),
        );
        final earlier = buildEvent(
          id: 'earlier',
          clubId: 'club-2',
          startTime: DateTime.now().add(const Duration(hours: 2)),
        );
        await _seedEvent(firestore, later);
        await _seedEvent(firestore, earlier);
        await _seedEvent(
          firestore,
          buildEvent(id: 'other-club', clubId: 'club-3'),
        );

        await expectLater(
          repository.watchEventsForClub(clubId: 'club-2'),
          emits([earlier, later]),
        );
      },
    );

    test(
      'watchAttendedEvents filters by attendee id and sorts descending',
      () async {
        final older = buildEvent(
          id: 'older',
          startTime: DateTime.now().subtract(const Duration(days: 2)),
        );
        final newer = buildEvent(
          id: 'newer',
          startTime: DateTime.now().subtract(const Duration(days: 1)),
        );
        await _seedEvent(firestore, older);
        await _seedEvent(firestore, newer);
        await _seedEvent(firestore, buildEvent(id: 'not-attended'));
        await _seedParticipation(
          firestore,
          event: older,
          uid: 'runner-1',
          status: EventParticipationStatus.attended,
        );
        await _seedParticipation(
          firestore,
          event: newer,
          uid: 'runner-1',
          status: EventParticipationStatus.attended,
        );
        await _seedParticipation(
          firestore,
          event: buildEvent(id: 'not-attended'),
          uid: 'runner-1',
          status: EventParticipationStatus.signedUp,
        );

        await expectLater(
          repository.watchAttendedEvents(uid: 'runner-1'),
          emits([newer, older]),
        );
      },
    );

    test(
      'watchSignedUpEvents filters by signup id and sorts ascending',
      () async {
        final later = buildEvent(
          id: 'later',
          startTime: DateTime.now().add(const Duration(hours: 5)),
        );
        final earlier = buildEvent(
          id: 'earlier',
          startTime: DateTime.now().add(const Duration(hours: 2)),
        );
        await _seedEvent(firestore, later);
        await _seedEvent(firestore, earlier);
        await _seedEvent(firestore, buildEvent(id: 'not-signed-up'));
        await _seedParticipation(
          firestore,
          event: later,
          uid: 'runner-1',
          status: EventParticipationStatus.signedUp,
        );
        await _seedParticipation(
          firestore,
          event: earlier,
          uid: 'runner-1',
          status: EventParticipationStatus.signedUp,
        );
        await _seedParticipation(
          firestore,
          event: buildEvent(id: 'not-signed-up'),
          uid: 'runner-1',
          status: EventParticipationStatus.waitlisted,
        );

        await expectLater(
          repository.watchSignedUpEvents(uid: 'runner-1'),
          emits([earlier, later]),
        );
      },
    );

    test('watchEventsByIds chunks ids, skips missing, and sorts', () async {
      final late = buildEvent(
        id: 'event-12',
        startTime: DateTime.now().add(const Duration(hours: 12)),
      );
      final early = buildEvent(
        startTime: DateTime.now().add(const Duration(hours: 1)),
      );
      await _seedEvent(firestore, late);
      await _seedEvent(firestore, early);
      await _seedEvent(firestore, buildEvent(id: 'not-requested'));

      await expectLater(
        repository.watchEventsByIds(
          eventIds: [for (var i = 1; i <= 12; i += 1) 'event-$i'],
        ),
        emits([early, late]),
      );
    });

    test(
      'fetchUpcomingEventsForClubs returns empty without querying for no clubs',
      () async {
        await _seedEvent(firestore, buildEvent());

        expect(await repository.fetchUpcomingEventsForClubs(const []), isEmpty);
      },
    );

    test(
      'fetchUpcomingEventsForClubs filters upcoming events and limits results',
      () async {
        final event = buildEvent(clubId: 'club-3');
        await _seedEvent(firestore, event);
        await _seedEvent(
          firestore,
          buildEvent(
            id: 'past',
            clubId: 'club-3',
            startTime: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        );
        await _seedEvent(
          firestore,
          buildEvent(id: 'other-club', clubId: 'club-11'),
        );

        final results = await repository.fetchUpcomingEventsForClubs(const [
          'club-1',
          'club-2',
          'club-3',
        ]);

        expect(results, [event]);
      },
    );

    test(
      'fetchUpcomingEventsForClubs queries beyond the whereIn club cap',
      () async {
        final early = buildEvent(
          id: 'early',
          startTime: DateTime.now().add(const Duration(hours: 2)),
        );
        final late = buildEvent(
          id: 'late',
          clubId: 'club-12',
          startTime: DateTime.now().add(const Duration(hours: 4)),
        );
        await _seedEvent(firestore, early);
        await _seedEvent(firestore, late);

        final results = await repository.fetchUpcomingEventsForClubs([
          for (var i = 1; i <= 12; i += 1) 'club-$i',
        ]);

        expect(results, [early, late]);
      },
    );

    test(
      'createEvent calls the server-owned createEvent Cloud Function',
      () async {
        final event = buildEvent(
          id: 'event-42',
          startingPointLat: 19.076,
          startingPointLng: 72.8777,
          photoUrl: 'https://img.example/events/event-42.jpg',
          constraints: const EventConstraints(minAge: 21, maxAge: 35),
        );
        final meetingLocation = event.effectiveMeetingLocation!;

        await repository.createEvent(event: event);

        expect(functions.callables['createEvent']!.calls, [
          {
            'eventId': 'event-42',
            'clubId': event.clubId,
            'startTimeMillis': event.startTime.millisecondsSinceEpoch,
            'endTimeMillis': event.endTime.millisecondsSinceEpoch,
            'meetingPoint': event.meetingPoint,
            'meetingLocation': meetingLocation.toJson(),
            'startingPointLat': event.startingPointLat,
            'startingPointLng': event.startingPointLng,
            'photoUrl': event.photoUrl,
            'eventFormat': event.eventFormat.toJson(),
            'distanceKm': event.distanceKm,
            'pace': event.pace.name,
            'description': event.description,
            'capacityLimit': event.capacityLimit,
            'priceInPaise': event.priceInPaise,
            'currency': event.currency,
            'constraints': {
              'minAge': 21,
              'maxAge': 35,
              'maxMen': null,
              'maxWomen': null,
            },
          },
        ]);
      },
    );

    test(
      'updateEventDetails calls the server-owned updateEvent Cloud Function',
      () async {
        final event = buildEvent(
          id: 'event-42',
          startingPointLat: 19.076,
          startingPointLng: 72.8777,
          photoUrl: 'https://img.example/events/event-42.jpg',
        );
        final meetingLocation = event.effectiveMeetingLocation!;

        await repository.updateEventDetails(event: event);

        expect(functions.callables['updateEvent']!.calls, [
          {
            'eventId': 'event-42',
            'fields': {
              'startTimeMillis': event.startTime.millisecondsSinceEpoch,
              'endTimeMillis': event.endTime.millisecondsSinceEpoch,
              'meetingPoint': event.meetingPoint,
              'meetingLocation': meetingLocation.toJson(),
              'startingPointLat': event.startingPointLat,
              'startingPointLng': event.startingPointLng,
              'locationDetails': event.locationDetails,
              'photoUrl': event.photoUrl,
              'distanceKm': event.distanceKm,
              'pace': event.pace.name,
              'description': event.description,
            },
          },
        ]);
      },
    );

    test(
      'cancelEvent calls the server-owned cancelEvent Cloud Function',
      () async {
        await repository.cancelEvent(
          eventId: 'event-42',
          reason: 'Weather warning',
        );

        expect(functions.callables['cancelEvent']!.calls, [
          {'eventId': 'event-42', 'reason': 'Weather warning'},
        ]);
      },
    );

    test('cancelEvent omits a missing reason', () async {
      await repository.cancelEvent(eventId: 'event-42');

      expect(functions.callables['cancelEvent']!.calls, [
        {'eventId': 'event-42'},
      ]);
    });

    test(
      'deleteEvent calls the server-owned deleteEvent Cloud Function',
      () async {
        await repository.deleteEvent(eventId: 'event-42');

        expect(functions.callables['deleteEvent']!.calls, [
          {'eventId': 'event-42'},
        ]);
      },
    );

    test('joinWaitlistViaFunction calls the matching Cloud Function', () async {
      await repository.joinWaitlistViaFunction(
        eventId: 'event-1',
        inviteCode: 'CATCH-DELHI',
        inviteLinkId: 'invite-link-1',
      );

      expect(functions.callables['joinEventWaitlist']!.calls, [
        {
          'eventId': 'event-1',
          'inviteCode': 'CATCH-DELHI',
          'inviteLinkId': 'invite-link-1',
        },
      ]);
    });

    test('createInviteLink calls the matching Cloud Function', () async {
      (functions.httpsCallable('createEventInviteLink') as TestHttpsCallable)
          .resultData = {
        'inviteLinkId': 'invite-link-1',
        'eventId': 'event-1',
        'label': 'Instagram bio',
        'source': 'instagram',
      };

      final result = await repository.createInviteLink(
        eventId: 'event-1',
        label: 'Instagram bio',
        source: 'instagram',
      );

      expect(functions.callables['createEventInviteLink']!.calls, [
        {'eventId': 'event-1', 'label': 'Instagram bio', 'source': 'instagram'},
      ]);
      expect(result.inviteLinkId, 'invite-link-1');
      expect(result.label, 'Instagram bio');
    });

    test('recordInviteLinkOpen calls the matching Cloud Function', () async {
      (functions.httpsCallable('recordEventInviteLinkOpen')
              as TestHttpsCallable)
          .resultData = {
        'accepted': true,
        'disabled': false,
        'eventId': 'event-1',
        'inviteLinkId': 'invite-link-1',
        'label': 'Instagram bio',
        'source': 'instagram',
      };

      final result = await repository.recordInviteLinkOpen(
        eventId: 'event-1',
        inviteLinkId: 'invite-link-1',
      );

      expect(functions.callables['recordEventInviteLinkOpen']!.calls, [
        {'eventId': 'event-1', 'inviteLinkId': 'invite-link-1'},
      ]);
      expect(result.accepted, isTrue);
      expect(result.source, 'instagram');
    });

    test('disableInviteLink calls the matching Cloud Function', () async {
      await repository.disableInviteLink(
        eventId: 'event-1',
        inviteLinkId: 'invite-link-1',
      );

      expect(functions.callables['disableEventInviteLink']!.calls, [
        {'eventId': 'event-1', 'inviteLinkId': 'invite-link-1'},
      ]);
    });

    test('leaveWaitlist calls the matching Cloud Function', () async {
      await repository.leaveWaitlist(eventId: 'event-1');

      expect(functions.callables['leaveEventWaitlist']!.calls, [
        {'eventId': 'event-1'},
      ]);
    });

    test('createWaitlistOffers calls the matching Cloud Function', () async {
      (functions.httpsCallable('createEventWaitlistOffers')
              as TestHttpsCallable)
          .resultData = {
        'createdCount': 2,
        'skippedCount': 1,
        'offers': [
          {
            'uid': 'runner-1',
            'status': 'created',
            'expiresAtMillis': 1767220200000,
          },
          {'uid': 'runner-3', 'status': 'skipped', 'reason': 'capacity_full'},
        ],
      };

      final result = await repository.createWaitlistOffers(
        eventId: 'event-1',
        userIds: ['runner-1', 'runner-2', 'runner-3'],
        expiresInMinutes: 45,
      );

      expect(functions.callables['createEventWaitlistOffers']!.calls, [
        {
          'eventId': 'event-1',
          'userIds': ['runner-1', 'runner-2', 'runner-3'],
          'expiresInMinutes': 45,
        },
      ]);
      expect(result.createdCount, 2);
      expect(result.skippedCount, 1);
      expect(result.offers.first.uid, 'runner-1');
      expect(result.offers.first.status, 'created');
      expect(result.offers.first.expiresAtMillis, 1767220200000);
      expect(result.offers.last.reason, 'capacity_full');
    });

    test('acceptWaitlistOffer calls the matching Cloud Function', () async {
      (functions.httpsCallable('acceptEventWaitlistOffer') as TestHttpsCallable)
          .resultData = {
        'accepted': true,
        'requiresPayment': true,
        'booked': false,
      };

      final result = await repository.acceptWaitlistOffer(eventId: 'event-1');

      expect(functions.callables['acceptEventWaitlistOffer']!.calls, [
        {'eventId': 'event-1'},
      ]);
      expect(result.accepted, isTrue);
      expect(result.requiresPayment, isTrue);
      expect(result.booked, isFalse);
    });

    test('declineWaitlistOffer calls the matching Cloud Function', () async {
      await repository.declineWaitlistOffer(eventId: 'event-1');

      expect(functions.callables['declineEventWaitlistOffer']!.calls, [
        {'eventId': 'event-1'},
      ]);
    });

    test('decideJoinRequest calls the matching Cloud Function', () async {
      await repository.decideJoinRequest(
        eventId: 'event-9',
        userId: 'runner-2',
        decision: 'approve',
      );

      expect(functions.callables['decideEventJoinRequest']!.calls, [
        {'eventId': 'event-9', 'userId': 'runner-2', 'decision': 'approve'},
      ]);
    });

    test('cancelSignUpViaFunction calls the matching Cloud Function', () async {
      await repository.cancelSignUpViaFunction(eventId: 'event-9');

      expect(functions.callables['cancelEventSignUp']!.calls, [
        {'eventId': 'event-9'},
      ]);
    });

    test('markAttendance calls the matching Cloud Function', () async {
      (functions.httpsCallable('markEventAttendance') as TestHttpsCallable)
          .resultData = {
        'attended': true,
      };
      final result = await repository.markAttendance(
        eventId: 'event-9',
        userId: 'user-1',
      );

      expect(result, true);
      expect(functions.callables['markEventAttendance']!.calls, [
        {'eventId': 'event-9', 'userId': 'user-1'},
      ]);
    });

    test('selfCheckInAttendance calls the matching Cloud Function', () async {
      await repository.selfCheckInAttendance(
        eventId: 'event-9',
        latitude: 19.076,
        longitude: 72.8777,
      );

      expect(functions.callables['selfCheckInAttendance']!.calls, [
        {'eventId': 'event-9', 'latitude': 19.076, 'longitude': 72.8777},
      ]);
    });

    test('selfCheckInAttendance omits missing coordinates', () async {
      await repository.selfCheckInAttendance(
        eventId: 'event-9',
        latitude: null,
        longitude: null,
      );

      expect(functions.callables['selfCheckInAttendance']!.calls, [
        {'eventId': 'event-9'},
      ]);
    });
  });

  group('EventRepository providers', () {
    late FakeFirebaseFirestore firestore;
    late TestFirebaseFunctions functions;
    late ProviderContainer container;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      functions = TestFirebaseFunctions();
      container = ProviderContainer(
        overrides: [
          firebaseFirestoreProvider.overrideWithValue(firestore),
          firebaseFunctionsProvider.overrideWithValue(functions),
        ],
      );
    });

    tearDown(() => container.dispose());

    test(
      'eventRepositoryProvider builds a repository from Firebase providers',
      () {
        expect(container.read(eventRepositoryProvider), isA<EventRepository>());
      },
    );

    test('watchEventProvider delegates to the repository', () async {
      final event = buildEvent();
      await _seedEvent(firestore, event);

      final provider = watchEventProvider(event.id);
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);

      final value = await container.read(provider.future);

      expect(value, event);
    });

    test(
      'watchEventProvider auto-disposes detail listeners when unwatched',
      () async {
        final event = buildEvent();
        final cancelCompleter = Completer<void>();
        final eventController = StreamController<Event?>(
          onCancel: () {
            if (!cancelCompleter.isCompleted) cancelCompleter.complete();
          },
        );
        addTearDown(() async {
          if (!cancelCompleter.isCompleted) await eventController.close();
        });

        final container = ProviderContainer(
          overrides: [
            eventRepositoryProvider.overrideWith(
              (ref) => _LifecycleEventRepository(
                eventStream: eventController.stream,
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        final provider = watchEventProvider(event.id);
        final subscription = container.listen(provider, (_, _) {});

        eventController.add(event);
        await container.pump();
        expect(subscription.read().value, event);

        subscription.close();
        await container.pump();

        await expectLater(cancelCompleter.future, completes);
      },
    );

    test('watchEventsForClubProvider delegates to the repository', () async {
      final event = buildEvent();
      await _seedEvent(firestore, event);

      final provider = watchEventsForClubProvider('club-1');
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);

      final value = await container.read(provider.future);

      expect(value, [event]);
    });

    test('watchAttendedEventsProvider delegates to the repository', () async {
      final event = buildEvent();
      await _seedEvent(firestore, event);
      await _seedParticipation(
        firestore,
        event: event,
        uid: 'runner-1',
        status: EventParticipationStatus.attended,
      );

      final provider = watchAttendedEventsProvider('runner-1');
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);

      final value = await container.read(provider.future);

      expect(value, [event]);
    });

    test('watchSignedUpEventsProvider delegates to the repository', () async {
      final event = buildEvent();
      await _seedEvent(firestore, event);
      await _seedParticipation(
        firestore,
        event: event,
        uid: 'runner-1',
        status: EventParticipationStatus.signedUp,
      );

      final provider = watchSignedUpEventsProvider('runner-1');
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);

      final value = await container.read(provider.future);

      expect(value, [event]);
    });

    test('watchEventsByIdsProvider delegates to the repository', () async {
      final event = buildEvent();
      await _seedEvent(firestore, event);

      final provider = watchEventsByIdsProvider(
        EventsByIdQuery(const ['event-1']),
      );
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);

      final value = await container.read(provider.future);

      expect(value, [event]);
    });

    testWidgets(
      'watchSignedUpEventsProvider keeps realtime streams alive while idle',
      (tester) async {
        final event = buildEvent(bookedCount: 1);
        final signedUpEventsController = StreamController<List<Event>>();
        addTearDown(signedUpEventsController.close);

        final container = ProviderContainer(
          overrides: [
            eventRepositoryProvider.overrideWith(
              (ref) => _IdleEventRepository(
                signedUpEventsStream: signedUpEventsController.stream,
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        final provider = watchSignedUpEventsProvider('runner-1');
        final subscription = container.listen(provider, (_, _) {});
        addTearDown(subscription.close);

        signedUpEventsController.add([event]);
        await container.pump();
        expect(subscription.read().value, [event]);

        await tester.pump(_pastLegacyStreamTimeout);
        await container.pump();

        expect(subscription.read(), isA<AsyncData<List<Event>>>());
        expect(subscription.read().value, [event]);
      },
    );

    test('recommendedEventsProvider delegates to the repository', () async {
      final event = buildEvent();
      await _seedEvent(firestore, event);

      final results = await container.read(
        recommendedEventsProvider(
          RecommendedEventsQuery.fromClubIds(const ['club-1']),
        ).future,
      );

      expect(results, [event]);
    });
  });
}

Future<void> _seedEvent(FakeFirebaseFirestore firestore, Event event) {
  return firestore.collection('events').doc(event.id).set(event.toJson());
}

Future<void> _seedParticipation(
  FakeFirebaseFirestore firestore, {
  required Event event,
  required String uid,
  required EventParticipationStatus status,
}) {
  final now = DateTime(2026);
  final participation = EventParticipation(
    id: eventParticipationId(eventId: event.id, uid: uid),
    eventId: event.id,
    clubId: event.clubId,
    uid: uid,
    status: status,
    createdAt: now,
    updatedAt: now,
  );
  return firestore
      .collection('eventParticipations')
      .doc(participation.id)
      .set(participation.toJson());
}

class _IdleEventRepository extends Fake implements EventRepository {
  _IdleEventRepository({required this.signedUpEventsStream});

  final Stream<List<Event>> signedUpEventsStream;

  @override
  Stream<List<Event>> watchSignedUpEvents({required String uid}) =>
      signedUpEventsStream;
}

class _LifecycleEventRepository extends Fake implements EventRepository {
  _LifecycleEventRepository({required this.eventStream});

  final Stream<Event?> eventStream;

  @override
  Stream<Event?> watchEvent(String id) => eventStream;
}

const _pastLegacyStreamTimeout = Duration(seconds: 11);
