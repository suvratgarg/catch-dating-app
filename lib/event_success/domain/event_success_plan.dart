import 'dart:math' as math;

import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/event_success/domain/event_success_assignment.dart';
import 'package:catch_dating_app/event_success/domain/event_success_coach.dart';
import 'package:catch_dating_app/event_success/domain/event_success_compatibility_response.dart';
import 'package:catch_dating_app/event_success/domain/event_success_feature_state.dart';
import 'package:catch_dating_app/event_success/domain/event_success_models.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/domain/event_success_preference.dart';
import 'package:catch_dating_app/event_success/domain/event_success_structure.dart';
import 'package:catch_dating_app/event_success/domain/event_success_wingman_request.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_success_plan.freezed.dart';
part 'event_success_plan.g.dart';

enum EventSuccessPlanStatus { setup, live, complete }

enum EventSuccessRevealStatus { idle, countingDown, revealed }

@freezed
abstract class EventSuccessPlan with _$EventSuccessPlan {
  const EventSuccessPlan._();

  const factory EventSuccessPlan({
    @JsonKey(includeToJson: false) required String id,
    required String eventId,
    required String clubId,
    required String playbookId,
    required List<String> selectedModuleIds,
    required int targetAttendeeCount,
    @Default(EventSuccessStructureConfig.legacyDefault())
    EventSuccessStructureConfig structureConfig,
    required String hostGoal,
    @Default(true) bool wingmanRequestsEnabled,
    @Default(true) bool contextualOpenersEnabled,
    @Default(false) bool compatibilityAffectsRanking,
    @Default(EventSuccessQuestionnaireConfig.defaultTemplate())
    EventSuccessQuestionnaireConfig questionnaireConfig,
    @Default(0) int activeStepIndex,
    @Default(EventSuccessPlanStatus.setup) EventSuccessPlanStatus status,
    @Default(EventSuccessRevealStatus.idle)
    EventSuccessRevealStatus revealStatus,
    @Default(0) int activeRevealRoundIndex,
    @NullableTimestampConverter() DateTime? revealStartedAt,
    @NullableTimestampConverter() DateTime? revealEndsAt,
    String? attendeePrompt,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
    @NullableTimestampConverter() DateTime? frozenAt,
    @NullableTimestampConverter() DateTime? completedAt,
  }) = _EventSuccessPlan;

  factory EventSuccessPlan.fromJson(Map<String, dynamic> json) =>
      _$EventSuccessPlanFromJson(json);

  factory EventSuccessPlan.defaultForEvent(Event event, {DateTime? now}) {
    final createdAt = now ?? DateTime.now();
    final draft = EventSuccessHostDraft.fromActivity(
      event.activityKind,
      targetAttendeeCount: math.max(1, event.capacityLimit),
    );
    return EventSuccessPlan.fromDraft(
      id: event.id,
      eventId: event.id,
      clubId: event.clubId,
      draft: draft,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }

  factory EventSuccessPlan.fromDraft({
    required String id,
    required String eventId,
    required String clubId,
    required EventSuccessHostDraft draft,
    required DateTime createdAt,
    required DateTime updatedAt,
    int activeStepIndex = 0,
    EventSuccessPlanStatus status = EventSuccessPlanStatus.setup,
    DateTime? frozenAt,
    DateTime? completedAt,
    String? attendeePrompt,
  }) {
    return EventSuccessPlan(
      id: id,
      eventId: eventId,
      clubId: clubId,
      playbookId: draft.playbook.id,
      selectedModuleIds: _stableModuleIds(draft.selectedModuleIds),
      targetAttendeeCount: draft.targetAttendeeCount,
      structureConfig: draft.structureConfig,
      hostGoal: draft.hostGoal,
      wingmanRequestsEnabled: draft.wingmanRequestsEnabled,
      contextualOpenersEnabled: draft.contextualOpenersEnabled,
      compatibilityAffectsRanking: draft.compatibilityAffectsRanking,
      questionnaireConfig: draft.questionnaireConfig,
      activeStepIndex: activeStepIndex,
      status: status,
      attendeePrompt: attendeePrompt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      frozenAt: frozenAt,
      completedAt: completedAt,
    );
  }

  EventSuccessPlaybook get playbook =>
      EventSuccessPlaybookLibrary.byIdOrDefault(playbookId);

  EventSuccessHostDraft get hostDraft => EventSuccessHostDraft(
    playbook: playbook,
    selectedModuleIds: selectedModuleIds
        .where(playbook.moduleIds.contains)
        .toSet(),
    targetAttendeeCount: targetAttendeeCount,
    structureConfig: structureConfig,
    hostGoal: hostGoal,
    wingmanRequestsEnabled: wingmanRequestsEnabled,
    contextualOpenersEnabled: contextualOpenersEnabled,
    compatibilityAffectsRanking: compatibilityAffectsRanking,
    questionnaireConfig: questionnaireConfig,
  );

  List<EventSuccessModule> get selectedModules => playbook.modules
      .where((module) => selectedModuleIds.contains(module.id))
      .toList(growable: false);

  bool hasModule(String moduleId) => selectedModuleIds.contains(moduleId);

  bool get liveRevealConfigured =>
      hasModule(EventSuccessModuleCatalog.liveReveal.id);

  bool isRevealCountdownRunning(DateTime now) =>
      revealStatus == EventSuccessRevealStatus.countingDown &&
      revealEndsAt != null &&
      revealEndsAt!.isAfter(now);

  Duration revealRemaining(DateTime now) {
    final endsAt = revealEndsAt;
    if (endsAt == null || !endsAt.isAfter(now)) return Duration.zero;
    return endsAt.difference(now);
  }

  double revealProgress(DateTime now) {
    if (revealStatus == EventSuccessRevealStatus.revealed) return 1;
    final startedAt = revealStartedAt;
    final endsAt = revealEndsAt;
    if (revealStatus != EventSuccessRevealStatus.countingDown ||
        startedAt == null ||
        endsAt == null ||
        !endsAt.isAfter(startedAt)) {
      return 0;
    }
    final totalMs = endsAt.difference(startedAt).inMilliseconds;
    final elapsedMs = now.difference(startedAt).inMilliseconds;
    return (elapsedMs / totalMs).clamp(0, 1).toDouble();
  }

  int revealedThroughRoundIndex(DateTime now) {
    final activeIndex = math.max(0, activeRevealRoundIndex);
    return switch (revealStatus) {
      EventSuccessRevealStatus.idle => -1,
      EventSuccessRevealStatus.revealed => activeIndex,
      EventSuccessRevealStatus.countingDown =>
        isRevealCountdownRunning(now) ? activeIndex - 1 : activeIndex,
    };
  }

  bool isRoundRevealed(int roundIndex, DateTime now) =>
      roundIndex <= revealedThroughRoundIndex(now);

  int? nextRevealRoundIndex({required int roundCount, required DateTime now}) {
    if (roundCount <= 0) return null;
    final nextIndex = revealedThroughRoundIndex(now) + 1;
    if (nextIndex >= roundCount) return null;
    return math.max(0, nextIndex);
  }

  bool allRevealRoundsShown({required int roundCount, required DateTime now}) =>
      roundCount > 0 &&
      nextRevealRoundIndex(roundCount: roundCount, now: now) == null;

  EventSuccessPlan copyWithDraft(
    EventSuccessHostDraft draft, {
    required DateTime updatedAt,
  }) {
    return copyWith(
      playbookId: draft.playbook.id,
      selectedModuleIds: _stableModuleIds(draft.selectedModuleIds),
      targetAttendeeCount: draft.targetAttendeeCount,
      structureConfig: draft.structureConfig,
      hostGoal: draft.hostGoal,
      wingmanRequestsEnabled: draft.wingmanRequestsEnabled,
      contextualOpenersEnabled: draft.contextualOpenersEnabled,
      compatibilityAffectsRanking: draft.compatibilityAffectsRanking,
      questionnaireConfig: draft.questionnaireConfig,
      updatedAt: updatedAt,
    );
  }

  EventSuccessLivePlan livePlan({
    required int bookedCount,
    required int checkedInCount,
  }) {
    return EventSuccessLivePlan.fromDraft(
      hostDraft,
      activeStepIndex: activeStepIndex,
      bookedCount: bookedCount,
      checkedInCount: checkedInCount,
    );
  }

  String attendeePromptFor(Event event) {
    final configured = attendeePrompt?.trim();
    if (configured != null && configured.isNotEmpty) return configured;
    return playbook.activityType.isMovementHeavy
        ? 'Find someone running your pace and ask what route they want to try next.'
        : 'Find someone near you and ask what brought them here.';
  }

  EventSuccessBrief buildBrief({
    required Event event,
    required List<EventSuccessFeedback> feedback,
    List<EventSuccessAssignment> assignments = const [],
    List<EventSuccessAssignment> rotationAssignments = const [],
    List<EventSuccessPreference> preferences = const [],
    List<EventSuccessWingmanRequest> wingmanRequests = const [],
  }) {
    final assignedUids = _assignmentParticipantUids([
      ...assignments,
      ...rotationAssignments,
    ]);
    final optedOutUids = preferences
        .where(
          (preference) =>
              preference.microPodsOptedOut ||
              preference.guidedRotationsOptedOut,
        )
        .map((preference) => preference.uid)
        .toSet();
    final scorecard = EventSuccessScorecard(
      bookedCount: event.signedUpCount,
      checkedInCount: event.attendedCount,
      attendeesWhoMetTwoPlusPeople: feedback
          .where((item) => item.metNewPeopleCount >= 2)
          .length,
      mutualMatchCount: 0,
      chatStartedCount: 0,
      repeatSignupCount: 0,
      averageWelcomeRating: _averageRating(
        feedback.map((item) => item.welcomeRating),
      ),
      averageStructureRating: _averageRating(
        feedback.map((item) => item.structureRating),
      ),
      safetyIncidentCount: feedback.where((item) => item.safetyConcern).length,
      feedbackResponseCount: feedback.length,
      assignmentParticipantCount: assignedUids.length,
      assignmentOptOutCount: optedOutUids.length,
      wingmanRequestCount: wingmanRequests
          .where((request) => request.isActive)
          .length,
    );
    return const EventSuccessCoach().analyze(
      playbook: playbook,
      scorecard: scorecard,
    );
  }
}

Set<String> _assignmentParticipantUids(
  Iterable<EventSuccessAssignment> assignments,
) {
  final uids = <String>{};
  for (final assignment in assignments) {
    uids.add(assignment.uid);
    uids.addAll(assignment.peerUids);
    for (final slot in assignment.rotationSlots) {
      uids.add(slot.peerUid);
    }
  }
  return uids;
}

@freezed
abstract class EventSuccessFeedback with _$EventSuccessFeedback {
  const factory EventSuccessFeedback({
    @JsonKey(includeToJson: false) required String id,
    required String eventId,
    required String clubId,
    required String uid,
    required int welcomeRating,
    required int structureRating,
    required int metNewPeopleCount,
    @Default(false) bool safetyConcern,
    String? privateNote,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _EventSuccessFeedback;

  factory EventSuccessFeedback.fromJson(Map<String, dynamic> json) =>
      _$EventSuccessFeedbackFromJson(json);
}

String eventSuccessFeedbackId({required String eventId, required String uid}) =>
    '${eventId}_$uid';

List<String> _stableModuleIds(Iterable<String> ids) {
  final values = ids.toSet().toList()..sort();
  return List.unmodifiable(values);
}

double _averageRating(Iterable<int> ratings) {
  final valid = ratings.where((rating) => rating > 0).toList();
  if (valid.isEmpty) return 0;
  return valid.reduce((a, b) => a + b) / valid.length;
}
