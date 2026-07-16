import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_success_arrival_mission.dart';
import 'package:catch_dating_app/event_success/domain/event_success_assignment.dart';
import 'package:catch_dating_app/event_success/domain/event_success_compatibility_response.dart';
import 'package:catch_dating_app/event_success/domain/event_success_feature_state.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/data/event_check_in_location_service.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_success_controller.g.dart';

@riverpod
class EventSuccessController extends _$EventSuccessController {
  static final ensurePlanMutation = Mutation<EventSuccessPlan>();
  static final saveSetupMutation = Mutation<void>();
  static final updateStepMutation = Mutation<void>();
  static final startRevealCountdownMutation = Mutation<void>();
  static final revealRoundMutation = Mutation<void>();
  static final resetRevealMutation = Mutation<void>();
  static final completePlanMutation = Mutation<void>();
  static final feedbackMutation = Mutation<void>();
  static final compatibilityResponseMutation = Mutation<void>();
  static final firstHelloStartMutation = Mutation<void>();
  static final firstHelloCompleteMutation = Mutation<void>();
  static final wingmanRequestMutation = Mutation<void>();
  static final generateMicroPodsMutation = Mutation<void>();
  static final generateGuidedRotationsMutation = Mutation<void>();
  static final overrideGuidedRotationsMutation = Mutation<void>();
  static final overrideGroupAssignmentsMutation = Mutation<void>();
  static final microPodsOptOutMutation = Mutation<void>();
  static final guidedRotationsOptOutMutation = Mutation<void>();

  @override
  void build() {}

  Future<EventSuccessPlan> ensurePlan(Event event) async {
    requireSignedInUid(ref, action: 'set up the live event guide');
    return ref.read(eventSuccessRepositoryProvider).ensurePlanForEvent(event);
  }

  Future<void> saveSetup({
    required EventSuccessPlan plan,
    required EventSuccessHostDraft draft,
    String? attendeePrompt,
  }) async {
    requireSignedInUid(ref, action: 'save the live event guide');
    final normalizedPrompt = attendeePrompt?.trim();
    final nextPlan = plan
        .copyWithDraft(draft, updatedAt: DateTime.now())
        .copyWith(
          attendeePrompt: normalizedPrompt == null || normalizedPrompt.isEmpty
              ? null
              : normalizedPrompt,
        );
    await ref
        .read(eventSuccessRepositoryProvider)
        .savePlan(nextPlan, expectedUpdatedAt: plan.updatedAt);
  }

  Future<void> updateActiveStep({
    required String eventId,
    required int activeStepIndex,
  }) async {
    requireSignedInUid(ref, action: 'run live event guide');
    await ref
        .read(eventSuccessRepositoryProvider)
        .updateActiveStep(eventId: eventId, activeStepIndex: activeStepIndex);
  }

  Future<void> startRevealCountdown({
    required String eventId,
    required int roundIndex,
  }) async {
    requireSignedInUid(ref, action: 'start event reveal countdown');
    await ref
        .read(eventSuccessRepositoryProvider)
        .startLiveRevealCountdown(eventId: eventId, roundIndex: roundIndex);
  }

  Future<void> revealRound({
    required String eventId,
    required int roundIndex,
  }) async {
    requireSignedInUid(ref, action: 'reveal event round');
    await ref
        .read(eventSuccessRepositoryProvider)
        .revealLiveRound(eventId: eventId, roundIndex: roundIndex);
  }

  Future<void> resetReveal({required String eventId}) async {
    requireSignedInUid(ref, action: 'reset event reveal');
    await ref
        .read(eventSuccessRepositoryProvider)
        .resetLiveReveal(eventId: eventId);
  }

  Future<void> completePlan(String eventId) async {
    requireSignedInUid(ref, action: 'complete the live event guide');
    await ref
        .read(eventSuccessRepositoryProvider)
        .completePlan(eventId: eventId);
  }

  Future<void> submitFeedback(EventSuccessFeedback feedback) async {
    requireSignedInUid(ref, action: 'submit event feedback');
    await ref.read(eventSuccessRepositoryProvider).submitFeedback(feedback);
  }

  Future<void> saveCompatibilityResponse({
    required Event event,
    required List<String> answerIds,
    EventSuccessQuestionnaireConfig questionnaireConfig =
        const EventSuccessQuestionnaireConfig.defaultTemplate(),
  }) async {
    final uid = requireSignedInUid(ref, action: 'save match clue answers');
    await ref
        .read(eventSuccessRepositoryProvider)
        .saveCompatibilityResponse(
          event: event,
          uid: uid,
          answerIds: EventSuccessCompatibilityQuestionnaire.normalizedAnswerIds(
            answerIds,
            config: questionnaireConfig,
          ),
          questionnaireConfig: questionnaireConfig,
        );
  }

  Future<void> startFirstHelloMission({required Event event}) async {
    requireSignedInUid(ref, action: 'start First Hello check-in');
    final position = await ref
        .read(eventCheckInLocationServiceProvider)
        .getCurrentLocation();
    await ref
        .read(eventSuccessRepositoryProvider)
        .startFirstHelloMission(
          event: event,
          latitude: position.latitude,
          longitude: position.longitude,
        );
  }

  Future<void> completeFirstHelloMission({
    required Event event,
    required EventSuccessArrivalMission mission,
    required String answerId,
  }) async {
    requireSignedInUid(ref, action: 'complete First Hello check-in');
    if (mission.eventId != event.id) {
      throw StateError('First Hello mission does not belong to this event.');
    }
    final position = await ref
        .read(eventCheckInLocationServiceProvider)
        .getCurrentLocation();
    await ref
        .read(eventSuccessRepositoryProvider)
        .completeFirstHelloMission(
          event: event,
          answerId: answerId,
          latitude: position.latitude,
          longitude: position.longitude,
        );
  }

  Future<void> saveWingmanRequest({
    required Event event,
    required PublicProfile target,
    String? note,
  }) async {
    requireSignedInUid(ref, action: 'ask host for help');
    await ref
        .read(eventSuccessRepositoryProvider)
        .saveWingmanRequest(event: event, target: target, note: note);
  }

  Future<void> withdrawWingmanRequest({required Event event}) async {
    requireSignedInUid(ref, action: 'withdraw host help request');
    await ref
        .read(eventSuccessRepositoryProvider)
        .withdrawWingmanRequest(event: event);
  }

  Future<void> generateMicroPods({required String eventId}) async {
    requireSignedInUid(ref, action: 'generate event micro-pods');
    await ref
        .read(eventSuccessRepositoryProvider)
        .generateMicroPodAssignments(eventId: eventId);
  }

  Future<void> generateGuidedRotations({required String eventId}) async {
    requireSignedInUid(ref, action: 'generate event rotations');
    await ref
        .read(eventSuccessRepositoryProvider)
        .generateGuidedRotations(eventId: eventId);
  }

  Future<void> overrideGuidedRotations({
    required String eventId,
    required List<EventSuccessRotationOverrideRound> rounds,
  }) async {
    requireSignedInUid(ref, action: 'override event rotations');
    await ref
        .read(eventSuccessRepositoryProvider)
        .overrideGuidedRotations(eventId: eventId, rounds: rounds);
  }

  Future<void> overrideGroupAssignments({
    required String eventId,
    required List<EventSuccessGroupOverrideRound> rounds,
  }) async {
    requireSignedInUid(ref, action: 'override event groups');
    await ref
        .read(eventSuccessRepositoryProvider)
        .overrideGroupAssignments(eventId: eventId, rounds: rounds);
  }

  Future<void> setMicroPodsOptOut({
    required Event event,
    required bool optedOut,
  }) async {
    final uid = requireSignedInUid(ref, action: 'update micro-pod preference');
    await ref
        .read(eventSuccessRepositoryProvider)
        .setMicroPodsOptOut(event: event, uid: uid, optedOut: optedOut);
  }

  Future<void> setGuidedRotationsOptOut({
    required Event event,
    required bool optedOut,
  }) async {
    final uid = requireSignedInUid(
      ref,
      action: 'update guided rotation preference',
    );
    await ref
        .read(eventSuccessRepositoryProvider)
        .setGuidedRotationsOptOut(event: event, uid: uid, optedOut: optedOut);
  }
}
