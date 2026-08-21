import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/event_rehearsal_runtime_adapter.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
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
          'layoutUnitId': 'table-2',
          'confirmedLayoutUnitId': 'table-2',
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

  test('projects rehearsal state into the canonical Host runtime', () {
    final rehearsal = EventRehearsalBootstrap.fromCallableData({
      'session': {
        'id': 'session-runtime',
        'organizerId': 'organizer-1',
        'sourceEventId': null,
        'scenarioId': 'lateAndNoShow',
        'seed': 7,
        'actorCount': 8,
        'actionCount': 1,
        'status': 'running',
        'setup': {
          'title': 'Sunday mixer',
          'locationName': 'Courtyard',
          'durationMinutes': 90,
          'hostGoal': 'Learn the runtime',
          'attendeePrompt': 'Meet someone new',
          'moduleIds': ['arrival', 'rotations'],
        },
        'setupRevision': 1,
        'runtimeRevision': 4,
        'activeStepIndex': 1,
        'virtualNowMillis': 100000,
        'faultId': 'none',
        'expiresAtMillis': 900000,
      },
      'actors': [
        {
          'actorId': 'actor-present',
          'displayName': 'Maya',
          'persona': 'firstTimer',
          'status': 'present',
          'guestMoment': 'assignment',
          'optedOut': false,
          'keepApartActorIds': <String>[],
          'helpRequested': false,
          'promptCompleted': false,
          'layoutUnitId': 'table-2',
          'confirmedLayoutUnitId': 'table-2',
        },
        {
          'actorId': 'actor-late',
          'displayName': 'Jordan',
          'persona': 'lateArrival',
          'status': 'late',
          'guestMoment': 'assignment',
          'optedOut': false,
          'keepApartActorIds': <String>[],
          'helpRequested': false,
          'promptCompleted': false,
        },
      ],
      'actions': <Map<String, Object?>>[],
      'guestUrl': 'https://catchdates.com/rehearse/public-runtime',
      'canUseInternalFaults': true,
    });

    final runtime = buildEventRehearsalRuntimeProjection(
      rehearsal,
      practiceGuestLabel: 'Practice guest',
      latePracticeGuestLabel: 'Late arrival · Practice guest',
    );

    expect(runtime.event.synthetic, isTrue);
    expect(runtime.plan.status, EventSuccessPlanStatus.live);
    expect(runtime.plan.liveControlRevision, 4);
    expect(runtime.roster.checkedInIds, ['actor-present', 'actor-late']);
    expect(runtime.layout.units, hasLength(2));
    expect(runtime.assignments, hasLength(2));
    expect(runtime.assignments.first.confirmedLayoutUnitId, isNotNull);
    expect(runtime.assignments.first.layoutUnitId, 'table-2');
    expect(runtime.assignments.last.confirmedLayoutUnitId, isNull);
    expect(runtime.presence.lateArrivals.single.uid, 'actor-late');
  });
}
