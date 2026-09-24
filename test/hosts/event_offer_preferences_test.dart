import 'package:catch_dating_app/hosts/data/event_offer_preferences_journal.dart';
import 'package:catch_dating_app/hosts/data/event_offer_preferences_repository.dart';
import 'package:catch_dating_app/hosts/data/manager_event_setup_defaults_repository.dart';
import 'package:catch_dating_app/hosts/data/manager_event_setup_preferences.dart';
import 'package:catch_dating_app/hosts/data/private_event_preferences_repository.dart';
import 'package:catch_dating_app/hosts/data/private_event_setup_repository.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/event_offer_preferences_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final hash = List.filled(64, 'a').join();

  EventOfferConfiguration configuration(int revision) => revision > 0
      ? const EventOfferConfiguration(
          organizerId: 'club-1', eventId: 'event-1',
          eventSourceRevision: 8, startsAtMillis: 1791043800000,
          nowMillis: 1790000000000, suggestedExpiresAtMillis: null,
          preferencesRevision: 1, preferences: null,
        )
      : EventOfferConfiguration.fromResponse({
        'organizerId': 'club-1', 'eventId': 'event-1',
        'eventSourceRevision': 8, 'startsAtMillis': 1791043800000,
        'nowMillis': 1790000000000, 'suggestedExpiresAtMillis': null,
        'preferencesRevision': revision, 'preferences': null,
        'paymentTerms': null,
      });
  ManagerEventSetupDefaults defaults() => ManagerEventSetupDefaults(
    organizerId: 'club-1', cityId: 'in-mh-mumbai',
    marketId: 'in-mh-mumbai', timezone: 'Asia/Kolkata',
    organizerDefaultsRevision: 1, basicsReviewedHash: hash,
    preferencesRevision: 1,
    preferences: const ManagerEventSetupPreferences(
      timezone: 'Asia/Kolkata', currency: 'INR',
    ),
    preferencesHash: hash, reviewedDefaultsHash: hash,
  );
  EventOfferPreferencesUpdateRequest request(String id) =>
      EventOfferPreferencesUpdateRequest(
        organizerId: 'club-1', eventId: 'event-1', requestId: id,
        expectedEventSourceRevision: 8, expectedPreferencesRevision: 0,
        reviewedDefaultsHash: hash,
        intents: const PrivateEventPreferenceIntents(
          currency: EventSetupValue.set('INR'),
          expectedAmountMinor: EventSetupValue.set(120000),
        ),
      );

  test('published event read and write reject malformed authority receipts', () {
    final projection = configuration(0);
    expect(projection.eventSourceRevision, 8);
    expect(projection.preferences, isNull);
    expect(() => EventOfferConfiguration.fromResponse({
      'organizerId': 'club-1', 'eventId': 'event-1',
      'eventSourceRevision': 8, 'startsAtMillis': 1791043800000,
      'nowMillis': 1790000000000, 'suggestedExpiresAtMillis': null,
      'preferencesRevision': 1, 'preferences': null,
      'paymentTerms': null,
    }), throwsFormatException);
    expect(() => EventOfferPreferencesReceipt.fromResponse({
      'eventId': 'event-1', 'preferencesRevision': 1,
      'replayed': 'false',
    }), throwsFormatException);
    final body = request('request-1').toJson();
    expect(body['expectedEventSourceRevision'], 8);
    expect(body['reviewedDefaultsHash'], hash);
    expect((body['intents'] as Map)['expectedAmountMinor'],
        {'mode': 'set', 'value': 120000});
    expect(EventOfferPreferencesUpdateRequest.fromJson(body).toJson(), body);
  });

  test('lost reply, denied retry and reopen preserve the exact command', () async {
    var attempts = 0;
    final sent = <Map<String, Object?>>[];
    Future<EventOfferPreferencesReceipt> write(
        EventOfferPreferencesUpdateRequest value) async {
      sent.add(value.toJson());
      attempts++;
      if (attempts == 1) throw StateError('response lost');
      if (attempts == 2) throw StateError('permission denied');
      return const EventOfferPreferencesReceipt(
        eventId: 'event-1', preferencesRevision: 1, replayed: true,
      );
    }
    EventOfferPreferencesController controller() =>
        EventOfferPreferencesController(
          userId: 'host-1', organizerId: 'club-1', eventId: 'event-1',
          readConfiguration: ({required organizerId, required eventId}) async =>
              configuration(attempts >= 3 ? 1 : 0),
          readDefaults: (_) async => defaults(), write: write,
        );
    final first = controller();
    await first.load();
    await first.save(request('request-1').intents);
    expect(first.canEdit, isFalse);
    final frozen = first.pending!.toJson();
    first.dispose();

    final reopened = controller();
    await reopened.load();
    expect(reopened.pending?.toJson(), frozen);
    await reopened.retryPending();
    expect(reopened.pending?.toJson(), frozen);
    await reopened.retryPending();
    expect(sent, everyElement(frozen));
    expect(reopened.pending, isNull);
    expect(await const EventOfferPreferencesJournal().load(
      userId: 'host-1', organizerId: 'club-1', eventId: 'event-1',
    ), isNull);
    reopened.dispose();
  });
}
