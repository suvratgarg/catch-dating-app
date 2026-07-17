import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/event_success/domain/event_success_assignment.dart';
import 'package:catch_dating_app/event_success/domain/event_success_feature_state.dart';
import 'package:catch_dating_app/event_success/domain/event_success_models.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/event_success/domain/event_success_preference.dart';
import 'package:catch_dating_app/event_success/domain/event_success_wingman_request.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';

enum EventSuccessHostTab { setup, live, report }

enum EventSuccessHostSectionStatus { loading, error, ready }

enum EventSuccessHostRetryIntent {
  plan,
  roster,
  assignments,
  rotationAssignments,
  assignmentParticipantProfiles,
  rotationParticipantProfiles,
  preferences,
  wingmanRequests,
  wingmanProfiles,
  scorecard,
}

class EventSuccessSetupActionState {
  const EventSuccessSetupActionState({this.isSaving = false, this.error});

  factory EventSuccessSetupActionState.resolve({
    required bool ensurePending,
    required bool savePending,
    Object? ensureError,
    Object? saveError,
  }) {
    return EventSuccessSetupActionState(
      isSaving: ensurePending || savePending,
      error: saveError ?? ensureError,
    );
  }

  final bool isSaving;
  final Object? error;

  bool get hasError => error != null;
}

class EventSuccessSetupSaveRequest {
  const EventSuccessSetupSaveRequest({
    required this.event,
    required this.plan,
    required this.planIsPersisted,
    required this.draft,
    required this.attendeePrompt,
  });

  final Event event;
  final EventSuccessPlan plan;
  final bool planIsPersisted;
  final EventSuccessHostDraft draft;
  final String attendeePrompt;
}

class EventSuccessLiveActionState {
  const EventSuccessLiveActionState({
    this.isChangingStep = false,
    this.isCompleting = false,
    this.stepError,
    this.completeError,
  });

  factory EventSuccessLiveActionState.resolve({
    required bool stepPending,
    required bool completePending,
    Object? stepError,
    Object? completeError,
  }) {
    return EventSuccessLiveActionState(
      isChangingStep: stepPending,
      isCompleting: completePending,
      stepError: stepError,
      completeError: completeError,
    );
  }

  final bool isChangingStep;
  final bool isCompleting;
  final Object? stepError;
  final Object? completeError;
}

class EventSuccessAssignmentGenerationActionState {
  const EventSuccessAssignmentGenerationActionState({
    this.isGenerating = false,
    this.error,
  });

  factory EventSuccessAssignmentGenerationActionState.resolve({
    required bool pending,
    Object? error,
  }) {
    return EventSuccessAssignmentGenerationActionState(
      isGenerating: pending,
      error: error,
    );
  }

  final bool isGenerating;
  final Object? error;
}

class EventSuccessHostSectionState {
  const EventSuccessHostSectionState._({
    required this.status,
    required this.plan,
    required this.planIsPersisted,
    required this.roster,
    required this.scorecard,
    required this.assignments,
    required this.assignmentParticipantProfiles,
    required this.rotationAssignments,
    required this.rotationParticipantProfiles,
    required this.preferences,
    required this.wingmanRequests,
    required this.wingmanProfiles,
    this.error,
    this.retryIntent,
  });

  factory EventSuccessHostSectionState.resolve({
    required Event event,
    required DateTime now,
    required CatchAsyncState<EventSuccessPlan?> planState,
    required CatchAsyncState<EventParticipationRoster> rosterState,
    required CatchAsyncState<EventSuccessScorecard?> scorecardState,
    required CatchAsyncState<List<EventSuccessAssignment>> assignmentsState,
    required CatchAsyncState<List<PublicProfile>>
    assignmentParticipantProfilesState,
    required CatchAsyncState<List<EventSuccessAssignment>>
    rotationAssignmentsState,
    required CatchAsyncState<List<PublicProfile>>
    rotationParticipantProfilesState,
    required CatchAsyncState<List<EventSuccessPreference>> preferencesState,
    required CatchAsyncState<List<EventSuccessWingmanRequest>>
    wingmanRequestsState,
    required CatchAsyncState<List<PublicProfile>> wingmanProfilesState,
  }) {
    final persistedPlan = planState.value;
    final plan =
        persistedPlan ?? EventSuccessPlan.defaultForEvent(event, now: now);
    final fallback = EventSuccessHostSectionState._(
      status: EventSuccessHostSectionStatus.ready,
      plan: plan,
      planIsPersisted:
          planState.status == CatchAsyncStatus.data && persistedPlan != null,
      roster: rosterState.value ?? EventParticipationRoster.empty(),
      scorecard: scorecardState.value,
      assignments: assignmentsState.value ?? const <EventSuccessAssignment>[],
      assignmentParticipantProfiles:
          assignmentParticipantProfilesState.value ?? const <PublicProfile>[],
      rotationAssignments:
          rotationAssignmentsState.value ?? const <EventSuccessAssignment>[],
      rotationParticipantProfiles:
          rotationParticipantProfilesState.value ?? const <PublicProfile>[],
      preferences: preferencesState.value ?? const <EventSuccessPreference>[],
      wingmanRequests:
          wingmanRequestsState.value ?? const <EventSuccessWingmanRequest>[],
      wingmanProfiles: wingmanProfilesState.value ?? const <PublicProfile>[],
    );

    if (_hasLoadingEventSuccessHostState([
      planState,
      rosterState,
      scorecardState,
      assignmentsState,
      assignmentParticipantProfilesState,
      rotationAssignmentsState,
      rotationParticipantProfilesState,
      preferencesState,
      wingmanRequestsState,
      wingmanProfilesState,
    ])) {
      return fallback.copyWith(status: EventSuccessHostSectionStatus.loading);
    }

    final error = _firstEventSuccessHostError([
      (planState, EventSuccessHostRetryIntent.plan),
      (rosterState, EventSuccessHostRetryIntent.roster),
      (assignmentsState, EventSuccessHostRetryIntent.assignments),
      (
        rotationAssignmentsState,
        EventSuccessHostRetryIntent.rotationAssignments,
      ),
      (
        assignmentParticipantProfilesState,
        EventSuccessHostRetryIntent.assignmentParticipantProfiles,
      ),
      (
        rotationParticipantProfilesState,
        EventSuccessHostRetryIntent.rotationParticipantProfiles,
      ),
      (preferencesState, EventSuccessHostRetryIntent.preferences),
      (wingmanRequestsState, EventSuccessHostRetryIntent.wingmanRequests),
      (wingmanProfilesState, EventSuccessHostRetryIntent.wingmanProfiles),
      (scorecardState, EventSuccessHostRetryIntent.scorecard),
    ]);
    if (error != null) {
      return fallback.copyWith(
        status: EventSuccessHostSectionStatus.error,
        error: error.$1,
        retryIntent: error.$2,
      );
    }

    return fallback;
  }

  final EventSuccessHostSectionStatus status;
  final EventSuccessPlan plan;
  final bool planIsPersisted;
  final EventParticipationRoster roster;
  final EventSuccessScorecard? scorecard;
  final List<EventSuccessAssignment> assignments;
  final List<PublicProfile> assignmentParticipantProfiles;
  final List<EventSuccessAssignment> rotationAssignments;
  final List<PublicProfile> rotationParticipantProfiles;
  final List<EventSuccessPreference> preferences;
  final List<EventSuccessWingmanRequest> wingmanRequests;
  final List<PublicProfile> wingmanProfiles;
  final Object? error;
  final EventSuccessHostRetryIntent? retryIntent;

  EventSuccessHostSectionState copyWith({
    EventSuccessHostSectionStatus? status,
    Object? error,
    EventSuccessHostRetryIntent? retryIntent,
  }) {
    return EventSuccessHostSectionState._(
      status: status ?? this.status,
      plan: plan,
      planIsPersisted: planIsPersisted,
      roster: roster,
      scorecard: scorecard,
      assignments: assignments,
      assignmentParticipantProfiles: assignmentParticipantProfiles,
      rotationAssignments: rotationAssignments,
      rotationParticipantProfiles: rotationParticipantProfiles,
      preferences: preferences,
      wingmanRequests: wingmanRequests,
      wingmanProfiles: wingmanProfiles,
      error: error ?? this.error,
      retryIntent: retryIntent ?? this.retryIntent,
    );
  }
}

bool _hasLoadingEventSuccessHostState(
  Iterable<CatchAsyncState<dynamic>> states,
) {
  return states.any((state) => state.status == CatchAsyncStatus.loading);
}

(Object, EventSuccessHostRetryIntent)? _firstEventSuccessHostError(
  Iterable<(CatchAsyncState<dynamic>, EventSuccessHostRetryIntent)> values,
) {
  for (final (value, intent) in values) {
    if (value.status == CatchAsyncStatus.error && value.error != null) {
      return (value.error!, intent);
    }
  }
  return null;
}
