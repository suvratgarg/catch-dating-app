import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/swipes/data/swipe_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart'
    show buildEvent, buildEventParticipation, buildPublicProfile;

void main() {
  group('EventSuccessRepository', () {
    late FakeFirebaseFirestore firestore;
    late EventSuccessRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = EventSuccessRepository(
        firestore,
        EventParticipationRepository(firestore),
        PublicProfileRepository(firestore),
        SwipeRepository(firestore),
      );
    });

    test('creates a default host plan for an event once', () async {
      final event = buildEvent(id: 'event-1', capacityLimit: 28);

      final plan = await repository.ensurePlanForEvent(event);
      final samePlan = await repository.ensurePlanForEvent(event);

      expect(plan.eventId, 'event-1');
      expect(plan.clubId, event.clubId);
      expect(plan.targetAttendeeCount, 28);
      expect(plan.playbookId, EventSuccessPlaybookLibrary.socialRun.id);
      expect(plan.selectedModuleIds, contains('qr_check_in'));
      expect(samePlan.createdAt, plan.createdAt);
    });

    test('saves host setup and live step updates', () async {
      final event = buildEvent(id: 'event-1');
      final plan = await repository.ensurePlanForEvent(event);
      final draft = plan.hostDraft.toggleModule('private_crush');

      await repository.savePlan(
        plan.copyWithDraft(draft, updatedAt: plan.updatedAt),
      );
      await repository.updateActiveStep(eventId: event.id, activeStepIndex: 2);

      final saved = await repository.watchPlan(event.id).first;
      expect(saved, isNotNull);
      expect(saved!.activeStepIndex, 2);
      expect(saved.status, EventSuccessPlanStatus.live);
      expect(saved.hasModule('private_crush'), isFalse);
    });

    test('writes attendee feedback under stable event-user id', () async {
      final event = buildEvent(id: 'event-1');
      final now = DateTime(2026, 5, 18, 12);
      final feedback = EventSuccessFeedback(
        id: eventSuccessFeedbackId(eventId: event.id, uid: 'runner-1'),
        eventId: event.id,
        clubId: event.clubId,
        uid: 'runner-1',
        welcomeRating: 5,
        structureRating: 4,
        metNewPeopleCount: 3,
        markedPrivateCrush: true,
        safetyConcern: false,
        createdAt: now,
        updatedAt: now,
      );

      await repository.submitFeedback(feedback);

      final saved = await repository
          .watchFeedbackForUser(eventId: event.id, uid: 'runner-1')
          .first;
      expect(saved?.id, 'event-1_runner-1');
      expect(saved?.metNewPeopleCount, 3);
    });

    test(
      'fetches private crush candidates from attended participants only',
      () async {
        final event = buildEvent(id: 'event-1');
        await _seedParticipation(
          firestore,
          buildEventParticipation(
            event: event,
            uid: 'runner-1',
            status: EventParticipationStatus.attended,
          ),
        );
        await _seedParticipation(
          firestore,
          buildEventParticipation(
            event: event,
            uid: 'runner-2',
            status: EventParticipationStatus.attended,
          ),
        );
        await _seedParticipation(
          firestore,
          buildEventParticipation(
            event: event,
            uid: 'runner-3',
            status: EventParticipationStatus.signedUp,
          ),
        );
        await firestore
            .collection('publicProfiles')
            .doc('runner-2')
            .set(buildPublicProfile(uid: 'runner-2', name: 'Rhea').toJson());
        await firestore
            .collection('publicProfiles')
            .doc('runner-3')
            .set(buildPublicProfile(uid: 'runner-3', name: 'Naina').toJson());

        final candidates = await repository.fetchPrivateCrushCandidates(
          eventId: event.id,
          currentUid: 'runner-1',
        );

        expect(candidates.map((profile) => profile.uid), ['runner-2']);
      },
    );

    test('private crush writes through the existing swipe pipeline', () async {
      final target = buildPublicProfile(uid: 'runner-2', name: 'Rhea');

      await repository.markPrivateCrush(
        eventId: 'event-1',
        currentUid: 'runner-1',
        target: target,
      );

      final swipe = await firestore
          .collection('profileDecisions')
          .doc('runner-1')
          .collection('outgoing')
          .doc('runner-2')
          .get();
      expect(swipe.data()?['direction'], 'like');
      expect(swipe.data()?['reactionTargetLabel'], 'Private crush');
    });
  });
}

Future<void> _seedParticipation(
  FakeFirebaseFirestore firestore,
  EventParticipation participation,
) {
  return firestore
      .collection('eventParticipations')
      .doc(participation.id)
      .set(participation.toJson());
}
