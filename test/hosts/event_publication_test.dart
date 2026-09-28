import 'dart:async';
import 'dart:convert';

import 'package:catch_dating_app/hosts/data/event_publication_journal.dart';
import 'package:catch_dating_app/hosts/data/event_publication_repository.dart';
import 'package:catch_dating_app/hosts/data/private_event_setup_repository.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/event_publication_controller.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

PrivateEventBasicSummary publicationEvent({
  int revision = 2,
  String state = 'private',
  bool ready = true,
}) => PrivateEventBasicSummary(
  eventId: 'event1',
  organizerId: 'org1',
  setupRevision: revision,
  name: 'Sunday dinner',
  city: const EventSetupCity(cityId: 'in-mp-indore', marketId: 'in-mp-indore'),
  localDate: '2030-03-17',
  localStartTime: '19:00',
  timezone: 'Asia/Kolkata',
  startTimeMillis: 1900000000000,
  status: 'active',
  setupDefaults: const {},
  detailsConfigured: true,
  eventPreferences: null,
  publicationState: state,
  publicationReadiness: EventPublicationReadiness(
    canPublish: ready && state == 'private',
    missing: ready ? const [] : const ['venue'],
  ),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'lost response replays exact intent and rereads current visibility',
    () async {
      var current = publicationEvent();
      final commands = <String>[];
      var calls = 0;
      Future<EventPublicationReceipt> write(
        EventPublicationRequest request,
      ) async {
        commands.add(jsonEncode(request.toJson()));
        calls++;
        if (calls == 1) {
          current = publicationEvent(revision: 3, state: 'published');
          throw StateError('response lost');
        }
        if (calls == 2) throw StateError('manager temporarily unavailable');
        return const EventPublicationReceipt(
          eventId: 'event1',
          setupRevision: 3,
          publicationState: 'published',
          replayed: true,
        );
      }

      EventPublicationController make() => EventPublicationController(
        userId: 'host1',
        organizerId: 'org1',
        eventId: 'event1',
        read: ({required organizerId, required eventId}) async => current,
        write: write,
        currentUserId: () => 'host1',
      );
      final first = make();
      await first.load();
      await first.changeTo('published');
      expect(first.pending, isNotNull);
      expect(first.canUnpublish, isFalse);
      first.dispose();
      final reopened = make();
      addTearDown(reopened.dispose);
      await reopened.load();
      expect(reopened.event?.publicationState, 'published');
      expect(reopened.canUnpublish, isFalse);
      await reopened.retry();
      expect(reopened.pending, isNotNull);
      // Another manager made the event private after the original publish.
      current = publicationEvent(revision: 4);
      await reopened.retry();
      expect(commands, everyElement(commands.first));
      expect(reopened.pending, isNull);
      expect(reopened.event?.publicationState, 'private');
      expect(reopened.event?.setupRevision, 4);
      expect(reopened.canPublish, isTrue);
    },
  );

  test(
    'only exact stale-rejection proof clears uncertain publication',
    () async {
      var exact = false;
      final controller = EventPublicationController(
        userId: 'host1',
        organizerId: 'org1',
        eventId: 'event1',
        read: ({required organizerId, required eventId}) async =>
            publicationEvent(),
        currentUserId: () => 'host1',
        write: (request) async {
          throw FirebaseFunctionsException(
            message: 'Review changed',
            code: 'aborted',
            details: exact
                ? {
                    'reason': 'event-publication-review-stale',
                    ...request.toJson(),
                  }
                : {
                    'reason': 'event-publication-review-stale',
                    'requestId': 'wrong',
                  },
          );
        },
      );
      addTearDown(controller.dispose);
      await controller.load();
      await controller.changeTo('published');
      expect(controller.pending, isNotNull);
      exact = true;
      await controller.retry();
      expect(controller.pending, isNull);
      expect(controller.canPublish, isTrue);
      expect(
        await const EventPublicationJournal().load(
          userId: 'host1',
          organizerId: 'org1',
          eventId: 'event1',
        ),
        isNull,
      );
    },
  );

  test(
    'readiness blocks publishing and receipt identity cannot unlock UI',
    () async {
      var ready = false;
      var writes = 0;
      final controller = EventPublicationController(
        userId: 'host1',
        organizerId: 'org1',
        eventId: 'event1',
        read: ({required organizerId, required eventId}) async =>
            publicationEvent(ready: ready),
        currentUserId: () => 'host1',
        write: (_) async {
          writes++;
          return const EventPublicationReceipt(
            eventId: 'other',
            setupRevision: 3,
            publicationState: 'published',
            replayed: false,
          );
        },
      );
      addTearDown(controller.dispose);
      await controller.load();
      await controller.changeTo('published');
      expect(writes, 0);
      ready = true;
      await controller.load();
      await controller.changeTo('published');
      expect(controller.pending, isNotNull);
      expect(controller.error, isA<FormatException>());
    },
  );

  test(
    'account switch discards late results and preserves original journal',
    () async {
      var uid = 'host1';
      final response = Completer<EventPublicationReceipt>();
      final invoked = Completer<void>();
      final controller = EventPublicationController(
        userId: 'host1',
        organizerId: 'org1',
        eventId: 'event1',
        read: ({required organizerId, required eventId}) async =>
            publicationEvent(),
        currentUserId: () => uid,
        write: (_) {
          invoked.complete();
          return response.future;
        },
      );
      addTearDown(controller.dispose);
      await controller.load();
      final save = controller.changeTo('published');
      await invoked.future;
      uid = 'host2';
      controller.invalidateActor();
      response.complete(
        const EventPublicationReceipt(
          eventId: 'event1',
          setupRevision: 3,
          publicationState: 'published',
          replayed: false,
        ),
      );
      await save;
      expect(controller.event, isNull);
      expect(controller.receipt, isNull);
      expect(controller.canChange, isFalse);
      expect(
        await const EventPublicationJournal().load(
          userId: 'host1',
          organizerId: 'org1',
          eventId: 'event1',
        ),
        isNotNull,
      );
    },
  );

  test('publication request journal rejects unknown authority fields', () {
    const request = EventPublicationRequest(
      organizerId: 'org1',
      eventId: 'event1',
      requestId: 'publication-one',
      expectedSetupRevision: 2,
      publicationState: 'published',
    );
    expect(
      EventPublicationRequest.fromJson(request.toJson()).toJson(),
      request.toJson(),
    );
    expect(
      () => EventPublicationRequest.fromJson({
        ...request.toJson(),
        'bypass': true,
      }),
      throwsFormatException,
    );
    expect(
      () => EventPublicationReadiness.fromResponse({
        'canPublish': true,
        'missing': ['venue'],
      }),
      throwsFormatException,
    );
  });
}
