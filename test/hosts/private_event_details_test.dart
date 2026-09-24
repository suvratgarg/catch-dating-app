import 'dart:convert';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/hosts/data/manager_event_setup_defaults_repository.dart';
import 'package:catch_dating_app/hosts/data/manager_event_setup_preferences.dart';
import 'package:catch_dating_app/hosts/data/private_event_details_journal.dart';
import 'package:catch_dating_app/hosts/data/private_event_details_repository.dart';
import 'package:catch_dating_app/hosts/data/private_event_setup_repository.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/private_event_details_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('partial details preserve inherit, set and clear without implied values', () {
    const details = PrivateEventDetailsPatch(
      durationMinutes: EventSetupValue.inherit(),
      venue: EventSetupValue.set('Town Hall'),
      eventFormat: EventSetupValue.clear(),
    );
    expect(details.toJson(), {
      'durationMinutes': {'mode': 'inherit'},
      'venue': {'mode': 'set', 'value': {'name': 'Town Hall'}},
      'eventFormat': {'mode': 'clear'},
    });
    expect(PrivateEventDetailsPatch.fromJson(details.toJson()).toJson(),
        details.toJson());
    expect(const PrivateEventDetailsPatch().isValid, isFalse);
    expect(const PrivateEventDetailsPatch(
      durationMinutes: EventSetupValue.set(14)).isValid, isFalse);
    expect(const PrivateEventDetailsPatch(
      durationMinutes: EventSetupValue.set(241)).isValid, isFalse);
    expect(const PrivateEventDetailsPatch(
      eventFormat: EventSetupValue.inherit()).isValid, isFalse);
    final format = EventFormatSnapshot.fromActivityKind(ActivityKind.dinner);
    final formatPatch = PrivateEventDetailsPatch(
      eventFormat: EventSetupValue.set(format));
    expect(PrivateEventDetailsPatch.fromJson(formatPatch.toJson())
        .eventFormat!.value!.activityKind, ActivityKind.dinner);
  });

  test('lost response, revocation and reopen replay one exact journaled command',
      () async {
    final hash = List.filled(64, 'a').join();
    var serverRevision = 2;
    var attempts = 0;
    final sentBodies = <String>[];
    final defaults = ManagerEventSetupDefaults(
      organizerId: 'club-1', cityId: 'in-mh-mumbai',
      marketId: 'in-mh-mumbai', timezone: 'Asia/Kolkata',
      organizerDefaultsRevision: 1, basicsReviewedHash: hash,
      preferencesRevision: 1,
      preferences: const ManagerEventSetupPreferences(
        usualDurationMinutes: 90),
      preferencesHash: hash, reviewedDefaultsHash: hash,
    );
    PrivateEventBasicSummary read() => PrivateEventBasicSummary(
      eventId: 'event-1', organizerId: 'club-1',
      setupRevision: serverRevision, name: 'Saturday mixer',
      city: const EventSetupCity(cityId: 'in-mh-mumbai',
        marketId: 'in-mh-mumbai'),
      localDate: '2026-10-03', localStartTime: '19:00',
      timezone: 'Asia/Kolkata', startTimeMillis: 1791043800000,
      status: 'active', setupDefaults: const {},
      detailsConfigured: serverRevision > 2, eventPreferences: null,
      eventDetails: PrivateEventDetailsSnapshot(
        endTimeMillis: serverRevision > 2 ? 1791049200000 : null),
    );
    Future<PrivateEventCreateReceipt> write(
        PrivateEventDetailsUpdateRequest request) async {
      sentBodies.add(jsonEncode(request.toJson()));
      attempts++;
      if (attempts == 1) {
        serverRevision = 3;
        throw StateError('Response lost after commit');
      }
      if (attempts == 2) {
        throw StateError('Manager access temporarily revoked');
      }
      return const PrivateEventCreateReceipt(
        eventId: 'event-1', setupRevision: 3, replayed: true);
    }
    PrivateEventDetailsController controller() =>
        PrivateEventDetailsController(
          userId: 'host-1', organizerId: 'club-1', eventId: 'event-1',
          readEvent: ({required organizerId, required eventId}) async => read(),
          readDefaults: (_) async => defaults,
          write: write,
        );
    final first = controller();
    await first.load();
    await first.save(const PrivateEventDetailsPatch(
      durationMinutes: EventSetupValue.inherit()));
    expect(first.pending, isNotNull);
    expect(first.canEdit, isFalse);
    final journal = const PrivateEventDetailsJournal();
    final persisted = await journal.load(userId: 'host-1',
      organizerId: 'club-1', eventId: 'event-1');
    expect(persisted?.toJson(), first.pending!.toJson());
    first.dispose();

    final reopened = controller();
    await reopened.load();
    expect(reopened.pending?.toJson(), persisted?.toJson());
    await reopened.retryPending();
    expect(reopened.pending, isNotNull);
    expect(reopened.canEdit, isFalse);
    await reopened.retryPending();
    expect(reopened.pending, isNull);
    expect(reopened.event!.setupRevision, 3);
    expect(sentBodies, everyElement(sentBodies.first));
    expect(await journal.load(userId: 'host-1', organizerId: 'club-1',
      eventId: 'event-1'), isNull);
    reopened.dispose();
  });
}
