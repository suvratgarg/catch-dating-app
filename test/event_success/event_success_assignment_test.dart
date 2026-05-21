import 'package:catch_dating_app/event_success/domain/event_success_assignment.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('event success assignment ids are stable by event module and user', () {
    expect(
      eventSuccessAssignmentId(
        eventId: 'event-1',
        moduleId: EventSuccessModuleCatalog.microPods.id,
        uid: 'runner-1',
      ),
      'event-1_micro_pods_runner-1',
    );
  });

  test('decodes Firestore assignment data with document id injected', () {
    final createdAt = DateTime(2026, 5, 21, 8);
    final assignment = EventSuccessAssignment.fromJson({
      'id': 'event-1_micro_pods_runner-1',
      'eventId': 'event-1',
      'clubId': 'club-1',
      'uid': 'runner-1',
      'moduleId': 'micro_pods',
      'label': 'Pod A',
      'displayTitle': 'Pod A',
      'displaySubtitle': '4 people in this event pod.',
      'peerUids': ['runner-2', 'runner-3', 'runner-4'],
      'rotationSlots': [
        <String, Object?>{
          'roundIndex': 0,
          'label': 'Round 1',
          'startsAt': Timestamp.fromDate(createdAt),
          'endsAt': Timestamp.fromDate(
            createdAt.add(const Duration(minutes: 15)),
          ),
          'peerUid': 'runner-2',
          'compatibility': 'mutual_interest',
        },
      ],
      'source': 'server_v1',
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(createdAt),
    });

    expect(assignment.displayTitle, 'Pod A');
    expect(assignment.peerUids, ['runner-2', 'runner-3', 'runner-4']);
    expect(assignment.rotationSlots.single.peerUid, 'runner-2');
    expect(assignment.rotationSlots.single.compatibility, 'mutual_interest');
    expect(assignment.toJson(), isNot(contains('id')));
  });
}
