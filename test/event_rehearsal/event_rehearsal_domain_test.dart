import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal.dart';
import 'package:catch_dating_app/events/domain/event_itinerary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a bounded isolated rehearsal projection', () {
    final rehearsal = EventRehearsalBootstrap.fromCallableData({
      'session': {
        'id': 'session-1',
        'organizerId': 'organizer-1',
        'sourceEventId': null,
        'scenarioId': 'lateAndNoShow',
        'seed': 42,
        'actorCount': 12,
        'actionCount': 3,
        'status': 'running',
        'setup': {
          'title': 'Practice',
          'locationName': 'Studio',
          'durationMinutes': 120,
          'hostGoal': 'Learn',
          'attendeePrompt': 'Say hello',
          'moduleIds': ['arrival', 'firstHello'],
          'movementSimulation': {
            'itinerary': [
              {
                'id': 'stop-1',
                'kind': 'stop',
                'offsetMinutes': 30,
                'durationMinutes': 20,
                'title': 'Courtyard stop',
              },
            ],
            'routePlan': {
              'version': 2,
              'movementMode': 'walk',
              'routeShape': 'pointToPoint',
              'groupStrategy': 'together',
              'stopCadence': 'hostedStops',
              'stopKinds': ['venue'],
              'roleKinds': ['routeLead'],
              'path': [
                {'latitude': 12.9716, 'longitude': 77.5946},
                {'latitude': 12.975, 'longitude': 77.6},
              ],
              'paceGroups': [],
              'liveTrackingPolicy': {
                'mode': 'hostOnly',
                'staleAfterSeconds': 120,
                'retentionMinutes': 60,
              },
            },
            'livePositions': [
              {
                'role': 'host',
                'latitude': 12.972,
                'longitude': 77.595,
                'recordedOffsetMinutes': 15,
              },
            ],
            'lateArrivalGuidance': 'Meet the group at Courtyard stop.',
          },
        },
        'setupRevision': 1,
        'runtimeRevision': 3,
        'activeStepIndex': 2,
        'virtualNowMillis': 1,
        'faultId': 'none',
        'expiresAtMillis': 86400001,
      },
      'actors': [
        {
          'actorId': 'actor-01',
          'displayName': 'Rhea',
          'persona': 'firstTimer',
          'status': 'present',
          'guestMoment': 'firstHello',
          'optedOut': false,
          'keepApartActorIds': <String>[],
          'helpRequested': false,
          'promptCompleted': false,
        },
      ],
      'actions': [
        {
          'clientActionId': 'action-1',
          'actorId': 'actor-01',
          'kind': 'behavior',
          'name': 'arrive',
          'runtimeRevision': 3,
          'virtualNowMillis': 1,
        },
      ],
      'guestUrl': 'https://catchdates.com/rehearse/public-1',
      'canUseInternalFaults': true,
    });

    expect(rehearsal.session.actionCount, 3);
    expect(rehearsal.session.canEditSetup, isFalse);
    expect(rehearsal.presentCount, 1);
    expect(rehearsal.unresolvedCount, 0);
    expect(rehearsal.canUseInternalFaults, isTrue);
    final movement = rehearsal.session.setup.movementSimulation;
    expect(movement, isNotNull);
    expect(movement!.itinerary.single.kind, EventItineraryKind.stop);
    expect(movement.routePlan?.version, 2);
    expect(movement.routePlan?.path, hasLength(2));
    expect(movement.livePositions.single.role, 'host');
    expect(
      rehearsal.session.setup.toJson()['movementSimulation'],
      isA<Map<String, Object?>>(),
    );
  });

  test('rejects malformed callable projections', () {
    expect(
      () => EventRehearsalBootstrap.fromCallableData(const {}),
      throwsFormatException,
    );
  });

  test('maps reserved behavior wire values explicitly', () {
    expect(EventRehearsalBehavior.returnActor.wireValue, 'return');
    expect(EventRehearsalBehavior.arriveLate.wireValue, 'arriveLate');
  });
}
