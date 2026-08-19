import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal.dart';
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
