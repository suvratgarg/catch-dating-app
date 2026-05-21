import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_success_assignment.dart';
import 'package:catch_dating_app/event_success/domain/event_success_compatibility_response.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/domain/event_success_wingman_request.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart'
    show buildEvent, buildEventParticipation, buildPublicProfile, buildUser;

void main() {
  group('EventSuccessRepository', () {
    late FakeFirebaseFirestore firestore;
    late TestFirebaseFunctions functions;
    late EventSuccessRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      functions = TestFirebaseFunctions();
      repository = EventSuccessRepository(
        firestore,
        EventParticipationRepository(firestore),
        PublicProfileRepository(firestore),
        functions: functions,
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
      final draft = plan.hostDraft.toggleModule('wingman_requests');

      await repository.savePlan(
        plan.copyWithDraft(draft, updatedAt: plan.updatedAt),
      );
      await repository.updateActiveStep(eventId: event.id, activeStepIndex: 2);

      final saved = await repository.watchPlan(event.id).first;
      expect(saved, isNotNull);
      expect(saved!.activeStepIndex, 2);
      expect(saved.status, EventSuccessPlanStatus.live);
      expect(saved.hasModule('wingman_requests'), isFalse);
    });

    test('persists host-controlled live reveal state', () async {
      final event = buildEvent(id: 'event-1');
      await repository.ensurePlanForEvent(event);

      await repository.startLiveRevealCountdown(
        eventId: event.id,
        roundIndex: 1,
        countdownSeconds: 10,
      );

      final countingDown = await repository.watchPlan(event.id).first;
      expect(countingDown?.status, EventSuccessPlanStatus.live);
      expect(countingDown?.revealStatus, EventSuccessRevealStatus.countingDown);
      expect(countingDown?.activeRevealRoundIndex, 1);
      expect(countingDown?.revealStartedAt, isNotNull);
      expect(
        countingDown!.revealEndsAt!.isAfter(countingDown.revealStartedAt!),
        isTrue,
      );

      await repository.revealLiveRound(eventId: event.id, roundIndex: 1);

      final revealed = await repository.watchPlan(event.id).first;
      expect(revealed?.revealStatus, EventSuccessRevealStatus.revealed);
      expect(revealed?.isRoundRevealed(1, DateTime.now()), isTrue);

      await repository.resetLiveReveal(eventId: event.id);

      final reset = await repository.watchPlan(event.id).first;
      expect(reset?.revealStatus, EventSuccessRevealStatus.idle);
      expect(reset?.activeRevealRoundIndex, 0);
      expect(reset?.revealStartedAt, isNull);
      expect(reset?.revealEndsAt, isNull);
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

    test('saves attendee micro-pod opt-out preference', () async {
      final event = buildEvent(id: 'event-1', clubId: 'club-1');

      await repository.setMicroPodsOptOut(
        event: event,
        uid: 'runner-1',
        optedOut: true,
      );

      final saved = await repository
          .watchPreferenceForUser(eventId: event.id, uid: 'runner-1')
          .first;
      expect(saved?.id, 'event-1_runner-1');
      expect(saved?.clubId, 'club-1');
      expect(saved?.microPodsOptedOut, isTrue);

      await repository.setMicroPodsOptOut(
        event: event,
        uid: 'runner-1',
        optedOut: false,
      );

      final eventPreferences = await repository
          .watchPreferencesForEvent(event.id)
          .first;
      expect(eventPreferences.single.microPodsOptedOut, isFalse);
    });

    test(
      'saves guided-rotation opt-out without clearing micro-pod preference',
      () async {
        final event = buildEvent(id: 'event-1', clubId: 'club-1');

        await repository.setMicroPodsOptOut(
          event: event,
          uid: 'runner-1',
          optedOut: true,
        );
        await repository.setGuidedRotationsOptOut(
          event: event,
          uid: 'runner-1',
          optedOut: true,
        );

        final saved = await repository
            .watchPreferenceForUser(eventId: event.id, uid: 'runner-1')
            .first;
        expect(saved?.microPodsOptedOut, isTrue);
        expect(saved?.guidedRotationsOptedOut, isTrue);

        await repository.setGuidedRotationsOptOut(
          event: event,
          uid: 'runner-1',
          optedOut: false,
        );

        final updated = await repository
            .watchPreferenceForUser(eventId: event.id, uid: 'runner-1')
            .first;
        expect(updated?.microPodsOptedOut, isTrue);
        expect(updated?.guidedRotationsOptedOut, isFalse);
      },
    );

    test('saves attendee compatibility questionnaire answers', () async {
      final event = buildEvent(id: 'event-1', clubId: 'club-1');

      await repository.saveCompatibilityResponse(
        event: event,
        uid: 'runner-1',
        answerIds: const [
          'event_energy_new_people',
          'first_conversation_activity',
          'unknown-answer',
        ],
      );

      final saved = await repository
          .watchCompatibilityResponseForUser(eventId: event.id, uid: 'runner-1')
          .first;
      expect(
        saved?.id,
        eventSuccessCompatibilityResponseId(eventId: event.id, uid: 'runner-1'),
      );
      expect(saved?.clubId, 'club-1');
      expect(saved?.answerIds, [
        'event_energy_new_people',
        'first_conversation_activity',
      ]);

      await repository.saveCompatibilityResponse(
        event: event,
        uid: 'runner-1',
        answerIds: const ['event_energy_playful_competition'],
      );

      final updated = await repository
          .watchCompatibilityResponseForUser(eventId: event.id, uid: 'runner-1')
          .first;
      expect(updated?.createdAt, saved?.createdAt);
      expect(updated?.answerIds, ['event_energy_playful_competition']);
    });

    test(
      'saves and withdraws an explicit host-visible wingman request',
      () async {
        final event = buildEvent(id: 'event-1', clubId: 'club-1');
        final target = buildPublicProfile(uid: 'runner-2', name: 'Riya');

        await repository.saveWingmanRequest(
          event: event,
          requesterUid: 'runner-1',
          target: target,
          note: 'Please help us land in the same rotation.',
        );

        final saved = await repository
            .watchWingmanRequestForUser(eventId: event.id, uid: 'runner-1')
            .first;
        expect(saved?.id, 'event-1_runner-1');
        expect(saved?.targetUid, 'runner-2');
        expect(saved?.status, EventSuccessWingmanRequestStatus.active);
        expect(saved?.hostVisibleConsent, isTrue);
        expect(saved?.note, 'Please help us land in the same rotation.');

        final eventRequests = await repository
            .watchWingmanRequestsForEvent(event.id)
            .first;
        expect(eventRequests.single.requesterUid, 'runner-1');

        await repository.withdrawWingmanRequest(
          event: event,
          requesterUid: 'runner-1',
        );

        final withdrawn = await repository
            .watchWingmanRequestForUser(eventId: event.id, uid: 'runner-1')
            .first;
        expect(withdrawn?.status, EventSuccessWingmanRequestStatus.withdrawn);
        expect(withdrawn?.targetUid, 'runner-2');

        final activeRequests = await repository
            .watchWingmanRequestsForEvent(event.id)
            .first;
        expect(activeRequests, isEmpty);
      },
    );

    test(
      'watches server-owned micro-pod assignments for one attendee',
      () async {
        final now = DateTime(2026, 5, 21, 8);
        final assignment = EventSuccessAssignment(
          id: eventSuccessAssignmentId(
            eventId: 'event-1',
            moduleId: EventSuccessModuleCatalog.microPods.id,
            uid: 'runner-1',
          ),
          eventId: 'event-1',
          clubId: 'club-1',
          uid: 'runner-1',
          moduleId: EventSuccessModuleCatalog.microPods.id,
          label: 'Pod A',
          displayTitle: 'Pod A',
          displaySubtitle: '4 people in this event pod.',
          peerUids: const ['runner-2', 'runner-3', 'runner-4'],
          source: 'server_v1',
          createdAt: now,
          updatedAt: now,
        );
        await firestore
            .collection('eventSuccessAssignments')
            .doc(assignment.id)
            .set(assignment.toJson());

        final saved = await repository
            .watchAssignmentForUser(eventId: 'event-1', uid: 'runner-1')
            .first;

        expect(saved?.displayTitle, 'Pod A');
        expect(saved?.peerUids, ['runner-2', 'runner-3', 'runner-4']);
      },
    );

    test(
      'watches server-owned guided rotation assignments for event and attendee',
      () async {
        final now = DateTime(2026, 5, 21, 8);
        final rotationAssignment = EventSuccessAssignment(
          id: eventSuccessAssignmentId(
            eventId: 'event-1',
            moduleId: EventSuccessModuleCatalog.guidedRotations.id,
            uid: 'runner-1',
          ),
          eventId: 'event-1',
          clubId: 'club-1',
          uid: 'runner-1',
          moduleId: EventSuccessModuleCatalog.guidedRotations.id,
          label: 'Guided rotations',
          displayTitle: '2 guided rotations',
          displaySubtitle: '15-minute pairings during the event.',
          peerUids: const ['runner-2'],
          rotationSlots: [
            EventSuccessRotationSlot(
              roundIndex: 0,
              label: 'Round 1',
              startsAt: now,
              endsAt: now.add(const Duration(minutes: 15)),
              peerUid: 'runner-2',
              compatibility: 'mutual_interest',
            ),
          ],
          source: 'server_v1',
          createdAt: now,
          updatedAt: now,
        );
        await firestore
            .collection('eventSuccessAssignments')
            .doc(rotationAssignment.id)
            .set(rotationAssignment.toJson());

        final savedForUser = await repository
            .watchRotationAssignmentForUser(eventId: 'event-1', uid: 'runner-1')
            .first;
        final savedForEvent = await repository
            .watchRotationAssignmentsForEvent(eventId: 'event-1')
            .first;

        expect(savedForUser?.displayTitle, '2 guided rotations');
        expect(savedForUser?.rotationSlots.single.peerUid, 'runner-2');
        expect(savedForEvent.single.uid, 'runner-1');
      },
    );

    test(
      'calls guided rotation override callable with round payload',
      () async {
        await repository.overrideGuidedRotations(
          eventId: 'event-1',
          rounds: const [
            EventSuccessRotationOverrideRound(
              roundIndex: 0,
              pairings: [
                EventSuccessRotationOverridePair(
                  uidA: 'runner-1',
                  uidB: 'runner-2',
                ),
              ],
            ),
          ],
        );

        final callable =
            functions.httpsCallable('overrideEventSuccessRotations')
                as TestHttpsCallable;
        expect(callable.calls, [
          {
            'eventId': 'event-1',
            'rounds': [
              {
                'roundIndex': 0,
                'pairings': [
                  {'uidA': 'runner-1', 'uidB': 'runner-2'},
                ],
              },
            ],
          },
        ]);
      },
    );

    test(
      'fetches wingman request candidates from attended participants only',
      () async {
        final event = buildEvent(id: 'event-1');
        await _seedParticipation(
          firestore,
          buildEventParticipation(
            event: event,
            uid: 'runner-1',
            status: EventParticipationStatus.attended,
            genderAtSignup: Gender.man,
            cohortAtSignup: EventCohortIds.menInterestedInWomen,
          ),
        );
        await _seedParticipation(
          firestore,
          buildEventParticipation(
            event: event,
            uid: 'runner-2',
            status: EventParticipationStatus.attended,
            genderAtSignup: Gender.woman,
            cohortAtSignup: EventCohortIds.womenInterestedInMen,
          ),
        );
        await _seedParticipation(
          firestore,
          buildEventParticipation(
            event: event,
            uid: 'runner-3',
            status: EventParticipationStatus.signedUp,
            genderAtSignup: Gender.woman,
            cohortAtSignup: EventCohortIds.womenInterestedInMen,
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

        final candidates = await repository.fetchWingmanRequestCandidates(
          eventId: event.id,
          currentUser: buildUser(
            uid: 'runner-1',
            gender: Gender.man,
            interestedInGenders: const [Gender.woman],
          ),
        );

        expect(candidates.map((profile) => profile.uid), ['runner-2']);
      },
    );

    test(
      'filters wingman request candidates by viewer interest and signup cohort',
      () async {
        final event = buildEvent(id: 'event-1');
        await _seedParticipation(
          firestore,
          buildEventParticipation(
            event: event,
            uid: 'viewer',
            status: EventParticipationStatus.attended,
            genderAtSignup: Gender.woman,
            cohortAtSignup: EventCohortIds.womenInterestedInMen,
          ),
        );
        await _seedParticipation(
          firestore,
          buildEventParticipation(
            event: event,
            uid: 'compatible-man',
            status: EventParticipationStatus.attended,
            genderAtSignup: Gender.man,
            cohortAtSignup: EventCohortIds.menInterestedInWomen,
          ),
        );
        await _seedParticipation(
          firestore,
          buildEventParticipation(
            event: event,
            uid: 'incompatible-woman',
            status: EventParticipationStatus.attended,
            genderAtSignup: Gender.woman,
            cohortAtSignup: EventCohortIds.womenInterestedInMen,
          ),
        );
        await _seedParticipation(
          firestore,
          buildEventParticipation(
            event: event,
            uid: 'man-not-seeking-women',
            status: EventParticipationStatus.attended,
            genderAtSignup: Gender.man,
            cohortAtSignup: EventCohortIds.queerOrOpen,
          ),
        );
        await firestore
            .collection('publicProfiles')
            .doc('compatible-man')
            .set(
              buildPublicProfile(
                uid: 'compatible-man',
                name: 'Arjun',
                gender: Gender.man,
              ).toJson(),
            );
        await firestore
            .collection('publicProfiles')
            .doc('incompatible-woman')
            .set(
              buildPublicProfile(
                uid: 'incompatible-woman',
                name: 'Riya',
                gender: Gender.woman,
              ).toJson(),
            );
        await firestore
            .collection('publicProfiles')
            .doc('man-not-seeking-women')
            .set(
              buildPublicProfile(
                uid: 'man-not-seeking-women',
                name: 'Kabir',
                gender: Gender.man,
              ).toJson(),
            );

        final candidates = await repository.fetchWingmanRequestCandidates(
          eventId: event.id,
          currentUser: buildUser(
            uid: 'viewer',
            gender: Gender.woman,
            interestedInGenders: const [Gender.man],
          ),
        );

        expect(candidates.map((profile) => profile.uid), ['compatible-man']);
      },
    );
  });
}

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

  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async {
    calls.add(parameters);
    return TestHttpsCallableResult<T>(null as T);
  }
}

class TestHttpsCallableResult<T> extends Fake
    implements HttpsCallableResult<T> {
  TestHttpsCallableResult(this.dataValue);

  final T dataValue;

  @override
  T get data => dataValue;
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
